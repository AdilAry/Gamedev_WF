---
name: wrap
description: End a work session so a fresh one can continue from PROGRESS.md alone - run Check, rewrite PROGRESS.md as a snapshot, move finished work to docs/history.md, record decisions, commit, push. Use when the user says wrap, wrap up, done for today, hand off, or before a usage limit.
---

# wrap - leave the project ready for a fresh session

Optional note from the human on where things stopped: the arguments. Ending
in the middle of a slice is fine; record exactly where it stopped.

Do only the steps whose condition holds. Keep this cheap: it runs at the end
of every session, when the context is at its fullest.

1. Run the Check command from AGENTS.md (in a Gamedev-WF game:
   `./harness/gw.sh check`). If it fails, say so plainly and record it under
   "Broken"; never hide or bypass it.
2. **PROGRESS.md is a snapshot, not a log.** Rewrite "Now" and "Next" from
   scratch. "Next" item 1 must be concrete enough to start from without
   asking. Delete everything resolved or no longer true (never strike
   through). Keep it under ~60 lines.
3. "Dead ends": if an approach was tried and abandoned this session, one line
   on what and why. Drop entries whose topic is finished.
4. "Waiting on me": every open decision the human must make. In a
   Gamedev-WF game the questions themselves live in `docs/QUESTIONS.md`;
   PROGRESS.md only names the ones that block "Next".
5. Only if a milestone, system or review finished: append an entry to
   `docs/history.md` (built, checked, left open). Git already records what
   changed; write what git cannot say.
6. Only if a decision was made that someone might question later: add it to
   `docs/decisions.md` (decision, why, rejected, revisit if).
7. Only if the project keeps them and something changed: status columns in a
   test plan or spec, `docs/ai_log.md` when a new AI tool was used.
8. `git status`, then commit (docs and state together; code only if Check is
   green, otherwise leave the code uncommitted or on a `wip/<topic>` branch
   and say so). Push if the project's workflow says so. Never bypass a
   commit hook.
9. Reply in at most 6 lines: what to run to check the result and the output
   to expect, what is waiting on the human, the next slice. In learn mode,
   end with 3 short questions on what was done.

Do not edit AGENTS.md here. It holds facts that are true for the whole
project and changes only when the human asks.
