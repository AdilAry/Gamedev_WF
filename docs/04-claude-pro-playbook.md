# 04 - Getting the most out of Claude Pro

Claude Pro is the "minimum wage" of your agent (the video's ~$20/month).
It includes Claude Code, but **chat and Claude Code share one usage budget**
that resets in rolling windows (a few hours) with a weekly cap on top. Plans
and limits change, so check the current details on the Claude plans page
and in `/usage` (or `/status`) inside Claude Code. These habits stretch the
budget furthest.

**pi is not covered by this budget.** Signed in with a Claude subscription,
pi is billed per token on top of the plan (pi says so at startup). Your Pro
allowance is spent in Claude Desktop and Claude Code. See [10-pi.md](10-pi.md).

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
| Building, testing, balancing | **Code tab on the Legion** (supervised, allow-list) or **the agent on the Mint box** in tmux (Claude Code or pi, no permission prompts) | closed loop; short slices either way |
| Small supervised edits, reading code with you | **Code tab in Claude Desktop** on Windows | you watch each step |
| Quick checks while at your job | Claude app on your phone: a chat about the design, or Claude Code on the web / Remote Control for a project on GitHub | check the current docs for what your plan includes |

## Token-saving habits (they really matter on Pro)

1. **One session = a few slices of one system.** Start the session, run
   `/build <IDs>`, say "next" two or three times, `/wrap`, then `/clear`
   (pi: `/new`). Long sessions re-read an ever-growing history on every turn.
   Staying inside one system means one spec file is read once.
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
   back to before the attempt (Claude Code: Esc Esc; pi: `/tree`) and
   re-prompt with what you learned. "No, try B" leaves the failed attempt in
   the context, where it is paid for on every turn and keeps steering.
   Watch the context (`/context`; pi's footer): around 40% full, finish the
   step and `/wrap`. Use `/compact` only when a session really must continue.
8. **Model choice:** use the default model for the build loop. Switch to the
   strongest model your plan offers (`/model`) for design-heavy or tricky
   architecture sessions, if it's included, and switch back after.
9. **Plan before big work:** for a new phase, ask for a plan first (plan
   mode, Shift+Tab in Claude Code), check it, then let it run. A bad plan
   found in 2 minutes saves an hour of bad code.
10. **Use the gaps.** While a slice builds (a few minutes), answer the next
    question in `docs/QUESTIONS.md` or play the previous build. When a batch
    is truly ready (no open questions, examples in the spec, a pattern you
    already approved), let it run on the Mint box while you are away:
    [09-loops.md](09-loops.md) has the conditions.

## When the limit hits mid-task
That's why `/wrap` exists. If you see a usage warning, say
"wrap up now". The log and commit let the next window continue cleanly.
If the agent stops mid-edit, the next session runs `gw.sh check` first and
reads `PROGRESS.md`; git shows exactly what changed (`git diff`).

## Prompts that work (talk to it like an employee, as the video says)

- "/spec" (first time: the map of my design documents, nothing else).
- "/spec status effects" then, after reading it: "questions answered".
- "/build STA-004 STA-005" -> read the planned tests -> "go" -> "next".
- "/build STA-006 go" (I trust the spec's examples; skip the test preview).
- "/build batch UNI-010..UNI-025" (the remaining units; same pattern as the
  two I reviewed).
- "/qa status effects" - "show me the worst seed as a trace".
- "The farm test fails on seed 7 only. Add debug prints in the sim, find out
  why, explain it to me before fixing."
- "/balance: wood piles up after tick 200. Target: wood stock below 500 at
  tick 500 with the greedy bot. Show me options; I pick."
- "Take the screenshot of the main scene and tell me what a new player
  would not understand."
- "Prepare a change request: winter every 60 ticks halves farm output.
  Show me the CR before implementing."
- "Update documentation and push." (= `/wrap`)
