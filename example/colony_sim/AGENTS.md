# AGENTS.md: Colony Sim (Gamedev-WF example)

A tiny tick-based colony economy that shows the Gamedev-WF harness on the short-loop workflow. Deliberately small: use a copy of it to practise `/start`, `/wrap`, `/qa`, `/balance` and `/change-request`.

## Project
- **What:** a one-screen colony economy: buildings need workers, workers need food and housing.
- **For:** me, as a teaching project.
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
- A finished task is ticked by setting its rows to `green` in `docs/TESTPLAN.md`.
- **At /wrap also:** statuses in `docs/TESTPLAN.md` match reality.

## Engine facts
- Never Godot 3 syntax. API of the installed version: `./harness/gw.sh doc` -> `docs/ref/godot-api/`.
- JSON numbers load as floats; `ColonyRules` converts them once.

## Architecture
- `sim/`: pure rules. `ColonyRules` (loads data/rules.json), `ColonyState` (data), `ColonySim` (commands and `step()`), `sim/ai/greedy_bot.gd`, `sim/ai/random_bot.gd` (fuzzing).
- `data/rules.json`: every number. `scenes/main.gd`: presentation only, UI built in code.
- `sim/harness_hook.gd`: adapter for the harness; parameter `bot` = greedy | idle | random.
- Never weaken a test to make it pass. Never bypass the commit gate.

## Workflow
- One task per session: `/start <task>` begins it, `/wrap` ends it. A fresh session continues from PROGRESS.md alone.

## Read only when needed
| File | Read when |
|---|---|
| `docs/GDD.md` | starting a task: the rows of its requirement IDs only |
| `docs/TESTPLAN.md` | starting a task: its rows; choosing the next task |
| `docs/history.md` | I ask what happened earlier |
