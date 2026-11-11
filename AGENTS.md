# Gamedev-WF kit - instructions for agents working on THIS repo

(`AGENTS.md` is the instruction file; `CLAUDE.md` only imports it, so Claude
Code, pi and other agents all read the same text.)

This repo is a kit (guide + skills + harness + example), not a game. Games
are created in their own folders/repos with the `/harness` skill.

## Layout
- `GUIDE.md`, `docs/`: the human guide. Plain, practical English; the owner is a
  beginner embedded engineer, Godot hobbyist, Claude Pro user who also uses
  the pi coding agent, Windows 10 main laptop + Linux Mint agent box. They
  design their games in detail themselves and want short, human-checked loops.
- `.claude/skills/<name>/SKILL.md`: skills (Agent Skills format). Claude Code
  gets a copy in `~/.claude/skills` from `scripts/install.*`; pi loads them
  from here through the `pi` manifest in `package.json`. Keep them
  agent-neutral: say "AGENTS.md", never rely on a tool only one agent has.
- `pi/extensions/gamedev-wf-guard/`: pi extension. Decisions live in
  `rules.ts` (no pi imports) and are tested with `npm test`.
- `harness/godot/harness/`: the canonical harness. **`example/colony_sim/harness/` must
  stay byte-identical** (CI diffs them). After editing the canonical copy:
  `cp harness/godot/harness/* example/colony_sim/harness/`.
- When the harness changes: bump `HARNESS_VERSION` in `gw.sh` and add a
  `CHANGELOG.md` entry that says what existing games must do.
- `harness/templates/`: files the skills copy into projects.
- `example/colony_sim/`: reference project; keep its tests green.

## Checks
- `cd example/colony_sim && ./harness/gw.sh check` (needs Godot 4.7.x as `godot` or `$GODOT`).
- `npm test` (Node 22.18+): the pi guard's rules.
- CI: `.github/workflows/example-ci.yml` runs the example, canaries, sim runner, screenshots.
- Keep `GODOT_VERSION` the same in both workflow files and the docs when upgrading Godot.

## Conventions
- GDScript 2.0 (Godot 4). Explicit types where a `Variant` is involved; tabs for indentation.
- Harness output stays terse (failures + one summary line): it is read by agents on a usage budget.
- Shell commands in docs: one command per code block, so each can be copied on its own.
