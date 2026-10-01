# Art and Asset Production Manifest

This is a production queue, not a claim that the assets exist.

## Folder rules

```
art/sprites/lootlings/
art/sprites/wanderers/
art/sprites/npcs/
art/sprites/enemies/
art/sprites/bosses/
art/sprites/weapons/
art/sprites/items/
art/sprites/rewards/
art/backgrounds/regions/
art/ui/
art/vfx/
art/reference/
```

Never place final runtime art inside `art/reference/`.

## Priority 0 — preserve
- canonical Relic Beast
- delivered Phase 1 UI assets
- Wave 2 iconography
- existing approved beta exports until replaced cleanly
- source boards and provenance files

## Priority 1 — canonical Lootling finals
For each:
- Emberhorn
- Mosskin
- Moonkip
- Pebblewyrm
- Glimmerfin
- Gloomlet

Need:
- transparent 1024×1024 idle, weaponless
- clean attachment-safe hands/paws
- portrait crop
- selector crop
- optional attack pose sheet later
- no board labels/neighbours
- exact approved identity

## Priority 2 — humanoid beta kit
First wave:
- 4 body-frame base sets
- 8 faces
- 12 hairstyles
- 10 skin-tone palettes
- 5 lineage accent kits
- 4 outfit families × practical/glamorous/revealing variants
- front/back arm pose layers for all 12 weapon families
- 6 jewellery pieces
- 6 markings/scars
- 5 horn/ear accessories

Do not generate a single fixed humanoid and call it customisation.

## Priority 3 — weapons
For every family:
- held base
- stage1
- stage2
- projectile if applicable
- inventory portrait if needed
- impact effect
- grip metadata

Specific missing concern from existing provenance: Relic Sling needs a genuine sling rather than a flail substitute.

## Priority 4 — NPCs
Final art:
- Patch Brasswick
- Ilex Quill
- Sera Vey
- Merrow Vane
Then planned:
- Nessa Vale
- Corvin Ash
- Vesper Thread
- Rook Marr
- Tamsin Coil
- Edda Sable
- Brother Kelm
- Pippa Voss

Each named NPC: bust portrait + full-body hub sprite before elaborate alternate outfits.

## Priority 5 — region enemies/bosses
Do not substitute unrelated board creatures merely because they are visually cool.
Each boss needs a dedicated identity matching story contract.

Known beta boss art currently documented:
- Verdant Mirror
- Furnace Regent

Production queue:
- Lantern Jackal
- Belljaw
- Drowned Engine
- Redactor
- Unchosen
- Chainwarden
- Hollow Crown
- final/clean Verdant Mirror
- final/clean Furnace Regent

Act I existing bosses remain their own art line.

## Priority 6 — items
Map dedicated art to existing item IDs first.
High-value named items:
- Scrapfang Blade
- Mimic Mallet
- Bonebow
- Glimmerstaff
- Moonbite Daggers
- Mossguard Harness
- Ironpaw Plate
- Hoarder's Locket
- Definitely Not Cursed Ring
- Ember Pop Rune
- Stormspark Rune
- Toxic Burst Rune
- Ground Slam Rune
- Vault Receipt
- Bossbane Sigil

Then expand through all existing bases.

## Priority 7 — chests / physical rewards
For each chest:
- closed
- anticipation
- opening
- opened
- glow/burst mask
- shadow/contact
- item eject socket

Stable IDs:
- scavenged_cache
- relic_chest
- hoard_chest

## Priority 8 — environments
Final high-res art for all ten campaign entries. Avoid flat recolours being sold as unique regions.

## Naming convention

Characters:
`<id>_<pose>_<variant>.png`

Weapons:
`<family>_stage0_held.png`
`<family>_stage1_held.png`
`<family>_stage2_held.png`

NPC:
`<npc_id>_portrait.png`
`<npc_id>_hub_idle.png`

Boss:
`<boss_id>_idle.png`
`<boss_id>_attack.png`

UI:
descriptive semantic names, never download UUIDs.

## Visual QA before runtime
- transparent edge clean at 1× and phone scale;
- no baked text unless intentionally part of world prop;
- no neighbour fragments;
- weapon facing correct;
- hands/grips plausible;
- no face obstruction in idle;
- silhouette readable against dark and bright region backgrounds;
- source and derivation documented.
