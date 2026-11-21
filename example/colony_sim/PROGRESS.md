# PROGRESS: Colony Sim
Updated: 2026-11-14. Current state only, under ~60 lines. Finished work is in docs/history.md.

## Now
- **Task:** none in progress.
- **State:** phase 2 (sim + playable UI) works. 17 tests green (unit 9, sim 5, scene 3), smoke OK, Godot 4.7.2, harness 1.2.3.

## Next
1. BAL-003, wood must stay useful: `/balance wood piles up; target wood <= 500 at tick 500 for the greedy bot`. First command: `./harness/gw.sh cases --only=greedy-500`.
2. CR-001, a winter every 60 ticks that halves farm output: `/change-request`.

## Broken
- nothing known.

## Waiting on me
- BAL-002: an idle colony settles at 4-5 people instead of dying (`./harness/gw.sh trace --seed=3 --ticks=300 --param.bot=idle`). Is "shrinks" enough, or should idling lose the game?
- What-if case `hungry` (food_per_person = 2): the greedy bot's colony collapses to 4-5 people. A balance cliff, or just a slow bot?

## Done
- Phase 1 simulation core, phase 2 playable UI, harness 1.2 additions (cases, trace, random bot). Details in docs/history.md.

## How to run
Needs: Godot 4.7.x as `godot` or `$GODOT` (on Windows the `*_console.exe` build). In a copy with its own git repo, `./harness/gw.sh hooks` once per clone.
```
./harness/gw.sh check
./harness/gw.sh cases
godot --path .
```
