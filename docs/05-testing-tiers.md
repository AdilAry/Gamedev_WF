# 05 - The harness in depth: testing tiers for games

> "You do not just need a better model - you need a harness."
> - the embedded video, and just as true for games.

The harness is four small Godot scripts and one shell script, copied into
each project's `harness/` folder:

| File | What it does |
|---|---|
| `harness/gw.sh` | single entry point for every loop; logs to `reports/logs/`, fails on any `SCRIPT ERROR` even if Godot exits 0, time-limits every run, installs the commit gate |
| `harness/test_runner.gd` | dependency-free test runner (no addon needed), tiers = folders, terse output, per-test timeout |
| `harness/gw_test.gd` | base class with assertions, `expect_error()` and scene helpers |
| `harness/gw_error_capture.gd` | catches script errors and `push_error()` while a test runs, so the runner can fail *that* test |
| `harness/sim_runner.gd` | runs the simulation headless: many seeds/ticks (CSV, summary, digest, cost per tick), named **balance cases** against targets, or one run as a **trace** |

It works on Linux, in Git Bash on Windows, and in GitHub Actions. It is
**verified in this repo's CI** against Godot 4.7.2 (see
`.github/workflows/example-ci.yml`), including canary tests that prove a
failing assertion, a runtime script error, a test that waits forever and an
endless loop are all reported as failures, that the commit gate blocks a red
commit, and that two identical sim runs give the same digest.

## What counts as a failure (so the agent can't fool itself)

| Situation | What happens |
|---|---|
| an assertion fails | the test is `FAIL` with the message; the other assertions still run |
| a script error (null access, wrong type...) inside a test | the test is `FAIL` with the error and its file:line (Godot 4.5+). Without this, GDScript just aborts the function and the test would look green |
| `push_error()` in the code under test | `FAIL`, unless the test announced it with `expect_error("fragment")` |
| a test waits for a signal that never comes | `FAIL ... timed out` after 60 s (`GW_TEST_TIMEOUT`), the run continues |
| an endless loop, or Godot hangs | `gw.sh` stops Godot after 900 s (`GW_TIMEOUT`) -> FAIL |
| Godot crashes | no `RESULT` line -> `gw.sh` reports FAIL |
| a parse error anywhere | `gw.sh` finds it in the log -> FAIL |
| a new `class_name` script that Godot has not indexed yet | not a failure any more: `gw.sh` re-imports by itself when the list of classes changed |

The time limits matter most on the agent box: a hung test at 23:00 should
not keep an unattended session (and your Pro usage) waiting until morning.

## The tiers

Order matters: fast feedback first, so the agent doesn't burn time (and your
Pro budget) on slow checks when a fast one already fails. `gw.sh test all`
(and therefore `check`) is **fail-fast**: if the unit tier is red, sim and scene
are skipped and the summary says so. Their failures would mostly be echoes of
the same bug. `GW_ALL_TIERS=1` runs everything anyway.

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

The summary ends with a few lines worth knowing:
- `... ms/tick` in the first line: how much one simulated tick costs. Your
  early warning for level 10 (when GDScript becomes too slow).
- `SAME ON EVERY SEED: population, wood, ...`: these metrics came out
  identical on all seeds, so running more seeds tells you nothing about them.
  The example colony shows this: its bot is fully deterministic and the only
  randomness (good harvests) barely matters. Real strategy games need
  variety (maps, events, bot choices) before "30 seeds" means anything.
- `DIGEST 3f9a...`: a fingerprint of all final metrics. Same command + same
  code = same digest. Comparing one line is the cheapest determinism test.

### Balance cases: the situations you care about, side by side
`tests/cases/balance.json` is **your** file. Each case is a named situation
(who plays, which rules are changed, how long) and, if you have one, a target:

```json
{ "name": "idle", "note": "BAL-002: doing nothing must be punished",
  "ticks": 200, "params": { "bot": "idle" }, "expect": { "population": [null, 5] } }
```

```bash
./harness/gw.sh cases
```

```
case               metric                  min       mean        max  target           verdict
greedy-300         population               35         35         35  >=20             ok
greedy-500         wood                   9772       9772       9772  <=500            OFF high (9772)
idle               population                4        4.1          5  <=5              ok
monkey             population               10       24.7         56  -
OFF TARGET: greedy-500/wood
CASES 5 cases, 3 targets: 2 ok, 1 off, in 355 ms
MD .../reports/cases/cases_20261111_064234.md
```

- `"expect": {"metric": [low, high]}` must hold on **every** seed; `null`
  means no bound. `{"mean": [0.4, 0.6]}` checks the average instead, which is
  what you want for win rates (let the hook report `win` as 1 or 0).
- A case without `expect` is a what-if: something you only want to look at.
- `--only=name` runs some cases; `--param.key=value` applies one change to
  **all** cases, which shows what else a tweak moves; `--strict` makes an
  off-target a failure (for CI, once your targets are settled).
- The `MD` file is the same table as Markdown, for your notes or a QA report.
- `params` go to `sim/harness_hook.gd::setup()`. By convention `bot` picks
  the player (`greedy`, `idle`, `random`, later your own strategies); the
  rest are rule overrides. Whole numbers arrive as `int`.

The difference to sim-tier tests: a test is a gate (red blocks the commit); the
cases are a **showcase**. An open balance problem stays visible as `OFF`
without blocking work on something else.

### Trace: read one run
Numbers say where a run ended; a trace says how it got there.

```bash
./harness/gw.sh trace --seed=3 --ticks=120
```

```
TRACE seed=3, 120 of 120 ticks, one line per 12 ticks: events | state at the end of the window
t     1-12    build farm, birth | population=7 food=52 wood=46 farms=2 mills=1 houses=2 housing=10
t    13-24    birth, build farm | population=8 food=76 wood=72 farms=3 mills=1 houses=2 housing=10
...
END ran all 120 ticks
```

Options: `--every=N` (window size), `--show=population,food` (fewer columns),
and the same `--param.key=value` as everywhere. Events come from the hook's
optional `events()` method (bot decisions plus what the rules did). The file
it names also lists every single event. Use it to replay a bug ("seed 17,
tick 412") or to see why a case is off.

### Fuzzing: the random bot
A bot that presses random buttons, including ones that should be refused,
reaches states no sensible player would. The example has one
(`sim/ai/random_bot.gd`, `--param.bot=random`, test SYS-004). It finds the
"negative wood after two builds in one tick" class of bug, and it is the
cheapest test you will ever write. `/qa` runs it over hundreds of seeds.

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
| "a normal game reaches Y by time Z" | sim (balance target), and a case in `tests/cases/balance.json` |
| "strategy A does not always beat B" | a case with `{"mean": [0.4, 0.6]}` on `win` |
| "no input can break the rules" | sim (random bot + invariants) |
| "AI opponent doesn't get stuck" | sim (bot vs bot, ticks without progress) |
| a button / hotkey / signal does the right thing | scene |
| the game boots and runs without errors | smoke |
| it's readable / not visually broken | visual |
| it's fun, the pacing feels right | playtest |

## The commit gate (pre-commit hook)
`./harness/gw.sh hooks` installs a git pre-commit hook that runs
`gw.sh check` before every commit that touches code, data or tests.
Commits that only change documents (`docs/`, `design/`, `ideas/`, `*.md`)
skip it, so a `/wrap` or your own design commit stays quick. This turns "run check before committing" from an
instruction the agent may forget into a rule it can't skip by accident.

- Git doesn't copy hooks when you clone, so run `./harness/gw.sh hooks` once
  per clone (Legion and Mint). `/harness` and `/commission` do it for you.
- You, the human, can bypass it with `git commit --no-verify` (e.g. to save
  a half-done experiment). The agent is told never to, and the safe
  permissions template denies it.

## The CI mirror
`harness/ci/godot-ci.yml` runs `gw.sh check` plus a balance snapshot on every
push, on GitHub's machines. If the agent on the Mint box (or you) pushes
something broken, the Actions tab turns red even if nobody ran the tests.
Free for public repos; private repos get a monthly allowance of minutes that
headless tests barely touch.

## Updating the harness in your games
Each game has its own copy of `harness/` so it works anywhere (CI, other
laptop) without the kit. When the kit improves (`git -C ~/Gamedev_WF pull`):

```bash
~/Gamedev_WF/scripts/update-harness.sh ~/games/my-game
```

Then `./harness/gw.sh check` in the game and commit. `./harness/gw.sh version`
shows which harness a game has; [CHANGELOG.md](../CHANGELOG.md) says what changed.

## Writing tests the agent can't cheat
- Tests cite requirement IDs; requirements come from your design, and the
  expected values come from the worked examples in the spec. You see the
  planned tests before they are written (Gate 1 of `/start`).
- The game's `AGENTS.md` forbids weakening tests; changes to expectations
  go through `/change-request`, and `/judge` looks for both.
- Skim the diff of `tests/` in each commit (`git log -p -- tests/`). If an
  expected number changed, there should be a CR or a balance note explaining why.
