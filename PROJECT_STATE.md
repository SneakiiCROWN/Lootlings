# Lootlings Project State

## CURRENT STATE
Playable and visually polished Godot 4.7.2 portrait vertical slice. A run spans 15 waves, includes a miniboss on wave 8 and a boss on wave 15, then awards permanent-progression currency and allows an immediate restart. Stable fallback before the polish pass is commit `99ccc07`.

## WHAT WORKS
- Automatic approach and attacks; tap/click/Space adds combo-scaled bonus attacks.
- Enemy health, retaliation, death, coins, XP, level-ups, wave scaling, miniboss, boss, victory and defeat.
- Three-choice paused level-ups with 12 stacking upgrades: damage, speed, crit, multihit, shockwave carry-over, life steal, HP/armor, low-health frenzy, tap power, execute, regeneration, and extra rewards.
- Clean portrait HUD and expressive procedural characters with oversized heads, tiny adventurer bodies/clothing, readable faces, and a comically oversized weapon.
- Layered combat feel: auto-attack windup, weapon follow-through, player recoil, enemy squash/knockback, restrained shake/flash, stronger crits, death animation, and tap-combo feedback.
- Coins and XP visibly arc from defeated enemies toward their HUD counters; reward particles occupy the short spawn gap.
- Animated wave/miniboss/boss/upgrade banners and improved victory/defeat presentation.
- Large color-coded upgrade cards with placeholder icons, concise effects, rarity, and stack count.
- Star-shard run rewards and purchasable permanent +5% starting damage/HP ranks.
- ConfigFile save/load with type conversion and clamped values.
- Automated smoke test covers the full loop, restart, defeat, save path, and simulated tapping balance.

## CONTROLS
- Tap/click anywhere in the arena or press Space: bonus attack.
- Upgrade and result screens: press/click their buttons.
- Combat otherwise proceeds automatically.

## IMPORTANT FILES
- `main.tscn` - minimal root scene.
- `lootling.gd` - run/combat controller, procedural visuals, UI/effects, meta progression, and save/load.
- `game_catalog.gd` - upgrade definitions, rarity colors, and display names.
- `tests/smoke_test.gd` - end-to-end headless regression and balance simulation.
- `project.godot` - 480x854 mobile-first project settings.

## SYSTEMS
- Run state machine: `playing`, `upgrade`, `result`.
- Three regular enemies per wave; wave 8 and 15 are single special encounters.
- Enemy values scale exponentially; 20% HP recovery between waves keeps varied builds viable.
- Visual effects are lightweight draw calls and small transient dictionaries; no imported art or plugin dependencies.
- Save path: `user://lootlings_save.cfg`; currently stores version, star shards, and power rank.

## KNOWN BUGS
- No known gameplay/parser/runtime errors.
- Headless runs print a Windows root-certificate-store warning caused by the sandboxed test environment.
- Godot's dummy renderer crashes if asked to use Movie Maker; real OpenGL rendering and normal headless gameplay both pass.
- Procedural visuals remain replacement-ready placeholders; final character art and audio are intentionally deferred.

## LAST COMPLETED CHECKPOINT
Polish + Game Feel checkpoint - stable vertical slice plus combat impact, visual hierarchy, upgrade cards, encounter presentation, and maintainability pass.

## NEXT TASK
Touch-device playtest: verify rapid tapping comfort, card readability on a small screen, shake intensity, boss difficulty, and whether coin/XP flight and wave banners remain legible during busy multihit builds. Then tune from feedback before replacing placeholder art/audio.
