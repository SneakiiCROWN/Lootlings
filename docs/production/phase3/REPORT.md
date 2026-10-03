# Phase 3 implementation, comparison and acceptance — 2026-10-03

The interrupted work was preserved, inspected and continued on the existing branch. No reset, replacement art generation or difficulty adjustment to meet a seed quota was performed. The exact [brief](BRIEF.md) and [frozen baseline](BASELINE.md) remain tracked. `af69ed4` implements the main tranche; `68162a1` checkpoints the measured target/reward/healing corrections. This delivery adds reproducible final evidence, native review and updated production authority.

**Acceptance remains open.** Code and testable content are implemented; missing canonical animation/body work and physical/human acceptance prevent an honest claim that every requirement of the full brief is finished. Native screenshots are real Godot OpenGL output inspected visually, with synthetic input transactions. They are not a manual play session, an S23 rendering test or a human listening review.

## Implementation and keep/revert decisions

| Baseline problem / proposal | Implemented correction | Evidence / decision |
|---|---|---|
| Reused scenes, late seeds and partial save clearing could contaminate measurements | Fresh scene and disposable storage per sample; seed before spawning; all disposable files cleared; legacy audit delegates to guarded harness | 512 paired records plus six independent replay assertions; repaired encounter/evolution fixtures reproduce. Keep. Earlier exploratory evidence preserved outside accepted cohorts. |
| Spear opening stayed consumed between solo enemies; overkill restored fictitious HP | Reset per-foe state; attack leech uses actual HP removed; poison siphon uses HP left after burn | Direct lethal/overkill/status contracts and regression pass. Keep; no raw weapon-speed buff. |
| Identical selectable actors; unbounded additions would compound control/healing | Twelve run-only species/personality perks with starter kits, explicit HP/movement tradeoffs; shared control budget and bounded ward/delayed-hit queues | 192 tap and 96 idle roster samples; twelve actor lab values and all actor/native matrix review. Keep identities; no forced win-rate parity. |
| Repeated predictable encounter order and enlarged basic boss attacks | Seeded bounded role variation; ten named regional six-action boss loops, phase-two rotation, real non-damaging recovery; four-action miniboss loops | 110 pressure measurements, 120 boss and 40 miniboss native action checks, encounter/group regressions. Keep mechanics. Distinct final regional silhouettes/animations are still missing. |
| Elite variety without coherent danger/reward constraints | Reknitting, Enraged and life-draining additions; eleven live modifiers, weighted compatibility, one modifier per foe and increased rewards | All elite native states and bounded healing/HP/control contracts. Keep; no arbitrary multi-modifier pileups. |
| Filler stats and inadequate behaviour/source identity | Twelve named variants: ward on critical kills, target-bound heavy echo, true follow-up frost shatter, first-hit courier bonus, poison retaliation, slow-heavy stagger and a disclosed cursed tradeoff | All twelve save/reload/signature contracts and reward screens; four identities restricted to their regional boss pools, tested across 3,000 boss choices plus public shops/caches. Keep. |
| Empty stretches and identical merchant visits | Two optional event opportunities per campaign, eight weighted nonrepeat events, two consequential choices plus skip; four merchant styles and modest family-aware stock weighting | 24 event-choice/duplicate boundaries, actual native touch no-attack-leak checks, 4,000 inventories. Keep; additions reuse the established route/event architecture, not a replacement run system. |
| Equipment droughts and adjacent duplicates | Eighteenth empty roll guarantees equipment; exclude the two most recent item IDs; unique boss choices | 10,000 ordinary rolls: worst drought 102 → 17, successive duplicates 17 → 0. Keep. Rare items remain rare; no guaranteed perfect build. |
| Incorrect percentage language and missing detailed build disclosure | Honest additive tap/interval wording; full perk/Core/stat text in scrollable Pause; short HUD totals and exact costs/details; rank-100 training cap | Native phone/tablet panels, extreme-total screens, cap and touch regressions. Keep. No new generic confirmation prompt on every action. |
| Broad balance or price changes without evidence | Retain base family cadence, enemy HP curves and permanent prices; compare new sources/sinks and policies | Stationary family DPS changes are small; affordability retains choices. Reject arbitrary global nerfs/buffs or bot-quota pricing. |

No existing good art was replaced. Bow facing/string/nock, elemental projectile silhouettes/trails, canonical pickups, species audio, startup branding, touch ownership and save protections from the fidelity tranches remain active and regression-checked. Audio sources/licenses remain packaged and tracked. No final art was generated.

## Measured before → after

[Full percentile tables](final/METRICS.md), [512 individual final runs](final/runs.jsonl), [comparison](final/comparison.json), [broader roster/pressure/Core contributions](final-broader/values.json), and [96 no-tap outcomes](final-idle/summary.json) are the evidence, including failed runs. Frozen and final cohorts remain disjoint: 384 weapon/Core-policy samples, 80 campaign sustain samples and 48 initial actor samples. Eight fixed shared seeds per weapon/Core policy support comparison; two initial actor seeds do not establish parity. Final additional actor cohorts use eight seeds each.

| Measure, 384 weapon-policy cohort | Frozen | Final |
|---|---:|---:|
| Completion | 297/384 | 341/384 |
| Combat duration median / p90 | 135.50 / 169.00 s | 139.45 / 183.35 s |
| Damage received median / p90 | 454.18 / 683.85 | 419.15 / 713.04 |
| Minimum HP ratio median / p10 | 0.51 / 0 | 0.75 / 0 |
| Completed boss duration median / p90 | 15.30 / 22.00 s | 16.25 / 24.00 s |
| Completed foe TTK median / p90 | 1.85 / 4.70 s | 1.85 / 4.85 s |
| Earned / spent / left Scrip, medians | 940 / 109 / 778 | 1028 / 199 / 839 |
| Recorded menu actions, median | 20 | 23 |

Completed-fight effective DPS median is 108.22 → 107.47, p10 46.53 → 44.21, p90 225.19 → 228.93. Foe HP divided by real fight time includes approach/entry/hit-stop and differs from stationary DPS. Failed unfinished fights are excluded from completed-fight durations but remain failed outcomes. Raw 30-second neutral four-tap DPS and two-second burst for every family are tabulated separately. Cadences are unchanged; small crit-stream shifts follow new seeded encounter selection. Core deltas and no-crit comparisons are measured, not invented additive percentages.

The single-seed two-second burst sample falls across the families, despite unchanged base cadence/damage formulas. Encounter RNG consumption now changes the subsequent crit stream; that table cannot distinguish a general burst change from the opening crit draw. It is a recorded sample, not a population estimate or grounds for a compensating buff. Multi-seed combat distributions and the final no-crit/Core lab remain the stronger evidence for keeping the base values.

All 80 campaign sustain samples complete in both cohorts; median duration rises 123.77 → 133.30 seconds. This is a deliberately strong fixed sustain strategy, not proof that every player/build can clear every region. Final roster: 192/192 active tap/sustain samples, versus 52/96 identity-kit idle/sustain samples. Idle actor range is 1/8 Moonkip to 8/8 Ruin Warden. This flags input-policy sensitivity and defensive value, not a reason to erase identities. Eight seeds are insufficient to prove population parity or rare extreme-build bounds.

Incoming-pressure trials cover every region's three regular roles at waves 1/7/14 plus every miniboss and boss: 0.904–14.589 damage/sec against an untrained, nonattacking Vanguard. The corresponding 100-HP approximation is 6.85–110.58 seconds. These 60-second trials inflate HP to prevent early termination and keep bosses in phase one; they are **not actual lethal-run TTK**. Both boss phases and their recovery are separately validated. Group/AoE/range/control value retains encounter contracts and actual run evidence; it is not claimed identical to raw stationary DPS.

Three additional median menu actions include two event skips. This is an action count, not a claim of three more meaningful player decisions or human pacing: menu dwell is excluded. The optional events, merchant styles and curated signatures create concrete alternative consequences; long-session replay appeal and varied human decisions still require playtesting.

## Economy, progression and RNG

Faucets: kill/elite/boss Scrip, explicit event rewards, capped run Gold/Shards, contract Gold, equipment finds and salvage. Sinks: run stock/rerolls/event bargains; persistent stock/cache/rerolls/stash capacity; Gold cache/home upgrades; Gold+Scrap Forge stages; Shard training. Scrip is run-only; leftover Scrip is displayed rather than silently presented as persistent wealth. Archive replays pay nothing; abandoned/empty route rewards and duplicate transactions retain existing guards.

Regular 10,000-roll finds: 695 → 976. Common/Rare/Epic/Legendary counts: 503/150/34/8 → 696/221/45/14. These are long-stream measurements with run-local pity, not a guaranteed per-run drop frequency. Boss, miniboss, cache and cursed-event sources keep separate weighting/source restrictions. Live affixes total fourteen of eighteen declared; four unavailable future behaviours stay gated. No fake fork projectile is advertised for the fifth-hit Lightning signature.

First merchant median held Scrip 157 → 181; median cheapest stock remains 94, total stock 332. Second merchant median held 433.5 → 396, cheapest 124, total 472; final held p10/p90 362/528. Some rich runs can buy everything; typical ones face a choice. The limited bot buys at most two cheapest affordable nonweapons and can stop when the cheapest is a weapon; its unused money is not evidence that real players lack useful purchases. Discount minima are 80/105. No price rewrite is justified by this bot.

Permanent prices remain Common/Rare/Epic/Legendary 12/28/65/140 Scrap; Mystery Cache 20, expected salvage 4.1; reroll 9; expansions 45/90; Gold cache 180; Forge 180/420 Gold + 8/18 Scrap. All buy→salvage loops lose resources. Existing home upgrade ladders and training cap stay intact. Per-segment income, purchases and reward distributions are retained. Full long-term progression across trained/loaded builds and human shopping strategies remains an acceptance gap, not an inferred economic success from short starter runs.

## Native, UI, narrative, audio and regression review

[Evidence manifest](evidence/manifest.json) links native matrices, reviewed phone/tablet contact sheets, regional miniboss loops and final high-resolution detail screens. The current matrix covers 2,592 actor × family × facing × pose samples; species audio fixture covers twelve playable identities/fourteen profiles and 27 enemy/boss contexts with captured mix peak −0.8 dBFS. This establishes hooks/routing/PCM bounds, not acceptable timbre or absence of fatigue on phone speakers. Nine regional miniboss bodies visibly reuse Grump Knight; that is a blocker, not a newly authored silhouette.

Reviewed screens include title/branding, all creature selectors, hub, combat/HUD/status feedback, merchant/rewards, inventory/Forge, upgrades/training, settings/profile, notes/archive/contracts/expeditions, results/toasts and confirmations. Phone 1080×2316 and tablet 1600×2560 each have 49 screen captures; final Pause, event consequences, new item descriptions and extreme totals have five additional native captures per size. Native content fixture covers 206 states, including all events/items/elites, 120 boss action states and 40 miniboss action states. Gesture/layout regression retains 22 size/cutout cases and UI input ownership. Screenshot-writing time is not device FPS.

New trait/event/item/boss strings were reviewed against canon/Voice Bible, with concise consequence labels, short recurring calls and serious lore retained. World Bible's old equal-cosmetic-power statement is explicitly superseded by run-only perks. Gloomlet identity remains canonical. Prior full dialogue cleanup is preserved rather than rewritten again; this pass corrects new/incorrect mechanics copy and disclosure. All dynamically possible descriptions, unforeseen stat magnitudes and future authored content are not certified by the finite captured screens.

[Accepted checks](final/qa-results.json) retain 152 green parser/regression/measurement/native entries and superseded results. The initial full command was **not wholly green**: old encounter/evolution isolation/assertions, renderer-only fixtures attempted headless, and an obsolete fixed Mossback opening assertion needed correction. Native renderer fixtures, fresh-scene replay repairs and the bounded seeded-opening smoke check supersede those failures, with history retained. Save recovery's two deliberate corrupt-fixture diagnostics remain expected. No error was suppressed to turn an invalid measurement into acceptance.

Earlier “2 wins from 5” is not a reliable balance target: the old harness seeded after spawning/reused state. Corrected pre-Phase-3 smoke reproduced 3/5; current two isolated diagnostic passes each reproduce smoke 4/5, survival 5/5 and merchant 5/5. Death is legitimate in those policy probes. New 384/192/96 distributions are substantially stronger evidence than five seeds, and still do not predict real-player difficulty. No enemy HP or global damage adjustment was made to force smoke wins.

## Android and smallest S23 retest

APK: **`C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase3-debug.apk`**. Version 5, `0.2.0-phase3`; 131,825,269 bytes; SHA-256 `a2528185af17e345eab87b0deaf7c61e4c02ab8478d9815d1056a200db973015`. [Build verification](final/android-build.json): signed arm64 debug, min SDK 24/target 36, 16-KB zip alignment, offline/no permissions, current imported bows/Relic poses and 329 PCM assets/licenses verified, Phase 3 modules present, development/reference/tests excluded. Runtime code matches the gameplay checkpoint; subsequent delivery edits affect tests/evidence/docs only. It is not release-signed or store-ready.

1. Copy the APK to the S23 and install it **over the existing Lootlings app**. Keep the existing installation/data; verify owned gear/currencies survive the update.
2. Play Act I with Relic Beast, then a bow starter (Vault Runner/Ashtrail). Tap and briefly stop tapping; inspect both bow facings, projectiles, creature hurt/death sounds, boss cues/recovery and reward cards. Try an event choice and merchant/menu drag; verify no stray attack/purchase.
3. Play about ten minutes, background/return once, Resume, then return to hub, close/reopen and check committed gear/currency. Report any clipping, stutter, heat, irritating sound or lost/duplicated reward. Pause → TEST REPORT provides the in-game diagnostic summary.

The device was not connected for this pass. Physical frame pacing/FPS, thermal/memory behaviour, loading, Android audio fatigue, safe-area/gesture feel and platform lifecycle/save persistence remain open. Existing focus-pause/Resume and persistent stores are tested synthetically; runs themselves are not resumable after process death, and eight stores are not a cross-store atomic transaction.

## Remaining blockers and multidisciplinary sign-off

Canonical art: 82 right-facing / 83 left-facing support-hand/paired combinations incomplete; weaponless Moonkip needed; distinct regional miniboss/boss bodies, silhouettes and authored attack/reaction animations remain unfinished. Do not fake them with transforms or generated final art. Eight music tracks remain provisional. Physical and human acceptance must test actual feel, audio, memory/frame budgets and long-session pacing. Further varied-strategy/trained progression measurements are required before claiming full balance/economy acceptance.

| Discipline | Sign-off | Evidence / remaining issue |
|---|---|---|
| DESIGN | ISSUES | Concrete identities/events/builds live; human pacing/replay appeal not accepted. |
| BALANCE | ISSUES | Paired distributions and pressure measured; active/idle disparity and loaded human strategies need acceptance. |
| ECONOMY | ISSUES | Sinks/affordability and duplicate guards pass; long-term trained progression/human shopping not established. |
| ROSTER | ISSUES | Twelve mechanics live; authored support/body pose blockers remain. |
| ENEMIES | ISSUES | Roles/weighted elites measured; final species presentation and human encounter feel remain. |
| BOSSES | ISSUES | All loops/recovery/phase cues verified; regional authored body/animation identities incomplete. |
| RNG | ISSUES | Reproducibility, source exclusions, pity and duplicates pass; extreme lucky-build/long-session replay coverage remains bounded. |
| UI/UX | ISSUES | Native phone/tablet/touch contracts pass; real S23 readability/gesture acceptance pending. |
| NARRATIVE | ISSUES | New copy/canon aligned; regional visual identity still contradicts distinct encounter presentation. |
| AUDIO | ISSUES | Species hooks/license/mix checks pass; phone-speaker listening/fatigue and final music unresolved. |
| MOBILE | ISSUES | Signed verified APK ready; physical FPS/memory/thermal/loading/lifecycle pending. |
| QA | ISSUES | Accepted automated/native evidence green; no physical/manual-feel or exhaustive future-state acceptance. |
| PRODUCTION | ISSUES | Safe checkpoints and reviewable evidence delivered; authored-content and device gates prevent full-phase completion. |

## Fact checks and scope of inference

[Godot RNG documentation](https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html) supports hashed seeds/reproducible sequences and warns the generator implementation is not a cross-version guarantee; engine 4.7.2 is pinned here. [Godot Android export documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html) informs JDK 17, signature/update constraints and launcher safety. [Dan Hart's GDC economy case study](https://media.gdcvault.com/gdconline11/Dan_Hart_VirtualItemsSummit_BalancingYourGame.pdf), p28, supports enumerating activity sources/sinks; no freemium values or another game's economy was copied. Keep/revert judgments above are project-specific inferences from measured outcomes and visible contracts, not invented industry rules.
