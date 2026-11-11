---
name: build
description: Implement one small slice of a harnessed Godot project in a short, human-checked loop - agree the tests (inputs and expected results) with the human first, then test, code, run the fastest tier, fix until green, commit with requirement IDs, report and stop. Batch mode (several slices unattended) only when the user asks for it. Use when the user says build, implement, next, continue, or names requirement IDs, a system or a phase.
---

# /build - the loop, one slice at a time

The human designed the game and stays in the loop. Usage is limited, so the
expensive mistake is building the wrong thing well. The default is therefore a
**short loop with two checkpoints**. A longer unattended run exists (batch
mode, at the end) but the human has to ask for it.

Read first, and nothing more: `AGENTS.md` ("Current state"), the newest entry
of `docs/LOG.md`, the rows you need from `docs/TESTPLAN.md`, the spec of the
system you touch (`docs/spec/<system>.md`, or its section of `docs/GDD.md`),
and `docs/QUESTIONS.md` for open questions on those requirements.

## 1. Pick the slice
- A slice is **one behaviour the human can check**: usually 1-3 requirement
  IDs of one system, a few tests, well under ~150 lines of new code.
- If the user named IDs, take those (split them into slices if there are
  more than three). Otherwise take the next `todo`/`red` rows in build order.
- A requirement marked `blocked by Q-...` is not buildable. Say so, show the
  question, and take the next unblocked one. Never answer a design question
  yourself to get unblocked.
- No harness yet (`harness/gw.sh` missing) -> stop and suggest `/harness`.

## 2. Checkpoint A - agree what "done" means (before any code)
Show the plan and wait for "go":

```
Slice: STA-004, STA-005 - status bars overflow into Temporary
Tests I will write (unit):
  1. 6 buffs + 1 more          -> the rightmost buff moves to Temporary   (spec example 3)
  2. Temporary full, 1 more    -> rightmost is removed, overload triggers once
  3. same status, two sources  -> two separate entries
Files: sim/status/status_bars.gd (new), data/status.json (bar size 6)
Assumptions: none   |   Not in this slice: overload damage formula (STA-006)
Go?
```

Rules for the plan:
- Expected values come from the spec's worked examples. If a test needs a
  value the spec does not give, do not make one up: ask now, in this message.
- At most ~12 lines. It is meant to be read in under a minute; it is the
  cheapest moment to catch a misunderstanding.
- Skip this checkpoint only if the user said so ("/build STA-004 go",
  "don't ask, just build") or in batch mode.

## 3. The loop: test -> code -> green
1. **Test first.** Write the tests from the plan in the right tier
   (`tests/unit`, `tests/sim`, `tests/scene`), each citing its ID in a comment.
   Run them and see them fail for the right reason.
2. **Implement** by the architecture rules in AGENTS.md: rules in `sim/`,
   numbers in `data/`, presentation in `scenes/`/`ui/`. Use the identifiers
   from the spec's glossary.
3. **Run the fastest tier first**, filtered while iterating:
   `./harness/gw.sh test unit <filter>` -> `test sim` -> `test scene`.
   Slower tiers only when the faster ones are green.
4. Read failures carefully. Add `print()` debugging if the cause is unclear,
   then remove it. A script error or `push_error()` fails the test that
   triggered it; a test that provokes one on purpose declares it with
   `expect_error("fragment")`.
5. Every new `if`/`match` branch in `sim/` needs a test that reaches it
   (GDScript only reports a misspelled method when that line runs).
6. Update the TESTPLAN rows to `green`.

## 4. Gate and commit
- `./harness/gw.sh check` must print `CHECK OK`.
- One commit per slice: `STA-004, STA-005: status bars overflow into Temporary`.
  The pre-commit hook runs the gate again. Never use `git commit --no-verify`.
- Push if a remote exists.

## 5. Checkpoint B - report and stop
```
Done: STA-004, STA-005 (commit 3f9a2c1) - 3 new tests, check OK (41 passed)
See it yourself: ./harness/gw.sh test unit status   |   in game: apply 7 buffs to one unit
Assumed: nothing   |   Questions filed: Q-014 (does overload fire per status or once?)
Next slice I would take: STA-006 overload damage - needs Q-014 answered first
```
- "See it yourself" is one command or a 30-second thing to try in the game.
  If the human can not check a slice, it was not a good slice.
- **Then stop.** Do not start the next slice. The human says "next", answers a
  question, or changes direction. If the session is ending, run `/wrap-up`.

## Stop rules (always, both modes)
- Never weaken, skip, delete or rewrite a test to make it pass, and never
  edit `design/` or `harness/`. If a test, a requirement or a design document
  looks wrong, stop and say so; propose a `/change-request`.
- A design decision appears mid-slice (a case the spec does not cover): finish
  what is unambiguous, file the question in `docs/QUESTIONS.md`, leave the
  affected requirement `red`, and report. Do not pick "the simplest reading".
- Same failure after 5 honest fix attempts -> stop. Write a "Blocked" entry in
  `docs/LOG.md` (what fails, what you tried, best hypothesis) and ask.
- A file passing ~300 lines or a function ~50 lines -> say so in the report
  and offer a refactor slice (tests green before and after, its own commit).
- No addons, Godot version changes or project-wide settings without asking.

## Batch mode (the long loop) - only on request
Triggered by "/build batch <IDs | system | phase>" or "build these unattended".
Before starting, check all three, and refuse with the reason if one fails:
1. No open question touches the batch.
2. Every requirement has expected values (worked examples in the spec), so no
   test value has to be invented.
3. The batch repeats a pattern the human already approved once in a normal
   slice (the 3rd unit after two reviewed ones, the remaining rows of a table).
   First-of-its-kind work is not batch work.

Then: one slice after the other, each with its own tests, gate and commit; no
checkpoint A; the stop rules still apply, and a blocked slice is skipped and
logged rather than guessed. Keep a running list in `docs/LOG.md` so an
interrupted batch (usage limit) can resume. End with one report in the
checkpoint-B format, a row per slice, plus everything that was skipped and why.
