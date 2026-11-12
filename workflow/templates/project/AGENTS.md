# AGENTS.md: [project name]

Loaded in every session, by every agent (`CLAUDE.md` only imports this file). Keep it under ~80 lines: only what every session needs. Everything else lives in docs/, behind "Read only when needed".

## Project
- **What:** [one line].
- **Mode:** [ship | learn | learn for the area named here, ship for the rest]. The modes are defined in my user-level instructions.
- **Second machine:** [no role in this project | its role, e.g. test box or budget-hardware tests].
- **Not doing:** [e.g. login, payments, native app].

## Stack
- **Language and tools:** [e.g. Python 3.12 + Streamlit | C + PlatformIO | Godot 4 + GDScript].
- **Run:** `[command that starts it, in a fresh terminal]`
- **Check:** `[the command that says whether it works: tests, build, linter]`. Run it before calling anything done.
- **Hardware:** [none | board, notes file in docs/].
- **Deploy:** [local only | where].

## Workflow
- One slice per session: `start <task>` begins it, `wrap` ends it. A slice is one thing I can check: small enough to finish with the context under about half full.
- `start` shows a plan and the checks before any file changes; wait for my OK.
- PROGRESS.md holds the current state only, under ~60 lines. Finished work goes to docs/history.md. A fresh session must be able to continue from PROGRESS.md alone.
- Something only I can decide goes under "Waiting on me" in PROGRESS.md; don't guess, work on something else.
- After each slice, tell me how to check it and the output I should see.
- `git pull` before starting. Run Check before every commit. [Commit and push to main | one branch per milestone].

## Read only when needed
| File | Read when |
|---|---|
| `docs/plan.md` | starting a milestone: its section only |
| `docs/decisions.md` | a decision is questioned or about to change |
| `docs/history.md` | I ask what happened earlier |
| `docs/notes/` | the task needs a source summarised there |
| [another file] | [when] |

## Files
```
[entry point, e.g. app.py | src/main.c | project.godot]   [what it is]
core/          [logic, no UI code]
tests/         what the Check command runs
docs/          plan, history, decisions; notes/ holds short summaries of long sources
out/           long output and commit messages (gitignored)
[other folder] [what lives there]
```
