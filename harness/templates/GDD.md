# <Game title> - Game Design Document (GDD / functional spec)

> The contract between you and the agent. It implements what is written
> here and in `docs/spec/`, nothing more. Every requirement says how it is proven.
>
> Two ways to fill it:
> - **You already wrote the design** (files in `design/`): `/spec` builds the
>   systems table below and one `docs/spec/<system>.md` per system. Your
>   `design/` files stay the origin; this file is only the index.
> - **You only have an idea**: `/define` interviews you and writes the
>   requirements straight into section 6 (fine for small games).

| Field | Value |
|---|---|
| Version | 0.1 |
| Engine | Godot 4.x (GDScript), renderer: Compatibility |
| Target | Windows + Linux desktop, keyboard + mouse |
| Status | Draft / Phase N in progress |

## 1. Pitch
One paragraph: genre, player fantasy, core tension, what makes it different.

## 2. Pillars (max 3)
1. **...** - what every feature must support.
2. **...**
3. **...**

## 3. Scope
### 3.1 In scope for the first playable (vertical slice)
### 3.2 Explicitly out of scope (for now)
### 3.3 Later / maybe

## 4. Core loop
- **Moment to moment (seconds):**
- **Short loop (minutes):**
- **Long loop (session / campaign):**
- **Win / lose / end conditions:**

## 5. Time model
Turn-based / fixed tick (N ticks per second, pausable, speed x1/x2/x4) /
real-time (the strategy/sim choices; an action game usually runs on Godot's
physics frame). The rules must be deterministic for a given seed + command list.

## 6. Systems
| System | Prefix | Design files | Spec | Depends on | Status |
|---|---|---|---|---|---|
| Stats & levels | STA | `design/Progression/...` | `docs/spec/stats.md` | - | mapped / specified / building / done |

Build order: the system others depend on first; inside it, the smallest
slice that runs headless.

Small game without `docs/spec/`: one subsection per system right here, each
with its rules, the data it reads (data/*.json) and its requirements.

### 6.1 <System name, e.g. Economy (strategy example) or Player movement>
Rules in plain language. Numbers live in `data/<file>.json`, not here; this
document says what the numbers *mean* and their intended ranges.

| ID | Requirement | Tier | Proof (test) |
|---|---|---|---|
| ECO-001 | ... | unit | tests/unit/test_economy.gd::test_... |
| ECO-002 | ... | sim | tests/sim/test_long_runs.gd::test_... |

### 6.2 <AI opponents / agents>
### 6.3 <Map / world generation>
### 6.4 <Save / load>

## 7. Balance targets (what "feels right" means, in numbers)
In a game with a simulation, each target becomes a case in
`tests/cases/balance.json`; `./harness/gw.sh cases`
shows them side by side. You own that file: it lists the situations you care about.

| ID | Target | How measured |
|---|---|---|
| BAL-001 | A simple bot reaches X by tick Y on 90% of seeds | sim runner, seeds 1-50 |
| BAL-002 | Doing nothing loses within N ticks | sim test |
| BAL-003 | No single strategy dominates (win rate 35-65%) | bot vs bot runs |

The rows are strategy examples. Without a simulation, a target is a number a
unit test checks (e.g. from level data) or a playtest question.

## 8. UI / UX
Screens, what each shows, controls. Readability rules (icon size, colour
meaning). Every UI requirement gets a scene-tier test or a visual check.

| ID | Requirement | Tier | Proof |
|---|---|---|---|
| UI-001 | ... | scene | tests/scene/... |
| UI-002 | ... | visual | `gw.sh shot` reviewed against docs/STYLE_GUIDE.md |

## 9. Art & audio direction
Link to docs/STYLE_GUIDE.md. Placeholder policy (what can stay grey-box).

## 10. Technical rules
- Simulation core in `sim/` is pure GDScript (RefCounted), no Nodes, no autoload state.
- All tunable numbers in `data/`.
- Scenes in `scenes/` only display state and send commands.
- Performance budget: e.g. 60 fps with 500 units on a GTX 1650 / 30 fps on integrated graphics.

## 11. Phases (implementation plan)
| Phase | Goal | Requirements | Done when |
|---|---|---|---|
| 1 | Core sim, no graphics | ECO-*, SYS-* | unit + sim tiers green |
| 2 | Playable UI | UI-* | scene tier green, playtest #1 |
| 3 | ... | | |

The rows are a strategy example; in an action game phase 1 might be the
player's rules and movement in one test level.

## 12. Open questions
See `docs/QUESTIONS.md` (the decision queue). Answer there, in any editor.

## 13. Change log
| Date | Change | CR |
|---|---|---|
