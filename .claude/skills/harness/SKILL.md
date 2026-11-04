---
name: harness
description: Strap a Godot 4 project into the Gamedev-WF harness - create the folder structure (sim/data/scenes/tests), copy the headless test and simulation runners, CLAUDE.md, TESTPLAN.md, CI workflow and git setup, based on docs/GDD.md. Use once per project after /define, or to retrofit the harness into an existing Godot project.
---

# /harness - couple the agent to the project

The harness is what lets the agent close the loop by itself: build, run,
test, read results, fix, repeat. Without it every iteration goes through the
human.

## 0. Find the kit
Kit root = `$GAMEDEV_WF`, else `~/Gamedev_WF`, else
`/c/Users/<user>/Gamedev_WF` on Windows, else ask the user. You need:
- `<kit>/harness/godot/harness/` (gw.sh, test_runner.gd, sim_runner.gd, gw_test.gd, gw_error_capture.gd)
- `<kit>/harness/templates/` (CLAUDE.md, TESTPLAN.md, LOG.md, ASSETS.md, ...)
- `<kit>/harness/ci/godot-ci.yml`
- `<kit>/example/colony_sim/` - a working reference project. When unsure how
  something should look, copy its pattern.

## 1. Preconditions
- `docs/GDD.md` exists. If not, stop and suggest `/define`.
- Godot is reachable: run `godot --version` (or `$GODOT --version`). On
  Windows it must be the `*_console.exe` build. If missing, explain how to set
  `GODOT` (see the kit's docs/02-setup-windows.md / docs/03-setup-mint.md).

## 2. Create the structure (do not overwrite existing files without asking)
```
project.godot            # Compatibility renderer, main scene set
CLAUDE.md                # from template, filled with the game's facts
.gitignore               # .godot/ reports/ docs/ref/ export/
.claude/settings.json    # from templates/claude-settings.json (safe allow-list)
.github/workflows/godot-ci.yml
harness/                 # copied verbatim from the kit - never edit per project
data/                    # JSON with every tunable number
sim/                     # pure rules (RefCounted, class_name, deterministic)
sim/harness_hook.gd      # setup/step/metrics/is_finished/check_invariants
sim/ai/                  # simple bots used by sim tests and balance runs
scenes/  ui/             # presentation only
assets/ASSETS.md         # asset manifest
tests/unit/ tests/sim/ tests/scene/
docs/GDD.md docs/TESTPLAN.md docs/LOG.md docs/changes/ docs/playtests/
```
- `project.godot` must contain `config_version=5`, `run/main_scene`,
  `config/features=PackedStringArray("<major.minor>", "GL Compatibility")` and
  `renderer/rendering_method="gl_compatibility"`. Copy the example's file and
  change the name.
- `chmod +x harness/gw.sh`.
- Set `GODOT_VERSION` in the CI workflow to the version from `godot --version`.

## 3. Seed the code
- A minimal main scene (`scenes/main.tscn` + `main.gd`) that builds its UI in code.
- Skeleton sim classes for the systems in GDD Phase 1 (state, rules, sim with
  `step()`), plus `sim/harness_hook.gd` implementing the runner contract.
- One real unit test per Phase-1 requirement ID, marked as failing/red is fine.
- Fill `docs/TESTPLAN.md` from the GDD: every requirement -> tier, test path,
  status `todo`.
- Fill `CLAUDE.md` "Current state" and copy the game-specific facts (genre,
  time model, data files) into it. Keep it under ~120 lines.

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
Run `./harness/gw.sh check`. Expected: import OK, the seeded tests run (red is
fine at this stage, but there must be no SCRIPT ERROR), smoke OK. Report the
result and suggest `/commission`.
