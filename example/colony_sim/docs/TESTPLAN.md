# Test plan - Colony Sim

| ID | Tier | Test | Status |
|---|---|---|---|
| ECO-001 | unit | tests/unit/test_economy.gd::test_rules_load_as_integers | green |
| ECO-002 | unit | tests/unit/test_economy.gd::test_staffed_farm_produces_food | green |
| ECO-003 | unit | tests/unit/test_economy.gd::test_unstaffed_farm_produces_nothing | green |
| ECO-004 | unit | tests/unit/test_economy.gd::test_work_priority_staffs_farms_first | green |
| ECO-005 | unit | tests/unit/test_economy.gd::test_build_spends_resources | green |
| ECO-006 | unit | tests/unit/test_economy.gd::test_broken_rules_file_is_reported | green |
| POP-001 | unit | tests/unit/test_economy.gd::test_growth_needs_food_and_housing | green |
| POP-002 | unit | tests/unit/test_economy.gd::test_starvation_reduces_population_and_never_goes_negative | green |
| SYS-001 | unit | tests/unit/test_economy.gd::test_same_seed_same_result | green |
| SYS-002 | sim | tests/sim/test_long_runs.gd::test_invariants_hold_for_many_seeds | green |
| SYS-003 | sim | tests/sim/test_long_runs.gd::test_extreme_rules_do_not_break_invariants | green |
| BAL-001 | sim | tests/sim/test_long_runs.gd::test_bot_colony_grows | green |
| BAL-002 | sim | tests/sim/test_long_runs.gd::test_idle_colony_starves | green |
| BAL-003 | sim | - | todo |
| UI-001 | scene | tests/scene/test_main_scene.gd::test_main_scene_boots_and_shows_status | green |
| UI-002 | scene | tests/scene/test_main_scene.gd::test_build_button_builds | green |
| UI-003 | scene | tests/scene/test_main_scene.gd::test_ticks_advance_over_time | green |
| UI-004 | visual | `./harness/gw.sh shot` | manual |

## Fault injection
| Case | Expected | Test | Status |
|---|---|---|---|
| growth every tick | invariants hold | SYS-003 | green |
| 5 food per person | colony starves, nothing negative | SYS-003 | green |
| farms produce 0 | colony starves, nothing negative | SYS-003 | green |
| free houses + harvest every tick | invariants hold | SYS-003 | green |
| rules file is not valid JSON | error reported, no rules returned | ECO-006 | green |
