extends SceneTree
## Gamedev-WF headless simulation runner (the "bench" for strategy / sim games).
##
## Runs the game's simulation core with NO rendering. Three modes:
##
##   seeds (default)  many seeds x many ticks -> CSV + min/mean/max summary
##       ... -s res://harness/sim_runner.gd -- --seeds=1-20 --ticks=600 --param.growth_ticks=8
##   --cases[=file]   named scenarios side by side, checked against targets
##       ... -- --cases=res://tests/cases/balance.json [--only=name] [--strict] [--param.x=y]
##   --trace          one seed as a readable timeline (what did the bot do, and when?)
##       ... -- --trace --seed=7 --ticks=200 [--every=20] [--show=population,food]
##
## The project provides the hook script res://sim/harness_hook.gd (override with
## --hook=res://path.gd). It must implement:
##     func setup(seed_value: int, params: Dictionary) -> void
##     func step() -> void                      # advance one tick (incl. bot decisions)
##     func metrics() -> Dictionary             # flat {name: number} for this tick
##     func is_finished() -> bool               # e.g. colony died / someone won
## Optional:
##     func check_invariants() -> Array         # list of violated rules (strings)
##     func events() -> Array                   # what happened in the last step (strings), for --trace
##
## Cases file (JSON, written by the human - these are the situations you care about):
##     { "defaults": { "seeds": "1-10", "ticks": 500, "show": ["population"] },
##       "cases": [ { "name": "baseline", "note": "why this case exists",
##                    "params": { "bot": "greedy" },
##                    "expect": { "population": [20, null], "win": { "mean": [0.35, 0.65] } } } ] }
## "expect": [low, high] must hold on EVERY seed (null = no bound);
##           {"mean": [low, high]} checks the average over the seeds (win rates).
## JSON has no integers: whole numbers in "params" reach the hook as int.
##
## Output is terse on purpose. Every mode ends with a DIGEST or file line; the
## seeds mode prints the cost per tick, a DIGEST (same args + same code => same
## digest) and a SAME ON EVERY SEED line naming metrics that never vary.
##
## Exit code 0 = ran fine, 1 = invariant violations (or targets off with
## --strict), 2 = setup problem.

const DEFAULT_HOOK := "res://sim/harness_hook.gd"
const DEFAULT_CASES := "res://tests/cases/balance.json"
const HIDDEN_METRICS := ["seed", "tick", "ticks_run"]

var _hook_script: Script
var _violations := 0
var _label := ""  # prefix for INVARIANT lines (the case name in --cases mode)


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := _parse_args(OS.get_cmdline_user_args())
	var hook_path: String = args.get("hook", DEFAULT_HOOK)
	_hook_script = load(hook_path)
	if _hook_script == null or not _hook_script.can_instantiate():
		printerr("HARNESS: cannot load sim hook %s" % hook_path)
		quit(2)
		return
	var params := {}
	for k in args:
		if k.begins_with("param."):
			params[k.substr(6)] = _to_value(args[k])
	var code := 0
	if args.has("cases"):
		code = _run_cases(args, params)
	elif args.has("trace"):
		code = _run_trace(args, params)
	else:
		code = _run_seeds(args, params)
	quit(code)


## Runs one seed. Returns the final metrics row plus "ticks_run" and "seed".
## `each_tick` (optional) is called as each_tick.call(tick, row, hook).
func _play(seed_value: int, ticks: int, params: Dictionary, each_tick: Callable = Callable()) -> Dictionary:
	var hook = _hook_script.new()
	hook.setup(seed_value, params)
	var can_check: bool = hook.has_method("check_invariants")
	var last := {}
	var t := 0
	while t < ticks:
		hook.step()
		t += 1
		last = hook.metrics()
		if each_tick.is_valid():
			each_tick.call(t, last, hook)
		if can_check:
			var broken: Array = hook.check_invariants()
			if not broken.is_empty():
				_violations += 1
				print("INVARIANT %sseed=%d tick=%d: %s" % [_label, seed_value, t, "; ".join(PackedStringArray(broken))])
				break
		if hook.is_finished():
			break
	last["ticks_run"] = t
	last["seed"] = seed_value
	return last


# --- mode: seeds -------------------------------------------------------------

func _run_seeds(args: Dictionary, params: Dictionary) -> int:
	var ticks := int(args.get("ticks", "500"))
	var seeds := _parse_seeds(args.get("seeds", "1-10"))
	var abs_dir := _out_dir(args.get("out", "reports/sim"))
	var csv_path := abs_dir.path_join("sim_%s.csv" % _stamp())
	var csv := FileAccess.open(csv_path, FileAccess.WRITE)
	if csv == null:
		printerr("HARNESS: cannot write %s" % csv_path)
		return 2

	var header: Array[String] = []
	var finals: Array[Dictionary] = []
	var started := Time.get_ticks_msec()
	for seed_value in seeds:
		var write_row := func(_t: int, row: Dictionary, _hook: Object) -> void:
			if header.is_empty():
				header.assign(row.keys())
				csv.store_line(",".join(PackedStringArray(["seed"] + header)))
			var cells: Array[String] = [str(seed_value)]
			for key in header:
				cells.append(str(row.get(key, "")))
			csv.store_line(",".join(PackedStringArray(cells)))
		finals.append(_play(seed_value, ticks, params, write_row))
	csv.close()
	_print_summary(finals, ticks, Time.get_ticks_msec() - started)
	print("CSV %s" % csv_path)
	return 1 if _violations > 0 else 0


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
		var s := _stats(finals, key)
		if int(s["n"]) > 0:
			print("%-22s %10.2f %10.2f %10.2f" % [key, s["lo"], s["mean"], s["hi"]])
			if s["lo"] == s["hi"] and key != "tick" and key != "ticks_run":
				constant.append(str(key))
	var short := _ended_early(finals, ticks)
	if short != "":
		print("ENDED EARLY (seed@tick): " + short)
	if finals.size() > 1 and not constant.is_empty():
		print("SAME ON EVERY SEED: %s (randomness does not reach these)" % ", ".join(PackedStringArray(constant)))
	print("DIGEST %s" % str(finals).md5_text().substr(0, 12))


# --- mode: cases -------------------------------------------------------------

func _run_cases(args: Dictionary, cli_params: Dictionary) -> int:
	var path: String = args["cases"]
	if path == "true" or path == "":
		path = DEFAULT_CASES
	elif not path.begins_with("res://") and not path.is_absolute_path():
		path = "res://" + path
	if not FileAccess.file_exists(path):
		printerr("HARNESS: no cases file at %s (copy the kit's harness/templates/cases.json to tests/cases/balance.json)" % path)
		return 2
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(data) != TYPE_DICTIONARY or typeof(data.get("cases")) != TYPE_ARRAY:
		printerr("HARNESS: %s is not valid: need {\"cases\": [ {\"name\": ..., \"params\": {...}, \"expect\": {...}} ]}" % path)
		return 2

	var defaults: Dictionary = data.get("defaults", {})
	var only: String = args.get("only", "")
	var started := Time.get_ticks_msec()
	var md: Array[String] = ["| case | note | metric | min | mean | max | target | verdict |", "|---|---|---|---|---|---|---|---|"]
	var off: Array[String] = []
	var all_finals: Array = []
	var case_count := 0
	var target_count := 0
	print("%-18s %-16s %10s %10s %10s  %-16s %s" % ["case", "metric", "min", "mean", "max", "target", "verdict"])

	var index := 0
	for c in data["cases"]:
		index += 1
		if typeof(c) != TYPE_DICTIONARY:
			continue
		var cname := str(c.get("name", "case%d" % index))
		if only != "" and not cname.contains(only):
			continue
		case_count += 1
		var seeds := _parse_seeds(str(args.get("seeds", c.get("seeds", defaults.get("seeds", "1-10")))))
		var ticks := int(float(str(args.get("ticks", c.get("ticks", defaults.get("ticks", 500))))))
		var params := {}
		for src in [defaults.get("params", {}), c.get("params", {})]:
			if typeof(src) == TYPE_DICTIONARY:
				for k in src:
					params[k] = _json_value(src[k])
		params.merge(cli_params, true)

		_label = "case=%s " % cname
		var finals: Array[Dictionary] = []
		for seed_value in seeds:
			finals.append(_play(seed_value, ticks, params))
		all_finals.append(finals)

		var expect: Dictionary = c.get("expect", {}) if typeof(c.get("expect")) == TYPE_DICTIONARY else {}
		var metrics: Array[String] = []
		for k in expect:
			metrics.append(str(k))
		var show = c.get("show", defaults.get("show", []))
		if typeof(show) == TYPE_ARRAY:
			for k in show:
				if not metrics.has(str(k)):
					metrics.append(str(k))
		if metrics.is_empty() and not finals.is_empty():
			for k in finals[0]:
				if not HIDDEN_METRICS.has(str(k)):
					metrics.append(str(k))

		var note := str(c.get("note", ""))
		for m in metrics:
			var s := _stats(finals, m)
			if int(s["n"]) == 0:
				print("%-18s %-16s %s" % [cname, m, "(the hook reports no metric with this name)"])
				md.append("| %s | %s | %s | - | - | - | - | no such metric |" % [cname, note, m])
				if expect.has(m):
					target_count += 1
					off.append("%s/%s" % [cname, m])
				continue
			var target := "-"
			var verdict := ""
			if expect.has(m):
				target_count += 1
				var judged := _judge(expect[m], s)
				target = judged[0]
				verdict = judged[1]
				if verdict != "ok":
					off.append("%s/%s" % [cname, m])
			print("%-18s %-16s %10s %10s %10s  %-16s %s" % [cname, m, _num(s["lo"]), _num(s["mean"]), _num(s["hi"]), target, verdict])
			md.append("| %s | %s | %s | %s | %s | %s | %s | %s |" % [cname, note, m, _num(s["lo"]), _num(s["mean"]), _num(s["hi"]), target, verdict])
		var short := _ended_early(finals, ticks)
		if short != "":
			print("%-18s ended early (seed@tick): %s" % [cname, short])
			md.append("| %s | %s | *ended early (seed@tick)* | | | | | %s |" % [cname, note, short])

	_label = ""
	if case_count == 0:
		printerr("HARNESS: no case matches (file %s, --only=%s)" % [path, only])
		return 2
	var abs_dir := _out_dir(args.get("out", "reports/cases"))
	var md_path := abs_dir.path_join("cases_%s.md" % _stamp())
	var f := FileAccess.open(md_path, FileAccess.WRITE)
	if f != null:
		f.store_line("# Balance cases - %s" % Time.get_datetime_string_from_system().replace("T", " "))
		f.store_line("")
		f.store_line("File: `%s`%s" % [path, "" if cli_params.is_empty() else "  -  what-if overrides: `%s`" % str(cli_params)])
		f.store_line("")
		for line in md:
			f.store_line(line)
		f.close()
	if not off.is_empty():
		print("OFF TARGET: %s" % ", ".join(PackedStringArray(off)))
	print("CASES %d cases, %d targets: %d ok, %d off, in %d ms" % [case_count, target_count, target_count - off.size(), off.size(), Time.get_ticks_msec() - started])
	print("MD %s" % md_path)
	print("DIGEST %s" % str(all_finals).md5_text().substr(0, 12))
	if _violations > 0:
		return 1
	return 1 if args.has("strict") and not off.is_empty() else 0


## Compare stats with a target. Returns [target text, verdict].
## target = [low, high] (every seed) or {"mean": [low, high]}; null = no bound.
func _judge(target: Variant, s: Dictionary) -> Array:
	var on_mean := false
	var bounds: Variant = target
	if typeof(target) == TYPE_DICTIONARY:
		on_mean = target.has("mean")
		bounds = target.get("mean", target.get("all"))
	if typeof(bounds) != TYPE_ARRAY or bounds.size() != 2:
		return ["?", "BAD TARGET (use [low, high] or {\"mean\": [low, high]})"]
	var lo: Variant = bounds[0]
	var hi: Variant = bounds[1]
	var text := ""
	if lo != null and hi != null:
		text = "%s..%s" % [_num(lo), _num(hi)]
	elif lo != null:
		text = ">=%s" % _num(lo)
	elif hi != null:
		text = "<=%s" % _num(hi)
	else:
		text = "any"
	if on_mean:
		text = "mean " + text
	var low_value: float = s["mean"] if on_mean else s["lo"]
	var high_value: float = s["mean"] if on_mean else s["hi"]
	if lo != null and low_value < float(lo):
		return [text, "OFF low (%s)" % _num(low_value)]
	if hi != null and high_value > float(hi):
		return [text, "OFF high (%s)" % _num(high_value)]
	return [text, "ok"]


# --- mode: trace -------------------------------------------------------------

func _run_trace(args: Dictionary, params: Dictionary) -> int:
	var seed_value: int = _parse_seeds(str(args.get("seed", args.get("seeds", "1"))))[0]
	var ticks := int(args.get("ticks", "200"))
	var every := int(args.get("every", "0"))
	if every <= 0:
		every = maxi(1, int(ceil(ticks / 10.0)))
	var show: PackedStringArray = str(args.get("show", "")).split(",", false)
	# lambdas capture by value, so shared state lives in this dictionary
	var window := {"from": 1, "counts": {}, "order": [], "has_events": false, "flushed": 0}
	var lines: Array[String] = []   # one line per window (stdout + file)
	var full: Array[String] = []    # one line per tick with events (file only)

	var flush := func(t: int, row: Dictionary) -> void:
		var parts: Array[String] = []
		for e in window["order"]:
			var n: int = window["counts"][e]
			parts.append(e if n == 1 else "%s x%d" % [e, n])
		lines.append("t %5d-%-5d %s | %s" % [window["from"], t, ", ".join(PackedStringArray(parts)) if not parts.is_empty() else "-", _snapshot(row, show)])
		window["from"] = t + 1
		window["counts"] = {}
		window["order"] = []
		window["flushed"] = t

	var on_tick := func(t: int, row: Dictionary, hook: Object) -> void:
		if hook.has_method("events"):
			window["has_events"] = true
			var evs: Array = hook.events()
			if not evs.is_empty():
				full.append("- t=%d: %s" % [t, ", ".join(PackedStringArray(evs))])
			for e in evs:
				var key := str(e)
				if not window["counts"].has(key):
					window["counts"][key] = 0
					window["order"].append(key)
				window["counts"][key] += 1
		if t % every == 0:
			flush.call(t, row)

	var broken_before := _violations
	var final_row := _play(seed_value, ticks, params, on_tick)
	var ran: int = final_row["ticks_run"]
	if int(window["flushed"]) != ran:
		flush.call(ran, final_row)

	print("TRACE seed=%d, %d of %d ticks, one line per %d ticks: events | state at the end of the window" % [seed_value, ran, ticks, every])
	for line in lines:
		print(line)
	var ending := "ran all %d ticks" % ticks
	if _violations > broken_before:
		ending = "STOPPED at tick %d: invariant broken (see INVARIANT line above)" % ran
	elif ran < ticks:
		ending = "finished early at tick %d (is_finished)" % ran
	print("END %s" % ending)
	if not window["has_events"]:
		print("NOTE the hook has no events() method: only state snapshots are shown. Add `func events() -> Array` to sim/harness_hook.gd.")

	var abs_dir := _out_dir(args.get("out", "reports/sim"))
	var md_path := abs_dir.path_join("trace_%s.md" % _stamp())
	var f := FileAccess.open(md_path, FileAccess.WRITE)
	if f != null:
		f.store_line("# Trace - seed %d, %d ticks%s" % [seed_value, ran, "" if params.is_empty() else ", params `%s`" % str(params)])
		f.store_line("")
		f.store_line("```")
		for line in lines:
			f.store_line(line)
		f.store_line("END %s" % ending)
		f.store_line("```")
		f.store_line("")
		f.store_line("## Every event")
		for line in full:
			f.store_line(line)
		f.close()
	print("TRACE FILE %s" % md_path)
	return 1 if _violations > 0 else 0


func _snapshot(row: Dictionary, show: PackedStringArray) -> String:
	var parts: Array[String] = []
	for k in row:
		var key := str(k)
		if HIDDEN_METRICS.has(key) or (not show.is_empty() and not show.has(key)):
			continue
		var v: Variant = row[k]
		parts.append("%s=%s" % [key, _num(v) if (typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT) else str(v)])
	return " ".join(PackedStringArray(parts))


# --- helpers -----------------------------------------------------------------

## min / mean / max of one metric over the final rows. n = 0 if it is missing.
func _stats(finals: Array[Dictionary], key: Variant) -> Dictionary:
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
	return {"n": n, "lo": lo, "hi": hi, "mean": total / maxf(1.0, float(n))}


func _ended_early(finals: Array[Dictionary], ticks: int) -> String:
	var short: Array[String] = []
	for f in finals:
		if int(f["ticks_run"]) < ticks:
			short.append("%d@%d" % [f["seed"], f["ticks_run"]])
	return ", ".join(PackedStringArray(short))


## Compact number: 12, 0.35, 1313.5
func _num(v: Variant) -> String:
	var x := float(v)
	if x == floorf(x) and absf(x) < 1e15:
		return str(int(x))
	return ("%.2f" % x).rstrip("0").rstrip(".")


func _out_dir(out_dir: String) -> String:
	var abs_dir := ProjectSettings.globalize_path("res://" + out_dir) if not out_dir.is_absolute_path() else out_dir
	DirAccess.make_dir_recursive_absolute(abs_dir)
	return abs_dir


func _stamp() -> String:
	return Time.get_datetime_string_from_system().replace(":", "").replace("-", "").replace("T", "_")


func _parse_seeds(spec: String) -> Array[int]:
	var out: Array[int] = []
	for part in spec.split(",", false):
		if part.contains("-"):
			var ab := part.split("-")
			for s in range(int(ab[0]), int(ab[1]) + 1):
				out.append(s)
		else:
			out.append(int(part))
	if out.is_empty():
		out.append(1)
	return out


func _to_value(s: String) -> Variant:
	if s.is_valid_int():
		return int(s)
	if s.is_valid_float():
		return float(s)
	if s == "true" or s == "false":
		return s == "true"
	return s


## JSON has only floats: turn whole numbers back into int (12.0 -> 12).
func _json_value(v: Variant) -> Variant:
	if typeof(v) == TYPE_FLOAT and v == floorf(v) and absf(v) < 1e15:
		return int(v)
	return v


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
