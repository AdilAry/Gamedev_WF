---
description: Strap a Godot 4 project into the Gamedev-WF harness once - folder structure, headless test and simulation runners, AGENTS.md, PROGRESS.md, balance cases, CI and git hook. Use after spec or define, or to retrofit or update the harness.
argument-hint: empty | "update" to bring an existing game's harness up to date
---
# /harness - couple the agent to the project

Request: $ARGUMENTS

The harness is what lets the agent close the loop by itself: build, run,
test, read results, fix, repeat. Without it every iteration goes through the
human. This command also sets the game up on the short-loop workflow, so
`/start`, `/wrap` and `/judge` work in it.

## 0. Find the kit and the workflow
Kit root = `$GAMEDEV_WF` (set by the kit's installer); workflow = `$WORKFLOW_DIR`
(set by the short-loop workflow's installer). If either is unset, stop and tell
the user: install the workflow (its WORKFLOW.md §3), then the kit
(`scripts/install.sh`, Windows `scripts\install.ps1`), and open a new terminal.
Never guess a path. You need:
- `<kit>/harness/godot/harness/` (gw.sh, test_runner.gd, sim_runner.gd, gw_test.gd, gw_error_capture.gd)
- `<kit>/harness/templates/` (AGENTS.md, CLAUDE.md, TESTPLAN.md, QUESTIONS.md, cases.json, ...)
- `$WORKFLOW_DIR/templates/project/` (PROGRESS.md, docs/history.md, docs/decisions.md:
  the session files of the short-loop workflow, the same in every project)
- `<kit>/harness/ci/godot-ci.yml`
- `<kit>/example/colony_sim/` - a working reference project. When unsure how
  something should look, copy its pattern.

## 1. Preconditions
- `docs/GDD.md` exists (written by `/spec` from the human's `design/` files,
  or by `/define`). If not, stop and suggest `/spec` when there are design
  documents, `/define` when there is only an idea.
- Godot is reachable: run `godot --version` (or `$GODOT --version`). On
  Windows it must be the `*_console.exe` build. If missing, explain how to set
  `GODOT` (see the kit's docs/02-setup-windows.md / docs/03-setup-mint.md).

## 2. Create the structure (do not overwrite existing files without asking)
```
project.godot            # Compatibility renderer, main scene set
AGENTS.md                # from <kit>/harness/templates/AGENTS.md, filled with the game's facts
CLAUDE.md                # copy <kit>/harness/templates/CLAUDE.md unchanged (one line: the import of AGENTS.md)
PROGRESS.md              # from the workflow templates: now / next / broken / waiting on me / done
.gitignore               # .godot/ reports/ out/ docs/ref/ export/ .env .claude/settings.local.json
                         # (NOT *.uid - Godot wants those committed)
design/                  # the human's design documents - never create or edit files in it
.claude/settings.json    # from templates/claude-settings.json (safe allow-list)
.github/workflows/godot-ci.yml
harness/                 # copied verbatim from the kit - never edit per project
data/                    # JSON with every tunable number
sim/                     # pure rules (RefCounted, class_name, deterministic)
sim/harness_hook.gd      # setup/step/metrics/is_finished/check_invariants
sim/ai/                  # simple bots for sim tests and balance runs, plus a seeded random bot for fuzzing
scenes/  ui/             # presentation only
assets/ASSETS.md         # asset manifest
tests/unit/ tests/sim/ tests/scene/
tests/cases/balance.json # the human's balance cases, from templates/cases.json
docs/GDD.md docs/spec/ docs/QUESTIONS.md docs/TESTPLAN.md
docs/history.md docs/decisions.md docs/notes/   # no docs/plan.md: the plan is spec + TESTPLAN
docs/changes/ docs/playtests/
```
- `project.godot` must contain `config_version=5`, `run/main_scene`,
  `config/features=PackedStringArray("<major.minor>", "GL Compatibility")` and
  `renderer/rendering_method="gl_compatibility"`. Copy the example's file and
  change the name.
- `chmod +x harness/gw.sh`.
- Set `GODOT_VERSION` in the CI workflow to the version from `godot --version`.

## 3. Seed the code
- A minimal main scene (`scenes/main.tscn` + `main.gd`) that builds its UI in code.
- Skeleton sim classes for the first system in build order (state, rules, sim
  with `step()`), plus `sim/harness_hook.gd` implementing the runner contract:
  `setup/step/metrics/is_finished`, `check_invariants()`, `events()` (for
  `gw.sh trace`) and a `bot` param (`greedy`/`idle`/`random`, for cases and
  fuzzing). Copy the example's hook and bots as the pattern.
- `tests/cases/balance.json`: one case per BAL-* target that already has
  numbers, using metric names the hook really reports. Leave targets the
  design does not state out; do not invent them.
- One trivial passing test, so Check has something to run. Do not write the
  requirement tests here: each task writes its own, after its plan is OK'd.
- Fill `docs/TESTPLAN.md` from the spec (or the GDD): every requirement ->
  tier, test path (empty for now), status `todo`. This file is the only place
  where a requirement's test and status are kept.
- Fill `AGENTS.md` with the game's facts and ask the human for the two
  choices it needs (Push, and the second machine's role). Leave no bracket
  behind: `grep -n '\[' AGENTS.md` must find nothing. Keep it under ~120
  lines; it is not a place for state.
- Fill `PROGRESS.md`: "Now" = harness created, "Next" 1 = `/commission`,
  2 = the first task in build order, named by its requirement IDs so that
  `/start` can take it without asking.

## 4. Git
- `git init` if needed, then `./harness/gw.sh hooks` (installs the pre-commit
  gate: commits that touch code, data or tests run `gw.sh check` first;
  docs-only commits skip it). Then the first commit "Harness: project structure".
  Hooks are not cloned by git, so every new clone (other laptop) needs
  `./harness/gw.sh hooks` once - `/commission` checks this.
- If the project has no GitHub remote, tell the user the exact steps (create
  an empty repo on github.com, then `git remote add origin ...` and
  `git push -u origin main`), or use `gh repo create` if `gh` is installed and
  authenticated. Never push to a remote the user did not confirm.

## Updating the harness of an existing project
When the kit has a newer harness (`./harness/gw.sh version` vs
`grep HARNESS_VERSION <kit>/harness/godot/harness/gw.sh`), run
`<kit>/scripts/update-harness.sh .`, then `./harness/gw.sh check`, read
`<kit>/CHANGELOG.md` for anything the project must adapt, and commit
"Harness <version>". Never hand-edit files in `harness/`; improve the kit instead.

## 5. Finish
Run `./harness/gw.sh check`. Expected: `CHECK OK`. Report the result and
suggest `/commission`, then `/start` for the first task.

The guards against editing `design/` and `harness/` come from
`.claude/settings.json`. For pi, later, the kit's guard extension does the
same once the kit is installed (`<kit>/scripts/install.sh`).
