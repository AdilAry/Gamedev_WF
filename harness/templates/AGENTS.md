# AGENTS.md: [game title]

Loaded in every session, by every agent (`CLAUDE.md` is the one-line import). Keep it under ~120 lines once filled in: only facts that hold for the whole game. Detail lives in docs/, behind "Read only when needed".

## Project
- **What:** [one line: genre and what the player does].
- **For:** [me | the players it is meant for].
- **Simulation:** [yes: sim/harness_hook.gd, bots in sim/ai/, tests/sim, balance cases | no: unit and scene tiers only].
- **Second machine:** [no role in this project | the agent box: headless tests, simulation runs and screenshots].

## Scope
- **First playable:** [3-5 bullets].
- **Not doing:** [e.g. multiplayer, save/load, menus, sound].
- **Constraints:** [Windows + Linux desktop, mouse + keyboard; must run on integrated graphics].

## Stack
- **Language and tools:** Godot [4.7] + GDScript 2.0, Compatibility renderer. `harness/gw.sh` is the test and simulation harness, copied from the Gamedev-WF kit.
- **Run:** `[godot --path .]`
- **Check:** `./harness/gw.sh check`. Run it before calling anything done.
- **Done gate:** the tests the plan names pass (`./harness/gw.sh test <tier> <filter>`), then Check passes. For a task that is not a requirement: Check passes, and a named test covers the change.
- **Run limit:** [20] harness runs in one session (every `gw.sh` call that starts Godot), passed or failed. Then stop and report.
- **Push:** [in /wrap | only after I've checked the result].

## Who decides what
- `design/` holds my design documents. Read them; never edit them.
- `docs/spec/<system>.md` restates my design as requirements with IDs and worked examples. It adds nothing that is not in `design/` or in an answered question.
- A gap or contradiction in the design is a row in `docs/QUESTIONS.md` with options and your recommendation, never a guess. A requirement marked "blocked by" a question cannot be started: show me the question and offer the next unblocked task.
- The numbers in `data/` and the targets in `tests/cases/balance.json` (if the game has a simulation) are design. Propose changes with evidence (`./harness/gw.sh cases`, or a playtest); change them after I pick.
- `harness/` belongs to the kit. Never edit it here.

## The plan
- The plan lives in `docs/spec/<system>.md` (what each requirement says) and `docs/TESTPLAN.md` (its test and status). A task is 1-3 requirement IDs of one system, or free text for anything else.
- In the /start plan, list each test as input -> expected result, taken from the spec's worked examples. A value the spec does not give is a question for me, not a number you choose.
- UI, visual and playtest requirements always have a part only I can check. Say what to look at and what I should see; they stay "awaiting my check" until I confirm.
- **At /start also:** a check I confirmed sets that task's rows in `docs/TESTPLAN.md` to `green`.
- **At /wrap also:** a finished task's rows in `docs/TESTPLAN.md` are set to `green`, and every status there matches reality; every question raised this session is filed in `docs/QUESTIONS.md`, and the ones blocking "Next" are named under "Waiting on me".
- **Judged on** (for /judge): every `green` requirement has a test that really proves it; no test was weakened and no expected value changed without a change request (`git log -p -- tests/`); the architecture rules below hold; nothing in code or data that is in neither `design/`, the spec nor an answered question; PROGRESS.md and the statuses match the code.

## Engine facts
- Never Godot 3 syntax: use `@export`, `@onready`, `instantiate()`, `signal.connect(callable)`, `await`, typed arrays, `super()`.
- The exact API of the installed version is in `docs/ref/godot-api/` (`./harness/gw.sh doc` creates it). Grep it instead of guessing method names.
- Type everything (`var farm: Building`, typed parameters and return types, `Array[Unit]`): mismatches are then rejected when the script loads. A call to a method that does not exist only fails when that line runs, so every branch you write needs a test that reaches it.
- JSON numbers load as floats: convert once, in the loader.
- Build UI in code or small scenes. Do not hand-write large `.tscn` files.

## Architecture rules
1. `sim/` holds the game rules: pure `RefCounted` classes with `class_name`, no Nodes, no autoload state, no rendering. All randomness comes from a seeded `RandomNumberGenerator` owned by the simulation, so the same seed and commands give the same result.
2. `data/` holds every tunable number (JSON). Balancing never needs a code change.
3. `scenes/` and `ui/` are presentation: they send commands to the sim and show its state. No rules there.
4. If the game has a simulation: `sim/harness_hook.gd` connects it to the harness (`setup/step/metrics/is_finished`, `check_invariants`, `events`, the `bot` parameter). Keep it working.
5. One class per file, files under ~300 lines, functions under ~50.

## Working rules
- Tests first, in the fastest tier that can prove the requirement: `tests/unit` (a rule or formula), `tests/sim` (if the game has a simulation: many ticks, seeds, bots), `tests/scene` (real nodes and input). Each test cites its requirement ID.
- While iterating, run filtered tests (`./harness/gw.sh test unit <filter>`); slower tiers only when the faster ones are green.
- A change of behaviour goes through `/change-request`.
- A script error or `push_error()` fails the running test. A test that provokes one on purpose declares it with `expect_error("fragment")`.
- Never bypass the commit gate (`git commit --no-verify`). Commit messages name the requirement IDs.
- No addons, Godot version changes or project settings changes without asking.
- Every generated or downloaded asset gets a row in `assets/ASSETS.md`.
- `/qa` tests the game headless (with bots, if it has a simulation) and reports; it fixes nothing.

## Read only when needed
| File | Read when |
|---|---|
| `docs/spec/<system>.md` | starting a task: the rows and worked examples of its requirement IDs only |
| `docs/TESTPLAN.md` | starting a task: its rows; choosing the next task |
| `docs/QUESTIONS.md` | a requirement is blocked, or a gap in the design shows up |
| `design/` | writing or checking a spec (`/spec`); a spec row looks wrong |
| `docs/GDD.md` | I ask about scope, systems or build order |
| `docs/decisions.md` | a decision is questioned or about to change |
| `docs/history.md` | I ask what happened earlier, or a judge pass compares results |
| `docs/STYLE_GUIDE.md` | art or UI work |
| `docs/notes/` | the task needs a source summarised there |

## Files
```
project.godot      the Godot project
design/            my design documents (read-only for agents)
data/              every tunable number
sim/               rules, state; with a simulation also bots (sim/ai/) and harness_hook.gd
scenes/ ui/        presentation
tests/             unit/ scene/; with a simulation also sim/ and cases/balance.json
harness/           gw.sh and the runners, from the kit
docs/              GDD, spec/, QUESTIONS, TESTPLAN, history, decisions, changes/, playtests/
reports/ out/      harness output and long output (gitignored)
```
