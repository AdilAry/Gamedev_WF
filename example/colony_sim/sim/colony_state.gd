class_name ColonyState
extends RefCounted
## Everything the simulation knows, as plain data.
## No nodes, no rendering, no globals -> trivially testable and saveable.

var tick: int = 0
var resources: Dictionary = {}   # "food" -> int, "wood" -> int
var population: int = 0
var buildings: Dictionary = {}   # building id -> count
var growth_progress: int = 0
var events: Array[String] = []   # what happened during the last tick


func count(building_id: String) -> int:
	return int(buildings.get(building_id, 0))


func amount(resource: String) -> int:
	return int(resources.get(resource, 0))


## Stable fingerprint of the state; equal seeds + equal inputs => equal checksum.
func checksum() -> int:
	var parts := [tick, population, growth_progress]
	for k in _sorted_keys(resources):
		parts.append("%s=%d" % [k, resources[k]])
	for k in _sorted_keys(buildings):
		parts.append("%s=%d" % [k, buildings[k]])
	return str(parts).hash()


func to_dict() -> Dictionary:
	return {
		"tick": tick,
		"resources": resources.duplicate(),
		"population": population,
		"buildings": buildings.duplicate(),
		"growth_progress": growth_progress,
	}


static func _sorted_keys(d: Dictionary) -> Array:
	var keys := d.keys()
	keys.sort()
	return keys
