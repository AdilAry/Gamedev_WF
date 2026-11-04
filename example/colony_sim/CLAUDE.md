# Colony Sim (Gamedev-WF example) - agent instructions

A tiny tick-based colony economy that demonstrates the Gamedev-WF harness.
It is deliberately small: use it to learn the loop and to try the skills
(/build, /balance, /change-request) before starting your own game.

## Sources of truth
- `docs/GDD.md` - requirements with IDs and proofs
- `docs/TESTPLAN.md` - requirement -> test -> status
- `docs/LOG.md` - newest entry first

## Engine facts
- Godot 4.x, GDScript 2.0 only (no Godot 3 syntax). Compatibility renderer.
- API reference of the installed version: `./harness/gw.sh doc` -> `docs/ref/godot-api/`.

## Architecture
- `sim/` pure rules: `ColonyRules` (loads data/rules.json), `ColonyState` (data),
  `ColonySim` (commands + `step()`), `sim/ai/greedy_bot.gd` (test/balance bot).
- `data/rules.json` every number. Balancing = editing this file.
- `scenes/main.gd` presentation only; builds UI in code.
- `sim/harness_hook.gd` adapter for `harness/sim_runner.gd`.
- `harness/` is copied from the kit; do not edit it here.

## Loop
`./harness/gw.sh test unit <filter>` -> `test sim` -> `test scene` -> `check` before commit.
Never weaken a test to pass it. Stop after 5 failed attempts on the same failure and log it.

## Current state
- Phase 2 done (sim + playable UI). All 16 tests green on Godot 4.7.2 (CI).
- Known balance issue: wood piles up (~10 000 by tick 500) - nothing spends it. Try `/balance`.
- Next step: CR-001 (winter) is a good exercise for `/change-request`.
