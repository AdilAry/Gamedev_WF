---
name: change-request
description: Create and apply a change request for a harnessed game project - write docs/changes/CR-NNN.md, update docs/GDD.md requirement IDs and docs/TESTPLAN.md, then implement it through the /build loop. Use when the user wants to change, add or remove a feature or rule after the GDD exists, or says "CR", "change request", "I want X to work differently".
---

# /change-request - change the spec first, then the code

The GDD stays the single source of truth. Code never drifts away from it.

## Steps
1. Restate the wish in one or two sentences from the player's point of view.
   Ask at most 2 questions if it is ambiguous.
2. Find affected requirements (grep the GDD for related IDs and systems) and
   the tests that prove them (TESTPLAN).
3. Write `docs/changes/CR-<NNN>.md` from the kit template
   (`<kit>/harness/templates/CHANGE_REQUEST.md`): what, why, affected IDs
   (old -> new), proof (tests to add/change with tier), risks (balance, saves, UI).
4. Show the user the CR summary (max 10 lines) and wait for "go" - unless they
   already said to just do it.
5. Apply to the GDD: edit requirement rows, new IDs for new behaviour, mark
   removed ones `dropped` (never reuse an ID), add a change-log row with the
   CR number. Update TESTPLAN rows to `todo`/`red`.
6. Implement with the `/build` loop (tests first). Commit message starts with
   the CR number: `CR-004: winter halves farm output (ECO-010, BAL-004)`.
7. Set the CR status to `implemented` and note the commit.

Small wishes (a typo, a colour, one number in `data/`) do not need a CR file -
just make the change, run `check` and mention it in the log.
