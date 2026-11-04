# The Godot AI Workflow Guide - from chat to closed loop

This guide takes the "10 levels" and "Embedded AI Harness" ideas from the
embedded videos (spec-driven development, agents, a sandboxed machine, a
harness that closes the loop) and moves them over to **Godot game
development, with strategy and simulation games in mind**. It assumes
your setup: Claude Pro, mostly Claude Desktop, a Windows 10 Legion Y540 as
your main machine and a Linux Mint ThinkPad T480s you can spare.

> **The one-sentence version:** you write the *what* (design doc +
> requirements + balance targets); the agent writes the *how* (GDScript),
> and a harness lets it **run the game headless, test it, measure it and
> fix it without you**, until the requirements are proven. You spend your
> scarce time on design, playtesting and taste.

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
| Functional Spec Document (FSD) | **Game Design Document** (`docs/GDD.md`) where every requirement has an ID *and a proof* |
| Firmware logic | **Simulation core** (`sim/`): pure GDScript rules, no nodes, deterministic |
| Host tests (logic on the PC) | **unit tier**: rules tested headless in milliseconds |
| Target tests (on the chip) | **scene tier**: real scenes in a real (headless) SceneTree |
| Bench tests (Pi testbench, fault injection) | **sim tier**: bots play thousands of ticks over many seeds, plus nasty edge cases |
| Field test (real smart meter) | **playtest**: you play it; notes go back in as tests or change requests |
| Datasheets in the project folder | **Godot API dump** of *your* version + design references in `docs/` |
| Pi testbench = the AI's hands and eyes | `harness/gw.sh` + Godot's `--headless`, `--write-movie` screenshots |
| VM / container with YOLO permissions | **The Mint laptop** as the agent box |
| /define /harness /commission /build | the same skills, plus /pitch /balance /playtest /style-guide /asset /change-request /wrap-up |

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

### Level 2 - The GDD as Markdown files
Put the description in files, not chat: `docs/IDEA.md` (the spark) and
`docs/GDD.md` (the contract). Markdown is what the agent reads and writes
best. You already write notes in an Obsidian-style format (front-matter,
`[[links]]`), so **use Obsidian as your editor** and point a vault at your
game folders. In Claude Desktop you can also add the GDD to a **Project** so
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
blanket access on that machine.

### Level 6 - A sandbox box with full permissions (the Mint laptop)
The videos use a VM; you have something better for free: a whole spare
laptop. The ThinkPad becomes the **agent box**: a dedicated Linux user,
Godot, Claude Code started with `--dangerously-skip-permissions` (the
`superclaude` alias), nothing personal on it. The agent can install, delete
and experiment there; the worst case is reinstalling Mint. Setup:
[docs/03-setup-mint.md](docs/03-setup-mint.md). Roles of both machines:
[docs/01-machines.md](docs/01-machines.md).

### Level 7 - Many projects in parallel, with memory
You have more ideas than time, so make ideas **cheap to park and cheap to
resume**:
- `/pitch` turns any idea into a one-page pitch with a score, filed in an
  `ideas/` inbox (or your Obsidian vault).
- Each game is its own folder + repo with its own `CLAUDE.md` (the agent's
  standing instructions) and `docs/LOG.md` (what happened last time).
- `/wrap-up` ends every session by updating the log, committing and pushing,
  so the next session (on either laptop, or from your phone) starts with
  "read the log and continue".
- Run Claude in `tmux` on the Mint box: start a long `/build` before work,
  check it later. Remote options (Claude Code on the web, Remote Control)
  let you check in from your phone - see the Pro playbook.

### Level 8 - The closed loop: Godot from the command line
This is the step that changes everything, the equivalent of Arduino CLI in
the video. Godot runs without a window:

```bash
./harness/gw.sh test unit          # rules, milliseconds
./harness/gw.sh test sim           # bots, many seeds, invariants
./harness/gw.sh test scene         # real scenes, simulated button presses
./harness/gw.sh smoke              # boot the game 300 frames, catch runtime errors
./harness/gw.sh sim --seeds=1-30 --ticks=800   # balance numbers + CSV
./harness/gw.sh shot               # render real frames to PNG; Claude looks at them
./harness/gw.sh check              # the gate before every commit
```

The agent writes code, runs these, **reads the errors and numbers itself**,
fixes, and repeats until the requirement's proof passes. You come back to
"done, 23 tests green, 2 questions for you". Details:
[docs/05-testing-tiers.md](docs/05-testing-tiers.md).

### Level 9 - Reference material in the project ("datasheets")
The embedded "datasheet" becomes:
- **The exact Godot API of your version:** `./harness/gw.sh doc` dumps it to
  `docs/ref/godot-api/`. `CLAUDE.md` tells the agent to grep it instead of
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
 idea --/pitch--> ideas/foo.md --/define--> docs/GDD.md (requirements + proofs)
                                                |
                                           /harness (once)
                                                |
                                          /commission (once per machine)
                                                |
           +-------------------------------> /build  <-----------------+
           |                     test -> code -> run tier -> fix ...   |
           |                                    |                      |
           |                               /wrap-up (log, push)        |
           |                                    |                      |
      /change-request <-- feel --  YOU PLAY IT (/playtest) -- bugs -----+
           ^                                    |
           +----------- numbers -------- /balance (sim runs, data/*.json)
```

1. **/pitch** - park the idea in 5 minutes. Pick the best one later.
2. **/define** - Claude interviews you one question at a time and writes the
   GDD. Every requirement gets an ID and a proof (`unit`, `sim`, `scene`,
   `visual`, `playtest`). Phase 1 is always "simulation core, no graphics".
3. **/harness** - creates the Godot project with the right structure, copies
   the runners, `CLAUDE.md`, test plan, CI workflow.
4. **/commission** - proves the setup itself works, including that a failing
   test really fails. After this, a red test means a game bug, not a setup bug.
5. **/build** - the loop. Ask for a phase or requirement IDs and walk away.
6. **/playtest** - play, ramble your notes, Claude sorts them into bugs (become
   failing tests), balance (become experiments) and feel (become CRs).
7. **/balance** - bots play thousands of games headless; Claude changes only
   JSON numbers and shows before/after tables.
8. **/change-request** - change the GDD first, then the code.
9. **/wrap-up** - always, at the end of each session.

Art runs in parallel and stays placeholder until the mechanics are fun:
**/style-guide** (from reference images) and **/asset** (SVG/procedural or
prompts for image tools, with a provenance manifest). See
[docs/07-asset-pipeline.md](docs/07-asset-pipeline.md).

---

## What stays your job

1. **Design and taste.** What's fun, what the game is about, what to cut.
2. **The requirements and the balance targets.** The agent works towards
   whatever "done" says. Vague targets get vague games.
3. **Playtesting.** Bots tell you a strategy dominates; only you can tell
   whether it's *boring*.
4. **Reviewing the test plan.** Ten minutes reading `TESTPLAN.md` is worth
   more than an hour reading code. Ask "what would prove that?" about anything
   you care about.
5. **Saying no.** The agent will happily build features. Scope fences in the
   GDD ("out of scope") protect your limited time.

## Honest limits

- **Pro usage limits are real.** A long autonomous `/build` can use up a
  5-hour window. Work in phases, keep CLAUDE.md short, filter test output (the
  runner already prints only failures). See the Pro playbook.
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
