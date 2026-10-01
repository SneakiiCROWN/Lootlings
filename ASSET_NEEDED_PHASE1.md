# ASSET_NEEDED — Phase 1 visual shell

The **34-PNG Foundation UI v1 batch is now supplied and integrated unchanged**: wordmark, five panel skins, all 15 button states, two inputs, two HUD shells, six meter frame/fill textures and three dividers. `README_PHASE1_FOUNDATION_UI.md` and `manifest.json` retain the supplied delivery record. Texture-backed nine-slicing replaces the temporary generated bevel chrome. The remaining icon/crest requests below are still outstanding. Upgrade icon sockets remain empty; names/effects are information, not substitute icons. Existing category drawings, currency glyphs and Trophy glyphs remain legacy placeholders, not approved final artwork.

Delivered table rows: brand, panels, buttons, inputs, HUD shells, meters and dividers. Outstanding rows: currencies, Cores/elements, statuses/variants, all 18 upgrade icons, gear categories, rarity marks, Trophy badges and Results crests. No Wave 2 assets were invented or enabled during foundation integration.

All dimensions below are source pixels; UI reference is portrait **480×854**. Supply PNG sRGB, clean alpha edges where transparent, no baked text/numbers, and no redesign of canonical characters. Gold / purple / cyan remain the identity palette. Frames must scale without stretching corners; supply nine-slice safe margins. No new gameplay rarity, element or currency is requested.

| Purpose / screen location | Suggested filename(s) | Dimensions / aspect | Transparency | States / material requirements |
| --- | --- | --- | --- | --- |
| Actual brand wordmark, Boot/Title | `art/ui/brand/lootlings_wordmark.png` | 1024×256, 4:1; displayed within 432×66 | Transparent | Normal, optional small-size simplified export; warm gold, original Lootlings identity, not another game's logo |
| Replace temporary dialog surfaces: Shrine, Stash, shop, Boss Hoard, defeat/pause | `art/ui/skins/panel_{relic,leather,salvage,hoard,danger}_9slice.png` | Each 256×256, 1:1; 32px protected corners | Transparent outer corners | Five distinct skins; dark navy/violet relic stone, muted leather, bronze salvage, warm-gold treasure, subdued red danger; quiet text-safe center; no fake inscriptions |
| Primary, secondary and destructive actions across all menus/cards | `art/ui/skins/button_{primary,secondary,destructive}_{normal,hover,pressed,disabled,focus}.png` | 384×96, 4:1; 24px protected caps | Transparent | All five states; gold primary, cyan/violet secondary, muted danger; depressed pressed state and clearly subdued disabled state; scalable to existing tap targets |
| Profile name inputs | `art/ui/skins/input_{normal,focus}.png` | 672×112, 6:1; 24px protected caps | Transparent | Dark inset field, warm focus edge, no baked placeholder or caret |
| Combat top shell and bottom build ribbon | `art/ui/skins/hud_header_9slice.png`, `hud_build_ribbon_9slice.png` | 960×292 and 888×176; about 3.3:1 and 5:1 | Transparent outer corners | Normal only; restrained warm metal/navy; preserve current bar and label geometry, center text-safe |
| HP/XP/enemy meter frames and fills, combat | `art/ui/skins/bar_{health,xp,enemy}_{frame,fill}.png` | Health 888×52; XP 888×36; enemy 660×44 | Transparent caps | Frame + separate stretchable fill, green HP/cyan XP/red enemy, readable empty state; no baked value |
| Currency identity, HUD/results/shop/Shrine | `art/ui/icons/currency_{gold,scrap,star_shard,run_scrip}.png` | Each 128×128, 1:1; readable at 16–28px | Transparent | Normal; optional muted export; distinct silhouettes, gold metal/salvage metal/violet crystal/cyan run token; do not confuse temporary Scrip with persistent Gold |
| Core/element identity, combat build chips and upgrades | `art/ui/icons/core_{neutral,physical,fire,lightning,poison}.png` | Each 128×128, 1:1 | Transparent | Normal, optional inactive; canon-compatible relic marks, distinct silhouettes; no text-token icons |
| Active statuses and enemy-variant chips, below enemy HP | `art/ui/icons/status_{burn,poison}.png`; `art/ui/icons/variant_{hasty,armoured,volatile,cursed,gilded,frostbitten,overcharged,rootbound}.png` | Each 128×128, 1:1; readable at 12–20px | Transparent | Normal, inactive optional; distinct silhouettes matching existing fire/poison/variant accents, restrained cyan/violet/green/gold; replace legacy glyphs, keep names and stack counters as supporting information |
| Upgrade illustration, three level-up choices | See exact filenames below | Each 128×128, 1:1; displayed 44×44 | Transparent | One normal icon each; family color supported by a distinct silhouette, readable without color; rarity stays separate |
| Gear categories, item decision/Stash/Boss Hoard/Peddler/Salvager | `art/ui/icons/gear_{armour,charm,rune}.png` | Each 256×256, 1:1; displayed 44–120px | Transparent | Normal only, rarity supplied separately; cute scavenged armour, trinket, physical rune, matching existing painted weapon style; replace legacy drawings |
| Rarity identity on items/rewards | `art/ui/icons/rarity_{common,rare,epic,legendary}.png` | Each 128×128, 1:1; readable at 16–24px | Transparent | Distinct silhouettes; green/cyan/violet/gold support, not sole distinction; no additional rarity tier; text badge remains supplementary |
| Trophy collection category badges and concealed state | `art/ui/trophies/category_{adventure,combat,bosses,loot,collection,mastery,hideout,secret}.png`, `trophy_locked.png` | Each 128×128, 1:1; displayed within existing tiles | Transparent | Unlocked badge, muted locked silhouette, mystery secret silhouette; no secret description baked into art; gold metal with restrained violet/cyan |
| Results victory/defeat identity | `art/ui/results/{victory_crest,defeat_crest}.png` | Each 512×192, 8:3 | Transparent | Victory and defeat; cheerful relic treasure vs cute bonked identity, no new character depiction; leave existing summary readable |
| Section divider decoration, Profile/Results/Shrine/rewards | `art/ui/skins/divider_{gold,relic,salvage}.png` | Each 768×32, 24:1 | Transparent | Three quiet material variants, narrow text-safe separators; no invented lore sigils |

## Exact upgrade icon delivery paths

The current renderer loads these paths only if a real texture exists. Do not change IDs or ship text tokens in the images.

| File under `art/ui/icons/upgrades/` | Existing upgrade / visual purpose |
| --- | --- |
| `damage.png` | Colossal Grip — forceful grip / damage |
| `crit.png` | Relic Edge — precise relic blade strike |
| `execute.png` | Mercy Breaker — finishing strike |
| `heavy.png` | Quake Bonk — weighty ground impact |
| `speed.png` | Quick Grip — swift weapon motion |
| `multi.png` | Twin Volt — paired strike / sparks |
| `tap.png` | Static Fingers — charged active tap |
| `storm.png` | Storm Rhythm — chained lightning |
| `splash.png` | Cinder Wake — ember echo |
| `ignite.png` | Ember Teeth — ignition / fang |
| `frenzy.png` | Furnace Heart — low-health fire surge |
| `wildfire.png` | Wildfire — burning burst |
| `vamp.png` | Toxic Fang — life-draining fang |
| `regen.png` | Mutant Moss — restorative moss |
| `venom.png` | Venom Coat — poisonous coating |
| `plague.png` | Plague Siphon — poison-to-healing flow |
| `armor.png` | Scavenger Plate — protective salvaged plate |
| `greed.png` | Relic Magnet — treasure attraction |

## Scope boundaries

Existing mascot, weapons, enemies, painted environments and Hoard Chest are reused unchanged. No art generation, fake playable character crops, new status mechanics or new art pipeline was added. Existing status chips are concise gameplay information, not new icon substitutes. Status/variant delivery is listed above; this phase does not invent emblems for them or expand Signature content.
