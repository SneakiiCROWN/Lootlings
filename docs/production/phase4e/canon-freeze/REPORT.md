# Phase 4E hard canon freeze and integration continuation

2026-10-06. Reference/status checkpoint `6dc8f82`; implementation `f365459`. Earlier clean remote `33e394e` and all prior checkpoints preserved. No reset, redesign, Phase4F, balance/timing/economy/save change or new generated body art.

## Implemented

The handoff originals are preserved and marked `REFERENCE_REJECTED_IDENTITY_DRIFT` in their status register and companion document. Gloomlet's mushroom interpretation and Moonkip's changed anatomy are explicitly owner-rejected. Their established canonical sheets/idle remain authoritative. Under the same no-redesign rule, the Dragon boards' winged quadruped body is excluded: the current canonical creature is wingless/coiled. Compatible continuous-tail anatomy, state-layout and VFX guidance remains usable. Overview board labels/designs establish no new IDs, regions, cast or weapons.

The interrupted 224×175 Dragon cutout is preserved in `art/reference/phase4e_handoff/experiments`, outside runtime/export. It was never integrated. Its alpha trace was incomplete and its body changed identity; it cannot serve as final/BETA production replacement art. The existing Dragon texture is unchanged; its tail remains malformed/ambiguous. No crop, squash or VFX is claimed as a repair.

Build/import guards now protect 11 frozen canonical source files and the existing authored pose asset hashes/paths. New or changed pose rows require established source provenance and explicit approval. Reference boards cannot be runtime bodies via a manifest edit or be silently renamed into approved frames. The Android build executes this preflight; runtime playable-manifest resolution also rejects reference paths.

Approved boss state/frame routing was implemented on existing clocks, with explicit left/right views, proportional fit and existing baseline/bounds. State priority is defeat, hurt, recovery, active named attack, current telegraph, idle. Full approved frames omit old procedural body attachments. Missing frames retain the current source; the production boss manifest is empty. No frame or art queue entry is accepted by this adapter. Actual delivered-frame integration/visual acceptance still requires proper assets.

## Validation and evidence

- Six Python rejection checks pass: current sources, frozen-source mutation, board-as-pose, unapproved new pose, silent existing-pose body substitution, and falsely approved board-as-boss. Mutation tests operate on in-memory manifest copies; source files/player saves are untouched.
- Final Godot isolated fixtures pass: `authored_pose_qa` (246 unique keys; 100 actual two-facing authored ready/release states), `boss_art_manifest_qa` (six states × two real target facings, unchanged fallback/RNG), `phase4e_polish_qa` (1,152 contact/facing/state samples, 948 prototype-rig samples). Earlier new-fixture windup assertion came from un-cleared QA entry animation; fixture corrected and final rerun passed. It was not fixed by changing gameplay telegraphs.
- Native 1080×2340 Dragon captures: 14 samples covering both normal target facings × idle, windup, actual attack, tail sweep, hurt, recovery and defeat. Tail defect remains visible.
- Native 1080×2340 phone and 1200×1920 tablet captures: 60 samples each across greatsword, bow, twin daggers, claws, staff and orb; left/right positions, both actors crossing, windup, attack, hit and recovery. No forced-facing overrides. Crossings are staged because free lateral movement is not exposed; the fixture's enemy name/archetype is staged for facing and does not prove regional identity. Close overlap during crossings is not art acceptance.
- Native selected full captures and detail sheets were visually inspected. Readable HUD and mechanical target-facing are retained. Flat prototype bodies visibly fail the quality target; these captures do not turn them into accepted art. Twelve labelled detail sheets and selected full captures are attached here; all 134 full PNG captures remain locally available in `.godot_test_data/phase4e` and are indexed by hashes. This is scoped regression evidence, not an exhaustive aesthetic review of every asset.
- Android v19 `0.4.10-phase4e-canon-freeze`: signed arm64, 16KB alignment, SDK24–36, offline/no permissions; both manifests included, no handoff/reference art packaged, current imported bow/greatsword assets and 456 source-documented PCM assets verified. Physical device not tested.

APK: `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-canon-freeze-debug.apk` — 137,130,747 bytes. SHA256 `fb170b15d077563b27694b953c91d6be616a7707f0622d0d869204edcf5b69e3`.

## Active external deliveries and non-art gates

The canonical register and its exact 52-row delivery requests remain the queue; 165 support-art cells remain open. First deliveries: established wingless/coiled Hoard Dragon with one anatomically continuous tail and its actual named states/views; weaponless hooded-rogue Moonkip; violet furry Assassin Gloomlet. Canvas/transparency, exact states, sockets and reusable rigs are specified in `ART_EXPORT_CONTRACT.md` / `replacement-export-requests.json`. Other regional/boss/resident entries require their established designs and exact production exports, not generated board bodies. No stale reference can bypass that gate.

Separate acceptance gates remain: semantic/cross-store/process-death save acceptance, final audio/mastering/perceptual acceptance, physical S23 FPS/frame pacing/memory/input/lifecycle, final player-facing visual owner acceptance. The defined desktop reward restart evidence from the previous checkpoint is preserved; this pass does not claim Android lifecycle acceptance.

Smallest optional S23 regression: install this APK over the existing app without uninstalling; verify the save opens; run one melee and one bow/staff encounter with targets on both sides; background/resume once and reopen the saved run. Record any facing, input or persistence regression. This build offers import safety/state routing, not repaired Dragon/Moonkip/Gloomlet artwork.

## Multidisciplinary sign-off

| Discipline | Status and scope |
|---|---|
| DESIGN | ISSUES: canonical combat readability/presentation still needs delivered art; no mechanic redesign |
| BALANCE | PASS, unchanged scope: prior measured balance retained; no difficulty tuning for test outcomes |
| ECONOMY | PASS, unchanged scope: prior protections retained; no pricing/reward/odds changes |
| ROSTER | ISSUES: rejected prototype bodies and missing authored states remain |
| ENEMIES | ISSUES: distinct canonical regional production exports remain |
| BOSSES | ISSUES: Dragon source tail and missing distinct authored states remain |
| RNG | PASS, scoped: state/art resolution leaves combat/loot RNG unchanged |
| UI/UX | ISSUES: native HUD regression retained; overall visual owner acceptance and physical touch gates open |
| NARRATIVE | PASS, scoped: established IDs/identity/lore frozen; conflicting board labels rejected; authored dialogue retained |
| AUDIO | ISSUES: prior licensed work retained; final mastering/perceptual approval open |
| MOBILE | ISSUES: signed/exported candidate and native layouts validated; physical S23 performance/lifecycle/input open |
| QA | ISSUES: scoped automated/native checks pass; actual new production frames, cross-store/save semantics and physical acceptance outstanding |
| PRODUCTION | ISSUES: safe checkpoints and continued integration support; full Phase4E remains HOLD, no Phase4F |

HOLD is an acceptance status, not cancellation of the active queue. This checkpoint completes the canon correction and available state/import engineering; it does not claim full Phase4E or art completion.
