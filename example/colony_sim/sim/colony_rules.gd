class_name ColonyRules
extends RefCounted
## Game rules loaded from data/rules.json. Data-driven on purpose:
## balancing = editing JSON, not code. JSON numbers arrive as floats in Godot,
## so everything numeric is converted to int here, once.

const DEFAULT_PATH := "res://data/rules.json"

var start_resources: Dictionary = {}
var start_population: int = 0
var start_buildings: Dictionary = {}
var food_per_person: int = 1
var growth_ticks: int = 10
var starvation_loss: int = 1
var event_chance: float = 0.0
var good_harvest_food: int = 0
var work_priority: Array[String] = []
## id -> {cost: {res: int}, workers: int, housing: int, produces: {res: int}}
var buildings: Dictionary = {}


static func load_default() -> ColonyRules:
	return load_from(DEFAULT_PATH)


static func load_from(path: String) -> ColonyRules:
	var text := FileAccess.get_file_as_string(path)
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("ColonyRules: cannot parse %s" % path)
		return null
	return from_dict(data)


static func from_dict(data: Dictionary) -> ColonyRules:
	var r := ColonyRules.new()
	var start: Dictionary = data.get("start", {})
	r.start_resources = _int_dict(start.get("resources", {}))
	r.start_population = int(start.get("population", 0))
	r.start_buildings = _int_dict(start.get("buildings", {}))
	r.food_per_person = int(data.get("food_per_person", 1))
	r.growth_ticks = int(data.get("growth_ticks", 10))
	r.starvation_loss = int(data.get("starvation_loss", 1))
	r.event_chance = float(data.get("event_chance", 0.0))
	r.good_harvest_food = int(data.get("good_harvest_food", 0))
	for id in data.get("work_priority", []):
		r.work_priority.append(str(id))
	var defs: Dictionary = data.get("buildings", {})
	for id in defs:
		var d: Dictionary = defs[id]
		r.buildings[id] = {
			"cost": _int_dict(d.get("cost", {})),
			"workers": int(d.get("workers", 0)),
			"housing": int(d.get("housing", 0)),
			"produces": _int_dict(d.get("produces", {})),
		}
	return r


## Apply a flat override such as {"growth_ticks": 8} or {"farm.workers": 3}.
## Used by the sim runner (--param.x=y) and by balance experiments.
func apply_override(key: String, value: Variant) -> void:
	if key.contains("."):
		var parts := key.split(".")
		var id := parts[0]
		if buildings.has(id) and parts.size() == 2:
			buildings[id][parts[1]] = int(value)
		elif buildings.has(id) and parts.size() == 3:
			buildings[id][parts[1]][parts[2]] = int(value)
		else:
			push_warning("ColonyRules: unknown override " + key)
	elif key in self:
		set(key, value)
	else:
		push_warning("ColonyRules: unknown override " + key)


func make_start_state() -> ColonyState:
	var s := ColonyState.new()
	s.resources = start_resources.duplicate()
	s.population = start_population
	s.buildings = start_buildings.duplicate()
	return s


static func _int_dict(src: Dictionary) -> Dictionary:
	var out := {}
	for k in src:
		out[k] = int(src[k])
	return out
