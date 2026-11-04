# <Game title> - Game Design Document (GDD / functional spec)

> This is the single source of truth. The agent implements what is written
> here, nothing more. If behaviour is wrong, fix THIS document first, then ask
> for the change (see docs/changes/). Every requirement says how it is proven.

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
real-time. Simulation must be deterministic for a given seed + command list.

## 6. Systems
One subsection per system. Each system lists its rules, the data it reads
(data/*.json) and its requirements.

### 6.1 <System name, e.g. Economy>
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
These are checked by `/balance` with headless simulation runs.

| ID | Target | How measured |
|---|---|---|
| BAL-001 | A simple bot reaches X by tick Y on 90% of seeds | sim runner, seeds 1-50 |
| BAL-002 | Doing nothing loses within N ticks | sim test |
| BAL-003 | No single strategy dominates (win rate 35-65%) | bot vs bot runs |

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

## 12. Open questions
-

## 13. Change log
| Date | Change | CR |
|---|---|---|
