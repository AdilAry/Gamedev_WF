# 09 - Short loops, long loops, and who decides what

The loop this kit runs is your own short-loop workflow (its own repo;
`$WORKFLOW_DIR/WORKFLOW.md` once installed). The kit does not change it.
This page shows what it looks like in a game, what the kit adds through the game's AGENTS.md,
and where a longer loop still has a place.

## One task, two gates

```
you: /start STA-004 STA-005
        |
  Gate 1. the plan, at most 5 bullets:
          tests as input -> expected result (from the spec's worked examples)
          done when: ./harness/gw.sh test unit status  passes
          what only you can check by hand
        |  "OK"
  the agent loops on its own: test red -> code -> run -> fix -> run ...
  it stops and reports when: "done when" passes | it must leave the plan |
  the same failure survived 3 different fixes | the Run limit (20 harness runs) |
  something needs your hands or the spec is ambiguous
        |
you: /wrap
  Check + "done when", PROGRESS.md rewritten, TESTPLAN ticked, commit
        |
  Gate 2. you check what it tells you to check, then clear the session.
          A part only you can judge stays "awaiting my check" until the
          next /start asks you about it.
```

`/start` with nothing takes "Next" item 1 from PROGRESS.md. Free text works
for anything that is not a requirement: `/start the farm test fails on seed 7`.

## What the game adds to the workflow

`/start`, `/wrap` and `/judge` know nothing about games. They read the game's
AGENTS.md, and that is where the kit plugs in:

| The workflow asks AGENTS.md for | A game answers |
|---|---|
| Check | `./harness/gw.sh check` |
| Done gate | the tests the plan names pass, then Check |
| Run limit | 20 harness runs (every `gw.sh` call that starts Godot) |
| "Read only when needed" (where the plan lives) | `docs/spec/<system>.md` (what) and `docs/TESTPLAN.md` (test and status) |
| "At /start also" | a check you confirmed sets the task's rows to `green` in `docs/TESTPLAN.md` |
| "At /wrap also" | a finished task's rows go `green`; TESTPLAN matches reality; questions are filed in `docs/QUESTIONS.md` |
| "Judged on" (for `/judge`) | green means proven, no weakened tests, architecture rules hold, nothing invented |

Three rules in the game's AGENTS.md make the plan at Gate 1 worth reading:
- every test is listed as input -> expected result, taken from the spec's
  worked examples, so you approve numbers from your own design, not code;
- a value the spec does not give is a question to you, never the agent's pick;
- a requirement blocked by an open question cannot be started.

## Why short loops are the cheap ones on a small budget

| Cost | Short loop | Long loop |
|---|---|---|
| Re-reading context every turn | small: one task, a few spec rows | grows with every step; a long session re-sends its whole history each turn |
| A wrong assumption | found at Gate 1, before code | built on for the rest of the run |
| A usage limit hitting mid-run | at worst one task is half done, and `/wrap` records where | a half-finished batch to untangle next time |
| Your time | a minute per gate | none during the run, more at review |

With a small budget, the expensive mistake is building the wrong thing well.

## Where a longer loop still fits

The workflow has no batch mode, on purpose: a session has a countable end
(the Run limit) and two gates. What you can vary is **how much one task
holds**. A bigger task is reasonable when all three are true:

1. No open question touches it.
2. The expected results already exist as worked examples in the spec.
3. It is the nth of a kind: you already checked the first one or two.

Then one task can carry several requirements of the same pattern:

```text
/start UNI-010 to UNI-014, same pattern as UNI-008. Run limit 50 for this task.
```

Gate 1 still shows you every test, and Gate 2 is still yours. Two honest limits:
- The stop rules in `/start` end a session that goes wrong, and
  WORKFLOW.md §4 ("Watch the context") holds the context backstop. If
  `/start` proposes a split, take it.
- There is no unattended multi-session run. Every session needs its two
  gates, so a workday you are away is not a workday the agent builds. What
  you can do from a phone on such a day is the part that costs no usage:
  answer `docs/QUESTIONS.md`, so the evening's tasks are not blocked.

If healthy sessions keep hitting the Run limit, raise the number in the game's
AGENTS.md rather than repeating it in every `/start`.

## Long loops for the machine cost nothing

There are two different "long loops", and only one spends usage:

- **The model thinking for an hour**: expensive.
- **The simulation running for an hour** (in a game with one): free. `./harness/gw.sh sim
  --seeds=1-500 --ticks=5000` or `./harness/gw.sh cases` is your laptop's CPU.
  The agent starts it, and reads twenty lines when it is done.

So be generous with seeds, ticks and cases, and stingy with what gets printed
into the conversation. You can also run these yourself, with no agent at all:

```bash
./harness/gw.sh cases
```

```bash
./harness/gw.sh trace --seed=7 --ticks=300
```

A game without a simulation has less to run here: its checks are short, and
more of them are yours (playtest).

## Who decides what

| Thing | Owner | The agent may |
|---|---|---|
| `design/` (your documents) | you | read; never edit |
| `docs/spec/*.md` (requirements, examples) | agent writes, you approve | restate your design; never add to it |
| `docs/QUESTIONS.md` | agent asks, you answer | recommend; never decide |
| `tests/cases/balance.json` (which situations matter, the targets) | you | propose cases and targets |
| `data/*.json` (the numbers) | you | propose with evidence; write after you pick |
| `tests/` | agent | write from the plan you OK'd; never weaken |
| `sim/`, `scenes/`, `ui/` (the code) | agent | everything, inside the architecture rules |
| `docs/TESTPLAN.md` | agent | tick what is finished; "awaiting my check" until you confirm |
| `PROGRESS.md` | agent rewrites it at `/wrap`; you read it | keep it a snapshot under ~60 lines |
| `AGENTS.md` | you | change it only when you ask |
| `harness/`, the commands | the kit | nothing; improve the kit instead |
| "finished" | you | say "done when" passed; finished is your call |

## What a week can look like

- **Any time, no AI:** write design in `design/`, answer `docs/QUESTIONS.md`,
  edit `tests/cases/balance.json` and run `gw.sh cases` (if the game has
  them), play the build, and do
  the checks that are "awaiting my check".
- **An evening (30-60 min of usage):** `/spec <system>` once, or two to four
  tasks (`/start`, OK, `/wrap`, check, clear, again), or one `/qa` and one
  `/balance`.
- **After a system is finished:** a new session, `/judge`.
