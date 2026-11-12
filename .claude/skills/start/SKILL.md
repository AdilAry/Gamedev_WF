---
name: start
description: Open a short work session on one slice of any software project - pull, read PROGRESS.md, propose a plan of at most 5 bullets with the checks, wait for OK before changing files. Use when the user says start, begin, continue, or names a milestone or task.
---

# start - open a session on one slice

Task for this session: the arguments given with the command (a milestone,
a slice, or a plain task such as "fix the export"). No arguments: take
"Next" item 1 from PROGRESS.md.

1. Run `git pull` (skip if there is no remote). Read `PROGRESS.md`. If the
   task belongs to a milestone, read only that milestone's section of
   `docs/plan.md`. Read nothing else yet.
2. If PROGRESS.md and the code disagree, or PROGRESS.md contradicts itself,
   say so before anything else.
3. If the task is bigger than one slice (one thing the human can check,
   finished with the context under about half full), say which slice you take
   now and which you leave for later sessions.
4. Reply with a plan of at most 5 bullets:
   - the steps and the files you will touch;
   - **the checks, before any code**: which tests you will add and what each
     expects (input -> expected result), or the command and output that will
     show it works. A value you would have to make up is a question, asked here;
   - anything listed under "Dead ends" in PROGRESS.md that you will avoid.
   Follow the project's Mode; in learn mode, mark the parts the human writes.
5. Wait for the OK before changing files. "go" with a correction means: apply
   the correction, do not re-plan.

A project that has its own opener for part of its work uses that instead: in
a Gamedev-WF game (`harness/gw.sh` exists), requirement slices go through the
`build` skill, which does these steps with the spec's worked examples.
`start` covers everything else there (a bug, a refactor, tooling, art).

While working: one slice only. A decision only the human can make goes under
"Waiting on me" in PROGRESS.md; do not guess, continue with what is not
blocked. The same failure twice with the same approach: stop and say so,
rather than trying a third variation. End with the `wrap` skill.
