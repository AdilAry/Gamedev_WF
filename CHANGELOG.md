# Changelog

What changed in the kit, and what to do in games that already use it.
Harness version = `HARNESS_VERSION` in `harness/godot/harness/gw.sh`
(`./harness/gw.sh version` in a game shows its copy).

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
