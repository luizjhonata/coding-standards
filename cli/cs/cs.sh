# cs — Claude session finder: list recent Claude Code sessions, pick one,
# then cd into its directory and resume it. See ~/.local/bin/claude-sessions.py
cs() {
  local selection dir id
  selection=$(python3 "$HOME/.local/bin/claude-sessions.py" "$@") || return
  [ -z "$selection" ] && return
  dir="${selection%%$'\t'*}"
  id="${selection##*$'\t'}"
  cd "$dir" && claude --resume "$id"
}
