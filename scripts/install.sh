#!/usr/bin/env bash
# Install the Gamedev-WF skills (Linux / macOS / Git Bash).
# - Claude Code: copies .claude/skills/* to ~/.claude/skills/ (available in every project)
# - pi: registers this folder as a pi package (skills + the guard extension).
#   pi loads it from here without copying, so `git pull` is the update.
# - sets GAMEDEV_WF in ~/.bashrc so the skills can find this kit
# Re-run after `git pull` to update the Claude Code copy.
set -euo pipefail
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$HOME/.claude/skills"
mkdir -p "$DEST"
rm -rf "${DEST:?}/wrap-up"   # renamed to wrap in kit 1.3
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
if command -v pi >/dev/null 2>&1; then
  if pi install "$KIT"; then
    echo "registered the kit as a pi package (pi list shows it; skills are /skill:<name> in pi)"
  else
    echo "could not register the kit with pi - run this yourself: pi install \"$KIT\""
  fi
else
  echo "pi not found - skipped. After installing pi, run: pi install \"$KIT\""
fi
echo "done. Game skills: pitch, spec, define, harness, commission, build, qa, balance, playtest, change-request, style-guide, asset"
echo "      Any project: start, wrap, review, judge (see workflow/README.md)"
echo "      Claude Code: type /build ...      pi: type /skill:build ..."
