# Lootlings Project State

## CURRENT STATE
Playable Godot 4.7.2 portrait vertical slice with a cohesive sprite-based 15-wave run and the first functional Hideout/Home meta loop. The game now opens in the Hideout, supports pre-run loadout management and permanent upgrades, enters the unchanged run through Play, presents a complete run summary, and returns to the Hideout. The canonical neutral Main Mascot RelicBeast, all enemies, four weapon families, and treasure-ruin presentation remain intact. Stable fallback `d3ffbfd` is the previous verified playable-run checkpoint.

## WHAT WORKS
- Automatic approach and attacks; tap/click/Space adds combo-scaled bonus attacks.
- Hideout → Play → existing 15-wave run → Results → Return to Hideout is the new complete game loop. The previous run can still end in victory or defeat without a softlock.
- The Hideout Home screen presents the exact canonical neutral mascot, persistent Scrap/Star Shards/power, equipped Weapon/Armour/Charm, weapon family, neutral Core identity, and large mobile buttons.
- Stash is functional outside runs: equipped and stored gear are clearly separated; every item exposes rarity, slot, family, description/effects, and green/red same-slot comparison; stored items can be equipped or scrapped. All changes save immediately.
- Upgrades now owns the existing permanent +5% Damage/Max HP progression. It clearly shows level, total benefit, escalating Star Shard cost, and the separation between persistent Shards and run-only Coins.
- Lootbook and Hideout Shop are honest `Coming Soon` destinations with working back navigation; they do not introduce placeholder economies or unfinished interactions.
- Results now summarizes victory/defeat, wave reached, enemies defeated, Run Coins earned/spent/left, Scrap gained, Star Shards gained, and up to two notable kept/equipped loot names, then offers one `Return to Hideout` action.
- Enemy health, retaliation, death, Coins, XP, level-ups, wave scaling, miniboss, boss, victory, and defeat remain unchanged.
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
- Wave 8 Grump Knight and wave 15 Hoard Dragon now use dedicated transparent painted enemy cutouts instead of the procedural special-enemy blobs. Their existing names, stats, attack rules, milestones, rewards, and scaling are unchanged; special encounters add restrained gold/violet presence glows and subtle idle motion.
- Combat feedback adds stronger restrained hit tint, clearer crit recoil and radial burst, Relic-colored elemental rings, an expanding death ring, and brighter Coin glints with larger special-enemy reward bursts. Screen shake remains restrained and combat balance is unchanged.
- Large center banners are now reserved for boss/final/core moments. Ordinary waves and upgrade confirmations use a compact upper-arena banner; normal defeated/next-foe messages no longer compete with the action.
- Item decisions now show equipped gear, concise found-item identity, and up to three direct changes with green gain and red loss markers. `KEEP IN STASH` explicitly communicates storage while retaining the same Equip/Keep/Scrap behavior and tap targets.
- The unchanged-height bottom strip now gives Core/weapon identity and Scrap a single header row, with Damage, Rate, Crit, and Hits shown as four large-value cards instead of dense tiny summary text.
- Enemy HP now follows a smoother 1.15 per-wave curve; regular skirmisher/tank variance was narrowed while miniboss and boss multipliers remain clear deliberate spikes.
- Layered combat feel remains intact: windup/follow-through, recoil, squash/knockback, restrained shake/flash, crits, death animation, tap combo, arcing Coin/XP rewards, and wave/boss banners.
- The newly added canonical systems overview is indexed in `ART_REFERENCE_INDEX.md`; all canonical images remain reference-only and are not loaded at runtime.
- Automated smoke coverage now includes Hideout startup and return flow, stash equip/scrap and persistence, Hideout permanent-upgrade persistence, result summary content, loot generation and rarity bounds, miniboss/boss guarantees, equipment effects, weapon style differences, Coin earning/spending, merchant purchase/reroll, current Relic mechanics, the complete run, victory, and defeat.

## CONTROLS
- Tap/click the arena or press Space: bonus attack.
- Hideout: Play begins a run; Stash manages persistent equipment; Upgrades spends Star Shards on permanent power; Lootbook/Shop display Coming Soon.
- Upgrade screen: choose one of three cards.
- Item screen: Equip immediately, Keep in the persistent stash, or Scrap for persistent currency.
- Merchant: buy an affordable item, reroll stock with Coins, or Continue without spending.
- Combat otherwise proceeds automatically.

## IMPORTANT FILES
- `main.tscn` - minimal root scene.
- `lootling.gd` - run/combat controller and UI/effects orchestration.
- `hideout_ui.gd` - modular Hideout Home, Stash, permanent Upgrades, and Coming Soon presentation/navigation.
- `game_catalog.gd` - run-upgrade definitions.
- `build_system.gd` - Relic tags, dominant identity, tiers, palettes, and weapon growth.
- `item_catalog.gd` - equipment definitions, rarities, effects, descriptions, and evolution hooks.
- `loot_system.gd` - centralized drop chances, rarity tables, seeded item rolls, and shop rolls.
- `inventory_system.gd` - equipped slots, stash, salvage, effect aggregation, and persistence.
- `shop_system.gd` - merchant stock, prices, reroll costs, and purchases.
- `creature_renderer.gd` - canonical player-sprite presentation plus regular, miniboss, boss, and weapon sprite selection.
- `art/sprites/relic_beast_base.png` - transparent canonical mascot game sprite; generated by background extraction only from the canonical source artwork.
- `art/sprites/enemies/` - transparent Razor Imp, Mossback Brute, Lantern Hexer, Grump Knight, and Hoard Dragon cutouts.
- `art/backgrounds/treasure_ruins_arena.png` - layered portrait gameplay arena.
- `art/sprites/weapons/` - transparent painterly Vanguard hammer, Ranger bow, Mage staff, and Rogue dagger-pair cutouts.
- `meta_store.gd` - validated Star Shard/permanent-power persistence.
- `ART_REFERENCE_INDEX.md` - canonical filename/identity/system reference map.
- `art/reference/canonical/` - canonical visual source of truth; no runtime dependency.
- `tests/smoke_test.gd` - end-to-end regression, persistence checks, and seeded balance simulation.

## SYSTEMS
- Top-level flow starts in `hideout`; run states remain `playing`, `upgrade`, `item`, `merchant`, `boss_reward`, and `result`.
- Three regular enemies per wave; waves 8 and 15 are single special encounters.
- Combat style is driven by the equipped Weapon family. Relic build is independent, allowing combinations such as Fire Ranger, Lightning Mage, Poison Rogue, and Physical Vanguard.
- Equipment slots are Weapon, Armour, Relic, and Rune. Stash capacity is intentionally small and mobile-friendly.
- The player, all five reachable enemy roles, four weapon families, and arena are texture-based. Loot glyphs, particles, and UI decoration remain lightweight draw calls or standard Controls.
- Save paths and schemas remain compatible: `user://lootlings_save.cfg` stores Star Shards/power; `user://lootlings_inventory.cfg` stores equipped gear, stash, and Scrap. Hideout equip, scrap, and power purchases save immediately.

## VALIDATION
- Headless asset import/parser and full smoke/regression suites pass. The new Hideout/stash/meta/result assertions pass alongside all prior combat, loot, merchant, persistence, boss-reward, and Texture2D checks. Current seeded tapping balance remains 4 victories in 5 runs.
- Real OpenGL render captures pass at 480x854 on the Godot 4.7.2 Compatibility renderer (NVIDIA GeForce RTX 4080 SUPER) with no project parser/runtime errors. Hideout Home, populated Stash comparison, Relic Training, and Results were visually inspected for scale, clipping, hierarchy, readability, and mobile tap targets.
- The Windows sandbox may print a root-certificate-store warning during headless tests; it does not affect gameplay or test results.

## KNOWN LIMITATIONS
- Loot-drop glyphs, small combat particles, and some general menu/HUD decoration remain procedural or standard-Control placeholders. Every enemy body reachable in the current 15-wave run is now sprite-based.
- Stash sorting/filtering, item locking, and a Forge are intentionally not implemented yet; the current 12-slot browser covers inspect, compare, equip, and scrap safely.
- Weapon evolution paths are represented in catalog data for safe future extension; this checkpoint does not implement mutation choices or a large evolution tree.
- Scrap has a clear salvage/future-forge purpose and persists, but the forge itself is not implemented yet.
- Merchant stock is intentionally equipment-only in this first pass; healing/run-upgrade stock can be assessed after playtesting the core shop economy.
- Lootbook and the separate Hideout Shop are intentionally Coming Soon. The between-wave Pack Peddler remains the only functional shop.

## LAST COMPLETED CHECKPOINT
First Hideout/Home meta loop checkpoint - functional Home navigation, pre-run loadout summary, persistent Stash management, relocated permanent upgrades, complete Results summary, and return-to-Hideout flow without changing run gameplay.

## NEXT MANUAL PLAYTEST
Start from the Hideout with an existing save, inspect every equipped/stored slot, equip a stored item, scrap another, buy a permanent upgrade, and relaunch to confirm all three changes persist. Complete one victory and one defeat, checking the Results economy totals/notable loot and the single Return to Hideout action. Reconfirm that Play enters the unchanged run and that Lootbook/Hideout Shop communicate Coming Soon without trapping navigation.
