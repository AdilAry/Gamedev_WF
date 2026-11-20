# 04 - Getting the most out of Claude Pro

Claude Pro is the "minimum wage" of your agent (the video's ~$20/month).
It includes Claude Code, but **chat and Claude Code share one usage budget**
that resets in rolling windows (a few hours) with a weekly cap on top. Plans
and limits change, so check the current details on the Claude plans page
and in `/usage` (or `/status`) inside Claude Code. These habits stretch the
budget furthest.

This playbook is about Claude Code and Claude Desktop. pi is for later; the
workflow's WORKFLOW.md §6 says why.

## What costs nothing

Worth knowing before the habits, because it changes where you spend your time:

| Free (no agent involved) | Costs usage |
|---|---|
| writing and changing `design/` | `/spec` reading your documents |
| answering `docs/QUESTIONS.md` in Obsidian | the agent asking the same thing in chat |
| editing `tests/cases/balance.json` | |
| `./harness/gw.sh cases`, `sim`, `trace`, `check` run by you | the agent reading their output (20 lines) |
| long simulation runs (hundreds of seeds) | |
| playing the build | `/playtest` sorting your notes |

## Which surface for what

| Task | Where | Why |
|---|---|---|
| Brainstorming, pitches, lore, naming, reviewing a GDD | **Claude Desktop chat / Project** with the GDD attached | no tool overhead; you're thinking, not building |
| `/spec` (your design -> requirements) | Claude Code / Code tab, strongest model you have, **one system per session** | the reading is the expensive part; the map step reads headings only |
| `/define` interview (idea only) | Claude Code (writes the files directly), or a chat Project and paste the result | it's a conversation either way |
| Building, testing, balancing | **Code tab on the Legion** (supervised, allow-list) or **the agent on the Mint box** in tmux (Claude Code, no permission prompts) | closed loop; one task per session either way |
| Small supervised edits, reading code with you | **Code tab in Claude Desktop** on Windows | you watch each step |
| Quick checks while at your job | Claude app on your phone: a chat about the design, or Claude Code on the web / Remote Control for a project on GitHub | check the current docs for what your plan includes |

## Token-saving habits (they really matter on Pro)

1. **One session = one task.** `/start <IDs>`, OK the plan, `/wrap`, check,
   then `/clear`. Long sessions re-read an ever-growing history
   on every turn. `/start` reads only the task's rows of the spec, so a fresh
   session costs little.
2. **Keep `AGENTS.md` short** (~100-150 lines). It is loaded every session. The
   template already is; resist adding essays.
3. **Point, don't paste.** "Read docs/spec/status.md" beats pasting the
   section. Don't let the agent read whole CSVs or logs: the harness prints
   compact summaries on purpose, and full logs stay in `reports/logs/`.
4. **Filter tests while iterating:** `gw.sh test unit farm`. Full `check`
   only before committing.
5. **Screenshots are expensive** (images cost far more than text). Use
   `gw.sh shot` for visual requirements, not after every change.
6. **Put worked examples in your design.** Ambiguity costs tokens: the agent
   has to stop and ask, or (worse) builds a guess. "Given this, the result is
   that" in your own document is the cheapest prompt you can write, and it
   becomes a test for free.
7. **Rewind instead of correcting.** When the agent went the wrong way, go
   back to before the attempt (Esc Esc) and
   re-prompt with what you learned. "No, try B" leaves the failed attempt in
   the context, where it is paid for on every turn and keeps steering.
   Watch the context (`/context`): around 40% full, finish the
   step and `/wrap`. Use `/compact` only when a session really must continue.
8. **Model choice:** use the default model for the build loop. Switch to the
   strongest model your plan offers (`/model`) for design-heavy or tricky
   architecture sessions, if it's included, and switch back after.
9. **The plan is built in.** Every `/start` shows a plan and waits (Gate 1).
   A bad plan found in a minute saves an hour of bad code. If the plan keeps
   being wrong, the spec rows are too vague: fix them, not the chat.
10. **Use the gaps.** While a task builds (a few minutes), answer the next
    question in `docs/QUESTIONS.md`, do a check that is "awaiting my check",
    or play the previous build.

## When the limit hits mid-task
That's why `/wrap` exists. If you see a usage warning, type `/wrap` with a
note on where things stand. PROGRESS.md and the commit let the next window
continue cleanly.
If the agent stops mid-edit, the next session runs `gw.sh check` first and
reads `PROGRESS.md`; git shows exactly what changed (`git diff`).

## Prompts that work (talk to it like an employee, as the video says)

- "/spec" (first time: the map of my design documents, nothing else).
- "/spec status effects" then, after answering in the file: "/spec questions answered".
- "/start STA-004 STA-005" -> read the plan -> "OK" -> "/wrap" -> check -> clear.
- "/start" (nothing else: it takes "Next" from PROGRESS.md).
- "/start UNI-010 to UNI-014, same pattern as UNI-008. Run limit 50 for this task."
- "/qa status effects" - "show me the worst seed as a trace".
- "/start the farm test fails on seed 7 only: find out why and explain it
  to me; the fix is a separate task."
- "/balance: wood piles up after tick 200. Target: wood stock below 500 at
  tick 500 with the greedy bot. Show me options; I pick."
- "Take the screenshot of the main scene and tell me what a new player
  would not understand."
- "Prepare a change request: winter every 60 ticks halves farm output.
  Show me the CR before implementing."
- "Update documentation and push." (= `/wrap`)
