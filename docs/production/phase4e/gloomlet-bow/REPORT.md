# Gloomlet Bow handoff validation — APK HOLD

Implementation checkpoint3150ea5.

2026-10-08. Preserved v41 and the interrupted pack HUD/ATTACK work. No balance, economy, save schema, encounter timing or touch ownership changes.

## Source and candidate decisions

The supplied canonical_reference PNG and the existing dedicated Gloomlet sheet decode to identical RGBA pixels. All eight listed candidate hashes match CANDIDATE_MANIFEST. The ninth candidate-folder file is a contact sheet, not another state. Black-purple fur, magenta ears, violet eyes/Core, partial armour and Assassin identity are retained. No identity board is reapproved.

| Candidate | Decision | Reason |
| --- | --- | --- |
| R03 | ACCEPT windup/right only | Complete independent silhouette, visible forward closed grip and drawing fist near cheek; native actual module/string contact passes. |
| L02 | ACCEPT windup/left only | Independently delivered left pose, measured forward grip/drawing fist; no body mirror. Native contact passes. |
| R01 | Not installed | Another draw-like candidate; does not add a distinct missing state over accepted R03. Not an idle/release substitute. |
| R04 | Not installed | Alternate draw-like candidate; no distinct delivery cell beyond R03. |
| R02 | Runtime idle not accepted | Lowered separated palms do not supply the required two-palm bow-ready/string contact as delivered; no anatomy repositioning permitted. |
| L01 | Runtime idle not accepted | Raised drawing fist/extended grip is draw-like, not a distinct neutral/movement state. |
| L03 | REJECT as release/follow-through | Drawing fist remains closed near cheek, bow arm still extended; supplied pixels do not establish an actual release/follow-through. Identity is not rejected. |
| R05 | REJECT as release/follow-through | Same closed-fist draw posture limitation; not relabelled to close strike/recovery. Identity is not rejected. |

Source alpha-boundary pixels are alpha1 background speckle, not clipped anatomy: real silhouettes fit inside the source. Only alpha<=8 background speckle is removed. Actual silhouette bounds are uniformly fitted with a single affine scale inside the512px canvas/inset16, with the lowest real paw at ground496. No stretching, mirroring, recolouring or invented anatomy. Grip and drawing-paw foregrounds are masks of delivered pixels only.

## Exact state acceptance

Closed: **windup/right and windup/left**. Installed two body PNGs, two grip PNGs and two measured-palm socket sidecars under `art/production/phase4e/lootlings/gloomlet/bow/`. `bow_slice_manifest.json` is an exact ANTICIPATE/bow-only mapping, never a ready/release fallback pack.

Still OPEN in BOTH facings: **idle, movement, strike_or_cast, follow_through, recovery, hurt, defeat, victory_return** — 16 cells. The consolidated GLOOMLET_BOW_RUNTIME_QUEUE.json copies their exact existing runtime requests, filenames, destinations, canvas/pivot/baseline, anatomy and separate-layer requirements. No other family is closed by these candidates. Full-family support packages remain 165.

Source palm measurements: R03 grip(1182,691), draw(630,620); L02 grip(96,655), draw(673,627), on1254px source. Canvas coordinates use the recorded source crop, uniform scale and crop_canvas_offset in each sidecar; pivot(256,341.3333333333333), ground496. Body display192px, shared arena ground unchanged.

## Bow/socket/native findings

Moonbranch and Gilded Shortbow both pass native draw/windup contact in right and left facings at phone1080x2340 and tablet1200x1920. Both items currently use the same accepted bow-family held module; this pass does not invent different item artwork. The module stays separate, grip pixels cover its handle, the string nock meets the drawing palm, and the arrow points toward the active target and spans the real palm-to-bow distance. Bow draw uses string contact rather than incorrectly rotating a rigid secondary handle to match the rear palm. No baked bow/body mirroring. Drawing-palm contact error <0.001 design pixels in the scoped native fixture.

Native review caught and corrected the first adapter's reversed arrow and too-short nocked shaft. Final evidence replaces those drafts; original head/feather size is retained while shaft length changes. Existing flying projectile presentation uses the unchanged default length. No attack clock, damage or projectile mechanics changes.

**Treasure Ruins → Warrens → Grump Knight → Hoard Depths does NOT have zero fallback cards.** Neutral, movement, attack/recovery and hurt samples still block; missing defeat/victory are explicit. Staged boss labels are not claimed to be a completed route. ART_GATE.json remains false. No owner-facing APK exported; v41 is preserved unchanged.

## HUD/control result and QA

Two/three enemy cards now preserve full names in bounded wrapping, with separate HP/status rows and cached canonical navy/gold backing. No name truncation. Longest current variants tested at readable12–13 design-pixel font; native phone/tablet screenshots inspected. The ATTACK control uses the existing canonical primary-button material, weapon icon and restrained ready/recharging/press feedback; input callback, cooldown and protected touch owner remain unchanged.

Passed: final native scoped bow/HUD capture; actual Window mobile gesture/tap/drag, HUD isolation, deliberate attacks, confirmation debounce, Back/full-stash protections; weapon-fit and staging regressions; canonical-art provenance guard and eleven rejection tests. Fresh isolated saves only. GALLERY.md includes both layouts and before/current HUD/control captures. Partial state coverage is not full slice acceptance, and desktop layout QA is not S23 physical-device acceptance.

Design/balance/economy: unchanged. Roster/art: ISSUES (16 exact bow cells). UI/UX: PASS for scoped HUD/control desktop-native checks. Mobile: ISSUES (physical S23 not retested). QA/production: HOLD for bow route/APK; no Phase4F.
