class_name ColonySim
extends RefCounted
## The rules engine. Deterministic: same seed + same commands => same result.
## The UI (scenes/) only calls build() and step() and reads `state`.

var rules: ColonyRules
var state: ColonyState
var rng := RandomNumberGenerator.new()


func _init(p_rules: ColonyRules, seed_value: int = 0) -> void:
	rules = p_rules
	rng.seed = seed_value
	state = rules.make_start_state()


# --- commands ----------------------------------------------------------------

func can_build(building_id: String) -> bool:
	if not rules.buildings.has(building_id):
		return false
	var cost: Dictionary = rules.buildings[building_id]["cost"]
	for res in cost:
		if state.amount(res) < int(cost[res]):
			return false
	return true


func build(building_id: String) -> bool:
	if not can_build(building_id):
		return false
	var cost: Dictionary = rules.buildings[building_id]["cost"]
	for res in cost:
		state.resources[res] = state.amount(res) - int(cost[res])
	state.buildings[building_id] = state.count(building_id) + 1
	return true


# --- queries -------------------------------------------------------------------

func housing() -> int:
	var total := 0
	for id in state.buildings:
		total += int(rules.buildings[id]["housing"]) * state.count(id)
	return total


## Which buildings get workers this tick: {id: staffed_count}, plus "_free".
func staffing() -> Dictionary:
	var free := state.population
	var out := {}
	for id in rules.work_priority:
		var need: int = rules.buildings[id]["workers"]
		var staffed := 0
		for i in state.count(id):
			if need > free:
				break
			free -= need
			staffed += 1
		out[id] = staffed
	out["_free"] = free
	return out


## Net change per tick if nothing else happens (production - consumption).
func income() -> Dictionary:
	var net := {}
	var staffed := staffing()
	for id in rules.work_priority:
		var produces: Dictionary = rules.buildings[id]["produces"]
		for res in produces:
			net[res] = int(net.get(res, 0)) + int(produces[res]) * int(staffed[id])
	net["food"] = int(net.get("food", 0)) - state.population * rules.food_per_person
	return net


# --- simulation step -----------------------------------------------------------

func step() -> void:
	state.tick += 1
	state.events.clear()

	# 1. production by staffed buildings
	var staffed := staffing()
	for id in rules.work_priority:
		var produces: Dictionary = rules.buildings[id]["produces"]
		for res in produces:
			state.resources[res] = state.amount(res) + int(produces[res]) * int(staffed[id])

	# 2. random events (seeded rng -> deterministic)
	if rng.randf() < rules.event_chance:
		state.resources["food"] = state.amount("food") + rules.good_harvest_food
		state.events.append("good_harvest")

	# 3. consumption, starvation, growth
	var need := state.population * rules.food_per_person
	if state.amount("food") >= need:
		state.resources["food"] = state.amount("food") - need
		if housing() > state.population:
			state.growth_progress += 1
			if state.growth_progress >= rules.growth_ticks:
				state.growth_progress = 0
				state.population += 1
				state.events.append("birth")
	else:
		state.resources["food"] = 0
		state.population = maxi(0, state.population - rules.starvation_loss)
		state.growth_progress = 0
		state.events.append("starvation")
