---
name: playtest
description: Turn the user's raw playtest notes or voice transcript into a structured playtest report in docs/playtests/ - bugs become failing tests, balance observations become /balance experiments, feel/clarity issues become change requests. Use after the user has played a build and shares impressions, complaints or ideas.
---

# /playtest - the field tier

Only a human can judge fun, clarity and feel. This skill makes their notes
actionable without losing anything.

## Steps
1. Get the notes (pasted text, a file, or a voice transcript). Do not ask the
   user to clean them up. Note the commit they played (`git log -1 --oneline`)
   unless they say otherwise.
2. Create `docs/playtests/PT-<NNN>-<date>.md` from the kit template
   (`<kit>/harness/templates/PLAYTEST.md`), raw notes pasted verbatim.
3. Sort every observation into exactly one bucket:
   - **Bug** - the game does something the GDD says it should not. Write the
     repro steps. If it can be reproduced in a test, write that test now (it
     should fail) and reference it. Do not fix yet unless the user asks.
   - **Balance** - numbers feel wrong ("wood is useless after minute 5").
     Turn it into a hypothesis plus a measurable experiment for `/balance`.
   - **Feel / clarity / fun** - needs a design change. Draft a change request
     line; create `docs/changes/CR-<NNN>.md` only for the ones the user wants.
   - **Keep** - what worked. These protect good things from later changes.
4. Ask the user at most 3 questions where an observation is unclear.
5. Summarise: counts per bucket, the top 3 things to do next, and which skill
   handles each (/build for bug tests, /balance, /change-request).
