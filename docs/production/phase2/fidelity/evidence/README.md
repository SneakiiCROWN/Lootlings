# Native fidelity evidence

Godot 4.7.2 native Compatibility renderer, RTX 4080 SUPER. These are actual main-game renderer captures with isolated disposable saves, not concept images. No model-generated final art. Portable WebP packaging is reproducible with `tools/package_fidelity_evidence.py`; full original PNGs remain under `.godot_test_data/fidelity`, `fidelity_matrix` and `fidelity_screens`.

## Bow sequence

Five columns: idle/nocked, draw/windup, fire, flight, recovery/impact. Three actors per page, original 480×310 combat crops preserved in each cell; WebP compression only. Right uses actual target placement. Left is labelled preview and directs the fixture projectile left while retaining the existing right-side enemy rendering; it does not claim new left-facing encounter gameplay.

| Actors | Right | Left preview |
|---|---|---|
| Vault Runner, Ruin Warden, Nightstage Drifter | [1](bow-right-1.webp) | [1](bow-left-1.webp) |
| Velvet Astrologer, Ashtrail Hunter, Relic Beast | [2](bow-right-2.webp) | [2](bow-left-2.webp) |
| Emberhorn, Mosskin, Moonkip | [3](bow-right-3.webp) | [3](bow-left-3.webp) |
| Pebblewyrm, Glimmerfin, Gloomlet | [4](bow-right-4.webp) | [4](bow-left-4.webp) |

String is behind the grip, limbs forward, nock points toward the target. Missing actual string-drawing hand/body art remains a blocker; the sequence validates corrected weapon geometry/animation, not anatomical completion.

## Projectiles / impacts / pickups

Six columns: bow, crossbow, sling, staff, wand, orb. Upper row flight, lower row impact. Native combat crops reduced to 240×155 for indexing. [Physical](projectiles-physical.webp), [fire](projectiles-fire.webp), [frost](projectiles-frost.webp), [lightning](projectiles-lightning.webp), [poison](projectiles-poison.webp), [corruption](projectiles-corruption.webp), [arcane](projectiles-arcane.webp). Palettes are deliberately forced in the fixture to expose each motif; live selection still follows existing build/signature/family. No new elemental damage mechanic is implied.

Actual ordinary enemy kill: [combat-death pickups](combat_death_pickups.webp). Item renderer: [common](item_drop_common.webp), [rare](item_drop_rare.webp), [epic](item_drop_epic.webp), [legendary](item_drop_legendary.webp). Phone actual payout [full screen](fidelity_combat_pickups-1080x2316.webp); painted chest [screen](hoard_chest_qa-1080x2316.webp), ejected item rewards [screen](hoard_ejection_qa-1080x2316.webp), legendary bow decision [screen](signature_loot_qa-1080x2316.webp). Tablet equivalents use `-1200x1600`. Boss choices and weapon/armour/charm/rune drops appear in the screen pages below.

## Every actor / weapon / state / facing

24 sheets, 2,592 main-game samples. Rows: greatsword, greataxe, maul, spear, daggers, claws, bow, crossbow, sling, staff, wand, orb. Columns: idle, ready, movement, windup, strike, impact, recovery, hurt, defeat. Native 2160×2280 sheets are packaged at 1620×1710; raw originals remain available. Fit/support status in [matrix-report.json](matrix-report.json). These sheets precede the final text-width/selector-only refinement; weapon/body art and motion are unchanged.

| Actor | Right | Left preview |
|---|---|---|
| Relic Beast | [Sheet](relic_beast_right.webp) | [Sheet](relic_beast_left.webp) |
| Emberhorn | [Sheet](emberhorn_right.webp) | [Sheet](emberhorn_left.webp) |
| Mosskin | [Sheet](mosskin_right.webp) | [Sheet](mosskin_left.webp) |
| Moonkip | [Sheet](moonkip_right.webp) | [Sheet](moonkip_left.webp) |
| Pebblewyrm | [Sheet](pebblewyrm_right.webp) | [Sheet](pebblewyrm_left.webp) |
| Glimmerfin | [Sheet](glimmerfin_right.webp) | [Sheet](glimmerfin_left.webp) |
| Gloomlet | [Sheet](gloomlet_right.webp) | [Sheet](gloomlet_left.webp) |
| Vault Runner | [Sheet](vault_runner_right.webp) | [Sheet](vault_runner_left.webp) |
| Ruin Warden | [Sheet](ruin_warden_right.webp) | [Sheet](ruin_warden_left.webp) |
| Nightstage Drifter | [Sheet](nightstage_drifter_right.webp) | [Sheet](nightstage_drifter_left.webp) |
| Velvet Astrologer | [Sheet](velvet_astrologer_right.webp) | [Sheet](velvet_astrologer_left.webp) |
| Ashtrail Hunter | [Sheet](ashtrail_hunter_right.webp) | [Sheet](ashtrail_hunter_left.webp) |

82 right / 83 left support-hand/paired combinations and Moonkip’s baked knives remain visible art debt. Current stance fallback is not certified by socket math. Reused boss bodies, unarticulated chest opening and absent authored death/attack sequences also remain explicit in the report.

## Phone / tablet screens

Each final layout has 68 captures, filename-labelled and sorted, packaged twelve per page. Fixtures inject sold stock, long names, HP boundaries, mixed builds and specific palettes to expose presentation problems; these are not all naturally reached values. Final recaptures include the corrected complete hoard message and player-facing selector copy.

| Layout | Pages |
|---|---|
| 1080×2316 phone | [1](screens-1080x2316-1.webp), [2](screens-1080x2316-2.webp), [3](screens-1080x2316-3.webp), [4](screens-1080x2316-4.webp), [5](screens-1080x2316-5.webp), [6](screens-1080x2316-6.webp) |
| 1200×1600 tablet | [1](screens-1200x1600-1.webp), [2](screens-1200x1600-2.webp), [3](screens-1200x1600-3.webp), [4](screens-1200x1600-4.webp), [5](screens-1200x1600-5.webp), [6](screens-1200x1600-6.webp) |

## Audio and qualification

[Native combat voice recording](combat-voices.wav) covers actual attack/damage/death hooks for all twelve players and 27 enemy/miniboss/boss contexts. Source banks, live mix and limiter pass; this is not a claim of human listening or physical S23 audio approval. [Accepted result records](../accepted-results.json) identify the guarded runs and expected corrupt-save diagnostics. [Final Android build](../android-build-report.json) identifies the byte-verified bow/audio imports. None of these desktop captures certify S23 FPS, memory, thermals or Android lifecycle.
