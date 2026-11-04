extends RefCounted
## Base class for Gamedev-WF harness tests.
##
## Usage in a test file (file name must start with "test_"):
##
##     extends "res://harness/gw_test.gd"
##
##     func test_farm_produces_food() -> void:
##         assert_eq(2 + 2, 4, "math still works")
##
## Every method whose name starts with "test_" is run on a FRESH instance.
## Optional hooks: before_each() and after_each(). Any of them may use await.
## Assertions never stop the test; all failures are collected and reported.
## A script error or push_error() during the test fails it (Godot 4.5+),
## unless the test announced it with expect_error().

## The running SceneTree. Use it for scene-tier tests (tree.root, frames).
var tree: SceneTree

var _failures: Array[String] = []
var _spawned: Array[Node] = []
var _expected_errors: Array[String] = []


# --- assertions ------------------------------------------------------------

func fail(msg: String) -> void:
	_failures.append(msg)


func assert_true(cond: bool, msg: String = "") -> void:
	if not cond:
		_fail("expected true, got false", msg)


func assert_false(cond: bool, msg: String = "") -> void:
	if cond:
		_fail("expected false, got true", msg)


func assert_eq(actual: Variant, expected: Variant, msg: String = "") -> void:
	if not _same(actual, expected):
		_fail("expected <%s>, got <%s>" % [str(expected), str(actual)], msg)


func assert_ne(actual: Variant, unexpected: Variant, msg: String = "") -> void:
	if _same(actual, unexpected):
		_fail("expected anything but <%s>" % str(unexpected), msg)


func assert_near(actual: float, expected: float, epsilon: float = 0.0001, msg: String = "") -> void:
	if absf(actual - expected) > epsilon:
		_fail("expected %s +/- %s, got %s" % [expected, epsilon, actual], msg)


func assert_between(actual: float, low: float, high: float, msg: String = "") -> void:
	if actual < low or actual > high:
		_fail("expected value in [%s, %s], got %s" % [low, high, actual], msg)


func assert_has(container: Variant, item: Variant, msg: String = "") -> void:
	var found := false
	if container is Array or container is Dictionary:
		found = container.has(item)
	elif container is String and item is String:
		found = container.contains(item)
	if not found:
		_fail("expected <%s> to contain <%s>" % [str(container), str(item)], msg)


func assert_not_null(value: Variant, msg: String = "") -> void:
	if value == null:
		_fail("expected a value, got null", msg)


func assert_null(value: Variant, msg: String = "") -> void:
	if value != null:
		_fail("expected null, got <%s>" % str(value), msg)


## Announce that this test deliberately triggers an error (e.g. a loader given
## a broken file calls push_error). Every error whose text contains `fragment`
## (case-insensitive) is then allowed, and at least one must happen.
## Errors that match no announced fragment still fail the test.
func expect_error(fragment: String) -> void:
	_expected_errors.append(fragment)


# --- scene-tier helpers ----------------------------------------------------

## Instantiate a scene, add it to the running tree, free it after the test.
func add_scene(path: String) -> Node:
	var packed: PackedScene = load(path)
	if packed == null:
		fail("could not load scene " + path)
		return null
	var node := packed.instantiate()
	tree.root.add_child(node)
	_spawned.append(node)
	return node


## Let the engine run n frames (_ready, _process, timers, signals...).
func wait_frames(n: int = 1) -> void:
	for i in n:
		await tree.process_frame


## Let the engine run for roughly `seconds` of game time.
func wait_seconds(seconds: float) -> void:
	await tree.create_timer(seconds).timeout


# --- internals (used by test_runner.gd) -----------------------------------

func _fail(text: String, msg: String) -> void:
	if msg == "":
		_failures.append(text)
	else:
		_failures.append(msg + " -- " + text)


func _same(a: Variant, b: Variant) -> bool:
	var num := [TYPE_INT, TYPE_FLOAT]
	if typeof(a) in num and typeof(b) in num:
		return a == b
	if typeof(a) != typeof(b):
		return false
	return a == b


## Called by the runner with the errors captured during this test.
## Returns failure lines (empty = fine).
func _check_errors(errors: Array[String]) -> Array[String]:
	var out: Array[String] = []
	var seen := {}
	for e in errors:
		var allowed := false
		for frag in _expected_errors:
			if e.findn(frag) != -1:
				allowed = true
				seen[frag] = true
		if not allowed:
			out.append(e)
	for frag in _expected_errors:
		if not seen.has(frag):
			out.append("expected an error containing <%s>, none happened" % frag)
	return out


func _cleanup() -> void:
	for node in _spawned:
		if is_instance_valid(node):
			node.queue_free()
	_spawned.clear()
