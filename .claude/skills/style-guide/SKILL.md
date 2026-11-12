---
name: style-guide
description: Create docs/STYLE_GUIDE.md from reference images the user picked - shapes, palette, lighting, UI readability, what the style is not, plus a prompt preamble for image generators. Use when the user starts art direction or shares references.
---

# /style-guide - art direction the agent can follow

Based on the reference-first approach: the user generates or collects a batch
of images, keeps the ones they like, and you extract the shared visual rules
so every later asset (and every UI change) stays consistent.

## Steps
1. Collect references. Ask the user to put 4-12 images in `docs/style_refs/`
   (screenshots of games they like, AI images they generated, photos). Look at
   every image. If you cannot open images in this environment, ask the user to
   attach them in chat.
2. For each image write one line: what you see and which trait is worth keeping.
3. Write `docs/STYLE_GUIDE.md` from the kit template
   (`<kit>/harness/templates/STYLE_GUIDE.md`). Be concrete and checkable:
   - **Proportions, shapes/silhouettes, colour + hex palette, materials,
     lighting, line/edge treatment, level of detail, what it is NOT.**
   - Strategy/sim specifics: silhouettes readable at the furthest zoom; player
     colours that differ in brightness (colour-blind safe); icons legible at
     32 px; numbers always with units and +/- rate; consistent light direction
     on map tiles; how "selected", "disabled", "danger" look.
   - Target pixel sizes for tiles, units, icons, fonts.
   - A **prompt preamble** (3-5 sentences) for image generators, and a
     **negative list** (things to avoid).
4. If the project has a UI, propose a Godot `Theme` derived from the palette
   (colours, font sizes, margins) as `ui/theme.tres` or code in `ui/theme.gd`,
   but only create it if the user agrees.
5. Ask the user to read the guide and strike anything that is wrong. The guide
   is versioned in git; changes to it should be deliberate.
