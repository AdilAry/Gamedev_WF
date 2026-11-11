class_name RandomBot
extends RefCounted
## The "monkey": presses random build buttons, sometimes several per tick,
## sometimes one that does not exist. It plays badly on purpose. Its job is to
## reach states no sensible player would, so the invariants get a real workout
## (the fuzzing half of the sim tier). Seeded, so every run can be repeated.

var rng := RandomNumberGenerator.new()


func _init(seed_value: int) -> void:
	rng.seed = seed_value


## Tries 0-3 random builds this tick. Returns the ids that were built.
func act(sim: ColonySim) -> Array[String]:
	var built: Array[String] = []
	var ids: Array = sim.rules.buildings.keys()
	ids.append("no_such_building")
	for i in rng.randi_range(0, 3):
		var id: String = ids[rng.randi_range(0, ids.size() - 1)]
		if sim.build(id):
			built.append(id)
	return built
