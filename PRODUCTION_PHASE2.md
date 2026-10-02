# Phase 2 — Act I vertical slice, tranche 1 (2026-10-02)

Baseline: `728585c`, following preserved work `69110bd` and audited fixes `4259eb3`. Production work is on `codex/phase2-vertical-slice`; implementation checkpoint: `7346b72`. The audit remains the historical baseline; this document owns subsequent slice progress. This tranche is LIVE, not commercial-release acceptance.

## Selected slice and priority order

Use the existing Act I expedition: Treasure Ruins → Salvage Warrens / Grump Knight → Hoard Depths / Hoard Dragon → physical Hoard Chest → choose one Epic+ reward → equipment decision → results → Hideout. Its combat, merchant stops, run upgrades, equipment and permanent progression already work. The optional Relic Route remains available under its existing unlock.

1. Remove notification occlusion and preserve consecutive reward messages. **Delivered.**
2. Make existing enemy behaviour readable and strengthen visible damage feedback. **Delivered presentation layer.**
3. Improve boss reward decision hierarchy and verify complete flow/persistence. **Delivered.**
4. Author the slice's actually visible default-character weapon poses and finish encounter presentation/audio. **Next production tranche.**
5. Establish Android deliverable, memory/frame-time targets and S23 Ultra acceptance. **Required before calling the slice commercially presentable.**

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

Highest-value next production step: finish and accept the Relic Beast/starter-greatsword animation/contact set in this exact Act I scene, while establishing an installable Android test build and a repeatable S23 Ultra profiling path.
