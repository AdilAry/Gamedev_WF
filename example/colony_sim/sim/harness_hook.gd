extends RefCounted
## Connects this game's simulation to res://harness/sim_runner.gd.
## Contract: setup(), step(), metrics(), is_finished(), optional
## check_invariants() and events().
##
## Params (from --param.x=y or a cases file):
##   bot = greedy (default) | idle | random   who plays
##   anything else                            a rules override (see ColonyRules.apply_override)

var sim: ColonySim
var bot := "greedy"
var random_bot: RandomBot
var last_events: Array[String] = []


func setup(seed_value: int, params: Dictionary) -> void:
	var rules := ColonyRules.load_default()
	for key in params:
		if key == "bot":
			bot = str(params[key])
		else:
			rules.apply_override(key, params[key])
	sim = ColonySim.new(rules, seed_value)
	# its own generator, so the bot's dice never change the game's dice
	random_bot = RandomBot.new(seed_value + 1000)


func step() -> void:
	last_events.clear()
	match bot:
		"idle":
			pass
		"random":
			for id in random_bot.act(sim):
				last_events.append("build " + id)
		_:
			var choice := GreedyBot.act(sim)
			if choice != "":
				last_events.append("build " + choice)
	sim.step()
	last_events.append_array(sim.state.events)


## What happened in the last step (bot decisions first, then game events).
func events() -> Array:
	return last_events


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
