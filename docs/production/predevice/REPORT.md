# Final pre-device candidate audit — 2026-10-04

The current candidate implements the owner's one-choice reward rule and fixes reproduced save, UI and cleanup problems. Runtime checkpoints: `4d262ef`, `de80adb`, on `codex/phase2-vertical-slice`, starting clean at `d073dd6`. Prior Phase 3 work is preserved. [Exact brief](BRIEF.md), [baseline/proposals/criteria](BASELINE.md), [repository inventory](repository.json), [evidence reuse proof](reuse.json), [accepted checks and supersession history](qa-results.json), [native evidence](evidence/manifest.json), [Android verification](android-build.json).

This is suitable for disclosed outside testing. It is **not full Phase 3/commercial acceptance**: missing canonical poses/encounter art, final music, physical phones and human/long-term balance/economy judgment remain open. No final AI art, monetization, blanket architecture rewrite or difficulty reduction was introduced.

## Audit and implementation

| Area | Review / result |
|---|---|
| Repository/code/files | Inventory includes runtime scripts/scenes/settings, assets/audio, tools and docs; all literal resource references checked. Only missing literal path is the wardrobe fixture's intentional negative `art/not_delivered.png`. Constructed references are covered by catalogs/package/regression checks. No inferred orphan assets or provenance were deleted. |
| Gameplay/routes/content | Campaign, dungeon/group patrols, route/evolution, events, contracts, merchants, hoards, death/result and return flows covered by fresh fixtures and retained native evidence. All ten regional boss loops, elite compatibility, miniboss recovery and twelve actor kits remain. Content quantity does not establish endless replay depth. |
| Run rewards / items | Multiple normal finds now offer one selection, with alternatives forfeited. One purchase per merchant stop, no automatic restock or second charge. Boss hoard still offers three Epic+ alternatives. Disposition is equip/stash/scrap of that acquisition. Level rewards/events/persistent services remain deliberate separately labelled beats; no extra confirmation on single normal finds. |
| Economy | Reroll starts at 36/51 Scrip at waves 6/11, rises 18 per reroll and retains weapon-family weighting. Gear prices, rarity, income, permanent prices and salvage stay intact. Duplicate purchase/reward and buy→salvage guards pass. Finite end-state usefulness is explicitly unresolved below. |
| Roster/weapons/enemies/bosses | No homogenizing stat change. Stationary DPS/pressure, 2,592 actor/family/facing/pose native samples, bows/projectiles/species voices and regional action evidence retained where unchanged. Fresh 192 active/96 idle roster runs supplement the 512 paired rows. Authored support/body/encounter blockers remain. |
| UI/HUD/text/mobile | Larger 86×64 Pause target; device-neutral report title; compact large Scrip totals; clear pick-one labels; cost/purchase consequence above scrollable details. Fresh native review found and fixed reward icons covering rarity/text: 124-unit text gutter with fitted names. Actual touch ownership, swipe/tap separation, confirmation guards and 22 size/cutout cases remain checked. |
| Narrative/canon/dialogue | Existing reviewed world/voice/dialogue/catalog files are unchanged and hashed against the delivered baseline. New copy discloses acquisition consequences and uses established Scrip/Hideout/hoard terms. No forced new jokes or franchise copying. Internal vignette beta metadata is not displayed: the player sees the category. Finite screenshots cannot certify every unforeseen future string/stat combination. |
| Audio / VFX / visuals | Approved asset bytes, species routing, bows/arrows/element trails, canonical pickups/rarity/chests retained. Fresh native combat exercised live hooks; mix capture peak −0.80 dBFS, RMS −23.33 dBFS, limiter enabled, 12,952,132 PCM bank bytes. This is routing/signal evidence, not subjective phone-speaker acceptance. Licenses preserved. Eight music tracks remain provisional. |
| Cleanup / performance | Removed uncalled procedural character/enemy renderers and dead merchant texture wrapper; renderer shrinks by 184 lines net, retaining the still-test-used compatibility helper. Retained renderer functions compare unchanged. Local diagnostic log now caps current file at 256 KiB, keeps one previous generation, rejects oversize entries and retains privacy filtering. Twelve scene/menu cleanup cycles return to one root node / zero orphans; static bytes increase about 223 KiB across those cycles. Desktop counters cannot prove Android PSS/GPU budgets or indefinite leak freedom. |
| Save/lifecycle | Validate parseable stash/equipment types/slots/finite effects and affected numeric fields. Invalid records ignored in memory, original save preserved on load; valid affixed/evolved gear survives exactly; starter fallback and prior-good backup recovery pass. Synthetic focus-pause/Resume, persistence, duplicates and empty/abandoned routes retain guards. Live runs do not resume after process death; eight stores are not an atomic cross-store transaction. |

## Measured keep decision

Compare against delivered Phase 3 `d073dd6`, not the earlier Phase 2 baseline. [512 individual rows/distributions](../phase3/rc-final/runs.jsonl), [paired comparisons](../phase3/rc-final/comparison.json), [active roster](../phase3/rc-broader/roster.jsonl), [idle cohort](../phase3/rc-idle/summary.json), [economy tables](economy.json). Each run has isolated fresh storage/scene and fixed seeded policy; six separate replay executions match. These policies preserve the starting weapon, prioritize sustain/Core upgrades and buy cheapest affordable nonweapon gear; they do not represent all human shopping or min-max strategies.

| Weapon/Core cohort, 384 runs | Before | Candidate |
|---|---:|---:|
| Wins | 341 | 339 |
| Combat seconds p10 / median / p90 | 105.15 / 139.45 / 183.35 | 105.15 / 140.22 / 183.10 |
| Boss TTK p10 / median / p90 | 10.40 / 16.25 / 24.00 | 10.40 / 16.45 / 24.00 |
| Damage received median / p90 | 419.15 / 713.04 | 431.64 / 725.25 |
| Minimum HP ratio median / p10 | .75 / 0 | .75 / 0 |
| Scrip earned / spent / left, medians | 1028 / 199 / 839 | 1027 / 199 / 844 |
| Decisions median | 23 | 21 |

All 80 campaign samples still win; the small mixed-policy 48 actor comparison remains 45/48. Broader active roster results remain 192/192. Idle identity-kit cohort remains 52/96, including Moonkip 1/8 and Ruin Warden 8/8; active performance, not idle equality, governs review. Lab sustained/burst DPS, healing, control, armour/ward and incoming-pressure distributions are reused because formulas and lab inputs are unchanged. No global damage, cadence or enemy-HP tuning was made. Deaths remain valid QA outcomes; no victory quota was imposed.

Keep the acquisition/reroll changes: the hard one-choice contract is now enforced, duplicate transactions blocked, consequences visible and overall TTK/survivability shift small under the paired policy. Rare extremes remain possible; eight seeds per weapon/Core do not prove the absence of every dominant combination. Original 2/5 smoke was an invalid seeded/reused-state harness; corrected fresh diagnostic results supersede it. Current smoke/survival/merchant outcomes are recorded in the accepted combat log rather than used as a difficulty target.

## Economy / RNG / new and veteran review

Faucets: kill/elite/boss Scrip, explicit event bargains/rewards, earned equipment, salvage, capped run Gold/Shards and contract Gold. Sinks: run stock/rerolls/event risk/tributes; persistent Scrap gear/cache/reroll/stash capacity; Gold cache/home ladders; Gold+Scrap Forge/crafting; Shard training. Archive playback pays nothing and empty/abandoned routes cannot mint permanent rewards. There is no real-money path.

Fresh 10,000 ordinary rolls reproduce 976 finds: 696 Common, 221 Rare, 45 Epic, 14 Legendary; longest drought 17, successive duplicate IDs zero. Four thousand merchant inventories preserve compatibility/source restrictions. Per-run pity and boss-exclusive sources remain distinct; these long-stream counts are not guaranteed per-run frequencies.

First merchant arrival median 181 Scrip; cheapest median 94. One 36-Scrip reroll leaves 145 and an affordable offer in all 2,000 sampled inventories; two rerolls cost 90 and leave 91, affordable in only 19.05%; three leave 19 and cannot fund sampled gear. This is an affordability example, not proof the new stock is desirable. At the second stop higher wealth permits more searching, but escalating costs can still remove purchase options. Legendary/Epic chasing competes with buying now, while the one-purchase rule prevents taking every offer even with excess funds. High final leftover Scrip under a no-reroll/weapon-preserving bot is not evidence that real players lack useful purchases.

Permanent Common/Rare/Epic/Legendary gear remains 12/28/65/140 Scrap. Cache costs 20 with expected salvage 4.1, so repeated buy→scrap loses resources. Home ladders total 11,700 Gold; training ranks 5/20/100 require cumulative 100/1,150/25,750 Shards. Rank 100 has 6× untrained base HP/damage before other modifiers; early-region trivialization at that earned rank is a real progression consequence, not a bug to hide by weakening or strengthening foes without evidence. Shards have no further sink after rank 100. Gold/Scrap remain usable for collections/services, but marginal value diminishes after ideal gear/caps. **Long-term post-cap economy/replay depth and loaded varied human strategies remain issues**, rather than being solved with an arbitrary tax/new system in this final audit.

For new players, controls and consequences are visible and drag/inspection cannot buy or attack accidentally. For veterans, target-specific leech, bounded control/ward, paid cache cycles, capped evolutions, source restrictions, duplicate guards and one-purchase gates resist tested loops. Human fun, novice frustration and every optimized strategy still require play acceptance.

## Native and final QA boundaries

One comprehensive final headless acceptance run includes parser/import, combat, fresh balance/economy/RNG/roster/boss/event/merchant/reward/save/touch/content regressions; unchanged DPS/pressure labs are explicitly reused. Separate final native acceptance covers gesture/monitor/layout, real-clock Act I trace, changed phone/tablet screens, item art and live audio mix. The trace won through wave 15 in 169.791 seconds, with desktop frame p95 17 ms; capture I/O and concurrent checks affect timing. This is scripted real-clock Windows play, not manual player feel or phone FPS/loading/heat.

Accepted evidence totals 166 parser/regression/measurement/native entries, including two explicitly reused labs. The original broad command was not wholly green: cleanup removed a still-test-used `weapon_pose_angle` helper, causing smoke to stop; the helper was restored and the focused smoke passes all original assertions. Its failure and followup are retained. No active rendering, combat or run measurement was altered by this compatibility restoration.

Original native layout failures are retained, including unsuccessful timing-only investigations. Fresh scene per size/cutout removes prior modal/native GUI focus/tween state; all original gameplay assertions pass. A tablet item-art invocation also exposed an obsolete hard-coded 480×854 capture assertion; it now checks actual requested size and passes. Reward icon overlap was a real game defect and was fixed in runtime. Focused native followups and final APK rebuild cover these local corrections; the expensive whole-run suite is not repeated.

Existing phone/tablet full menu/HUD review, 2,592 pose states, 120 regional boss and 40 miniboss actions are retained by exact unchanged-source/art proof. Fresh changed-screen captures are linked above; pre-gutter real-trace boss captures remain historical, with `boss_hoard_icon_lane` captures superseding their layout. No claimed physical pass is inferred from desktop rendering or export.

## Android and smallest handset retest

**Exact path:** `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-predevice-rc-debug.apk`  
**Filename:** `Lootlings-predevice-rc-debug.apk`  
Version 6 / `0.2.1-predevice-rc`; signed ARM64 debug; 131,817,077 bytes. SHA-256 `15e4c2f7dadf663d51e1cc26c3a9044ca21791163d695bb872daba17be877e9f`. Export, signature, 16-KB alignment, SDK 24/36, offline permission-free package, current imported bow/Relic poses, 329 PCM assets/licenses and exclusion of tests/tools/reference/source/docs are verified. Same existing debug key allows an update over version 5. It is not store/release signed.

Perform this same small test on **S23 Ultra**, then **S24 Ultra**:

1. Copy/install the APK **over the existing app**, without uninstalling. Verify committed gear/currencies survive.
2. Play Act I with Relic Beast and briefly try a bow starter. At merchant/reward screens inspect, drag and cancel once, then select one; check the other offers cannot be acquired, no stray attacks and all text/icons fit. Listen to creature/weapon/boss cues and watch both bow facings, projectiles and boss recovery.
3. After about ten minutes, background/return, Resume, then return to Hideout, close/reopen and verify no lost/duplicate committed reward. Pause → TEST REPORT; report phone model, stutter/heat/readability/audio/touch/lifecycle problems and report values.

The phones were not available. Actual gesture feel/safe-area density, cold startup, speaker fatigue, Android memory/frame pacing/thermals and OS lifecycle remain final gates. A live run lost to process death is an explicit current limitation, not proof a committed save was lost.

## Acceptance questions and multidisciplinary sign-off

Outside testers: **yes, as a debug candidate with these disclosed limits**. Veteran exploitation: tested loops are guarded, but loaded/long-session dominance is not exhausted. Normal-player understanding: clearer choices are demonstrated, fun requires human judgment. Mobile comfort: synthetic/native contracts pass, both physical phones remain pending.

| Discipline | Sign-off | Remaining gate |
|---|---|---|
| DESIGN | ISSUES | Human pacing/fun/replay acceptance. |
| BALANCE | ISSUES | Measured starter policies pass; loaded/varied human strategies remain bounded. |
| ECONOMY | ISSUES | Acquisition/affordability/loops corrected; post-cap usefulness and long-term play unresolved. |
| ROSTER | ISSUES | 82 right / 83 left support-hand/paired combinations and weaponless Moonkip need canonical art. |
| ENEMIES | ISSUES | Mechanics/compatibility checked; species presentation and human encounter feel incomplete. |
| BOSSES | ISSUES | Regional bodies/animations remain reused; nine miniboss bodies reuse Grump Knight. |
| RNG | ISSUES | Measured pity/duplicates/replay pass; exhaustive extreme loaded-build depth not established. |
| UI/UX | ISSUES | Native phone/tablet fixes pass; physical touch/density acceptance pending. |
| NARRATIVE | ISSUES | Copy/canon preserved; distinct regional visual identities remain incomplete. |
| AUDIO | ISSUES | Native signal/routing/license checks pass; eight provisional music tracks and handset listening remain. |
| MOBILE | ISSUES | Verified signed APK ready; S23/S24 physical gates remain. |
| QA | ISSUES | Accepted automated/native checks pass; manual/physical/long-session judgment pending. |
| PRODUCTION | ISSUES | Safe candidate/checkpoints delivered; authored art/music/device gates prevent commercial completion. |

Android target guidance and Godot semantics are linked in BASELINE.md. [Godot Input documentation](https://docs.godotengine.org/en/stable/classes/class_input.html) describes buffered event delivery used by the native fixture; it is not a production input-setting change. The prior [Phase 3 fact checks](../phase3/REPORT.md#fact-checks-and-scope-of-inference) retain engine/RNG/export and primary economy-reference context. Keep/revert judgments here are project-specific inferences from current evidence.
