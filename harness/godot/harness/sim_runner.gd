extends SceneTree
## Gamedev-WF headless simulation runner (the "bench" for strategy / sim games).
##
## Runs the game's simulation core with NO rendering, for many ticks and many
## seeds, writes a CSV of per-tick metrics and prints a compact summary.
## This is how the agent (and you) check balance, pacing and stability.
##
## Run (from the project folder):
##     godot --headless --path . -s res://harness/sim_runner.gd -- --seeds=1-20 --ticks=600
##     ... -- --seeds=7 --ticks=2000 --param.growth_ticks=8 --out=reports/sim
##
## The project provides the hook script res://sim/harness_hook.gd (override with
## --hook=res://path.gd). It must implement:
##     func setup(seed_value: int, params: Dictionary) -> void
##     func step() -> void                      # advance one tick (incl. bot decisions)
##     func metrics() -> Dictionary             # flat {name: number} for this tick
##     func is_finished() -> bool               # e.g. colony died / someone won
## Optional:
##     func check_invariants() -> Array         # list of violated rules (strings)
##
## Output: a min/mean/max table of the final metrics, the cost per tick (is
## GDScript fast enough?), a DIGEST line (same args + same code => same digest,
## so determinism is checked by comparing one line), and a SAME ON EVERY SEED
## line naming metrics that never vary (more seeds prove nothing about those).
##
## Exit code 0 = ran fine, 1 = invariant violations, 2 = setup problem.

const DEFAULT_HOOK := "res://sim/harness_hook.gd"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := _parse_args(OS.get_cmdline_user_args())
	var hook_path: String = args.get("hook", DEFAULT_HOOK)
	var ticks := int(args.get("ticks", "500"))
	var seeds := _parse_seeds(args.get("seeds", "1-10"))
	var out_dir: String = args.get("out", "reports/sim")
	var params := {}
	for k in args:
		if k.begins_with("param."):
			params[k.substr(6)] = _to_value(args[k])

	var hook_script: Script = load(hook_path)
	if hook_script == null or not hook_script.can_instantiate():
		printerr("HARNESS: cannot load sim hook %s" % hook_path)
		quit(2)
		return

	var abs_dir := ProjectSettings.globalize_path("res://" + out_dir) if not out_dir.is_absolute_path() else out_dir
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var stamp := Time.get_datetime_string_from_system().replace(":", "").replace("-", "").replace("T", "_")
	var csv_path := abs_dir.path_join("sim_%s.csv" % stamp)
	var csv := FileAccess.open(csv_path, FileAccess.WRITE)
	if csv == null:
		printerr("HARNESS: cannot write %s" % csv_path)
		quit(2)
		return

	var header: Array[String] = []
	var finals: Array[Dictionary] = []
	var violations := 0
	var started := Time.get_ticks_msec()

	for seed_value in seeds:
		var hook = hook_script.new()
		hook.setup(seed_value, params)
		var last := {}
		var t := 0
		while t < ticks:
			hook.step()
			t += 1
			var row: Dictionary = hook.metrics()
			if header.is_empty():
				header.assign(row.keys())
				csv.store_line(",".join(PackedStringArray(["seed"] + header)))
			var cells: Array[String] = [str(seed_value)]
			for key in header:
				cells.append(str(row.get(key, "")))
			csv.store_line(",".join(PackedStringArray(cells)))
			last = row
			if hook.has_method("check_invariants"):
				var broken: Array = hook.check_invariants()
				if not broken.is_empty():
					violations += 1
					print("INVARIANT seed=%d tick=%d: %s" % [seed_value, t, "; ".join(PackedStringArray(broken))])
					break
			if hook.is_finished():
				break
		last["ticks_run"] = t
		last["seed"] = seed_value
		finals.append(last)

	csv.close()
	_print_summary(finals, ticks, Time.get_ticks_msec() - started)
	print("CSV %s" % csv_path)
	quit(1 if violations > 0 else 0)


func _print_summary(finals: Array[Dictionary], ticks: int, ms: int) -> void:
	var total_ticks := 0
	for f in finals:
		total_ticks += int(f.get("ticks_run", 0))
	var per_tick := float(ms) / maxf(1.0, float(total_ticks))
	print("SIM %d seeds x up to %d ticks in %d ms (%.3f ms/tick incl. bot + hook)" % [finals.size(), ticks, ms, per_tick])
	if finals.is_empty():
		return
	var keys: Array = finals[0].keys()
	var constant: Array[String] = []
	print("%-22s %10s %10s %10s" % ["final metric", "min", "mean", "max"])
	for key in keys:
		if key == "seed":
			continue
		var lo := INF
		var hi := -INF
		var total := 0.0
		var n := 0
		for f in finals:
			var v = f.get(key)
			if typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT:
				lo = minf(lo, v)
				hi = maxf(hi, v)
				total += v
				n += 1
		if n > 0:
			print("%-22s %10.2f %10.2f %10.2f" % [key, lo, total / n, hi])
			if lo == hi and key != "tick" and key != "ticks_run":
				constant.append(str(key))
	var short: Array[String] = []
	for f in finals:
		if int(f["ticks_run"]) < ticks:
			short.append("%d@%d" % [f["seed"], f["ticks_run"]])
	if not short.is_empty():
		print("ENDED EARLY (seed@tick): " + ", ".join(PackedStringArray(short)))
	if finals.size() > 1 and not constant.is_empty():
		print("SAME ON EVERY SEED: %s (randomness does not reach these)" % ", ".join(PackedStringArray(constant)))
	print("DIGEST %s" % str(finals).md5_text().substr(0, 12))


func _parse_seeds(spec: String) -> Array[int]:
	var out: Array[int] = []
	for part in spec.split(",", false):
		if part.contains("-"):
			var ab := part.split("-")
			for s in range(int(ab[0]), int(ab[1]) + 1):
				out.append(s)
		else:
			out.append(int(part))
	return out


func _to_value(s: String) -> Variant:
	if s.is_valid_int():
		return int(s)
	if s.is_valid_float():
		return float(s)
	if s == "true" or s == "false":
		return s == "true"
	return s


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
