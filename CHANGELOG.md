# Changelog

What changed in the kit, and what to do in games that already use it.
Harness version = `HARNESS_VERSION` in `harness/godot/harness/gw.sh`
(`./harness/gw.sh version` in a game shows its copy).

## Kit 1.6.2 / Harness 1.2.3 - 2026-11-22

Docs only. The workflow (v2.9) dropped "wrap at about 40% context": the stop
rules in `/start` are the real cutoff, and WORKFLOW.md §4 ("Watch the
context") holds a token backstop. The kit restated the old rule; it now
points to §4 instead. The contract date stays 21 November 2026: the
workflow's list is now dated 22 November because competition material moved
to the Pitch_WF kit, which this kit never used (WORKFLOW.md §9 says so too).

**On every machine:** pull the kit (`git -C ~/Gamedev_WF pull` on Linux).

**In an existing game:** nothing.

Changes:
- `docs/04-claude-pro-playbook.md` tip 7: keep `/context`, the 40% sentence
  became a pointer to WORKFLOW.md §4.
- `docs/09-loops.md`, first "honest limit": the stop rules end a session that
  goes wrong, §4 holds the context backstop.

## Kit 1.6.1 / Harness 1.2.3 - 2026-11-21

Written against the short-loop workflow's contract of 21 November 2026. That
contract adds "At /judge also" fields (this kit uses none), and `/judge` now
starts from PROGRESS.md "How to run": the setup its `Needs:` line names is
expected, every other step is an issue. `/harness` now fills all of
PROGRESS.md, that line included, and leaves no bracket.

**On every machine:** pull the workflow, then the kit. Linux:
`git -C ~/Workflow pull` and `git -C ~/Gamedev_WF pull` (the commands are
links). Windows: after the pulls, re-run the workflow's §3 copy line and
`scripts/install.ps1`.

**In an existing game:** add the `Needs:` line at the top of "How to run" in
PROGRESS.md by hand, for example:
`Needs: Godot 4.7.x as godot or $GODOT (on Windows the *_console.exe build), then ./harness/gw.sh hooks once per clone.`
Without it, every `/judge` pass lists installing Godot as an issue.

## Kit 1.6.0 / Harness 1.2.3 - 2026-11-20

A game without a simulation no longer gets sim scaffolding. `/harness`
reads GDD section 5 (or asks) whether the game has one, and only then
creates the sim hook, bots, `tests/sim/` and balance cases. `/commission`
marks the sim checks N/A without a hook, and `/define` stops pushing designs
toward ticks and turns. A game with a simulation is set up exactly as
before.

**On every machine:** nothing.

**In an existing game:** nothing required.
- Harness 1.2.3 changes one comment (`sim_runner.gd` line 2), so updating
  (`scripts/update-harness.sh <game folder>` from the kit) is optional.
- You can add the new line under Project in its AGENTS.md:
  `- **Simulation:** yes` (or `no`). Without it, `/commission` notes the
  missing line but does not fail.
- If the game never used its sim parts, you may delete
  `sim/harness_hook.gd`, `sim/ai/`, `tests/sim/` and
  `tests/cases/balance.json`, then run `./harness/gw.sh check`.
- To skip the CI balance snapshot in a game without a hook, copy the new
  `run:` lines of the "Balance snapshot" step from the kit's
  `harness/ci/godot-ci.yml` into the game's copy.

Changes:
- `/harness`: decides "simulation or not" in its preconditions, and marks
  the hook, `sim/ai/`, `tests/sim/` and the cases file as simulation only.
- `/commission`: steps 8-9 are N/A without a hook; step 13 checks that the
  AGENTS.md Simulation line matches the hook file.
- `/define`: question 2 asks whether the game has a simulation. SYS-001
  (determinism) and BAL- targets only with one. SYS-002 (invariants) has
  genre-neutral examples. Phase 1 is the smallest slice that tests the core
  mechanic.
- Templates: AGENTS.md has a Simulation line; GDD section 5 is "Time model
  and simulation". The example's AGENTS.md has the line too.
- Game CI template: the balance snapshot runs only when
  `sim/harness_hook.gd` exists, like the cases step.
- Harness: the `sim_runner.gd` header comment is genre-neutral.

## Kit 1.5.3 / Harness 1.2.2 - 2026-11-20

Wording only: the kit now reads as being for any Godot game. Strategy and
sim games still fit best, and the parts made for them (the sim tier and
runner, bots, balance cases, `/balance`, the genre advice) are labelled as
optional. No existing step changed; `/balance` and `/qa` gain a branch for
games without a simulation.

**On every machine:** nothing.

**In an existing game:** nothing. If you want the new template wording in
its AGENTS.md, change these lines by hand (from `harness/templates/AGENTS.md`
in the kit): the `tests/cases/balance.json` line under "Who decides what",
architecture rule 4, the `tests/sim` part of the first working rule, the
`/qa` line under "Workflow", and the `sim/` and `tests/` lines under "Files".
A game with a simulation can keep its AGENTS.md as it is.

- README and GUIDE: a genre-neutral title and intro, the honest limit (feel
  can't be tested headless), and a list of what every game uses and what is
  optional.
- docs/05, 06, 07, 08, 09: the sim tier, balance cases, trace, fuzzing and
  the time models are labelled strategy/sim. New: what to test in a game
  that is mostly feel.
- Commands: `/balance` and the bot parts of `/qa` say what to do in a game
  without a simulation; `/playtest` routes balance notes to a data change
  when there is none; `/pitch`, `/style-guide`, `/asset` and one `/define`
  example label their strategy/sim specifics.
- Templates: AGENTS.md, GDD, SPEC, TESTPLAN, PLAYTEST, QA_REPORT,
  STYLE_GUIDE and cases.json label the sim-only parts and the strategy
  examples.

## Kit 1.5.2 / Harness 1.2.2 - 2026-11-20

Godot no longer imports the harness output in `reports/`. It read the
simulation CSVs as translation tables, and that import could crash Godot
("double free or corruption"), so a check could fail now and then although
nothing in the game was wrong.

**On every machine:** nothing.

**In an existing game:** update its harness (`scripts/update-harness.sh
<game folder>` from the kit). Until then, `touch reports/.gdignore` in the
game does the same. Then delete any `*.translation` and `*.csv.import` files
under `reports/`.

- `gw.sh` creates `reports/.gdignore` on every call, so Godot skips the
  whole folder. The runners write there with plain file access, so nothing
  else changes.
- `gw.sh doc` creates `docs/ref/.gdignore`, so Godot no longer scans the
  API reference's XML files on every import. In an existing game, run
  `./harness/gw.sh doc` once more after updating, or
  `touch docs/ref/.gdignore`.

## Kit 1.5.1 / Harness 1.2.1 - 2026-11-20

Claude Code is the agent; pi is for later (the workflow's WORKFLOW.md §6).
The safe allowlist now allows every git command the workflow runs (its
WORKFLOW.md §8, "Git commands the workflow runs").

**On every machine:** nothing.

**In an existing game:** add these two lines to the `allow` list in
`.claude/settings.json`, so `/start` and `/wrap` no longer wait on a prompt:
`"Bash(git pull:*)"` and `"Bash(git show:*)"`.

- `harness/templates/claude-settings.json`: allows `git pull` (`/start`) and
  `git show` (`/wrap`). The deny and ask rules are unchanged.
- README, GUIDE, docs/01-04, 08 and 10, the kit's AGENTS.md, `/harness` and
  `/commission` (check 13): Claude Code is the default; pi is marked "for
  later" and the reason is left to the workflow's §6. `docs/10-pi.md`, the
  guard extension, `package.json` and the installers' pi step are kept.
- GUIDE: "How this kit differs from the videos" has two rows now; the "one
  agent" row is no longer a difference.
- Example brought in line with `harness/templates/AGENTS.md` (At /start, At /wrap, Judged on); its GDD no longer points to the removed LOG and CLAUDE.md.

## Kit 1.5.0 / Harness 1.2.1 - 2026-11-19

The short-loop workflow is no longer bundled. It is its own repo, and the
kit is an add-on to it: it finds it through `WORKFLOW_DIR` and uses only the
list in the workflow's WORKFLOW.md §8 ("Building a kit on this workflow"),
contract of 20 November 2026. A new workflow version needs no kit release
unless that list changes.

**On every machine:**
1. Clone the workflow repo to a fixed folder and install it. Linux:
   `bash install.sh` in that folder. Windows: the PowerShell lines in its
   WORKFLOW.md §3. Both set `WORKFLOW_DIR`.
2. Open a new terminal, `git pull` the kit, and run `scripts/install.sh`
   again (Windows: `scripts\install.ps1`). Both stop with a message if
   `WORKFLOW_DIR` is not set. On Linux the commands now link into the
   workflow's folder, not into the kit's old `workflow/`.

**In a game set up with 1.4.0:** in AGENTS.md, replace the line "A finished
task is ticked by setting its rows to `green` in `docs/TESTPLAN.md`" with the
two hooks from `harness/templates/AGENTS.md` ("At /start also" and the new
start of "At /wrap also"). The workflow's `/wrap` now ticks only plans with
checkboxes, so without this the TESTPLAN rows would stay as they are. You may
also delete "Never weaken, skip or delete a test to make it pass": `/start`
has that rule now. Nothing else, unless you copied files from the kit's
`workflow/` folder by hand (take them from `$WORKFLOW_DIR` instead).

- `workflow/` removed. CI clones the workflow from `WORKFLOW_GIT_URL` (one
  line at the top of `example-ci.yml`) and tests the installer with it, and
  without it (must stop, change nothing).
- `scripts/install.sh` runs `"$WORKFLOW_DIR/install.sh"` with the kit's
  commands; `install.ps1` copies only the kit's commands (the workflow's §3
  installs its own). Neither saves `WORKFLOW_DIR`: the workflow does.
- `/harness` takes PROGRESS.md, history.md and decisions.md from
  `$WORKFLOW_DIR/templates/project/`. `/harness`, `/spec` and `/define` no
  longer guess where the kit is (`~/Gamedev_WF`, `/c/Users/...`): they use
  `$GAMEDEV_WF` and `$WORKFLOW_DIR`, and stop or ask when one is unset.
- `/commission` records the workflow version (check 1) and says to install
  the workflow first when `/start` is not offered (check 13).
- Game AGENTS.md template: TESTPLAN rows go `green` through "At /start also"
  and "At /wrap also"; the test-weakening rule is gone (it is in `/start`).
- README names the contract date and gives the install order for Linux and
  Windows; GUIDE, docs/02, 03, 05, 09, 10 and the kit's AGENTS.md point to the
  external workflow.

## Kit 1.4.0 / Harness 1.2.1 - 2026-11-14

Version 4 of the owner's short-loop workflow replaces the kit's own session
layer. The workflow is vendored unchanged in `workflow/`; the kit plugs into
the hooks it offers instead of carrying its own copies.

**On every machine:** run `scripts/install.sh` again (Windows:
`scripts\install.ps1`). It runs the workflow's installer with the game
commands added, and moves the skills that earlier kit versions copied to
`~/.claude/skills` into `~/.claude/skills-replaced-by-gamedev-wf/` (a skill
with the same name would shadow the new command).

**In a game set up with 1.3.0 or earlier:** replace its AGENTS.md with a
filled-in `harness/templates/AGENTS.md` (it now carries Check, Done gate, Run
limit, Push, "The plan", "At /wrap also", "Judged on"); bring PROGRESS.md to
the workflow's format (`workflow/templates/project/PROGRESS.md`); if the game
has `docs/spec/` files, move their Proof and Status columns into
`docs/TESTPLAN.md`.

- **Skills became commands.** `commands/*.md` in the workflow's command
  format, linked into `~/.claude/commands` and `~/.pi/agent/prompts` by the
  workflow's own installer. Same names in both agents (`/spec`, not
  `/skill:spec`), and `git pull` in the kit is the update on Linux.
- **`/build` is gone; `/start <IDs>` is the build loop.** The workflow's
  `/start` already does what `/build` did (plan, wait, loop until "done
  when", stop rules). What is specific to games moved into the game's
  AGENTS.md: where the plan lives, tests listed as input -> expected result
  from the spec's worked examples, blocked requirements cannot be started.
  `/build batch` is gone with it: the workflow has a Run limit per session
  instead. docs/09 says where a bigger task still fits.
- **`/start`, `/wrap`, `/judge` are the owner's**, replacing the kit's
  1.3.0 skills of the same names. `/review` is gone: its checks (weakened
  tests, unproven green, structure drift, invented things) are now the game's
  "Judged on" line, which `/judge` reads.
- **Finished means checked.** UI, visual and playtest requirements stay
  "awaiting my check" in TESTPLAN and PROGRESS.md until the human confirms.
- **One place for a requirement's test and status:** `docs/TESTPLAN.md`.
  Spec rows keep ID, requirement, source, tier and "blocked by".
- **`/qa` and `/playtest` no longer leave red tests in the tree** (they
  blocked every commit). The reproducing test goes into the report; the fix
  task adds it first.
- `/change-request` updates design and spec and queues the code change as
  `/start CR-NNN` instead of implementing in the same session.
- `/commission` check 13 covers the workflow setup (no brackets left in
  AGENTS.md, no instruction file in a parent folder, commands offered).
- Mode ship | learn removed, as in the workflow: teaching is a per-task request.
- Removed: the kit's `workflow/README.md`, its core/profile templates and the
  "Dead ends" section (all 1.3.0). The pi package now carries only the guard
  extension.
- Docs: GUIDE, README, 02, 03, 04, 05, 08, 09, 10 reworked. Games must be
  created outside the kit folder; the first-weekend guide copies the example
  out before an agent is started in it.

## Kit 1.3.0 / Harness 1.2.1 - 2026-11-12

(Superseded by 1.4.0 two days later; kept for the record.)

The owner's general short-loop workflow is now the session layer of the kit.

**Update existing games** (only needed if a game was set up with 1.2.0 or
earlier): run `scripts/install.sh` again (it removes the old `wrap-up`
skill), `scripts/update-harness.sh <game>`, then in the game: copy
`workflow/templates/project/PROGRESS.md` to the repo root and fill it from
the newest `docs/LOG.md` entry and the "Current state" section of AGENTS.md;
rename `docs/LOG.md` to `docs/history.md`; delete "Current state" from
AGENTS.md and add the Mode and Check lines from `harness/templates/AGENTS.md`.

- **`PROGRESS.md` replaces `docs/LOG.md` and the "Current state" section of
  AGENTS.md.** A snapshot (now, next, broken, dead ends, waiting on me) under
  ~60 lines, rewritten at every wrap. The log grew with every session and was
  read at every start; state lived in two places. Finished work goes to
  `docs/history.md` (append only, read when asked), technical decisions to
  `docs/decisions.md`. AGENTS.md is no longer edited at wrap.
- **`/wrap-up` is now `/wrap`**, and general: it reads the Check command from
  AGENTS.md, so the same skill ends a session in any project. Only the
  snapshot and the commit happen every time; history, decisions and status
  columns only when something changed.
- **New `/start`**: the two-checkpoint opener for any task (plan of at most
  5 bullets with the checks, wait for OK). In a game, `/build` stays the
  opener for requirement slices; `/start` covers bugs, refactors and tooling.
- **New `/review`**: fresh-session review of finished work (weakened tests,
  untested paths, structure drift, invented things), ranked by value per
  hour, fixes nothing. **New `/judge`** for deadline projects. Both are
  explicit-only, so their descriptions cost nothing in normal sessions.
- **Mode: ship | learn** per project, honoured by `/start` and `/build`.
- **`workflow/`**: the general workflow's guide, a user-level template, the
  project core templates and a hackathon profile. `/harness` takes
  PROGRESS.md, history.md and decisions.md from there.
- All skill descriptions shortened (they are loaded in every session):
  803 words for 13 skills before, 584 for the 14 that load now.
- Harness 1.2.1: two messages now point to PROGRESS.md. No behaviour change.

## Kit 1.2.0 / Harness 1.2.0 - 2026-11-11

**Update existing games:** `~/Gamedev_WF/scripts/update-harness.sh <game folder>`,
then in the game: `./harness/gw.sh check`, commit "Harness 1.2.0". Optional but
recommended: rename the game's `CLAUDE.md` to `AGENTS.md` and create a new
`CLAUDE.md` containing the single line `@AGENTS.md`; copy
`harness/templates/QUESTIONS.md` to `docs/` and `harness/templates/cases.json`
to `tests/cases/balance.json` (then edit the cases to your game).

Why: the kit assumed one agent (Claude Code), a design written by the agent
in an interview, and long unattended builds. The owner designs in detail
first, wants to stay in the loop on a small budget, wants the agent to act as
playtester, and also uses pi.

Harness:
- **`gw.sh cases`**: named balance situations from `tests/cases/balance.json`
  in one table against their targets (`[low, high]` on every seed, or
  `{"mean": [low, high]}` for win rates). `--only`, `--param.x=y` on all
  cases, `--strict`. Also written as a Markdown file. A showcase, not a gate:
  an open balance problem stays visible as `OFF` without blocking commits.
- **`gw.sh trace`**: one seed as a timeline, a line per window of ticks with
  the events and the state. Needs the optional hook method `events()`.
- **No more "Could not find type" after adding a class.** `gw.sh` re-imports
  the project by itself when the set of `class_name` scripts changed.
- The pre-commit gate treats `design/` like `docs/` (no test run for commits
  that only touch documents).
- Sim runner output of the plain seeds mode is unchanged.

Skills:
- **New `/spec`**: turns the human's own design documents (`design/`,
  read-only for the agent) into `docs/spec/<system>.md`: requirement rows with
  sources, worked examples as test vectors, data, glossary. Gaps,
  contradictions and superseded rules go to `docs/QUESTIONS.md` with options
  and a recommendation; nothing is invented. A cheap map step first, then one
  system at a time.
- **`/build` is a short loop now**: one slice (1-3 requirements), checkpoint
  A (the planned tests with expected values, wait for "go"), build, gate,
  commit, checkpoint B (report with a "see it yourself" command), stop.
  `/build batch` is the long loop, on request, and refuses unless there are
  no open questions, expected values exist and the pattern was approved once.
  Ambiguity is no longer resolved by "the simplest reading"; it is a question.
- **New `/qa`**: the agent as playtester. Fuzzing with a random bot, fault
  injection, the balance cases, traces, a report in `docs/playtests/`. Finds
  and shows; fixes nothing unasked.
- `/balance` proposes options with before/after evidence and waits for the
  human's pick before touching `data/`.
- `/define` points to `/spec` when design documents exist. `/harness`,
  `/commission` (13 checks), `/wrap-up`, `/change-request`, `/playtest` follow.

Agents:
- **`AGENTS.md`** is the project instruction file (pi and others read it);
  `CLAUDE.md` is a one-line import of it for Claude Code.
- **pi**: `package.json` makes the kit a pi package (`pi install <kit>`, done
  by `scripts/install.sh` when pi is present): the skills plus a guard
  extension that asks before `design/` or `harness/` are edited and blocks
  `git commit --no-verify` and forced pushes. Rules tested with `npm test`.
  Not yet run inside pi itself: see the check list in docs/10-pi.md.
- `claude-settings.json` template: `ask` rules for `design/` and `harness/`.

Docs: new [docs/09-loops.md](docs/09-loops.md) (short vs long loops, who
decides what) and [docs/10-pi.md](docs/10-pi.md) (cost with Claude Pro,
install, mapping, guard); GUIDE, README, 01, 04, 05, 08 reworked to match.

Example: random bot + SYS-004 (17 tests), hook `bot` param and `events()`,
`tests/cases/balance.json`; `*.uid` ignored in the example so running it
leaves the kit clean (in your own games, commit the `.uid` files).

## Harness 1.1.0 - 2026-11-04

**Update existing games:** `~/Gamedev_WF/scripts/update-harness.sh <game folder>`,
then in the game: `./harness/gw.sh check`, `./harness/gw.sh hooks`, commit
"Harness 1.1.0".

Why: the old runner counted a test that crashed with a script error as
**passed** (only `gw.sh`'s log grep caught it, without saying which test).
A hanging test could also stall an unattended agent indefinitely.

- **Errors fail the right test.** A script error or `push_error()` during a test
  now fails that test, with the message and file:line (Godot 4.5+, new file
  `harness/gw_error_capture.gd`). Tests that trigger an error on purpose
  declare it with `expect_error("fragment")`.
  *Possible effect on your game:* a test that was "green" while code under test
  called `push_error()` now fails. That is a real finding: fix the code, or
  add `expect_error()` if the error is the point of the test.
- **Time limits.** One test may wait at most 60 s (`GW_TEST_TIMEOUT`); one Godot
  run at most 900 s (`GW_TIMEOUT`, `0` disables). Long sim tests may need a
  higher `GW_TEST_TIMEOUT`.
- **Crash detection.** A test or sim run that ends without its summary line
  (Godot crashed) is a failure.
- **Fail-fast tiers.** `gw.sh test all` / `check` stop after the first red tier
  (unit -> sim -> scene) and say what was skipped; `GW_ALL_TIERS=1` runs all.
  As the embedded video puts it: slow tests run only when the fast ones pass.
- **Commit gate.** `gw.sh hooks` installs a git pre-commit hook that runs
  `gw.sh check` for commits touching code/data/tests; docs-only commits skip it.
  Once per clone.
- **Sim runner summary.** `ms/tick`, a `DIGEST` line (one-line determinism
  check) and `SAME ON EVERY SEED` for metrics the seeds don't influence.
- `gw.sh version` prints the harness version; `gw.sh help` works from any folder.

Kit (no action needed in games):
- `scripts/update-harness.sh`.
- `/define` offers to research known mechanics into `docs/ref/` before the interview.
- docs/06 + CLAUDE.md template: GDScript has no compiler to catch invented
  methods (CI proves an unreached `sim.bild_farm()` passes), so tests must
  reach every branch; types still catch mismatches at load (CI proves that too).
- Skills: `/harness` installs the hook and knows how to update a harness;
  `/commission` checks harness version, hanging-test timeout, digest
  determinism and the commit gate (12 checks); `/build` and `/wrap-up` respect
  the gate; `/balance` reads the new summary lines.
- Templates: `CLAUDE.md` forbids `--no-verify`; `claude-settings.json` denies
  `git commit --no-verify` / `-n` and `git push -f`; `godot-ci.yml` cancels
  superseded runs and uses current action versions.
- CI: shellcheck, canaries for crash attribution, a hanging test, an endless
  loop and the commit gate, and a two-run determinism check.
- Example: ECO-006 (broken rules file is reported) shows `expect_error()`; 16 tests.

## Harness 1.0.0 - 2026-11-04
First version: `gw.sh`, test runner, sim runner, example colony sim.
