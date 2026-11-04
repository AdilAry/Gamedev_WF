class_name GreedyBot
extends RefCounted
## A deliberately simple "player" used by sim tests and balance runs.
## It is not meant to be smart; it is meant to be predictable, so changes in
## its results point at changes in the rules.

## Makes at most one build decision per tick. Returns the building id or "".
static func act(sim: ColonySim) -> String:
	var net := sim.income()
	var free: int = sim.staffing()["_free"]
	var choice := ""
	if int(net.get("food", 0)) < 1 and free >= 2:
		choice = "farm"
	elif sim.housing() <= sim.state.population:
		choice = "house"
	elif free >= 2 and int(net.get("food", 0)) >= 2:
		choice = "lumber_mill"
	if choice != "" and sim.build(choice):
		return choice
	return ""
