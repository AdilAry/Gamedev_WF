---
name: commission
description: Verify the development setup itself before real work starts - Godot version, import, test runner catches failures and script errors, smoke run, sim runner, screenshots, CI and git push - and record the result in docs/COMMISSIONING.md. Use after /harness, after changing machines or Godot versions, or when failures look like setup problems rather than game bugs.
---

# /commission - prove the test bench before trusting it

Goal: once commissioning passes, any later failure points at the game code or
the requirement - not at a broken toolchain. Run every step, even if earlier
ones pass. Fix setup problems yourself where you can; ask the human only for
things you cannot do (install software needing a password, create a GitHub
repo, plug in hardware).

## Checklist (run in order, record each result)

1. **Environment**: OS, `godot --version` (or `$GODOT`), `git --version`,
   free disk space, the kit version (`git -C <kit> log -1 --oneline`).
   Godot major.minor must match `config/features` in project.godot and
   `GODOT_VERSION` in `.github/workflows/godot-ci.yml`.
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
   non-zero with `HARNESS: script errors found`. Delete the canary file afterwards.
6. **Smoke**: `./harness/gw.sh smoke 300` -> `SMOKE OK`.
7. **Sim runner**: `./harness/gw.sh sim --seeds=1-3 --ticks=100` -> summary
   table and a CSV path. Open the CSV head to confirm columns.
8. **Determinism**: run the same sim command twice; final metrics must match.
9. **Visual**: `./harness/gw.sh shot "" 60` -> PNG paths. Open the last PNG
   and describe what you see in one sentence. (On a headless Linux box this
   needs `xvfb`; if it cannot work on this machine, mark it N/A and say which
   machine can do it.)
10. **Git**: `git status` clean after commit; `git push` works (if a remote exists).
11. **CI**: if GitHub is set up, push and check the `godot-ci` workflow result
    (ask the user to look at the Actions tab if you cannot see it).

## Record
Write `docs/COMMISSIONING.md`: date, machine, Godot version, a table of the 11
checks with PASS / FAIL / N/A and a note, and anything the human must do.
Commit it ("Commissioning: <machine> <date>").

## Finish
Summarise in 5 lines. If everything critical (1-8, 10) passes, say the project
is ready for `/build`.
