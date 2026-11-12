# Plan: [project name]

Read only the section of the current milestone. Every milestone ends the same way: stop, tell me how to check it and the output I should see, then wrap.

## M0 Skeleton (5%)
- Check that "First question" in docs/brief.md is filled. If it isn't, ask me before building.
- Repo structure, dependency file, `.env.example`, `.gitignore`, PROGRESS.md from its template, LICENSE ([MIT | the event's, client's or employer's terms | none, private repo]).
- The smallest thing that runs end to end and shows one real result: [e.g. a page showing one number from the data | firmware printing one sensor reading | a scene where the player moves].
- [IF deployed] Deployed and reachable on a phone.

## M1 Foundation (15%)
- [What everything else depends on: load and clean the data, plus its rules | drivers behind a hardware abstraction layer | core game loop and state].
- Tests on known cases, including the edge cases: [the ones you already know].
- [IF data] Drop physically implausible values and log how many. Before choosing the unit of analysis, count how many units have enough samples; if most don't, tell me.

## M2 Core feature (25%)
- [The core feature from the MVP], visible on the main screen in plain language.
- If it ranks or shortlists: read the top results as the user would. They must make sense for that use, in that order.
- If it exports: open the file where users will, with their locale settings (delimiter, decimal mark, encoding). If that can't be tested, list it as a limit.

## First-question check (10 min, fresh session)
Read the results as the person in "For" would, and answer the First question from them. If the answer is weak, tell me before M3.

## M3 [Extra layer, e.g. AI explanations] (10%)
- [What it adds.]
- [IF AI] Works without keys: cached answers, labelled as cached. Read generated text for meaning as well as numbers: it must not claim more than the data shows, and it uses the app's own wording and units.

## M4 Polish (20%)
- The demo moment, layout on the target screen, wording without jargon.
- Error states: [the ones you expect, e.g. missing data, no key, no connection].
- No function or variable names on screen, including loading messages.

## Judge pass + fixes (25%, fresh session)
Run the judge skill. It reports issues ranked by value per hour; I pick which ones get fixed.

## Freeze
After the judge pass, when the budget is used up, or when I say so. From then on, bug fixes only.
[IF deck or video] After the presentation materials are done: the judge skill with "final", in a fresh session.
