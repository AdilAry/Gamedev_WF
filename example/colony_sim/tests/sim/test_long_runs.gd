extends "res://harness/gw_test.gd"
## Sim tier: hundreds of ticks with the GreedyBot, several seeds.
## These are the "black box" checks: we don't care how, only that the
## colony behaves within the design targets from docs/GDD.md.

const SEEDS := [1, 2, 3, 4, 5]
const TICKS := 300

var hook_script := preload("res://sim/harness_hook.gd")


func test_invariants_hold_for_many_seeds() -> void:
	# SYS-002: no negative resources/population, never above housing
	for seed_value in SEEDS:
		var hook = hook_script.new()
		hook.setup(seed_value, {})
		for t in TICKS:
			hook.step()
			var broken: Array = hook.check_invariants()
			if not broken.is_empty():
				fail("seed %d tick %d: %s" % [seed_value, t, broken])
				break


func test_bot_colony_grows() -> void:
	# BAL-001: a simple bot reaches >= 20 population by tick 300 on every seed
	for seed_value in SEEDS:
		var hook = hook_script.new()
		hook.setup(seed_value, {})
		for t in TICKS:
			hook.step()
		var pop: int = hook.metrics()["population"]
		assert_true(pop >= 20, "seed %d: population %d at tick %d" % [seed_value, pop, TICKS])


func test_idle_colony_starves() -> void:
	# BAL-002: doing nothing must be punished - the starting colony cannot feed itself
	var sim := ColonySim.new(ColonyRules.load_default(), 7)
	for t in 200:
		sim.step()
	assert_true(sim.state.population < ColonyRules.load_default().start_population, "idle colony should shrink")


func test_extreme_rules_do_not_break_invariants() -> void:
	# SYS-003 (fault injection): zero-cost / zero-food / huge numbers must not crash or go negative
	var cases := [
		{"growth_ticks": 1},
		{"food_per_person": 5},
		{"farm.produces.food": 0},
		{"house.cost.wood": 0, "event_chance": 1.0},
	]
	for params in cases:
		var hook = hook_script.new()
		hook.setup(3, params)
		for t in 150:
			hook.step()
			var broken: Array = hook.check_invariants()
			if not broken.is_empty():
				fail("%s tick %d: %s" % [params, t, broken])
				break
