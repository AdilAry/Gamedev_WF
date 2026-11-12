# The short-loop workflow (any software project)

How to work with a coding agent in short sessions, with files carrying the
memory between them. This is the general workflow; the Gamedev-WF kit is this
workflow plus a Godot harness and game-specific skills. It is version 2 of
your own `WORKFLOW.md`: section 9 says what changed and why.

Works in Claude Code, the Code tab of Claude Desktop and pi. As of November
2026; check the agent's docs if a command behaves differently.

---

## 1. The idea

A session gets worse as its context fills up. So each session does one slice
of work and ends, and the next one starts clean and reads what it needs from
files. That only works if the files that are read every time stay small. So
files are split by **how often they are read**:

| File | Holds | Loaded | Size | Edited by |
|---|---|---|---|---|
| user-level instructions | About me, my machines, the two modes, rules for every project | Every session, every project | ~50 lines | Me, once |
| `AGENTS.md` (`CLAUDE.md` imports it) | What every session in this project needs: stack, Run, Check, workflow, read-when table | Every session in this project | under ~80 lines (a game: ~120) | Me at setup; the agent only when I ask |
| `PROGRESS.md` | Current state only | Start of every session | under ~60 lines | Agent, at wrap |
| `docs/plan.md` | Milestones as lists of slices | At a milestone's start, its section only | Any | Me at setup |
| `docs/history.md` | Finished milestones and reviews | Only when asked | Any (append only) | Agent |
| `docs/decisions.md` | Decisions with reasons and rejected options | When a decision is questioned | Any | Agent |
| `docs/notes/` | Short summaries of long sources (specs, datasheets) | When a task needs one | Short each | Agent (often a subagent) |
| profile files (`docs/brief.md`, `docs/data.md`, a game's `docs/spec/`...) | What one kind of project needs | Per the read-when table | Any | Per profile |
| skills `start`, `wrap`, `review` | The session routine | When I type them | Short | The kit, once for all projects |

Sizes are rough guides. To see the real cost in Claude Code, run `/context`
at the start of a session; pi shows context use in its footer.

**Six rules that keep the files small:**
1. **PROGRESS.md is a snapshot, not a log.** Wrap rewrites "Now" and "Next" every session.
2. **Delete, don't strike through.** Once something is resolved it leaves PROGRESS.md; history.md keeps the record.
3. **Point, don't paste.** Long material lives in `docs/`, and AGENTS.md says when to read it.
4. **One fact, one place.** If two files say it, one of them will go stale.
5. **Rules for every project go in the user-level file once.**
6. **Behaviour lives in skills, facts live in the project.** The routine (`start`, `wrap`, `review`) is installed once and updated once. A project's files hold only what is true for that project.

---

## 2. Setup

**Once per machine:**

```bash
~/Gamedev_WF/scripts/install.sh
```

That installs the skills for Claude Code and, if pi is present, for pi. Then
copy `templates/user-level/AGENTS.md`, fill its brackets, and put it where
your agent reads user-level instructions: `~/.claude/CLAUDE.md` for Claude
Code (on Windows `%USERPROFILE%\.claude\CLAUDE.md`), `~/.pi/agent/AGENTS.md`
for pi. Using both agents: keep one real file and make the other a copy you
refresh when it changes; the file is short and changes rarely.

**Per project:**
1. Copy everything in `templates/project/` into the repo root.
2. If a profile fits, follow its README (`templates/profiles/hackathon/`). A
   game uses the Gamedev-WF skills instead (`/spec`, `/harness`), which create
   these same files.
3. Fill in AGENTS.md and docs/plan.md. Delete what doesn't apply.
4. Run the bracket check until it finds nothing:

```bash
grep -n '\[' AGENTS.md docs/plan.md
```

5. `/start M0` (pi: `/skill:start M0`).

Markers in the templates: `[text]` fill in; `[value]` a default to keep or
change; `[a | b | c]` choose one; `[IF condition]` keep the line only if it
holds. The templates contain no other square brackets, so any `[` left in a
file you filled in means something is unfinished. In the files the agent
maintains (PROGRESS.md, history.md, decisions.md) the brackets only show the
format.

---

## 3. A session

**Start:** `/start <task>`. The agent pulls, reads PROGRESS.md and the
milestone's section of plan.md, and proposes a plan of at most 5 bullets,
including **the checks**: which tests it will add and what each expects. You
correct it or say OK. This is the cheapest moment to catch a misunderstanding.

**Work.** One slice: one thing you can check, finished with the context under
about half full. Habits that keep the context clean:
- **Wrong path? Rewind** (Claude Code: Esc Esc; pi: `/tree`) to before the
  attempt and re-prompt with what you learned. A correction leaves the failed
  attempt in context, where it keeps steering the agent.
- **Watch the context.** Around 40% full, finish the current step and wrap.
- **Big reading** (a spec, a datasheet, another codebase): ask for a summary
  into `docs/notes/`, by a subagent if your agent has them. Later sessions
  read the note, not the source.
- **Side question** in Claude Code: `/btw`, which doesn't add to the conversation.
- **Run it yourself:** `!` + a command runs it without the agent spending a
  turn on it (pi: `!!` keeps the output out of the context entirely).
- **Same mistake twice:** stop. Wrap, clear, and start fresh with what you learned in the first prompt.

**End:** `/wrap`. It runs Check, rewrites PROGRESS.md, records dead ends and
what is waiting on you, appends to history.md only if something finished,
commits, and tells you what to run and what output to expect. Then check it
and clear the session (`/clear`; pi: `/new`). Ending mid-slice is fine: wrap
records exactly where it stopped.

---

## 4. Reviews with fresh eyes

`/review` runs in a **new session**. A reviewer that watched the work being
built ends up grading its own work. It reads the diff against the plan and
the rules, ranks issues by value per hour, and fixes nothing; you pick. Run
it after each milestone. For a second opinion from a different model, run the
same skill in another agent on the same repository.

Deadline projects (hackathon profile) also have `/judge`: the project through
the eyes of the person it is for, scored against the brief.

---

## 5. Modes

Each project's AGENTS.md picks **ship** (the agent writes the code, you review
and check) or **learn** (you write the core logic; the agent explains, writes
scaffolding and tests, leaves `TODO(human)`, reviews without rewriting). The
definitions live once, in the user-level file. "Learn for the area named
here, ship for the rest" is often the right choice.

---

## 6. Profiles

The core above is the same for every project. A profile adds what one kind of
project needs, in files that are read only when relevant.

| Project | Profile | Check command | Adds |
|---|---|---|---|
| Hackathon, data app, client demo | `templates/profiles/hackathon/` | `pytest` or the stack's tests | brief, time budget, data rules, AI log, judge pass, freeze |
| Game (Godot) | the Gamedev-WF kit: `/spec` or `/define`, then `/harness` | `./harness/gw.sh check` | design/, specs with worked examples, question queue, test tiers, balance cases, `/build`, `/qa` |
| Embedded | none yet: core + notes | host-side tests (e.g. `pio test -e native`) plus the build | put the pin map and errata in `docs/hardware.md` with a read-when row; flashing and measuring stay yours |
| Learning project | core, `Mode: learn` | the exercise's tests | nothing |
| Comics, writing, art | this workflow doesn't fit | none | use a Claude Project with critique-only instructions |

---

## 7. When things go wrong

| Symptom | Fix |
|---|---|
| A session starts at 15%+ context | Trim AGENTS.md and PROGRESS.md; move detail to `docs/`. Check which plugins and MCP servers are loaded: each one's tools are paid for in every session. |
| The agent works from stale information | PROGRESS.md contradicts itself: rewrite "Now" and "Next", delete resolved items. |
| Auto-compact fired | Finish the current step, wrap, start fresh. The slice was too big. |
| A milestone doesn't fit in one session | It shouldn't: a milestone is a list of slices. Split the slice that didn't fit. |
| The same mistake keeps coming back | It wasn't in "Dead ends". If it comes back across projects, add one line to the user-level file. Remove rules again once models stop needing them. |
| The agent keeps asking what to do next | "Next" in PROGRESS.md isn't concrete enough to start from. |
| Wrap takes long | It is doing unconditional work. Only PROGRESS.md and the commit happen every time. |

---

## 8. Files in this folder

```
templates/user-level/AGENTS.md      about you, machines, modes, rules everywhere
templates/project/                  AGENTS.md, CLAUDE.md, PROGRESS.md, docs/plan.md, history.md, decisions.md
templates/profiles/hackathon/       brief, deadline plan, data rules, AI log
../.claude/skills/start|wrap|review|judge   the routine (installed by scripts/install.sh)
```

---

## 9. What changed from version 1, and why

Version 1 is the `WORKFLOW.md` you wrote after LoadLedger. Its core is kept
as it was: files split by how often they are read, PROGRESS.md as a
snapshot, a plan before code, a fixed end-of-session routine, reviews in a
fresh session, the learn and ship modes, the bracket markers.

| Version 1 | Version 2 | Why (against your three goals) |
|---|---|---|
| `/start`, `/wrap`, `/judge` as Claude Code commands, copied into every project | Skills, installed once per machine | **Updatable:** a fix reaches every project at once, and old projects cannot drift. **General:** the same files work in pi and other agents; no second copy as prompt templates. |
| `CLAUDE.md` holds everything; `AGENTS.md` "later" | `AGENTS.md` from day one, `CLAUDE.md` is the one-line import | **Updatable:** switching or mixing agents costs nothing. Your tools note already recommended this; the templates now do it. |
| Project CLAUDE.md (up to ~120 lines) includes the brief: who it is for, problem, concept, look, demo moment | AGENTS.md (~80 lines) keeps stack, Run, Check, workflow, read-when. The brief moves to `docs/brief.md` | **Tokens:** by your own first rule, the brief is not read every session; it is read for user-facing work and by the judge. This roughly halves what every session loads. |
| One template shaped like a hackathon data app; other projects delete sections | A core every project shares, plus profiles | **General:** generality by adding a profile, not by deleting someone else's sections. A game or a firmware project never sees "Judged on", "Hand-in" or "Freeze". |
| The unit of a session is a milestone; if it doesn't fit, split it afterwards | The unit is a slice; a milestone is a list of slices in plan.md | **Short loop:** a 4-hour milestone was never going to fit one session below 40% context. Sizing happens at planning time, not after an auto-compact. |
| The plan says "how I'll check the result" | The plan names the checks before code: tests and what each expects | **Human in the loop:** you approve expected results, which takes a minute and needs no code reading. A value the agent would have to invent becomes a question. |
| Failed approaches live in your head after a rewind or clear | "Dead ends" in PROGRESS.md, at most 5 lines | **Tokens:** the next fresh session does not rediscover the same wall. Your tools note listed dead ends as part of the hand-off; the template had no place for them. |
| Wrap always walks through history, decisions and the AI log | Wrap does the snapshot and the commit every time; the rest only when something happened | **Tokens:** short loops mean more wraps, and wrap runs when the context is fullest. |
| PROGRESS.md has a "Done" list and a "Time" table that grow | Neither in the core. History is in history.md and git; time tracking is in the hackathon profile | Rule 1: a snapshot does not grow. |
| `/judge` is the only review | `/review` (general, code and structure) plus `/judge` (hackathon profile) | **General:** most projects have no judge, but all of them drift. |

Not carried over into the kit: your `efficient-ai-tools.md`. It is a personal
tool list rather than part of the workflow, and I did not verify the
third-party plugins it names. One caution from the workflow's own logic: every
plugin and MCP server adds tool definitions that are loaded in every session,
so each one should earn its place the way a line in AGENTS.md has to.
