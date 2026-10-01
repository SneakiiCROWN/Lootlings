# Lootlings Content Implementation Status

Authoritative planning source: `art/reference/docs/`.

Status meanings: `LIVE` is player-facing and validated; `DEFINED_DATA` is implemented data behind an activation gate; `ASSET_NEEDED` requires dedicated clean runtime art; `FUTURE` is deliberately later; `DEFERRED` was excluded from this checkpoint for stability.

## Characters

| Content | Status | Runtime note |
| --- | --- | --- |
| Neutral Relic Beast | LIVE | Exact canonical `art/sprites/relic_beast_base.png`; current base player. |
| Emberhorn, Mosskin, Moonkip, Pebblewyrm, Glimmerfin, Gloomlet | LIVE — TEMP ART | Selectable/persistent cosmetic identities; labelled tinted neutral stand-in under latest gameplay-first brief. Canonical final art still required; sheets are not cropped. Cached runtime catalog hooks feed combat/Home/Title. |
| Additional pose cutouts for all seven Lootlings | DEFERRED | Existing transform-driven pose layer is live. Four optional extra cutouts per identity are LATER; accepted idle art is sufficient for an initial honest identity integration. |

## Run, enemies, and world

| Content | Status | Runtime note |
| --- | --- | --- |
| Outer Treasure Ruins / Salvage Warrens / Hoard Depths | LIVE | 15-wave Act I run, painted backgrounds, distinct species, music, metadata hooks. |
| Hasty / Armoured / Volatile / Cursed / Gilded | LIVE | Existing deterministic variants retained. |
| Frostbitten / Overcharged / Rootbound | LIVE | Zone-weighted variants with explicit names, accents, reward multipliers, and readable mechanics. |
| Echoing / Hungry / Hoarder / Shiny | DEFINED_DATA | Master-catalog identities retained for later mechanics/art/collection hooks. |
| Solo Duelist / Heavy Solo | LIVE | Current single-target combat architecture. |
| Duos / Guard+Caster / Scraprat Pack / treasure escape / Mimic Room / Elite Guard | DEFINED_DATA | Composition contracts exist; simultaneous targeting and dedicated assets intentionally deferred. |
| Act II–V zones | LIVE — TEMP ART | Eight sequentially unlocked 15-wave solo expeditions; role mixes, pace/durability, themed loot/music, names/tints and readable existing regional-variant patrol mechanics. Existing actor/boss/environment art reused honestly; bespoke bosses and multi-actor encounters remain deferred. |
| The First Hoard | LIVE — TEMP ART | Ninth unlockable new region; same established reward flow, heavy patrol identity and curated existing loot. Full endgame narrative/bespoke boss remains future. |

## Loot, weapons, and rewards

| Content | Status | Runtime note |
| --- | --- | --- |
| Greatsword, Maul, Bow, Staff, Twin Daggers | LIVE | Correct current combat semantics and safe runtime art families; weapon subtype/evolution/projectile metadata added. |
| Greataxe, Spear/Halberd, Claws, Crossbow, Relic Sling, Wand, Orb/Focus | LIVE — TEMP ART | Seven Forge-crafted approved bases with distinct actual attack hooks/projectile timing. Existing class held art/icon reused with explicit TEMP ART; dedicated texture paths ready. Not added to the validated 35-base random drop pool. |
| 35 drop bases + seven Forge bases | LIVE | Existing 35-base drop pool and odds unchanged; additional weapon bases are crafted into Stash for 150 Gold + 6 Scrap each. IDs/rarity/affix/save compatibility preserved. |
| 20 standard affixes | LIVE | Slot compatibility retained; additions use existing bounded stats. |
| Crooked Constellation / First Light / Grudgekeeper / Last Laugh | LIVE | Existing behaviour-changing signatures preserved. |
| Last Lantern / Frostbell Chime | LIVE | New fully implemented behaviour hooks with bounded once-per-run/once-per-foe rules. |
| Nine additional Signature definitions | DEFINED_DATA | Explicitly excluded from random rolls until each behaviour is implemented and tested. |
| Weapon evolution lines | LIVE / PARTIAL | Stash Forge evolves owned items with existing evolution_path; two capped additive stages, Gold/Scrap costs, persistent schema 3. Remaining catalog-only bases/lines are not yet obtainable. |
| Scavenged Cache / Relic Chest reward contracts | LIVE | Existing cache claim/miniboss item flows; dedicated physical closed/open chest art and texture sequences are not implemented. Do not equate data/reward rules with Hoard's renderer. |
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
