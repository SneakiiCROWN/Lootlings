# Lootlings Project State

## CURRENT STATE
Playable Godot 4.7.2 portrait vertical slice with a signature Relic Core build system and canonical art-aware placeholder presentation. A run spans 15 waves, includes a miniboss on wave 8 and a boss on wave 15, then awards permanent-progression currency and allows an immediate restart. Stable fallbacks are `99ccc07` (base vertical slice), `bed14ba` (pre-identity polish), and `8615f29` (pre-canonical-art integration).

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
- The procedural base player now follows the canonical neutral Main Mascot RelicBeast: warm beige/brown fur, huge pointed ears, small rock horns, amber eyes, visible fang, fluffy curled tail, partial scavenger armour, satchel, amber diamond Relic Core, and oversized patched hammer.
- The neutral mascot remains distinct from Emberhorn. Current build overlays borrow visual language without replacing the base character: Fire/Emberhorn, Lightning/Moonkip, Poison/Mosskin, and Physical/Pebblewyrm.
- Mossback Brute, Razor Imp, and Lantern Hexer silhouettes use clearer guardian, nimble, and shadow/ranged cues without representing the canonical playable characters themselves.
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
- `ART_REFERENCE_INDEX.md` - canonical filename/identity map and gameplay-presentation notes.
- `art/reference/canonical/` - canonical visual source of truth for the neutral mascot and six established character/class identities.
- `tests/smoke_test.gd` - end-to-end headless regression and balance simulation.
- `project.godot` - 480x854 mobile-first project settings.

## SYSTEMS
- Run state machine: `playing`, `upgrade`, `result`.
- Three regular enemies per wave; wave 8 and 15 are single special encounters.
- Implemented Relic identities are Fire, Lightning, Poison, and Physical only. Frost, Void, and Holy are reserved for later.
- Build mechanics are driven by tag counts rather than color-only stat bonuses.
- Canonical character identities are separate from Relic build identities. The neutral Main Mascot RelicBeast is the current player; Emberhorn, Mosskin, Moonkip, Pebblewyrm, Glimmerfin, and Gloomlet remain distinct established characters.
- Enemy values scale exponentially; 20% HP recovery between waves keeps varied builds viable.
- Runtime visuals remain lightweight draw calls and small transient dictionaries; canonical images are references only and are not loaded during gameplay.
- Save path: `user://lootlings_save.cfg`; currently stores version, star shards, and power rank.

## KNOWN BUGS
- No known gameplay/parser/runtime errors.
- Headless runs print a Windows root-certificate-store warning caused by the sandboxed test environment.
- Godot's dummy renderer crashes if asked to use Movie Maker; real OpenGL rendering and normal headless gameplay both pass.
- Procedural visuals remain replacement-ready placeholders; final character art and audio are intentionally deferred.

## LAST COMPLETED CHECKPOINT
Canonical visual-alignment checkpoint - neutral mascot corrected to the Main Mascot RelicBeast, separate character/class references indexed, current build motifs aligned, and gameplay preserved.

## NEXT TASK
Manually verify the neutral mascot reads clearly on a small phone, especially the ears, rock horns, fang, tail, satchel, chest core, and hammer. Confirm Fire/Lightning/Poison/Physical overlays remain distinct without making the mascot look like Emberhorn, Moonkip, Mosskin, or Pebblewyrm themselves. Production sprite integration remains a later pass.
