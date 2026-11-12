# 08 - Your first weekend (and the daily cheat sheet)

A realistic plan for someone with a job and limited Pro usage. Each block
is roughly one evening or half a day. Skills are written as `/build`; in pi
type `/skill:build`.

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

5. Read `example/colony_sim/docs/GDD.md`, `TESTPLAN.md` and
   `tests/cases/balance.json` side by side. This is the format your own
   games will use (bigger games get one spec file per system).

## Block 2 - Agent box (1-2 h)
1. Follow [03-setup-mint.md](03-setup-mint.md). If you want pi there, also
   [10-pi.md](10-pi.md) (read its cost section first).
2. From the Legion: `ssh agent@mint-dev.local`, `tmux new -A -s game`.
3. `cd ~/Gamedev_WF/example/colony_sim`, start your agent (`superclaude` or `pi`).
4. Prompt: *"Run /commission on this project."* Read the resulting
   `docs/COMMISSIONING.md`.

## Block 3 - Practise the loop on the example (1-2 h)
Copy the example so you can mess with it freely:

```bash
cp -r ~/Gamedev_WF/example/colony_sim ~/games/colony-practice && cd ~/games/colony-practice && git init && ./harness/gw.sh hooks && git add -A && git commit -m "start"
```

Then, with the agent in that folder:
1. *"/qa"* - it plays the game with bots and writes a report. Check that it
   found the wood problem and did not change anything.
2. *"/balance - BAL-003: wood should stay useful. Target: wood below 500 at
   tick 500 for the greedy bot."* It comes back with options and a
   before/after table. **You** pick one. Then it edits `data/rules.json`.
3. *"/change-request: every 60 ticks there is a winter of 15 ticks in which
   farms produce half."* Read the CR, say "go", read the planned tests, say
   "go" again, read the report.
4. Pull it on the Legion and play it. Run *"/playtest"* with your raw notes.
5. *"/wrap"*.

You've now used the whole loop once on something small, and you know what the
two checkpoints feel like.

## Block 4 - Your own game (rest of the weekend, and the weeks after)
You design in documents already, so start from them.

1. `mkdir -p ~/games/<name>/design && cd ~/games/<name> && git init`
2. Copy the design documents **for the part you want playable first** into
   `design/`. Not the whole archive: combat rules and three units, not the
   monetisation notes. Old and superseded drafts stay out (or go in
   `design/old/`, and tell the agent to ignore that folder).
3. *"/spec"* - you get a map: which file belongs to which system, which notes
   seem to amend which, a suggested build order. Correct it.
4. *"/spec <first system>"* - read `docs/spec/<system>.md`. Every row should
   be something you recognise from your own text. Then open
   `docs/QUESTIONS.md` in Obsidian and answer. Expect many questions the
   first time; that is the skill working. Say *"questions answered"*.
5. *"/harness"*, then *"/commission"*.
6. *"/build"* - the first slice. Read the tests it proposes, "go", read the
   report, try the "see it yourself" command. Then "next". Two to four slices
   is a normal evening.
7. When a system is done: *"/qa <system>"*, and add the situations you care
   about to `tests/cases/balance.json`.
8. *"/wrap"* at the end of every session. After a finished system, in a new
   session: *"/review"*.

Only an idea, no documents? `/pitch`, then `/define` instead of steps 2-4.

## Daily cheat sheet

| I want to... | Say / run |
|---|---|
| park a new idea | `/pitch` + paste the ramble |
| see what the agent makes of my design docs | `/spec` (map), `/spec <system>` |
| tell the agent I answered its questions | "questions answered" |
| start a project | `/spec` -> `/harness` -> `/commission` |
| continue work | `/build` (takes the next unblocked slice), then "next" |
| build specific things | `/build STA-004 STA-005` |
| skip the test preview for an obvious slice | `/build STA-006 go` |
| let repeat work run unattended | `/build batch UNI-010..UNI-025` ([09-loops.md](09-loops.md)) |
| have the agent playtest | `/qa` or `/qa <system>` |
| see my balance situations | `./harness/gw.sh cases` (no agent needed) |
| watch one run | `./harness/gw.sh trace --seed=7 --ticks=300` |
| fix a bug I saw | "Write a failing test for: <what happened>, then show me before fixing." |
| tune numbers | `/balance <what feels wrong + target>` -> pick an option |
| change the design | edit `design/`, then `/change-request <what changed>` |
| report a play session | `/playtest` + notes |
| art direction | put refs in `docs/style_refs/`, `/style-guide` |
| an icon/sprite | `/asset food icon, 32 px` |
| work on something that is not a requirement (a bug, a refactor, tooling) | `/start <task>` |
| stop for today | `/wrap` |
| a second look at finished work | new session, `/review` |
| see where the project stands, without an agent | open `PROGRESS.md` |
| check things myself | `./harness/gw.sh check` |
| see what the agent changed | `git log --oneline -10`, `git diff HEAD~1` |
| make sure nobody touched my design | `git log --oneline -- design/` |
| undo the agent's last commit | "Revert the last commit and explain what it did." |
| the setup itself seems broken (Godot, git, CI) | "Something is wrong with the setup, run /commission and fix what you can." |

## Signs things are going wrong (and the fix)
| Sign | Fix |
|---|---|
| The spec contains a rule you never wrote | Say so; it must be removed or become a question. Check the row's `source` |
| The agent stopped asking questions | Either your design is complete, or it is guessing. Ask: "list every assumption you made in this slice" |
| Tests changed alongside every feature | Ask why; insist on `/change-request` for expectation changes |
| One file keeps growing | "Refactor X into smaller classes, tests must stay green" |
| Same bug comes back | It had no test. "Write a regression test first" |
| Agent goes in circles | Stop it. Ask it to log what it tried; clarify the requirement yourself |
| Usage limit every evening | One system per session, `/clear` (pi: `/new`) between tasks, fewer screenshots, shorter AGENTS.md, answer questions in the file instead of in chat |
| `docs/QUESTIONS.md` keeps growing | The design for that system is not ready to build. Design more, build something else |
| Game works, isn't fun | That's normal and it's your job. Playtest, cut, `/change-request`. Don't add features to rescue it |
