# Gamedev-WF: a Godot AI harness for strategy & sim games

A guide plus a working setup for building Godot games with a coding agent
(**Claude Code, the Code tab of Claude Desktop, or pi**) in a **closed loop
with you in it**:

1. **You design.** Your own documents in `design/`, as detailed as you like.
   The agent turns them into numbered, testable requirements and asks you
   about every gap instead of filling it (`/spec`).
2. **The agent implements, one small slice at a time.** You approve the tests
   (inputs and expected results) before code is written; it builds, proves it
   headless, reports and stops (`/build`).
3. **The agent playtests.** Bots, fuzzing and your balance cases: bugs come
   back with a seed and a failing test, balance comes back as one table (`/qa`).

It follows the ideas of the "10 levels of AI-assisted embedded development"
and "Embedded AI Harness" videos (spec-driven development, agents, a
sandboxed machine, a harness that closes the loop), translated to game
development and set up for **a small AI budget (Claude Pro), a Windows main
laptop and a Linux Mint agent box**.

[![example-ci](https://github.com/AdilAry/Gamedev_WF/actions/workflows/example-ci.yml/badge.svg)](https://github.com/AdilAry/Gamedev_WF/actions/workflows/example-ci.yml)

## Start here
1. **[GUIDE.md](GUIDE.md)**: the concepts, the 10 levels for gamedev, and the workflow.
2. **[docs/08-first-weekend.md](docs/08-first-weekend.md)**: a step-by-step first weekend plus a cheat sheet.
3. **[docs/09-loops.md](docs/09-loops.md)**: short loops vs long loops, and who decides what.
4. **[docs/10-pi.md](docs/10-pi.md)**: using pi (cost with Claude Pro, install, the guard extension).
5. **[workflow/README.md](workflow/README.md)**: the short-loop workflow for any software project, not only games.

## What's in the box

| Path | What |
|---|---|
| [`GUIDE.md`](GUIDE.md) | the guide |
| [`docs/`](docs/) | machines & roles, Windows setup, Mint agent-box setup, Claude Pro playbook, testing tiers, architecture, asset pipeline, first weekend, loops, pi |
| [`.claude/skills/`](.claude/skills/) | 16 skills in the Agent Skills format (Claude Code and pi). Game: `/pitch` `/spec` `/define` `/harness` `/commission` `/build` `/qa` `/balance` `/playtest` `/change-request` `/style-guide` `/asset`. Any project: `/start` `/wrap` `/review` `/judge` |
| [`workflow/`](workflow/) | the general short-loop workflow: guide, user-level and project templates (AGENTS.md, PROGRESS.md, plan, history, decisions), a hackathon profile |
| [`harness/godot/harness/`](harness/godot/harness/) | the harness copied into every game: `gw.sh`, a dependency-free test runner that also catches script errors and hangs, the headless sim runner (seeds, balance cases, traces) |
| [`harness/templates/`](harness/templates/) | the game-specific files: AGENTS.md (+ CLAUDE.md import), SPEC per system, QUESTIONS (decision queue), GDD index, TESTPLAN, balance cases, QA report, IDEA, STYLE_GUIDE, ASSETS manifest, CR, PLAYTEST, safe permissions |
| [`pi/extensions/`](pi/extensions/) + [`package.json`](package.json) | pi package: the skills plus a guard extension (asks before `design/` or `harness/` are edited, blocks `--no-verify` and forced pushes) |
| [`harness/ci/godot-ci.yml`](harness/ci/godot-ci.yml) | GitHub Actions workflow for game repos |
| [`example/colony_sim/`](example/colony_sim/) | a small working tick-based colony economy built the harness way: 17 tests over 3 tiers, sim runner hook, three bots, balance cases, GDD, test plan |
| [`scripts/`](scripts/) | `install.sh` / `install.ps1`: install the skills for Claude Code and pi; `update-harness.sh`: bring a game's `harness/` up to date |
| [`CHANGELOG.md`](CHANGELOG.md) | what changed in the kit and harness, and what to do in existing games |

## Quick start

```bash
git clone https://github.com/AdilAry/Gamedev_WF.git ~/Gamedev_WF && ~/Gamedev_WF/scripts/install.sh
```

```bash
cd ~/Gamedev_WF/example/colony_sim && ./harness/gw.sh check
```

Expected output ends with `RESULT OK: 17 passed`, `SMOKE OK` and `CHECK OK`.
You need Godot 4.7.x on your PATH as `godot`, or set `GODOT` to it (on Windows
use the `*_console.exe` and Git Bash; see [docs/02-setup-windows.md](docs/02-setup-windows.md)).

Then, in a new game folder: put your design documents in `design/`, and
`/spec` -> `/harness` -> `/commission` -> `/build` (one slice at a time) ->
`/qa`. With only an idea: `/pitch` -> `/define` instead of `/spec`. In pi the
skills are `/skill:spec`, `/skill:build`, ...

## The harness commands

```bash
./harness/gw.sh test unit|sim|scene|all [filter]   # tests, terse output
./harness/gw.sh smoke [frames]                     # boot main scene, fail on errors
./harness/gw.sh sim --seeds=1-30 --ticks=800 [--param.key=value]   # balance runs -> CSV
./harness/gw.sh cases [--only=name] [--param.key=value] [--strict] # your balance cases vs targets, one table
./harness/gw.sh trace --seed=7 --ticks=200 [--param.key=value]     # one run as a readable timeline
./harness/gw.sh shot [res://scene.tscn] [frames]   # real rendered frames -> PNG
./harness/gw.sh check                              # gate before every commit
./harness/gw.sh hooks                              # make git run the gate on every code commit
./harness/gw.sh doc                                # Godot API of your version -> docs/ref/
./harness/gw.sh version                            # harness + Godot version
```

## Verified
The example project and harness run in CI on every push (Godot 4.7.2 on
Ubuntu): shellcheck, all tiers, smoke run, sim runner (twice, digests must
match), balance cases and trace, a new `class_name` picked up without a manual
import, the pi guard's rules (`npm test`), xvfb screenshots, plus canary checks proving that a failed
assertion, a runtime script error (attributed to the right test), a test
that waits forever and an endless loop all fail the run, and that the
pre-commit gate blocks a red commit.

Not verified here: the pi package inside a running pi (see the 2-minute check
in [docs/10-pi.md](docs/10-pi.md)), and anything on Windows.

## Sources & credits
- The embedded AI workflow videos (levels 0-10; the ESP32 workbench; the
  Embedded AI Harness with `/define`, `/harness`, `/commission`, `/build`).
  The structure of this kit is modelled on them.
- pi, the coding agent ([pi.dev](https://pi.dev)); the pi integration follows
  its documentation and bundled extension examples (version 1.5.2).
- Gambo7592's AI game-dev posts (style-guide-first asset generation, Claude
  writing image prompts and Blender scripts), as summarised in the owner's
  notes; adapted in [docs/07-asset-pipeline.md](docs/07-asset-pipeline.md).
