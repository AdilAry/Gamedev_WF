# QA-<NNN> - YYYY-MM-DD - <scope>

| Field | Value |
|---|---|
| Build / commit | |
| Scope | whole game / system |
| Runs | the commands, so this can be repeated |

## Bugs
| # | What happens | Repro (seed, tick, params) | Red test | Severity |
|---|---|---|---|---|

## Balance showcase
The table from `./harness/gw.sh cases` (copy it from the `MD` file it printed).

| case | note | metric | min | mean | max | target | verdict |
|---|---|---|---|---|---|---|---|

### Reading
Plain words: what is off and by how much, what the seeds do not influence,
dead or runaway resources, dominant or useless options, cliffs, stalls.

### Traces
`./harness/gw.sh trace --seed=...` of the 1-3 runs worth reading, pasted.

### Cases worth adding (proposals - you decide)
| name | params | why |
|---|---|---|

## Test gaps
Rules with a limit but no test at the limit and one step past it.

## Only you can judge (10-minute play script)
What to try, and what to watch for.
-

## Decisions (filled in by the human)
| Finding | Decision (fix / tune / change design / leave) |
|---|---|
