---
description: Interview the user one question at a time and turn a game idea into a Game Design Document with requirement IDs and proofs. Use only when there are no design documents yet and the user says define, GDD, or wants an idea specified.
argument-hint: the idea, or empty to be asked
---
# /define - idea to testable Game Design Document

Request: $ARGUMENTS

**First check which situation this is.** If the user already has design
documents (a `design/` folder, a pile of notes or drafts they point to), this
is the wrong command: their documents are the design, and an interview would
make them repeat it. Put the files in `design/` and use `/spec` instead.
`/define` is for the other case: there is only an idea, and the user wants to
be asked the right questions.

This is the "functional specification" step. Output: `docs/IDEA.md` (if
missing) and `docs/GDD.md`, following the template in the Gamedev-WF kit
(`$GAMEDEV_WF/harness/templates/GDD.md`; if `$GAMEDEV_WF` is unset, ask the
user where the kit is and suggest running its installer).

## 0. Investigate first (optional, offer it)
The embedded workflow researches the hardware and protocols before writing
the spec. The game equivalent: if the idea leans on a known mechanic, genre
convention or real-world system (e.g. "supply lines like Hearts of Iron",
"queueing at a harbour", "Lanchester combat", "logistic population growth"),
offer to research it first and write a short `docs/ref/<topic>.md`: how it
works, the formulas or rules, typical numbers, what players like and
complain about, and sources. Keep each under ~100 lines. The interview and the
GDD then build on facts, and later tasks can cite them. Skip this if the user
wants to go straight to questions.

## Rules for the interview
- **One question per message.** Offer 2-4 concrete options plus "you decide".
  Put your recommendation first and explain it in one line.
- Keep it to roughly 10-15 questions. Skip anything the idea already answers.
- The user is a beginner developer and has little time: always push towards the
  **smallest vertical slice that tests the core mechanic.**
- Prefer designs whose rules can be tested headless: rules in plain classes,
  seeded randomness, numbers in data files. Don't push a design toward ticks
  or turns to get there; the time model is the user's choice.

## Question bank (pick what matters, in roughly this order)
1. Player fantasy and the one-sentence pitch (confirm your summary).
2. Time model: turn-based / ticks with pause & speed / real-time. And: does
   the game have a simulation (rules that run without a screen and that a bot
   can play)? This decides the sim tier, bots and balance cases.
3. The core loop at three scales: seconds, minutes, whole session.
4. Win, lose and end conditions. How long is a session?
5. The main resources / quantities and what converts into what.
6. Opponents: none (sandbox) / scripted events / AI players. How smart?
7. Map: none / fixed / hand-made / procedural. Grid (square/hex) or free?
8. Unit/agent count at peak (performance budget on GTX 1650 and on integrated graphics).
9. What is the player NOT allowed to do (scope fences)?
10. UI density: how many numbers on screen; which ones always visible?
11. Art: placeholder shapes / pixel art / flat vector / 3D. 2D strongly preferred.
12. Save/load needed in the first slice? (Default: no.)
13. Balance targets in numbers (strategy example: "a decent player reaches 50 pop by tick 300").
14. Platforms and input (default: Windows + Linux, mouse + keyboard).

## Writing the GDD
- Fill every section of the template. Unknowns go to `docs/QUESTIONS.md`
  (kit template `harness/templates/QUESTIONS.md`), not into invented detail.
- Every requirement row: `ID | requirement | tier | proof`. Use prefixes per
  system (ECO, POP, MAP, AI, UI, SYS, BAL, SAV ...). Choose the **fastest tier
  that can prove it**:
  - `unit`  - a rule or formula on the pure simulation
  - `sim`   - needs many ticks/seeds/bots (stability, balance, AI behaviour; games with a simulation)
  - `scene` - needs real nodes/signals/input (UI wiring)
  - `visual`- needs a screenshot judged against the style guide
  - `playtest` - only a human can judge (fun, clarity, feel). Keep these few
    and specific ("a new player finds the build menu within 30 s").
- Always include SYS-002 (invariants: what must never happen, e.g. no
  negative resources, health never below 0, nothing outside the map), plus at
  least one fault-injection case. With a simulation also SYS-001
  (determinism: same seed + commands = same result).
- With a simulation, add balance targets (BAL-*) as numbers so `/balance` and
  `/qa` can measure them; each becomes a case in `tests/cases/balance.json`.
  Without one, a number that matters (a level's length, a boss's health) is a
  unit-tested requirement or a playtest question.
- Split work into phases. Phase 1 is the smallest slice that tests the core
  mechanic. With a simulation: the simulation core with unit and sim tests,
  no graphics beyond debug labels. Without one: the player's rules with unit
  tests, plus one grey-box test level to play.

## Finish
1. Show the user a 10-line summary: pitch, pillars, phase plan, number of
   requirements per tier, open questions.
2. Ask them to read `docs/GDD.md` (it is the contract) and to answer the open
   questions or say "go".
3. Suggest the next step: `/harness` (new project) or `/start <IDs>` (harness exists).
