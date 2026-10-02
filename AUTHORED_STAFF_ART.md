# Authored adult Staff fit tranche

## Shipped presentation

Five adults (vault_runner, ruin_warden, nightstage_drifter, velvet_astrologer, ashtrail_hunter) now use genuine two-hand braced Staff READY/RELEASE poses in both facings. Reuses the twenty accepted heavy-body textures directly: arms/hands/wardrobe are painted, not stretched limbs or duplicate files. Existing Mage anticipation, recoil/hurt/reward root motion remains. A braced forward cast is appropriate for these exports; this is not a claim of a new ground-planted staff pose, skeletal animation, or every casting in-between.

The separate held export preserves the existing Glimmerstaff's gold ring/crescent, blue vortex/crystal, wood/leather and close-head cloth/trinkets. Inventory `mage_staff.png` is unchanged. Source `art/source/held_staff_v1/staff_held.png` is 1280×1280 RGBA; runtime `art/sprites/weapons/stances/staff_held.png` is 512×512 RGBA, mechanically resized by `tools/export_authored_staff.gd`. Originals/canonical boards retained.

Manifest records staff-specific size 104×144, primary grip (.49,.80), secondary grip calculated from each body's measured hand span, and release socket (.49,.20). Real two-hand solver keeps both contacts. Body/back-weapon depth protects face/hair; left body exports retain asymmetry with no blind flip. Initial 112×170 fitting clipped Hunter's left head at the viewport edge; corrected to 104×144 and re-rendered, not accepted merely from a math check.

## Provenance / exact selected prompt

Image tool edit used existing original runtime Glimmerstaff as the weapon identity reference. Selected tool output exec-62b06ce8-3dfe-4ae2-b63d-3578933b05bd.png, one candidate, preserved unmodified in source. No third-party asset/audio added.

```text
Use case: precise-object-edit. Input is original Lootlings Glimmerstaff design reference. Create its SEPARATE HELD/combat export, not an inventory icon or redesign. One upright staff centered on transparent 1024x1024 RGBA canvas. Preserve gold crescent/ring head, glowing cyan/blue vortex gem, blue crystal points, leather-wrapped dark wood, small gold trinkets and cloth accents. Composition: head/vortex at normalized(.50,.20), head spans x .28 to .72 and y .03 to .36. Shaft straight vertical at x=.50, length down to y=.94. At y=.48 through .86 give an uninterrupted slim leather/wood grip area, no crystal collars/trinkets/cloth crossing this two-hand grip stretch. Trinkets stay close to head, tiny bottom endcap. No perspective diagonal, no handle curve, no fists/person, no cast spell trail or big glow halo. Premium painted Lootlings fantasy finish, readable gold/purple/cyan, original weapon identity. No text/background/shadow/watermark. Exact centered continuous shaft allows a real measured two-hand hold.
```

Body lineage/prompt/occlusion limits are retained in `AUTHORED_HEAVY_ART.md` and `OPPOSITE_HEAVY_ART.md`; the manifest explicitly marks shared braced casting reuse.

## Validation / limits

Parser/import and twenty regression entrypoints passed: smoke, Wanderer migration/save/inventory, full weapon fit, authored poses/real staff flight, fifty wardrobe contracts, seven weapon runs, twelve-family evolution, bounded encounters/AoE, dungeon routes, campaign, canonical roster/Gloomlet, item/chest/contracts/presentation/vignette/resident/audio, deterministic balance and Forge/campaign migration. Smoke remains 2/5 victories and 96-run audit remains 22 wins. Per-test APPDATA is isolated. Native runtime finished without parser/runtime errors.

Native OpenGL 480×854: 80 READY/RELEASE states (previous 60 heavy + 20 staff) captured and visually inspected in five sheets and selected full-size edge/face/grip views. Five real rightward projectile-flight views captured and inspected. Launch uses transformed staff-head socket; QA proves enemy HP does not change during flight and damage resolves at arrival. Left is a fit preview, not a new leftward gameplay/targeting mode.

236 unique manifest rows, 40 authored rows, twenty unique body textures. Full 144 actor/family matrix = 864 facing/phase assertions. Pending support-hand/paired art is now **88 combinations per facing / 176 facing-specific cells**, not final completed artwork. Seven creatures still need their own natural paw/brace/mount/channel heavy/staff treatment; polearm/bow/crossbow/dual across roster, real paired/Sling/weaponless and standalone Gloomlet remain required. Neutral single-hand fallback is not a finished action pack. Fifty wardrobe contracts unchanged; no nonexistent cosmetics enabled.

No gameplay damage/cadence/projectile-lifetime/RNG/evolution/economy/drop/save changes. One active four-body pack is reused rather than copied; held runtime adds ~1 MiB raw RGBA before driver/compression overhead. No new per-frame processing/nodes/shaders/particles. Android hardware/battery measurements remain outstanding.
