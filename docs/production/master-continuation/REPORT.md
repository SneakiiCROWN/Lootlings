# Phase4E permanent master production index and continuation — 2026-10-06

Continue clean/pushed v25 `11cd6c4`; no reset, re-extraction, Phase4F or identity redesign. Main implementation `18f462d9aa1efa3a73f9f94eeb26febc1560839c`; additional production tooling checkpoints `4b839e8` and subsequent portable handoff/path corrections are preserved. Latest implementation/tooling checkpoint: 4fab67b961420152210931f1205adb539e2db398. Separate final QA/status SHA is reported after commit.

## Permanent inventory

[Master JSON](../MASTER_INTEGRATION_MANIFEST.json), [CSV](../MASTER_INTEGRATION_MANIFEST.csv), [summary/status counts](../MASTER_INTEGRATION_SUMMARY.md), [story](../STORY_CONTENT_MAP.md), [UI screens](../UI_SCREEN_MAP.md), [world/regions](../WORLD_REGION_MAP.md), [character](../CHARACTER_POSE_MATRIX.csv), [boss](../BOSS_ASSET_MATRIX.csv), [enemy](../ENEMY_ASSET_MATRIX.csv) matrices and [one consolidated missing-art contract](../NEEDS_NEW_CANON_EXPORT.json).

**6,788 records; 6,058 current launch/runtime slots.** The remainder preserves historical/reference/planned scope. This is an inventory of distinct runtime/content/delivery/evidence slots, not 6,788 unique images. Counts are intentionally conservative: no technical or provenance test grants LIVE_FINAL visual acceptance.

| Status | All records | Current launch/runtime slots |
|---|---:|---:|
| LIVE_FINAL | 0 | 0 |
| LIVE_BETA | 2,961 | 2,961 |
| EXTRACTABLE_NOW | 0 | 0 |
| NEEDS_CROP_OR_MASK | 0 | 0 |
| NEEDS_RUNTIME_ASSEMBLY | 0 | 0 |
| NEEDS_NEW_CANON_EXPORT | 3,097 | 3,097 |
| REFERENCE_ONLY | 502 | 0 |
| REJECTED_IDENTITY_DRIFT | 6 | 0 |
| PLANNED_NOT_IMPLEMENTED | 11 | 0 |
| NOT_REQUIRED_FOR_CURRENT_LAUNCH | 211 | 0 |

The five compatible crop/mask candidates and shared inline/item runtime-assembly opportunities were implemented before the final index, so these queues are zero for **currently identified approved opportunities**, not proof that all reference artwork is production-ready. Reference-only records require semantic/identity/occlusion approval; they are not automatically extraction work. Five rejected handoff boards plus the old goblin Patch proposal are explicitly rejected. Current adult Patch/Ilex/Sera, canonical Lootlings, campaign order and twelve families remain authoritative; Edda and historical board names do not become live NPCs.

The index cross-references current catalogs and 118 source inputs, including all requested top-level bibles/status documents, reference docs, pose/export manifests, current scripts and audio provenance. The checked-in source-hashed runtime snapshot reflects 87 current implementation scripts via the official [Godot Script constant/method API](https://docs.godotengine.org/en/stable/classes/class_script.html), without instantiating game/save objects. Builder refuses stale reflected definitions; validator checks source hashes, ID uniqueness, status partition, CSV parity, current paths and exact grouped request coverage. Android builds now run both canon and master-index preflights. Future changes require refreshing this index from actual underlying contracts rather than another discovery pass.

## Actual visible integration

Five additional original rune glyph exports: Fire, Frost, Poison, Lightning and generic Arcane. Original source RGB and dimensions preserved; alpha-only separation; no new spell effects, mechanics or identities. Ten elemental item IDs route to the appropriate glyph; existing bespoke jewellery, earth/physical item art, body poses and held weapons remain unchanged. Generic Rune thumbnails for Echo Invoice/Fault Script use the arcane glyph. Inline HUD markup now calls the same cached icon resolver as ordinary drawn icons, fixing stale paths for the v25 Fire/Lightning source assets.

**5 new assets integrated; 78 total extraction-manifest exports. TEMP body assets removed this pass: 0.** Twenty-eight v25 body/state cells remain preserved. No fake states or unsupported support-hand packages were claimed. Exact missing-art count remains **3,097 = 2,359 playable + 738 regional/boss/current resident/merchant**. The fresh 144-combination/864-facing-phase fit run recalculates **165 whole support packages = 82 right + 83 left**, zero unresolved mechanical contacts. Existing shared heavy modules and partial source-backed idles are already credited; missing authored paired/action hands remain real art debt.

## One portable art production package

`C:\Users\Snkii\Documents\lootlings\builds\art\Lootlings_NEEDS_NEW_CANON_EXPORT.zip` contains the contract JSON, 21 unchanged locked source images, seven clearly TEMP attack evidence images, export contract, actual existing source socket manifest, source hashes and instructions. ZIP integrity verified. [Receipt](art-package.json) records the exact bytes/hash.

The 3,097 fine delivery cells collapse into **106 shared body/view bundles**, each listing reusable states/families, exact canonical identity, delivery canvas/transparency, baseline/pivot/rig socket targets, support/layering and scale rules. This is not an instruction to manufacture thousands of duplicated bodies. Source image paths/hashes are included; actual missing source-pixel palms are explicitly OPEN until an authored frame exists. Bundles without an approved canonical visual are marked **OPEN visual-source approval gate** and carry written identity only. ChatGPT must not guess a final design from a proxy. This remains a real prerequisite, rather than a falsely complete “no guessing” art prompt.

Moonkip weaponless original hooded anatomy, actual missing action/views, paired/support packages, wingless/coiled Hoard Dragon continuous source tail and NPC work/seated/activity remain art blockers. Existing Dragon source is included strictly as identity and defective-tail evidence, not repaired art. Rejected boards are absent from the portable package. No new artwork was generated.

## Validation

[20 new native full-size phone/tablet captures](GALLERY.md), 1080×2340 and 1200×1920: all five glyphs, twelve Rune inventory entries, scroll positions, merchant/Home return and actual Fire/Frost/Arcane item reward cards. Final native run `phase4e-master-native-final-956116e090`: exit0, zero errors,15.57s. Reviewed Gear/icon colour/silhouette/text clarity and reward-card fit; no newly introduced overflow noticed. This is desktop native rendering, not physical S23 performance acceptance.

Final item/icon run `phase4e-master-item-accepted-784e517672`: item art and semantic mapping both pass. Broader `phase4e-master-continuation-ac03a68e8c`: extracted body routing, mobile gesture, visible reward/navigation protection and weapon-fit matrix pass. Its initial item-art fixture failure is preserved in evidence: old source paths and a formerly clickable equipped-slot assumption were stale after v25/current UI changes. Fixture now validates current explicit filter/list flow and display-only equipped slots; final replacement passes. No shipping interaction was weakened to make the fixture pass. Eight canonical guards pass; eleven frozen sources, five rejected-board statuses and 246 original pose rows preserved.

No balance, damage, RNG, save schema, economy or timing changes. Audio/license and established mobile safeguards preserved. Existing v25 168-body/layout gallery remains intact; no duplicate body extraction/review is claimed.

## Android and owner retest

**v26 / `0.4.17-phase4e-master-integration`**:
`C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-master-integration-debug.apk`

139,817,167 bytes; SHA256 `bbae8f9edf045cfec84e9e911a4af3e633c65263a0b0fd537eee5b680f99a1a0`. [Build receipt](android-build.json): signed arm64/no requested permissions, branded splash, 16KiB alignment, audio/source licenses retained, all78 extracted imported assets byte-match current imports. Production docs/reference sources excluded from APK. Physical-device validation remains false.

Install over the existing debug app without clearing data. Open Gear with any owned Rune: inspect icon/label, scroll, open/close its comparison, return Hideout. Check one Rune reward if encountered, then background/resume and confirm equipment persists. No artificial reward or paid purchase is needed for testing. Prior v25 character/weapon checks remain relevant.

**GO for scoped S23 owner review; full Phase4E HOLD.** Separate semantic/cross-store/process-death saves, final perceptual audio/mastering, physical S23 performance/lifecycle/input and owner visual acceptance remain open. No Phase4F.

## Multidisciplinary sign-off

| Discipline | Status | Scope / open gate |
|---|---|---|
| DESIGN | issues | Full presentation still depends on canonical action art |
| BALANCE | pass within change scope | No tuning; prior measurements retained |
| ECONOMY | pass within change scope | No sources/sinks/odds/purchases changed |
| ROSTER | issues | Existing identities preserved; missing action/weaponless art |
| ENEMIES | issues | Regional canonical visuals/states remain open |
| BOSSES | issues | Actual Dragon tail and unique missing boss state packages |
| RNG | pass within change scope | Presentation-only routes; no RNG changes |
| UI/UX | issues | Native Gear/rewards reviewed; final owner/device acceptance |
| NARRATIVE | pass within change scope | Canon preserved; historical labels not promoted |
| AUDIO | issues | Existing implementation retained; perceptual/mastering gate |
| MOBILE | issues | Native layouts/APK pass; physical S23 gate |
| QA | issues | Focused checks pass; full device/owner acceptance remains |
| PRODUCTION | issues | Permanent index and safe checkpoints; external source gates remain |
