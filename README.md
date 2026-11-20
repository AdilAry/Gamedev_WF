# Gamedev-WF: a Godot AI harness for games you design yourself

A guide plus a working setup for building Godot games with a coding agent
(**Claude Code**, in the terminal or the Code tab of Claude Desktop) in a **closed loop
with you in it**:

1. **You design.** Your own documents in `design/`, as detailed as you like.
   The agent turns them into numbered, testable requirements and asks you
   about every gap instead of filling it (`/spec`).
2. **The agent implements, one small task per session.** You OK the plan
   (the tests with inputs and expected results, and the command that proves
   it) before code is written; it works until that command passes; finished
   is your call (`/start`, `/wrap`).
3. **The agent tests what a headless run can prove; you play.** Every game
   gets tiered tests, a smoke run and screenshots. A game with a simulation
   also gets bots, fuzzing and your balance cases: bugs come back with a seed
   and a reproducing test, balance comes back as one table (`/qa`). Feel is
   your call (`/playtest`).

**For any Godot game; strategy and sim games fit best.** Not only because
some tools are made for them (bots, the sim runner, balance cases,
`/balance`), but because their core is numbers and rules, and those can be
tested without a screen. In a platformer or action game, much of what
matters is how it feels: jump arcs, timing, impact. No headless test can
judge that. The parts that are rules (damage, inventory, state machines,
whether level data is valid) still get tests, but more tasks end as
"awaiting my check", and `/playtest` does more of the work than the bots do.
[GUIDE.md](GUIDE.md#what-every-game-uses-and-what-is-optional) lists what to
use and what to skip.

The session routine is your own **short-loop workflow**, a separate repo this
kit depends on and does not copy. The kit is an add-on to it: it plugs in
through each game's AGENTS.md and uses only what the workflow's WORKFLOW.md §8
("Building a kit on this workflow") lists. **Written against the contract of
20 November 2026.**

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
4. **[docs/10-pi.md](docs/10-pi.md)**: pi, for later (the workflow's WORKFLOW.md §6 says why).
5. **WORKFLOW.md in the workflow repo** (`$WORKFLOW_DIR/WORKFLOW.md` once installed): the short-loop workflow for any software project, not only games.

## What's in the box

| Path | What |
|---|---|
| [`GUIDE.md`](GUIDE.md) | the guide |
| [`docs/`](docs/) | machines & roles, Windows setup, Mint agent-box setup, Claude Pro playbook, testing tiers, architecture, asset pipeline, first weekend, loops, pi (for later) |
| [`commands/`](commands/) | the 11 game commands, in the same format: `/pitch` `/spec` `/define` `/harness` `/commission` `/qa` `/balance` `/playtest` `/change-request` `/style-guide` `/asset` |
| [`harness/godot/harness/`](harness/godot/harness/) | the harness copied into every game: `gw.sh`, a dependency-free test runner that also catches script errors and hangs, and, for games with a simulation, the headless sim runner (seeds, balance cases, traces) |
| [`harness/templates/`](harness/templates/) | the game-specific files: AGENTS.md (+ CLAUDE.md import), SPEC per system, QUESTIONS (decision queue), GDD index, TESTPLAN, balance cases (optional), QA report, IDEA, STYLE_GUIDE, ASSETS manifest, CR, PLAYTEST, safe permissions |
| [`pi/extensions/`](pi/extensions/) + [`package.json`](package.json) | pi package, for later: a guard extension (asks before `design/` or `harness/` are edited, blocks `--no-verify` and forced pushes) |
| [`harness/ci/godot-ci.yml`](harness/ci/godot-ci.yml) | GitHub Actions workflow for game repos |
| [`example/colony_sim/`](example/colony_sim/) | a small working tick-based colony economy built the harness way: 17 tests over 3 tiers, sim runner hook, three bots, balance cases, GDD, test plan. It shows every part of the kit, the optional sim parts too; a game in another genre uses fewer |
| [`scripts/`](scripts/) | `install.sh` / `install.ps1`: install the game commands next to the workflow's (needs `WORKFLOW_DIR`); `update-harness.sh`: bring a game's `harness/` up to date |
| [`CHANGELOG.md`](CHANGELOG.md) | what changed in the kit and harness, and what to do in existing games |

## Quick start

Install the workflow first, then the kit. The workflow's installer sets
`WORKFLOW_DIR`; the kit's installer only checks that it is there and stops
with a message if it isn't. The workflow repo is on GitHub for now
(<https://github.com/AdilAry/Workflow>); if it moves, only its clone URL changes.

**Linux (the agent box):** keep the workflow folder in one fixed place, since the
commands are links into it.

```bash
git clone https://github.com/AdilAry/Workflow.git ~/Workflow && bash ~/Workflow/install.sh
```

Open a new terminal (so `WORKFLOW_DIR` is set), then:

```bash
git clone https://github.com/AdilAry/Gamedev_WF.git ~/Gamedev_WF && ~/Gamedev_WF/scripts/install.sh
```

**Windows (main laptop):** clone the workflow (Git Bash), then run the
PowerShell lines in its WORKFLOW.md §3 from that folder; the last one sets
`WORKFLOW_DIR`. Then, in Git Bash:

```bash
cd ~ && git clone https://github.com/AdilAry/Gamedev_WF.git
```

```bash
powershell -ExecutionPolicy Bypass -File ~/Gamedev_WF/scripts/install.ps1
```

Then try the example:

```bash
cd ~/Gamedev_WF/example/colony_sim && ./harness/gw.sh check
```

Expected output ends with `RESULT OK: 17 passed`, `SMOKE OK` and `CHECK OK`.
You need Godot 4.7.x on your PATH as `godot`, or set `GODOT` to it (on Windows
use the `*_console.exe` and Git Bash; see [docs/02-setup-windows.md](docs/02-setup-windows.md)).

Then, in a new game folder: put your design documents in `design/`, and
`/spec` -> `/harness` -> `/commission`, then `/start` ... `/wrap` for each
task, and `/qa` when a system is built. With only an idea: `/pitch` ->
`/define` instead of `/spec`.
Create games outside this folder (e.g. `~/games/<name>`): an agent started
inside the kit also loads the kit's own AGENTS.md.

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

`sim`, `cases`, `trace` and the `sim` test tier need a simulation hook
(`sim/harness_hook.gd`); they fit strategy and sim games best. Everything
else works in any game.

## Verified
The example project and harness run in CI on every push (Godot 4.7.2 on
Ubuntu): shellcheck, all tiers, smoke run, sim runner (twice, digests must
match), balance cases and trace, a new `class_name` picked up without a manual
import, the guard's rules for pi (for later, `npm test`), the installer into
an empty home (every command linked for Claude Code, and for pi when it is
installed), xvfb screenshots, plus canary checks proving that a failed
assertion, a runtime script error (attributed to the right test), a test
that waits forever and an endless loop all fail the run, and that the
pre-commit gate blocks a red commit.

Not verified here: anything on Windows, and the pi package inside a running
pi (for later; see the 2-minute check in [docs/10-pi.md](docs/10-pi.md)).

## Sources & credits
- The embedded AI workflow videos (levels 0-10; the ESP32 workbench; the
  Embedded AI Harness with `/define`, `/harness`, `/commission`, `/build`).
  The structure of this kit is modelled on them.
- pi, the coding agent ([pi.dev](https://pi.dev)), for the parts kept for
  later (docs/10 and the guard extension); they follow its documentation and
  bundled extension examples (version 1.5.2).
- Gambo7592's AI game-dev posts (style-guide-first asset generation, Claude
  writing image prompts and Blender scripts), as summarised in the owner's
  notes; adapted in [docs/07-asset-pipeline.md](docs/07-asset-pipeline.md).
