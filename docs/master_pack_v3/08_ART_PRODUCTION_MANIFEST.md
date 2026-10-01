# ART PRODUCTION MANIFEST

## General
All production exports:
- original Lootlings visual language;
- no copied external characters/logos/UI;
- sRGB PNG;
- clean alpha where transparent;
- no baked labels unless the asset is intentionally a wordmark;
- preserve source/reference/provenance records;
- final runtime uses individual assets, not giant board sheets.

## Canonical Lootlings
Final neutral/idle:
art/sprites/lootlings/<id>_idle.png
1024×1024 transparent.

Required remaining priority:
gloomlet_idle.png
and high-resolution weaponless replacements for Emberhorn, Mosskin, Moonkip, Pebblewyrm, Glimmerfin.

Optional later:
<id>_attack.png
<id>_hurt.png
<id>_victory.png

## Adult humanoid player bodies
Neutral weaponless full body:
art/sprites/humanoids/<origin_id>/body_<frame>.png
Suggested source canvas: 1024×1536 transparent.
Feet aligned to shared baseline.
Hands visible and separable from torso.
No baked weapon.

Portrait:
art/sprites/humanoids/<origin_id>/portrait.png
768×768 or larger transparent/clean bust.

Optional authored action pose:
attack_heavy
attack_dual
attack_ranged
cast
hurt
victory
These supplement, not bypass, runtime socket fitting.

## Layered customisation
Hair:
art/cosmetics/humanoid/hair/<hair_id>.png

Facial hair:
art/cosmetics/humanoid/facial_hair/<id>.png

Outfit:
art/cosmetics/humanoid/outfits/<outfit_id>/<slot>.png

Jewellery/accessory:
art/cosmetics/humanoid/accessories/<id>.png

Dyes should be mask-driven where practical instead of exporting every colour permutation.

## NPCs
Portrait:
art/sprites/npcs/<npc_id>_portrait.png
768×960 recommended.

World body if needed:
art/sprites/npcs/<npc_id>_body.png
1024×1536 transparent.

Current beta portraits for Patch/Sera/Ilex may stay until replacements exist.

## Weapons
Held:
art/sprites/weapons/<weapon_type>_held.png
1024×1024 transparent.
Grip toward left/actor; attack direction toward right by default unless renderer handles mirroring.
No detached neighbouring props.

Priority production gap:
sling_held.png

Evolution art:
art/sprites/weapons/evolved/<weapon_type>_stage1.png
art/sprites/weapons/evolved/<weapon_type>_stage2.png
Only ship when the named evolution is actually reachable.

## Chests
art/sprites/rewards/scavenged_chest_closed.png
art/sprites/rewards/scavenged_chest_open.png
art/sprites/rewards/relic_chest_closed.png
art/sprites/rewards/relic_chest_open.png

Optional anticipation/glow layers separate.
Do not fake an open frame by slicing one painting.

## Items
Final per-base art:
art/sprites/items/<item_id>.png
512×512 transparent minimum, preferably 1024×1024 source.

Use category art only as fallback.
Existing beta mappings do not imply new gameplay.

## Environments
Final portrait environment:
art/backgrounds/regions/<region_id>.png
Recommended master: 1440×2562 (3× the 480×854 target).
Keep character-safe centre/lower floor readability.
Distinct composition, not simple recolour.

## UI
Keep delivered Foundation/Wave 2 assets unless replacing intentionally.
New character creator needs:
- portrait socket frame
- body/face tab icons
- hair tab icon
- outfit tab icon
- dye swatches
- accessory tab icon
- randomise icon
- undo/reset icon
- save/confirm states
All must inherit current gold/purple/cyan material language.

## Production replacement order
1. Gloomlet
2. first 4 humanoid playable weaponless bodies + portraits
3. Relic Sling
4. NPC body/portrait set
5. major outfit families + hair library
6. remaining region bosses
7. per-item final art
8. evolution stage weapons
9. remaining region backgrounds
10. optional bespoke action poses/VFX.
