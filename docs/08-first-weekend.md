# 08 - Your first weekend (and the daily cheat sheet)

A realistic plan for someone with a job and limited Pro usage. Each block
is roughly one evening or half a day.

## Block 1 - Main laptop (1-2 h)
1. Follow [02-setup-windows.md](02-setup-windows.md) steps 1-3.
2. `cd ~/Gamedev_WF/example/colony_sim && ./harness/gw.sh check` -> `CHECK OK`.
3. Open it in Godot, play for 2 minutes. Notice that wood piles up.
4. Read `example/colony_sim/docs/GDD.md` and `TESTPLAN.md` side by side.
   This is the format your own games will use.

## Block 2 - Agent box (1-2 h)
1. Follow [03-setup-mint.md](03-setup-mint.md).
2. From the Legion: `ssh agent@mint-dev.local`, `tmux new -A -s game`.
3. `cd ~/Gamedev_WF/example/colony_sim && superclaude`
4. Prompt: *"Run /commission on this project."* Read the resulting
   `docs/COMMISSIONING.md`.

## Block 3 - Practise the loop on the example (1-2 h)
Copy the example so you can mess with it freely:

```bash
cp -r ~/Gamedev_WF/example/colony_sim ~/games/colony-practice && cd ~/games/colony-practice && git init && ./harness/gw.sh hooks && git add -A && git commit -m "start"
```

Then in `superclaude`:
1. *"/balance - BAL-003: wood should stay useful. Target: GreedyBot wood stock
   below 500 at tick 500. Propose 2-3 options before changing anything."*
2. *"/change-request: every 60 ticks there is a winter of 15 ticks in which
   farms produce half. Show the CR first."* -> "go" -> watch it test, build, fix.
3. Pull it on the Legion and play it. Run *"/playtest"* with your raw notes.
4. *"/wrap-up"*.

You've now used the whole loop once on something small.

## Block 4 - Your own game (rest of the weekend)
1. Dump 3-5 ideas: *"/pitch"* for each one (5 min each, a voice dump is fine).
2. Pick the highest-scoring one with the cheapest prototype.
3. `mkdir ~/games/<name> && cd ~/games/<name> && superclaude`
4. *"/define"* - answer the questions. Prefer the smaller option every time.
5. Read the GDD properly. It's your contract. Fix it, then: *"/harness"*,
   *"/commission"*.
6. *"/build phase 1"* - simulation core, no graphics. Go do something else.
7. Check in, review `TESTPLAN.md`, *"/wrap-up"*.

## Daily cheat sheet

| I want to... | Say / run |
|---|---|
| park a new idea | `/pitch` + paste the ramble |
| start a project | `/define` -> `/harness` -> `/commission` |
| continue work | "Read the latest LOG entry and continue with the next step." or `/build` |
| build specific things | `/build ECO-004 ECO-005` |
| fix a bug I saw | "Write a failing test for: <what happened>, then fix it." |
| tune numbers | `/balance <what feels wrong + target>` |
| change the design | `/change-request <the wish>` |
| report a play session | `/playtest` + notes |
| art direction | put refs in `docs/style_refs/`, `/style-guide` |
| an icon/sprite | `/asset food icon, 32 px` |
| stop for today | `/wrap-up` |
| check things myself | `./harness/gw.sh check`, `./harness/gw.sh sim --seeds=1-20 --ticks=600` |
| see what the agent changed | `git log --oneline -10`, `git diff HEAD~1` |
| undo the agent's last commit | "Revert the last commit and explain what it did." |
| the setup itself seems broken (Godot, git, CI) | ask the agent first: "Something is wrong with the setup, run /commission and fix what you can." |

## Signs things are going wrong (and the fix)
| Sign | Fix |
|---|---|
| Tests changed alongside every feature | Ask why; insist on `/change-request` for expectation changes |
| One file keeps growing | "Refactor X into smaller classes, tests must stay green" |
| Same bug comes back | It had no test. "Write a regression test first" |
| Agent goes in circles | Stop it. Ask it to log what it tried; clarify the requirement yourself |
| Usage limit every evening | Smaller batches, `/clear` between tasks, fewer screenshots, shorter CLAUDE.md |
| Game works, isn't fun | That's normal and it's your job. Playtest, cut, `/change-request`. Don't add features to rescue it |
