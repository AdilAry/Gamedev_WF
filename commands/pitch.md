---
description: Turn a rough game idea into a one-page pitch with the smallest playable prototype and an honest scope estimate, filed in the ideas inbox. Use when the user has a new idea to park, compare or triage.
argument-hint: the idea, however rough
---
# /pitch - capture and triage a game idea

Request: $ARGUMENTS

The user has more ideas than time. Your job is to make each idea cheap to
store, easy to compare, and honest about size. Do NOT start designing in depth
(that is /define) and do NOT write game code.

## Steps

1. **Read the raw idea.** It may be messy. If the user pasted nothing, ask for
   the idea in one message: "Describe it however you like - even voice-to-text."

2. **Ask at most 3 short questions**, one at a time, only if the answer changes
   the scope a lot (e.g. "single-player only?", "real-time or turn-based?").
   If the user says "you decide", choose the smaller option and say so.

3. **Write `ideas/<kebab-title>.md`** (create the `ideas/` folder if needed;
   if the user keeps ideas in Obsidian, write it where they say, with
   their front-matter style: `created: YYYY.MM.DD`, `tags:`). Use this structure:

   ```markdown
   ---
   created: YYYY.MM.DD
   status: pitched
   tags: idea
   ---
   # <Title>
   > One sentence: "A <genre> where you <verb> to <goal>, but <tension>."

   ## Player fantasy
   ## Core loop (seconds / minutes / session)
   ## What makes it interesting (the one mechanic to prototype)
   ## Smallest playable prototype (an evening to a weekend)
   - 3-6 bullet points, no art, no menus, no save/load
   ## Scope estimate
   | Piece | Size (S/M/L/XL) | Risk | Note |
   ## Riskiest assumption
   The thing that, if it isn't fun, kills the idea. The prototype must test it.
   ## Score
   | Excitement (1-5) | Prototype cost (1-5, 5 = cheap) | Fits my skills/hardware (1-5) | Total |
   ## Related ideas
   ```

4. **Be honest about scope.** Red flags to call out in any genre:
   multiplayer, 3D characters with animation, narrative with branching
   dialogue. For strategy/sim also: procedural worlds with many interacting
   systems, real-time with hundreds of units on a GTX 1650 / integrated
   graphics. Suggest the cut that keeps the core.

5. If several ideas exist in `ideas/`, offer to update `ideas/INDEX.md` - a
   table sorted by Total score with one line per idea.

6. End with: the next step is either "park it" or "run /define on it".
