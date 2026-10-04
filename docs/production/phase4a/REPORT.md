# Phase 4A playable expansion slice — 2026-10-04

Continued from clean human-QA checkpoint `2eb5616` on `codex/phase2-vertical-slice`. The first expansion slice is implemented, measured and packaged. This is not completion of the future roster/art/secret-content roadmap or physical-device acceptance. No generated art, replacement canonical artwork, sound-bank change, difficulty reduction or player-save reset was used.

## Baseline and decision record

Frozen source: `2eb5616`; prior accepted native pictures and economy distributions remain in `docs/production/humanqa`. Baseline had 47 item definitions, five selectable adult Wanderers, seven Lootlings, twelve mechanically live weapon families, ten replayable campaign destinations, eight roadside events, starter/evolution Forge and three rotating local jobs. Cleared destinations were already launchable; their targeted farm value, blueprint/material loop, use mastery and rank were absent. Existing humans already had distinct combat traits. We preserved those differences instead of pretending five new bodies were created.

Proposal: add 24 signature sidegrades to supported geometry, a saved use/collection foundation, regional crafting routes, optional rotating bounties and three uncommon roadside discoveries. Keep existing run currencies, tier-zero combat formulas, encounters, quiet hub, touch ownership, TAKE/BUY and destructive-action protections. Accept on real catalog compatibility, bounded target drought, receipt-safe forging, persisted progress, native readability and matched economy distributions. Do not require every combat seed to win.

Implementation was retained after the focused checks below. Two corrections came from evidence: small target pools could exhaust the prior two-item exclusion, so they now alternate rather than abandon the region; expanded result text needed native scrolling. A final pool test uses the actual combined old-plus-new regional pools, rather than assuming only new gear is eligible.

## Roster and arsenal

Five existing playable human presets now have collection biographies, weapon affinities, named mastery identities and persistent use progress:

| Human | Role / affinity | Existing differentiated combat identity |
|---|---|---|
| Vault Runner | agile courier; daggers/spear | kill-stored next-target force, lighter HP, faster movement |
| Velvet Astrologer | precision arcanist; bow/wand | fifth-attack restoration, lighter HP |
| Ruin Warden | heavy guardian; greatsword/maul | softens large hits, more HP, slower movement |
| Ashtrail Hunter | relic-coil marksman; crossbow/sling | enhanced first critical hit against a target |
| Nightstage Drifter | close finisher; daggers/claws | damage against wounded targets, lighter HP, faster movement |

Affinities are recommendations, not weapon locks. Existing light/heavy human voices and their license manifests are retained. New approved final human art: **zero**. Existing beta body assets remain beta; the native samples demonstrate integration, not final animation approval.

The item catalog grows **47 → 71**: twelve weapons, four armour pieces, four charms/jewellery/relics and four runes. Named behaviors use tested signature hooks: delayed heavy echoes, survived-hit counterstrokes, first-critical lightning, chimes, staggering heavies, stored kill force, fifth-attack lightning, three-target circuits, status ward, critical-finish ward, fatal-hit escape and cache-fed force. Risk pieces expose incoming-damage, HP, attack-speed or Scrip tradeoffs. These reuse family art; they do not claim 24 unique authored silhouettes. Spell/passive expansion is through equipped rune/signature behavior, not a new spellbook or skill tree. Single-hand sword/shield/offhand anatomy remains unsupported.

## Mastery, rank and Forge

Character and equipped weapon-family mastery gain one point per defeated foe; records survive failed runs, lifecycle persistence and reload. Displayed mastery advances every 30 defeats, capped at six display levels. Relic Rank uses up to four contributions per character/family, divided by four and added to starting rank one, capped at eight. Spreading use across the roster/families continues account progress after a single contribution caps. Rank adds **no combat stats**. Rank two opens Hardened; rank three opens Strange. Higher rank expansion beyond those gates is a foundation, not additional implemented unlocks.

Each named item has a three-fragment blueprint. Minibosses supply one fragment; Trail bosses one, Hardened two, Strange three. Lowest-progress local recipes are filled first, capped at three. The six synthetic clear tests (40 ordinary foes + miniboss + boss each) completed every regional local recipe; they are farming arithmetic checks, not six real playable region clears.

Forge costs **12 home-region materials + one home-region boss seal**, yielding a Rare item with its named signature. Recipes remain owned and reusable. Ordinary foes supply material on every third run defeat; elites supply one; minibosses two; bosses 4/5/6 across tiers. Boss seals supply one per boss on every tier. Existing 150 Gold/6 Scrap starter crafting and Gold/Scrap evolutions are unchanged.

The new Forge transaction persists a pending delivery before inventory, then records an inventory receipt before clearing the delivery. Interrupted delivery recovers once, including after the delivered item was later salvaged. Full stash rejects new payment. Unavailable inventory saving reserves the paid delivery. Returning to/refreshed Hideout retries recovery after making room; the receipt ledger survives item removal. This is recovery for this transaction, not a claim that all existing stores are cross-file atomic.

## Permanent regional farms

All destinations remain replayable after their existing story unlock. Cleared cards say RETURN TO FARM, show local material and a named target. Named gear also occurs in eligible global drops/shops/event caches; crafting supplies a guaranteed route rather than an impossible single-source chase.

| Region | Material | New local targets |
|---|---|---|
| Treasure Ruins | Promise Brass | Oath Slab, Courier Pike, Warden Warranty |
| Mossglass Wilds | Rootglass | Root Splitter, Marsh Promise, Second Skin |
| Moonfen | Moonthread | Moonstage Shivs, Witness Bow, Safe Aperture |
| Frostbell Hollows | Chime Ice | Winter Clause, Keeper Coat |
| Sunken Gearworks | Coil Teeth | Coil Dispatch, Rivet Fangs, Fault Script |
| Cinder Crown | Crown Ember | Bellows Maul, Scarlet Margin, Shelter Script |
| Starfall Archive | Living Ink | Marginalia Staff, Threefold Ink |
| Nullglass Expanse | Nullglass | Debt Orbit, Receipt Ring |
| Skyhook Bastion | Skywire | Pilgrim Sling, Hush Wand |
| First Hoard | First Gold | Coffer Key, Oath Slab, Keeper Coat |

Shared targets can drop in either listed destination; Forge uses the first listed home region's resources. The detail panel explicitly names that home. Regional loot attempts have 45% weight, with a forced broad-region target after three non-target **drops within a run**. This bounds a broad regional drought, not drought for one exact named item or the number of kills. Existing ordinary 7% drop chance, 18-defeat ordinary-drop protection and rarity weights are preserved. Blueprint progress provides the exact-item fallback.

## Tiers, contracts and discoveries

Trail preserves combat formulas. Hardened adds regional elite presence from wave three plus increased boss material/blueprint harvest. Strange adds more regional elite presence, 8% shorter ordinary-foe attack intervals and a higher discovery chance. No new blanket HP multiplier or new boss phase is introduced. Existing elite health/behavior rules still apply. Measured tier calibration is **provisional**: see balance evidence below.

Regional Bounties cycle through boss seal, three elites, roadside lead and Hardened clear. Progress starts when a region's job is opened, has no expiration, and is claimable once before rotation. Rewards: six local materials plus one local recipe fragment. Existing three local contracts remain. No daily attendance, energy or purchase mechanic was added.

Three rare roadside encounters use the existing two scheduled event opportunities: bell-door clue, travelling Compact smith, and mimic negotiation. They offer HP/treasure, paid treasure/healing, and curse/XP decisions respectively. Chance is 8/12/16% across tiers; five missed opportunities enable another rare attempt, still respecting per-run non-repetition. Archive records chosen encounters/secrets. The bell encounter is a text discovery and reward decision; **there is no newly authored explorable room, puzzle or secret boss**. Those require future content, not stand-ins.

## Archive, hub and resources

New content is reached contextually through Forge, Regional Bounties and Collection & Mastery in Archive. No new permanent giant hub buttons. Quiet hub/loadout and lighter combat HUD remain. Workshop separates scrollable selection, readable detail, and a primary action; a 180ms selection guard and cleared selection prevent drag/rapid repeat purchases. Native touch checks verify card swipes do not select/craft, one forge/claim only, and no combat attack leakage. Expanded result progress scrolls inside its panel.

Collection tracks actor/family mastery, human biographies, named gear, recipes, and seen regions/enemies/elites/minibosses/bosses/events/secrets. Unknown named finds show ??? until discovered or a recipe piece is found. This is a compact collection foundation, not an exhaustive new lore/cosmetic unlock index.

| Resource | Purpose preserved/added |
|---|---|
| Run Scrip | temporary expedition merchants/events; preserved prices and TAKE/BUY behavior |
| Gold | persistent shop, starter Forge/evolutions and Hideout improvements |
| Scrap | salvage, stash space, stock rerolls/caches and starter/evolution Forge |
| Star Shards | existing permanent power; separate from new rank |
| Regional material | target-region ordinary/elite farming for named crafting |
| Boss seal | region boss-clear requirement for named crafting |
| Blueprint fragments | permanent recipe discovery; not spent by crafting |

New crafting does not charge Scrip/Gold/Scrap/Shards or replace their existing roles. No income, rarity or merchant price formula was reduced to make seeds win.

## Measured/native acceptance and limits

- `phase4_qa`: actual 71-item catalog, 24 nonempty named hooks, supported families; ten regional farming arithmetic cohorts; persistence, migration from no new file, receipt recovery after salvage, full-stash payment rejection, one bounty claim, five human trait profiles with twelve weapon families.
- Actual combined regional loot pools: **30,000 seeded ordinary roll attempts**, 270–281 resulting drops per region; broad regional targets 155–164 or 150 in Skyhook; new named drops 55–155; maximum non-target drop streak three. Exact raw values are in accepted logs. This samples one long seed per region; guarantees are enforced by counters, not inferred from averages.
- **104 fresh actual-combat seeded runs**: 20 human-affinity runs, 12 Relic Beast starter runs, twelve tier comparisons, 24 named weapon runs and 36 matched economy-policy runs. Full per-run foe TTK, effective DPS, damage, lowest HP, loot, merchant decisions, sources/sinks and distributions are in `runs.json` / `metrics.json`. They use the existing sustain/tap policy; this is not broad human-skill or long-term balance acceptance.
- Native Godot Compatibility rendering on RTX 4080 SUPER: **1080×2316 phone and 1600×2560 tablet render layouts**. Actual screen-touch swipes/selection/forge/bounty/tier paths, no duplicate charge/attack leak; five humans with affinity weapons, both facings and windup/release; all three rare event cards; expanded end-of-run panel. Contact sheets are alongside this report. OS window sizing may clamp the desktop window; render-layout evidence is not a physical Galaxy test.
- Focused mobile gesture, reward and save-recovery regression fixtures pass. Save recovery emits its two expected corrupt-fixture diagnostics. Parser failures and the bounty/typed-array fixture setup failures were superseded by corrected accepted runs; failed attempts are not acceptance evidence.
- APK exported, signature verified, arm64 verified, 16KB ZIP alignment verified, branded splash/bow/pose imports current, 329 licensed PCM assets present, new progress/catalog modules included, no Android permissions, tests/tools/source-reference art excluded. See `android-build.json` for exact identity.

### Before/after comparison

The prior frozen human-QA cohort has the same engine/seed/actor/core/merchant policies as the new 36-run cohort; changed loot tables naturally change later RNG outcomes. All three policies remain 12/12 wins. Median foe TTK: cheap **1.72→1.75s**, save **1.70→1.75s**, search **1.60→1.65s**. Median Scrip spent: **218→211**, **341→341**, **414→388.5**. Lower-tail HP is riskier: lowest observed cheap HP ratio **0.314→0.086**, save **0.685→0.237**, search **0.727→0.237**. Keep the meaningful risk gear and target sources; do not turn these wins into a difficulty target or claim tails are harmless. Further real-player judgments remain open.

Named weapons: 23/24 runs win; Hush Wand loses one of two. Witness Bow reaches 12.5% lowest HP in one run. Retain those outcomes as behavior/risk evidence, not proof of a balanced weapon ranking. Starting with a Rare named item differs from the Common starter cohort and is not a causal DPS comparison.

Tier elite medians **3.5 / 14 / 23**, ordinary foe TTK medians **1.75 / 1.50 / 2.00s** (all defeated foes pooled), duration medians **146.60 / 122.60 / 147.12s**. More elites do not guarantee monotonic survival pressure: changed elite rewards feed upgrades and healing. The four-seed tier cohort proves altered encounter/reward flow, not difficulty certification. No difficulty edit was made solely to force wins or monotonic test outcomes. Treat Hardened/Strange tuning as provisional pending human play and larger weak/median/strong build cohorts.

Engine fact-check: [Godot RandomNumberGenerator source documentation](https://github.com/godotengine/godot/blob/master/doc/classes/RandomNumberGenerator.xml) treats its algorithm as an implementation detail; seeds here are engine-4.7.2 reproduction evidence, not cross-version guarantees. [Official Android export documentation](https://github.com/godotengine/godot-docs/blob/master/tutorials/export/exporting_for_android.rst) informs use of the existing local SDK/JDK/signing setup. No outside game's exact balance values or purported industry rules were used.

## Genuine blockers / future content

`human-art-inventory.json` preserves exact existing manifest entries. Each of the five humans has twelve authored-beta pose entries and twelve body-art-required entries: READY and RELEASE for **bow, crossbow, sling, caster, wand and orb**. All human entries remain right-only authoring; left silhouettes use the existing mirrored fallback. New left authored sheets, paired support-hand/grip layers, ranged draw/release and final identity/approval remain art work. Movement/hurt/death uses existing motion/flash/result presentation; no separate newly authored animation sheets are claimed. Existing whole-roster support-hand gaps, weaponless Moonkip, regional boss/miniboss stand-ins and provisional music remain open from prior reports.

No new single-hand sword/shield slot, offhand system, unique named-item final art, cosmetic unlock art, explorable secret room, secret boss or fully distinct regional boss animation was invented. This slice implements compatible gameplay foundations; those are future roadmap/content/art debt. Human long-term economy/mastery enjoyment, difficulty-tier calibration, physical touch feel, audio mix, loading/memory/thermal frame pacing and Android background/resume remain physical acceptance gates.

## Multidisciplinary sign-off

Whole-product readiness is deliberately separate from focused fixture acceptance.

| Discipline | Sign-off |
|---|---|
| DESIGN | ISSUES — expansion loop implemented; long-term mastery and tier feel require human acceptance |
| BALANCE | ISSUES — measured distributions retained; small tier/weapon cohorts do not certify calibration |
| ECONOMY | ISSUES — transaction/farming/source-sink checks pass; long-term human pacing remains open |
| ROSTER | ISSUES — five existing humans integrated; exact final ranged/left/support art is missing |
| ENEMIES | ISSUES — regional elite pressure live; existing authored regional art debt persists |
| BOSSES | ISSUES — blueprint/seal sources live; no new canonical boss mechanics/art claimed |
| RNG | ISSUES — bounded broad target drops and recipe access pass; rare discovery feel needs playtest |
| UI/UX | ISSUES — native phone/tablet checks pass; physical touch/readability acceptance pending |
| NARRATIVE | PASS for new slice copy — original Compact/Crown-compatible biographies and encounter text; deep secret/lore expansion is future work |
| AUDIO | ISSUES — licensed bank/mix preserved and packaged; provisional music and device listening remain |
| MOBILE | ISSUES — export/native layout pass; S23 thermals/lifecycle/frame pacing not measured |
| QA | ISSUES — focused automated/native evidence accepted; physical acceptance outstanding |
| PRODUCTION | ISSUES — playable slice/checkpoints/package delivered; commercial art/device gates remain |

## Smallest S23 retest

1. Install `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4a-debug.apk` over the existing app; keep app data.
2. Choose a human, finish/retry Treasure Ruins, then inspect **Gear → Forge → Blueprint Forge**, **Expeditions → Local Contracts → Regional Bounties**, and **Archive → Collection & Mastery**. Swipe a list, forge when eligible, claim one completed bounty; verify costs once and mastery/materials remain after closing/reopening.
3. Replay a cleared region; try Hardened at Rank 2 and Strange at Rank 3. During one run background/resume once. Report only incorrect touches/charges, unreadable text, visual/audio faults, stutter or unexpectedly easier/harder tier behavior. No unlock/save wipe is required.

No device was attached during packaging. Use Settings support/diagnostic details if a fault needs reproduction; native desktop evidence does not replace this short physical check.
