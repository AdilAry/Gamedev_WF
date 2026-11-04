# Colony Sim - Game Design Document

| Field | Value |
|---|---|
| Version | 1.0 |
| Engine | Godot 4.7 (GDScript), Compatibility renderer |
| Status | Phase 2 complete |

## 1. Pitch
A one-screen colony economy. Buildings need workers; workers need food and
housing. Doing nothing starves the colony; expanding blindly does too.

## 2. Pillars
1. **Every build is a trade-off** between food, materials and growth.
2. **Readable numbers** - the player always sees stock and per-tick rate.
3. **Tiny** - this is a teaching project for the harness.

## 3. Scope
- In: 2 resources (food, wood), 3 buildings, population growth/starvation, random good harvests.
- Out: map, combat, save/load, menus, sound.

## 4. Core loop
- Tick (0.5 s): produce -> random event -> eat -> grow or starve.
- Minutes: build to keep food positive and housing available.
- End: the colony dies out (population 0). No win condition (sandbox).

## 5. Time model
Fixed tick, 0.5 s real time per tick, pausable. Deterministic per seed.

## 6. Systems

### 6.1 Economy
Numbers in `data/rules.json`.

| ID | Requirement | Tier | Proof |
|---|---|---|---|
| ECO-001 | Rules load from data/rules.json; all numbers are integers (except probabilities) | unit | test_economy.gd::test_rules_load_as_integers |
| ECO-002 | A fully staffed building adds its `produces` every tick | unit | test_economy.gd::test_staffed_farm_produces_food |
| ECO-003 | A building without enough free workers produces nothing | unit | test_economy.gd::test_unstaffed_farm_produces_nothing |
| ECO-004 | Workers are assigned in `work_priority` order | unit | test_economy.gd::test_work_priority_staffs_farms_first |
| ECO-005 | Building costs are paid up front; unaffordable builds change nothing | unit | test_economy.gd::test_build_spends_resources |

### 6.2 Population
| ID | Requirement | Tier | Proof |
|---|---|---|---|
| POP-001 | +1 population every `growth_ticks` while fed and housing > population | unit | test_economy.gd::test_growth_needs_food_and_housing |
| POP-002 | If food < need: food = 0, population -= `starvation_loss` (min 0) | unit | test_economy.gd::test_starvation_reduces_population_and_never_goes_negative |

### 6.3 System
| ID | Requirement | Tier | Proof |
|---|---|---|---|
| SYS-001 | Same seed + same commands = same state checksum | unit | test_economy.gd::test_same_seed_same_result |
| SYS-002 | Invariants: no negative resources/population; population never above housing once grown | sim | test_long_runs.gd::test_invariants_hold_for_many_seeds |
| SYS-003 | Extreme rule values (fault injection) keep invariants | sim | test_long_runs.gd::test_extreme_rules_do_not_break_invariants |

## 7. Balance targets
| ID | Target | How measured |
|---|---|---|
| BAL-001 | GreedyBot reaches >= 20 population by tick 300 on seeds 1-5 | test_long_runs.gd::test_bot_colony_grows |
| BAL-002 | An idle colony shrinks below its starting population within 200 ticks | test_long_runs.gd::test_idle_colony_starves |
| BAL-003 | (open) Wood should stay useful: stock below 500 at tick 500 for GreedyBot | not yet - see LOG |

## 8. UI
| ID | Requirement | Tier | Proof |
|---|---|---|---|
| UI-001 | Main scene shows tick, population/housing, stock and rate per resource, building counts | scene | test_main_scene.gd::test_main_scene_boots_and_shows_status |
| UI-002 | One build button per building, showing its cost; pressing it issues the build | scene | test_main_scene.gd::test_build_button_builds |
| UI-003 | The clock advances by itself every 0.5 s; Pause toggles it | scene | test_main_scene.gd::test_ticks_advance_over_time |
| UI-004 | Layout is readable at 960x540 | visual | `gw.sh shot` |

## 10. Technical rules
See CLAUDE.md (sim/ pure, data/ numbers, scenes/ presentation).

## 11. Phases
| Phase | Goal | Requirements | Status |
|---|---|---|---|
| 1 | Simulation core | ECO-*, POP-*, SYS-*, BAL-001/002 | done |
| 2 | Playable UI | UI-* | done |
| 3 | Practice: wood sink + winter season | BAL-003, CR-001 | todo |

## 12. Open questions
- What spends wood after the colony is built up? (BAL-003)

## 13. Change log
| Date | Change | CR |
|---|---|---|
| 2026-11-04 | Initial version | - |
