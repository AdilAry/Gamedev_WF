# Gamedev-WF kit - instructions for agents working on THIS repo

This repo is a kit (guide + skills + harness + example), not a game. Games
are created in their own folders/repos with the `/harness` skill.

## Layout
- `GUIDE.md`, `docs/`: the human guide. Plain, practical English; the owner is a
  beginner embedded engineer, Godot hobbyist, Claude Pro user, Windows 10
  main laptop + Linux Mint agent box.
- `.claude/skills/<name>/SKILL.md`: skills, installed to `~/.claude/skills` by `scripts/install.*`.
- `harness/godot/harness/`: the canonical harness. **`example/colony_sim/harness/` must
  stay byte-identical** (CI diffs them). After editing the canonical copy:
  `cp harness/godot/harness/* example/colony_sim/harness/`.
- `harness/templates/`: files the skills copy into projects.
- `example/colony_sim/`: reference project; keep its tests green.

## Checks
- `cd example/colony_sim && ./harness/gw.sh check` (needs Godot 4.7.x as `godot` or `$GODOT`).
- CI: `.github/workflows/example-ci.yml` runs the example, canaries, sim runner, screenshots.
- Keep `GODOT_VERSION` the same in both workflow files and the docs when upgrading Godot.

## Conventions
- GDScript 2.0 (Godot 4). Explicit types where a `Variant` is involved; tabs for indentation.
- Harness output stays terse (failures + one summary line): it is read by agents on a usage budget.
- Shell commands in docs: one command per code block, so each can be copied on its own.
