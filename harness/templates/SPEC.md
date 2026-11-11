# <System name> - spec (prefix: XXX)

> Written by `/spec` from your design documents. It restates them as things
> that can be tested; it adds nothing. If a row is wrong, the fix belongs in
> your design file (or in your answer to a question), then `/spec <system>` again.

| Field | Value |
|---|---|
| Design sources | `design/...`, `design/...` |
| Depends on | other systems |
| Status | specified / building / done |
| Open questions | Q-..., Q-... (see docs/QUESTIONS.md) |

## 1. Summary
Three to six lines in the designer's own terms: what this system is for.

## 2. Requirements
One checkable statement per row. Tier = the fastest way to prove it:
`unit` (a rule/formula), `sim` (many ticks/seeds/bots), `scene` (real nodes
and input), `visual` (screenshot), `playtest` (only a human can judge).

| ID | Requirement | Source | Tier | Proof (test) | Status |
|---|---|---|---|---|---|
| XXX-001 | ... | `File.md#heading` | unit | tests/unit/test_xxx.gd::test_... | todo |
| XXX-002 | ... (blocked by Q-003) | `File.md#heading` | unit | | blocked |

Status: `todo`, `blocked`, `red`, `green`, `dropped` (IDs are never reused).

## 3. Worked examples (the test vectors)
Every calculation your documents walk through, as inputs and expected
results. Tests are written from this table; a missing example is a question.

| # | Given | When | Then | Source |
|---|---|---|---|---|
| 1 | level 40, base HP 160, two HP modifiers | pre-combat stats | HP 170 | `Stat_Modifier_Clarifications.md` |
| 2 | pre-combat HP 170 | entering combat | HP 510 | same |

## 4. Data
Numbers live in `data/*.json`, not in code. Values as given in the design;
an empty value is an open question.

| Key | Meaning | Value | Allowed range | File |
|---|---|---|---|---|

## 5. Balance targets
What "feels right" means in numbers. Each becomes a case in
`tests/cases/balance.json` (`./harness/gw.sh cases`).

| ID | Situation | Target |
|---|---|---|
| BAL-0xx | two equal-level teams, both played by the simple bot | first player wins 45-55% |

## 6. Glossary
| Your term | Meaning | Name in code |
|---|---|---|

## 7. Not covered / later
Mentioned in the design for this system but not defined, or out of scope for
the first playable. Listed with the source so nothing is lost; not built.

## 8. Change log
| Date | Change | Reason (design edit, Q-..., CR-...) |
|---|---|---|
