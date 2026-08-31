#!/bin/sh
# install-rules.sh — Download and install AI assistant rule files.
#
# Usage:
#   ./install-rules.sh [--force] [target-dir]
#
# If target-dir is provided, rules are installed at project level:
#   <target>/.claude/rules/  <target>/.claude/commands/  <target>/.claude/CLAUDE.md
#
# If omitted, rules are installed globally:
#   ~/.claude/rules/  ~/.claude/commands/  ~/.claude/CLAUDE.md

set -e

REPO="luizjhonata/coding-standards"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
API_URL="https://api.github.com/repos/${REPO}/contents"

# "Overwrite all" is tracked via a marker file so the choice survives subshells.
# The download loop runs in a pipe subshell (`echo | while`) and directory
# recursion runs in its own subshell, so a plain variable set in either would be
# lost. Presence of the marker means "overwrite everything without asking".
OVERWRITE_ALL_MARKER="${TMPDIR:-/tmp}/install-rules-overwrite-all.$$"
rm -f "$OVERWRITE_ALL_MARKER"
trap 'rm -f "$OVERWRITE_ALL_MARKER"' EXIT INT TERM

if [ "${1:-}" = "--force" ]; then
  : > "$OVERWRITE_ALL_MARKER"
  shift
fi

# Determine target directory
if [ -n "${1:-}" ]; then
  TARGET_DIR="$(cd "$1" 2>/dev/null && pwd)" || { echo "Error: directory '$1' does not exist."; exit 1; }
else
  TARGET_DIR="$HOME"
fi

prompt_overwrite() {
  file="$1"
  if [ ! -f "$file" ]; then
    return 0
  fi
  if [ -f "$OVERWRITE_ALL_MARKER" ]; then
    return 0
  fi
  printf "File %s already exists. Overwrite? [y/n/a] " "$file"
  read -r answer </dev/tty
  case "$answer" in
    y|Y) return 0 ;;
    a|A) : > "$OVERWRITE_ALL_MARKER"; return 0 ;;
    *)   return 1 ;;
  esac
}

download_file() {
  url="$1"
  dest="$2"
  dir="$(dirname "$dest")"
  mkdir -p "$dir"
  if prompt_overwrite "$dest"; then
    if curl -fsSL -o "$dest" "$url"; then
      echo "  Installed: $dest"
    else
      echo "  Warning: failed to download $url" >&2
    fi
  else
    echo "  Skipped: $dest"
  fi
}

# download_directory recursively downloads all files from a GitHub directory.
# Args: $1 = remote path (e.g., "claude/rules"), $2 = local base dir (e.g., "$TARGET_DIR/.claude/rules")
download_directory() {
  remote_path="$1"
  local_base="$2"
  response=$(curl -fsSL "${API_URL}/${remote_path}?ref=${BRANCH}" 2>/dev/null) || {
    echo "  Warning: failed to list ${remote_path}" >&2
    return 0
  }

  # Extract entries with their types (file or dir)
  entries=$(echo "$response" | grep -o '"name": *"[^"]*"\|"type": *"[^"]*"' | sed 's/"name": *"//;s/"type": *"//;s/"//')

  # Process pairs of (name, type)
  name=""
  echo "$entries" | while read -r value; do
    if [ -z "$name" ]; then
      name="$value"
    else
      type="$value"
      if [ "$type" = "file" ]; then
        download_file "${BASE_URL}/${remote_path}/${name}" "${local_base}/${name}"
      elif [ "$type" = "dir" ]; then
        # Run recursion in a subshell so it cannot clobber remote_path/local_base
        # in this loop (POSIX sh has no `local`; these vars are global).
        ( download_directory "${remote_path}/${name}" "${local_base}/${name}" )
      fi
      name=""
    fi
  done
}

echo "Installing coding standards into: $TARGET_DIR"
echo ""

# CLAUDE.md
echo "Claude Code CLAUDE.md:"
download_file "${BASE_URL}/claude/CLAUDE.md" "${TARGET_DIR}/.claude/CLAUDE.md"
echo ""

# Claude Code rules (recursive)
echo "Claude Code rules:"
download_directory "claude/rules" "${TARGET_DIR}/.claude/rules"
echo ""

# Claude Code commands (recursive)
echo "Claude Code commands:"
download_directory "claude/commands" "${TARGET_DIR}/.claude/commands"
echo ""

echo "Done."
