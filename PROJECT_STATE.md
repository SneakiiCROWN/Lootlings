# Lootlings Project State

## CURRENT STATE
Playable Godot 4.7.2 portrait vertical slice with a cohesive sprite-based combat presentation. The canonical neutral Main Mascot RelicBeast remains the actual player artwork; regular enemies, all four weapon families, and the treasure-ruin arena now share a polished painterly style. The established 15-wave loot loop, equipment, merchant, Relic builds, miniboss, boss, persistence, results, and restart remain functional. Stable fallback `29fc459` is the previous verified enemy/arena presentation checkpoint.

## WHAT WORKS
- Automatic approach and attacks; tap/click/Space adds combo-scaled bonus attacks.
- Enemy health, retaliation, death, Coins, XP, level-ups, wave scaling, miniboss, boss, victory, defeat, and restart.
- Three-choice paused level-ups with 18 stacking upgrades. Fire, Lightning, Poison, and Physical Relic builds still combine freely with equipment.
- Four interchangeable weapon combat styles, with no permanent class lock: heavy/defensive Vanguard, ranged/rapid Ranger, ranged/proc Mage, and fast/crit/execute Rogue.
- Small data-driven equipment catalog covering Weapon, Armour, Relic, and Rune slots with named effects and future weapon-evolution metadata.
- Normal enemies have a restrained 7% equipment chance; the wave 8 miniboss guarantees one Rare+ item. The wave 15 boss visibly drops a three-item Epic+ hoard, then the player chooses one reward.
- Equipment physically pops from enemies, bounces, casts a phone-readable rarity beam, and bursts on pickup. Normal finds queue until a wave-safe review instead of repeatedly interrupting combat.
- Large mobile item review shows rarity, slot/family, description, effects, and the currently equipped comparison, then offers Equip, Keep, or Scrap.
- Equipped gear applies combat effects immediately. Replaced non-starter gear returns to the stash where space allows; a full stash safely auto-scraps the replaced item.
- Persistent lightweight inventory has four equipped slots, a 12-item stash, and Scrap. The starter Scrapfang Blade is supplied when no weapon save exists.
- Optional Pack Peddler visits before waves 6 and 11 with fixed Weapon, Armour, and Charm lanes plus reroll as the fourth utility action. Purchases use the same item-decision flow and the shop is never mandatory.
- Coins are an in-run merchant currency, Scrap is persistent salvage currency, XP remains run leveling, and Star Shards retain the existing permanent-power purpose.
- Representative automatic item procs include crit Lightning, stronger/longer elemental effects, Mage repeat spells, kill shockwaves, boss/heavy bonuses, execute, low-health power, and coin bonuses.
- The player body is a transparent game-ready cutout of the canonical neutral Main Mascot RelicBeast artwork itself, not a procedural approximation. Face, ears, horns, palette, eyes, tail, gear, satchel, Relic Core, proportions, and personality are preserved. Weapons remain separate overlays and change between mallet/blade, bow, staff, and daggers.
- Idle bob, gentle breathing tilt, movement, attack lean/recoil, hit squash, hurt tilt/tint, weapon swing, and restrained Relic aura/core overlays animate the sprite without repainting or replacing its identity. The mascot is approximately 9% larger in the 480x854 combat view.
- Regular enemy roles now use transparent sprite cutouts with phone-readable silhouettes: the crystal-spiked Razor Imp/Scrapper skirmisher, wide shielded Mossback Brute tank, and floating hooded Lantern Hexer caster. These are enemy species, not canonical playable Lootlings.
- The flat procedural battlefield is replaced by a portrait treasure-ruin environment with distant moonlit towers, layered arches and waterfalls, lanterns, crystals, treasure, a readable platform, contact shadows, and restrained darkening behind combatants.
- HUD and overlay styling now uses deeper navy surfaces, warm gold framing, stronger card shadows, and retained rarity-colored borders. Existing layout, interaction, and readable 480x854 text are preserved.
- Vanguard, Ranger, Mage, and Rogue now display transparent painterly weapon cutouts instead of line/polygon placeholders. Each weapon retains the existing windup, swing, family spacing, Relic-color accent, and weapon-tier growth while using readable stone, wood, bronze, leather, and crystal materials.
- The between-wave Pack Peddler is presented as an explicit `MERCHANT STOP` with a `BETWEEN WAVES` subtitle, visible run-Coin budget, three large slot-labelled offers, prices, rarity frames, and clearly separated Reroll/Continue actions.
- Floating combat text now uses short staggered lanes, duplicate damage-over-time suppression, a seven-message safety cap, calmer lifetimes, and a soft shadow. Heavy-hit callouts no longer hijack the large wave banner, and status messages use a restrained lower-arena pill.
- Enemy HP now follows a smoother 1.15 per-wave curve; regular skirmisher/tank variance was narrowed while miniboss and boss multipliers remain clear deliberate spikes.
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
- `creature_renderer.gd` - canonical player-sprite presentation, regular-enemy sprite selection, and replaceable weapon/special-enemy overlays.
- `art/sprites/relic_beast_base.png` - transparent canonical mascot game sprite; generated by background extraction only from the canonical source artwork.
- `art/sprites/enemies/` - transparent first-pass Razor Imp, Mossback Brute, and Lantern Hexer cutouts.
- `art/backgrounds/treasure_ruins_arena.png` - layered portrait gameplay arena.
- `art/sprites/weapons/` - transparent painterly Vanguard hammer, Ranger bow, Mage staff, and Rogue dagger-pair cutouts.
- `meta_store.gd` - validated Star Shard/permanent-power persistence.
- `ART_REFERENCE_INDEX.md` - canonical filename/identity/system reference map.
- `art/reference/canonical/` - canonical visual source of truth; no runtime dependency.
- `tests/smoke_test.gd` - end-to-end regression, persistence checks, and seeded balance simulation.

## SYSTEMS
- Run states: `playing`, `upgrade`, `item`, `merchant`, `boss_reward`, and `result`.
- Three regular enemies per wave; waves 8 and 15 are single special encounters.
- Combat style is driven by the equipped Weapon family. Relic build is independent, allowing combinations such as Fire Ranger, Lightning Mage, Poison Rogue, and Physical Vanguard.
- Equipment slots are Weapon, Armour, Relic, and Rune. Stash capacity is intentionally small and mobile-friendly.
- The player, three regular enemy roles, four weapon families, and arena are texture-based. Special enemies, loot glyphs, particles, and UI decoration remain lightweight draw calls or standard Controls.
- Save paths: `user://lootlings_save.cfg` stores Star Shards/power; `user://lootlings_inventory.cfg` stores equipped gear, stash, and Scrap.

## VALIDATION
- Headless asset import/parser and smoke/regression suites pass, including Texture2D import checks for the mascot, enemies, arena, and all four weapon cutouts. Current seeded tapping balance remains 4 victories in 5 runs.
- Real OpenGL render captures pass at 480x854 on the Godot 4.7.2 Compatibility renderer (NVIDIA GeForce RTX 4080 SUPER) with no parser/runtime errors. Vanguard, Ranger, Mage, Rogue, ordinary combat, and merchant-stop frames were visually inspected for alpha edges, scale, character occlusion, background contrast, shop clarity, tap-target size, and phone readability.
- The Windows sandbox may print a root-certificate-store warning during headless tests; it does not affect gameplay or test results.

## KNOWN LIMITATIONS
- Miniboss and boss bodies intentionally retain the previous procedural fallback in this safe first pass. Regular enemy bodies, the player, and the arena are now sprite-based.
- Loot glyphs, combat particles, miniboss/boss bodies, and some HUD/stat-strip decoration remain procedural or standard-Control placeholders. The four active weapon-family silhouettes no longer do.
- Kept stash items persist but there is not yet a separate out-of-run stash browser/forge screen. Items can currently be equipped at acquisition time.
- Weapon evolution paths are represented in catalog data for safe future extension; this checkpoint does not implement mutation choices or a large evolution tree.
- Scrap has a clear salvage/future-forge purpose and persists, but the forge itself is not implemented yet.
- Merchant stock is intentionally equipment-only in this first pass; healing/run-upgrade stock can be assessed after playtesting the core shop economy.

## LAST COMPLETED CHECKPOINT
Focused interface/weapon checkpoint - four painterly weapon-family cutouts, a clearly signposted between-wave merchant, calmer combat text, and tighter mobile UI hierarchy without gameplay-rule changes.

## NEXT MANUAL PLAYTEST
Play two full phone-sized runs. Watch each weapon through idle, windup, follow-through, hurt, and Relic-build growth; confirm the wave 6/11 Merchant Stop immediately communicates budget, offer type, price, affordability, reroll, and exit; and stress-test multihit plus Fire/Poison damage-over-time builds for calm readable floating text. Reconfirm the unchanged 7% normal drop cadence, guaranteed special rewards, boss choice, saves, and merchant tradeoffs.
