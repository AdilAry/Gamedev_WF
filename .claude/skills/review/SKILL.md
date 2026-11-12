---
name: review
description: Fresh-eyes review in a NEW session - read the diff since the last review against plan, spec and rules, run Check, and rank issues by value per hour without fixing anything. Use after a milestone or system is finished.
disable-model-invocation: true
---

# review - fresh eyes on finished work

A reviewer that watched the work being built ends up grading its own work.
If this session wrote any of the code under review, say so and ask the human
to run this in a new session instead.

Scope: the arguments (a milestone, a system, a commit range). No arguments:
everything since the last review entry in `docs/history.md`, else the last 10
commits.

1. Read AGENTS.md's rules, then what the work was supposed to do: the
   milestone's section of `docs/plan.md`, or the spec of the system. Not the
   chat history, not PROGRESS.md's account of it.
2. `git log --oneline <range>` and `git diff --stat <range>`. Read the diff of
   the files that matter; do not read the whole repository.
3. Run the Check command. Run the program if that is cheap.
4. Look for, in this order:
   - **Wrong or missing behaviour** against the plan or spec.
   - **Weakened checks**: tests deleted, loosened, skipped, or expected values
     changed without a recorded reason (`git log -p -- tests/` shows it).
   - **Untested paths**: new branches no test reaches; limits without a test
     at the limit.
   - **Structure drift**: logic in the wrong layer, files or functions grown
     too large, duplicated code, a second way of doing the same thing.
   - **Invented things**: numbers, names or features that are in neither the
     plan, the spec nor a recorded decision.
   - **Stale state**: PROGRESS.md, the plan or the docs saying something the
     code no longer does.
5. Do not fix anything. Reply with the issues ranked by value per hour of
   fixing: what, where (file:line), why it matters, rough size of the fix.
   Say what looked good in two lines at most.
6. Append a short entry to `docs/history.md` (date, range reviewed, issue
   count, the top three) and add the accepted fixes to "Next" in PROGRESS.md
   only after the human has picked them.

For a second opinion from a different model, the human can run this skill in
another agent on the same repository; nothing here depends on which one.
