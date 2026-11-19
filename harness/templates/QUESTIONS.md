# Open questions - the decision queue

The agent never decides design. When your documents are silent, unclear or
contradict each other, it files a question here and works on something that is
not blocked. **Answer in the "Your answer" column whenever you like, in any
editor: that costs no AI usage.** Then say "questions answered" (or run
`/spec <system>` again) and the agent moves the answers into the spec.

| ID | System | Question | Options | Agent recommends | Blocks | Your answer |
|---|---|---|---|---|---|---|
| Q-001 | STA | A 7th buff arrives while Buffs and Temporary are both full. `Status_Effects.md#bars` says the rightmost moves to Temporary; `Some_Fundamental_Changes.md` says overload triggers. Which happens first? | A: move, then overload on the Temporary bar - B: overload at once, nothing moves | A (matches the newer file) | STA-005, STA-006 | |

Rules for the agent:
- One decision per row. Quote the sources. 2-3 concrete options. A
  recommendation with a one-line reason. IDs are never reused.
- "Blocks" lists the requirement IDs that wait for this answer.
- An answered row moves to the table below with the date, and the spec is
  updated in the same step.

## Answered
| ID | Question (short) | Decision | Date | Applied to |
|---|---|---|---|---|
