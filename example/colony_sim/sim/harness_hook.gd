extends RefCounted
## Connects this game's simulation to res://harness/sim_runner.gd.
## Contract: setup(), step(), metrics(), is_finished(), optional check_invariants().

var sim: ColonySim


func setup(seed_value: int, params: Dictionary) -> void:
	var rules := ColonyRules.load_default()
	for key in params:
		rules.apply_override(key, params[key])
	sim = ColonySim.new(rules, seed_value)


func step() -> void:
	GreedyBot.act(sim)
	sim.step()


func metrics() -> Dictionary:
	var s := sim.state
	return {
		"tick": s.tick,
		"population": s.population,
		"food": s.amount("food"),
		"wood": s.amount("wood"),
		"farms": s.count("farm"),
		"mills": s.count("lumber_mill"),
		"houses": s.count("house"),
		"housing": sim.housing(),
	}


func is_finished() -> bool:
	return sim.state.population <= 0


func check_invariants() -> Array:
	var broken: Array[String] = []
	var s := sim.state
	for res in s.resources:
		if s.amount(res) < 0:
			broken.append("negative %s (%d)" % [res, s.amount(res)])
	if s.population < 0:
		broken.append("negative population")
	if s.population > sim.housing() and s.population > sim.rules.start_population:
		broken.append("population %d exceeds housing %d" % [s.population, sim.housing()])
	return broken
