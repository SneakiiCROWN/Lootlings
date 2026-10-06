# Phase 4E owner-capture staging correction

2026-10-06. Branch `codex/phase4e-gamefeel`. Staging implementation `59275da`; completed damage-label correction `b1e805a`, preserving `78b1aa9` and every earlier checkpoint. On resume the worktree was clean: the earlier 23-file continuation had already been checkpointed. No reset, discarded files, canonical redesign, generated final art or Phase4F.

## Changes and measured comparison

`combat_stage.gd` supplies presentation-only lane bounds and a shared design-space ground at y548. Neutral bodies stay on their existing logical side; only existing short attack motion enters the gap. Logical positions, target-facing logic and encounter timing remain unchanged. Rendering, shadows and projectile launch/landing positions use the same presentation transforms. Normal enemy source images fit proportionally inside their existing archetype bounds. Boss source aspect corrections remain intact.

| Owner case: Relic Beast / Razor Imp | Before | After |
|---|---:|---:|
| Neutral right-facing body-envelope gap | -10 px overlap | 35.6 px clearance |
| Neutral left-facing body-envelope gap | -19.6 px overlap | 26 px clearance |
| Player foot baseline, right / left | 565 / 576 | 548 / 548 |
| Enemy foot baseline | 558 | 548 |
| TEMP rig scale | 1.10 | 1.00 |
| Single normal-enemy HP-bar y | 255 | 366 |
| Pack HUD top y | 194 | 307 |

These are 480×854 design-space rectangle-envelope measurements, not alpha-pixel anatomy measurements. Native before/after views confirm separated idle/recovery silhouettes and preserved feet/weapon margins. Good authored heavy-weapon art stays in use. TEMP bodies are not enlarged to compete with detailed enemies.

Enemy labels/HP follow the rendered opponent horizontally and sit closer vertically. Pack card touch dimensions are retained; moving cards into the arena also required explicit gesture ownership: a card tap selects without attacking; a drag/cancel does neither; mouse selection follows the same rule. Existing scrolling, menu ownership and purchase protections remain.

Final damage/hurt text layout now anchors and centers labels on the rendered recipient. The earlier attempted correction `78b1aa9` was overwritten by a later fixed-lane assignment and did not fix native output. `b1e805a` corrects that final assignment and centered text-box placement. Enemy hit labels start below the normal enemy HUD; player damage labels track the player. Actual left/right melee and hurt captures prove this final correction. No damage values changed.

## Validation and evidence

- Final isolated `combat_staging_qa`: 1,152 samples = 12 actors × 12 weapon families × two real target facings × four attack positions. Checks full body/held single and paired weapon bounds, planted feet, neutral separation, projectile socket transforms and unchanged logical positions, HP, clocks, combat/loot RNG and profile. Additional damage/hurt anchors and selected 2/3-enemy pack anchors pass.
- `encounter_qa`, `mobile_gesture_qa` and `phase4e_feedback_qa` pass. Pack HUD tap/mouse selection never dispatches an attack; card dragging does not select or attack. Prior broad authored/facing QA remains preserved.
- Native phone 1080×2340 and tablet 1200×1920: Relic Beast versus Razor Imp idle, melee, ranged ready/fire, orb charge/fire, hurt and recovery in both target relationships; all twelve selectable actors idle/bounds; 2/3-enemy pack staging. Dedicated contact runs invoke the actual player/enemy attack functions in isolated seeded encounters. Bow/orb flights use actual projectile launch and mid-flight update, not a painted projectile stand-in.
- Both-facings captures arrange real logical target positions explicitly; `forced_facing_test=0`. They are staged regression encounters, not evidence of player-controlled lateral movement or new attack mechanics. Earlier crossing evidence remains in the canon-freeze report.
- `capture-index.json` indexes 148 full native PNGs with dimensions, bytes and SHA256: 18 baseline phone; 42 final phone; 42 tablet roster/state views; 10 final actual-contact phone; 10 final actual-contact tablet; six ranged/pack views per layout; 14 retained Dragon margin/state views. Tablet roster captures precede final label centering, but label-bearing actual contacts were recaptured afterward. Local original paths are indexed; readable comparison sheets, both roster sheets and selected full-resolution frames are committed here. Evidence crops are review aids, not modified game art.
- Native visual inspection confirms lane/ground/HUD corrections. It also confirms the flat fallback bodies remain below the quality target. This is scoped geometry acceptance, not full roster/enemy aesthetic acceptance.

## Android candidate

`C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-staging-owner-debug.apk`

137,134,986 bytes; SHA256 `c829e7d39ffe82a484c96133311414834c40295320f8dfdeac44eff222a7d079`. Version20 / `0.4.11-phase4e-staging`. Signed arm64 debug build; 16KB alignment; SDK24–36; no permissions; current bow/heavy imports, manifests and 456 documented PCM assets verified. Reference/test source art excluded. `android-build-report.json` and `apk-compiled-modules.json` record the exact candidate. Physical S23 performance/lifecycle/input are not validated by desktop native review.

Smallest S23 retest: install this APK over the existing app without uninstalling; fight with Relic Beast's greatsword and watch neutral/contact/hurt/recovery spacing and numbers; try bow/orb and tap/drag a pack target card (selection must not trigger an extra attack); background/resume once, then close/reopen and check progress. Report clipping, wrong-facing/contact or card-triggered attack with a short recording. Final perceptual audio and visual owner acceptance remain separate.

## Remaining queue and sign-off

Continue from `polish/CANONICAL_REPLACEMENTS.md`. No canonical replacement row or support-art cell is closed by geometry: 165 support-art cells remain. Relic Beast and other rejected flat bodies remain TEMP rig/socket prototypes where proper authored states are missing. Moonkip needs established hooded-rogue weaponless production art; Gloomlet needs its established violet furry Assassin combat body. Hoard Dragon's malformed/double-reading source tail remains REPLACE: common-ground/aspect rendering is not a tail repair. No conflicting handoff board body is imported. Exact transparent canvas/state/view/socket deliveries remain in the canonical register/export requests and `ART_EXPORT_CONTRACT.md`. Remaining regional/boss/NPC identities require those exact canonical exports; neither technical rigs nor reference boards count as final bodies.

Non-art gates remain separate: save semantic/cross-store/process-death acceptance beyond scoped existing reward checks; final audio/mastering/perceptual acceptance; physical S23 performance/lifecycle/input; final player-facing owner visual acceptance. Full Phase4E remains HOLD while targeted repo-side fixes continue.

| Discipline | Scoped sign-off |
|---|---|
| DESIGN | PASS for staging correction; no gameplay redesign |
| BALANCE | PASS for unchanged-state contract; no retuning or new full balance acceptance |
| ECONOMY | PASS for unchanged presentation-only scope; prior gates preserved |
| ROSTER | ISSUES: canonical combat exports and 165 support-art cells |
| ENEMIES | ISSUES: geometry improved, outstanding canonical identity replacements |
| BOSSES | ISSUES: source tail and other canonical replacement art; no tail sign-off |
| RNG | PASS for unchanged RNG contract |
| UI/UX | ISSUES: desktop native/card regressions pass; physical touch acceptance pending |
| NARRATIVE | PASS for unchanged canon/text in this correction |
| AUDIO | ISSUES: perceptual/mastering/owner gate unchanged |
| MOBILE | ISSUES: build and desktop phone/tablet pass; physical S23 pending |
| QA | ISSUES: scoped automatic/native pass; external acceptance gates remain |
| PRODUCTION | ISSUES: safe implementation/evidence checkpoints; full Phase4E HOLD |
