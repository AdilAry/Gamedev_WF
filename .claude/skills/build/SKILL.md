---
name: build
description: Run the closed development loop on a harnessed Godot project - pick the next requirements from docs/GDD.md, write the proving tests, implement, run the fastest test tier, fix, repeat until green, then commit with requirement IDs. Use when the user says build, implement, next phase, continue, or names requirement IDs or a phase.
---

# /build - the closed loop

Read first: `CLAUDE.md`, the newest entry of `docs/LOG.md`, `docs/TESTPLAN.md`,
and only the GDD sections you need (save context).

## 1. Choose the work
- If the user named requirement IDs or a phase, do those.
- Otherwise take the lowest unfinished phase in the GDD and its `todo`/`red`
  requirements. Prefer a batch that can be finished and committed in this
  session (about 3-8 requirements). Tell the user the batch in 3 lines, then go.
- If a requirement is ambiguous, pick the simplest reading that satisfies its
  proof, note the assumption in the log, and continue. Ask only if it changes
  the architecture.

## 2. For each requirement: test -> code -> green
1. **Test first.** Write/extend the test named in TESTPLAN in the right tier
   (`tests/unit`, `tests/sim`, `tests/scene`). Cite the ID in a comment.
   Run it and see it fail for the right reason.
2. **Implement** following the architecture rules in CLAUDE.md:
   rules in `sim/`, numbers in `data/`, presentation in `scenes/`/`ui/`.
3. **Run the fastest tier first**, filtered while iterating:
   `./harness/gw.sh test unit <filter>` -> `test sim` -> `test scene`.
   Only run slower tiers once the faster ones are green.
4. Read failures carefully; add `print()` debugging in the sim or in a test if
   the cause is unclear, then remove it. A script error or `push_error()`
   fails the test that triggered it; if a test provokes an error on purpose
   (bad input to a loader), declare it with `expect_error("fragment")`.
5. Update the TESTPLAN status to `green`.

## 3. Visual work
For UI/art requirements run `./harness/gw.sh shot res://scenes/<scene>.tscn 60`,
open the newest PNG(s), and compare against `docs/STYLE_GUIDE.md` and the GDD.
Describe what is wrong before changing anything. Keep visual checks few; they
are slow and cost context.

## 4. Gate and commit
- `./harness/gw.sh check` must print `CHECK OK`.
- Commit per finished requirement batch: `ECO-003, ECO-004: worker priority`.
  The pre-commit hook runs the gate again; if it blocks the commit, fix the
  cause. Never use `git commit --no-verify`.
- Push if a remote exists (CI will run the same check).

## Stop rules (important)
- Never weaken, skip, delete or rewrite a test just to make it pass. If you
  believe the test or the requirement is wrong, stop and propose a change
  request (`/change-request`) instead.
- Same failure after 5 honest fix attempts -> stop. Write a "Blocked" entry in
  `docs/LOG.md` (what fails, what you tried, your best hypothesis) and ask.
- If a file you touch passes ~300 lines or a function ~50 lines, refactor
  while tests are green, in its own commit.
- Do not install addons, change Godot versions or project-wide settings
  without asking.

## 5. End of batch
Report: requirements done (IDs), test counts per tier, anything assumed or
blocked, the next batch. Then run `/wrap-up` if the session is ending.
