# The Godot AI Workflow Guide - from chat to closed loop

This guide takes the "10 levels" and "Embedded AI Harness" ideas from the
embedded videos (spec-driven development, agents, a sandboxed machine, a
harness that closes the loop) and moves them over to **Godot game
development**, for any genre. Strategy and sim games set the level of
complexity it was built for, and some of its tools fit them best ([what
every game uses](#what-every-game-uses-and-what-is-optional)). It assumes
your setup: Claude Pro, mostly Claude Desktop and Claude Code (pi is for
later: the workflow's WORKFLOW.md §6), a Windows 10 Legion Y540 as your
main machine and a Linux Mint ThinkPad T480s you can spare.

> **The one-sentence version:** you design the game, in as much detail as you
> like, in your own documents; the agent turns them into numbered
> requirements, **asks you about every gap instead of filling it**, writes the
> GDScript one small task at a time, and a harness lets it **run the game
> headless and test it** (and, in a game with a simulation, play it with
> bots), so each task comes back proven and, where there are bots, each
> balance question comes back with numbers. You stay in the loop at
> two gates: before the work (is this the right plan, with the right expected
> results?) and after it (finished is your call, not the agent's).

## How the pieces fit

Three layers, each usable without the one above it:

| Layer | What it is | Where |
|---|---|---|
| **Your short-loop workflow** | one task per session, `/start` and `/wrap`, two gates, `PROGRESS.md` as a snapshot, `/judge` in a fresh session. Works for any software project | its own repo (`$WORKFLOW_DIR/WORKFLOW.md`); the kit depends on it and keeps no copy |
| **The harness** | `gw.sh`: headless tests in tiers, a smoke run, screenshots, the commit gate; for a game with a simulation also the sim tier, simulation runs, balance cases and traces (the part that fits strategy/sim best) | `harness/` |
| **The game commands** | `/spec`, `/harness`, `/commission`, `/qa`, `/balance`, `/playtest`, `/change-request`, and for ideas and art `/pitch`, `/define`, `/style-guide`, `/asset` (`/balance` and the bot part of `/qa` fit number-driven games) | `commands/` |

A game is a normal short-loop project whose AGENTS.md says: Check is
`./harness/gw.sh check`, the plan lives in `docs/spec/` and
`docs/TESTPLAN.md`, expected results come from the worked examples in the
spec, and design gaps go to `docs/QUESTIONS.md`. There is no separate
"build" command: `/start STA-004` is the build loop.

## How this kit differs from the videos

The embedded videos end with "the human is completely out of the programming
loop". That fits a smart-meter gateway, where the spec is small and the
result is either right or wrong. It fits a game you have designed in depth
less well, and it fits a small AI budget badly. So the kit keeps the harness
and changes two things:

| The videos | This kit |
|---|---|
| `/define` interviews you and writes the spec | `/spec` reads the design you already wrote (`design/`), restates it as testable requirements, and files every contradiction or gap as a question for you. `/define` is still there for when you only have an idea |
| one long autonomous `/build` | one task per session, two gates, a Run limit. [docs/09-loops.md](docs/09-loops.md) explains why, and where a bigger task still fits |

## Why bother? (and what went wrong in the Gambo pipeline)

Your note on Gambo7592's pipeline found the key weakness: after a few days
the codebase was "pure spaghetti". That is what happens with **open-loop**
AI coding: prompt, code, hope. Nothing stops the agent from piling quick
fixes on top of each other, and nobody notices a broken rule until you
play.

The embedded videos fix this with three things, and they all carry over:

| Embedded world | Gamedev equivalent in this kit |
|---|---|
| Functional Spec Document (FSD) | Your documents in `design/` + **specs** (`docs/spec/<system>.md`, indexed by `docs/GDD.md`) where every requirement has an ID, a source in your documents *and a proof* |
| Firmware logic | **Rules core** (`sim/`, in every game): pure GDScript rules, no nodes, deterministic |
| Host tests (logic on the PC) | **unit tier**: rules tested headless in milliseconds |
| Target tests (on the chip) | **scene tier**: real scenes in a real (headless) SceneTree |
| Bench tests (Pi testbench, fault injection) | **sim tier** (optional, fits strategy/sim best): bots play thousands of ticks over many seeds, a random bot fuzzes the rules, plus nasty edge cases; `gw.sh cases` puts your balance situations side by side |
| Field test (real smart meter) | **playtest**: you play it; notes go back in as tests or change requests |
| Datasheets in the project folder | **Godot API dump** of *your* version + design references in `docs/` |
| Pi testbench = the AI's hands and eyes | `harness/gw.sh` + Godot's `--headless`, `--write-movie` screenshots |
| VM / container with YOLO permissions | **The Mint laptop** as the agent box |
| /define /harness /commission /build | /spec (or /define), /harness, /commission as commands; the build loop is your workflow's /start and /wrap; plus /qa /balance /playtest /change-request /pitch /style-guide /asset and /judge |

Strategy and sim games fit this approach best. That's not only because some
tools are made for them, but because their core is numbers and rules, and
those can be tested without a screen: bots can play your economy 10 000
times overnight. In a platformer or action game, much of what matters is how
it feels: jump arcs, timing, impact. No headless test can judge that. You
can still test the parts that are rules, such as damage, inventory, state
machines and whether level data is valid. But more tasks will end as
"awaiting my check", and `/playtest` does more of the work than the bots do.

## What every game uses, and what is optional

**Any Godot game:**
- the session loop (the workflow's `/start`, `/wrap`, `/judge`) and its two gates;
- `/pitch`, `/define`, `/spec`, `/harness`, `/commission`, `/change-request`,
  `/playtest`, `/style-guide`, `/asset`;
- the harness: the test runner with the `unit` and `scene` tiers, `smoke`,
  `check`, the commit gate, `doc`, `shot`, `export` and CI;
- the templates: AGENTS.md, SPEC, QUESTIONS, GDD, TESTPLAN, CHANGE_REQUEST,
  PLAYTEST, IDEA, ASSETS, STYLE_GUIDE;
- the architecture: rules in `sim/` as plain classes, presentation in
  `scenes/` and `ui/`, numbers in `data/`. A platformer has rules too
  (damage, inventory, state machines, level-data validity), and they get the
  same fast tests.

**Fits strategy and sim games best (optional elsewhere):**
- the `sim` tier and the sim runner (`gw.sh sim`, `cases`, `trace`),
  `sim/harness_hook.gd`, bots in `sim/ai/`, fuzzing with the random bot;
- balance cases (`tests/cases/balance.json`), BAL- targets, `/balance`, and
  the bot and balance parts of `/qa`;
- the colony example: it shows everything, the optional parts included;
- the genre advice: time models ([docs/06](docs/06-architecture.md)),
  readability and silhouettes ([docs/07](docs/07-asset-pipeline.md), the
  STYLE_GUIDE template, `/style-guide`), the strategy/sim scope flags in
  `/pitch`, the strategy examples in the GDD template and `cases.json`.

A game without a simulation skips the second list. An empty `tests/sim/` is
fine: `check` runs the same. `/harness` asks which kind your game is and only
sets up the second list when it has a simulation.

---

## The 10 levels, gamedev edition

Treat these as stairs, not a checklist for one weekend. Most of the payoff
comes from levels 2, 3, 4 and 8.

### Level 0 - Vibe coding in chat
You ask Claude Desktop for a script, paste it into Godot, hope. Fine for
"how do I make a Timer repeat?", useless for a game. Its typical failure in
Godot: it mixes up **Godot 3 and Godot 4 syntax** (`instance()` vs
`instantiate()`, `export var` vs `@export var`, `yield` vs `await`).

### Level 1 - Spec-driven
Stop editing code by hand. Describe the behaviour; if it's wrong, change the
description and let the AI regenerate. Your job moves from typing code to
writing precise sentences, which a designer does anyway.

### Level 2 - The design as Markdown files
Put the description in files, not chat. You already do this: your drafts are
many small documents, one per system, with later "clarification" notes that
amend earlier ones. Keep working exactly like that, in a `design/` folder
inside the game (it can be an Obsidian vault). The agent never edits that
folder. `/spec` derives the contract from it: `docs/GDD.md` (the index) and
one `docs/spec/<system>.md` per system. Markdown is what the agent reads and
writes best.

Two habits make your documents much cheaper to turn into a game:
- **Worked examples.** "Level 40, two HP modifiers: 160 -> 170 -> 510 in
  combat" is worth more than a paragraph. Each example becomes a test.
- **Say what replaces what.** When a new note changes an older rule, name the
  old file. Otherwise the agent has to ask which one wins (it will ask; it
  will not guess).
 In Claude Desktop you can also add the GDD to a **Project** so
design conversations always have it in context.

Game-specific extra: **numbers live in data files** (`data/*.json`), not in the
GDD or the code. The GDD says what a number *means* and its target range;
the JSON holds the value. That lets balancing happen without touching code.

### Level 3 - Agents (Claude Code)
A coding agent works on the **whole project folder**: it reads, edits single
lines, runs commands. With Claude Pro you have **Claude Code** included. Use
it from the **Code tab in Claude Desktop** (Windows) or as the `claude`
command in a terminal (Mint). Same account, same usage limits. See
[docs/04-claude-pro-playbook.md](docs/04-claude-pro-playbook.md).

### Level 4 - Git + GitHub
Non-negotiable once an agent edits files. Every working state is one
`git checkout` away, and GitHub becomes the bridge between your two laptops.
You never need to learn git syntax: say "commit and push" or run `/wrap`.
Make game repos **private** if you like; GitHub Actions minutes for private
repos are limited but plenty for headless tests.

### Level 5 - Let the agent run things
An agent that can't run Godot is a chat window with extra steps. Allow it to
run the harness, git and file edits without asking every time. On **Windows
(your main machine)** use the allow-list in `.claude/settings.json` (the
`/harness` command installs one) or Claude Code's auto mode. Don't give it
blanket access on that machine.

### Level 6 - A sandbox box with full permissions (the Mint laptop)
The videos use a VM; you have something better for free: a whole spare
laptop. The ThinkPad becomes the **agent box**: a dedicated Linux user,
Godot, and Claude Code without permission prompts
(`--dangerously-skip-permissions`, the `superclaude` alias), nothing
personal on it. The agent can install, delete
and experiment there; the worst case is reinstalling Mint. Setup:
[docs/03-setup-mint.md](docs/03-setup-mint.md). Roles of both machines:
[docs/01-machines.md](docs/01-machines.md).

### Level 7 - Many projects in parallel, with memory
You have more ideas than time, so make ideas **cheap to park and cheap to
resume**:
- `/pitch` turns any idea into a one-page pitch with a score, filed in an
  `ideas/` inbox (or your Obsidian vault).
- Each game is its own folder + repo with its own `AGENTS.md` (the agent's
  standing instructions) and `PROGRESS.md` (the current state: now, next,
  broken, dead ends, waiting on you; a snapshot of under 60 lines, not a log).
- `/wrap` ends every session by rewriting that snapshot, committing and pushing,
  so the next session (on either laptop, in either agent) starts with
  `/start`, which reads PROGRESS.md and only the rows of the plan it needs.
- Run the agent in `tmux` on the Mint box, so a dropped SSH connection does
  not end the session.
  Remote options (Claude Code on the web, Remote Control) let you check in
  from your phone - see the Pro playbook.

### Level 8 - The closed loop: Godot from the command line
This is the step that changes everything, the equivalent of Arduino CLI in
the video. Godot runs without a window:

```bash
./harness/gw.sh test unit          # rules, milliseconds
./harness/gw.sh test sim           # bots, many seeds, invariants
./harness/gw.sh test scene         # real scenes, simulated button presses
./harness/gw.sh smoke              # boot the game 300 frames, catch runtime errors
./harness/gw.sh sim --seeds=1-30 --ticks=800   # balance numbers + CSV
./harness/gw.sh cases              # your balance situations side by side vs their targets
./harness/gw.sh trace --seed=7 --ticks=200     # one run as a readable timeline
./harness/gw.sh shot               # render real frames to PNG; Claude looks at them
./harness/gw.sh check              # the gate before every commit
```

The `sim` tier, `sim`, `cases` and `trace` need a simulation; a game without
one uses the rest.

The agent writes code, runs these, **reads the errors and numbers itself**,
fixes, and repeats until the task's "done when" passes. You get back
five lines: the result, the output line that proves it, what is left, and
what to check before you type `/wrap`. Details:
[docs/05-testing-tiers.md](docs/05-testing-tiers.md).

### Level 9 - Reference material in the project ("datasheets")
The embedded "datasheet" becomes:
- **The exact Godot API of your version:** `./harness/gw.sh doc` dumps it to
  `docs/ref/godot-api/`. `AGENTS.md` tells the agent to grep it instead of
  guessing. This prevents most hallucinated or Godot-3 APIs.
- **Design references:** mechanics write-ups, wiki pages of games you admire,
  formulas (e.g. Lanchester combat laws, logistic growth, queueing). Put them
  in `docs/ref/` and say "use docs/ref/combat.md for the battle model".
- **Data tables you'd normally type by hand** (unit stats, tech trees): give
  the agent a rough spreadsheet/CSV and let it generate the JSON + loader +
  validation tests.

### Level 10 - Beyond your comfort zone
Because you no longer write every line yourself, the learning curve of
"harder" tech flattens: shaders for map overlays, C# or GDExtension (C++) for
a hot simulation loop, multithreaded pathfinding, procedural map generation.
Your embedded background helps here (performance budgets, determinism,
fixed-point thinking). Rule: **only go there when a measurement says so** (the
sim runner prints timings; in any game, Godot's profiler), and only where
tests cover the behaviour, so the rewrite can be checked against the old one.

---

## The workflow (what you actually do)

```
 YOU: design/*.md  (your documents, as detailed as you like; the agent never edits them)
        |
     /spec            system map, then one system at a time
        |-----------> docs/spec/<system>.md   requirements + worked examples + sources
        |-----------> docs/QUESTIONS.md       gaps and contradictions  <--- YOU answer (no AI needed)
        |
   /harness, /commission   (once per project / per machine)
        |
        v
     /start <IDs>  --> Gate 1: plan, tests with expected results, "done when" -- YOU: OK
        |              the agent loops alone until "done when" passes (or a stop rule fires)
     /wrap         --> Check, PROGRESS.md rewritten, TESTPLAN ticked, commit
        |              Gate 2: YOU check what it names; a hand check stays "awaiting my check"
        |  clear the session, /start again
        v
      /qa  the agent tests it: bugs with a reproducing test; with a simulation also seed + tick and your balance cases as one table
        |
        +-- bug -------> /start <the bug>  (its plan begins with the reproducing test)
        +-- numbers ---> /balance: options with before/after  --> YOU pick --> data/*.json
        +-- design ----> /change-request  (you change design/, the spec follows, then /start CR-NNN)
        |
   YOU play it --> /playtest sorts your notes into the same three buckets
        |
     /judge  in a fresh session, after a system: is green really proven, were tests weakened, did structure drift
```

Every session, in any project:
- **/start <task>** - pulls, reads PROGRESS.md and only the task's rows of the
  plan, and proposes at most 5 bullets ending in "done when". Nothing changes
  before your OK. Then the agent works alone until "done when" passes, or
  until it must leave the plan, the same failure survived 3 fixes, or the
  Run limit is reached.
- **/wrap** - runs Check, rewrites PROGRESS.md, ticks what is finished,
  commits, and tells you what to check. Finished means checked by you.
- **/judge** - a review in a new session that did not build the work.

Game commands, when you need them:
1. **/pitch** - park a new idea in 5 minutes. Pick the best one later.
2. **/spec** - for the game you have designed. First a cheap map of your
   documents (which file belongs to which system, which notes amend which,
   a build order). Then one system at a time: requirements with IDs, the
   worked examples from your text as test vectors, the numbers for `data/`,
   a glossary, and a question for everything that is missing or contradictory.
   (**/define** instead, if there is only an idea: it interviews you.)
3. **/harness** - creates the Godot project with the right structure, copies
   the runners, and sets the game up as a short-loop project: `AGENTS.md`,
   `PROGRESS.md`, test plan, CI workflow, and with a simulation the hook,
   bots and balance cases.
4. **/commission** - proves the setup itself works, including that a failing
   test really fails. After this, a red test means a game bug, not a setup bug.
5. **/qa** - the agent as playtester: the test tiers and the spec's edge
   cases and, in a game with a simulation, fuzzing with a random bot, fault
   injection, your balance cases and traces of the interesting runs; a report.
   It finds and shows; it does not fix or retune on its own.
6. **/balance** - evidence and options for one balance question; you pick;
   then it changes only JSON numbers and shows before/after. It fits
   number-driven games with a simulation.
7. **/playtest** - you play, ramble your notes, the agent sorts them.
8. **/change-request** - change the design and spec first; the code change is
   then an ordinary `/start`.

Art runs in parallel and stays placeholder until the mechanics are fun:
**/style-guide** (from reference images) and **/asset** (SVG/procedural or
prompts for image tools, with a provenance manifest). See
[docs/07-asset-pipeline.md](docs/07-asset-pipeline.md).

---

## What stays your job

1. **Design and taste.** What's fun, what the game is about, what to cut.
   Everything in `design/` is yours and stays yours.
2. **Answering questions.** `docs/QUESTIONS.md` is where the agent puts every
   decision it is not allowed to make. Keeping that queue short is the best
   thing you can do for the project, and it costs no usage.
3. **The balance cases and targets** (in a game that has them).
   `tests/cases/balance.json` lists the
   situations you care about and what "right" means for each. The agent
   proposes; the file is yours. Vague targets get vague games.
4. **Approving tests, not code.** At Gate 1 you read a few lines of
   "given this, expect that". That, plus ten minutes with `TESTPLAN.md` now
   and then, is worth more than an hour reading code.
5. **Checking and playtesting.** "Done when" passing is the agent's evidence;
   finished is your call. Bots can tell you one way of playing dominates;
   only you can tell whether it's *boring*, or whether a jump feels right.
6. **Saying no.** The agent will happily build features. Scope fences in the
   GDD ("out of scope") protect your limited time.

## Honest limits

- **Pro usage limits are real.** That is why the loop is short and every session has a Run limit. Keep
  AGENTS.md short, read one spec file at a time, filter test output (the
  runner already prints only failures). See the Pro playbook.
- **`/spec` is only as good as the documents.** It will not notice a rule you
  never wrote down; it can only notice that something it needs is missing.
- **Headless can't judge feel.** Juice, camera, animation timing and audio
  need you or screenshots. Keep the game's core testable and the feel layer thin.
  In a feel-heavy game that layer is a bigger share of the work.
- **`.tscn` files are fragile for agents.** This kit builds UI in code and
  keeps scenes small. Bigger hand-made scenes are better done by you in the
  editor, with the agent wiring scripts to them.
- **Bots are dumb.** Balance from bots is a starting point; a dominant way
  of playing that bots don't find still exists.
- **Windows 10 is out of support** (see docs/01-machines.md); one more reason
  the full-permission agent lives on the Mint box.

## Where to go next

1. [docs/01-machines.md](docs/01-machines.md) - which laptop does what
2. [docs/02-setup-windows.md](docs/02-setup-windows.md) - main laptop
3. [docs/03-setup-mint.md](docs/03-setup-mint.md) - agent box
4. [docs/04-claude-pro-playbook.md](docs/04-claude-pro-playbook.md) - get the most out of Pro
5. [docs/05-testing-tiers.md](docs/05-testing-tiers.md) - the harness in depth
6. [docs/06-architecture.md](docs/06-architecture.md) - how to structure a game so its rules stay testable
7. [docs/07-asset-pipeline.md](docs/07-asset-pipeline.md) - art with AI, adapted from the Gambo note
8. [docs/08-first-weekend.md](docs/08-first-weekend.md) - a step-by-step plan and prompt cheat sheet
9. [docs/09-loops.md](docs/09-loops.md) - short loops, long loops, and who decides what
10. [docs/10-pi.md](docs/10-pi.md) - pi, for later: cost, install, the guard extension
11. `$WORKFLOW_DIR/WORKFLOW.md`, in the workflow's own repo - your short-loop workflow, for any software project: the session files and commands this kit is built on (install it first: [README](README.md#quick-start))
