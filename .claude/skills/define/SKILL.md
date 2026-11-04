---
name: define
description: Interview the user one question at a time and turn a game idea into a Game Design Document (docs/GDD.md) whose every requirement has an ID and says how it will be proven (unit, sim, scene, visual or playtest). Use when starting a new game project, when the user says "define", "spec", "GDD", or wants to turn an idea or pitch into a specification.
---

# /define - idea to testable Game Design Document

This is the "functional specification" step. Output: `docs/IDEA.md` (if
missing) and `docs/GDD.md`, following the template in the Gamedev-WF kit
(`$GAMEDEV_WF/harness/templates/GDD.md`; if `$GAMEDEV_WF` is unset try
`~/Gamedev_WF`, then ask the user where the kit is).

## 0. Investigate first (optional, offer it)
The embedded workflow researches the hardware and protocols before writing
the spec. The game equivalent: if the idea leans on a known mechanic, genre
convention or real-world system (e.g. "supply lines like Hearts of Iron",
"queueing at a harbour", "Lanchester combat", "logistic population growth"),
offer to research it first and write a short `docs/ref/<topic>.md`: how it
works, the formulas or rules, typical numbers, what players like and
complain about, and sources. Keep each under ~100 lines. The interview and the
GDD then build on facts, and `/build` can cite them. Skip this if the user
wants to go straight to questions.

## Rules for the interview
- **One question per message.** Offer 2-4 concrete options plus "you decide".
  Put your recommendation first and explain it in one line.
- Keep it to roughly 10-15 questions. Skip anything the idea already answers.
- The user is a beginner developer and has little time: always push towards the
  **smallest vertical slice that tests the core mechanic.**
- Prefer designs that are easy to test headless: tick- or turn-based
  simulation, deterministic seeded randomness, numbers in data files.

## Question bank (pick what matters, in roughly this order)
1. Player fantasy and the one-sentence pitch (confirm your summary).
2. Time model: turn-based / ticks with pause & speed / real-time.
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
13. Balance targets in numbers ("a decent player reaches 50 pop by tick 300").
14. Platforms and input (default: Windows + Linux, mouse + keyboard).

## Writing the GDD
- Fill every section of the template. Unknowns go to "Open questions", not
  into invented detail.
- Every requirement row: `ID | requirement | tier | proof`. Use prefixes per
  system (ECO, POP, MAP, AI, UI, SYS, BAL, SAV ...). Choose the **fastest tier
  that can prove it**:
  - `unit`  - a rule or formula on the pure simulation
  - `sim`   - needs many ticks/seeds/bots (stability, balance, AI behaviour)
  - `scene` - needs real nodes/signals/input (UI wiring)
  - `visual`- needs a screenshot judged against the style guide
  - `playtest` - only a human can judge (fun, clarity, feel). Keep these few
    and specific ("a new player finds the build menu within 30 s").
- Always include the system requirements SYS-001 (determinism: same seed +
  commands = same result) and SYS-002 (invariants: no negative resources, no
  NaN, no unit outside the map...), plus at least one fault-injection case.
- Add balance targets (BAL-*) as numbers so `/balance` can measure them.
- Split work into phases. Phase 1 is always: simulation core + unit/sim tests,
  no graphics beyond debug labels.

## Finish
1. Show the user a 10-line summary: pitch, pillars, phase plan, number of
   requirements per tier, open questions.
2. Ask them to read `docs/GDD.md` (it is the contract) and to answer the open
   questions or say "go".
3. Suggest the next step: `/harness` (new project) or `/build` (harness exists).
