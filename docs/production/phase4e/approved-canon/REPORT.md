# Phase4E approved missing-source canon / v38

## Outcome
35 previously source-less identities now have owner-approved reference authority: 27 regional enemies, Lantern Jackal, Belljaw, Drowned Engine, Redactor, The Unchosen, Chainwarden, Hollow Crown, and Pack Peddler/Merrow role. Exact named board panels and source hashes are registered; board headings do not change game regions or stable IDs. Established Lootlings, five Wanderers, current NPCs and existing bosses remain unchanged. Supporting and marketing boards remain reference-only.

One actual runtime RGBA export is installed: `art/production/phase4e/enemies/fen_sneak/fen_sneak_idle_right.png`, 1024x1024, complete silhouette, original source RGB, uniform scaling, transparent corners, baseline 992, pivot [512,992], actual source socket sidecar. Only neutral right-facing gameplay can use it. Attack/windup/hurt/recovery/defeat/opposite-facing states remain OPEN; there is no mirrored or repeated-idle substitute.

## Counts / honest boundaries
New source subset: 594 -> 593 missing delivery cells. Global debt: 3051 -> 3050 (2313 playable + 737 other); 106 body/view bundles and 165 support packages unchanged. Exactly one TEMP delivery cell closed. Zero LIVE_FINAL. Ten approved source boards are references, not ten runtime exports.

All ten missing-source boards were reviewed. Small action strips cannot meet full native-scale canvas/readability requirements. Six large neutral crops were alpha-tested: Fen Sneak passed; Forge Beetle, Mirror Knight, First Guard, Deck Hexer and Pack Peddler fail complete source silhouette, unobstructed foot/contact, or palm/socket verification. No failed candidate was installed. Pack Peddler's second white shape cannot be verified as a palm. Merrow is a separate labelled appearance panel; it is not silently substituted for the Pack Peddler body. Boss strips are too small/obstructed for the requested 2048 state deliveries. No anatomy was reconstructed, and no board image was called a finished action frame.

The single consolidated `../HIGH_RES_RUNTIME_GENERATION_QUEUE.json` contains all 593 exact remaining state/view requests with approved identity source, canvas, baseline/pivot, filenames, destinations, layer/socket requirements and reason extraction fails. Established actor debt remains in NEEDS_NEW_CANON_EXPORT.json.

## Validation
Canonical guard, dedicated-sheet freeze, nine negative art cases, seven negative registry cases, new 35-entity/one-export guard, fresh master/registry checks and Godot parser/import pass. Native phone/tablet exact-state routing and fallback guard pass; eight captures are linked in [gallery](GALLERY.md). Mobile gesture, Phase4B, Phase4E visible, save and weapon-fit regressions pass. Weapon-fit still reports the pre-existing Glimmerfin Staff support issue and 696 sampled TEMP frames; this pass does not accept or close them.

The target-side capture is a synthetic fixture with the player placed to Fen Sneak's right to exercise its authored right view. It is not normal-lane acceptance. The flat Relic Beast prototype is still TEMP and its fixture overlap is not accepted as final presentation. No balance, encounter clocks, damage, RNG, save schema or input behavior changes.

Android debug v38 / 0.4.29-phase4e-approved-canon builds successfully. [Receipt](qa/APK_RECEIPT.json) verifies the new routing script, exact manifest and imported texture inside the APK, with reference boards excluded. APK: `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-approved-canon-debug.apk`. Physical S23 performance, lifecycle, input, visual and perceptual acceptance remain untested.

## Acceptance
Scoped reference promotion / one exact runtime delivery: PASS. Full Phase4E: HOLD for authored state art, known support debt, save semantic/cross-store/process-death acceptance, final audio/perceptual owner acceptance, and physical device testing. No Phase4F.

DESIGN: pass for unchanged mechanics. BALANCE: pass for unchanged balance. ECONOMY: pass for unchanged rewards. ROSTER: issues, remaining TEMP states. ENEMIES: issues, 593 subset cells remain. BOSSES: issues, exact authored states missing. RNG: pass for unchanged RNG. UI/UX: scoped regressions pass. NARRATIVE: pass for preserved IDs/regions. AUDIO: issues, final perceptual acceptance outstanding. MOBILE: issues, S23 acceptance outstanding. QA: scoped checks pass; full acceptance issues. PRODUCTION: issues, explicit art/device/owner gates remain.

Implementation SHA: `553687575882d80d60e5d3ad6c9d0de5696826da`.
QA/evidence SHA: recorded by separate following Git commit.
