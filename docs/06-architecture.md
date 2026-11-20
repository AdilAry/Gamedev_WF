# 06 - Architecture for AI-built games

The Gambo pipeline turned into spaghetti within days. Better prompts don't
fix that; **structure plus tests** do. The agent follows structure well if
it is written down (AGENTS.md) and enforced (tests). This is the structure
`/harness` sets up, and the example project uses it.

## The split: rules core vs presentation

```
data/*.json  ──►  sim/  (rules, state, bots)  ──state──►  scenes/ + ui/  (draw, input)
                    ▲                                          │
                    └──────────── commands (build, move) ◄─────┘
```

| Layer | Contains | Rules |
|---|---|---|
| `data/` | every tunable number: costs, rates, unit stats, tech tree | JSON (or `.tres` resources if you prefer the editor); validated by unit tests |
| `sim/` | game state + rules + `step()`/`apply_command()` + seeded RNG + bots (if the game has them) | `RefCounted` classes only; **no Nodes, no autoload state, no rendering, no `randf()` global**; deterministic |
| `scenes/`, `ui/` | nodes, sprites, UI, camera, audio, input | read `sim.state`, send commands; **no rules** |
| `sim/harness_hook.gd` | adapter for the sim runner (only in a game with a simulation) | keeps the core runnable headless |

In embedded terms: `sim/` is your firmware logic, `scenes/` is the HAL and
peripherals. You test the logic on the host and keep the hardware layer thin.

### Why this works so well with an agent
- **Unit and sim tests need no scene tree**, so they're fast and stable.
- **Balancing is editing JSON**, which the agent can do safely and you can
  review at a glance.
- **Swapping presentation is cheap**: placeholder UI now, real art later,
  same tests.
- **Determinism gives reproducible bugs**: seed + command list = replay.
  Later you get save games, replays, lockstep multiplayer and "AI watches
  a bot game" almost for free.
- **Small files with one job** fit in the agent's context. Big tangled files
  cause the "corrupted main file" disasters the video mentions.
- **It pays off in an action game too.** A platformer's rules (damage,
  health, inventory, the player's state machine, level data) live in `sim/`
  as plain classes and get unit tests in milliseconds. Movement, physics,
  animation and camera, where the feel is, stay in `scenes/`, and you judge
  them by playing. The thinner that layer, the more of the game a test can
  prove.

## Time models (strategy/sim: state it in your design, or pick in /define)

This choice matters most in strategy and sim games; an action game usually
runs on Godot's own physics frame.

| Model | Fits | Note |
|---|---|---|
| Turn-based | 4X, tactics, board-game-likes | simplest to test; a turn is a step |
| Fixed tick + pause/speed | colony sims, city builders, Paradox-likes, management | the example uses this; drive `step()` from a Timer or `_physics_process` accumulator |
| Real-time | RTS, action-strategy | still run the *rules* on a fixed tick; let only movement/visuals interpolate |

## Patterns worth knowing (ask the agent for them by name)

- **Command pattern**: player and AI both issue `Command` objects
  (`BuildCommand`, `MoveCommand`) to the sim. Gives you undo, replays,
  networking and testable AI.
- **Entity tables over node trees**: for hundreds of units, keep units as data
  in the sim (arrays/dictionaries or small RefCounted objects) and draw them
  with a `MultiMeshInstance2D` or by pooling sprites, rather than a Node per unit
  with its own logic.
- **Utility AI** for opponents: score each possible action, pick the best.
  Easy to test ("with no food, building a farm scores highest") and to tune
  in JSON.
- **Event log**: the sim appends events (`"starvation"`, `"battle_won"`), the
  UI shows them, tests assert on them.
- **Grid helpers**: `TileMapLayer` for drawing, but a plain grid array in the
  sim for rules and pathfinding (`AStarGrid2D` works without a scene tree).
- **Save = serialise the state**: `state.to_dict()` -> JSON. Test round trips.

## Godot specifics the agent gets wrong (they are in AGENTS.md)

- Godot 3 vs 4 syntax. Keep `docs/ref/godot-api/` (from `gw.sh doc`) and tell it
  to grep there.
- JSON numbers load as **floats**. Convert once in the loader (see
  `sim/colony_rules.gd`), or `typeof()` checks and dictionary keys go wrong.
- `:=` can't infer the type from a `Variant` (e.g. `dict.get()`); give an
  explicit type.
- **GDScript has no compiler to catch hallucinations.** The embedded video
  says compilers don't tolerate hallucinations: an invented function in C
  simply doesn't build. GDScript is weaker. Types help (assigning a String
  to an `int` is rejected when the script loads, so CI checks that), but
  **a call to a method that doesn't exist only fails when that line runs**.
  This kit's CI tested it on Godot 4.7: `var sim: ColonySim` plus
  `sim.bild_farm()` in a branch no test reaches passes every check. So for
  games, tests that exercise every branch are the compiler. Two habits
  follow: the agent greps `docs/ref/godot-api/` instead of guessing method
  names, and every new `if`/`match` branch in `sim/` gets a test that reaches it.
- Hand-editing `.tscn` files: keep the root scene small, build UI in code,
  or have *you* lay out scenes in the editor and let the agent attach scripts.
- Autoloads (singletons) are convenient but make tests order-dependent; keep
  game state out of them.

## When to leave GDScript (level 10)
Only when a measurement (the sim runner's timing, or Godot's profiler in a
game without one) says the core is too slow for your target
(e.g. 1 000 units on the T480s). Then move **one hot function** to C# or
GDExtension (C++), keep the GDScript version as the reference, and add a
test that compares both on random inputs. Your embedded experience is an
asset here.
