---
name: spec
description: Turn the human's own design documents (the design/ folder - many files, any structure) into numbered, testable requirements without rewriting or extending the design - a system map first, then one system at a time into docs/spec/<system>.md with sources, worked examples and proofs, and every contradiction, gap or superseded rule put to the human in docs/QUESTIONS.md. Use when the user already has design notes or drafts, says "spec", "ingest my design", "here are my docs", names a system to specify, or changed a design file.
---

# /spec - from your design documents to a contract the agent can build

The human is the designer and has already thought the game through. Your job
here is a **translator and a proof-reader, never a co-designer**: restate what
their documents say as requirements that can be tested, and report everything
that is unclear. You do not fill holes with your own ideas.

Where things live (create what is missing):
- `design/` - the human's documents. **Read-only for you.** Any structure, any
  number of files, Obsidian links and images welcome.
- `docs/spec/<system>.md` - one contract per system, written by you from the
  kit template (`<kit>/harness/templates/SPEC.md`; kit = `$GAMEDEV_WF`, else
  `~/Gamedev_WF`, else ask).
- `docs/QUESTIONS.md` - the decision queue (`<kit>/harness/templates/QUESTIONS.md`).
- `docs/GDD.md` - the short index: pitch, scope, the systems table, build order.

Work in two steps. Do only the step that was asked for, then stop.

## Step 1 - the system map (`/spec` with no system named)
Cheap on purpose: do NOT read every file in full.
1. List `design/` with sizes and dates (`ls -R`, `wc -c`). Read headings and
   first lines only (`grep -n '^#' ...`, `head -5`). Open a whole file only
   when its name and headings do not tell you what it covers.
2. Write (or update) the systems table in `docs/GDD.md`:
   `system | prefix (3 letters) | design files | depends on | status`.
   Status is `mapped` until step 2 has run for it.
3. Report which documents look like **amendments** to others (names such as
   "clarifications", "changes", "v2", "new info"; later dates; text like "this
   is reworked", "now X is..."). List each pair `older file -> newer file` and
   ask whether the newer one wins. Do not assume it.
4. Propose a build order: the system the others depend on first, and inside it
   the smallest slice that can run headless. Give the reason in one line each.
5. Stop. Ask which system to specify first.

## Step 2 - one system (`/spec <system>`)
1. Read every design file mapped to that system, in full, oldest first.
2. Write `docs/spec/<system>.md` from the template:
   - **Rules as requirement rows**: `ID | requirement | source | tier | proof`.
     One checkable statement per row. `source` is `file#heading` so the human
     can jump back. Keep their terms; do not rename things. IDs are never
     reused. Choose the fastest tier that can prove the row (unit / sim /
     scene / visual / playtest).
   - **Worked examples**: every calculation the documents walk through
     ("level 40, two modifiers -> 170 -> 510") becomes a row of inputs and
     expected outputs, quoted with its source. These are the future test
     vectors. Recompute each one from the rules as written; if your result
     differs from the document, that is a QUESTION, not a correction.
   - **Data**: which numbers belong in `data/*.json`, with the values the
     documents give. A number the documents do not give is a QUESTION.
   - **Glossary**: their term -> one-line meaning -> the identifier the code
     will use.
   - **Not covered**: things the documents mention for this system but do not
     define. Listed, not designed.
3. File a row in `docs/QUESTIONS.md` for each of these. Never resolve them yourself:
   - two statements that cannot both be true (quote both, with sources)
   - a rule superseded by a later document, when the human has not confirmed it
   - a missing number, range, order of operations or tie-break
   - a term used but never defined
   - a rule that cannot be tested as written ("feels fair") - ask what would count
   - a worked example that does not match the rules
   Each question: what blocks on it (IDs), 2-3 concrete options, your
   recommendation and why, in one line each. Mark requirements that depend on
   an open question as `blocked by Q-012` in the spec.
4. Set the system's status in the GDD table to `specified`.
5. Report, in at most 12 lines: requirements per tier, worked examples found,
   questions filed (the 3 that block the most first), and the first slice you
   would build. Then stop: the human reads the spec and answers the questions
   in their editor, which costs no usage.

## Rules
- Never write to `design/`. If a design file has an obvious typo that changes
  meaning, that is a question too.
- No invented mechanics, numbers, names or "sensible defaults". An empty cell
  with a question beats a plausible guess: a guess gets built, tested and
  balanced before anyone notices it was never the design.
- Scope fence: only what the first playable needs gets full requirement rows.
  Later-phase material (monetisation, seasons, story) is listed under "Not
  covered / later" with its source file, so nothing is lost and nothing is built early.
- When a design file changes later, run `/spec <system>` again: update the
  rows, keep the IDs, list what changed, and turn changed behaviour that is
  already implemented into a `/change-request`.
