# Development log

## 2026-11-04 - Harness 1.1.0
- **Done:** ECO-006 (broken rules file is reported; shows `expect_error()`). Harness updated to 1.1.0.
- **State of tests:** `gw.sh check` -> 16 passed (unit 9, sim 4, scene 3), smoke OK, on Godot 4.7.2 in GitHub Actions.
- **Finding:** `gw.sh sim --seeds=1-10 --ticks=500` prints `SAME ON EVERY SEED: population, wood, farms, mills, houses, housing`. GreedyBot is fully deterministic and good harvests are too rare to change its choices, so seeds only move the food stock. More seeds prove nothing here until the game has real randomness (events that matter, a bot with some variety).
- **Next step:** unchanged - `/balance` for BAL-003, then CR-001 (winter). Winter will also give the seeds something to do if its timing is random.

## 2026-11-04 - Example project created with the harness
- **Done:** ECO-001..005, POP-001..002, SYS-001..003, BAL-001..002, UI-001..003.
- **State of tests:** `gw.sh check` -> 15 passed (unit 8, sim 4, scene 3), smoke OK, on Godot 4.7.2 in GitHub Actions.
- **Decisions:** UI is built in code (no hand-written .tscn beyond the root node).
- **Blocked / questions:** none.
- **Balance finding:** `gw.sh sim --seeds=1-10 --ticks=500` shows population 55 and wood ~9 800 at tick 500. Wood has no use once houses are built -> BAL-003 is open.
- **Next step (exercises for you):**
  1. `/balance` - make wood matter (BAL-003), e.g. upkeep or a wood-hungry building.
  2. `/change-request` - "CR-001: winter every 60 ticks halves farm output".
