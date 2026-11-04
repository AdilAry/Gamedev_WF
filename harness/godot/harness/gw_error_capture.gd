extends Logger
## Collects engine and script errors while a test runs, so test_runner.gd can
## fail the test that caused them (Godot 4.5+, where the Logger class exists).
##
## Without this, a GDScript runtime error inside a test only aborts that test
## function: the runner would still count it as PASSED. gw.sh greps the log as
## a second safety net, but this tells you WHICH test broke and where.
##
## Loggers can be called from any thread and must not print (that would
## recurse), so this class only stores strings behind a mutex.

var _mutex := Mutex.new()
var _active := false
var _errors: Array[String] = []


## Start collecting (clears anything collected before).
func begin() -> void:
	_mutex.lock()
	_errors.clear()
	_active = true
	_mutex.unlock()


## Stop collecting and return what was collected since begin().
func end() -> Array[String]:
	_mutex.lock()
	_active = false
	var out: Array[String] = _errors.duplicate()
	_errors.clear()
	_mutex.unlock()
	return out


func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
	if error_type == ERROR_TYPE_WARNING:
		return
	var kind := "SCRIPT ERROR" if error_type == ERROR_TYPE_SCRIPT else "ERROR"
	var text := rationale if rationale != "" else code
	var where := "%s:%d" % [file, line] if file != "" else function
	_mutex.lock()
	if _active and _errors.size() < 20:
		_errors.append("%s: %s (%s)" % [kind, text, where])
	_mutex.unlock()


func _log_message(_message: String, _error: bool) -> void:
	pass
