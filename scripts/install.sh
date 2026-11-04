#!/usr/bin/env bash
# Install the Gamedev-WF skills for Claude Code (Linux / macOS / Git Bash).
# - copies .claude/skills/* to ~/.claude/skills/ (available in every project)
# - sets GAMEDEV_WF in ~/.bashrc so the skills can find this kit
# Re-run after `git pull` to update the skills.
set -euo pipefail
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$HOME/.claude/skills"
mkdir -p "$DEST"
for d in "$KIT"/.claude/skills/*/; do
  name="$(basename "$d")"
  rm -rf "${DEST:?}/$name"
  cp -r "$d" "$DEST/$name"
  echo "installed skill /$name"
done
if ! grep -q "GAMEDEV_WF=" "$HOME/.bashrc" 2>/dev/null; then
  echo "export GAMEDEV_WF=\"$KIT\"" >> "$HOME/.bashrc"
  echo "added GAMEDEV_WF=$KIT to ~/.bashrc (open a new terminal)"
fi
chmod +x "$KIT/harness/godot/harness/gw.sh" "$KIT/example/colony_sim/harness/gw.sh" 2>/dev/null || true
echo "done. In Claude Code type / to see: pitch, define, harness, commission, build, playtest, balance, change-request, style-guide, asset, wrap-up"
