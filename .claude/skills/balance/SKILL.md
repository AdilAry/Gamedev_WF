---
name: balance
description: Tune a strategy or simulation game with headless simulation runs - run many seeds through the sim runner, compare results to the balance targets (BAL-*) in docs/GDD.md, change only data/*.json, re-run, and report the before/after evidence. Use when the user says balance, tune, too easy/hard, economy feels off, or after a playtest raises balance issues.
---

# /balance - measure, propose, let the human pick, measure again

Balance is an experiment, not a guess. The headless sim runner plays the game
with bots across many seeds in seconds, and those runs cost CPU, not usage.
The numbers in `data/` are part of the design, so **you bring the evidence and
the options; the human picks**. Write to `data/*.json` only after they chose
(or said up front "apply the best one").

## 1. Define the question
State in one line what is being tuned and which target it serves, e.g.
"BAL-001: a GreedyBot should reach 20-30 population by tick 300 (now 35)".
If the GDD has no numeric target for it, propose one and ask the user to
confirm before tuning towards it.

## 2. Baseline
`./harness/gw.sh cases` first: every situation the human cares about
(`tests/cases/balance.json`), side by side against its target. Keep that
table; it is the "before". If the thing being tuned has no case yet, propose
one (name, params, target) and add it once the human agrees.
For a closer look at one configuration:
`./harness/gw.sh sim --seeds=1-30 --ticks=<N>` (use enough ticks to cover a
full session). Save the summary table. If the hook offers more metrics than
needed, look at the CSV with `head`/`awk` - do not print whole CSVs.
Look for: runaway resources, dead resources (never spent), stalls (metric
flat for a long time), early deaths, and variance between seeds.
Read the extra summary lines:
- `SAME ON EVERY SEED: ...` - those metrics do not depend on the seed. More
  seeds prove nothing about them; if the design wants variety there, the
  randomness (events, map, bot choices) does not reach them yet. Say so.
- `ms/tick` - cost of one simulated tick. Note it if it grows a lot between
  experiments (performance budget, GDD section 10).
- `DIGEST` - identical for identical inputs; quote it in the report so a
  later run can confirm it reproduces the same numbers.

## 3. Experiments
- Try changes with overrides first, without editing files:
  `./harness/gw.sh sim --seeds=1-30 --ticks=600 --param.growth_ticks=12 --param.farm.produces.food=3`
  (the hook's `apply_override` decides which keys exist; extend it if needed).
- The same override works on all cases at once, which shows what else a
  change moves: `./harness/gw.sh cases --param.growth_ticks=12`.
- Change one or two numbers per experiment. Keep a small table:
  `experiment | params | key metrics (min/mean/max) | verdict`.
- When numbers alone do not explain a result, read one run:
  `./harness/gw.sh trace --seed=<n> --ticks=<N> --param...`.
- If the bot is too dumb to show the effect (e.g. never builds X), improve
  the bot in `sim/ai/` in a separate, clearly described step - a bot change
  is not a balance change.

## 4. Propose, then apply
- Show 2-3 options as a table: `option | what changes | the cases before ->
  after | side effects on other cases | what a player would feel`. Recommend
  one. If no option reaches the target by numbers alone, say that the rule
  itself needs a design change (`/change-request`) instead of forcing it.
- Wait for the human's choice.
- Write the chosen numbers into `data/*.json`. Never hard-code numbers in
  `sim/` to fix balance.
- Update or add the sim-tier tests that pin the target
  (e.g. `assert_between(pop, 20, 30)`), so a later change cannot silently
  break the balance.
- `./harness/gw.sh cases` again (the "after"), `./harness/gw.sh check` ->
  `CHECK OK`, commit `BAL-001: slower growth (12 ticks)`.

## 5. Report
Before/after table, what changed, what a human should feel differently in a
playtest, and what the bots cannot tell us (fun, readability). Suggest a
focused playtest goal.
