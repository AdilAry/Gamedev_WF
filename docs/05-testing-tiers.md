# 05 - The harness in depth: testing tiers for games

> "You do not just need a better model - you need a harness."
> - the embedded video, and just as true for games.

The harness is three small Godot scripts and one shell script, copied into
each project's `harness/` folder:

| File | What it does |
|---|---|
| `harness/gw.sh` | single entry point for every loop; logs to `reports/logs/`, fails on any `SCRIPT ERROR` even if Godot exits 0 |
| `harness/test_runner.gd` | dependency-free test runner (no addon needed), tiers = folders, terse output |
| `harness/gw_test.gd` | base class with assertions and scene helpers |
| `harness/sim_runner.gd` | runs the simulation headless for many seeds/ticks, writes CSV, prints a summary |

It works on Linux, in Git Bash on Windows, and in GitHub Actions. It is
**verified in this repo's CI** against Godot 4.7.2 (see
`.github/workflows/example-ci.yml`), including canary tests that prove a
failing assertion and a runtime script error are both reported as failures.

## The tiers

Order matters: fast feedback first, so the agent doesn't burn time (and your
Pro budget) on slow checks when a fast one already fails.

### 1. unit - the rules (like host tests)
Pure simulation code, no scene tree. Milliseconds. Proves formulas, edge cases
and rules: "an unstaffed farm produces nothing", "costs are paid up front".

```gdscript
extends "res://harness/gw_test.gd"

func test_unstaffed_farm_produces_nothing() -> void:
	# ECO-003
	var sim := ColonySim.new(ColonyRules.load_default(), 1)
	sim.state.population = 1
	sim.state.buildings = {"farm": 1}
	assert_eq(sim.staffing()["farm"], 0)
```

### 2. sim - the bench (bots, seeds, fault injection)
Strategy/sim games are ideal for this tier: a simple bot plays hundreds of
ticks over many seeds. Three kinds of checks:
- **Invariants** - must never happen, whatever the input: negative resources,
  NaN, units off the map, more population than housing, a dead player still
  acting. Implement them once in `sim/harness_hook.gd::check_invariants()`; the
  sim runner and the tests both use them.
- **Balance targets** - numbers from the GDD (`BAL-*`): "the bot reaches 20
  population by tick 300 on every seed", "doing nothing loses".
- **Fault injection** (the video's negative tests) - absurd rules and states on
  purpose: zero costs, 5x consumption, every random event every tick, empty
  map, all AIs dead, a save from an older version. The game must stay
  consistent, even if it is no longer fun.

And outside the test suite, the **sim runner** for exploration:

```bash
./harness/gw.sh sim --seeds=1-30 --ticks=800 --param.growth_ticks=12
```

```
SIM 30 seeds x up to 800 ticks in 412 ms
final metric                  min       mean        max
population                  41.00      43.20      46.00
wood                      2210.00    2390.10    2604.00
...
CSV /home/agent/games/colony/reports/sim/sim_20261104_201502.csv
```

Determinism (same seed + same commands = same result) is what makes this
tier trustworthy, and it makes bugs reproducible: "seed 17, tick 412" is a
complete bug report.

### 3. scene - the real thing, headless (like target tests)
Real scenes in a real SceneTree, without a window. Proves the UI is wired
to the simulation: buttons exist, signals connect, timers tick.

```gdscript
func test_build_button_builds() -> void:
	var main = add_scene("res://scenes/main.tscn")
	await wait_frames(1)
	main.sim.state.resources["wood"] = 100
	var button: Button = main.find_child("Build_farm", true, false)
	button.pressed.emit()
	assert_eq(main.sim.state.count("farm"), 2)
```

Plus the **smoke** run: `gw.sh smoke` boots the main scene for 300 frames and
fails on any runtime error. It's cheap and catches a surprising amount.

### 4. visual - the agent's eyes
`gw.sh shot [scene] [frames]` uses Godot's Movie Maker mode to render real
frames to PNG (on the Mint box through `xvfb`, so no monitor is needed). It
keeps three frames (start, middle, end). Claude can open PNGs and judge them
against `docs/STYLE_GUIDE.md`: overlapping labels, unreadable text, wrong
colours, empty screens. Use it sparingly; images are expensive in tokens.

### 5. playtest - the field
You. Only you can say whether it's fun or clear. `/playtest` makes sure each of
your observations ends up as a test, an experiment or a change request.

## Where does a check belong? (fastest tier that can prove it)

| You want to prove... | Tier |
|---|---|
| a formula, a rule, a state transition | unit |
| "over a whole game, X never happens" | sim (invariant) |
| "a normal game reaches Y by time Z" | sim (balance target) |
| "AI opponent doesn't get stuck" | sim (bot vs bot, ticks without progress) |
| a button / hotkey / signal does the right thing | scene |
| the game boots and runs without errors | smoke |
| it's readable / not visually broken | visual |
| it's fun, the pacing feels right | playtest |

## The CI mirror
`harness/ci/godot-ci.yml` runs `gw.sh check` plus a balance snapshot on every
push, on GitHub's machines. If the agent on the Mint box (or you) pushes
something broken, the Actions tab turns red even if nobody ran the tests.
Free for public repos; private repos get a monthly allowance of minutes that
headless tests barely touch.

## Writing tests the agent can't cheat
- Tests cite requirement IDs; requirements come from you.
- `CLAUDE.md` and `/build` forbid weakening tests; changes to expectations
  go through `/change-request`.
- Skim the diff of `tests/` in each commit (`git log -p -- tests/`). If an
  expected number changed, there should be a CR or a balance note explaining why.
