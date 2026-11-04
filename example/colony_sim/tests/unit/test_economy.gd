extends "res://harness/gw_test.gd"
## Unit tier: pure rules, no scene tree. Each test cites the GDD requirement it proves.

var rules: ColonyRules


func before_each() -> void:
	rules = ColonyRules.load_default()


func test_rules_load_as_integers() -> void:
	# ECO-001: rules come from data/rules.json; numbers are ints, not floats
	assert_not_null(rules, "rules.json must parse")
	assert_eq(typeof(rules.buildings["farm"]["workers"]), TYPE_INT)
	assert_eq(typeof(rules.start_population), TYPE_INT)


func test_staffed_farm_produces_food() -> void:
	# ECO-002: a fully staffed farm adds its "produces.food" every tick
	rules.event_chance = 0.0
	var sim := ColonySim.new(rules, 1)
	sim.state.population = 2
	sim.state.buildings = {"farm": 1, "house": 1}
	sim.state.resources = {"food": 0, "wood": 0}
	sim.step()
	var expected := 4 - 2 * rules.food_per_person
	assert_eq(sim.state.amount("food"), expected, "4 produced, 2 eaten")


func test_unstaffed_farm_produces_nothing() -> void:
	# ECO-003: buildings without enough workers produce nothing
	var sim := ColonySim.new(rules, 1)
	sim.state.population = 1
	sim.state.buildings = {"farm": 1, "house": 1}
	assert_eq(sim.staffing()["farm"], 0)
	assert_eq(sim.income().get("food", 0), -1)


func test_work_priority_staffs_farms_first() -> void:
	# ECO-004: workers go to buildings in data "work_priority" order
	var sim := ColonySim.new(rules, 1)
	sim.state.population = 2
	sim.state.buildings = {"lumber_mill": 1, "farm": 1}
	var s := sim.staffing()
	assert_eq(s["farm"], 1)
	assert_eq(s["lumber_mill"], 0)


func test_broken_rules_file_is_reported() -> void:
	# ECO-006: a broken rules file is reported as an error and yields no rules
	# (never half-loaded rules). expect_error() declares the error as intended;
	# without it, the push_error in ColonyRules would fail this test.
	expect_error("parse")
	var path := "user://broken_rules.json"
	var f := FileAccess.open(path, FileAccess.WRITE)
	assert_not_null(f, "can write a temp file")
	if f == null:
		return
	f.store_string("{ this is not json")
	f.close()
	assert_null(ColonyRules.load_from(path), "broken file must give null")


func test_build_spends_resources() -> void:
	# ECO-005: building costs are paid up front; impossible builds change nothing
	var sim := ColonySim.new(rules, 1)
	sim.state.resources = {"food": 0, "wood": 10}
	assert_true(sim.build("farm"))
	assert_eq(sim.state.amount("wood"), 0)
	assert_false(sim.build("farm"), "no wood left")
	assert_eq(sim.state.count("farm"), rules.start_buildings.get("farm", 0) + 1)


func test_starvation_reduces_population_and_never_goes_negative() -> void:
	# POP-002: when food runs out, population drops; food never goes below 0
	rules.event_chance = 0.0
	var sim := ColonySim.new(rules, 1)
	sim.state.population = 3
	sim.state.buildings = {}
	sim.state.resources = {"food": 0, "wood": 0}
	for i in 10:
		sim.step()
	assert_eq(sim.state.population, 0)
	assert_eq(sim.state.amount("food"), 0)


func test_growth_needs_food_and_housing() -> void:
	# POP-001: +1 population every growth_ticks while fed AND housing is free
	rules.event_chance = 0.0
	var sim := ColonySim.new(rules, 1)
	sim.state.population = 1
	sim.state.buildings = {"house": 1}
	sim.state.resources = {"food": 1000, "wood": 0}
	for i in rules.growth_ticks:
		sim.step()
	assert_eq(sim.state.population, 2, "grew once")
	sim.state.buildings = {}
	for i in rules.growth_ticks * 2:
		sim.step()
	assert_eq(sim.state.population, 2, "no housing, no growth")


func test_same_seed_same_result() -> void:
	# SYS-001: the simulation is deterministic for a given seed and command list
	var a := ColonySim.new(ColonyRules.load_default(), 42)
	var b := ColonySim.new(ColonyRules.load_default(), 42)
	for i in 200:
		GreedyBot.act(a)
		a.step()
		GreedyBot.act(b)
		b.step()
	assert_eq(a.state.checksum(), b.state.checksum())
