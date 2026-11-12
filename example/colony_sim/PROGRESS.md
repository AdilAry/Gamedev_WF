# PROGRESS: Colony Sim
Updated: 2026-11-12. Current state only, under ~60 lines. Finished work is in docs/history.md.

## Now
- **Working on:** nothing in progress. Phase 2 (sim + playable UI) is done.
- **State:** 17 tests green (unit 9, sim 5, scene 3), smoke OK, on Godot 4.7.2. Harness 1.2.1.

## Next
1. `/balance` for BAL-003: wood must stay useful (greedy bot, wood <= 500 at tick 500; now 9772).
2. `/change-request` CR-001: a winter every 60 ticks that halves farm output.

## Broken
- nothing known.

## Dead ends
- none.

## Waiting on me
- BAL-002: an idle colony settles at 4-5 people instead of dying. Is "shrinks" enough, or should idling lose the game? (`./harness/gw.sh trace --seed=3 --ticks=300 --param.bot=idle`)
- What-if `hungry` (food_per_person = 2): the greedy bot's colony collapses to 4-5 people. A balance cliff, or just a slow bot?

## How to run
```
./harness/gw.sh check
./harness/gw.sh cases
godot --path .
```
