#!/usr/bin/env bash
# Install the Gamedev-WF kit on this machine. Linux and macOS.
# On Windows use scripts\install.ps1 (PowerShell).
#
#     scripts/install.sh [--copy]
#
# Needs the short-loop workflow installed first: its installer sets
# WORKFLOW_DIR, and this kit uses only what that workflow's WORKFLOW.md §8
# ("Building a kit on this workflow") lists.
#
# 1. Sets GAMEDEV_WF in ~/.bashrc so the game commands can find this kit.
# 2. Runs "$WORKFLOW_DIR/install.sh" with this kit's commands/ folder. Result,
#    for Claude Code (and pi, if it is installed): /start /wrap /judge plus the
#    game commands (/spec /harness /qa ...). The commands are LINKED into the
#    two folders, so `git pull` in either one is the whole update.
#    --copy copies them instead (then re-run this after every pull).
# 3. pi only, if pi is installed: registers this folder as a pi package, for
#    the guard extension (for later; see docs/10-pi.md).
# 4. Moves aside the skills that kit versions before 1.4 copied to
#    ~/.claude/skills (a skill with the same name would shadow the new command).
set -euo pipefail
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -z "${WORKFLOW_DIR:-}" || ! -f "${WORKFLOW_DIR:-}/install.sh" ]]; then
  echo "WORKFLOW_DIR is not set, or has no install.sh: '${WORKFLOW_DIR:-}'." >&2
  echo "Install the short-loop workflow first (bash install.sh in its folder sets WORKFLOW_DIR)," >&2
  echo "then open a new terminal (or: source ~/.bashrc) and run this again." >&2
  exit 1
fi

chmod +x "$KIT/harness/godot/harness/gw.sh" "$KIT/example/colony_sim/harness/gw.sh" 2>/dev/null || true
if ! grep -q "GAMEDEV_WF=" "$HOME/.bashrc" 2>/dev/null; then
  echo "export GAMEDEV_WF=\"$KIT\"" >> "$HOME/.bashrc"
  echo "added GAMEDEV_WF=$KIT to ~/.bashrc (open a new terminal)"
fi

# Skills from older kit versions. Only folders that are recognisably the
# kit's are touched, and they are moved, not deleted.
OLD="$HOME/.claude/skills"
ASIDE="$HOME/.claude/skills-replaced-by-gamedev-wf"
for name in asset balance build change-request commission define harness judge pitch playtest qa review spec start style-guide wrap wrap-up; do
  f="$OLD/$name/SKILL.md"
  if [[ -f "$f" ]] && grep -q -E 'gw\.sh|PROGRESS\.md|docs/GDD\.md|docs/LOG\.md|STYLE_GUIDE|ideas/|docs/playtests|docs/changes' "$f"; then
    mkdir -p "$ASIDE"
    rm -rf "${ASIDE:?}/$name"
    mv "$OLD/$name" "$ASIDE/$name"
    echo "moved old skill /$name to $ASIDE/"
  fi
done

bash "$WORKFLOW_DIR/install.sh" "$@" "$KIT/commands"

if command -v pi >/dev/null 2>&1; then
  if pi install "$KIT"; then
    echo "pi: registered the kit as a package (guard extension; see pi list)"
  else
    echo "pi: could not register the kit - run this yourself: pi install \"$KIT\""
  fi
fi
echo "Game commands: /pitch /spec /define /harness /commission /qa /balance /playtest /change-request /style-guide /asset"
echo "Every session:  /start <task> ... /wrap     Fresh-eyes review: /judge"
