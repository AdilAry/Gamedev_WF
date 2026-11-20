# Gamedev-WF kit - instructions for agents working on THIS repo

(`AGENTS.md` is the instruction file; `CLAUDE.md` only imports it, so Claude
Code reads it today, and pi can read the same text later, unchanged.)

This repo is a kit (guide + game commands + harness + example) on top of
the owner's short-loop workflow,
not a game. Games are created in their own folders/repos, outside this one,
with the `/harness` command. Do not start an agent for game work inside this
folder: it would load this file too.

## Layout
- `GUIDE.md`, `docs/`: the human guide. Plain, practical English; the owner is a
  beginner embedded engineer, Godot hobbyist, Claude Pro user (Claude Code is
  the only agent today; pi is for later), Windows 10 main laptop + Linux Mint
  agent box. They design their games in detail themselves and want short,
  human-checked loops.
- **The short-loop workflow is an external dependency** (its own repo,
  found through `$WORKFLOW_DIR`, which its installer sets). The kit uses only
  the WORKFLOW.md §8 list ("Building a kit on this workflow"); the README names
  the contract date it was written against. A change to how sessions work
  belongs in the workflow repo first. If the kit needs a word the §8 list
  doesn't have, list it for the owner. Never copy or restate the workflow's
  files here.
- `commands/<name>.md`: the game commands, in the workflow's command format
  (frontmatter `description` and optional `argument-hint`, body uses
  `$ARGUMENTS`). They are linked into `~/.claude/commands` by
  `scripts/install.sh` (and into `~/.pi/agent/prompts` when pi is installed).
  Keep them agent-neutral so they keep working in pi later: say "AGENTS.md",
  never rely on a tool only one agent has, keep the frontmatter valid YAML
  (no `: ` inside a description), and do not write an at-sign directly
  before a file name or an exclamation mark before a backtick in a body
  (Claude Code would expand them).
- There is no build command. A requirement task is `/start <IDs>`; what makes
  it game-specific is in `harness/templates/AGENTS.md`. Game logic belongs
  there or in a game command, never in a copy of the workflow's commands.
- `/harness` copies `$WORKFLOW_DIR/templates/project/{PROGRESS.md,docs/history.md,docs/decisions.md}`
  into games, so there is one copy of those templates.
- `pi/extensions/gamedev-wf-guard/`: pi extension, for later. Decisions live in
  `rules.ts` (no pi imports) and are tested with `npm test`.
- `harness/godot/harness/`: the canonical harness. **`example/colony_sim/harness/` must
  stay byte-identical** (CI diffs them). After editing the canonical copy:
  `cp harness/godot/harness/* example/colony_sim/harness/`.
- When the harness changes: bump `HARNESS_VERSION` in `gw.sh` and add a
  `CHANGELOG.md` entry that says what existing games must do.
- `harness/templates/`: the game-specific files the commands copy into projects.
- `example/colony_sim/`: reference project; keep its tests green.

## Checks
- `cd example/colony_sim && ./harness/gw.sh check` (needs Godot 4.7.x as `godot` or `$GODOT`).
- `npm test` (Node 22.18+): the pi guard's rules.
- `HOME=$(mktemp -d) WORKFLOW_DIR=<a workflow clone> bash scripts/install.sh`
  after creating `.claude` in that folder: every command must end up linked.
  Without `WORKFLOW_DIR` it must stop with a message.
- CI: `.github/workflows/example-ci.yml` runs the example, canaries, sim runner, screenshots.
- Keep `GODOT_VERSION` the same in both CI files (`.github/workflows/example-ci.yml`,
  `harness/ci/godot-ci.yml`) and the docs when upgrading Godot.

## Conventions
- GDScript 2.0 (Godot 4). Explicit types where a `Variant` is involved; tabs for indentation.
- Harness output stays terse (failures + one summary line): it is read by agents on a usage budget.
- Shell commands in docs: one command per code block, so each can be copied on its own.
