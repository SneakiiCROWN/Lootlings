# Established-canon reuse checkpoint — 2026-10-06

Recovered clean `codex/phase4e-gamefeel` at `a33a6fc`. No interrupted edits existed. Preserved all previous canonical extraction, heavy/ranged poses, combat staging, target-facing, mobile gestures, reward/save protections and earned-spin behavior.

Implementation: `1c86aec`. This is a targeted reuse checkpoint, not completion of the requested game-wide integration. Owner source-correction steering was resolved by the authoritative `art/reference` clarification; source-sync work continues using the established hierarchy. See [source-correction report](../source-correction/REPORT.md).

## Actual changes

- Directly reused five existing transparent, weaponless Wanderer idle bodies: Vault Runner, Ruin Warden, Nightstage Drifter, Velvet Astrologer, Ashtrail Hunter. Each now replaces TEMP in right-facing stationary wand/orb/dagger/claw/sling neutral states: 25 cells. Source proportions, colours, outfit, face and anatomy remain unchanged. Existing source palm contracts drive the modular weapons; secondary palms were checked against the original visible hands.
- Added seven compatible neutral sling assemblies on original body exports: Relic Beast, Emberhorn, Pebblewyrm, Glimmerfin and Gloomlet right; Emberhorn and Mosskin actual left. Mosskin's shield-bearing right source and Moonkip's baked-dagger source remain excluded.
- Zero images generated, repainted, cropped or newly extracted in this checkpoint. Five direct body assets reused plus seven existing extracted body views; 32 TEMP cells replaced. Prior 78 extraction outputs remain unchanged.
- Exact cached source routing is stationary/neutral only. Missing movement, attacks, hurt and opposite views still use explicitly TEMP rig presentation. No idle-as-attack or asymmetric mirroring. Good existing authored heavy/ranged state pairs keep priority.
- Master manifests now include reuse source contracts, fresh source hashes, revised per-cell debt and candidate/reason evidence for every surviving exact missing cell. Android verification byte-checks the five reused imported bodies and new manifest.

## Counts and remaining delivery

Missing exact state/view/family cells: **3,097 → 3,065** (2,327 playable; 738 other). Whole body/view bundles: **106 → 106**. Complete support packages: **165 → 165**, 82 right / 83 left. Partial neutral coverage does not close a full action/view/support package.

The [exact remaining delivery file](../../NEEDS_NEW_CANON_EXPORT.json) contains every state/facing/family, dimensions, transparency, baseline/anchor, real rig targets, required socket layers and source search/reason. Missing source-pixel anatomy remains OPEN. Moonkip weaponless original anatomy, Dragon actual repaired continuous tail, missing actions/opposite views and distinct regional/NPC body states remain unresolved. The intended newer handoff must be located before this queue is considered exhaustive against that package.

Home, NPC routes, environments, Forge/Archive/Contracts, HUD, merchant, chest/spinner and audio were preserved in this batch; no invented improvements are claimed for them. Native Home/Gear/merchant/reward coverage was refreshed using the unchanged master fixture.

## Validation

Six isolated fixtures pass: extracted-art (35 exact canonical cells), reuse-canon (25 direct neutral cells), master icon mapping, 144-family weapon matrix/864 samples, mobile gestures and visible navigation/purchase safeguards. Eight canon guard tests pass; original 246 authored pose records and frozen sources retained.

Native phone 1080×2340 and tablet 1200×1920: [86 before/after images](GALLERY.md), actual target-facing canonical neutral weapons and authored left sling views; plus 20 preserved Home/Gear/merchant/reward captures from the current master native fixture. Representative full-size frames were visually inspected for silhouette, palm/weapon contact, scale and separation.

An initial fixture used an incorrect aggregate count while the routing was under development; it was interrupted and corrected to 35. All final fixtures pass; failed/interrupted evidence is retained. No gameplay contract was changed to satisfy the test.

APK v27 / `0.4.18-phase4e-reuse-canon`: `builds/android/Lootlings-phase4e-reuse-canon-debug.apk`, 139,821,358 bytes, SHA256 `497020700bbd1f16794b7b15041f83b24fe444e35d34474457a82e8e8ae7770f`. Signed arm64, target36/min24, 16 KB alignment, branded splash, 78 extracted assets and five unchanged reused bodies verified against local imports. Physical device acceptance remains false.

GO for scoped S23 regression test of this preserved build; HOLD for final Phase4E, intended-handoff source acceptance and production. Minimal retest: inspect one Wanderer with wand/paired weapons and Relic Beast sling; turn/cross target sides and attack; verify UI taps/swipes do not attack; background/resume and reopen the save. Report visual transitions and device FPS/audio feel. Do not treat remaining TEMP action frames as final canonical art.

## Multidisciplinary sign-off

DESIGN / BALANCE / ECONOMY / RNG: existing contracts preserved; this art-only batch does not re-accept the entire game. ROSTER / ENEMIES / BOSSES / PRODUCTION: issues — missing canonical states and intended source-package location. UI/UX: scoped regressions pass, final owner acceptance open. NARRATIVE: unchanged, no new acceptance. AUDIO: issues — perceptual/mastering acceptance open. MOBILE / QA: scoped native and automatic checks pass; physical S23, lifecycle/save acceptance and final owner visual approval remain issues. Phase4E remains HOLD.
