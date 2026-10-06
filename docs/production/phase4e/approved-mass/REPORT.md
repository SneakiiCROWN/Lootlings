# Phase4E approved-source presentation integration — 2026-10-06

## Verification and scope
VERIFIED OK for repo-side continuation from `7b9fcd3c325def53c2984e12fcd5cee374ff7ec8`. Current authority/history boundaries, 834 registry identities, 814 catalog/screen routes, rejected-source exclusions, master inventory, 11 frozen source hashes and isolated save/Field Notes checks passed. Checkpoint diff contained no asset/evidence deletion or rename. No approved artwork was removed or overwritten. Physical-device, process-death/cross-store, perceptual audio and final owner acceptance were not proven by these checks.

## Actual implementation
- Blueprint Forge cards now show existing item/weapon glyphs beside readable captions; selection, craft requirements, costs and confirmation paths remain intact.
- Regional bounty cards reuse actual campaign arena paintings. Thumbnail crops apply only to environment illustrations, preserve aspect ratio, and do not manufacture actor states.
- Memory cards explicitly use established resident portraits and the selected accepted Wanderer portrait atlas for the unlocked origin. Existing canonical Lootling portrait routes remain intact.
- Field Notes presents Trails paintings across the full header width with a contrasting title strip. Three discovery-gated Act I location pages reuse their exact existing paintings and actual encounter rosters. No invented lore, new identities or reward grants.
- ATTACK shows the current weapon glyph inside its existing hit target. The decorative texture ignores input; cooldown, trigger and modal blocking logic are unchanged.
- The Relic Machine incorporates the accepted crystal/brass production nine-slice frame with a subdued existing mechanical engraving. All six rarity effects, aperture clipping, stop axis, anticipation, skip/pity/earned-spin contracts remain intact. This is a frame integration, not final art/feel acceptance of the entire machine.

Reuse: existing 12-family weapon/inventory icon routes, established gear icons, campaign region illustrations, three Act I arena paintings, three resident portrait routes, accepted Wanderer portrait crops, and `art/ui/production/relic.png`. Runtime assembly: decorative cards, weapon control glyph, painted Field Notes headers and machine frame/inset. New raster exports/cutouts: **0**. Combat TEMP cells replaced: **0**. No new boss/NPC action states or dungeon mechanics were claimed. Existing characters, rig/socket/facing, encounter timing, damage, economy, RNG and save schema remain intact.

## Art debt: start → end
| Unit | Start | End |
|---|---:|---:|
| Missing delivery cells | 3065 | 3065 |
| Playable delivery cells | 2327 | 2327 |
| Body/view bundles | 106 | 106 |
| Authored support packages | 165 | 165 |
| LIVE_FINAL | 0 | 0 |

The generator retains 6805 records / 6075 launch slots / 3010 LIVE_BETA. Visible reuse improves existing presentation slots; it does not close absent authored attack/facing/support artwork. Exact requests remain in `docs/production/NEEDS_NEW_CANON_EXPORT.json` and the active canonical replacement register. Moonkip weaponless paws, canonical Gloomlet combat actions, flat player prototypes, Dragon source tail and distinct regional/boss/NPC states remain blockers. Rejected handoff bodies supply no runtime art.

## Evidence and QA
108 native before/after captures (27 per layout per revision). Native GLES3 fixtures use disposable saves at 1080×2340 and 1200×1920. Gallery includes blueprint/bounty rows and detail, upper/lower Archive, all three Act I paintings, six equipped ATTACK glyphs, and anticipation/reveal for **COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, RED**. Forced rarity previews explicitly grant nothing; they are presentation evidence, not earned-reward/RNG evidence. Combat captures use target-facing mode, not forced facing; they show existing TEMP body quality and do not certify missing canonical poses.

Before components are exact `git show` exports from starting HEAD for Hideout UI, combat controls and Relic Machine, loaded in ignored fixture paths. Other current catalogs/data are shared, including the new route pages. This is a controlled UI/control/frame comparison, **not an old-APK full-game comparison**. Original full-resolution PNGs remain in `.godot_test_data/phase4e/approved-mass`; committed JPEGs retain pixel dimensions at quality 94, without cropping or enhancement.

Passing regressions: mobile gestures; visible UI/free-spin/save contracts; RC save; Relic Spinner; weapon fit; Field Notes including positive/negative route discovery; canon registry and canonical-source mutation guards. Weapon fit covers 144 combinations / 864 facing-phase checks, zero unresolved technical contacts; 165 authored support packages remain visually unaccepted. Native fixture cleanup frees its helper to avoid test-owned shutdown leaks. Compiled APK proof loads shipped scripts and checks 11 boss accounts, three Engine captions, five tabs, five portrait atlases and three gated route pages.

Build once after the runtime batch: signed arm64 debug APK, v31 `0.4.22-phase4e-approved-mass`, target SDK36, 16KB zip alignment, reference/test source art excluded, licensed audio manifest retained. See `build-receipt.json` and compiled-code proof. No physical S23 FPS/memory/audio/lifecycle claim.

## Delivery
Implementation SHA: 844b0ad2c7c4d696db0826f90863e07d4c2fbf39
QA/evidence SHA is recorded by the subsequent current-authority receipt, avoiding a self-referential commit hash.
APK: `C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-approved-mass-debug.apk`
**GO for scoped S23 owner review; HOLD for full Phase4E/release. No Phase4F.**

Smallest S23 retest: install APK as an update; inspect Forge/bounty rows and Back/scroll; open Archive Trails after recovering Act I; test ATTACK then open/close a modal to check touch ownership; use an available earned spin and review the machine reveal; background/resume once. Report clipping/mistaps and visual/audio feel. Do not uninstall/clear data to run this check.

## Multidisciplinary sign-off
DESIGN: issues — final whole-game feel acceptance open; no balance change.
BALANCE: issues — unchanged mechanics; not a new full balance sign-off.
ECONOMY: issues — inspection/reward guards pass; physical/cross-store acceptance remains open.
ROSTER: issues — canonical action/support assets still missing.
ENEMIES: issues — exact regional art replacements remain open.
BOSSES: issues — Dragon source tail and distinct state exports remain open.
RNG: issues — existing spinner regressions pass; forced visual previews do not measure distributions.
UI/UX: pass for this inspected batch; whole-phase owner acceptance open.
NARRATIVE: pass for reused names/rosters/discovery gating; no new canon invented.
AUDIO: issues — final perceptual/mastering acceptance open; licensed sources preserved.
MOBILE: issues — native phone/tablet geometry and gestures pass; physical S23 performance/lifecycle/input open.
QA: issues — scoped automated/native checks pass; device and final visual gates open.
PRODUCTION: issues — safe checkpoint delivery; Phase4E remains HOLD.
