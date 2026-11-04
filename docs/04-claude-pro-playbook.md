# 04 - Getting the most out of Claude Pro

Claude Pro is the "minimum wage" of your agent (the video's ~$20/month).
It includes Claude Code, but **chat and Claude Code share one usage budget**
that resets in rolling windows (a few hours) with a weekly cap on top. Plans
and limits change, so check the current details on the Claude plans page
and in `/usage` (or `/status`) inside Claude Code. These habits stretch the
budget furthest.

## Which surface for what

| Task | Where | Why |
|---|---|---|
| Brainstorming, pitches, lore, naming, reviewing a GDD | **Claude Desktop chat / Project** with the GDD attached | no tool overhead; you're thinking, not building |
| `/define` interview | Claude Code (writes the files directly), or a chat Project and paste the result | it's a conversation either way |
| Building, testing, balancing | **Claude Code on the Mint box** (`superclaude` in tmux) | closed loop, no permission prompts, runs unattended |
| Small supervised edits, reading code with you | **Code tab in Claude Desktop** on Windows | you watch each step |
| Quick checks while at your job | Claude app on your phone: a chat about the design, or Claude Code on the web / Remote Control for a project on GitHub | check the current docs for what your plan includes |

## Token-saving habits (they really matter on Pro)

1. **One session = one phase or one batch.** Start the session, run
   `/build <IDs>`, `/wrap-up`, then `/clear` (or a new session). Long sessions
   re-read an ever-growing history on every turn.
2. **Keep `CLAUDE.md` short** (~100-150 lines). It is loaded every session. The
   template already is; resist adding essays.
3. **Point, don't paste.** "Read docs/GDD.md section 6.2" beats pasting the
   section. Don't let the agent read whole CSVs or logs: the harness prints
   compact summaries on purpose, and full logs stay in `reports/logs/`.
4. **Filter tests while iterating:** `gw.sh test unit farm`. Full `check`
   only before committing.
5. **Screenshots are expensive** (images cost far more than text). Use
   `gw.sh shot` for visual requirements, not after every change.
6. **Write good requirements.** Ambiguity costs tokens: the agent explores,
   guesses, gets corrected, redoes. A clear proof column is the cheapest
   prompt you can write.
7. **Use `/compact`** when a session must continue but has grown long, and
   `/resume` (or `claude --continue`) to pick up the last session instead of
   re-explaining.
8. **Model choice:** use the default model for the build loop. Switch to the
   strongest model your plan offers (`/model`) for design-heavy or tricky
   architecture sessions, if it's included, and switch back after.
9. **Plan before big work:** for a new phase, ask for a plan first (plan
   mode, Shift+Tab in Claude Code), check it, then let it run. A bad plan
   found in 2 minutes saves an hour of bad code.
10. **Batch your evening:** start a long `/build` on the Mint box, and while
    it runs, spend your own time playtesting the *previous* build on the
    Legion. Two things progress at once.

## When the limit hits mid-task
That's why `/wrap-up` exists. If you see a usage warning, say
"wrap up now". The log and commit let the next window continue cleanly.
If the agent stops mid-edit, the next session runs `gw.sh check` first and
reads the log; git shows exactly what changed (`git diff`).

## Prompts that work (talk to it like an employee, as the video says)

- "Read CLAUDE.md and the latest LOG entry. Then /build phase 2. Stop and ask
  if a requirement is unclear; otherwise don't ask, just log assumptions."
- "The farm test fails on seed 7 only. Add debug prints in the sim, find out
  why, explain it to me before fixing."
- "/balance: wood piles up after tick 200. Target: wood stock below 500 at
  tick 500 with the greedy bot. Only change data/rules.json."
- "Take the screenshot of the main scene and tell me what a new player
  would not understand."
- "Prepare a change request: winter every 60 ticks halves farm output.
  Show me the CR before implementing."
- "Update documentation and push." (= `/wrap-up`)
