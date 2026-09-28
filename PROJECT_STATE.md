# Lootlings Project State

## CURRENT STATE
Playable Godot 4.7.2 portrait vertical slice. A run spans 15 waves, includes a miniboss on wave 8 and a boss on wave 15, then awards permanent-progression currency and allows an immediate restart.

## WHAT WORKS
- Automatic approach and attacks; tap/click/Space adds combo-scaled bonus attacks.
- Enemy health, retaliation, death, coins, XP, level-ups, wave scaling, miniboss, boss, victory and defeat.
- Three-choice paused level-ups with 12 stacking upgrades: damage, speed, crit, multihit, shockwave carry-over, life steal, HP/armor, low-health frenzy, tap power, execute, regeneration, and extra rewards.
- Portrait HUD, procedural placeholder characters, oversized weapon, hit squash/flash/shake, particles, and floating numbers.
- Star-shard run rewards and purchasable permanent +5% starting damage/HP ranks.
- ConfigFile save/load with type conversion and clamped values.
- Automated smoke test covers the full loop, restart, defeat, save path, and simulated tapping balance.

## CONTROLS
- Tap/click anywhere in the arena or press Space: bonus attack.
- Upgrade and result screens: press/click their buttons.
- Combat otherwise proceeds automatically.

## IMPORTANT FILES
- `main.tscn` - minimal root scene.
- `lootling.gd` - gameplay, procedural visuals, UI, effects, meta progression, and save/load.
- `tests/smoke_test.gd` - end-to-end headless regression and balance simulation.
- `project.godot` - 480x854 mobile-first project settings.

## SYSTEMS
- Run state machine: `playing`, `upgrade`, `result`.
- Three regular enemies per wave; wave 8 and 15 are single special encounters.
- Enemy values scale exponentially; 20% HP recovery between waves keeps varied builds viable.
- Save path: `user://lootlings_save.cfg`; currently stores version, star shards, and power rank.

## KNOWN BUGS
- No known gameplay/parser/runtime errors.
- Headless runs print a Windows root-certificate-store warning caused by the sandboxed test environment.
- Godot's dummy renderer crashes if asked to use Movie Maker; real OpenGL rendering and normal headless gameplay both pass.
- Placeholder visuals and balance are intentionally first-pass and should receive device playtesting.

## LAST COMPLETED CHECKPOINT
Checkpoint C - stable vertical slice, including all Checkpoint A and B requirements.

## NEXT TASK
Playtest on an actual touch device, tune run length/difficulty from player feedback, then replace procedural placeholder art/audio without changing gameplay architecture.
