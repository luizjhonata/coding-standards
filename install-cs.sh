#!/bin/sh
# install-cs.sh — Install the `cs` Claude session finder.
#
# Installs:
#   ~/.local/bin/claude-sessions.py    the session-scanner script
#   a `cs` shell function appended to your shell rc (~/.zshrc or ~/.bashrc)
#
# Usage:
#   ./install-cs.sh [--force] [rc-file]
#   curl -fsSL <raw>/install-cs.sh | sh
#   curl -fsSL <raw>/install-cs.sh | sh -s -- ~/.config/zsh/.zshrc
#
# Requires: python3 (3.7+) and the `claude` CLI in PATH.

set -e

REPO="luizjhonata/coding-standards"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

BIN_DIR="$HOME/.local/bin"
SCRIPT_DEST="$BIN_DIR/claude-sessions.py"

FORCE=""
if [ "${1:-}" = "--force" ]; then
  FORCE="yes"
  shift
fi

# Determine the shell rc file to add the function to.
if [ -n "${1:-}" ]; then
  RC_FILE="$1"
else
  case "$(basename "${SHELL:-}")" in
    zsh)  RC_FILE="$HOME/.zshrc" ;;
    bash) RC_FILE="$HOME/.bashrc" ;;
    *)    RC_FILE="$HOME/.profile" ;;
  esac
fi

echo "Installing the cs Claude session finder..."
echo ""

# 1. Check prerequisites.
if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 is required but was not found in PATH." >&2
  exit 1
fi
echo "  python3 found: $(python3 -c 'import sys; print("%d.%d.%d" % sys.version_info[:3])')"

if ! command -v claude >/dev/null 2>&1; then
  echo "  Warning: 'claude' CLI not found in PATH — cs needs it to resume sessions." >&2
fi

# 2. Install the scanner script.
mkdir -p "$BIN_DIR"
install_script="yes"
if [ -f "$SCRIPT_DEST" ] && [ "$FORCE" != "yes" ]; then
  printf "  %s already exists. Overwrite? [y/N] " "$SCRIPT_DEST"
  read -r answer </dev/tty
  case "$answer" in
    y|Y) ;;
    *)   install_script="no" ;;
  esac
fi
if [ "$install_script" = "yes" ]; then
  if curl -fsSL -o "$SCRIPT_DEST" "${BASE_URL}/cli/cs/claude-sessions.py"; then
    chmod +x "$SCRIPT_DEST"
    echo "  Installed: $SCRIPT_DEST"
  else
    echo "Error: failed to download claude-sessions.py" >&2
    exit 1
  fi
else
  echo "  Skipped: $SCRIPT_DEST"
fi

# 3. Add the cs function to the rc file (idempotent).
if grep -q "claude-sessions.py" "$RC_FILE" 2>/dev/null; then
  echo "  cs function already present in $RC_FILE — skipping."
else
  function_body=$(curl -fsSL "${BASE_URL}/cli/cs/cs.sh") || {
    echo "Error: failed to download cs.sh" >&2
    exit 1
  }
  printf "\n%s\n" "$function_body" >> "$RC_FILE"
  echo "  Added cs function to $RC_FILE"
fi

echo ""
echo "Done. Restart your shell or run: source $RC_FILE"
