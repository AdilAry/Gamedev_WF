#!/usr/bin/env bash
# Update the harness/ folder of a game project to this kit's version.
#   ~/Gamedev_WF/scripts/update-harness.sh ~/games/my-game
# Every game keeps its own copy of harness/ (so it builds on CI and on any
# machine without the kit). After `git pull` on the kit, run this once per
# game, then `./harness/gw.sh check` there and commit "Harness <version>".
# Works on Linux and in Git Bash on Windows.
set -euo pipefail
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$KIT/harness/godot/harness"
GAME="${1:?usage: update-harness.sh <game project folder>}"
DEST="$GAME/harness"

if [[ ! -f "$GAME/project.godot" ]]; then
  echo "no project.godot in $GAME - is this a Godot project?" >&2; exit 2
fi

version_of() { grep -m1 '^HARNESS_VERSION=' "$1" 2>/dev/null | cut -d'"' -f2 || true; }
old="$(version_of "$DEST/gw.sh")"
new="$(version_of "$SRC/gw.sh")"

mkdir -p "$DEST"
for f in "$SRC"/*; do
  name="$(basename "$f")"
  if [[ -f "$DEST/$name" ]] && ! cmp -s "$f" "$DEST/$name"; then
    echo "updated  harness/$name"
  elif [[ ! -f "$DEST/$name" ]]; then
    echo "added    harness/$name"
  fi
  cp "$f" "$DEST/$name"
done
chmod +x "$DEST/gw.sh"

echo "harness ${old:-(unversioned)} -> $new in $GAME"
echo "next: cd \"$GAME\" && ./harness/gw.sh check && ./harness/gw.sh hooks"
echo "then commit: git commit -am \"Harness $new\" (see $KIT/CHANGELOG.md for what changed)"
