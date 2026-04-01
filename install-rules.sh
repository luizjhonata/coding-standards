#!/bin/sh
# install-rules.sh — Download and install AI assistant rule files.
#
# Usage:
#   ./install-rules.sh [target-dir]
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

OVERWRITE_ALL=""
if [ "${1:-}" = "--force" ]; then
  OVERWRITE_ALL="yes"
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
  if [ "$OVERWRITE_ALL" = "yes" ]; then
    return 0
  fi
  printf "File %s already exists. Overwrite? [y/n/a] " "$file"
  read -r answer </dev/tty
  case "$answer" in
    y|Y) return 0 ;;
    a|A) OVERWRITE_ALL="yes"; return 0 ;;
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

list_remote_entries() {
  path="$1"
  response=$(curl -fsSL "${API_URL}/${path}?ref=${BRANCH}" 2>/dev/null) || {
    echo "Error: failed to list files at ${path}" >&2
    return 1
  }
  echo "$response" \
    | grep -o '"name": *"[^"]*"' \
    | sed 's/"name": *"//;s/"//'
}

echo "Installing coding standards into: $TARGET_DIR"
echo ""

# CLAUDE.md
echo "Claude Code CLAUDE.md:"
download_file "${BASE_URL}/claude/CLAUDE.md" "${TARGET_DIR}/.claude/CLAUDE.md"
echo ""

# Claude Code rules
echo "Claude Code rules:"
for file in $(list_remote_entries "claude/rules"); do
  download_file "${BASE_URL}/claude/rules/${file}" "${TARGET_DIR}/.claude/rules/${file}"
done
echo ""

# Claude Code commands
echo "Claude Code commands:"
for file in $(list_remote_entries "claude/commands"); do
  download_file "${BASE_URL}/claude/commands/${file}" "${TARGET_DIR}/.claude/commands/${file}"
done
echo ""

echo "Done."
