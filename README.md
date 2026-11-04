# Gamedev-WF: a Godot AI harness for strategy & sim games

A guide plus a working setup for building Godot games with Claude Code in
a **closed loop**: you write the design and the requirements, and the agent
writes GDScript, **runs the game headless, tests it, measures balance, looks
at screenshots and fixes things** until each requirement is proven.

It follows the ideas of the "10 levels of AI-assisted embedded development"
and "Embedded AI Harness" videos (spec-driven development, agents, a
sandboxed machine, /define -> /harness -> /commission -> /build), translated
to game development and set up for **Claude Pro + Claude Desktop, a Windows
main laptop and a Linux Mint agent box**.

[![example-ci](https://github.com/AdilAry/Gamedev_WF/actions/workflows/example-ci.yml/badge.svg)](https://github.com/AdilAry/Gamedev_WF/actions/workflows/example-ci.yml)

## Start here
1. **[GUIDE.md](GUIDE.md)**: the concepts, the 10 levels for gamedev, and the workflow.
2. **[docs/08-first-weekend.md](docs/08-first-weekend.md)**: a step-by-step first weekend plus a cheat sheet.

## What's in the box

| Path | What |
|---|---|
| [`GUIDE.md`](GUIDE.md) | the guide |
| [`docs/`](docs/) | machines & roles, Windows setup, Mint agent-box setup, Claude Pro playbook, testing tiers, architecture, asset pipeline, first weekend |
| [`.claude/skills/`](.claude/skills/) | 11 Claude Code skills: `/pitch` `/define` `/harness` `/commission` `/build` `/playtest` `/balance` `/change-request` `/style-guide` `/asset` `/wrap-up` |
| [`harness/godot/harness/`](harness/godot/harness/) | the harness copied into every game: `gw.sh`, a dependency-free test runner, the headless sim runner |
| [`harness/templates/`](harness/templates/) | IDEA, GDD (with requirement IDs + proofs), TESTPLAN, CLAUDE.md, STYLE_GUIDE, ASSETS manifest, CR, PLAYTEST, LOG, safe permissions |
| [`harness/ci/godot-ci.yml`](harness/ci/godot-ci.yml) | GitHub Actions workflow for game repos |
| [`example/colony_sim/`](example/colony_sim/) | a small working tick-based colony economy built the harness way: 16 tests over 3 tiers, sim runner hook, bot, GDD, test plan |
| [`scripts/`](scripts/) | `install.sh` / `install.ps1`: install the skills for Claude Code |

## Quick start

```bash
git clone https://github.com/AdilAry/Gamedev_WF.git ~/Gamedev_WF && ~/Gamedev_WF/scripts/install.sh
```

```bash
cd ~/Gamedev_WF/example/colony_sim && ./harness/gw.sh check
```

Expected output ends with `RESULT OK: 16 passed`, `SMOKE OK` and `CHECK OK`.
You need Godot 4.7.x on your PATH as `godot`, or set `GODOT` to it (on Windows
use the `*_console.exe` and Git Bash; see [docs/02-setup-windows.md](docs/02-setup-windows.md)).

Then, in a new folder with Claude Code: `/pitch` -> `/define` -> `/harness`
-> `/commission` -> `/build`.

## The harness commands

```bash
./harness/gw.sh test unit|sim|scene|all [filter]   # tests, terse output
./harness/gw.sh smoke [frames]                     # boot main scene, fail on errors
./harness/gw.sh sim --seeds=1-30 --ticks=800 [--param.key=value]   # balance runs -> CSV
./harness/gw.sh shot [res://scene.tscn] [frames]   # real rendered frames -> PNG
./harness/gw.sh check                              # gate before every commit
./harness/gw.sh doc                                # Godot API of your version -> docs/ref/
```

## Verified
The example project and harness run in CI on every push (Godot 4.7.2 on
Ubuntu): all tiers, smoke run, sim runner, xvfb screenshots, plus two canary
checks proving that a failed assertion **and** a runtime script error both
fail the run.

## Sources & credits
- The embedded AI workflow videos (levels 0-10; the ESP32 workbench; the
  Embedded AI Harness with `/define`, `/harness`, `/commission`, `/build`).
  The structure of this kit is modelled on them.
- Gambo7592's AI game-dev posts (style-guide-first asset generation, Claude
  writing image prompts and Blender scripts), as summarised in the owner's
  notes; adapted in [docs/07-asset-pipeline.md](docs/07-asset-pipeline.md).
