# Lootlings Project State

## CURRENT STATE
Playable Godot 4.7.2 portrait vertical slice with a complete first-pass loot loop: fight, physical drop, rarity reveal, Equip/Keep/Scrap, persistent equipment, merchant spending, build growth, boss reward, results, and restart. A run spans 15 waves, includes a miniboss on wave 8 and a boss on wave 15. Stable fallbacks are `99ccc07` (base vertical slice), `bed14ba` (pre-identity polish), `8615f29` (pre-canonical-art integration), and `6f7a81e` (pre-loot-loop checkpoint).

## WHAT WORKS
- Automatic approach and attacks; tap/click/Space adds combo-scaled bonus attacks.
- Enemy health, retaliation, death, Coins, XP, level-ups, wave scaling, miniboss, boss, victory, defeat, and restart.
- Three-choice paused level-ups with 18 stacking upgrades. Fire, Lightning, Poison, and Physical Relic builds still combine freely with equipment.
- Four interchangeable weapon combat styles, with no permanent class lock: heavy/defensive Vanguard, ranged/rapid Ranger, ranged/proc Mage, and fast/crit/execute Rogue.
- Small data-driven equipment catalog covering Weapon, Armour, Relic, and Rune slots with named effects and future weapon-evolution metadata.
- Normal enemies have a restrained equipment chance; the wave 8 miniboss guarantees Rare+ and the wave 15 boss guarantees Epic+ with a Legendary chance. Drop chances and rarity weights are centralized.
- Equipment physically pops from enemies, bounces, casts a phone-readable rarity beam, and bursts on pickup. Normal finds queue until a wave-safe review instead of repeatedly interrupting combat.
- Large mobile item review shows rarity, slot/family, description, effects, and the currently equipped comparison, then offers Equip, Keep, or Scrap.
- Equipped gear applies combat effects immediately. Replaced non-starter gear returns to the stash where space allows; a full stash safely auto-scraps the replaced item.
- Persistent lightweight inventory has four equipped slots, a 12-item stash, and Scrap. The starter Scrapfang Blade is supplied when no weapon save exists.
- Optional Pack Peddler visits before waves 6 and 11 with three priced items, Buy, escalating Coin rerolls, and Continue. Purchases use the same item-decision flow and the shop is never mandatory.
- Coins are an in-run merchant currency, Scrap is persistent salvage currency, XP remains run leveling, and Star Shards retain the existing permanent-power purpose.
- Representative automatic item procs include crit Lightning, stronger/longer elemental effects, Mage repeat spells, kill shockwaves, boss/heavy bonuses, execute, low-health power, and coin bonuses.
- The canonical neutral Main Mascot RelicBeast remains the base player and is not recolored or redesigned as Emberhorn. Procedural weapon silhouettes now visibly change between mallet/blade, bow, staff, and daggers.
- Layered combat feel remains intact: windup/follow-through, recoil, squash/knockback, restrained shake/flash, crits, death animation, tap combo, arcing Coin/XP rewards, and wave/boss banners.
- The newly added canonical systems overview is indexed in `ART_REFERENCE_INDEX.md`; all canonical images remain reference-only and are not loaded at runtime.
- Automated smoke coverage now includes loot generation and rarity bounds, miniboss/boss guarantees, Equip/Keep/Scrap, inventory/Scrap save-load, equipment effects, weapon style differences, Coin earning/spending, merchant purchase/reroll, current Relic mechanics, the complete run, victory, defeat, and restart.

## CONTROLS
- Tap/click the arena or press Space: bonus attack.
- Upgrade screen: choose one of three cards.
- Item screen: Equip immediately, Keep in the persistent stash, or Scrap for persistent currency.
- Merchant: buy an affordable item, reroll stock with Coins, or Continue without spending.
- Combat otherwise proceeds automatically.

## IMPORTANT FILES
- `main.tscn` - minimal root scene.
- `lootling.gd` - run/combat controller and UI/effects orchestration.
- `game_catalog.gd` - run-upgrade definitions.
- `build_system.gd` - Relic tags, dominant identity, tiers, palettes, and weapon growth.
- `item_catalog.gd` - equipment definitions, rarities, effects, descriptions, and evolution hooks.
- `loot_system.gd` - centralized drop chances, rarity tables, seeded item rolls, and shop rolls.
- `inventory_system.gd` - equipped slots, stash, salvage, effect aggregation, and persistence.
- `shop_system.gd` - merchant stock, prices, reroll costs, and purchases.
- `creature_renderer.gd` - replaceable procedural mascot/enemy/weapon placeholder rendering.
- `meta_store.gd` - validated Star Shard/permanent-power persistence.
- `ART_REFERENCE_INDEX.md` - canonical filename/identity/system reference map.
- `art/reference/canonical/` - canonical visual source of truth; no runtime dependency.
- `tests/smoke_test.gd` - end-to-end regression, persistence checks, and seeded balance simulation.

## SYSTEMS
- Run states: `playing`, `upgrade`, `item`, `merchant`, and `result`.
- Three regular enemies per wave; waves 8 and 15 are single special encounters.
- Combat style is driven by the equipped Weapon family. Relic build is independent, allowing combinations such as Fire Ranger, Lightning Mage, Poison Rogue, and Physical Vanguard.
- Equipment slots are Weapon, Armour, Relic, and Rune. Stash capacity is intentionally small and mobile-friendly.
- Runtime visuals remain lightweight draw calls and bounded transient dictionaries; there is no asset pipeline expansion or node-heavy particle system.
- Save paths: `user://lootlings_save.cfg` stores Star Shards/power; `user://lootlings_inventory.cfg` stores equipped gear, stash, and Scrap.

## VALIDATION
- Headless smoke/regression suite passes. Current seeded tapping balance: 4 victories in 5 runs, with the failed run still reaching the final boss.
- Real OpenGL render capture passes at 480x854 on the Godot 4.7.2 Compatibility renderer with no parser/runtime errors.
- The Windows sandbox may print a root-certificate-store warning during headless tests; it does not affect gameplay or test results.

## KNOWN LIMITATIONS
- Procedural visuals remain replacement-ready placeholders; production sprites and audio are intentionally deferred.
- Kept stash items persist but there is not yet a separate out-of-run stash browser/forge screen. Items can currently be equipped at acquisition time.
- Weapon evolution paths are represented in catalog data for safe future extension; this checkpoint does not implement mutation choices or a large evolution tree.
- Scrap has a clear salvage/future-forge purpose and persists, but the forge itself is not implemented yet.
- Merchant stock is intentionally equipment-only in this first pass; healing/run-upgrade stock can be assessed after playtesting the core shop economy.

## LAST COMPLETED CHECKPOINT
Loot-loop checkpoint - physical rarity drops, meaningful item decisions, persistent equipment/stash/Scrap, optional Coin merchant, four weapon combat styles, extended regression coverage, and canonical systems-reference indexing.

## NEXT MANUAL PLAYTEST
Play two full runs on a phone-sized window. Verify that loot beams are noticed without feeling too frequent; item comparison is readable; Equip/Keep/Scrap feels quick; waves 6 and 11 merchant prices create real choices; Ranger/Mage spacing and Vanguard/Rogue impact are distinct; boss loot resolves before victory; and a restarted game retains equipment, stash, Scrap, Star Shards, and permanent power. Record any item that feels like an automatic choice and whether Coin income makes rerolls too cheap or too rare.
