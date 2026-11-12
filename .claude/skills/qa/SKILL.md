---
name: qa
description: Act as the game's playtester with headless runs - test tiers, balance cases, fuzzing bots, fault injection, traces; write a report with reproducible bugs and a balance table. Finds and shows, fixes nothing unasked. Use when the user says qa, find bugs, show me the balance, or after a system is built.
---

# /qa - the agent as playtester

Two jobs: **catch bugs** and **show balance cases**. You report what the game
does; the human decides what it should do. Do not fix bugs or change numbers
in this skill unless the user asked for that in the same message.

Runs cost CPU, not usage: prefer long runs with many seeds and read only the
summaries. Never print CSVs or logs into the conversation.

## 1. Scope (one line, then go)
The whole game, or the system the user named. Note the commit
(`git log -1 --oneline`).

## 2. Bugs
1. `./harness/gw.sh check` - the gate. A red gate is finding number one; stop
   the run there if the game cannot even start.
2. **Fuzz**: let the dumbest possible player loose. If the hook supports a
   random bot (`--param.bot=random`, see `sim/harness_hook.gd`), run
   `./harness/gw.sh sim --seeds=1-200 --ticks=<a long game> --param.bot=random`.
   Every `INVARIANT seed=S tick=T` line is a bug with a built-in repro. If the
   project has no random bot yet, say so and offer to add one (`sim/ai/`, seeded,
   also tries commands that should be refused) as a separate small slice.
3. **Fault injection**: absurd rules through overrides, one at a time: zero
   costs, zero income, 10x consumption, every random event every tick, the
   smallest and largest counts the design allows.
   `./harness/gw.sh sim --seeds=1-20 --ticks=<N> --param.<key>=<value>`
4. **Edge cases from the spec**: for each rule with a limit ("at most 6",
   "cannot exceed 80%"), check there is a test at the limit and one step past
   it. List the missing ones; do not write them all unasked.
5. For each failure, **replay it**: `./harness/gw.sh trace --seed=S --ticks=T`
   (add the same `--param`s). The timeline usually shows the cause. Then write
   one failing test that reproduces it (tier unit if possible), cite the seed,
   and leave it red. A bug without a test comes back.

## 3. Balance showcase
1. `./harness/gw.sh cases` - the human's cases (`tests/cases/balance.json`)
   side by side against their targets. This table is the core of the report.
   No cases file yet -> offer to draft one from the BAL-* targets in the spec
   (kit template `harness/templates/cases.json`) and let the human edit it:
   which situations matter is a design decision.
2. Read the table like a playtester and say it in plain words:
   - `OFF` rows: by how much, and in which direction.
   - **Seeds do not matter** (min = mean = max): the randomness never reaches
     this number; more seeds prove nothing.
   - **Dead or runaway resources**: something that only ever grows, or is never spent.
   - **Dominant or useless options**: a building/unit/strategy every winning
     run uses, or none does. Compare bots or strategies as separate cases.
   - **Cliffs**: a small parameter change that flips the outcome (try the
     neighbours of a suspicious value with `--param`).
   - **Stalls**: long windows where nothing changes (use `trace`).
3. For the 1-3 most interesting cases, attach a trace
   (`./harness/gw.sh trace --seed=<a typical or the worst seed> ...`) so the
   human can read *how* the run went, not just where it ended.
4. Suggest new cases worth adding (name, params, why). Do not add targets
   (`expect`) yourself; propose them.

## 4. Write the report
`docs/playtests/QA-<NNN>-<date>.md` from the kit template
(`<kit>/harness/templates/QA_REPORT.md`): commit, what was run (commands, so
it can be repeated), then
- **Bugs** - what happens, repro (seed, tick, params), the red test, severity.
- **Balance showcase** - the cases table (copy it from the `MD` file the run
  printed), your reading, the traces.
- **Test gaps** - rules without a test at their limits.
- **Only you can judge** - what bots cannot see (fun, clarity, pacing, whether
  a dominant strategy is boring), as a 10-minute play script: what to try and
  what to watch for.

## 5. Report and stop
At most 10 lines in chat: counts, the top three findings, the file. Then ask
what to do with them: fix a bug (`/build`, the red test is already there), tune
(`/balance`), change the design (`/change-request`), or play it yourself
(`/playtest`). Do not continue on your own. Structure and code quality are
not this skill's job: that is `review`, in a fresh session.
