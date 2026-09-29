# Lootlings Project State

## CURRENT STATE
Playable Godot 4.7.2 portrait vertical slice with a real boot/title flow, persistent offline player identity, saved five-channel audio settings, original procedural placeholder audio, a living illustrated Hideout, and the validated sprite-based 15-wave expedition. Persistent Gold now provides the broad future economy foundation while temporary merchant currency is clearly named Run Scrip. Stable profile, chest, analytics, customisation, account-link, and solo/duo/swarm encounter contracts prepare later systems without replacing the working run. Stable fallback `7918c4ea466b6696decb9c4a60d12af3075ee88f` is the previous verified checkpoint.

## WHAT WORKS
- Automatic approach and attacks; tap/click/Space adds combo-scaled bonus attacks.
- Boot ignition → Title → first-launch Profile or returning-player menu → Hideout → 15-wave run → Results → Return to Hideout is the complete local game loop. Victory and defeat remain softlock-free.
- The short Relic Core boot beat is skippable and automatically resolves after 1.35 seconds. The title uses the canonical mascot, existing treasure-ruin world art, subtle orbiting motes, and three focused actions: Enter the Hideout, Profile, and Settings.
- Local profile schema stores a stable UUID separately from editable display name, optional Lootling nickname, icon/title/banner/current-Lootling IDs, cosmetic/badge/loadout references, boss/Legendary counters, future clan placeholders, rename metadata, and a future Google Play Games Services v2/cloud-link record. Returning players are never asked to name themselves again.
- Settings persist Master, Music, SFX, UI, and Ambience volumes plus independent mutes and apply them to native Godot buses.
- `AudioManager` provides bounded reusable event voices and original runtime-synthesized placeholder feedback/music hooks. No external audio or unknown licence was added.
- Local analytics writes schema-versioned, PII-filtered JSON lines only on device. It has event hooks for startup/profile, navigation, runs/zones/kills, progression, gear/chests, shops, Gold/Scrap, and Run Scrip; no paid service or network collection exists.
- The Hideout Home screen presents the exact canonical neutral mascot, persistent Scrap/Star Shards/power, equipped Weapon/Armour/Charm, weapon family, neutral Core identity, and large mobile buttons.
- Hideout Home now uses a dedicated 480x854 treasure-den environment instead of the combat arena plus code-drawn props. The Expedition Gate, Relic Shrine, Salvager stall, Stash vault, Archive, lanterns, rugs, tools, treasure, and moonlit ruin depth are physical parts of the scene. Large safe hotspots remain, but their idle boxes are virtually invisible so physical destinations and restrained labels carry the interaction hierarchy; hover/press feedback remains clear.
- The canonical mascot remains unchanged and idles at the center of the Hideout with a subtle bob/contact shadow. Drifting motes add restrained scene life while the painted lantern, Relic, water, cloth, and moonlight details establish the environmental mood without obstructing tap targets.
- The former dominant loadout panel is reduced to a compact two-line bottom expedition ribbon showing weapon/family, armour, Charm, and separate Relic Core identity.
- Stash is functional outside runs: equipped and stored gear are clearly separated; every item exposes rarity, slot, family, description/effects, and green/red same-slot comparison; stored items can be equipped or scrapped. All changes save immediately.
- Upgrades retains the existing permanent +5% Damage/Max HP progression. It clearly shows level, total benefit, escalating Star Shard cost, and the separation between persistent Shards and run-only Run Scrip. Its controlled future progression-board evolution is documented rather than prematurely implemented.
- The Salvager's Shop is a functional persistent Hideout Shop with three rotating equipment offers, a Mystery Cache, one paid reroll per completed-run cycle, and finite Stash Expansion. Purchases use Scrap and go only to the persistent Stash.
- The Shop now has a dedicated illustrated salvage-stall environment and an original non-playable goblin-like Salvager artisan with goggles, tools, apron, counter, lanterns, scrap bins, Mystery Cache, and three physical offer plinths. The exact canonical mascot remains a separate visiting sprite. Unselected display cards are quieter, selecting one opens a compact detail panel, and buying clears that panel while the exact physical plinth receives a faded `SOLD OUT` label and crossed display treatment.
- Mystery Cache, Stash Expansion, reroll, Scrap budget, purchase feedback, and reveal/claim flow remain unchanged underneath their new scene presentation. Cache reveal adds a short shake, glow, burst, and readable result; purchases pulse the selected display/resource total; Stash Equip/Scrap and Shrine upgrades use concise local confirmation sparks without adding modal interruptions.
- Shop offers are Common/Rare-heavy with only a small Epic chance and no normal Legendary offer path. Prices, rarity weights, cache cost, reroll cost, and capacity costs are centralized in one tuning file so boss/world drops remain the premium source.
- Mystery Cache uses a separate conservative rarity table and a two-step reveal/claim flow. The revealed item persists safely if the player leaves before claiming it.
- Shop stock persists across restarts, including sold-out state, and refreshes only after a completed victory or defeat. Restarting the app cannot refresh offers. Lootbook remains an honest `Coming Soon` destination.
- Stash Expansion persists through the data-driven 12 → 18 → 24 progression. Full-Stash purchases and cache openings are visibly blocked without spending Scrap or overwriting gear.
- Stash now has simple ALL/WEAPON/ARMOUR/CHARM/RUNE filters. Equipped and stored cards remain distinct, and equipped gear cannot be scrapped from this interface.
- Stash now uses a dedicated illustrated moonlit equipment vault with an open treasure chest, armour, weapon racks, charms, lanterns, rarity gems, and a calmer center for functional overlays. Its upper art receives more screen space, while compact rarity cards and the selected comparison card preserve filters, capacity, Equip/Scrap, and protection behavior. Weapon items reuse the existing family weapon sprites as real card thumbnails.
- Relic Training now uses a dedicated violet/cyan shrine chamber with a physical Relic Core altar, candles, carvings, offerings, and a staged mascot-to-core light connection. The exact canonical mascot remains a separate overlay; the upgrade panel is shorter and sits below the altar, while the permanent-power logic and costs are unchanged.
- Lootbook remains Coming Soon, but the notice now sits over the illustrated Hideout/Archive environment instead of a generated code-drawn bookshelf wall.
- Player-facing equipment terminology is standardized to WEAPON, ARMOUR, CHARM, and RUNE. The internal `Relic` equipment key remains unchanged for save compatibility, while RELIC CORE continues to describe the separate run-build system.
- Results now responsively separates temporary Run Scrip earned/spent/left from persistent Gold, Scrap, and Star Shards, plus wave, enemies, notable loot, and one `Return to Hideout` action. Four-digit stress values and long loot names remain visible at 480x854.
- Active combat now has a small deliberate pause button. `RUN PAUSED` offers Resume or Abandon; Abandon requires a second confirmation with Stay/Return Home. Confirming discards only current run progress/unclaimed rewards, grants no result currency, does not refresh Hideout Shop stock, and returns directly to the Hideout.
- Hideout destination changes use a short 0.22-second fade, while native pressed/hover states provide immediate interaction feedback and leave clean attachment points for future UI audio.
- Enemy health, retaliation, death, Run Scrip, XP, level-ups, wave scaling, miniboss, boss, victory, and defeat remain unchanged.
- The expedition is now data-driven through `zone_catalog.gd`: waves 1–5 are Outer Treasure Ruins, 6–10 are Salvage Warrens, and 11–15 are Hoard Depths. Every zone has a stable ID, name, wave range, background, accent/atmosphere, regular-enemy definitions, deterministic composition table, boss hooks, and future music/loot-theme hooks.
- Wave 6 introduces Cinder Gnawer, Scrap Golem, and Kiln Wisp; wave 11 introduces Gemfang Wyrmling, Vaultbound Sentinel, and Shardseer. These replacement-ready painted enemy cutouts preserve the validated skirmisher/tank/caster mechanics while changing zone identity and silhouette.
- Same-wave normal kills hand off in 0.48 seconds and use only a small player backstep. New waves, zones, and special encounters retain deliberate repositioning. Run Scrip/XP travel continues while the next regular enemy enters, while a real equipment drop still protects a 1.2-second reveal window.
- Newly spawned enemies receive a predictable first-hit clock rather than stale timing. No raw damage, attack-rate, HP, healing, boss, loot-odds, or reward values were changed in this checkpoint.
- One bonus tap can buffer for up to 0.45 seconds during final approach, with an immediate ring response and a 0.11-second request ceiling. It fires once on reaching attack range; burst input cannot queue an attack backlog. The permanent help line disappears after the first successful tap.
- Weapon-family idle transform timing now communicates weight (Vanguard), rhythm (Ranger/Mage), or sharpness (Rogue); tap strikes receive slightly stronger lean/stretch. Skirmishers, tanks, casters, minibosses, and bosses receive restrained role-specific transform motion, with a small caster pre-cast glow.
- Ordinary wave and upgrade events now use a single confirmation lane. Heavy Physical hits combine their identity and damage into one `QUAKE` result instead of stacking `QUAKE BONK` and damage text.
- The encounter counter reads `FOE 1 / 3` while the first foe is active. Combat-only encounter/name/HP/status/build-strip elements are suppressed during upgrade, equipment, merchant, boss-reward, result, and zone-transition states.
- Pack Peddler keeps the same three equipment lanes, balance, and Continue behavior while presenting the temporary budget as Run Scrip. Prices remain `[58, 108, 185, 320] + 6 × wave` by rarity; rerolls remain `55 + 6 × wave + 25 × prior rerolls`.
- Wave 5 and 10 interstitial work resolves before a short 0.85-second travel card. `DESCENDING INTO THE EMBERWORKS / SALVAGE WARRENS` and `THE VAULT OPENS / HOARD DEPTHS` then hand off to the next zone without stacked wave banners.
- Zone ambience is bounded draw-time presentation rather than accumulating nodes: cool motes in Outer Ruins, ember drift in Salvage Warrens, and restrained gold/violet glints in Hoard Depths.
- Three-choice paused level-ups with 18 stacking upgrades. Fire, Lightning, Poison, and Physical Relic builds still combine freely with equipment.
- Four interchangeable weapon combat styles, with no permanent class lock: heavy/defensive Vanguard, ranged/rapid Ranger, ranged/proc Mage, and fast/crit/execute Rogue.
- Small data-driven equipment catalog covering Weapon, Armour, Relic, and Rune slots with named effects and future weapon-evolution metadata.
- Normal enemies have a restrained 7% equipment chance; the wave 8 miniboss guarantees one Rare+ item. The wave 15 boss visibly drops a three-item Epic+ hoard, then the player chooses one reward.
- Equipment physically pops from enemies, follows a short arc, bounces/squashes, briefly settles, casts rarity-scaled phone-readable glow/beam treatment, and bursts on pickup. Common treatment stays subtle, Rare glows more strongly, and Epic/Legendary gains controlled glints; normal finds still queue until a wave-safe review instead of repeatedly interrupting combat.
- Run Scrip and XP rewards briefly scatter from the defeated enemy before travelling to their HUD targets; arrival pulses the correct counter/bar and uses bounded pickup audio. Boss rewards use a larger but bounded shower, longer death burst, and three readable high-value loot markers without changing quantities or odds.
- Large mobile item review shows rarity, slot/family, description, effects, and the currently equipped comparison, then offers Equip, Keep, or Scrap.
- Equipped gear applies combat effects immediately. Replaced non-starter gear returns to the stash where space allows; a full stash safely auto-scraps the replaced item.
- Persistent lightweight inventory has four equipped slots, expandable 12/18/24-item Stash capacity, and Scrap. The starter Scrapfang Blade is supplied when no weapon save exists.
- Optional Pack Peddler visits before waves 6 and 11 with fixed Weapon, Armour, and Charm lanes plus reroll as the fourth utility action. Purchases use the same item-decision flow and the shop is never mandatory.
- Gold is persistent broad/everyday currency; Scrap is persistent gear/salvage currency; Star Shards remain rare Relic/meta progression; Run Scrip is temporary merchant currency and resets every run; XP remains run leveling. Version-1 meta saves migrate Gold to zero without losing Shards or power.
- Representative automatic item procs include crit Lightning, stronger/longer elemental effects, Mage repeat spells, kill shockwaves, boss/heavy bonuses, execute, low-health power, and Run Scrip bonuses.
- The player body is a transparent game-ready cutout of the canonical neutral Main Mascot RelicBeast artwork itself, not a procedural approximation. Face, ears, horns, palette, eyes, tail, gear, satchel, Relic Core, proportions, and personality are preserved. Weapons remain separate overlays and change between mallet/blade, bow, staff, and daggers.
- Idle bob, gentle breathing tilt, movement, attack lean/recoil, hit squash, hurt tilt/tint, weapon swing, and restrained Relic aura/core overlays animate the sprite without repainting or replacing its identity. The mascot is approximately 9% larger in the 480x854 combat view.
- Regular enemy roles now use transparent sprite cutouts with phone-readable silhouettes: the crystal-spiked Razor Imp/Scrapper skirmisher, wide shielded Mossback Brute tank, and floating hooded Lantern Hexer caster. These are enemy species, not canonical playable Lootlings.
- The flat procedural battlefield is replaced by a portrait treasure-ruin environment with distant moonlit towers, layered arches and waterfalls, lanterns, crystals, treasure, a readable platform, contact shadows, and restrained darkening behind combatants.
- HUD and overlay styling now uses deeper navy surfaces, warm gold framing, stronger card shadows, and retained rarity-colored borders. Existing layout, interaction, and readable 480x854 text are preserved.
- Vanguard, Ranger, Mage, and Rogue now display transparent painterly weapon cutouts instead of line/polygon placeholders. Each weapon retains the existing windup, swing, family spacing, Relic-color accent, and weapon-tier growth while using readable stone, wood, bronze, leather, and crystal materials.
- The between-wave Pack Peddler is presented as an explicit roadside stop with a visible Run Scrip budget, three large slot-labelled offers, prices, rarity frames, and clearly separated Reroll/Continue actions.
- Floating combat text now uses short staggered lanes, duplicate damage-over-time suppression, a five-message safety cap, calmer lifetimes, and a soft shadow. Heavy-hit callouts no longer hijack the large wave banner, and status messages use a restrained lower-arena pill.
- Floating messages now also use stable damage/proc/secondary/reward/player lanes, keeping simultaneous crit, elemental, loot, and hurt feedback away from faces and each other.
- Wave 8 Grump Knight and wave 15 Hoard Dragon use dedicated transparent painted enemy cutouts instead of procedural special-enemy blobs. The Hoard Dragon was replaced with a cleaner single-body cutout: one head/jaw, exactly two forelimbs, one tail, controlled violet crystal ridge, dark scales, pale underside, and gold relic bindings. Names, stats, attack rules, milestones, rewards, and scaling are unchanged; the boss receives one restrained gold halo/two-seal motif.
- Combat feedback adds stronger restrained hit tint, clearer crit/heavy recoil and radial burst, Relic-colored elemental rings, an expanding death ring, and brighter Run Scrip glints with larger special-enemy reward bursts. A very short visual-only impact freeze does not pause combat clocks, screen shake remains restrained, and seeded balance is unchanged.
- Large center banners are reserved for boss/final moments. Ordinary waves, upgrade confirmations, and Core awakenings use a compact banner in the clear band below enemy HP; Core transformations prioritize the chest flare and elemental rings without a duplicate lower status message. Floating messages are capped at five and the boss reward burst avoids a redundant Scrip label.
- Item decisions now show equipped gear, concise found-item identity, and up to three direct changes with green gain and red loss markers. `KEEP IN STASH` explicitly communicates storage while retaining the same Equip/Keep/Scrap behavior and tap targets.
- The unchanged-height bottom strip now gives Core/weapon identity and Scrap a single header row, with Damage, Rate, Crit, and Hits shown as four large-value cards instead of dense tiny summary text.
- Melee positions are role-aware: regulars, tanks, Grump Knight, and Hoard Dragon settle at progressively safer anchors, while ranged families retain their established distance. Player attacks gain a slightly stronger visual lunge and enemies answer with a short visual-only attack lunge; damage timing and balance are unchanged.
- Waves 8 and 15 use a single 0.8-second pre-encounter hierarchy (`MINIBOSS AHEAD` / `FINAL WAVE`). The special spawns without a second full banner, and its name/HP waits until the entry beat has begun.
- The pause control now occupies the clear top-center HUD gap instead of competing with HP. Upgrade cards use wider content-safe controls and a consistent icon/name/rarity then tag/effect hierarchy; all 18 cards, including stacked three-line variants, fit at 480x854.
- Long item titles dynamically reduce only as far as 18 px and wrap inside a two-line title region. Equip/Keep/Scrap, rarity, slot/family, and green/red deltas remain visible and unchanged functionally.
- Hoard Dragon rewards eject on three visibly different arcs with a short protected reveal, readable Weapon/Armour/Charm/Rune glyph labels, a stronger restrained death burst, and the existing choose-one Epic+ flow. Normal gear keeps its protected reveal and existing probabilities.
- Relic Magnet remains a neutral utility upgrade that grants +25% Run Scrip and +15% XP. Scrip and XP multipliers remain tracked separately.
- The accepted Hideout gains bounded life without changing its background: a tiny code-drawn scavenger wanders the lower floor and an occasional reusable speech bubble rotates six original, short, loot-obsessed lines. It never runs continuously or blocks destination hitboxes.
- A shared `LootlingsUI` component/palette layer now centralizes physical navy/gold panel and button styles for new screens and future incremental adoption.
- Stable chest data defines Scavenged Cache, Relic Chest, and Hoard Chest with rarity floor, roll count, special-pool flag, accent, and shared drop/land/anticipate/open/burst/eject/settle/reveal phases. The current Mystery Cache and boss hoard remain mechanically unchanged; broader chest sources are roadmap hooks.
- Zone encounters now expose a stable encounter container supporting `solo`, `duo`, and `small_swarm`; all live encounters remain solo. The optional swarm demonstration was deliberately deferred so targeting/AoE/wave boundaries are not destabilized.
- Poison damage heals only after taking Plague Siphon; merely reaching three Poison affinity no longer silently grants siphon. Plague Siphon scales from 15% to a 20% cap, and Toxic Fang sustain stacks to an 8% lifesteal cap. Poison damage, duration, regeneration, and build identity otherwise remain intact.
- Enemy HP now follows a smoother 1.15 per-wave curve; regular skirmisher/tank variance was narrowed while miniboss and boss multipliers remain clear deliberate spikes.
- Layered combat feel remains intact: windup/follow-through, recoil, squash/knockback, restrained shake/flash, crits, death animation, tap combo, arcing Run Scrip/XP rewards, and wave/boss banners.
- The newly added canonical systems overview is indexed in `ART_REFERENCE_INDEX.md`; all canonical images remain reference-only and are not loaded at runtime.
- Automated smoke coverage now includes all Hideout destinations, stable Shop display slots, inspect/buy foundations, pause freeze/resume, two-step abandon confirmation/cancel, reward-free abandon, no-refresh abandon, and all prior Shop/economy/save/combat/run regressions.

## CONTROLS
- Tap/click the arena or press Space: bonus attack.
- Hideout: Play begins a run; Stash manages persistent equipment; Upgrades spends Star Shards on permanent power; Shop spends Scrap on persistent equipment/capacity; Lootbook displays Coming Soon.
- Upgrade screen: choose one of three cards.
- Item screen: Equip immediately, Keep in the persistent stash, or Scrap for persistent currency.
- Merchant: buy an affordable item, reroll stock with Run Scrip, or Continue without spending.
- Combat otherwise proceeds automatically.

## IMPORTANT FILES
- `main.tscn` - minimal root scene.
- `lootling.gd` - run/combat controller and UI/effects orchestration.
- `startup_ui.gd` - boot, title, first-launch/profile editing, and audio-settings presentation.
- `profile_store.gd` - offline-first profile schema, stable UUID, customisation/social fields, and future account-link metadata.
- `settings_store.gd` - persistent five-channel volume/mute settings.
- `audio_manager.gd` - native Godot buses, bounded event voices, cue routing, and original procedural placeholder audio.
- `analytics_logger.gd` - local-only PII-filtered JSONL event abstraction.
- `lootlings_ui.gd` - shared navy/gold panel/button component styling for new UI.
- `chest_catalog.gd` - stable chest qualities, reward rules, sources, and presentation phases.
- `hideout_ui.gd` - modular Hideout Home, filtered Stash, persistent Shop, permanent Upgrades, and Coming Soon presentation/navigation.
- `hideout_shop_system.gd` - persistent Hideout stock, conservative rarity tables, Scrap prices, cache state, reroll cycle, and Stash Expansion costs.
- `game_catalog.gd` - run-upgrade definitions.
- `build_system.gd` - Relic tags, dominant identity, tiers, palettes, and weapon growth.
- `item_catalog.gd` - equipment definitions, rarities, effects, descriptions, and evolution hooks.
- `loot_system.gd` - centralized drop chances, rarity tables, seeded item rolls, and shop rolls.
- `inventory_system.gd` - equipped slots, stash, salvage, effect aggregation, and persistence.
- `shop_system.gd` - merchant stock, prices, reroll costs, and purchases.
- `zone_catalog.gd` - stable zone IDs, wave ranges, backgrounds, palettes, enemy identity/composition data, special-enemy hooks, and future audio/loot-theme hooks.
- `creature_renderer.gd` - canonical player-sprite presentation plus regular, miniboss, boss, and weapon sprite selection.
- `art/sprites/relic_beast_base.png` - transparent canonical mascot game sprite; generated by background extraction only from the canonical source artwork.
- `art/sprites/enemies/` - transparent zone atlases plus Razor Imp, Mossback Brute, Lantern Hexer, Grump Knight, and Hoard Dragon cutouts.
- `art/backgrounds/treasure_ruins_arena.png` - layered portrait gameplay arena.
- `art/backgrounds/salvage_warrens_arena.png` - dedicated ancient-forge Salvage Warrens arena.
- `art/backgrounds/hoard_depths_arena.png` - dedicated sealed-vault Hoard Depths arena.
- `art/backgrounds/lootlings_hideout.png` - dedicated painted Home hub with five physical destinations and central mascot stage.
- `art/backgrounds/salvager_shop.png` - illustrated Salvager NPC, counter, offer plinths, Mystery Cache, and salvage-stall environment.
- `art/backgrounds/stash_vault.png` - illustrated equipment vault, open gear chest, racks, armour, charms, and comparison-space backdrop.
- `art/backgrounds/relic_shrine.png` - illustrated Relic Training chamber, core altar, mascot stage, and upgrade-space backdrop.
- `art/sprites/weapons/` - transparent painterly Vanguard hammer, Ranger bow, Mage staff, and Rogue dagger-pair cutouts.
- `meta_store.gd` - validated Star Shard/permanent-power persistence.
- `MASTER_ROADMAP.md` - staged long-term gameplay, content, profile, mode, social, online, trading, event, and future-only monetisation direction.
- `AUDIO_LICENSES.md` / `ASSET_PROVENANCE.md` - audio and important runtime-asset origin/licence records.
- `ART_REFERENCE_INDEX.md` - canonical filename/identity/system reference map.
- `art/reference/canonical/` - canonical visual source of truth; no runtime dependency.
- `tests/smoke_test.gd` - end-to-end regression, persistence checks, and seeded balance simulation.
- `tests/balance_audit.gd` - reproducible 96-run weapon/Core/seed matrix with run-time, win, level, HP, damage taken, Run Scrip, spend, reroll, Scrap, upgrade-timing, and sustain reporting.

## SYSTEMS
- Top-level flow starts in `boot`; startup screens cover title/profile/settings, while run states include `hideout`, `playing`, `special_intro`, `zone_transition`, `paused`, `abandon_confirm`, `upgrade`, `item`, `merchant`, `boss_reward`, and `result`.
- Three regular enemies per wave; waves 8 and 15 are single special encounters.
- Combat style is driven by the equipped Weapon family. Relic build is independent, allowing combinations such as Fire Ranger, Lightning Mage, Poison Rogue, and Physical Vanguard.
- Player-facing equipment slots are Weapon, Armour, Charm, and Rune. The internal `Relic` key is retained only for compatibility; Relic Core/build identity remains separate. Stash capacity progresses through 12, 18, and 24 slots.
- The player, all eleven reachable enemy identities, four weapon families, three combat arenas, Hideout Home, Salvager Shop, Stash, and Relic Shrine are texture-based. Loot glyphs, particles, and UI decoration remain lightweight draw calls or standard Controls.
- Save paths remain compatible: version-2 `user://lootlings_save.cfg` adds Gold while version-1 Shards/power load unchanged; version-2 `user://lootlings_inventory.cfg` adds Stash capacity while loading version-1 saves at 12 slots; `user://lootlings_hideout_shop.cfg` stores stock/cycle/reroll/pending-cache; `user://lootlings_profile.cfg` stores local identity; `user://lootlings_settings.cfg` stores audio; local events use `user://lootlings_events.jsonl`. Purchases, profile changes, settings, and claims save immediately.

## BALANCE / ECONOMY AUDIT
- Current player baseline remains 11 damage, 0.85-second base attack interval, 8% crit at 2x, and 0.65x tap power before equipment/build modifiers. Weapon personalities remain Vanguard slow/heavy, Ranger quick, Mage measured/proc-driven, and Rogue fastest/crit-driven.
- Enemy HP remains `(24 + 7 × wave) × 1.15^(wave-1)` before archetype/special multipliers; regular role multipliers, enemy damage/intervals, 20% completed-wave heal, miniboss 2.65x HP, and boss 4.8x HP are unchanged. The heal materially helps marginal builds but did not erase the spread in the matrix.
- XP remains `13 + 2.2 × wave` before special/reward modifiers; level requirements remain `32 + 15 × current level`. Upgrade/Core timing therefore changes only when an existing build earns bonus XP.
- The corrected permanent audit covers 96 deterministic runs: four weapons × four Core biases × six seeds. Its active-shopper policy attempts up to two purchases at each stop, makes one affordable reroll only when needed, and records damage taken, earned/spent/left Run Scrip, buys, rerolls, Scrap, residual XP, upgrades, awaken/ascend timing, lifesteal, regeneration, and Plague power.
- Before the balance correction, the 48-run matrix recorded Poison at 12/12 wins versus 5/36 for all other Core biases, with Poison reaching roughly level 14.7–18.7 because the Poison-tagged Relic Magnet fed +50% XP and temporary currency back into further upgrades. Separating the multipliers, removing its Poison tag, and requiring actual Plague Siphon for poison healing eliminated that progression loop.
- In the final 96-run matrix, Poison won 13/24 and non-Poison pairings won 12/72. Poison finishes around level 10.8–11.5, now comparable with other identities, while retaining a deliberate sustain advantage. By weapon, Poison wins were Vanguard 5/6, Ranger 4/6, Mage 2/6, and Rogue 2/6; non-Poison wins included Physical Vanguard/Ranger, Lightning and Physical Mage, and one win in each Rogue non-Poison bias. The simulator is a consistency lens rather than a human-skill balance target, so no broad weapon or enemy rebalance was added.
- Final average Run Scrip earned spans 672.5–919.0 across the matrix. Average spending spans 350.3–410.3, leftovers 294.3–537.3, purchases 2.7–3.2, and rerolls 0.0–0.5 per run. This absorbs roughly 43–57% of typical income while preserving the choice to save. Wave-6 Common/Rare prices are 94/144; wave-11 Rare is 174; first rerolls cost 91 and 121 respectively.
- The five-seed tapping smoke simulation currently produces 2/5 victories while still completing the full victory and defeat paths without softlock. Its purpose is regression safety, not the build matrix; the dedicated audit above is the reproducible balance record.
- Loot remains 7% on regular foes, guaranteed Rare+ at Grump Knight, and a three-item Epic+ Hoard Dragon choice. Inventory/save behavior, rarity tables, Scrap yields, Star Shards, persistent Hideout Shop/cache/reroll/capacity prices, and auto-scrap protection were not changed.
- Remaining balance watchpoint: Poison still has the clearest sustain identity and wins more deterministic policy runs than other Core biases. Manually compare Poison and non-Poison runs before making any further numerical change; the former runaway XP/Run Scrip coupling is no longer present.

## VALIDATION
- Foundation validation covers fresh-profile creation, normal-launch title flow, stable UUID and display-name editing, optional nickname, future account-link fields, version-1 meta migration, persistent Gold, separate Run Scrip reset/spending, audio bus creation, saved volumes/mutes, chest definitions/phases, and future encounter-kind hooks.
- Headless asset import/parser, normal runtime, full smoke/regression/persistence/economy suite, and the corrected 96-run audit pass. Pause/abandon, reward-free abandon/no-refresh behavior, interactive destinations, save compatibility, merchant/item flow, exact prices/rerolls, tap buffering/ceiling, role spacing, special introductions, no-drop/drop timing, zone handoff, Relic Magnet semantics, item-title fitting, all 18 upgrade formats, three-arc boss loot, responsive results, combat, loot, and boss-reward assertions pass. Current seeded tapping smoke completes with 2 victories in 5 runs.
- Real OpenGL 480x854 captures pass on the Godot 4.7.2 Compatibility renderer (NVIDIA GeForce RTX 4080 SUPER). Boot, title, first-launch/Profile, Settings, Hideout speech/life, Shop, Stash, Shrine, combat/Scrip HUD, Pack Peddler, upgrade cards, and Results were inspected at gameplay scale alongside the prior miniboss, boss-hoard, loot-comparison, and pause coverage. The canonical mascot, existing arenas/enemies/weapons, Hideout destinations, and return-home paths remain unchanged and regression-covered.
- The Windows sandbox may print a root-certificate-store warning during headless tests; it does not affect gameplay or test results.

## KNOWN LIMITATIONS
- Current synthesized audio is intentionally original placeholder feedback, not final signature sound design or music. It prioritizes event coverage, bus/settings validation, and safe provenance.
- Gold currently has conservative run-result earning and persistent display/storage but no spending sink yet. Future progression, utility, cosmetics, Forge, and earned-currency chests are roadmap work; no artificial sink was rushed into this checkpoint.
- Chest definitions and presentation phases are replacement-ready data contracts. The existing Mystery Cache and physical boss hoard exercise current reward presentation, but a new standalone tap-to-open world chest was not added.
- Duo/small-swarm encounter kinds are data-supported only. Every live encounter remains solo until targeting, AoE, death aggregation, and wave completion can be introduced and tested together.
- Profile/account-link fields are local preparation only. Google Play Games Services v2, cloud save, friends, clans, parties, trading, raids, and real networking are not implemented.
- Loot-drop glyphs, small combat particles, and some general menu/HUD decoration remain procedural or standard-Control placeholders. Every enemy body reachable in the current 15-wave run is now sprite-based.
- Stash sorting and item locking are not implemented; filtering, comparison, equip, and stored-item scrap are functional. Forge remains out of scope.
- Weapon evolution paths are represented in catalog data for safe future extension; this checkpoint does not implement mutation choices or a large evolution tree.
- Scrap now funds the persistent Hideout Shop, Mystery Cache, reroll, and capacity expansion; Forge remains intentionally unimplemented.
- Merchant stock is intentionally equipment-only in this first pass; healing/run-upgrade stock can be assessed after playtesting the core shop economy.
- Lootbook remains Coming Soon. Its physical Archive nook exists in the Home art, but a full collectible compendium is intentionally deferred. The Hideout Shop intentionally sells only the existing catalog and has no real-world timer, premium currency, or unlimited inventory.
- Armour, Charm, and Rune list entries still use readable category glyphs because dedicated item art does not exist yet; weapon entries use the four existing painted family sprites. Loot particles and some UI decoration remain procedural/Control-based. No canonical character art was repainted or redesigned.
- New regular-zone enemies use one three-cell bitmap atlas per zone and lightweight transform motion rather than frame-by-frame animation. Zone selection is data-driven, but this first expedition's five-wave composition tables are deterministic rather than procedurally shuffled.
- The accepted Hoard Dragon remains unchanged. Its rear body/coil/tail taper still deserves a small targeted future art-QA cleanup; do not redesign the whole boss to address it.
- Stable zone/music/loot hooks now support future expedition or mode definitions, but Dungeons, Rogue Runs, Endless, Raids, social systems, and networking are intentionally not implemented.

## LAST COMPLETED CHECKPOINT
Foundation / identity / game-feel checkpoint - Lootlings now boots through a real title experience, persists local player identity and audio settings, provides original procedural audio hooks, distinguishes persistent Gold from Run Scrip, adds bounded Hideout life, and establishes documented chest, UI, analytics, customisation, encounter, account-link, and long-term roadmap contracts without replacing the validated expedition.

## NEXT MANUAL PLAYTEST
On a fresh local save, watch or skip the ignition, create one profile, edit its nickname/name, restart, and confirm naming is never requested again. Exercise every audio slider and mute, enter the Hideout, wait for two ambient speech beats, and verify Gold/Scrap/Shards remain readable. Complete one run while listening for tap/hit/crit/hurt/death/pickup/drop/level/Core/boss/zone/result hooks; spend Run Scrip at both merchants and confirm it resets on the next run while Gold persists. Recheck Profile and Settings after restart, then note which procedural sounds most need final authored replacements.
