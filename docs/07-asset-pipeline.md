# 07 - Art and assets: the Gambo pipeline, adapted

Your note on Gambo7592's pipeline concluded it's good for **assets and quick
demos**, weak for sustained development. So this kit keeps its strong part
(style-guide-first, Claude writes the prompts, Claude scripts the cleanup)
and connects it to the harness. The development side is covered by the
harness and the architecture rules.

## Principles for strategy/sim art

1. **Mechanics first, art last.** Bots and playtests decide whether the game
   is fun. Until then, placeholders: coloured shapes, SVG icons, a free CC0
   pack. Cheap to throw away.
2. **Readability beats beauty.** Strategy players read the screen like a
   dashboard: silhouettes at full zoom-out, player colours that differ in
   brightness, icons at 32 px, numbers with rates. This is in the style guide
   template.
3. **2D or 2.5D (isometric) over 3D.** Far less work per asset, runs on the
   T480s's integrated GPU, and much easier for an agent to generate or draw.
4. **Consistency comes from the style guide**, not from the image model.
5. **Provenance.** Every asset gets a manifest row: source, licence, prompt.
   Stores (Steam) ask about AI-generated content, and you'll want to
   regenerate assets in the same style later.

## The steps

### 1. Art direction -> `/style-guide`
As Gambo does: generate or collect a batch of candidate images (any image
generator, screenshots of games you like), keep the 4-12 you love, put them in
`docs/style_refs/`, run `/style-guide`. Claude extracts the shared rules
(proportions, shapes, palette in hex, materials, lighting, edges, detail
level, **what the style is not**) plus strategy readability rules, and a
**prompt preamble** reused for every asset.

### 2. Producing assets -> `/asset`
Four routes. Claude recommends one per asset:

| Route | Best for | How |
|---|---|---|
| **A. SVG written by Claude** | icons, UI, resource symbols, map markers, flat buildings, placeholders | Claude writes `.svg` files directly; Godot imports SVG. Zero cost, perfectly consistent, editable. **Underrated for strategy games.** |
| **B. Procedural** | terrain tiles, noise, colour variants (team colours), minimaps | a GDScript tool or generator script; reproducible |
| **C. Image model** | painted art, portraits, concept art, detailed unit sprites | Claude writes the prompt from the style guide (Gambo's "Claude, here's my style, write a Gemini prompt for a tree"), you generate in Gemini / ChatGPT / a local model, drop the file in `assets/` |
| **D. Asset packs** | speed | e.g. Kenney (CC0); note licence in manifest |

For route C with 3D in mind (Gambo's multi-view sheet -> Meshy -> Blender):
it works, but it's the most expensive path in time and money. For
strategy/sim games prefer 2D sprites rendered from a few angles, or
isometric 2D. If you do go 3D, Gambo's Blender trick carries over: Claude
writes **Blender Python scripts** for decimation, cleanup, rigging and batch
export, run with `blender --background --python script.py` (headless, so it
fits the harness idea). Also his animation advice: derive variations from one
base animation instead of making each from scratch.

### 3. Integrate and check
- Import settings: pixel art = Nearest filter, no mipmaps.
- Data files reference assets (`"icon": "res://assets/icons/food.svg"`).
- `gw.sh shot` and ask Claude to compare the screenshot against the style guide.

## Your hardware and local image generation
- **GTX 1650 (4 GB VRAM):** local Stable Diffusion is possible with
  low-VRAM settings in tools like ComfyUI or Forge (SD 1.5-class models at
  512 px work; SDXL-class models are tight and slow). Fine for icon/texture
  experiments, sprite variations with a fixed style (LoRA) or upscaling.
  Not a must: online image generators are faster and the results usually better.
- **T480s:** no local image generation; it's the agent and test box.
- Local LLMs on either laptop are not worth it compared to Claude for coding.

## Sound
Placeholder SFX from sfxr-style generators (jsfxr in the browser), CC0 packs
for ambience/music until the game is worth commissioning or generating more.
Same manifest rules.
