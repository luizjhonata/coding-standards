#!/usr/bin/env python3
"""List recent Claude Code sessions and pick one to resume.

Scans ~/.claude/projects/<encoded-cwd>/<session-id>.jsonl, reading the real
working directory plus the first and last user prompts from each transcript so
you can remember where a session was, what it was about, and — crucially —
where you left off after a reboot.

Usage:
    claude-sessions.py [--list] [--limit N] [FILTER]

Modes:
    default   Print a numbered table to stderr, prompt for a choice on the
              terminal, then print "<cwd>\t<session-id>" to stdout (consumed
              by the `cs` shell function to cd + resume).
    --list    Only print the table (to stdout) and exit; no selection.

FILTER is an optional case-insensitive substring matched against the directory
and both the first and last prompts.
"""

from __future__ import annotations

import json
import sys
import time
from datetime import datetime
from pathlib import Path

PROJECTS_DIR = Path.home() / ".claude" / "projects"
MAX_PROMPT_LEN = 70
WEEKDAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]


def relative_time(epoch: float) -> str:
    """Return a short human-friendly age like '3h' or '2d'."""
    delta = max(0, int(time.time() - epoch))
    for size, suffix in ((86400, "d"), (3600, "h"), (60, "m")):
        if delta >= size:
            return f"{delta // size}{suffix}"
    return f"{delta}s"


def parse_iso(timestamp: str | None) -> datetime | None:
    """Parse an ISO 8601 UTC timestamp into a local-time datetime."""
    if not isinstance(timestamp, str):
        return None
    try:
        parsed = datetime.fromisoformat(timestamp.replace("Z", "+00:00"))
    except ValueError:
        return None
    return parsed.astimezone()


def format_datetime(moment: datetime | None) -> str:
    """Format a datetime as 'Fri 19/06 17:42', padded when unknown."""
    if moment is None:
        return "      ?      "
    return f"{WEEKDAYS[moment.weekday()]} {moment:%d/%m %H:%M}"


def truncate(text: str) -> str:
    """Clip a prompt to MAX_PROMPT_LEN with an ellipsis when needed."""
    if len(text) > MAX_PROMPT_LEN:
        return text[: MAX_PROMPT_LEN - 1] + "…"
    return text


def read_user_text(entry: dict) -> str | None:
    """Return clean prompt text from a user entry, skipping meta/tool noise."""
    if entry.get("type") != "user":
        return None
    content = entry.get("message", {}).get("content")
    if isinstance(content, list):
        content = next(
            (b.get("text") for b in content if isinstance(b, dict) and b.get("text")),
            None,
        )
    if not isinstance(content, str):
        return None
    text = content.strip()
    if not text or text.startswith("<"):
        return None
    return " ".join(text.split())


def extract_session(jsonl_path: Path) -> dict | None:
    """Read a transcript and return its cwd plus first/last prompts and times."""
    cwd = None
    first = None
    last = None
    try:
        with jsonl_path.open(encoding="utf-8") as handle:
            for line in handle:
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if cwd is None and isinstance(entry.get("cwd"), str):
                    cwd = entry["cwd"]
                text = read_user_text(entry)
                if text is None:
                    continue
                moment = parse_iso(entry.get("timestamp"))
                if first is None:
                    first = (text, moment)
                last = (text, moment)
    except OSError:
        return None
    if cwd is None:
        return None
    return {
        "id": jsonl_path.stem,
        "cwd": cwd,
        "first_prompt": first[0] if first else "(no text prompt)",
        "first_dt": first[1] if first else None,
        "last_prompt": last[0] if last else "(no text prompt)",
        "last_dt": last[1] if last else None,
        "mtime": jsonl_path.stat().st_mtime,
    }


def collect_sessions(limit: int, query: str) -> list[dict]:
    """Gather sessions across all projects, newest first, optionally filtered."""
    sessions = []
    for jsonl_path in PROJECTS_DIR.glob("*/*.jsonl"):
        session = extract_session(jsonl_path)
        if session is None:
            continue
        haystack = f"{session['cwd']} {session['first_prompt']} {session['last_prompt']}".lower()
        if query and query not in haystack:
            continue
        sessions.append(session)
    sessions.sort(key=lambda s: s["mtime"], reverse=True)
    return sessions[:limit]


def render_table(sessions: list[dict], stream) -> None:
    """Print a numbered, aligned table of sessions to the given stream."""
    home = str(Path.home())
    for index, session in enumerate(sessions, start=1):
        directory = session["cwd"].replace(home, "~", 1)
        age = relative_time(
            session["last_dt"].timestamp() if session["last_dt"] else session["mtime"]
        )
        print(f"{index:>2}  {directory}  ({age})", file=stream)
        print(
            f"     ↪ start  {format_datetime(session['first_dt'])}:  {truncate(session['first_prompt'])}",
            file=stream,
        )
        print(
            f"     ↩ last   {format_datetime(session['last_dt'])}:  {truncate(session['last_prompt'])}",
            file=stream,
        )


def main() -> int:
    args = sys.argv[1:]
    list_only = "--list" in args
    args = [a for a in args if a != "--list"]
    limit = 20
    if "--limit" in args:
        position = args.index("--limit")
        try:
            limit = int(args[position + 1])
            del args[position : position + 2]
        except (IndexError, ValueError):
            print("error: --limit needs a number", file=sys.stderr)
            return 2
    query = " ".join(args).lower().strip()

    if not PROJECTS_DIR.is_dir():
        print(f"error: {PROJECTS_DIR} not found", file=sys.stderr)
        return 1

    sessions = collect_sessions(limit, query)
    if not sessions:
        print("No sessions found.", file=sys.stderr)
        return 1

    if list_only:
        render_table(sessions, sys.stdout)
        return 0

    render_table(sessions, sys.stderr)
    try:
        with open("/dev/tty", encoding="utf-8") as tty:
            print("\nNumber to resume (Enter to cancel): ", end="", file=sys.stderr)
            sys.stderr.flush()
            choice = tty.readline().strip()
    except OSError:
        return 0
    if not choice:
        return 0
    try:
        chosen = sessions[int(choice) - 1]
    except (ValueError, IndexError):
        print("Invalid selection.", file=sys.stderr)
        return 1
    print(f"{chosen['cwd']}\t{chosen['id']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
