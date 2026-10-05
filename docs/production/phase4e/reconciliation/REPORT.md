# Phase 4E source-of-truth reconciliation + resumed targeted work

2026-10-05. Documentation-only checkpoint `5928ded` preserves historical records, locks the implemented 7 Lootlings/5 Wanderers/12 weapon families, retains all World Bible regions/IDs, clarifies Moonkip/Glimmerfin/Gloomlet, separates CURRENT/PLANNED/FUTURE NPC status and records the four non-art acceptance gates. PRODUCTION_PHASE4E.md and the exact canonical replacement register remain production authority. Boards remain reference unless explicitly approved/imported.

One authored support-art debt count: **165 actor Ã— weapon Ã— facing cells: 82 right / 83 left**. The current QA report now records this separately from zero unresolved technical support/contact flags; a rig pass cannot close canonical art debt. No extra actor/family or named NPC was inferred from a board.

## Immediate return to FIX work

Implementation `d3a579b`: the Hoard Dragon source is 1372Ã—1146, but the previous renderer forced it into 226Ã—214, adding roughly 13.4% vertical distortion relative to proportional width. Its display now fits the same bounds with the source aspect intact (226Ã—188.77), preserving the bottom baseline, live target facing and existing animation/rig. The same source-aspect safeguard applies to the still-TEMP dragon-based Hollow Crown proxy. Other boss sizing is unchanged. No source pixels, stats, hitboxes, economy, saves or RNG were changed.

**This does NOT repair the malformed Hoard Dragon source tail.** Native before/after crops show that defect openly; the canonical redraw remains in CANONICAL_REPLACEMENTS.md. No procedural replacement was promoted to canon. The approved roster/regions/identities are preserved.

Native before/after: 14 captures each, both real target-facing arrangements, idle/wind-up/attack/actual tail-sweep/hurt/recovery/defeat, forced-facing flag zero. Both contact sheets preserve exact captured pixels without enhancement. Aspect/bounds/grounded-baseline invariants pass, as do current weapon-fit and Phase4E contact/RNG contracts. The initial baseline fixture used the wrong action-field name, generated only two incomplete images and was rejected; corrected captures/logs are the accepted evidence. Its failed run remains locally preserved.

The new QA report contains 864 contract states over all 288 actor/weapon/facing cells and reproduces the 165 authored support-art debt derived from the preserved 1,728-state native matrix. The 576-state focused matrix remains a subset, not a new debt denominator.

No full Phase4E acceptance: art replacements (including source tail), save semantic/cross-store/process-death acceptance, final audio/perceptual mastering, physical S23 performance/lifecycle/input and final visual owner acceptance remain HOLD. No Phase4F.

The prior version15 APK is preserved. Latest version16 / `0.4.7-phase4e-reconciled` APK: `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-reconciled-debug.apk`, 137,126,412 bytes, SHA256 `e1e227af40f24dc1667831fbbc21661a9be140ca511856a34301cb6cbcebfbdc`. Export/signature/16KB alignment/arm64/SDK24–36/offline package checks and ZIP integrity pass. Build receipt is adjacent; device acceptance remains open.
