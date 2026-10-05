# Approved replacement delivery contract

This is the delivery specification for the existing CANONICAL_REPLACEMENTS.md queue, not an alternative queue or approval of TEMP art. No replacement package is currently approved/imported by this continuation. Concept boards and portrait crops cannot close a combat-body entry.

## Playable actors

Each of the exact 12 actor IDs in the register needs transparent, weaponless full-body PNG exports. Keep canonical anatomy, outfit, species and lighting. Moonkip must have the baked daggers actually removed/redrawn by the artist; do not erase hands or cover the weapons. Gloomlet must match its approved canonical sheet/idle, not combat_rigs/gloomlet.svg. Glimmerfin already has a weaponless idle.

Canvas: creatures 512 × 512; Wanderers 1024 × 1536; Relic Beast greatsword exports retain their existing 1280 × 1280 canvas. PNG RGBA with transparent background, straight alpha, no baked floor shadow/VFX or equipped weapon. Every export in a stance has the same canvas, pivot and planted baseline. Higher-resolution sources may be retained separately; do not resize existing good authored exports merely to meet a new canvas.

Both left and right views. For each required weapon group: READY/idle, WINDUP, RELEASE/strike/cast, RECOVER, HURT, movement, defeat and victory/return. Deliver only actual needed combinations from support-art-debt.json plus deficient one-hand/body entries; share a stance only where grip and silhouette genuinely work. The 165 count is cells, not a request for 165 unrelated character designs.

Follow art/production_pose_manifest.json for normalized primary_anchor, secondary_anchor, core_anchor, body_rect, feet_baseline, draw_depth, facing, weapon_types and weapon_overrides. Existing good row coordinates are authoritative for their exports. Include a transparent foreground hand layer when the grip passes behind fingers. Paired weapons need distinct palm anchors and an alternating lead-hand RELEASE. Bow needs supporting palm on the grip and draw fingers at the existing string nock; crossbow needs stock/support contact. Staff needs two actual palms on shaft; orb needs palm-driven cast and release; sling needs pouch/string clearance. Do not bake a separate weapon into a weaponless body.

Preserve existing attack clocks: art samples current IDLE/ANTICIPATE/ATTACK/IMPACT/RECOVER/HURT phases. Manifest WINDUP routes to ANTICIPATE; STRIKE/CAST route to ATTACK. READY/RELEASE remain the required baseline pair, with optional authored phases overriding only where approved exports exist. Movement/defeat/victory exports still require their own explicit integration and native review; no new actor states are implied by a request. Art cannot add damage delay or change strike cadence. Right art may mirror only when canonical accessories/anatomy permit it; explicit left art preserves its own anchors. Runtime rig/socket logic remains reusable.

## Regional enemies and bosses

Every named regional row needs its own approved species/body; the current shared body is only a timing/socket reference. Regional exports: 1024 × 1024 RGBA PNG; boss exports: 2048 × 2048 RGBA PNG (keep already-good source resolution if replacing only articulated states). Full uncropped silhouette with room for limbs, wings and tail; consistent canvas/pivot/baseline across idle, windup, commit, hurt, recovery and defeat, both facings. Hovering species retain hover baseline; grounded species retain foot baseline. Atlas delivery must include exact region/encounter ID and frame rectangles, never infer names from image labels.

Boss action states are the exact calls in boss_patterns.gd PATTERNS: include the windup, commit and recovery of each distinct call, plus vulnerable/recovery action, phase transition, hurt and defeat. Intro/portrait and combat identity must match. Do not turn Furnace Regent into a generic golem, Verdant Mirror into another guardian, or Hollow Crown into a dragon clone.

Hoard Dragon requires a real replacement/redraw of the malformed/double-reading source tail, including hip connection, continuous taper, overlap depth and silhouette. Provide idle, claws, brace, coin breath, tail sweep, recovery, hurt and defeat; both views and close tail crops for approval. Keep proportional renderer fit. Squash, crop or effects cannot count as tail replacement.

Elite overlays must fit each species without extra limbs: existing eleven modifier IDs in the register. Named/miniboss variants retain encounter IDs and their actual role; deliver E states rather than inventing another species.

## Current NPCs

Patch, Ilex and Sera: 1024 × 1536 RGBA full-body exports, same canvas/baseline, both route facings; rest, walk/route, work/read/tend, inspect, talk and sit. Separate repair hammer, book and relic props with exact palm contact metadata. Existing resident routes/activity clocks/dialogue ownership remain. Pack Peddler/Merrow: same export size, rest, talk, offer, inspect and return; merchant role remains its current implemented role, not a new Home resident. Current portrait, written canon and IDs constrain identity. Future NPCs are excluded.

## Delivery and acceptance

Supply source provenance/licence, approval reference, actor/region ID, state/view list and normalized socket manifest with each package. Import only approved rows, preserve good existing poses, native-review beside portrait/environment/enemy/boss on phone and tablet, and compare both facings and real target-driven transitions. Contact/RNG tests cannot approve the artwork. Missing packages remain TEMP/BETA and owner acceptance remains explicit.

### Canon freeze and approved boss-frame adapter (2026-10-06)

Read `art/reference/phase4e_handoff/REFERENCE_REJECTED_IDENTITY_DRIFT.md` before using the new handoff. Its boards are excluded from body integration. Existing sheets/designs remain the production source; no whole-body reinterpretation or masked board sprite can close this contract.

`tools/validate_canonical_art.py` now runs before Android export. It checks frozen sources, preserved authored pose assets, rejected reference paths/hashes, and provenance/explicit owner approval for new or changed production rows. It is an integrity guard, not an aesthetic approval service.

`art/production_boss_manifest.json` is deliberately empty until proper approved exports arrive. Each approved row needs `region` (existing boss region ID), `state` (`idle`, `windup`, `commit`, `hurt`, `recovery`, `defeat`), exact named `action` for windup/commit (empty for other states), `facing` (`left`/`right`), `asset_path` under `res://art/sprites/enemies/approved/`, `canvas`, normalized `anchor`, `source_reference`, `source_sha256`, `asset_sha256`, `owner_approval` and `production_status: owner_approved_beta`. Owner approval must be real evidence, never invented boilerplate. Full transparent exports preserve the existing display bounds/baseline and their source aspect; explicit facings are not mirrored. Missing/unapproved states retain the existing TEMP source. Existing recovery/hurt/defeat/action clocks choose the frame; no combat timing, RNG or balance changes. Approved full-body frames omit old procedural identity attachments so those cannot create doubled anatomy. Native acceptance of each actual delivered frame remains outstanding.

Godot's [ResourceLoader documentation](https://docs.godotengine.org/en/stable/classes/class_resourceloader.html) specifies imported resources for texture loading and separate inclusion of non-resource files. The adapter uses imported texture resources; both export presets explicitly include the JSON manifest and exclude all reference boards. The Android package was inspected for those inclusions/exclusions.
