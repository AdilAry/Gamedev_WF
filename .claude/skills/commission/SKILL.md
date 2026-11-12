---
name: commission
description: Verify the development setup itself (Godot, test runner catching failures, sim runner, screenshots, commit gate, CI, agent setup) and record it in docs/COMMISSIONING.md. Use after harness, on a new machine or Godot version, or when failures look like setup problems.
---

# /commission - prove the test bench before trusting it

Goal: once commissioning passes, any later failure points at the game code or
the requirement - not at a broken toolchain. Run every step, even if earlier
ones pass. Fix setup problems yourself where you can; ask the human only for
things you cannot do (install software needing a password, create a GitHub
repo, plug in hardware).

## Checklist (run in order, record each result)

1. **Environment**: OS, `./harness/gw.sh version` (harness + Godot), `git --version`,
   free disk space, the kit version (`git -C <kit> log -1 --oneline`).
   Godot major.minor must match `config/features` in project.godot and
   `GODOT_VERSION` in `.github/workflows/godot-ci.yml`. If the kit's
   `HARNESS_VERSION` (in `<kit>/harness/godot/harness/gw.sh`) is newer than
   the project's, run `<kit>/scripts/update-harness.sh .` first.
2. **Import**: `./harness/gw.sh import` -> no errors.
3. **Runner reports passes**: `GW_VERBOSE=1 ./harness/gw.sh test all` -> lists tests.
4. **Runner catches a failed assertion**: create
   `tests/unit/test_zz_canary.gd`:
   ```gdscript
   extends "res://harness/gw_test.gd"
   func test_canary() -> void:
       assert_eq(1, 2, "canary")
   ```
   `./harness/gw.sh test unit canary` must exit non-zero and print `FAIL`.
5. **Runner catches a script error**: replace the body with
   `var d := {}` / `var x: int = d["missing"].size()`. The command must exit
   non-zero, print `FAIL [unit] test_zz_canary.gd::test_canary` with a
   `SCRIPT ERROR` line under it, and `HARNESS: script errors found`.
6. **Runner stops a hanging test**: replace the body with
   `await wait_seconds(999)` and run `GW_TEST_TIMEOUT=3 ./harness/gw.sh test unit canary`.
   It must fail with `timed out`. Delete the canary file afterwards.
7. **Smoke**: `./harness/gw.sh smoke 300` -> `SMOKE OK`.
8. **Sim runner**: `./harness/gw.sh sim --seeds=1-3 --ticks=100` -> summary
   table and a CSV path. Open the CSV head to confirm columns.
9. **Determinism**: run the same sim command twice; the `DIGEST` lines must match.
   **Cases and trace**: `./harness/gw.sh cases` prints the table and a `CASES`
   line (N/A if `tests/cases/balance.json` does not exist yet);
   `./harness/gw.sh trace --seed=1 --ticks=50` prints a timeline with events.
10. **Visual**: `./harness/gw.sh shot "" 60` -> PNG paths. Open the last PNG
   and describe what you see in one sentence. (On a headless Linux box this
   needs `xvfb`; if it cannot work on this machine, mark it N/A and say which
   machine can do it.)
11. **Git + commit gate**: `./harness/gw.sh hooks` (once per clone). Stage a
    red canary test and try `git commit` - it must be blocked by `PRECOMMIT`.
    Unstage and delete it. `git status` clean after a real commit; `git push`
    works (if a remote exists).
12. **CI**: if GitHub is set up, push and check the `godot-ci` workflow result
    (ask the user to look at the Actions tab if you cannot see it).
13. **Agent setup**: `AGENTS.md` exists and `CLAUDE.md` is the one-line import
    of it; `PROGRESS.md` exists and is under ~60 lines. Say which agent you are. On pi: the startup header lists
    `AGENTS.md`, the Gamedev-WF skills and the guard extension; if the skills
    are missing, the kit is not installed (`pi install <kit>`). On Claude
    Code: `.claude/settings.json` exists.

## Record
Write `docs/COMMISSIONING.md`: date, machine, Godot and harness versions, a
table of the 13 checks with PASS / FAIL / N/A and a note, and anything the
human must do.
Commit it ("Commissioning: <machine> <date>").

## Finish
Summarise in 5 lines. If everything critical (1-9, 11) passes, say the project
is ready for `/build`.
