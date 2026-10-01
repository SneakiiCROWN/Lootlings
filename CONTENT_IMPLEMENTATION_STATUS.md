# Lootlings Content Implementation Status

Authoritative planning source: `art/reference/docs/`.

Status meanings: `LIVE` is player-facing and validated; `DEFINED_DATA` is implemented data behind an activation gate; `ASSET_NEEDED` requires dedicated clean runtime art; `FUTURE` is deliberately later; `DEFERRED` was excluded from this checkpoint for stability.

## Characters

| Content | Status | Runtime note |
| --- | --- | --- |
| Neutral Relic Beast | LIVE | Exact canonical `art/sprites/relic_beast_base.png`; current base player. |
| Emberhorn, Mosskin, Moonkip, Pebblewyrm, Glimmerfin, Gloomlet | ASSET_NEEDED | Catalog/selector entries exist and stay locked until clean transparent standalone runtime sprites exist. Canonical sheets are reference only. |
| Five-pose runtime sets for all seven Lootlings | ASSET_NEEDED | Idle/ready, anticipate, attack/release, hurt/recovery, victory/reward. |

## Run, enemies, and world

| Content | Status | Runtime note |
| --- | --- | --- |
| Outer Treasure Ruins / Salvage Warrens / Hoard Depths | LIVE | 15-wave Act I run, painted backgrounds, distinct species, music, metadata hooks. |
| Hasty / Armoured / Volatile / Cursed / Gilded | LIVE | Existing deterministic variants retained. |
| Frostbitten / Overcharged / Rootbound | LIVE | Zone-weighted variants with explicit names, accents, reward multipliers, and readable mechanics. |
| Echoing / Hungry / Hoarder / Shiny | DEFINED_DATA | Master-catalog identities retained for later mechanics/art/collection hooks. |
| Solo Duelist / Heavy Solo | LIVE | Current single-target combat architecture. |
| Duos / Guard+Caster / Scraprat Pack / treasure escape / Mimic Room / Elite Guard | DEFINED_DATA | Composition contracts exist; simultaneous targeting and dedicated assets intentionally deferred. |
| Act II–V zones | ASSET_NEEDED | Nine replacement-ready metadata records include palette, enemy family, boss, and loot identity. |
| The First Hoard | FUTURE | Endgame narrative/content arc only. |

## Loot, weapons, and rewards

| Content | Status | Runtime note |
| --- | --- | --- |
| Greatsword, Maul, Bow, Staff, Twin Daggers | LIVE | Correct current combat semantics and safe runtime art families; weapon subtype/evolution/projectile metadata added. |
| Greataxe, Spear/Halberd, Claws, Crossbow, Relic Sling, Wand, Orb/Focus | ASSET_NEEDED | Full master data exists, but held/item/evolution/projectile art and some distinct runtime semantics are required before live activation. |
| 35 equipment bases | LIVE | Expanded curated Weapon/Armour/Charm/Rune pool using only validated effect keys. Existing IDs remain stable. |
| 20 standard affixes | LIVE | Slot compatibility retained; additions use existing bounded stats. |
| Crooked Constellation / First Light / Grudgekeeper / Last Laugh | LIVE | Existing behaviour-changing signatures preserved. |
| Last Lantern / Frostbell Chime | LIVE | New fully implemented behaviour hooks with bounded once-per-run/once-per-foe rules. |
| Nine additional Signature definitions | DEFINED_DATA | Explicitly excluded from random rolls until each behaviour is implemented and tested. |
| Weapon evolution lines | DEFINED_DATA | 36 named three-stage lines; no Forge/crafting activation this pass. |
| Scavenged Cache / Relic Chest / Hoard Chest | LIVE | Contents finalized before data-driven rarity spectacle. |
| Cursed Coffer | DEFINED_DATA | Reward/presentation contract only. |
| Mimic Husk | ASSET_NEEDED | Requires clean chest/enemy states and encounter implementation. |
| Starfall Vault | FUTURE | Mythic/endgame profile only. |

## Hideout, trophies, and platform direction

| Content | Status | Runtime note |
| --- | --- | --- |
| Patch, Nym, Quillik, Nibs contextual dialogue | LIVE | Expanded concise weighted pools; cosmetic RNG remains independent. |
| Tonk, Mara, Pip & Pock, Mote | FUTURE | Defined cast; no fake runtime actors. |
| Trophy Archive | LIVE | 27 local achievements after this pass, including new variant, Signature, chest, kill, weapon-family, and boss milestones. |
| Platform achievement IDs | DEFINED_DATA | Empty provider mapping fields; no authentication/submission. |
| Networking, clans, raids, secure trading, monetisation | FUTURE | No backend or player-facing promise implemented. |

## Dedicated art still required

- Six named Lootling standalone sprites plus five-pose sets, portraits, selector heroes, and attachment anchors.
- Dedicated held/item/evolution art for the seven locked weapon families and their projectiles.
- Cursed Coffer, Mimic Husk, and Starfall Vault state art.
- Act II–V background/midground/foreground/postcard/boss layers and their enemy/boss sets.
- Dedicated Hoard Dragon replacement remains an isolated later art sprint.
