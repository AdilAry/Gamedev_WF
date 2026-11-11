# 09 - Short loops, long loops, and who decides what

You asked for the human in the loop and said you mostly run short loops
because of your budget. The kit now works that way by default. This page says
why, and makes the case for the long loop where it earns its place.

## The default: one slice, two checkpoints

```
you: /build STA-004
        |
  A. agent shows the tests it will write: inputs -> expected results   (1 minute of your time)
        |  "go"
  agent: tests red -> code -> green -> gate -> commit
        |
  B. agent reports: done, how to see it in one command, questions filed. STOPS.
        |
you: "next" / answer a question / change direction
```

- **Checkpoint A is the important one.** You are not asked to read code. You
  read five lines like "6 buffs + 1 more -> the rightmost moves to Temporary"
  and say whether that is your game. A misunderstanding caught here costs one
  message. Caught after three more slices were built on it, it costs an evening.
- **Checkpoint B keeps you in the picture.** Every slice ends with something
  you can check yourself in under a minute.
- **Questions go to a queue, not into guesses.** When your design is silent or
  contradicts itself, the agent writes a row in `docs/QUESTIONS.md` with
  options and a recommendation and works on something else. You answer in
  Obsidian. Answering costs no usage at all.

## Why short loops are the cheap ones on a small budget

It looks backwards: more stops, more messages. But count what a session pays for.

| Cost | Short loop | Long loop |
|---|---|---|
| Re-reading context every turn | small: one slice, one spec file | grows with every step; a long session re-sends its whole history each turn |
| A wrong assumption | found at checkpoint A, before code | built on for the rest of the run |
| A usage limit hitting mid-run | at worst one slice is half done | a half-finished batch to untangle next time |
| Your time | a minute per slice | none during the run, more at review |

With a large budget, wasted work is an annoyance. With a small one it is the
whole evening. The scarce thing is usage, and the cheapest way to spend less
of it is to never build the wrong thing.

## The case for the long loop

A long loop is the right tool when **your judgement would add nothing per
step**. That is true more often than "never", and less often than the videos
suggest for a game you have designed in detail. It pays when all three hold:

1. **No open questions** touch the work.
2. **The expected results already exist** (worked examples in the spec), so
   the agent does not have to make up what "correct" means.
3. **It is the nth of a kind.** You reviewed the first two units; units 3 to
   20 follow the same pattern from the same table.

Typical long-loop work: content rollout from a data table, tests for rules
that already work, a refactor that must keep every test green, fault-injection
sweeps, moving a system to a new data format.

Two more arguments for it, both about your situation:

- **Pro usage is use-it-or-lose-it.** The allowance comes in windows. A window
  that passes while you are at work is gone. A batch that was prepared the
  evening before (questions answered, examples in the spec) turns that idle
  window into progress. This is the one real advantage of the unattended run,
  and it only exists if the batch needs nothing from you.
- **Fixed overhead.** Every session reads AGENTS.md, the log and the spec
  once. Five slices in one session pay that once; five sessions pay it five times.

So the honest recommendation is a ladder, not a side:

| Rung | What | Loop |
|---|---|---|
| 1 | First slice of a system, anything touching a design decision | short, both checkpoints |
| 2 | More slices of the same system, same session | short, but say "go" in the request (`/build STA-006 go`) to skip checkpoint A when the spec's examples leave nothing to agree on |
| 3 | The nth of a kind, examples in the spec, no open questions | `/build batch <IDs>` - the agent checks the three conditions and refuses if one fails |

`/build batch` still commits per slice, still obeys every stop rule, skips
(and logs) a slice that turns out to need a decision, and ends with one report.

## Long loops for the machine cost nothing

There are two different "long loops", and only one spends usage:

- **The model thinking for an hour**: expensive.
- **The simulation running for an hour**: free. `./harness/gw.sh sim
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

## Who decides what

| Thing | Owner | The agent may |
|---|---|---|
| `design/` (your documents) | you | read; never edit |
| `docs/spec/*.md` (requirements, examples) | agent writes, you approve | restate your design; never add to it |
| `docs/QUESTIONS.md` | agent asks, you answer | recommend; never decide |
| `tests/cases/balance.json` (which situations matter, the targets) | you | propose cases and targets |
| `data/*.json` (the numbers) | you | propose with evidence; write after you pick |
| `tests/` | agent | write from approved examples; never weaken |
| `sim/`, `scenes/`, `ui/` (the code) | agent | everything, inside the architecture rules |
| `harness/` | the kit | nothing; improve the kit instead |

## What a week can look like

- **Any time, no AI:** write design in `design/`, answer `docs/QUESTIONS.md`,
  edit `tests/cases/balance.json`, run `gw.sh cases` and play the build.
- **An evening (30-60 min of usage):** `/spec <system>` once, or two to four
  `/build` slices, or one `/qa` + one `/balance`. End with `/wrap-up`.
- **A workday you are away:** if rung 3 applies, start `/build batch ...` on
  the agent box in tmux before you leave. If it does not apply, don't; let
  the window go and answer questions on your phone instead.
