extends "res://harness/gw_test.gd"
## Scene tier: the real scene in the real SceneTree, driven like a player would.


func test_main_scene_boots_and_shows_status() -> void:
	# UI-001: main scene starts and shows the colony status
	var main = add_scene("res://scenes/main.tscn")
	await wait_frames(2)
	assert_not_null(main)
	var status: Label = main.find_child("Status", true, false)
	assert_not_null(status, "Status label exists")
	if status:
		assert_true(status.text.contains("Population"), "status text: " + status.text)


func test_build_button_builds() -> void:
	# UI-002: pressing a build button issues the build command to the simulation
	var main = add_scene("res://scenes/main.tscn")
	await wait_frames(1)
	main.sim.state.resources["wood"] = 100
	var before: int = main.sim.state.count("farm")
	var button: Button = main.find_child("Build_farm", true, false)
	assert_not_null(button, "Build_farm button exists")
	if button:
		button.pressed.emit()
		assert_eq(main.sim.state.count("farm"), before + 1)


func test_ticks_advance_over_time() -> void:
	# UI-003: the game clock advances by itself (Timer drives sim.step)
	var main = add_scene("res://scenes/main.tscn")
	await wait_seconds(1.3)  # main.gd ticks every 0.5 s
	assert_true(main.sim.state.tick >= 2, "tick is %d" % main.sim.state.tick)
