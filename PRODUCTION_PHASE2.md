# Phase 2 — Act I vertical slice, tranche 1 (2026-10-02)

**Latest state (2026-10-03): tranche 4 player-facing correction pass**, implementation checkpoint `c99704a`. Expanded scenery/safe viewport, canonical Gloomlet export, weighted presentation/HUD/UI/copy/branding corrections, exhaustive 2,592-state native matrix and phone/tablet review. [Current report, evidence, build and remaining art/device gates](docs/production/phase2/correction/REPORT.md). Earlier tranche sections below are historical; their letterboxing, stand-in and UI details are superseded where the correction report says so.

Baseline: `728585c`, following preserved work `69110bd` and audited fixes `4259eb3`. Production work is on `codex/phase2-vertical-slice`; implementation checkpoint: `7346b72`. The audit remains the historical baseline; this document owns subsequent slice progress. This tranche is LIVE, not commercial-release acceptance.

## Selected slice and priority order

Use the existing Act I expedition: Treasure Ruins → Salvage Warrens / Grump Knight → Hoard Depths / Hoard Dragon → physical Hoard Chest → choose one Epic+ reward → equipment decision → results → Hideout. Its combat, merchant stops, run upgrades, equipment and permanent progression already work. The optional Relic Route remains available under its existing unlock.

1. Remove notification occlusion and preserve consecutive reward messages. **Delivered.**
2. Make existing enemy behaviour readable and strengthen visible damage feedback. **Delivered presentation layer.**
3. Improve boss reward decision hierarchy and verify complete flow/persistence. **Delivered.**
4. Author the slice's actually visible default-character weapon poses. **Delivered focused starter-greatsword tranche below; deeper encounter animation/audio remain.**
5. Establish Android deliverable, memory/frame-time targets and S23 Ultra acceptance. **Installable debug build and profiling path delivered below; physical acceptance pending.**

## Delivered

- Trophy/reward notices occupy the quiet 554–644px band at 480×854. HP, XP, enemy names/bars, feet, build ribbon and attack instruction remain clear. Notifications queue, deduplicate and defer during travel, cinematics, Pause and decision panels; deferred reading time is retained. Queue is capped at eight waiting entries.
- Notices and decorative flashes ignore pointer input. Travel still blocks interaction; its veil cannot be cancelled by an older decorative flash tween.
- Quick/heavy/hex/ward/boss windups read the real attack clock and upcoming hexer attack count. A filling ground ring and named cue provide information without colour-only flashing. They introduce no new attack patterns, dodge promise or hidden combat modifier.
- Player/enemy meters retain a brief warm damage trail. Pack members keep independent trails through target switching. Presentation holds at most three enemy records plus the player; no additional textures, timers or spawned VFX nodes.
- Reduced-motion preference also suppresses combat screen shake and notification slide. This does not claim complete motion accessibility.
- Boss choices separate rarity/slot, larger item name and two headline effects into measured icon-safe lanes. Purple/gold rarity accents reinforce the existing tier identity. Existing button text/tooltip semantics and reward/equipment rules remain intact.
- Documentation is excluded from editor import using `docs/.gdignore`, preventing evidence CSVs from producing unintended translation assets. Original audit evidence is preserved.

## Art and pose decisions

The default Relic Beast, Act I enemies, Grump Knight, Hoard Dragon, three regional backgrounds, current equipment/icon art, chest and accepted UI materials are reused. This tranche creates no raster art and does not relabel BETA assets FINAL.

Highest-value authored pose work is the default Relic Beast with its actual starter greatsword: ready, attack/release and recovery in genuinely visible facings, preserving the canonical body, real grip/support anatomy and socket/layering contracts. Assess that combination in native combat before extending it. Existing accepted adult heavy/staff/polearm bodies remain useful alternatives; their completeness does not certify creature anatomy. Ranged/paired creature poses, weaponless baked variants, Gloomlet and wardrobe layers remain documented debt. Do not manufacture all 83 missing combinations for this slice or mirror unsuitable asymmetric bodies.

## Validation and evidence

- Clean Godot 4.7.2 editor import with both user data and editor cache isolated.
- Five final headless fixtures: `vertical_slice_qa`, `smoke_test`, `dungeon_qa`, `vignette_qa`, `save_recovery_qa`; zero unexpected errors. Recovery retains its two intentional corrupt-file diagnostics.
- Three final native fixtures at 480×854: `vertical_slice_qa`, `encounter_qa`, `presentation_qa`; zero errors. Chest presentation also passed in the preceding reward tranche.
- New guarded fixture verifies notification queue/deferral/nonblocking bounds, actual windup identities, independently retained damage trails, merchant purchase, upgrade/equipment decisions, miniboss/boss/chest/reward/results, single payout and saved gear/campaign reload. Its controlled kills validate flow, not difficulty. ConfigFile numeric round-trip comparisons allow floating-point serialization precision; no saved gameplay value was changed to satisfy equality.
- Existing smoke combat still reports **2/5 seeded tapping victories**. No balance, rarity, reward, equipment or economy redesign.
- Native pack stress: 180 rendered frames; average game-step 156µs, worst 373µs on RTX 4080 SUPER. This is CPU game-step time, not GPU time, FPS, Android performance, memory or thermal acceptance.
- Native viewport captures were inspected directly. The computer-use helper did not expose the launched game windows in its desktop inventory, so no manual touch/input playthrough is claimed. Native fixtures exercise the real renderer/audio/UI with disposable saves; human/device acceptance remains pending.
- Restricted-runtime attempts encountered Windows certificate/editor-cache access errors. Desktop runs and the fully isolated editor import passed; those failed attempts are not counted as clean validations.

Portable results and representative native captures: [docs/production/phase2](docs/production/phase2/native-results.json). Reproduce with the bundled Python or installed Python and `tools/run_qa.py --only vertical_slice_qa smoke_test dungeon_qa vignette_qa save_recovery_qa`; use `--native --only vertical_slice_qa encounter_qa presentation_qa` for rendered checks. Always retain the guarded disposable-save boundary.

## Remaining slice gaps

Canonical weapon/pose anatomy for the focused starter combination; authored boss attack/reaction animation and deeper encounter gameplay; final original/licensed audio; final environment/prop acceptance; screen/aspect/safe-area and touch acceptance; actual Android export/device profiling; semantic save/cross-store/process-death hardening and run resumption. The existing complete loop is now clearer, but these gaps prevent a production-complete claim.

## Tranche 2 — focused Relic Beast greatsword / Android test deliverable

Implementation checkpoint: `cc19b29`. Continues the clean tranche 1 branch without restarting the audit. The focused starter-greatsword presentation is now live and natively validated. Physical S23 acceptance remains the immediate next step; this is not commercial-release acceptance.

- Two new real-paw body exports: grounded ready and forward strike/follow-through. Preserve the huge ears, curled tail, cracked relic horns, fang, single original pauldron and left satchel; reuse the accepted existing blade. Canonical base/portraits and adult pose art remain intact. A generated windup that moved asymmetric armour was rejected, not shipped. [Art provenance and exact prompts](docs/production/phase2/RELIC_GREATSWORD_ART.md).
- Ready supplies idle, grounded movement, weight-loaded automatic anticipation, settle, recoil/hurt and reward personality. Release supplies strike, impact and decelerating recovery. A planted-foot pivot and bounded shifts convey weight. Tap hits remain immediate; automatic anticipation reads the existing attack clock. No damage, attack cadence, enemy, loot or economy changes.
- Both closed paws contact opaque handle pixels through the existing two-anchor fit solver; weapon stays behind the real paws. During the contact stroke, only the blade crosses enemy foreground, fixing its disappearance behind large foes. There are no painted substitute hands or new limbs.
- Scope is Relic Beast + greatsword + right-facing Act I combat. Maul/greataxe and left-facing variants retain explicit fallback/debt. This completes one useful combination rather than every missing stance. Manifest remains 246 rows, now 62 authored entries / 22 body textures; measured support-hand debt is 82 right / 83 left combinations.
- Preserve both 1254-square RGBA source exports; runtime imports are 768-square, lossless, no mipmaps: approximately 4.5 MiB total texture pixels before overhead. This is not a total-game memory budget.
- Uniform 480×854 canvas letterboxing replaces expansion that mismatched fixed UI coordinates. Android safe-area layout fits the whole root uniformly; touch targeting uses its inverse transform and rejects outside-frame taps. Explicit touch mouse emulation supports existing buttons. Test report's independent CanvasLayer inherits the safe transform. A 60 FPS cap sets the initial device target.
- Official Godot 4.7.2 arm64 debug APK exports, signs and verifies with a workspace-local official toolchain; SDK24 minimum / SDK36 target, 16KB ZIP alignment, no requested permissions. Build and read-only collection scripts are reproducible. The test-feature-only bounded telemetry reports frame/combat percentiles, loading qualification, render/static counters and lifecycle. [APK identity, phone steps and targets](docs/production/phase2/ANDROID_S23_TEST.md).

### Current validation

- Isolated clean editor import. Preserved adult authored-pose fixture, focused weapon-fit fixture, smoke, full slice/save-recovery regressions pass; recovery retains exactly its two intentional corrupt-file diagnostics. One initial source-size assertion assumed the requested 1280 square; actual generated sources are 1254 square. Corrected source expectation passes; no art was resized to satisfy it.
- Native focused fixture validates nine visible states, opaque anatomy/shaft anchors, 768 runtime textures, exact support alignment, restricted fallbacks, RNG isolation, immediate melee damage and actual game processing through the complete attack sequence. Native blade layering captures inspected. [Contact sheet](docs/production/phase2/relic-greatsword-contact-sheet.png), [results](docs/production/phase2/relic-greatsword-native-results.json).
- Eight native screen/simulated-cutout scenarios validate physical ScreenTouch dispatch, Pause/Resume, group targeting, rapid-tap cooldown, outside-frame rejection, single merchant charge, reward choices, HUD/menu/card bounds and report transform. The gated monitor validates persisted JSON, fixed histograms, bounded contexts and synthetic focus/suspend/return. [Layout/input evidence](docs/production/phase2/mobile-layout-native-results.json).
- Final native encounter, presentation and full Act I flow fixtures pass with zero unexpected errors. [Native result](docs/production/phase2/tranche2-native-results.json), [flow/save/smoke result](docs/production/phase2/tranche2-flow-save-smoke-results.json).
- Earlier 2/5 smoke result was real bot defeats plus an inadequate seed/isolation contract: RNG was seeded after the first foe and prior smoke mutations remained. Corrected fresh-baseline/pre-start seeding repeats byte-for-byte at **3/5**. Thirty diagnostic simulations repeat the same five seeds under three policies: rotating choices 3/5, sustain choices 5/5, sustain + affordable shopping 5/5. The bot cannot judge visual cues; wins are loop coverage, not a population balance target. No difficulty reduction. [Full interpretation](docs/production/phase2/COMBAT_SEED_DIAGNOSTICS.md).

No phone is attached to adb. Actual S23 touch feel, cold launch, GPU rendering, frame pacing, thermals, process memory, edges/text/reward readability and Android lifecycle/save acceptance need the prepared handset test. Native synthetic checks do not certify a physical device. Committed progress survives relaunch; live expeditions still do not resume after process death.

Highest-value next production step: run the prepared S23 test, collect its report/PSS/logs and resolve measured device problems; then finish boss attack/reaction animation and original/licensed audio in this same Act I scene. Wider pose completion, final environments, modular wardrobe, semantic/cross-store save hardening and live-run restoration remain release debt.

## Tranche 3 — first-phone feedback / mobile, sound and copy

The owner reports that the prior APK runs and feels great overall on the S23. Continued the interrupted uncommitted tranche without reset. Implementation checkpoint `91db81d`; [complete report, validation qualifications and exact phone steps](docs/production/phase2/mobileux/REPORT.md).

- Natural card/content and rich-text swipe scrolling, inertia, tap/drag separation and synthetic-mouse guards. HUD/menu touches and swipes cannot become combat taps. Required purchases/rewards/upgrades inspect then confirm; destructive full-stash equip warns explicitly. Existing select-plus-BUY/EQUIP paths stay fast. Back hierarchy, comfortable target heights, simplified hub/loadout and fourteen phone/tablet size/cutout checks.
- Canonical text-free adaptive app icon, monochrome icon, system splash and wordmark boot replace default robot branding. Actual APK resources compared with canonical pixels. No generated final art.
- 174 bounded recorded/designed PCM48 SFX and four original ambience loops, CC0 provenance exported, all twelve real weapon hooks and thirty-family native audio capture verified without clipping. Default QOA import/fallback issue corrected and guarded. Existing music remains provisional.
- 70 revised pooled lines across 21 contexts and focused item/upgrade/help/boss/reward/progression copy; preserve good canon/character reactions, fit longer bubbles, expose revised context lines, remove player-visible pipeline jargon and keep Act I hooks within the established display limit.
- Native weapon matrix reviewed: 144 combinations / 864 facing-phase checks. Preserve authored starter/adult work; 82 right / 83 left anatomical support combinations remain debt, rather than falsely accepting fit math as finished art.
- Updated signed/aligned arm64 debug APK: `builds/android/Lootlings-phase2-mobile-ux-debug.apk`, version code 2, same package/key, all 178 current audio imports verified. [Exact build identity](docs/production/phase2/mobileux/android-build-report.json). Core/flow/economy/save/native presentation checks pass with documented superseded attempts. Combat smoke stays 3/5 without difficulty changes; prior seed diagnosis remains authoritative.

Highest-value next step is physical acceptance of this replacement APK: swipe/action safety, sound quality, launch, sustained pacing/PSS/thermals and Android lifecycle. Then finish canonical fallback support anatomy, authored boss animation and final music. Live expeditions still do not resume after process death. First-APK positive phone feedback does not certify performance or acceptance of this new APK.

## Tranche 4 — player-facing correction / expanded mobile scenery

Implemented directly from owner S23 review, preserving the existing slice/architecture/difficulty and previous checkpoints. Initial interrupted pass had no uncommitted edits. [Correction report](docs/production/phase2/correction/REPORT.md), [voice bible](docs/production/phase2/correction/VOICE_BIBLE.md), [native evidence](docs/production/phase2/correction/evidence/README.md).

- Expand backgrounds/ambience proportionally outside the centered safe combat frame; preserve touch geometry and validate 22 layout/cutout cases. Capture 49 production screens each at 1080×2316 and 1200×1600. Correct startup/hub combat leakage and obsolete visual fixture assumptions.
- Connect canonical Gloomlet, stronger grounded/body motion and melee tip layering. Capture 2,592 native actor/weapon/state/facing samples with settled large enemies; preserve real authored starter paws. 82 right / 83 left support/paired combinations and Moonkip weaponless art remain blocked, not accepted by fit math. Inspected Glimmerfin is already weaponless.
- Compact combat stats with Pause details, predictable text lanes, clear damage loss trail, readable TAP COMBO, two-column trophies, quiet utility/filter hierarchy, comfortable sliders, complete wrapped toasts, deliberate sold slot and actual item/rarity result icons.
- Deeper resident/campaign voice and caption reading time; consistent boot/title tagline; enlarged canonical adaptive mascot and verified navy Android system theme. Preserve licensed audio/buses; native peak −0.80 dBFS, subjective device listening still pending.
- Signed/aligned replacement `builds/android/Lootlings-phase2-presentation-debug.apk`, version 3, same package/key, fresh assets/source exclusions. Physical S23 pacing/memory/thermal/input/lifecycle acceptance and process-death run restoration remain explicit. Correct seeded smoke still 3/5, with sustain policies 5/5; no balance change.
