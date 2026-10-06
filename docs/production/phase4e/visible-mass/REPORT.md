# Phase 4E mass visible integration / owner candidate

2026-10-06. `codex/phase4e-gamefeel`. First implementation `ffde2842df66708dfd03581ef2266562287bcf51`; final implementation `1362a891841b2b77674226b770af5a08f3aaec87`. The clean starting checkpoint `b7b4c4d` and all prior staging/canon work are preserved. No reset, discarded source work, Phase 4F, canonical redesign or generated final body art.

**GO for a scoped S23 owner retest. HOLD for full Phase 4E acceptance/release.** This is implemented phone navigation, reward choices, earned spins and presentation work, not closure of the canonical art queue.

## Visible implementation and native corrections

- Home keeps the established painted world, hero, residents and stations visible; large bottom Expeditions and Relic Engine actions replace the single bottom expedition action. Earned bank count is shown at Home. Footer moved below the actions and notifications above them. Existing resident bodies remain TEMP, visibly below final quality.
- Regions, Siege and Dungeons have a clear mode tab strip, selected state, environment image, concise route summary and separate large actions. Underlying Hideout panels/dialogue and results are actually hidden, not merely drawn underneath. Back closes the active detail/modal before its parent; mode/engine/results return to the correct Home or results origin. Merchant Back leaves without spending; perk/item Back keeps current; boss-find Back declines the find without throwing away a completed victory. Unfinished route/chest/Siege exits retain an explicit abandon confirmation.
- A dedicated 320x72 design-unit ATTACK button sits in the lower combat area, away from reward/shop controls. A genuinely thin custom track replaces the engine ProgressBar whose theme minimum inflated it into a gold block in first native review. Auto-attacks and the existing tap cooldown remain unchanged; arena tapping remains supported. ATTACK is hidden during modal choices, narrative and travel states.
- Buttons dispatch deliberate releases. Active-panel ownership, clipped ancestor checks, drag cancellation and synthetic-mouse suppression protect combat from shop/menu/HUD touches. Existing pack target-selection protections remain intact. Phone/tablet scrolling continues to use the existing gesture owner.
- Merchant inspectable offers show NEW ITEM, current equipped gear, stat changes, price and optional BUY / SKIP. Unaffordable offers can be inspected but cannot be bought. Home purchases stay in Gear, leaving equipped gear untouched. Gear shows owned candidate/free equip cost/current comparison; existing Back and unequip safeguards remain.
- Perks show current stacks, new stacks/effect and FREE cost with TAKE / KEEP CURRENT. Item review adds KEEP CURRENT / LEAVE FIND. Boss finds add a readable equipped comparison before selection and a separate KEEP CURRENT / LEAVE FINDS action. Declining an item does not equip, salvage or charge it. Declining a level-up intentionally forgoes that pending perk, rather than retaining an endlessly re-openable offer.
- Siege services display current state and capped before/after hits, leech/armour tradeoff or healing and Embers cost. Full-health healing and fully capped boosts cannot charge for no improvement. KEEP MOVING stays available. Values/prices and service effects are unchanged.
- First phone review exposed attack-meter inflation, a dungeon button exceeding its width and the Home footer intersecting the dock. Fixed the track, wrapped/clipped action captions and shortened the primary dungeon caption, then recaptured phone/tablet. A later native fixture used a nonexistent `glassveil_blade` ID; it was rejected by the runner, replaced with shipped items, and rerun cleanly. Failed captures are not presented as passing evidence.

Godot documents that draw order/z-index does not itself control input order, so hiding inactive panels and choosing an explicit input surface are deliberate parts of the fix: [CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html), [Control](https://docs.godotengine.org/en/stable/classes/class_control.html). No invented external design standard or copied economy values.

## Relic Engine and earned rewards

The existing original machine now has additional brass bevels, crystal side inserts, engraved highlights, cylindrical reel lighting/curvature, staggered audible reel stops, quieter decelerating ticks and a clear central lock axis. Incoming symbols compress toward reel edges; final premium medallions are bounded to their reel cells. Existing clipped apertures, rarity colours, premium anticipation, gold rays, RED crackle/punch/hold, reveal card and delayed-frame/reduced-motion protections are retained. Epic/Legendary/RED full reveals remain unskippable; repeat Common/Uncommon/Rare can run quickly or be skipped. This is original UI material work, not procedural character art. Owner perceptual/visual approval is still required; this report does not assert the machine has achieved final premium quality.

FREE earned spins use the same useful existing pool, charge **zero Scrip**, do not consume the paid-spin allowance and reserve reward plus progress atomically. Eligible reasons are boss, elite/miniboss, 30-kill milestone, discovered secret and successful extraction/victory. One award per reason per run, maximum **3 per run**, saved bank maximum **12**; grants at a full bank/cap are declined. No dangerous-combat modal is opened. Results offer use-now/later; stored credits remain available from Home. Free credits are consumed before paid spins. Home only offers stored free credits; paid spins retain their existing eligible result/mode flow, three-spin cap and prices.

Saved receipts reject duplicate achievement grants and reward replays. A failed grant/debit save restores the bank; a failed free-spin reservation restores both data and RNG state. Delivery continues through existing inventory/progression receipt recovery. Every earned or paid spin adds one Spark; 12 Sparks earn one Crownroot fragment and 24 fragments unlock the existing RED forge. **RED is not a new random reel outcome**. Existing complete-drop/forge paths and odds are unchanged. Pool & Odds explains rewards, earned criteria/caps and RED semantics in a scrollable panel. Symbols sliding past are animation, not alternate reward rolls.

### Measured economy change

Baseline: zero earned-spin entitlement. Paid pool remains Common42%, Uncommon35%, Rare15%, Epic6%, Legendary2%. In 10,000 fresh independently seeded three-credit cohorts (30,000 rolls), counts were Common12,519 / Uncommon10,581 / Rare4,488 / Epic1,782 / Legendary630. No balance/damage/timing or paid odds were adjusted to improve tests.

| Additional reward from three earned credits | Mean | P10 | P50 | P90 | Observed max | Zero runs |
|---|---:|---:|---:|---:|---:|---:|
| Regional materials | 3.8988 | 0 | 4 | 8 | 21 | 1,283 |
| Mastery credited to actor and weapon | 6.3486 each | 0 | 6 | 12 | 18 | 2,677 |
| Recipe clues | 0.4488 | 0 | 0 | 1 | 3 | 6,111 |

These are base pool bundles for runs that earned all three credits, not an assertion that every run earns three or a simulation of every live account. Completed recipe clues convert to materials in the existing delivery system. No roll gives an empty reward; each of the three rolls also contributes a Spark. Long-term progression speed and reward satisfaction need S23 play feedback; caps constrain additive rewards without changing combat difficulty.

## Loading, combat feedback and branding

Removed fake imported-resource boot waiting (1.35s), title-to-Home travel (.48s), departure travel (.68s) and route-room travel (.42s). Imported local assets open their target screen directly. Zone changes keep their existing .85s spawn cadence and show a compact wave/region notice instead of a fake full-screen loading card. Real story/encounter telegraphs and combat clocks remain.

Impact changes add a restrained heavy arc, faceted glass shards/highlights and directional two-tone wooden splinters. Existing flame/frost/lightning/poison/corruption/arcane identity, metal/molten impacts, actual projectile origins, bounded effect counts and target-facing remain. Machine stop/reveal cues use existing documented sound families. No new licensed audio is substituted; all 456 documented PCM imports/license manifests are preserved. No-clipping or successful playback is not perceptual audio acceptance. Launcher/adaptive/monochrome icons remain the existing canonical brand; native title is captured and Android navy splash/resources are build-verified. Physical launcher/splash animation remains a device check.

## Validation and screenshots

[All major screens, both layouts and all six tier sequences](GALLERY.md); [142-image index with original PNG and committed JPEG hashes](capture-index.json). Original PNGs remain in the disposable capture folders; committed full-resolution JPEG94 images have no crop, recolour or enhancement. Overview sheets are navigation aids, not text-readability proof.

- Native 1080x2340 phone and 1200x1920 tablet: **51 captures each**. Title/Home/Patch/Sera/Ilex dialogue, Expeditions/region detail/Dungeons/Siege, Home shop/Gear/Shrine/Jobs/Archive, ATTACK and actual attack, merchant/perk/Relic comparisons, boss-find Keep/comparison, capped boosts/Leave, results/later, Home free engine, an actual free spin with unchanged Scrip/decremented credit, pool/odds and four animation states of each of Common/Uncommon/Rare/Epic/Legendary/RED.
- All tier previews say **FORCED TIER PREVIEW / no reward granted**. They prove presentation states, not natural jackpot occurrence. RED uses the existing Gravebloom Staff. The preview fixtures use staged bank/encounter inputs, and a nonlethal enemy HP value, not normal balance. Ordinary tier preview payloads are material stand-ins; actual useful pool types/distributions are tested separately. Actual free-spin dispatch uses normal reservation/recovery/reveal code. No final roster aesthetic acceptance is inferred from the one good authored Relic Beast heavy pose.
- Native impacts: **40 actual projectile landings** across phone1080x2340/tablet1600x2560, bow/staff/orb/sling, both real target relationships and seven explicitly labelled element overrides. Existing real target-facing logic is used, not the forced-facing flag. Frozen older impact comparison evidence remains preserved.
- Eight final automated fixtures pass with no script errors: combat_staging, mobile_gesture, phase4b, phase4e_feedback, phase4e_visible, rc_reward, rc_save, relic_spinner. Staging retains the 1,152 samples covering all12 actors/all12 families/both target facings/four phases. Gesture fixture covers360x640/480x1030/1200x1600, deliberate attack, drags, menus and return paths. Earned bank reload/caps/duplicate grant/recovery/save-failure rollback/RNG restore, optional boss-find/victory/Keep, current comparisons, unaffordable inspect, modal layering and direct title entry pass. Preserved scoped reward restart fixture also passed earlier in this tranche.
- Canonical freeze preflight: 11 frozen sources unchanged, five rejected boards excluded, 246 pose rows retained, **zero approved production boss frames**. Current valid imported bow/heavy assets and new compiled attack-control modules are verified inside the APK. There are no approved pending production bodies to integrate automatically from the conflicting reference boards.

## Android owner candidate

`C:\Users\Snkii\Documents\lootlings\builds\android\Lootlings-phase4e-visible-owner-debug.apk`

Version22 / `0.4.13-phase4e-visible-polish`; 137,151,670 bytes; SHA256 `c0c62b2244d1a468addc189052341444f98d0c4c3820762d38a4d3b682851b1f`. Signed arm64 debug; SDK24-36;16KB alignment; no app permissions. [Exact receipt](android-build-report.json). Prior v20/v21 APKs remain. Desktop captures are not proof of S23 FPS, thermal behaviour, Android safe insets or lifecycle acceptance.

Smallest S23 retest:
1. Install the new APK over the current app; do not uninstall. Open Home, Regions/Dungeons/Siege and Gear/shop; scroll and Back through them. Look for overlap or Back exposing the wrong screen.
2. Play one expedition. Tap ATTACK, drag menus and inspect then Keep/Skip a perk/item/merchant offer. A shop/menu touch must not create a combat attack or purchase. Watch both target facings, weapon contact and hurt/recovery.
3. After earning a boss/elite/milestone/secret/extraction credit, choose Later, reopen Home's Engine, spin once and check Scrip did not drop. Leave, background/resume, then close/reopen and check gear/remaining credits. Record visible clipping, freeze or wrong numbers; judge weapon/material/premium audio and machine feel. Natural Legendary/RED need not occur in this short retest; native forced evidence covers those states without changing odds.

## Exact remaining blockers / active queue

No replacement row is closed. [CANONICAL_REPLACEMENTS.md](../polish/CANONICAL_REPLACEMENTS.md), [per-asset deliveries](../polish/replacement-export-requests.json) and [export contract](../polish/ART_EXPORT_CONTRACT.md) remain the sole queue:52 asset rows plus current merchant supplement,165 support/paired cells (82right/83left). Reuse all working rigs, sockets, facing and timing.

- All7 Lootlings/all5 Wanderers: established-source transparent combat states in both target views; 512x512 RGBA where specified; idle/move/wind-up/strike-or-cast/follow-through/recovery/hurt/defeat/victory-return. Keep good authored heavy rows. Flat rejected fallbacks remain TEMP. Moonkip specifically needs the established hooded-rogue **weaponless** export. Gloomlet specifically needs the existing violet furry Assassin combat states; mushroom mage/foxlike body rejected. Glimmerfin's weaponless canonical idle is already retained.
- Hoard Dragon: established wingless/coiled purple/obsidian/gold body, **one redrawn continuous tail**, full silhouette, both views, named attacks/idle/hurt/recovery/defeat,2048x2048 RGBA complete-state delivery with existing pivots. Correct aspect/ground is retained; malformed source tail is **REPLACE**, never hidden or called fixed.
- Registered regional species and Verdant Mirror/Lantern Jackal/Belljaw/Drowned Engine/Furnace Regent/Redactor/The Unchosen/Chainwarden/Hollow Crown need exact existing-identity state exports. Intro art or procedural proxies are not articulated production states. No reference-board creature is silently promoted.
- Patch/Ilex/Sera/current Pack Peddler-Merrow role need canonical transparent rest/route/work/inspect/talk/sit layers fitting the existing activity/prop rig. Flat resident art visible in the Home screenshots remains a player-facing blocker.
- Separate NON-ART gates: full save semantic/cross-store/process-death acceptance beyond scoped receipts; perceptual audio/mastering; physical S23 performance/input/safe-area/background/process lifecycle; owner final visual acceptance, including machine premium quality. No final sound/visual sign-off from automated assertions.

## Multidisciplinary sign-off

PASS below is scoped only where no known blocker in that discipline's changed scope remains. It is not full Phase4E acceptance.

| Discipline | Status |
|---|---|
| DESIGN | ISSUES: implemented optional choices and earned loop; final reward feel/long-session pacing owner review open |
| BALANCE | PASS for unchanged combat values/timing and preserved geometry contracts; no new full balance claim |
| ECONOMY | ISSUES: atomic/capped free rewards measured and scoped tests pass; long-term additive progression acceptance open |
| ROSTER | ISSUES: canonical combat packages/165 support cells remain |
| ENEMIES | ISSUES: registered canonical replacement species remain |
| BOSSES | ISSUES: Dragon source-tail and distinct articulated packages remain |
| RNG | PASS for unchanged paid pool, isolated reward RNG and measured seeded distribution; no random RED added |
| UI/UX | ISSUES: phone/tablet scoped corrections pass; physical touch/safe-inset/owner acceptance open |
| NARRATIVE | PASS for preserved frozen canon/contextual voices and clearer changed instructions; no new entire-string audit claim |
| AUDIO | ISSUES: existing documented assets/cue routing preserved; perceptual weight/material/element/boss/premium acceptance open |
| MOBILE | ISSUES: signed current APK/native layouts pass; physical S23 FPS/lifecycle/input unproven |
| QA | ISSUES: scoped automated/native checks pass; outstanding owner/art/device/save acceptance gates |
| PRODUCTION | ISSUES: implementation and separate QA checkpoint/back-up ready; full Phase4E HOLD, no Phase4F |
