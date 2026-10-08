# Minimum complete launch Home systems

Owner has authorised these practical production decisions. No canon redesign and no runtime changes in this task.

## Catalogue and placements

Six free built-in decoration IDs: home_companion_cushion, home_companion_ledge, home_trophy, home_plans, home_banner, home_lantern. Four existing approved sprites reused byte-identically; only cushion and ledge need new transparent body/front-layer exports plus measured metadata. No new decor economy or item consumption. Placement is bounded discrete-slot swap/remove, not arbitrary free transforms. Exact original image dimensions, alpha bounds, pivots, mounts, design footprints, filenames and paths are in HOME_LAUNCH_DECOR_CATALOGUE.json and master file records.

Five slots at480x854: floor contact(92,594), wall ledge contact(374,412), display bottom(386,337), banner top(103,181), lantern top(388,165). Full background1536x2732 uses x*3.2 and y*2732/854. Clear these mount zones; movable objects never baked into the background. Companion following pivot(110,602) replaces crowding at the footer. Player ground remains(240,570), display item legacy binding preserved.

## Companion interactions

All6 retain their exact identity and cosmetic status. Four grounded companions dock only to the cushion; Lunarwisp/Breezewyn may also hover at the ledge. Each gets perch_rest and perch_interact in both views,256x256RGBA, bounds[32,24,224,224], pivot/contact reference[128,224],56px design size. New states are distinct from standing idle/reaction. Hover reference is not fake feet. Dock/undock uses approved move state; grounded pets never teleport/jump to ledge. One selected pet; Perch/Follow toggles, deliberate Greet triggers0.9sec exact companion interaction then rest.

Reuse each existing canonical unlock image as a20px separate prop: Sunfeather Relic, Terrastone Core, Shadowflame Ember, Moonlantern Shard, Bloomnest Seed, Skybell Orbit. Never bake props, shadows or temporal FX into bodies. Open-paw/nose/hover gestures avoid need for new closed-grip foreground layers. Actual gesture anchors still measured after art. No rewards/stats/RNG change.

## Safe editing and persistence

Personal Displays provides existing styled Decor panel: choose item→compatible slot→Place/Remove preview→Apply/Cancel. Tap-vs-drag safety and gesture-release ownership remain. Back cancels draft before clean Home/Hub return. Reset affects layout only; selection/inventory untouched. Slots, safe hit rectangles, render ordering and phone/tablet acceptance are in HOME_PLACEMENT_METADATA.json and HOME_MOBILE_ACCEPTANCE.json. No new UI image sheets.

Stable save root profile.homestead.home_layout version1 stores slot→decor IDs, follow/perch mode and perch slot. Existing profile.homestead.display, companion selection/ownership/accompany retained. Defaults and legacy migration specified in HOME_PERSISTENCE_CONTRACT.json. Remove occupied perch returns pet to follow; invalid IDs sanitise locally. One atomic Apply save; no draft positions or reaction timers persisted. Current sanitizer and state selector need explicit future integration; specification is not implementation.

## Acceptance

All6×2perch states×2facings native-reviewed; real contact/hover/cushion/ledge depth correct; props complete after removal. No new identity, clipping or UI overlap. Phone1080x2340/tablet1200x1920 use current logical safe-area fit; uniform cover background is independent of control hitboxes. Save/reload, old-save migration, edit Cancel, reset/remove occupied perch, companion change, no-state gating and Back/Leave must pass. Existing six-state follower availability gate retained; new four-state perch gate additional. Main Hub and Home stay separate.
