# Lootlings Content Implementation Status

Authoritative planning source: `art/reference/docs/`.

Current world/art authority additionally includes `LOOTLINGS_WORLD_BIBLE.md` and the approved Phase 2 boards. `BETA_ART_PROVENANCE.md` distinguishes live beta extracts from final production needs. Archive Field Notes covers all seven identities, three named painted resident busts, Crownfall and campaign-unlocked trail pages. Forge/contract contextual dialogue is connected to successful actions. Bounded optional groups and a seeded route are live; full-body residents and bespoke encounters remain production scope.

Status meanings: `LIVE` is player-facing and validated; `DEFINED_DATA` is implemented data behind an activation gate; `ASSET_NEEDED` requires dedicated clean runtime art; `FUTURE` is deliberately later; `DEFERRED` was excluded from this checkpoint for stability.

## Characters

| Content | Status | Runtime note |
| --- | --- | --- |
| Neutral Relic Beast | LIVE | Exact canonical `art/sprites/relic_beast_base.png`; current base player. |
| Emberhorn, Mosskin, Moonkip, Pebblewyrm, Glimmerfin | LIVE — CANONICAL BETA | Original canonical turnaround cutouts, untinted, through existing runtime hooks. High-resolution weaponless production replacements still needed; see BETA_ART_PROVENANCE.md. |
| Gloomlet | LIVE — TEMP ART | Selection restored; clearly labelled previous temporary neutral stand-in. Missing final art never removes this playable identity. |
| Adult Wanderers | LIVE — BETA PRESETS | Accepted Vault Runner/Ruin Warden plus additive Nightstage Drifter/Velvet Astrologer/Ashtrail Hunter. Schema 3, stat-neutral identity and seventeen-slot baked appearance manifest, sixty tested body/weapon combinations. Not an independent modular creator. Art/provenance: WANDERER_BETA_ART.md. |
| Origin previews / Memory Archive | LIVE — ILLUSTRATED BETA | 33 existing-content scenes, short skippable read-only previews/replays, first meeting/region/supported-boss hooks, persistent discovery and reduced-motion settings. No final limb/gesture animation; VIGNETTE_IMPLEMENTATION.md gives exact scope. |
| Additional pose cutouts for all seven Lootlings | DEFERRED | Existing transform-driven pose layer is live. Four optional extra cutouts per identity are LATER; accepted idle art is sufficient for an initial honest identity integration. |

## Run, enemies, and world

| Content | Status | Runtime note |
| --- | --- | --- |
| Outer Treasure Ruins / Salvage Warrens / Hoard Depths | LIVE | 15-wave Act I run, painted backgrounds, distinct species, music, metadata hooks. |
| Hasty / Armoured / Volatile / Cursed / Gilded | LIVE | Existing deterministic variants retained. |
| Frostbitten / Overcharged / Rootbound | LIVE | Zone-weighted variants with explicit names, accents, reward multipliers, and readable mechanics. |
| Echoing / Hungry / Hoarder / Shiny | DEFINED_DATA | Master-catalog identities retained for later mechanics/art/collection hooks. |
| Solo Duelist / Heavy Solo | LIVE | Current single-target combat architecture. |
| Regular duos / role-mixed small packs | LIVE — OPT-IN | Expedition GROUPS patrol option; existing scheduled roles, independent HP/status/clock/target, bound projectiles, bounded AoE and per-member rewards. Solo default unchanged. |
| Seeded Relic Route | LIVE — OPT-IN | Unlocks after Act I; eight seeded room forks, all eight room kinds, existing physical chest/shop/upgrade/Hoard flow, route-only scaling and proportional reward caps. No campaign unlock or resumable route save. |
| Boss adds / Scraprat swarm / treasure escape / Mimic Room / bespoke Elite Guard | DEFINED_DATA | Not claimed by regular duo/pack integration; bespoke encounters/art remain needed. |
| Act II–V zones | LIVE — BETA SCENERY | Every expanded region has a distinct approved-art composition; Mossglass/Cinder also have distinct boss cutouts. Final high-resolution environments and remaining boss/actor art still needed. Solo mechanics/balance unchanged; multi-actor encounters deferred. |
| The First Hoard | LIVE — BETA SCENERY | Distinct treasury/throne composition, established reward flow/heavy patrol/curated loot. Bespoke boss mechanics/body remain future. |

## Loot, weapons, and rewards

Current evolution behaviour: all twelve weapon families support their existing two owned stages with family-specific combat hooks and pre-purchase Forge descriptions. Original costs/cap/+4%, affixes/rarity/save IDs and default acquisition pool are retained. Stage-specific painted exports remain needed; this does not activate every catalog-only base/evolution line or gated Signature.

| Content | Status | Runtime note |
| --- | --- | --- |
| Greatsword, Maul, Bow, Staff, Twin Daggers | LIVE | Correct current combat semantics and safe runtime art families; weapon subtype/evolution/projectile metadata added. |
| Greataxe, Spear/Halberd, Claws, Crossbow, Relic Sling, Wand, Orb/Focus | LIVE — PARTIAL BETA ART | Forge mechanics unchanged. Greatsword/Greataxe/Focus/Spear/Claws/Crossbow/Wand have distinct approved art; only Relic Sling still reuses class art. Random drop pool unchanged. |
| 35 drop bases + seven Forge bases | LIVE | Existing 35-base drop pool and odds unchanged; additional weapon bases are crafted into Stash for 150 Gold + 6 Scrap each. IDs/rarity/affix/save compatibility preserved. |
| 20 standard affixes | LIVE | Slot compatibility retained; additions use existing bounded stats. |
| Crooked Constellation / First Light / Grudgekeeper / Last Laugh | LIVE | Existing behaviour-changing signatures preserved. |
| Last Lantern / Frostbell Chime | LIVE | New fully implemented behaviour hooks with bounded once-per-run/once-per-foe rules. |
| Nine additional Signature definitions | DEFINED_DATA | Explicitly excluded from random rolls until each behaviour is implemented and tested. |
| Weapon evolution lines | LIVE / PARTIAL | Stash Forge evolves owned items with existing evolution_path; two capped additive stages, Gold/Scrap costs, persistent schema 3. Remaining catalog-only bases/lines are not yet obtainable. |
| Scavenged Cache / Relic Chest reward contracts | LIVE — BETA PRESENTATION | Approved painted closed sprites land/glow and reveal the existing shop/miniboss item. Original price/claim/pickup rules unchanged. Genuine hinged-open frames still required; Hoard renderer unchanged. |
| Hoard Chest | LIVE | Dedicated painted closed sprite, landing/charge/tap/burst/three Epic+ arcs and choose-one are live. |
| Cursed Coffer | DEFINED_DATA | Reward/presentation contract only. |
| Mimic Husk | ASSET_NEEDED | Requires clean chest/enemy states and encounter implementation. |
| Starfall Vault | FUTURE | Mythic/endgame profile only. |

## Hideout, trophies, and platform direction

Local contracts: LIVE. Expeditions → Local Contracts, three simultaneous jobs/six templates; actual kill/miniboss/boss/chest/victory counters, 10–20 Gold claim rewards, local rotation and schema-1 persistence. No backend or daily clock.

| Content | Status | Runtime note |
| --- | --- | --- |
| Patch, Nym, Quillik, Nibs contextual dialogue | LIVE | Expanded concise weighted pools; cosmetic RNG remains independent. |
| Tonk, Mara, Pip & Pock, Mote | FUTURE | Defined cast; no fake runtime actors. |
| Trophy Archive | LIVE | 27 local achievements after this pass, including new variant, Signature, chest, kill, weapon-family, and boss milestones. |
| Platform achievement IDs | DEFINED_DATA | Empty provider mapping fields; no authentication/submission. |
| Networking, clans, raids, secure trading, monetisation | FUTURE | No backend or player-facing promise implemented. |

## Phase 1 delivered / Phase 2 art authority

All 34 Foundation and 55 Wave 2 PNGs are delivered and integrated: shells, meters, controls, category/upgrade/currency/Core/status/variant/rarity/Trophy icons and Results crests are no longer missing programmer-art requests. Dedicated base-item art is distinct from delivered category icons. See `ASSET_NEEDED_PHASE2.md` for the full scoped request and `art/reference/phase2_master/REFERENCE_INDEX.md` for all approved boards. Adult heroes, companions and named board demons/worlds have no corresponding live IDs and remain REFERENCE ONLY. No runtime system was changed by this audit.

## Dedicated art still required

- Six exact canonical standalone idle sprites with consistent attachment anchors are needed for roster unlocks; additional pose cutouts are later. Reuse idle exports for portraits/selector previews until dedicated portrait composition is required.
- Dedicated held/item/evolution art for the seven locked weapon families and their projectiles.
- Cursed Coffer, Mimic Husk, and Starfall Vault state art.
- Future zone portrait backgrounds and enemy/boss sets; separate midground/foreground/postcards are optional future deliveries, not additional mandatory duplicates. Exact deferred requests are in `ASSET_NEEDED_PHASE2.md`.
- Dedicated Hoard Dragon replacement remains an isolated later art sprint.
