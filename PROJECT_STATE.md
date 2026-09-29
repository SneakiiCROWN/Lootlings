# Lootlings Project State

## CURRENT STATE
Playable Godot 4.7.2 portrait vertical slice with a cohesive sprite-based 15-wave run and a fully illustrated interactive Hideout. The working meta economy, Stash, Relic Training, Shop, run, combat, rewards, and saves are preserved while Home, Salvager, Stash, and Shrine now use dedicated painted environments. Stable fallback `43f63f9` is the previous verified place-first Hideout checkpoint.

## WHAT WORKS
- Automatic approach and attacks; tap/click/Space adds combo-scaled bonus attacks.
- Hideout → Play → existing 15-wave run → Results → Return to Hideout is the new complete game loop. The previous run can still end in victory or defeat without a softlock.
- The Hideout Home screen presents the exact canonical neutral mascot, persistent Scrap/Star Shards/power, equipped Weapon/Armour/Charm, weapon family, neutral Core identity, and large mobile buttons.
- Hideout Home now uses a dedicated 480x854 treasure-den environment instead of the combat arena plus code-drawn props. The Expedition Gate, Relic Shrine, Salvager stall, Stash vault, Archive, lanterns, rugs, tools, treasure, and moonlit ruin depth are physical parts of the scene. Accessible translucent hotspots preserve the existing navigation.
- The canonical mascot remains unchanged and idles at the center of the Hideout with a subtle bob/contact shadow. Drifting motes add restrained scene life while the painted lantern, Relic, water, cloth, and moonlight details establish the environmental mood without obstructing tap targets.
- The former dominant loadout panel is reduced to a compact bottom expedition ribbon showing weapon/family, armour, Charm, and separate Relic Core identity.
- Stash is functional outside runs: equipped and stored gear are clearly separated; every item exposes rarity, slot, family, description/effects, and green/red same-slot comparison; stored items can be equipped or scrapped. All changes save immediately.
- Upgrades now owns the existing permanent +5% Damage/Max HP progression. It clearly shows level, total benefit, escalating Star Shard cost, and the separation between persistent Shards and run-only Coins.
- The Salvager's Shop is a functional persistent Hideout Shop with three rotating equipment offers, a Mystery Cache, one paid reroll per completed-run cycle, and finite Stash Expansion. Purchases use Scrap and go only to the persistent Stash.
- The Shop now has a dedicated illustrated salvage-stall environment and an original non-playable goblin-like Salvager artisan with goggles, tools, apron, counter, lanterns, scrap bins, Mystery Cache, and three physical offer plinths. The exact canonical mascot remains a separate visiting sprite. Tapping a translucent display opens the unchanged purchase card; buying leaves that exact display visibly `SOLD OUT`.
- Mystery Cache, Stash Expansion, reroll, Scrap budget, purchase feedback, and reveal/claim flow remain unchanged underneath their new scene presentation. Cache reveal, stock changes, and purchases provide clear visual state feedback.
- Shop offers are Common/Rare-heavy with only a small Epic chance and no normal Legendary offer path. Prices, rarity weights, cache cost, reroll cost, and capacity costs are centralized in one tuning file so boss/world drops remain the premium source.
- Mystery Cache uses a separate conservative rarity table and a two-step reveal/claim flow. The revealed item persists safely if the player leaves before claiming it.
- Shop stock persists across restarts, including sold-out state, and refreshes only after a completed victory or defeat. Restarting the app cannot refresh offers. Lootbook remains an honest `Coming Soon` destination.
- Stash Expansion persists through the data-driven 12 → 18 → 24 progression. Full-Stash purchases and cache openings are visibly blocked without spending Scrap or overwriting gear.
- Stash now has simple ALL/WEAPON/ARMOUR/CHARM/RUNE filters. Equipped and stored cards remain distinct, and equipped gear cannot be scrapped from this interface.
- Stash now uses a dedicated illustrated moonlit equipment vault with an open treasure chest, armour, weapon racks, charms, lanterns, rarity gems, and a calmer center for functional overlays. Its upper art receives more screen space, while compact rarity cards and the selected comparison card preserve filters, capacity, Equip/Scrap, and protection behavior. Weapon items reuse the existing family weapon sprites as real card thumbnails.
- Relic Training now uses a dedicated violet/cyan shrine chamber with a physical Relic Core altar, candles, carvings, offerings, and a staged mascot-to-core light connection. The exact canonical mascot remains a separate overlay; the permanent-power logic and costs are unchanged.
- Lootbook remains Coming Soon, but the notice now sits over the illustrated Hideout/Archive environment instead of a generated code-drawn bookshelf wall.
- Player-facing equipment terminology is standardized to WEAPON, ARMOUR, CHARM, and RUNE. The internal `Relic` equipment key remains unchanged for save compatibility, while RELIC CORE continues to describe the separate run-build system.
- Results now summarizes victory/defeat, wave reached, enemies defeated, Run Coins earned/spent/left, Scrap gained, Star Shards gained, and up to two notable kept/equipped loot names, then offers one `Return to Hideout` action.
- Active combat now has a small deliberate pause button. `RUN PAUSED` offers Resume or Abandon; Abandon requires a second confirmation with Stay/Return Home. Confirming discards only current run progress/unclaimed rewards, grants no result currency, does not refresh Hideout Shop stock, and returns directly to the Hideout.
- Hideout destination changes use a short 0.22-second fade, while native pressed/hover states provide immediate interaction feedback and leave clean attachment points for future UI audio.
- Enemy health, retaliation, death, Coins, XP, level-ups, wave scaling, miniboss, boss, victory, and defeat remain unchanged.
- Three-choice paused level-ups with 18 stacking upgrades. Fire, Lightning, Poison, and Physical Relic builds still combine freely with equipment.
- Four interchangeable weapon combat styles, with no permanent class lock: heavy/defensive Vanguard, ranged/rapid Ranger, ranged/proc Mage, and fast/crit/execute Rogue.
- Small data-driven equipment catalog covering Weapon, Armour, Relic, and Rune slots with named effects and future weapon-evolution metadata.
- Normal enemies have a restrained 7% equipment chance; the wave 8 miniboss guarantees one Rare+ item. The wave 15 boss visibly drops a three-item Epic+ hoard, then the player chooses one reward.
- Equipment physically pops from enemies, bounces, casts a phone-readable rarity beam, and bursts on pickup. Normal finds queue until a wave-safe review instead of repeatedly interrupting combat.
- Large mobile item review shows rarity, slot/family, description, effects, and the currently equipped comparison, then offers Equip, Keep, or Scrap.
- Equipped gear applies combat effects immediately. Replaced non-starter gear returns to the stash where space allows; a full stash safely auto-scraps the replaced item.
- Persistent lightweight inventory has four equipped slots, expandable 12/18/24-item Stash capacity, and Scrap. The starter Scrapfang Blade is supplied when no weapon save exists.
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
- Automated smoke coverage now includes all Hideout destinations, stable Shop display slots, inspect/buy foundations, pause freeze/resume, two-step abandon confirmation/cancel, reward-free abandon, no-refresh abandon, and all prior Shop/economy/save/combat/run regressions.

## CONTROLS
- Tap/click the arena or press Space: bonus attack.
- Hideout: Play begins a run; Stash manages persistent equipment; Upgrades spends Star Shards on permanent power; Shop spends Scrap on persistent equipment/capacity; Lootbook displays Coming Soon.
- Upgrade screen: choose one of three cards.
- Item screen: Equip immediately, Keep in the persistent stash, or Scrap for persistent currency.
- Merchant: buy an affordable item, reroll stock with Coins, or Continue without spending.
- Combat otherwise proceeds automatically.

## IMPORTANT FILES
- `main.tscn` - minimal root scene.
- `lootling.gd` - run/combat controller and UI/effects orchestration.
- `hideout_ui.gd` - modular Hideout Home, filtered Stash, persistent Shop, permanent Upgrades, and Coming Soon presentation/navigation.
- `hideout_shop_system.gd` - persistent Hideout stock, conservative rarity tables, Scrap prices, cache state, reroll cycle, and Stash Expansion costs.
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
- `art/backgrounds/lootlings_hideout.png` - dedicated painted Home hub with five physical destinations and central mascot stage.
- `art/backgrounds/salvager_shop.png` - illustrated Salvager NPC, counter, offer plinths, Mystery Cache, and salvage-stall environment.
- `art/backgrounds/stash_vault.png` - illustrated equipment vault, open gear chest, racks, armour, charms, and comparison-space backdrop.
- `art/backgrounds/relic_shrine.png` - illustrated Relic Training chamber, core altar, mascot stage, and upgrade-space backdrop.
- `art/sprites/weapons/` - transparent painterly Vanguard hammer, Ranger bow, Mage staff, and Rogue dagger-pair cutouts.
- `meta_store.gd` - validated Star Shard/permanent-power persistence.
- `ART_REFERENCE_INDEX.md` - canonical filename/identity/system reference map.
- `art/reference/canonical/` - canonical visual source of truth; no runtime dependency.
- `tests/smoke_test.gd` - end-to-end regression, persistence checks, and seeded balance simulation.

## SYSTEMS
- Top-level flow starts in `hideout`; run states include `playing`, `paused`, `abandon_confirm`, `upgrade`, `item`, `merchant`, `boss_reward`, and `result`.
- Three regular enemies per wave; waves 8 and 15 are single special encounters.
- Combat style is driven by the equipped Weapon family. Relic build is independent, allowing combinations such as Fire Ranger, Lightning Mage, Poison Rogue, and Physical Vanguard.
- Player-facing equipment slots are Weapon, Armour, Charm, and Rune. The internal `Relic` key is retained only for compatibility; Relic Core/build identity remains separate. Stash capacity progresses through 12, 18, and 24 slots.
- The player, all five reachable enemy roles, four weapon families, combat arena, Hideout Home, Salvager Shop, Stash, and Relic Shrine are texture-based. Loot glyphs, particles, and UI decoration remain lightweight draw calls or standard Controls.
- Save paths remain compatible: `user://lootlings_save.cfg` stores Star Shards/power; version-2 `user://lootlings_inventory.cfg` adds Stash capacity while loading version-1 saves at 12 slots; `user://lootlings_hideout_shop.cfg` stores stock/cycle/reroll/pending-cache state. Purchases and claims save immediately.

## VALIDATION
- Headless asset import/parser and full smoke/regression suites pass. Pause/abandon and interactive-destination assertions pass alongside all prior Shop, economy, capacity, legacy-save, combat, loot, persistence, and boss-reward checks. Current seeded tapping balance remains 4 victories in 5 runs.
- Real OpenGL 480x854 captures pass on the Godot 4.7.2 Compatibility renderer (NVIDIA GeForce RTX 4080 SUPER). Painted Home, illustrated Salvager/Shop, equipment-vault Stash, Relic Shrine, and Archive notice were re-inspected for clipping, hierarchy, readability, mascot fidelity, background visibility, and mobile tap targets. The unchanged combat view also renders normally.
- The Windows sandbox may print a root-certificate-store warning during headless tests; it does not affect gameplay or test results.

## KNOWN LIMITATIONS
- Loot-drop glyphs, small combat particles, and some general menu/HUD decoration remain procedural or standard-Control placeholders. Every enemy body reachable in the current 15-wave run is now sprite-based.
- Stash sorting and item locking are not implemented; filtering, comparison, equip, and stored-item scrap are functional. Forge remains out of scope.
- Weapon evolution paths are represented in catalog data for safe future extension; this checkpoint does not implement mutation choices or a large evolution tree.
- Scrap now funds the persistent Hideout Shop, Mystery Cache, reroll, and capacity expansion; Forge remains intentionally unimplemented.
- Merchant stock is intentionally equipment-only in this first pass; healing/run-upgrade stock can be assessed after playtesting the core shop economy.
- Lootbook remains Coming Soon. Its physical Archive nook exists in the Home art, but a full collectible compendium is intentionally deferred. The Hideout Shop intentionally sells only the existing catalog and has no real-world timer, premium currency, or unlimited inventory.
- Armour, Charm, and Rune list entries still use readable category glyphs because dedicated item art does not exist yet; weapon entries use the four existing painted family sprites. Loot particles and some UI decoration remain procedural/Control-based. No canonical character art was repainted or redesigned.

## LAST COMPLETED CHECKPOINT
Illustrated Hideout checkpoint - dedicated painted Home, Salvager Shop/NPC, equipment-vault Stash, and Relic Shrine environments replace code-drawn location props while preserving every existing interaction, economy, save, and run system.

## NEXT MANUAL PLAYTEST
At phone size, tap the edges and centers of every illustrated Home destination and confirm the labels remain readable over the art. In Shop, inspect a weapon thumbnail, buy an offer, verify its physical plinth becomes SOLD OUT, then test Cache reveal/claim and return. In Stash, scroll long inventories and compare/equip/scrap both weapon and non-weapon items. In Relic Training, buy one upgrade and confirm the shrine presentation stays readable. Enter a run once to confirm the Expedition Gate still transitions into unchanged combat.
