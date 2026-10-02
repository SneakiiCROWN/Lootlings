# Weapon / actor fit contract

## Shipped correction (not finished articulated animation)

**Current authored extension:** five adult heavy READY/RELEASE pairs and dedicated greatsword/greataxe/maul held exports now override the neutral mapping below for right-facing combat. `art/production_pose_manifest.json` is authoritative for authored rectangles, measured anchors, phase/depth/compatibility/status. Thirty native phase states accepted; 93 support-hand-incomplete right-facing combinations remain. Opposite-facing authored bodies remain required and explicitly fall back. The older neutral tables below remain fallback/export-planning context, not current heavy-pack status. See `AUTHORED_HEAVY_ART.md`.

One `weapon_fit_catalog.gd` now resolves every active playable body and held weapon. `wanderer_pose_catalog.gd` is a compatibility facade, not a second pose implementation. The active renderer and projectile launches use the same root, squash/recoil, hand, texture grip, weapon mirror, rotation and socket. Gameplay damage, interval, projectile lifetime, evolution, rarity, loot, economy, saves and RNG are unchanged.

All five adult presets and all seven Lootlings remain selectable. Exact canonical bodies and accepted artwork are unchanged. Gloomlet retains the explicitly documented tinted neutral stand-in and its matching anatomy.

### Body mapping

| Actor | Profile/category | Handling limitation |
|---|---|---|
| Vault Runner | athletic | Neutral lowered hands; no authored support-hand stance |
| Ruin Warden | broad, narrower authored bounds | Same; existing silhouette preserved |
| Nightstage Drifter | athletic, own primary/secondary anchors | Same |
| Velvet Astrologer | curvy, own anchors | Same |
| Ashtrail Hunter | muscular, own anchors | Same |
| Relic Beast | chunky biped | Canonical paw and chest Core anchors |
| Emberhorn | small biped | Own paws/bounds/Core |
| Mosskin | shielded biped | Exposed left paw; outward heavy stance protects face/shield |
| Moonkip | small biped | Daggers baked into body: weaponless variant required |
| Pebblewyrm | heavy brute | Own squat rocky anatomy |
| Glimmerfin | floating | Small wand detail baked into body; weaponless variant needed |
| Gloomlet | chunky biped stand-in | Clean canonical runtime body still required |

Human light/heavy categories are also supported for future authored bodies; they are not new playable presets. Secondary anchors describe neutral hands/paws, **not** a claim they contact a weapon. Future authored exports must remeasure them. Creature `LootlingCatalog.pose_profile` is now consumed rather than ignored.

### Twelve-family mapping

Normalized primary grip/socket values and sizes are in `GEOMETRY`; secondary grips and phase angles in `STANCES`. All families have an explicit ready/release transform, world origin, bounded size, facing rule and front/back layer contract.

| Family | Stance | Handling | Current art status |
|---|---|---|---|
| Greatsword | heavy_two_hand | Two-hand | Visible handle corrected; clean held export/stance needed |
| Greataxe | heavy_two_hand | Two-hand | Handle corrected; low-resolution/clipped held export needed |
| Maul | heavy_two_hand | Two-hand | Real shaft grip corrected; support-hand pose needed |
| Spear / Halberd | polearm | Two-hand | Support-hand stance and cleaner held export needed |
| Twin Daggers | dual_wield | Paired | Combined item bitmap; separate left/right held blades needed |
| Claws / Gauntlets | dual_wield | Paired | Wrist grip corrected; separate left/right wearable art needed |
| Bow | bow | Two-hand | Draw-hand stance needed; socket follows bow |
| Crossbow | crossbow | Two-hand | Bitmap muzzle mirror and socket corrected; support stance needed |
| Relic Sling | one_hand | Special | Existing bow stand-in retained, real sling export still required |
| Staff | staff | Two-hand | Shaft grip/socket corrected; support-hand stance needed |
| Wand | wand | One-hand | Grip/socket corrected; cleaner held export recommended |
| Orb / Focus | orb | Levitated | Deliberate detached focus, not a floating failed hand grip |

**108 of 144 actor/family combinations still require authored second-hand/paired art.** These are development QA art failures, not visual passes. Wand/Orb do not require a second hand; Sling is not considered art-complete. Static lowered hands cannot be honestly transformed into bow draws or heavy two-hand grips. No invented arms, painted replacement mascot or feature removal was used.

### Authored asset integration

`register_stance(actor_id, group, data)` supports:
- actual Texture2D body export, body_rect, primary_hand, secondary_hand (body-local units);
- `supports_two_hand` only when real art contains the relevant grip pose;
- `depth` front/back and optional transparent full-body-aligned `foreground` hand/wardrobe layer;
- keyed `phase_variants` using ActionPoseCatalog phases, premerged at registration;
- optional body_lean/body_offset and per-family `weapon_overrides` (size/grip/socket/angle/mirror);
- `wardrobe_requires` component IDs; incompatible baked wardrobe falls back to the safe neutral body.

Two-anchor solving aligns the authored hand span to the weapon span only within 0.75–1.25 scale tolerance and 149×179 held bounds. It does not fabricate a second hand when unsupported. Neutral/one-hand/heavy/polearm/dual/bow/crossbow/staff/wand/orb stance groups are supported. Current wardrobe remains baked; no false independent layers or cosmetic stat effects.

`WeaponCatalog.presentation_texture` separates held/inventory/projectile roles; held evolution exports remain `<family>_stage1_held.png` / stage2. Active held rendering uses this API. Existing inventory/projectile rendering and textures remain unchanged; optional separate exports must be deliberately wired at their consumers when supplied. No false claim that a new projectile pack exists.

## Exact production exports still needed

Preserve approved identities/designs and existing source files. All bodies/foreground layers RGBA transparent; feet/bounds registered to neutral, no weapons baked into body. No new animation pipeline required.

1. For each of five adults + six real creature bodies: `art/sprites/poses/<actor_id>/<stance>_<phase>.png`.
   - Adults 1024×1536 (2:3); creatures 512×512 (1:1); Relic Beast 1280×1280.
   - First batch: heavy_two_hand ready/release, bow ready/release, crossbow ready/release, polearm ready/release, staff ready/release; then dual_wield.
   - Same original faces, anatomy, gear and palette; only believable authored body/arm poses. Include primary/secondary anchor metadata per export.
   - Optional `<stance>_<phase>_foreground.png`, same canvas/alignment, containing only real foreground hands/wardrobe occlusion.
2. `art/sprites/lootlings/gloomlet_idle.png`: 512×512 RGBA clean standalone canonical Gloomlet, followed by same stance exports. Stand-in stays selectable until valid.
3. Moonkip/Glimmerfin weaponless neutral exports, same dimensions/identity as current bodies, separately authored (no destructive erasure of canonical source).
4. `art/sprites/weapons/{greatsword,greataxe,spear,wand}_held.png`: replaceable clean 512×512 RGBA export; complete silhouette without clipped blade/ornament, clear shaft/handle and consistent side-facing perspective.
5. `daggers_left_held.png`, `daggers_right_held.png`, `claws_left_held.png`, `claws_right_held.png`: 512×512 RGBA independent grips, not a two-item inventory cluster. Consumer/stance override hook must bind each actual hand; current single bitmap remains explicitly incomplete.
6. `sling_held.png`: 512×512 RGBA approved Relic Sling with visible pouch/grip/release socket; replace documented bow stand-in.
7. Optional separate `<family>_inventory.png`, `<family>_projectile.png` and evolution held exports where approved designs genuinely differ. Do not duplicate textures merely to satisfy naming.

## QA / repeatability

Debug-build-only view:
`Godot --path . --rendering-method gl_compatibility --resolution 480x854 --script tests/weapon_fit_qa.gd -- --interactive`

Up/down actors, left/right families, hold F mirrored facing, hold Space release. This is a facing/pose preview, **not a new leftward combat mode**. Labels show missing authored support art. It is not attached to the production scene.

Headless matrix: same script without user flags. Native capture matrix: `-- --visual`. Captures go only into ignored `.godot_test_data/`, never production art.

144 actor/family combinations; 864 facing/phase transform assertions; real release launches for ranged families; stat/gameplay/loot RNG isolation; authored two-anchor solver and invalid registration checks. Native matrix captures 144 idle screens + 96 heavy/bow/crossbow/staff release/mirror screens at actual 480×854. All twelve actor contact sheets inspected; worst full-screen examples inspected. Corrected greatsword/axe/maul/wand/claw/staff grips, backwards crossbow/muzzle socket, creature root/weapon drift, creature recoil/socket sampling order, Mosskin heavy-head collision. Bow/Sling bitmap reuse, baked creature gear and absent two-hand poses are explicit production blockers.

Bounded cached body/texture metadata, no new runtime nodes/shaders/particles, same four-edge actor outline and one held draw. Native desktop QA is not Android hardware or final anatomical-pose certification.
