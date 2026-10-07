# Phase4E recovered approved-art/runtime integration — 2026-10-07

**GO for scoped S23 owner review; HOLD for full Phase4E/release acceptance.** Branch `codex/phase4e-gamefeel`. No Phase4F. Preserved all interrupted implementation and established identities; no reset, source deletion, redesign, balance/economy/RNG/save-schema change.

Recovered implementation: `f7d9ed653106b183ab05d07e9c2a9c9e7fb46d30`, already pushed before continuing. Native-reviewed world/layout continuation: `7e7d48dab7e23360aa0bd55ea875afcb1346e334`. Separate QA/evidence SHA is recorded by the subsequent current-authority receipt.

## Visible implementation

- Recovered all twelve named interrupted files: exporter, cached art resolver, creature/casting renderer, impacts, projectiles, chest presentation, avatar HUD portrait, dungeon destinations, Home/shop/Forge, Relic Machine, combat HUD and native fixture.
- **13 new original-pixel transparent exports; all 13 integrated.** Three established `art/reference/phase2_master` sheets supply eight static VFX motifs, three reward/item glyphs and two world props. Paths: `art/production/phase4e/{vfx,items,props}`; exact crop/canvas/alpha-mask/source/export hashes in the extraction manifest. No new character body or fake animation frame. RGB preservation and four-pixel transparent gutters verified for each export in `qa/extraction-audit.json`.
- Fire/Frost/Arcane/Corruption contacts now use bounded painted motifs on existing clocks. Arcane/Corruption projectiles use accepted crystal/shadow art; orb charges remain connected to the existing socket. Lightning/Poison retain existing presentation where no exact accepted export exists. A motif is not an authored cast pose.
- Existing chest-opening energy gains an accepted treasure burst behind the complete chest. No fake hinged-open state. Recipe reels use source scrolls. Legendary/RED add different painted energy inside the clipped machine aperture; the source crown retains its original colours. All six tiers remain one machine, with readable tier/stop axis. Existing odds, pity, skip, earned/free-spin and reward/save contracts remain intact.
- Relic Beast's HUD uses its accepted face/ears crop; player/enemy HUD frames reuse accepted crystal/brass material without changing bar/control hit regions. This is a HUD improvement, not new combat-body acceptance.
- Home's existing merchant/Forge stations now show accepted cart/forge props. Forge hotspot remains above the footer and below storage; no new station/economy. Shop header uses the same cart.
- Dungeon Treasure/Merchant/Shrine/Rest choices reuse key/cart/shrine/vines illustrations. Correct Moonfen arena remains behind the route. Native inspection found invisible duplicate Button text expanding route cards offscreen: visible child labels now own wrapping and hidden text is removed; captions remain in the tooltip. A native bounds assertion guards the two route cards. Godot's Control minimum size is content-driven; setting a nominal size alone does not defeat it ([official documentation](https://docs.godotengine.org/en/stable/classes/class_control.html)).
- Field Notes landscape pages now devote a 240-high header to the actual accepted painting, with contrasting title strip; the 18pt body remains scrollable. Page painting also supplies the backdrop. Boss pages lacking body art continue using their region painting, explicitly **not** substitute boss portraits.
- Unlocked region/boss Memory cards now have larger aspect-preserving illustrations and readable captions; locked memories stay concealed. Existing portraits/neutral sources remain unchanged.
- Relic Siege mode menu uses its accepted First Hoard painting; other mode choices retain the accepted Grove. No region IDs or lore changed.
- Ilex native review exposed dialogue text close to its Archive action. The panel grows upward with a larger text region and separated action; existing authored voices, portrait routing and dismissal/navigation remain unchanged.

## Sources and identity boundaries

Used established accepted phase2-master non-character sheets, existing production frame/shrine, accepted runtime Relic Beast face, current resident portraits, current campaign/Act I paintings and existing Memory sources. The five rejected handoff boards supply **zero runtime bodies and zero exports in this batch**; no conflicting board guidance was needed. Frozen source hashes and accepted pose rows remain protected. No canonical character sheet was changed or used to fabricate a missing action/facing.

Seven Lootlings, five Wanderers and twelve weapon families remain locked. Existing NPC/enemy/boss art is reused in Archive and contextual pages; **no new enemy, boss or NPC combat/activity states** are delivered. Neutral Relic Beast spell fixtures do not certify cast/action body art. The Moonfen combat fixture visibly retains a regional enemy proxy under Fen Sneak: that identity replacement remains open, not accepted by this effects pass.

## Counts: start → end

| Unit | Start | End |
|---|---:|---:|
| Existing extracted exports | 78 | 91 |
| New exports integrated this batch | 0 | 13 |
| Combat TEMP cells removed | 0 | 0 |
| Missing delivery cells | 3065 | 3065 |
| Playable delivery cells | 2327 | 2327 |
| Body/view bundles | 106 | 106 |
| Authored support packages | 165 | 165 |
| LIVE_FINAL | 0 | 0 |

Generated inventory: 6831 records, 6101 launch slots, 3036 LIVE_BETA, 122 fresh inputs, 834 identities/814 routes. Recovered interim inventory had one additional duplicated route text record; removing invisible duplicate text changes that record count, not content/art debt. Exact absent states/canvases/baselines/anchors/sockets/source matches remain in `docs/production/NEEDS_NEW_CANON_EXPORT.json`, alongside the active replacement/export contracts. Units are not additive image counts.

## QA and limits

[38 final native captures](GALLERY.md), 19 per phone 1080×2340/tablet 1200×1920, GLES3, disposable profiles. Images preserve dimensions, JPEG94 without crop/enhancement; PNG originals remain local. Includes Home, Ilex, merchant, region/boss memories, three illustrated Notes pages, actual dungeon choices, four spell motifs and COMMON/UNCOMMON/RARE/EPIC/LEGENDARY/RED previews. Forced rarity previews explicitly grant no reward and prove presentation, not odds or real earned results. Spell fixtures inject visual missiles/impacts into neutral target-facing staging, not automated combat acceptance.

Fixture corrections: early dungeon capture was not a valid unlocked route. Final fixture explicitly unlocks only its disposable profile and starts the real Moonfen route. Later spell staging inherited its route overlay; fixture now clears it before neutral combat captures. These exploratory images are not final evidence. Early incomplete fixture resource/property errors remain in local exploratory logs; final fixture completes with zero engine/script errors.

Passing existing suites: dungeon, Field Notes, mobile gestures, Phase4E visible/free-spin contracts, RC save, Relic Spinner and weapon fit. Latest changed route/touch/visible paths rechecked after native overflow correction. Weapon fit: 144 combinations/864 facing-phase checks, zero technical contact errors; 165 authored support packages remain unaccepted. Eight canonical guard mutation checks and seven registry mutation checks pass. Master/registry/frozen-source validation passes. No test-win tuning or simulation/balance changes.

Compiled APK checks: 11 boss accounts, three bounded Engine captions, five Field Notes categories, five accepted Wanderer portrait atlases and three discovery-gated Act I routes. Build verifies all 91 extracted imported assets, accepted bodies/poses, bow/residents, source/reference/test art exclusion, licensed audio manifest, signature and 16KB alignment. These are build checks, **not physical S23 performance or perceptual art/audio acceptance**.

## Android delivery / smallest owner retest

**v33 / `0.4.24-phase4e-bible-world`**, signed arm64 debug, targetSDK36:

`C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-bible-world-debug.apk`

142,290,948 bytes; SHA256 `e041628af3b60680c076b7df189e68cf3345e05cbaf60555af8ee9e99e7331fa`. Current receipt in `build-receipt.json`; recovered v32 receipt preserved separately in `build-receipt-v32.json`. APK includes runtime at `7e7d48d`; subsequent fixture/evidence/docs do not change shipped game code.

1. Install v33 over the existing test app without uninstalling/clearing data; check your gear/currencies remain.
2. Home → Ilex/Archive → Trails/Bosses/Memories; swipe, read the illustrated pages, return. Enter an unlocked Dungeon and check both destination cards fit and select safely.
3. Play one available spell/orb run; review HUD, effects and ATTACK/UI isolation. Open Relic Engine when safe and use an already-earned free spin if available; inspect result/return. Do not spend or alter odds just to force a premium reveal.
4. Background/resume once during combat and once after a reward; relaunch and confirm progression/reward is retained once. Report jank, heat/FPS, lost input/progression and visual/audio dissatisfaction.

## Remaining gates and next work

Exact canonical weaponless Moonkip paws, Gloomlet actions, missing playable action/facing/support artwork, distinct regional proxies and boss/NPC activity states remain queued. Original Hoard Dragon continuous-tail source repair remains required; no crop/squash/FX repair claimed. Do not use rejected Moonkip/Gloomlet/winged-Dragon bodies. Final spinner/character/world visual owner approval, perceptual audio/mastering, physical S23 input/performance/lifecycle and semantic/cross-store/process-death save acceptance remain open. Repo-side integration continues against exact safe accepted sources; this checkpoint does **not** declare game-wide integration exhausted or Phase4E complete.

## Multidisciplinary sign-off

DESIGN: issues — overall Phase4E presentation acceptance open; scoped mechanics preserved.
BALANCE: issues — no retuning; this visual batch does not certify full balance.
ECONOMY: issues — existing regressions pass; cross-store/reward acceptance remains open.
ROSTER: issues — missing canonical actions/weaponless/support art.
ENEMIES: issues — regional proxies remain.
BOSSES: issues — Dragon tail and distinct state/body exports remain.
RNG: issues — spinner regressions pass, no odds change; no new distribution acceptance claimed.
UI/UX: issues — reviewed layout fixes pass locally; S23 touch/owner acceptance open.
NARRATIVE: issues — written canon preserved and reviewed pages readable; no new full-string acceptance claim.
AUDIO: issues — assets/licences preserved; perceptual mastering remains open.
MOBILE: issues — desktop native phone/tablet layouts pass; physical S23 gates open.
QA: issues — scoped native/regressions/build pass; missing art/device/save gates prevent full acceptance.
PRODUCTION: issues — safe implementation checkpoints; Phase4E remains HOLD, no Phase4F.
