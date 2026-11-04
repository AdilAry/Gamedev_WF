extends Control
## Presentation layer. Builds its UI in code (AI agents edit code far more
## reliably than hand-written .tscn files). Holds NO game rules: it only sends
## commands to ColonySim and displays ColonySim.state.

const TICK_SECONDS := 0.5

var sim: ColonySim
var paused := false

var _status: Label
var _log: Label
var _timer: Timer


func _ready() -> void:
	sim = ColonySim.new(ColonyRules.load_default(), int(Time.get_unix_time_from_system()))
	_build_ui()
	_refresh()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color("1d2330")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root := VBoxContainer.new()
	root.name = "Root"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 24
	root.offset_top = 24
	root.add_theme_constant_override("separation", 12)
	add_child(root)

	var title := Label.new()
	title.text = "Colony Sim - Gamedev-WF example"
	title.add_theme_font_size_override("font_size", 24)
	root.add_child(title)

	_status = Label.new()
	_status.name = "Status"
	root.add_child(_status)

	var buttons := HBoxContainer.new()
	root.add_child(buttons)
	for id in sim.rules.buildings:
		var b := Button.new()
		b.name = "Build_%s" % id
		b.text = "Build %s %s" % [str(id).capitalize(), _cost_text(id)]
		b.pressed.connect(_on_build_pressed.bind(id))
		buttons.add_child(b)

	var pause := Button.new()
	pause.name = "Pause"
	pause.text = "Pause"
	pause.pressed.connect(_on_pause_pressed)
	buttons.add_child(pause)

	_log = Label.new()
	_log.name = "Log"
	root.add_child(_log)

	_timer = Timer.new()
	_timer.wait_time = TICK_SECONDS
	_timer.autostart = true
	_timer.timeout.connect(_on_tick)
	add_child(_timer)


func _on_tick() -> void:
	if paused or sim.state.population <= 0:
		return
	sim.step()
	if not sim.state.events.is_empty():
		_log.text = "Tick %d: %s" % [sim.state.tick, ", ".join(PackedStringArray(sim.state.events))]
	_refresh()


func _on_build_pressed(building_id: String) -> void:
	if sim.build(building_id):
		_log.text = "Built a %s" % building_id
	else:
		_log.text = "Not enough resources for %s" % building_id
	_refresh()


func _on_pause_pressed() -> void:
	paused = not paused


func _refresh() -> void:
	var s := sim.state
	var net := sim.income()
	_status.text = "Tick %d   Population %d / housing %d\nFood %d (%+d/tick)   Wood %d (%+d/tick)\nFarms %d   Mills %d   Houses %d" % [
		s.tick, s.population, sim.housing(),
		s.amount("food"), int(net.get("food", 0)), s.amount("wood"), int(net.get("wood", 0)),
		s.count("farm"), s.count("lumber_mill"), s.count("house"),
	]
	if s.population <= 0:
		_status.text += "\nThe colony has died out."


func _cost_text(building_id: String) -> String:
	var cost: Dictionary = sim.rules.buildings[building_id]["cost"]
	var parts: Array[String] = []
	for res in cost:
		parts.append("%d %s" % [cost[res], res])
	return "(" + ", ".join(PackedStringArray(parts)) + ")"
