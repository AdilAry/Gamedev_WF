extends SceneTree
## Gamedev-WF test runner. Dependency-free, headless, agent-friendly.
##
## Run (from the project folder):
##     godot --headless --path . -s res://harness/test_runner.gd -- --tier=unit
##     godot --headless --path . -s res://harness/test_runner.gd -- --tier=all --filter=economy
##     ... -- --verbose            (also print PASS lines)
##
## Tiers map to folders:  unit -> res://tests/unit
##                        sim  -> res://tests/sim
##                        scene-> res://tests/scene
## Output is deliberately terse (failures + one summary line) so an AI agent
## can read it without burning context. Exit code 0 = all green, 1 = failures.

const TIER_DIRS := {
	"unit": "res://tests/unit",
	"sim": "res://tests/sim",
	"scene": "res://tests/scene",
}
const TIER_ORDER := ["unit", "sim", "scene"]

var _passed := 0
var _failed := 0
var _verbose := false


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := _parse_args(OS.get_cmdline_user_args())
	_verbose = args.has("verbose")
	var filter: String = args.get("filter", "")
	var tier_arg: String = args.get("tier", "all")

	var tiers: Array[String] = []
	if tier_arg == "all":
		tiers.assign(TIER_ORDER)
	else:
		for t in tier_arg.split(",", false):
			if not TIER_DIRS.has(t):
				printerr("HARNESS: unknown tier '%s' (use unit, sim, scene or all)" % t)
				quit(2)
				return
			tiers.append(t)

	var started := Time.get_ticks_msec()
	for tier in tiers:
		var files := _find_tests(TIER_DIRS[tier])
		for path in files:
			await _run_file(tier, path, filter)

	var ms := Time.get_ticks_msec() - started
	var status := "FAILED" if _failed > 0 else "OK"
	print("RESULT %s: %d passed, %d failed (%s) in %d ms" % [status, _passed, _failed, ",".join(PackedStringArray(tiers)), ms])
	if _passed + _failed == 0:
		print("HARNESS: no tests found. Test files must be named test_*.gd inside tests/<tier>/")
	quit(1 if _failed > 0 else 0)


func _run_file(tier: String, path: String, filter: String) -> void:
	var script: Script = load(path)
	if script == null or not script.can_instantiate():
		_failed += 1
		print("FAIL [%s] %s :: could not load script (parse error? see output above)" % [tier, path])
		return

	var methods: Array[String] = []
	for m in script.get_script_method_list():
		var mname: String = m["name"]
		if not mname.begins_with("test_") or methods.has(mname):
			continue
		if filter != "" and not (mname.contains(filter) or path.contains(filter)):
			continue
		methods.append(mname)

	for mname in methods:
		var inst = script.new()
		inst.tree = self
		if inst.has_method("before_each"):
			await inst.before_each()
		await inst.call(mname)
		if inst.has_method("after_each"):
			await inst.after_each()
		inst._cleanup()
		# give queued frees a frame to happen before the next test
		await process_frame

		var failures: Array[String] = inst._failures
		var label := "[%s] %s::%s" % [tier, path.get_file(), mname]
		if failures.is_empty():
			_passed += 1
			if _verbose:
				print("PASS " + label)
		else:
			_failed += 1
			print("FAIL " + label)
			for f in failures:
				print("     - " + f)


func _find_tests(dir_path: String) -> Array[String]:
	var out: Array[String] = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return out
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		var full := dir_path.path_join(entry)
		if dir.current_is_dir():
			if not entry.begins_with("."):
				out.append_array(_find_tests(full))
		elif entry.begins_with("test_") and entry.ends_with(".gd"):
			out.append(full)
		entry = dir.get_next()
	dir.list_dir_end()
	out.sort()
	return out


func _parse_args(raw: PackedStringArray) -> Dictionary:
	var out := {}
	for a in raw:
		if not a.begins_with("--"):
			continue
		var body := a.substr(2)
		var eq := body.find("=")
		if eq == -1:
			out[body] = "true"
		else:
			out[body.substr(0, eq)] = body.substr(eq + 1)
	return out
