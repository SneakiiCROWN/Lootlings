# Phase 4B implementation and acceptance

Continued from clean Phase 4A `05d32f3`, preserving the interrupted local implementation. No resets, old checkout replacement, generated final art, new audio downloads or broad controller refactor. Recovery brief is archived alongside this report. Scope is section 23's first playable slice.

## What is playable

Home → Begin Expedition → **Modes / Relic Siege / Dungeons** opens the contextual selector. Siege works without Act I completion. Rootglass Vault opens after Act I unlocks Mossglass; the existing Relic Route remains available. Twelve owned character identities retain their starters, affinities, perks, gear and saved mastery.

Siege uses the existing three Act I environments as round bands, then remains in the Hoard Depths. It has sequential enemy encounters, not a new explorable map or simultaneous horde system. Rounds never stop at 15. Three foes per ordinary round rise to six; bosses/invasions use one special foe. Round 5 and every fifth round guarantee elite pressure; every tenth round presents the existing mechanically distinct boss and an extraction choice. Random elite weight rises from .10 + .012/round to .45; eligible miniboss invasions have 7% weight. Existing Hasty, Overcharged, Leeching, Rootbound, Enraged and Gilded affixes retain their readable mechanics. One affix per foe is the current exclusion rule.

Both exponential and base HP growth cap at round 15. Later pressure comes from increasing sequence length, elite frequency, attack cadence and incoming damage. Cadence has a .65s floor. The actual-combat fixture reached and extracted at round 40; this does not certify arbitrarily deep balance. No multi-affix packs, unique new rare boss variants or new final boss art are claimed.

Every third non-boss round offers a paid service: **Prism Split** (+1 hit, cap six), **Bloodfire** (+2.5% leech, cap 20%, with −1.5% armour), or **Patch Up** (25% HP), or Keep Moving. Named machine/shrine events are chosen randomly. Costs increase with round and cap their surcharge at 180 Embers. Existing elements/signatures combine with these run-only stats. The Quiet Mechanism has a discoverable staff/round interaction and a saved Archive discovery; its optional fragment stays unsecured until extraction. No puzzle room or secret boss is invented.

Extraction at 10 awards The Last Receipt; extraction at 20+ also secures Crownroot fragments. Continuing retains an unsecured bundle and raises round pressure/harvest, while death loses that bundle. Gear, ordinary regional material, mastery, discoveries and general earned progression survive. Increased rare-invasion weighting and distinct deeper reward pools remain content tuning beyond this foundation; current elite weighting and fragment quantities increase with depth.

Rootglass Vault adapts the existing eight-stop seeded DungeonController: Mossglass identities/materials/modifiers, a guaranteed third-stop regional miniboss and the region's established final boss. It awards one guaranteed Crownroot fragment on completion plus a 1% complete Gravebloom Staff chance. Targeted dungeon victory never unlocks campaign regions. This is a replayable sample destination using existing rooms/art, not a newly authored dungeon map.

## Fixes and safety

- Contextual mode panel has explicit visual order and an opening guard. Registered Phase 4B buttons, the Home gate and rebuilt destination cards now use the existing gesture owner for one deliberate release, drag cancellation and suppression of duplicate synthetic mouse events; mouse/keyboard paths and other menu touch fixes stay intact. Ownership respects travel/vignette/confirmation input veils. State-specific navigation returns Modes to Home and Spinner to Results. Leaving resets Siege/target flags.
- `run_resolved` makes run settlement terminal, including calls after opening the spinner. Extract/Continue operate only in checkpoint state; rapid repeated input cannot settle twice.
- Siege starts with zero Embers; permanent Run Scrip pouch upgrades cannot seed Siege funds. New runs clear the old spinner wallet and temporary upgrades.
- Tier reward caps were moved from the mistakenly edited debug helper into live spawning. Forced higher-tier elites cannot accelerate temporary coin/XP income. Between-wave restoration is 20/12/8% for Trail/Hardened/Strange; enemy HP curves are unchanged in normal modes.
- RED reserved delivery survives a full stash, retries after room is made and uses a persistent receipt. Numeric fields and pending reward schemas are checked. Failed provider writes roll back spin debit and RED craft debit.
- Completed local recipes redirect spinner clues to another incomplete local recipe; if all are complete, the clue becomes regional material.
- Rootglass HUD/results name the destination. RED sorting, rarity colouring and existing item badge presentation are supported. Secured keepsakes appear on result cards and in the summary; Archive reports Gravebloom ownership. Gravebloom has two existing Forge evolution stages.
- Removed the Archivist tap branch that replaced a character reaction with a next-region story line. Quiet Home behavior from human-QA remains intact.

## Measured gameplay and economy

[Raw per-run evidence](runs.json) and [distributions](metrics.json) retain failures. Fresh disposable saves/scenes use owned starters, no meta power and a Sustain/tap policy; automatic simulation is breadth evidence, not human skill or mobile timing. Choices and menus consume little simulated time. There is no victory quota.

| Cohort | Outcomes | Median simulated seconds | Median incoming damage | Median materials |
|---|---:|---:|---:|---:|
| All 12 characters, Siege 10 | 11/12 extracts | 73.3 | 162.3 | 16 |
| Four Beast seeds, Siege 20 | 3/4 extracts | 200.4 | 738.0 | 40.5 |
| One Beast seed, Siege 40 | 1/1 extract | 522.25 | 6608.4 | 101 |
| Four Rootglass Vault seeds | 4/4 clears | 37.325 | 93.8 | 10.5 |

Mosskin died at round 10; one deeper Beast seed died at 17. Their ordinary materials and general progress survived; no RED extraction fragment was secured. Do not make these seeds win by reducing difficulty. Single-seed roster coverage proves valid flows, not roster parity. Round-40 success demonstrates traversal, not a calibrated endless ladder.

Paired four-seed normal-tier comparison against frozen Phase 4A:

| Tier | Median seconds before → after | Damage before → after | Scrip before → after | Lowest HP ratio before → after |
|---|---|---|---|---|
| Trail | 146.6 → 146.6 | 527.8 → 527.8 | 962 → 962 | .823 → .823 |
| Hardened | 122.6 → 123.375 | 332.3 → 338.6 | 978.5 → 961.5 | .590 → .425 |
| Strange | 147.125 → 146.525 | 531.9 → 540.3 | 990 → 954 | .816 → .794 |

Strange median end level falls 12 → 11. The corrected temporary reward faucet and reduced free restoration increase risk without HP inflation. Hardened still clears faster for this build/policy; reduced HP reserve indicates greater danger, but remaining tier/cadence/build interaction calibration is an ISSUE. Small samples do not justify further arbitrary tuning.

Spinner: at least ten defeated foes; at most three meaningful spins; escalating 140/230/360 cost (730 total). Each independent roll gives 50% two local material, 35% six mastery units for both active actor/weapon, or 15% one local recipe clue. Three spins expect three materials, 6.3 mastery per track and .45 recipe fragments. No boss seals, exclusive Siege item or full RED/RED fragments. Consequently it cannot replace boss/RED farming. It remains a supplementary faucet; long-term material/mastery reward/hour requires human duration and broader loadout evidence. After an eligible failure it remains usable with leftover funds; starting another run expires that wallet.

20,000 round-rule samples exercise milestones/elite/invasion probabilities. 3,000 RED paths use 1% complete chance plus guaranteed one fragment per dungeon clear. **p50 24 clears, p90 24, worst case 24**, minimum one. At the measured dungeon median: **14.93 minutes of simulated combat**; real reading/navigation/deaths add time. At 1–3 minute human clears: 24–72 minutes for the guarantee. This is reasonable as an introductory deterministic RED route, not a final long-term endgame chase. Deep Siege secures more fragments per extraction but puts them at risk. Keep 24 until S23 clear-time evidence exists.

Gravebloom has Legendary-level raw rarity scaling, a poison/three-target circuit identity and an HP tradeoff; RED is not a global loot-tier power escalation. Only its specified dungeon/deep extraction sources award it. Existing canonical staff art is reused: unique final RED art is a recorded production need.

| Resource | Current distinct purpose |
|---|---|
| Run Scrip | Expedition/Dungeon temporary decisions; eligible result spinner |
| Siege Embers | Siege temporary services; eligible result spinner |
| Gold | Permanent general supplies, crafts/evolutions |
| Scrap | Salvage, common Forge/stash/gear transactions |
| Star Shards | Existing permanent Shrine power/character unlocks |
| Regional materials | Region-targeted named forging |
| Boss Seals | Boss-gated high-tier named forging |
| Blueprint fragments | Recipe access |
| Crownroot fragments | Single explicit RED target guarantee |
| Mastery XP | Character/weapon use tracks; stat-free Relic Rank recognition |

Scrip and Embers deliberately share temporary spending mechanics but are mode-labelled and reset separately. No ten-currency proliferation or monetisation was added. Owned weapon two-stage investment remains capped; there is no new ascension/wardrobe system.

## Save architecture

`LocalSaveProvider` wraps existing verified-temp/prior-good SafeConfig for the new `endgame.cfg`; old stores remain intact. Highest round, score, tracked target, Crownroot count, dungeon clears, session identity and reserved deliveries persist. Existing records continue in their original stores. No fake cloud transport, no required network and no mid-run resume is claimed.

Spinner debit plus pending reward reservation save together before payout. Item delivery uses the inventory craft receipt; material/mastery delivery stores resource mutation plus receipt in expedition progress before removing the reservation. Replays cannot pay twice. This is recoverable ordered per-file delivery, **not atomic settlement across all legacy stores**. General end-run Gold/Shards still use the legacy save path; power-loss at every cross-store instruction is not certified. Full-stash RED is reserved, not destroyed or automatically scrapped; the mode panel says to make room. Starting a new run expires the previous leftover wallet intentionally.

Current Godot references: [ConfigFile explicit save/error semantics](https://docs.godotengine.org/en/stable/classes/class_configfile.html), [RNG implementation limits](https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html), [input propagation/emulation](https://docs.godotengine.org/en/stable/classes/class_viewport.html). Replay claims bind to verified 4.7.2 and fixtures, not cross-version RNG determinism. No unsupported industry practice or copied tuning values is asserted.

## Acceptance evidence and limits

Focused fixtures: new mode rules/flow, exclusive pools, RED forge/reload/full-stash/replay, failed save writes, spinner cap/receipt, temporary reset/pouch isolation; existing dungeon, gestures, rewards, recovery, evolution and mobile telemetry. Existing corrupt-save fixture's two expected parse diagnostics are deliberate. [QA results](qa-results.json) record accepted runs; failed native investigation is separately retained, not silently reported as passing.

Native Godot captures inspect actual 1080×2316 and 1600×2560 viewport rendering, menu entry, Siege combat/boss checkpoints, extraction/Continue, rapid spin, target route, scroll-to-Siege Archive, RED forge and ordinary-mode return/pause. Native touch uses screen events and the established stretch transform, with window focus and settled layouts. Before the scoped single-owner correction, synthetic mouse ordering intermittently missed contextual button actions. The final fixture also retests the original one-frame mode-entry/Continue/extract contacts and drag cancellation; investigation exposed a wrong normal-Home fixture assumption and an attack-counter sample taken before automatic combat. Runtime state/settlement/funds/navigation fixes are separate from those fixture corrections. Physical S23 input remains an acceptance gate.

Uninterrupted 90-frame desktop Siege/boss/Archive samples and conservative texture estimates are in evidence. Capture-time FPS snapshots include PNG readback/encoding stalls and are not steady gameplay FPS. Native desktop GL on RTX 4080 SUPER does not establish handset performance. All runtime PNG assets together have an approximate **346.3 MiB RGBA8 upper bound**; this is not actual residency or Android PSS. Static actor/body/portrait caches and preloaded backgrounds retain visited content; full human body poses remain uncapped in some imports. No texture quality was destroyed to lower a speculative memory number. Physical loading, PSS, spikes, thermals, background/resume, phone speakers and headphones remain required.

APK version 9 / `0.4.0-phase4b`: offline signed arm64, package identity preserved, min SDK24/target36, 16KB alignment, current imported poses/bow and 329 licensed PCM assets validated. Tests/tools/reference/source art are excluded. [Exact package identity](android-build.json). Debug signing is not store-release approval.

## Production gates and discipline sign-off

The [consolidated project QA](FULL_PROJECT_QA.md) separates current functional acceptance from whole-product readiness. Missing final human ranged/support/left poses, weaponless Moonkip, paired assets, Relic Sling, sharper approved Gloomlet master, Hoard Dragon/regional boss identity/animation, unique RED art and final audio remain gates. Glimmerfin's inspected runtime is already weaponless; do not revive that historical blocker. No generated/beta asset is declared final.

| Discipline | Sign-off |
|---|---|
| DESIGN | ISSUES — playable retention loop; human session/greed feel pending |
| BALANCE | ISSUES — measured improvements; residual tier/build and deep-round calibration |
| ECONOMY | ISSUES — bounded/targeted receipts pass; human reward/hour pacing pending |
| ROSTER | ISSUES — all twelve combat flows; final human/creature support art missing |
| ENEMIES | ISSUES — existing roles/affixes work; identity/art expansion remains |
| BOSSES | ISSUES — milestone/region mechanics live; final art/variants incomplete |
| RNG | ISSUES — rules/pity/exclusions measured; full variety/rare-event depth remains |
| UI/UX | ISSUES — native touch/layout evidence; S23 acceptance pending |
| NARRATIVE | ISSUES — slice copy usable; contextual character/item writing needs Phase 4C |
| AUDIO | ISSUES — working licensed/procedural fallback preserved; final production pending |
| MOBILE | ISSUES — signed export/native layouts; physical frame/memory/lifecycle pending |
| QA | ISSUES — focused evidence retained; physical/human acceptance outstanding |
| PRODUCTION | ISSUES — first slice delivered; commercial gates remain |

Stop after checkpoint/backup. Install over existing app data, test Siege 10 extraction or Continue, one spin, Rootglass target/source and one background/resume/reopen. Do not wipe saves or start Phase 4C automatically.
