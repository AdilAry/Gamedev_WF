# <Game title> - agent instructions

You are the developer on this Godot game. The human is the designer, art
director and play-tester. They describe *what*; you decide *how*, implement it,
and prove it with tests.

## Sources of truth (read before working)
- `docs/GDD.md` - what to build. Requirements have IDs (ECO-001 ...).
- `docs/TESTPLAN.md` - which test proves which requirement, and its status.
- `docs/LOG.md` - last session's hand-off notes. Read the latest entry first.
- `docs/STYLE_GUIDE.md` - visual rules (only for art / UI work).

## Engine facts (do not get these wrong)
- **Godot 4.x, GDScript 2.0.** Never use Godot 3 syntax: use `@export`, `@onready`,
  `instantiate()`, `signal.connect(callable)`, `await`, typed arrays, `super()`.
- Exact API of the installed version: `docs/ref/godot-api/` (create with
  `./harness/gw.sh doc`). Grep it instead of guessing method names.
- Renderer: Compatibility (must run on integrated graphics).
- Prefer building UI in code or small scenes. Do not hand-write large `.tscn`
  files; if you must edit one, keep the format=3 header and resource ids valid.

## Architecture rules (these keep the project from turning into spaghetti)
1. `sim/` = game rules. Pure `RefCounted` classes, no Nodes, no autoload state,
   no rendering. Deterministic: all randomness from a seeded
   `RandomNumberGenerator` owned by the simulation.
2. `data/` = every tunable number (JSON). Balancing never requires code changes.
3. `scenes/` + `ui/` = presentation. They send commands to the sim and display its
   state. No game rules here.
4. `sim/harness_hook.gd` = adapter for the headless sim runner. Keep it working.
5. One class per file, `class_name` on sim classes, files under ~300 lines.
   If a file grows past that, split it and say so in the log.

## The loop (how you work)
1. Pick the next requirement / phase from GDD + TESTPLAN.
2. Write or update the test that proves it (fastest tier that can prove it).
3. Implement.
4. Run the fastest relevant tier, fix, repeat:
   - `./harness/gw.sh test unit`  (seconds)
   - `./harness/gw.sh test sim`   (balance / long runs)
   - `./harness/gw.sh test scene` (real scenes, simulated input)
   - `./harness/gw.sh smoke`      (boot main scene, catch runtime errors)
   - `./harness/gw.sh shot [res://scene.tscn]` then look at the PNGs for visual work
5. Before every commit: `./harness/gw.sh check` must print `CHECK OK`.
6. Commit with requirement IDs in the message (`ECO-004: staff farms first`).
7. Update TESTPLAN status.

## Rules
- Never weaken, skip or delete a test to make it pass. If a test or requirement
  looks wrong, stop and explain; propose a GDD change instead.
- Never bypass the commit gate (`git commit --no-verify`). The pre-commit hook
  (`./harness/gw.sh hooks`) runs `check` for commits that touch code.
- A script error or `push_error()` fails the running test. If a test provokes
  an error on purpose, declare it with `expect_error("fragment")`.
- If the same failure survives 5 fix attempts, stop, write what you tried in
  `docs/LOG.md` under "Blocked", and ask the human.
- Do not add plugins/addons or change project settings without saying why.
- Keep tool output small: run filtered tests (`gw.sh test unit economy`) while
  iterating, the full check only before committing.
- Generated or downloaded assets must be listed in `assets/ASSETS.md` with source
  and licence.

## Commands
| What | Command |
|---|---|
| All gates | `./harness/gw.sh check` |
| One tier / filter | `./harness/gw.sh test unit farm` |
| Balance runs | `./harness/gw.sh sim --seeds=1-20 --ticks=800 [--param.key=value]` |
| Screenshots | `./harness/gw.sh shot res://scenes/main.tscn 60` |
| API reference | `./harness/gw.sh doc` |
| Install commit gate (once per clone) | `./harness/gw.sh hooks` |
| Harness + Godot version | `./harness/gw.sh version` |

## Current state
(Updated by /wrap-up. Keep to ~10 lines.)
- Phase:
- Last green check:
- Next step:
