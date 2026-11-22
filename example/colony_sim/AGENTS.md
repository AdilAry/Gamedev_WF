# AGENTS.md: Colony Sim (Gamedev-WF example)

A tiny tick-based colony economy that shows the Gamedev-WF harness on the short-loop workflow. Deliberately small: use a copy of it to practise `/start`, `/wrap`, `/qa`, `/balance` and `/change-request`.

## Project
- **What:** a one-screen colony economy: buildings need workers, workers need food and housing.
- **For:** me, as a teaching project.
- **Simulation:** yes: sim/harness_hook.gd, bots in sim/ai/, tests/sim, balance cases.
- **Second machine:** the agent box runs the same harness.

## Stack
- **Language and tools:** Godot 4.7 + GDScript 2.0, Compatibility renderer. `harness/gw.sh` is copied from the kit; never edit it here.
- **Run:** `godot --path .`
- **Check:** `./harness/gw.sh check`. Run it before calling anything done.
- **Done gate:** the tests the plan names pass (`./harness/gw.sh test <tier> <filter>`), then Check passes. For a task that is not a requirement: Check passes, and a named test covers the change.
- **Run limit:** 20 harness runs in one session, passed or failed. Then stop and report.
- **Push:** in /wrap.

## Who decides what
- Requirements and balance targets are in `docs/GDD.md`; the cases in `tests/cases/balance.json` and the numbers in `data/rules.json` are design. Propose changes with `./harness/gw.sh cases` evidence; change them after I pick.
- A gap in the design is a question for me, never a guess.

## The plan
- The plan lives in `docs/GDD.md` (requirements with IDs, sections 6-8) and `docs/TESTPLAN.md` (test and status). This game is small enough to have no `docs/spec/`.
- In the /start plan, list each test as input -> expected result.
- **At /start also:** a check I confirmed sets that task's rows in `docs/TESTPLAN.md` to `green`.
- **At /wrap also:** a finished task's rows in `docs/TESTPLAN.md` are set to `green`, and every status there matches reality.
- **Judged on** (for /judge): every `green` requirement has a test that really proves it; no test was weakened and no expected value changed without a change request (`git log -p -- tests/`); the Architecture rules below hold; nothing in code or data that is in neither `docs/GDD.md` nor an answered question; PROGRESS.md and the statuses match the code.

## Engine facts
- Never Godot 3 syntax. API of the installed version: `./harness/gw.sh doc` -> `docs/ref/godot-api/`.
- JSON numbers load as floats; `ColonyRules` converts them once.

## Architecture
- `sim/`: pure rules. `ColonyRules` (loads data/rules.json), `ColonyState` (data), `ColonySim` (commands and `step()`), `sim/ai/greedy_bot.gd`, `sim/ai/random_bot.gd` (fuzzing).
- `data/rules.json`: every number. `scenes/main.gd`: presentation only, UI built in code.
- `sim/harness_hook.gd`: adapter for the harness; parameter `bot` = greedy | idle | random.
- Never bypass the commit gate.

## Read only when needed
| File | Read when |
|---|---|
| `docs/GDD.md` | starting a task: the rows of its requirement IDs only |
| `docs/TESTPLAN.md` | starting a task: its rows; choosing the next task |
| `docs/history.md` | I ask what happened earlier |
