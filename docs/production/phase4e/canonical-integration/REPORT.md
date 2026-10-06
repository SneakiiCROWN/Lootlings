# Phase 4E canonical asset integration — scoped owner test GO, phase HOLD

2026-10-06. Continued the preserved `codex/phase4e-gamefeel` branch from `9b8a8d9`. No reset, redesign, Phase4F, generated body art, balance/timing/RNG/save-schema change or substitution of rejected boards.

Implementation checkpoints: `a28e119a4e350a1bb63852220f0a9363195bafe7` (existing canonical NPC integration, proportional bosses, visible XP, selector labels) and `6ee28a3fee33214f090a4b4f926416cb25f37d6a` (native-review full-name HUD correction). QA/report is a separate checkpoint. The final QA commit and remote receipt are reported with the handoff.

## Actual visible integration

Three complete **existing** 1024×1536 RGBA production idle exports now replace flat Home resident puppets: `art/sprites/npcs/beta/patch_idle.png`, `ilex_idle.png`, `sera_idle.png`. These exact bodies already appear in resident memory scenes; no new approval, character identity or artwork is invented. [Source hashes, alpha bounds and runtime mapping](source-integration.json). Full canvases are rendered without cropping, tinting, body segmentation or aspect distortion. Their original costume/face/colours remain. Existing route translation, activity schedule, dialogue ownership and touch targets remain; this is **idle-body integration**, not authored walking, seated, work or talk animation.

Native review found old forge weapon/spark overlays floating beside Patch and a procedural page block at Ilex's shins. Those disconnected prototype props were removed; the existing painted counters/books and ambient lights remain. No fake hand contact is hidden with FX. Authored activity/prop-contact exports remain required.

All ten boss profiles now fit the source aspect ratio inside their **own existing bounds, anchor and baseline**, rather than stretching non-dragon sources to fill rectangles. Existing individual sizes, source routing, target orientation, encounter timing and attack logic remain. This corrects renderer distortion only: Dragon's malformed/double-reading source tail is still **REPLACE**, and reused/procedural boss bodies remain TEMP.

The four-unit XP track previously became zero-height after a two-unit inset on both sides. It now keeps a two-unit fill, using the existing skin. HP/enemy bars retain their dimensions. The selector tabs read **LOOTLINGS | WANDERERS**; this does not remove TEMP/BETA status from combat art. Native roster review also found Nightstage Drifter/Velvet Astrologer names clipped by the header width. Font size now fits the full canonical name into the existing 170-unit lane without moving Pause/currency controls. Every Wanderer name is checked against the actual loaded font.

Godot's [CanvasItem drawing contract](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html#class-canvasitem-method-draw-texture-rect) draws textures into the supplied rectangle. The proportional rectangles use the source dimensions from [Texture2D.get_size](https://docs.godotengine.org/en/stable/classes/class_texture2d.html#class-texture2d-method-get-size). Uniform fit is tested and inspected in native scenes; it does not repair malformed source anatomy.

## Batches preserved and examined

- **7 Lootlings / 5 Wanderers:** exact canonical selectors and existing good authored heavy poses retained. Both staged target relationships captured for every actor. The current pose manifest contains 246 rows, **62 nonempty authored-beta rows referencing 22 distinct images**; empty `art_required` rows are not usable assets. Static selector idles cannot become missing support-hand/attack frames without authored contact/state art. Relic Beast's right heavy pose is good; its left/ranged and other deficient creature bodies remain visibly TEMP. Adult heavy exports are retained in both views. No handoff board replaces any identity.
- **12 weapon families:** native READY and executed attack states, both target relationships, using existing art/routing. Bow orientation/nock, crossbow, separate dagger/claw palms, staff support, orb launch and sling connections retain existing contracts. Technical contact checks pass; crude body presentation still blocks visual approval. **165 authored support/paired cells remain, 82 right / 83 left**. The support-only count does not close deficient one-hand/body states.
- **27 regional profiles / 10 bosses / modifier presentation:** every existing regional profile captured with its TEMP status explicit; all ten boss encounters captured in idle/opposite target/windup/executed attack/hurt/recovery/defeat. Existing regional backgrounds remain routed to stable region IDs. Wave6 seeded encounters are **not guaranteed elites**; ten additional captures explicitly use the existing Armoured modifier and are labelled **FORCED MODIFIER TEST**. These are not naturally rolled elite-distribution evidence. No distinct regional or boss export was delivered to replace the remaining proxies. The approved boss-frame manifest remains empty.
- **Home/current cast:** Patch, Ilex and Sera idle integration is new. Pack Peddler/Merrow's current merchant role remains; Edda Sable is not promoted from a board into an implemented NPC. The replacement register and derivative delivery requests record the three available idle exports and pending activity art, without closing their N-state rows.
- **Equipment/UI/world/app:** existing held weapon assets, seven item-image mappings, type/currency/rarity icons, bar/card skins, chests, regional paintings and brand/icon/splash/wordmark routing retained. No separate newly supplied armour/shield/off-hand/outfit animation layers exist to integrate. Shared type icons are not proof of item-specific or body-layer art. Gear/shop/results/engine/title and all selectors captured; earlier phone/tablet navigation, comparisons, optional Keep/Skip/Leave, earned-spin protection, ATTACK and six-tier machine evidence remains [preserved](../visible-mass/REPORT.md). No new region/family/NPC is inferred from concept labels.

## Evidence and limits

[Native gallery](GALLERY.md), [all image paths and hashes](evidence-manifest.json), [source mapping](source-integration.json), [QA logs](qa), [APK receipt](android-build.json). **236 native images**:203 phone matrix,1 tablet Home,22 final phone and10 final tablet. Full-resolution JPEG92 images preserve the original capture dimensions; original PNG paths/hashes remain available locally. Review contact sheets are navigation aids, not substitutes for readable full images. Final Home/dialogue/XP/modifier/full-name images are in `final-phone` / `final-tablet`. All matrix frames were recaptured after the name-fit correction. An initially hidden-selector fixture was corrected to open the actual startup parent, select after the panel initializer, and assert panel visibility; its misleading underlying-scene images were replaced by the final native run.

Native GUI fixtures use disposable saves. Combat is deliberately staged and processing frozen for reproducible capture; attack methods execute, but these are sampled renders rather than continuous gameplay recordings. Target positions are explicitly staged, with the generic forced-facing flag off. Defeat/hurt/recovery use existing presentation states, **not new authored frames**. Floating numbers can persist across frozen samples; this is fixture staging, not evidence that they persist in live play. No physical S23 FPS/audio/lifecycle acceptance is claimed.

Eight focused automated fixtures passed with no engine/script errors: authored poses, boss manifest, canonical integration, staging, mobile gestures, visible reward/input safety, resident source identity, weapon fit. Staging covers **1,152** actor/weapon/facing/phase samples. Weapon fit covers **144 combinations / 864 facing-phase checks**, unchanged gameplay/loot RNG, transformed palms/nock/projectile origin and zero unresolved technical support flags; it explicitly reports the unchanged 165-cell **art** debt. The final HUD-specific test separately passes all Wanderer name widths. Native matrix and final phone/tablet Home/HUD checks also pass. An initial restricted-shell run emitted Windows certificate-store access errors; the same fixtures rerun in the permitted native runtime passed. A new fixture typo (`name` instead of `display_name`) was corrected before the final HUD result; it did not alter game behaviour.

Canonical guard: **11 frozen sources unchanged; five rejected boards excluded; 246 existing pose rows preserved; zero newly approved boss frames; art acceptance false**. This is source-integrity evidence, not aesthetic sign-off.

## Remaining exact production work

The active queue remains [CANONICAL_REPLACEMENTS.md](../polish/CANONICAL_REPLACEMENTS.md). Its [52 per-ID export requests plus current merchant supplement](../polish/replacement-export-requests.json) and [export contract](../polish/ART_EXPORT_CONTRACT.md) specify identity, state/view, RGBA canvas, full silhouette, baseline/pivots, palm/nock/launch/foreground-finger metadata and compatible weapon groups. No queue row or support cell is falsely closed.

1. Canonical C-state bodies for all12 actors where absent/deficient: creatures512×512, Wanderers1024×1536, retain Relic Beast's good1280×1280 heavy exports. Both views, actual required idle/move/windup/strike-or-cast/follow-through/recovery/hurt/defeat/victory-return; shared canvas/baseline and current manifest sockets. **Moonkip** needs its established hooded-rogue weaponless body, baked daggers genuinely removed by the source artist. **Gloomlet** needs violet furry Assassin combat states; existing selector idle retained, rejected foxlike rig/mushroom board never canon. **Glimmerfin** already has a weaponless idle.
2. **Hoard Dragon:** established wingless/coiled purple/obsidian/gold body with one genuinely redrawn continuous tail,2048×2048 complete-state RGBA package, uncropped/full source proportions, both views, current pivot/anchor; idle/claws/brace/coin-breath/tail-sweep/hurt/recovery/defeat. Correct renderer proportions do not fix this source.
3. Every named E/B queue entry still needs its exact existing species/region/identity: regional1024×1024; bosses2048×2048; both views, same baseline, named windup/commit/recovery/hurt/defeat and boss phase/vulnerability states. Elite overlays must fit those species. Existing intro/detail textures or procedural attachments are not approved articulated combat packages.
4. Patch/Ilex/Sera: existing idle exported and integrated; exact1024×1536 transparent route/work-read-tend/inspect/talk/sit layers, both route views, palm/prop metadata remain missing. Merchant rest/talk/offer/inspect/return remains a separate current-role package. Rig/routes/dialogue can be reused.
5. Missing item-specific/off-hand/outfit layers need actual canonical assets and explicit inventory/body socket mappings; generic icons or reference labels cannot establish them.

Rejected identity-drift references remain exactly [REFERENCE_STATUS.json](../../../../art/reference/phase4e_handoff/REFERENCE_STATUS.json): changed Hoard Dragon, Moonkip, Gloomlet, overview/art-bible and combat-style board bodies. Compatible pose/export/VFX guidance only; no runtime import.

Separate non-art gates remain: full save semantic/cross-store/process-death acceptance beyond existing scoped checks; perceptual audio/mastering; final visual owner approval (including machine payoff); physical S23 performance, insets, input and lifecycle.

## Android / smallest owner retest

`C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-canonical-integration-debug.apk`

Version23 / `0.4.14-phase4e-canonical-integration`.137,155,925 bytes (130.80MiB). SHA256 `f5cdf2df3f3de1df19f212b7e2baf3c5b2ef868cb698a8ed0c0ed7b107fecb71`. Signed arm64 debug build;16KB alignment; offline/no permissions; current imported NPC idles, bow and heavy poses checked byte-for-byte;456 PCM audio assets and licence/source documentation verified; tests/tools/source/reference/rejected boards excluded. Device validation remains false. The three full-resolution idle textures retain their existing imports:18MiB of raw RGBA texels in total before runtime allocation overhead; physical memory/performance acceptance remains required.

Install over the previous test app **without uninstalling/clearing data**. Open Home and tap Patch/Ilex/Sera; check full bodies, dialogue and Gear/Back. Select Nightstage Drifter then Velvet Astrologer and enter combat; check full header names and growing XP. Pause/background/resume once and confirm saves/input still behave. Capture any clipping or misplaced bodies. This is a scoped **GO for S23 owner review**, not release/art acceptance. Full Phase4E **HOLD**.

## Multidisciplinary sign-off

Statuses are scoped to this change; none imply whole-game approval.

| Discipline | Status |
|---|---|
| DESIGN | ISSUES: full reward/game-feel owner acceptance remains |
| BALANCE | PASS: combat stats/damage/cadence unchanged; scoped geometry/fit regressions pass |
| ECONOMY | ISSUES: earned/optional flows preserved and tested; long-term additive progression acceptance remains |
| ROSTER | ISSUES: missing canonical C states and165 support cells |
| ENEMIES | ISSUES: regional proxy replacements remain |
| BOSSES | ISSUES: malformed Dragon source-tail and exact articulated packages remain |
| RNG | PASS: RNG/pool/encounter definitions unchanged; fixture staging is explicit |
| UI/UX | ISSUES: resident/XP/full-name corrections native-checked; owner/device acceptance remains |
| NARRATIVE | PASS: frozen existing identities, voices/region IDs retained; no new canon inferred |
| AUDIO | ISSUES: routing/provenance preserved; perceptual/mastering acceptance remains |
| MOBILE | ISSUES: verified APK and native phone/tablet evidence; physical performance/lifecycle/input unproven |
| QA | ISSUES: scoped regressions/native evidence pass; art/owner/save/device gates remain |
| PRODUCTION | ISSUES: safe implementation/QA checkpoints; full Phase4E HOLD, external exact exports still required |
