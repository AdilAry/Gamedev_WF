# Test plan

Maps every GDD requirement to the test that proves it. The agent keeps this
up to date; the human reviews it (this is where you decide what "done" means).

## Tiers (fastest first)
| Tier | Runs | Speed | Proves | Command |
|---|---|---|---|---|
| unit | pure sim code, no scene tree | ms | rules, formulas, edge cases | `gw.sh test unit` |
| sim | many seeds x many ticks, bots play | seconds | stability, invariants, balance targets | `gw.sh test sim`, `gw.sh sim` |
| scene | real scenes in a headless SceneTree, simulated input | seconds | UI wiring, scene setup, signals | `gw.sh test scene`, `gw.sh smoke` |
| visual | real rendering to PNG, agent looks at it | ~10 s | layout, readability, "does it look broken" | `gw.sh shot` |
| playtest | a human plays | minutes | fun, feel, clarity | docs/playtests/ |

Rule: put each check in the **fastest tier that can prove it**.

## Requirements
| ID | Requirement (short) | Tier | Test | Status |
|---|---|---|---|---|
| ECO-001 | | unit | | todo |

Status values: `todo`, `red` (test written, failing), `green`, `awaiting my check` (its test passes, the part only the human can judge is open), `manual` (playtest only), `dropped`.
This is the only place a requirement's test and status are kept: `/start` reads a task's rows here, and a finished task is ticked here.

## Fault injection / negative tests
List the nasty cases on purpose: empty resources, huge numbers, zero costs,
all AI players dead, save file from older version, window resized to 800x600 ...

| Case | Expected | Test | Status |
|---|---|---|---|
