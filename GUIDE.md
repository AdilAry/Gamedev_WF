# The Godot AI Workflow Guide - from chat to closed loop

This guide takes the "10 levels" and "Embedded AI Harness" ideas from the
embedded videos (spec-driven development, agents, a sandboxed machine, a
harness that closes the loop) and moves them over to **Godot game
development, with strategy and simulation games in mind**. It assumes
your setup: Claude Pro, mostly Claude Desktop, the pi coding agent you are
learning, a Windows 10 Legion Y540 as your main machine and a Linux Mint
ThinkPad T480s you can spare.

> **The one-sentence version:** you design the game, in as much detail as you
> like, in your own documents; the agent turns them into numbered
> requirements, **asks you about every gap instead of filling it**, writes the
> GDScript one small slice at a time, and a harness lets it **run the game
> headless, test it and play it with bots**, so each slice comes back proven
> and each balance question comes back with numbers. You stay in the loop at
> the two points where your judgement is cheap and decisive: before a slice
> (are these the right tests?) and after it (here is how to see it).

## How this kit differs from the videos

The embedded videos end with "the human is completely out of the programming
loop". That fits a smart-meter gateway, where the spec is small and the
result is either right or wrong. It fits a game you have designed in depth
less well, and it fits a small AI budget badly. So the kit keeps the harness
and changes three things:

| The videos | This kit |
|---|---|
| `/define` interviews you and writes the spec | `/spec` reads the design you already wrote (`design/`), restates it as testable requirements, and files every contradiction or gap as a question for you. `/define` is still there for when you only have an idea |
| one long autonomous `/build` | one slice, two checkpoints, stop. Batches only on request and only for repeat work. [docs/09-loops.md](docs/09-loops.md) explains why, and when the long loop wins |
| one agent (Claude Code) | any agent that reads `AGENTS.md` and Agent Skills: Claude Code, the Code tab of Claude Desktop, and pi. [docs/10-pi.md](docs/10-pi.md) |

---

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
| Firmware logic | **Simulation core** (`sim/`): pure GDScript rules, no nodes, deterministic |
| Host tests (logic on the PC) | **unit tier**: rules tested headless in milliseconds |
| Target tests (on the chip) | **scene tier**: real scenes in a real (headless) SceneTree |
| Bench tests (Pi testbench, fault injection) | **sim tier**: bots play thousands of ticks over many seeds, a random bot fuzzes the rules, plus nasty edge cases; `gw.sh cases` puts your balance situations side by side |
| Field test (real smart meter) | **playtest**: you play it; notes go back in as tests or change requests |
| Datasheets in the project folder | **Godot API dump** of *your* version + design references in `docs/` |
| Pi testbench = the AI's hands and eyes | `harness/gw.sh` + Godot's `--headless`, `--write-movie` screenshots |
| VM / container with YOLO permissions | **The Mint laptop** as the agent box |
| /define /harness /commission /build | the same skills, plus /spec /qa /pitch /balance /playtest /style-guide /asset /change-request /wrap-up |

Strategy and sim games fit this approach **better than platformers**: their
core is numbers and rules, which can be tested headless, while "game feel"
(jump arcs, juice) mostly can't be. Bots can play your economy 10 000 times
overnight. They can't tell you if a jump feels good.

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
You never need to learn git syntax: say "commit and push" or run `/wrap-up`.
Make game repos **private** if you like; GitHub Actions minutes for private
repos are limited but plenty for headless tests.

### Level 5 - Let the agent run things
An agent that can't run Godot is a chat window with extra steps. Allow it to
run the harness, git and file edits without asking every time. On **Windows
(your main machine)** use the allow-list in `.claude/settings.json` (the
`/harness` skill installs one) or Claude Code's auto mode. Don't give it
blanket access on that machine. pi has no permission prompts at all, so pi
belongs on the agent box (next level); the kit's guard extension adds the
few questions that matter (see [docs/10-pi.md](docs/10-pi.md)).

### Level 6 - A sandbox box with full permissions (the Mint laptop)
The videos use a VM; you have something better for free: a whole spare
laptop. The ThinkPad becomes the **agent box**: a dedicated Linux user,
Godot, and your agent without permission prompts (pi works that way by
default; for Claude Code it is `--dangerously-skip-permissions`, the
`superclaude` alias), nothing personal on it. The agent can install, delete
and experiment there; the worst case is reinstalling Mint. Setup:
[docs/03-setup-mint.md](docs/03-setup-mint.md). Roles of both machines:
[docs/01-machines.md](docs/01-machines.md).

### Level 7 - Many projects in parallel, with memory
You have more ideas than time, so make ideas **cheap to park and cheap to
resume**:
- `/pitch` turns any idea into a one-page pitch with a score, filed in an
  `ideas/` inbox (or your Obsidian vault).
- Each game is its own folder + repo with its own `AGENTS.md` (the agent's
  standing instructions) and `docs/LOG.md` (what happened last time).
- `/wrap-up` ends every session by updating the log, committing and pushing,
  so the next session (on either laptop, or from your phone) starts with
  "read the log and continue".
- Run the agent in `tmux` on the Mint box, so a dropped SSH connection does
  not end the session. A prepared batch (`/build batch ...`, see
  [docs/09-loops.md](docs/09-loops.md)) can run there while you are at work.
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

The agent writes code, runs these, **reads the errors and numbers itself**,
fixes, and repeats until the slice's tests pass. You get back
"done, 41 tests green, see it with this command, 1 question for you". Details:
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
sim runner prints timings), and only where tests cover the behaviour, so
the rewrite can be checked against the old one.

---

## The harness workflow (what you actually do)

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
     /build  one slice --> A: "these tests?" -- YOU: go --> red, code, green, commit --> B: report, STOP
        ^                                                                                  |
        |  "next"                                                                          v
        +------------------------- YOU check it in one command  <--------------------------+
        |
      /qa  the agent plays it: bugs with seed + tick, a red test each; your balance cases as one table
        |
        +-- bug -------> /build (the red test is already there)
        +-- numbers ---> /balance: options with before/after  --> YOU pick --> data/*.json
        +-- design ----> /change-request  (you change design/, the spec follows, then code)
        |
   YOU play it --> /playtest sorts your notes into the same three buckets
        |
     /wrap-up  log, state, push: the next session starts in one minute, in any agent
```

1. **/pitch** - park a new idea in 5 minutes. Pick the best one later.
2. **/spec** - for the game you have designed. First a cheap map of your
   documents (which file belongs to which system, which notes amend which,
   a build order). Then one system at a time: requirements with IDs, the
   worked examples from your text as test vectors, the numbers for `data/`,
   a glossary, and a question for everything that is missing or contradictory.
   (**/define** instead, if there is only an idea: it interviews you.)
3. **/harness** - creates the Godot project with the right structure, copies
   the runners, `AGENTS.md`, test plan, balance cases, CI workflow.
4. **/commission** - proves the setup itself works, including that a failing
   test really fails. After this, a red test means a game bug, not a setup bug.
5. **/build** - one slice. You approve the tests, it builds, reports, stops.
   `/build batch ...` for repeat work, when you ask for it.
6. **/qa** - the agent as playtester: fuzzing with a random bot, fault
   injection, your balance cases, traces of the interesting runs, a report.
   It finds and shows; it does not fix or retune on its own.
7. **/balance** - evidence and options for one balance question; you pick;
   then it changes only JSON numbers and shows before/after.
8. **/playtest** - you play, ramble your notes, the agent sorts them.
9. **/change-request** - change the design and spec first, then the code.
10. **/wrap-up** - always, at the end of each session.

In pi the same skills are `/skill:spec`, `/skill:build` and so on.

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
3. **The balance cases and targets.** `tests/cases/balance.json` lists the
   situations you care about and what "right" means for each. The agent
   proposes; the file is yours. Vague targets get vague games.
4. **Approving tests, not code.** At checkpoint A you read a few lines of
   "given this, expect that". That, plus ten minutes with `TESTPLAN.md` now
   and then, is worth more than an hour reading code.
5. **Playtesting.** Bots tell you a strategy dominates; only you can tell
   whether it's *boring*.
6. **Saying no.** The agent will happily build features. Scope fences in the
   GDD ("out of scope") protect your limited time.

## Honest limits

- **Pro usage limits are real.** That is why the default loop is short. Keep
  AGENTS.md short, read one spec file at a time, filter test output (the
  runner already prints only failures). See the Pro playbook.
- **pi does not run on your Pro allowance.** Anthropic bills third-party
  tools per token on top of the plan. Details in [docs/10-pi.md](docs/10-pi.md).
- **`/spec` is only as good as the documents.** It will not notice a rule you
  never wrote down; it can only notice that something it needs is missing.
- **Headless can't judge feel.** Juice, camera, animation timing and audio
  need you or screenshots. Keep the game's core testable and the feel layer thin.
- **`.tscn` files are fragile for agents.** This kit builds UI in code and
  keeps scenes small. Bigger hand-made scenes are better done by you in the
  editor, with the agent wiring scripts to them.
- **Bots are dumb.** Balance from bots is a starting point; a dominant
  strategy that bots don't find still exists.
- **Windows 10 is out of support** (see docs/01-machines.md); one more reason
  the full-permission agent lives on the Mint box.

## Where to go next

1. [docs/01-machines.md](docs/01-machines.md) - which laptop does what
2. [docs/02-setup-windows.md](docs/02-setup-windows.md) - main laptop
3. [docs/03-setup-mint.md](docs/03-setup-mint.md) - agent box
4. [docs/04-claude-pro-playbook.md](docs/04-claude-pro-playbook.md) - get the most out of Pro
5. [docs/05-testing-tiers.md](docs/05-testing-tiers.md) - the harness in depth
6. [docs/06-architecture.md](docs/06-architecture.md) - how to structure a sim game so it stays testable
7. [docs/07-asset-pipeline.md](docs/07-asset-pipeline.md) - art with AI, adapted from the Gambo note
8. [docs/08-first-weekend.md](docs/08-first-weekend.md) - a step-by-step plan and prompt cheat sheet
9. [docs/09-loops.md](docs/09-loops.md) - short loops, long loops, and who decides what
10. [docs/10-pi.md](docs/10-pi.md) - using pi: cost, install, the guard extension
