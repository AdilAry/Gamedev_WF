---
name: asset
description: Produce one game asset consistent with docs/STYLE_GUIDE.md (SVG, procedural, or a prompt for an image tool), import it into Godot and record it in assets/ASSETS.md. Use when the user needs an icon, tile, sprite, UI element or sound.
---

# /asset - consistent assets with provenance

## 1. Clarify (one message)
What is it, where does it appear, at what pixel size, how many variants
(e.g. 4 rotations, 3 damage states, player colours)? Default to the sizes in
the style guide.

## 2. Pick the route (recommend one)
| Route | When | Output |
|---|---|---|
| **A. SVG written by you** | icons, UI, simple flat/vector buildings, map symbols, placeholders | `assets/.../*.svg` (Godot imports SVG natively) |
| **B. Procedural in Godot** | tiles, noise textures, colour variations | a `@tool` script or a generator script under `tools/` |
| **C. Prompt for an image tool** | painted/detailed art, portraits, concept art | `assets/prompts/<name>.md` with the prompt; the user generates and drops the file in |
| **D. Free asset pack** | the user wants speed (e.g. Kenney, CC0) | file + licence noted |

Strategy/sim games need many small readable things (icons, tiles, markers)
far more than detailed art - route A/B usually wins, and placeholders are fine
until the mechanics are proven by playtests.

## 3. Route C - writing the prompt
Start with the style guide's prompt preamble, then: subject, view
(top-down / isometric 2:1 / side), framing (centred, isolated, plain
background for easy cut-out), size/aspect, palette hexes, lighting direction,
the negative list. For multi-view sheets (turnarounds for 3D or rotations),
ask for a labelled grid. Save the prompt so the asset can be regenerated.
Remind the user: check the image tool's licence/terms for commercial use, and
keep the prompt + tool + date in the manifest (stores such as Steam ask about
AI-generated content).

## 4. Import into Godot
- Pixel art: Project Settings or per-texture import -> filter **Nearest**,
  no mipmaps. Painted art: Linear filter.
- Name files `snake_case`, group by type: `assets/icons/`, `assets/tiles/`,
  `assets/units/`, `assets/ui/`, `assets/audio/`.
- Reference assets from `data/` (e.g. `"icon": "res://assets/icons/food.svg"`)
  instead of hard-coding paths in scenes.
- Run `./harness/gw.sh import` and, if it is visible in a scene,
  `./harness/gw.sh shot` and look at the result against the style guide.

## 5. Record
Add a row to `assets/ASSETS.md`: file, type, source/route, licence, prompt
file or notes, status (`placeholder` / `draft` / `final`).

## Sounds
Simple SFX: suggest jsfxr / sfxr-style generators (the user exports `.wav`),
or free CC0 packs. Record them in the manifest like images.
