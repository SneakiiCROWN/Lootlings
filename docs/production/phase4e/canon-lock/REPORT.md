# Phase4E canon lock, housekeeping and safe continuation

2026-10-06. Preserved the clean v29 checkpoint and all working combat, touch, save and reward systems. No Phase4F, redesign, source-art regeneration or deletion.

Housekeeping implementation: `d523bbe5442b4651b288ff02bc040fe4b06aea23`. Runtime/guard implementation: `18738f2d909a8874371758f6e13200b276b2831e`. QA/evidence is checkpointed separately; the current starting point pins its verified commit after delivery.

## Authority and canon

Created [START_HERE_CURRENT](../../START_HERE_CURRENT.md), [CANON_REGISTRY](../../CANON_REGISTRY.json), [CODEX_HANDOFF](../../CODEX_HANDOFF.md), and [reference-root guidance](../../../../art/reference/README.md). Both top-level status documents have exactly one CURRENT block and an explicit historical boundary; old Current headings are labelled historical records. History remains intact.

Registry: **834 identity/option/system records; 814 current catalog/screen routes**, all exact pose IDs covered. Seven Lootlings, five accepted Wanderers, twelve families, current residents/merchant, enemies, elites, boss identities/profiles, regions, currencies, rewards, equipment, dialogue, audio hooks and UI entry points retain stable namespaces. An option/profile is not another character. Missing states point to the exact existing matrix; accepted idle, expression or inventory art never implies an action export. Registry generation grants no new approval.

The five handoff boards remain blocked from direct runtime body use. Moonkip's changed body, mushroom Gloomlet and winged Dragon are rejected; compatible previously accepted icon extracts remain valid under their restricted contracts. Gloomlet remains the violet furry Assassin; Moonkip stays the hooded rogue; Dragon remains wingless/coiled violet-obsidian-gold. No new handoff guidance or artwork was imported.

## Targeted runtime comparison and actual correction

Used the existing 51-source SHA inventory, 85 export-route mapping, generated runtime catalog and exact pose matrix. Did not rediscover/open every binary.

| Current usage | Correct authority/source | Result |
|---|---|---|
| Home and character Memory: seven neutral body exports | Frozen sheets and accepted original extraction manifest | Preserved; not substituted into missing combat actions |
| Archive: five small full-body Wanderer thumbnails | Same five accepted sprites and the existing Avatar HUD portrait regions | **Corrected five runtime assemblies**; larger readable faces, exact identity and source pixels retained |
| Character expressions, gear/HUD/rune glyphs | Existing approved restricted extraction contracts | Preserved; no icon becomes a held weapon/body |
| Patch/Ilex/Sera Home and dialogue | Existing accepted idle/portrait exports and written voices | Preserved; authored activity layers remain missing |
| Pack Peddler/Merrow | Existing World Bible merchant role and composition | No invented body/NPC; fuller portrait/activity art remains open |
| Regional enemy/proxy and deficient player action bodies | Written identity, frozen sheets, exact authored pose contracts | Remain explicitly TEMP where the exact source state is absent; zero false art closures |
| Regional boss proxies and Dragon source tail | Existing written/accepted intro identities; exact replacement register | Still blocked; no winged redesign or hidden tail defect |
| Boss memories and region paintings | Existing encounter-specific paintings and regional maps | Preserved; closer code inspection confirmed Act I boss backdrops were already correct |
| Spinner/rewards, HUD, title/app, Home/world | Existing accepted assets and current implementation | Preserved; no conflicting board import or value/odds change |

This is a presentation correction, not a changed canonical identity. No balance, RNG, timing, price, save schema, grants or combat/socket code changed. **Zero TEMP combat cells removed; zero new art files.**

## Housekeeping

[Targeted candidate classification](../../HOUSEKEEPING_REVIEW.md): **zero deletions**, zero tree moves. Identical named sources retain their authority/provenance roles. The two ignored handoff archives are review-only candidates because deletion provenance/Git recovery requirements are unproven. Canonical sources, unique raw art, licenses, matrices, tests, historical records and current evidence are preserved.

## Validation and build

- Native Godot phone **1080×2340** and tablet **1200×1920**, all five Wanderers before/after: **20 full-resolution captures**, directly inspected for faces, identity and title fit. [Gallery](GALLERY.md), [source/image hashes](native_manifest.json).
- Fresh isolated `field_notes_qa`, `mobile_gesture_qa`, `relic_spinner_qa`: all pass, no script errors. Native baseline and after fixtures also pass. Read-only Archive data, touch ownership and repeat-spin protections preserved.
- Existing canonical guard: **11 frozen source hashes**, five rejected boards, 246 authored pose rows, eight mutation tests pass. New cheap registry guard: source freshness, unique stable identity, exact pose/catalog/screen coverage, no rejected board preload/canonical source, authority boundaries; **seven in-memory mutation tests pass** (including rejected identity authority); frozen actor-source routes and all twelve family IDs are also locked. Android preflight now runs the registry guard alongside existing canonical/master checks.
- Master regenerated from isolated reflection of **88 scripts**, validated against **121 source inputs**. Counts unchanged: **6,805 records / 6,075 launch slots / 3,010 LIVE_BETA / 3,065 missing cells / 106 bundles / 165 support packages**. No generated rows hand edited.
- Android **v30 / 0.4.21-phase4e-canon-lock**, signed debug arm64, min24/target36, 16KiB aligned. Reference/source/test art excluded; licensed audio and accepted imports preserved. Actual compiled APK code verifies five Wanderer portrait atlases, eleven boss accounts, three bounded Engine captions and five Notes categories. [Build receipt](android-build.json), [compiled proof](qa/apk-compiled-code.json).

APK: `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-canon-lock-debug.apk`

140,301,297 bytes; SHA256 `07a5635676a477e7b1482caefb3ba9a58200641702dfd791296b99e0b9a38272`.

## Acceptance and next work

**GO for scoped S23 owner review; HOLD for full Phase4E/release.** Art debt remains 3,065 exact cells (2,327 playable), 106 body/view bundles and 165 complete support packages. Missing Moonkip weaponless paws, original Dragon repaired tail, deficient actions/facings and regional/NPC exports remain real art gates. No ambiguity permits a replacement identity. Save semantic/cross-store/process-death, perceptual audio/mastering, physical S23 performance/lifecycle/input and final player-facing owner acceptance remain separate gates.

S23 minimum: install v30 over the existing debug app; open Archive → Field Notes → CAST, cycle through the five Wanderers; confirm readable faces/names and scroll/Back; background/resume once and check the existing save. Native desktop captures cannot establish physical-device acceptance.

Continue exact approved-source integration from the registry/replacement queue, preserving the remaining explicit art slots. Do not treat HOLD as a development stop or begin Phase4F.

## Multidisciplinary sign-off

| Discipline | Status |
|---|---|
| DESIGN | PASS for this read-only portrait reuse; no system redesign |
| BALANCE | ISSUES: broader acceptance limits unchanged; no balance changes or new tuning claims |
| ECONOMY | PASS for unchanged values/grants and tested repeat-spin/read-only flows |
| ROSTER | ISSUES: missing canonical combat/action/support exports |
| ENEMIES | ISSUES: regional TEMP/proxy bodies remain |
| BOSSES | ISSUES: original Dragon tail and missing canonical states/bodies |
| RNG | PASS for unchanged RNG/odds and repeated-spinner regression |
| UI/UX | ISSUES: scoped native Archive improvement passes; final owner/device acceptance open |
| NARRATIVE | ISSUES: identity/voices preserved; full final owner acceptance open |
| AUDIO | ISSUES: final perceptual/mastering acceptance open |
| MOBILE | ISSUES: native phone/tablet pass; physical S23 gates open |
| QA | ISSUES: scoped tests/guards/build pass; save/device acceptance gates remain |
| PRODUCTION | ISSUES: clean authority/checkpoints achieved; full Phase4E HOLD |
