# Lootlings Project State

## CURRENT STATE
Playable Godot 4.7.2 portrait vertical slice with a signature Relic Core build system. A run spans 15 waves, includes a miniboss on wave 8 and a boss on wave 15, then awards permanent-progression currency and allows an immediate restart. Stable fallbacks are `99ccc07` (base vertical slice) and `bed14ba` (pre-identity polish build).

## WHAT WORKS
- Automatic approach and attacks; tap/click/Space adds combo-scaled bonus attacks.
- Enemy health, retaliation, death, coins, XP, level-ups, wave scaling, miniboss, boss, victory and defeat.
- Three-choice paused level-ups with 18 stacking upgrades. Every choice contributes Fire, Lightning, Poison, or Physical build tags.
- Fire builds stack burning damage and evolve into death explosions/spreading damage.
- Lightning builds trigger rhythm chain hits, with multihit improving chain damage and high-tier chains carrying power forward.
- Poison builds stack damage over time and evolve into healing/drain sustain.
- Physical builds trigger timed 2.2x heavy hits and combine naturally with crit, execute, armour, and weapon growth.
- Dominant tag counts produce Spark, Awakened (2 tags), and Ascended (5 tags) Relic Core evolution tiers.
- Three regular enemy behaviours: fast Razor Imp, armoured Mossback Brute, and ranged/healing Lantern Hexer.
- Clean portrait HUD and expressive procedural mascot with huge ears, tiny horns, one fang, curled tail, scavenger armour, glowing chest Relic Core, and a comically oversized weapon.
- Dominant builds visibly recolor/evolve the Relic Core, aura, HUD identity, and weapon markings; the weapon grows at 3 and 7 upgrades.
- Layered combat feel: auto-attack windup, weapon follow-through, player recoil, enemy squash/knockback, restrained shake/flash, stronger crits, death animation, and tap-combo feedback.
- Coins and XP visibly arc from defeated enemies toward their HUD counters; reward particles occupy the short spawn gap.
- Animated wave/miniboss/boss/upgrade banners and improved victory/defeat presentation.
- Large color-coded upgrade cards with placeholder icons, concise mechanical effects, build tag, rarity, and stack count.
- Star-shard run rewards and purchasable permanent +5% starting damage/HP ranks.
- ConfigFile save/load with type conversion and clamped values.
- Automated smoke test covers the full loop, restart, defeat, save path, and simulated tapping balance.

## CONTROLS
- Tap/click anywhere in the arena or press Space: bonus attack.
- Upgrade and result screens: press/click their buttons.
- Combat otherwise proceeds automatically.

## IMPORTANT FILES
- `main.tscn` - minimal root scene.
- `lootling.gd` - run/combat controller, UI/effects orchestration, and progression integration.
- `game_catalog.gd` - upgrade definitions, rarity colors, and display names.
- `build_system.gd` - extensible build tags, dominant identity, evolution tiers, palettes, and weapon tier.
- `creature_renderer.gd` - replaceable procedural Lootling/enemy placeholder rendering.
- `meta_store.gd` - validated permanent-progression persistence.
- `tests/smoke_test.gd` - end-to-end headless regression and balance simulation.
- `project.godot` - 480x854 mobile-first project settings.

## SYSTEMS
- Run state machine: `playing`, `upgrade`, `result`.
- Three regular enemies per wave; wave 8 and 15 are single special encounters.
- Implemented Relic identities are Fire, Lightning, Poison, and Physical only. Frost, Void, and Holy are reserved for later.
- Build mechanics are driven by tag counts rather than color-only stat bonuses.
- Enemy values scale exponentially; 20% HP recovery between waves keeps varied builds viable.
- Visual effects are lightweight draw calls and small transient dictionaries; no imported art or plugin dependencies.
- Save path: `user://lootlings_save.cfg`; currently stores version, star shards, and power rank.

## KNOWN BUGS
- No known gameplay/parser/runtime errors.
- Headless runs print a Windows root-certificate-store warning caused by the sandboxed test environment.
- Godot's dummy renderer crashes if asked to use Movie Maker; real OpenGL rendering and normal headless gameplay both pass.
- Procedural visuals remain replacement-ready placeholders; final character art and audio are intentionally deferred.

## LAST COMPLETED CHECKPOINT
Signature Relic Core identity checkpoint - four mechanical/visual builds, visible run evolution, enemy archetypes, tagged upgrades, and focused system extraction.

## NEXT TASK
Manually play at least one strongly focused run per identity. Check whether Fire explosions, Lightning rhythm chains, Poison drain, and Physical heavy-hit cadence are obvious without reading stats; verify Lantern Hexer ranged pressure and Mossback Brute fight length; then tune tag offering frequency and thresholds from feedback.
