# 08 - Your first weekend (and the daily cheat sheet)

A realistic plan for someone with a job and limited Pro usage. Each block
is roughly one evening or half a day.

## Block 1 - Main laptop (1-2 h, no AI usage)
1. Follow [02-setup-windows.md](02-setup-windows.md) steps 1-3.
2. `cd ~/Gamedev_WF/example/colony_sim && ./harness/gw.sh check` -> `CHECK OK`.
3. Open it in Godot, play for 2 minutes. Notice that wood piles up.
4. See the same thing as numbers, then as a story:

```bash
./harness/gw.sh cases
```

```bash
./harness/gw.sh trace --seed=3 --ticks=300
```

5. Read `example/colony_sim/AGENTS.md`, `PROGRESS.md`, `docs/GDD.md`,
   `docs/TESTPLAN.md` and `tests/cases/balance.json`. This is the format your
   own games will use (bigger games get one spec file per system).

## Block 2 - Agent box (1-2 h)
1. Follow [03-setup-mint.md](03-setup-mint.md).
2. Open the user-level file the installer created (`~/.claude/CLAUDE.md`) and
   fill its one bracket.
3. Copy the example out of the kit. An agent started inside the kit folder
   would also load the kit's own AGENTS.md, which is about maintaining the kit:

```bash
mkdir -p ~/games && cp -r ~/Gamedev_WF/example/colony_sim ~/games/colony-practice && cd ~/games/colony-practice && git init -q && ./harness/gw.sh hooks && git add -A && git commit -q -m "start"
```

4. Start Claude Code there (`superclaude`) and type `/commission`.
   Read the resulting `docs/COMMISSIONING.md`.

## Block 3 - Practise the loop on the copy (1-2 h)
One command per session; clear the session (`/clear`) between them.
1. `/qa` - it plays the game with bots and writes a report. Check that it
   found the wood problem and did not change anything.
2. `/balance wood piles up; target wood below 500 at tick 500 for the greedy bot` -
   it comes back with options and a before/after table. **You** pick one.
   Then it edits `data/rules.json`. `/wrap`.
3. `/change-request every 60 ticks there is a winter of 15 ticks in which farms produce half` -
   read the CR, say "go". `/wrap`.
4. `/start CR-001` - Gate 1: read the plan (the tests with their expected
   numbers, and "done when"). OK it. When it reports, `/wrap`, then run what
   it tells you to run. That was Gate 2.
5. Pull it on the Legion and play it. `/playtest` with your raw notes.

You've now used the whole loop once on something small, and you know what the
two gates feel like.

## Block 4 - Your own game (rest of the weekend, and the weeks after)
You design in documents already, so start from them.

1. Create the folder outside the kit and outside any other project:
   `mkdir -p ~/games/<name>/design && cd ~/games/<name> && git init`
2. Copy the design documents **for the part you want playable first** into
   `design/`. Not the whole archive: combat rules and three units, not the
   monetisation notes. Old and superseded drafts stay out (or go in
   `design/old/`, and tell the agent to ignore that folder).
3. `/spec` - you get a map: which file belongs to which system, which notes
   seem to amend which, a suggested build order. Correct it.
4. `/spec <first system>` - read `docs/spec/<system>.md`. Every row should
   be something you recognise from your own text. Then open
   `docs/QUESTIONS.md` in Obsidian and answer. Expect many questions the
   first time; that is the command working. Then `/spec questions answered`.
5. `/harness`, then `/commission` (each in its own session).
6. `/start` - it takes the first task from PROGRESS.md. Gate 1, OK, it
   works, `/wrap`, Gate 2, clear. Two to four tasks is a normal evening.
7. When a system is done: `/qa <system>`, add the situations you care
   about to `tests/cases/balance.json`, and in a new session `/judge`.

Only an idea, no documents? `/pitch`, then `/define` instead of steps 2-4.

## Daily cheat sheet

| I want to... | Type / run |
|---|---|
| park a new idea | `/pitch` + the ramble |
| see what the agent makes of my design docs | `/spec` (map), `/spec <system>` |
| tell the agent I answered its questions | `/spec questions answered` |
| set a project up | `/spec` -> `/harness` -> `/commission` |
| continue work | `/start` (takes "Next" from PROGRESS.md) |
| build specific things | `/start STA-004 STA-005` |
| fix a bug I saw | `/start <what happened>` (the plan starts with a test that reproduces it) |
| several repeat requirements in one task | `/start UNI-010 to UNI-014, same pattern as UNI-008. Run limit 50 for this task.` ([09-loops.md](09-loops.md)) |
| end the session | `/wrap`, then do the check it names, then clear |
| have the agent playtest | `/qa` or `/qa <system>` |
| see my balance situations | `./harness/gw.sh cases` (no agent needed) |
| watch one run | `./harness/gw.sh trace --seed=7 --ticks=300` |
| tune numbers | `/balance <what feels wrong + target>` -> pick an option |
| change the design | edit `design/`, then `/change-request <what changed>` |
| report a play session | `/playtest` + notes |
| a second look at finished work | new session, `/judge` |
| see where the project stands, without an agent | open `PROGRESS.md` |
| art direction | put refs in `docs/style_refs/`, `/style-guide` |
| an icon/sprite | `/asset food icon, 32 px` |
| check things myself | `./harness/gw.sh check` |
| see what the agent changed | `git log --oneline -10`, `git diff HEAD~1` |
| make sure nobody touched my design | `git log --oneline -- design/` |
| the setup itself seems broken (Godot, git, CI) | `/commission` |

## Signs things are going wrong (and the fix)
| Sign | Fix |
|---|---|
| The spec contains a rule you never wrote | Say so; it must be removed or become a question. Check the row's `source` |
| The plan at Gate 1 has a number you don't recognise | Ask where it comes from. No worked example in the spec means it should have been a question |
| The agent hits the Run limit | The task is too big or its "done when" too far away. Split it |
| "Waiting on me" piles up | You're not checking. Nothing there counts as done; check before starting more |
| Tests changed alongside every feature | Ask why; insist on `/change-request` for expectation changes. `/judge` looks for exactly this |
| One file keeps growing | `/start refactor X into smaller classes, tests must stay green` |
| Same bug comes back | It had no test. The fix task starts with the test that reproduces it |
| Usage limit every evening | One task per session and clear between; fewer screenshots; a shorter AGENTS.md; answer questions in the file instead of in chat |
| `docs/QUESTIONS.md` keeps growing | The design for that system is not ready to build. Design more, build something else |
| Game works, isn't fun | That's normal and it's your job. Playtest, cut, `/change-request`. Don't add features to rescue it |
