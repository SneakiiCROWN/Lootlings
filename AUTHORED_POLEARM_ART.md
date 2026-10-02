# Authored adult polearm fit tranche

Five adults × Spear × READY/RELEASE × both facings = twenty new real native 480×854 states. Accepted original two-hand braced body exports are reused directly through the existing manifest (no copied bodies or generated limbs). Actual primary/support hands meet uninterrupted leather/wood shaft; back weapon depth preserves torso/head/hair occlusion, left exports preserve asymmetric wardrobe. Guard-to-forward-thrust action uses the existing Vanguard anticipation/follow-through/recovery/hurt root transforms. This is a compact two-painting beta action, not a skeletal rig or full polearm choreography.

## Separate held art / provenance

Original diagonal `art/sprites/weapons/spear_held.png` remains intact for fallback/inventory. Selected image-tool edit exec-8569cf85-24dc-4d73-9976-7798a44cbd21.png uses that original Lootlings Ruin Pike / halberd as identity reference. One candidate. Preserves silver/blue swept blade, engraved dark navy/gold head, blue crystal/ribbons and wine cloth, adds the practical straight continuous shaft demanded by actual grip fitting.

Unmodified 1280² RGBA source: `art/source/held_spear_v1/spear_held.png`.
Mechanical 512² RGBA runtime: `art/sprites/weapons/stances/spear_held.png`.
Shared exporter: `tools/export_authored_staff.gd -- --spear` (default remains Staff). No third-party source/audio or canonical-board replacement. Body source prompts remain in `AUTHORED_HEAVY_ART.md` / `OPPOSITE_HEAVY_ART.md`.

Exact selected built-in prompt:

```text
Use case: precise-object-edit. Input image is original Lootlings Ruin Pike / halberd weapon identity reference; create a SEPARATE combat held export, do not replace inventory/source. One upright centered polearm on genuinely transparent 1024x1024 RGBA canvas. Preserve its narrow swept silver/blue spear blade, gold dark navy engraved head, brilliant blue crystal, small blue energy ribbons and wine-purple cloth tassel close to head. Same premium painted Lootlings fantasy style. Head centered x=.50, tip y=.04, blade/head occupy y=.04-.33 and x=.30-.70. Extend a straight SLIM leather/dark wood shaft vertically x=.50 to y=.94. Uninterrupted wood/leather grip area from y=.43 through .88: no gems, ornamental collars, ribbons or spikes crossing hand-contact stretch. Tiny pointed gold bottom endcap. Shaft must read long and plausible, not a short decorated knife. Orthographic flat cutout, no diagonal perspective, no cast glow halo, no person/hand, no text/shadow/background/watermark. Keep original gold/blue/purple material identity and aggressive pike silhouette, do not create another weapon family.
```

Per-row polearm metadata: 104×154 held rectangle, primary (.49,.74), secondary Y from real hand distance / 154, socket (.49,.04), explicit BACK depth and unchanged body anchors/wardrobe requirements. Runtime two-anchor solver places shaft contact exactly; test also samples alpha at BOTH held grip pixels, rejecting mathematically attached but transparent air grips. Each existing heavy/staff grip passes this additional audit too.

## QA / current matrix

Native OpenGL: 100 heavy/Staff/Spear READY/RELEASE states captured and visually inspected as five sheets plus selected full-size head/shaft/edge views; five real Staff flight captures retained. No visible face piercing, floating support grip or Spear tip clipping in the accepted matrix. Native actor spacing unchanged. Left remains a fitting preview, not a new left-target combat mode.

Parser/import and twenty regression entrypoints passed on independent APPDATA directories: smoke, Wanderer migration/profile/inventory, fit, authored pose + real Staff flight/held alpha, wardrobe, weapon runs, evolution, encounters/AoE, dungeon, campaign, canonical world, item art, chest, contract, presentation, vignette, resident, audio, balance, expansion. Smoke 2/5; balance 22/96 unchanged. Twelve weapon families, seven Lootlings/Gloomlet stand-in, fifty wardrobe contracts, Forge/equipment/save/campaign and RNG separation preserved.

Manifest 246 unique rows, 60 authored rows, twenty unique shared body textures. Full actor/family/facing/phase matrix remains 864 checks. **83 support-hand/paired combinations remain per facing / 166 facing-specific cells.** Remaining exact packs: creature-specific heavy/Staff/polearm natural paw/brace/mount/channel in both facings; all bow draw/release, crossbow support/trigger, dual dagger/claw pairs, real Sling and clean weaponless creature exports. Standalone canonical Gloomlet remains required; temporary selectable stand-in is unchanged. Neutral single-hand fallbacks are not claimed as completed action paintings. Further wardrobe/world/UI tranches stay behind fit closure.

One additional cached 512² held texture (~1 MiB raw RGBA before driver/compression overhead), no duplicate body texture files, new runtime nodes/shaders/particles/per-frame work. No gameplay/economy/cadence/damage/projectile-lifetime/drop/RNG/save or evolution behaviour changes. Evolution appearance for authored packs still uses this family held export plus existing evolution overlays; separate final stage paintings remain an art task, not falsely complete. Desktop NVIDIA native QA does not certify low-end Android battery/performance.

