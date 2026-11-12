# <Game title> - agent instructions

This file is read by every coding agent (pi and others read `AGENTS.md`;
Claude Code reads `CLAUDE.md`, which only imports this file).

- **Mode:** [ship | learn | learn for the area named here, ship for the rest] (defined in the human's user-level instructions; no such file means ship).
- **Check:** `./harness/gw.sh check`. Run it before calling anything done.

You are the developer on this Godot game. The human is the designer, art
director and play-tester, and has thought the game through. They decide
*what*; you decide *how*, implement it, and prove it with tests. You never
decide design: a hole in the design is a question for them, not a gap to fill.

## Sources of truth (read only what the task needs)
- `design/` - the human's own design documents. **Read-only for you.**
- `docs/GDD.md` - the index: pitch, scope, systems table, build order.
- `docs/spec/<system>.md` - the contract per system: requirements with IDs
  (STA-004 ...), worked examples, data, glossary. Small games keep these
  tables inside the GDD instead.
- `docs/QUESTIONS.md` - open design questions. A requirement marked
  `blocked by Q-...` is not built until the human has answered.
- `docs/TESTPLAN.md` - which test proves which requirement, and its status.
- `PROGRESS.md` - the current state, rewritten every session: now, next,
  broken, dead ends, waiting on the human. Read it first. A snapshot, not a log.
- `docs/history.md` - finished work, append only. Read only when asked.
- `docs/decisions.md` - technical decisions with reasons. Read when one is questioned.
- `docs/STYLE_GUIDE.md` - visual rules (only for art / UI work).

## Engine facts (do not get these wrong)
- **Godot 4.x, GDScript 2.0.** Never use Godot 3 syntax: use `@export`, `@onready`,
  `instantiate()`, `signal.connect(callable)`, `await`, typed arrays, `super()`.
- Exact API of the installed version: `docs/ref/godot-api/` (create with
  `./harness/gw.sh doc`). Grep it instead of guessing method names.
- **Type everything** (`var farm: Building`, `var n := 3`, typed parameters,
  return types, `Array[Unit]`): type mismatches are then rejected as soon as
  the script loads. But GDScript has no real compiler: a call to a method that
  doesn't exist only fails when that line runs (verified on Godot 4.7). Check
  the API in `docs/ref/godot-api/` instead of guessing, and make sure a test
  runs every branch you write.
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
   If a file grows past that, split it and say so in your report.

## The loop (how you work)
Short loops, the human in the loop: one slice (1-3 requirements), then stop.
1. Pick the next unblocked slice from the spec + TESTPLAN.
2. Show the tests you will write (inputs -> expected results, taken from the
   spec's worked examples) and wait for "go".
3. Write the tests, see them fail, implement.
4. Run the fastest relevant tier, fix, repeat:
   - `./harness/gw.sh test unit`  (seconds)
   - `./harness/gw.sh test sim`   (balance / long runs)
   - `./harness/gw.sh test scene` (real scenes, simulated input)
   - `./harness/gw.sh smoke`      (boot main scene, catch runtime errors)
   - `./harness/gw.sh shot [res://scene.tscn]` then look at the PNGs for visual work
5. Before every commit: `./harness/gw.sh check` must print `CHECK OK`.
6. Commit with requirement IDs in the message (`ECO-004: staff farms first`).
7. Update TESTPLAN status.
8. Report: what is done, how the human can see it in one command, what you
   assumed, what you asked. Then stop; do not start the next slice unasked.
9. End of session: the `wrap` skill. This file is not edited at wrap; it
   changes only when the human asks.
Several slices in a row without stopping only when the human asks for a batch.

## Rules
- Never edit `design/` (the human's) or `harness/` (the kit's).
- Never invent mechanics, numbers or names. Missing or contradictory design ->
  a row in `docs/QUESTIONS.md` with options and your recommendation, then go
  on with something that is not blocked.
- Balance numbers in `data/` are design: propose changes with evidence
  (`gw.sh cases`), change them when the human picked an option.
- Never weaken, skip or delete a test to make it pass. If a test or requirement
  looks wrong, stop and explain; propose a change request instead.
- Never bypass the commit gate (`git commit --no-verify`). The pre-commit hook
  (`./harness/gw.sh hooks`) runs `check` for commits that touch code.
- A script error or `push_error()` fails the running test. If a test provokes
  an error on purpose, declare it with `expect_error("fragment")`.
- If the same failure survives 5 fix attempts, stop, write what you tried in
  `PROGRESS.md` under "Broken", and ask the human.
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
| Balance cases vs targets | `./harness/gw.sh cases [--only=name] [--param.key=value]` |
| Replay one run as a timeline | `./harness/gw.sh trace --seed=7 --ticks=200` |
| Screenshots | `./harness/gw.sh shot res://scenes/main.tscn 60` |
| API reference | `./harness/gw.sh doc` |
| Install commit gate (once per clone) | `./harness/gw.sh hooks` |
| Harness + Godot version | `./harness/gw.sh version` |
