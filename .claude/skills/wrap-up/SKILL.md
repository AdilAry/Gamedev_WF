---
name: wrap-up
description: End a work session cleanly - run the full harness check, update TESTPLAN, the "Current state" section of CLAUDE.md and a new docs/LOG.md entry, commit and push - so the next session (on any machine) can resume in one minute. Use when the user says wrap up, done for today, update documentation and push, hand off, or before the usage limit runs out.
---

# /wrap-up - leave the project ready for next time

Short sessions are the norm (Pro usage limits, evenings after work). Every
session must end in a state where the next one can start with "read the log,
continue".

## Steps
1. `./harness/gw.sh check`. If it fails, do NOT hide it: either fix it quickly
   (small, obvious) or record it as the first item under "Blocked".
2. `docs/TESTPLAN.md`: statuses match reality (green / red / todo).
3. `docs/LOG.md`: add a new entry on top (template in the kit):
   done (IDs + commits), test state, decisions not yet in the GDD, blocked /
   questions for the human, the single next step.
4. `CLAUDE.md` "Current state": update to max ~10 lines (phase, last green
   check, next step). Keep the rest of CLAUDE.md stable - edit it only when a
   rule really changed.
5. If the GDD has open questions answered during the session, move the
   answers into the GDD.
6. `git add -A && git commit -m "Wrap-up: <summary>"` and `git push` if a
   remote exists. Never commit `reports/`, `.godot/` or secrets. The
   pre-commit hook re-runs the gate when code changed (docs-only commits skip
   it). If the gate is red and cannot be fixed now, do not bypass it: commit
   the docs (LOG with the Blocked entry) on their own and leave the code
   change uncommitted, or on a `wip/<topic>` branch, and say so.
7. Tell the user in 3-5 lines: what is done, what is next, what they need to
   decide or test (e.g. "play 10 minutes and tell me if winter feels unfair").
