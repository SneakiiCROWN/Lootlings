# Canonical beta art integration — 2026-10-01

The latest owner-supplied CANONICAL WORLD / ART / STORY / CONTENT OVERHAUL permits clean approved-board extraction/recomposition for beta, superseding earlier reference-only restrictions. Original sources and their existing hash/index records remain untouched. Owner approval is not an inferred external commercial licence.

Offline exporter: `tools/extract_beta_boards.gd`. Exact rectangles/thresholds are recorded there. It crops original pixels, removes edge-connected backdrop/identified neighbouring seams, uses Lanczos resizing and fits transparent bodies within 512×512. No repainting or invented character identity. Runtime uses imported/cached individual textures, never source boards.

| Runtime files | Source | Live use |
| --- | --- | --- |
| `art/sprites/lootlings/{emberhorn,mosskin,moonkip,pebblewyrm,glimmerfin}_idle.png` | Respective `art/reference/canonical/characters/<Name>_CharacterSheet_Canonical.png`; front turnaround (0,765,166,189) | Selector, combat, Home, Title; original colours |
| `art/backgrounds/beta/{crystal_grove,infernal_citadel,frozen_citadel,moonmarket}.png` | `art/reference/phase2_master/lootlings_environment_town_forest_infernal_frost_reference.png`; four separate panels, portrait focal crop 480×568 | Mossglass, Cinder, Frostbell; Expedition/Contracts/Forge |
| `art/backgrounds/beta/ruin_platform.png` | Existing `art/backgrounds/treasure_ruins_arena.png`; stone band with feathered alpha 480×110 | Contact floor for new biome paintings |
| `art/sprites/weapons/{greatsword,greataxe,orb}_held.png` | `art/reference/phase2_master/lootlings_fantasy_gear_compendium.png`; (588,69,68,168), (663,68,87,169), (960,571,84,100) respectively | Held art and item thumbnails |
| `art/sprites/enemies/beta/{furnace_regent,verdant_mirror}.png` | `art/reference/phase2_master/lootlings_boss_demon_mimic_reference.png`; (0,0,540,569), (991,0,457,594) respectively | Cinder and Mossglass final bosses; mechanics unchanged |

## Beta limitations and required production replacements

- Neutral `art/sprites/relic_beast_base.png` is byte-for-byte unchanged.
- Named cutouts are low-resolution original turnaround pixels, not final production exports. Moonkip's original daggers, Mosskin's shield and Glimmerfin's water accent are baked in. All five need high-resolution **weaponless** transparent 1024×1024 exports at these same paths, preserving canonical face/body/palette/gear/Core; separate gear layers and optional action poses may follow. Equipped weapon overlays remain independent.
- Gloomlet dark fur could not be separated cleanly. Trials were rejected, not shipped. Gloomlet remains selectable with the clearly labelled previous temporary neutral fallback. Required: `art/sprites/lootlings/gloomlet_idle.png`, transparent 1024×1024, exact canonical design, clean edge, no sheet text/neighbours.
- Accepted weapon cuts need higher-resolution production exports. Spear, Claws, Crossbow, Relic Sling and Wand still use existing class art. Stage-specific paths are supported; no new stage sprites are claimed. Rejected crops were removed.
- Regional bosses retain interior dark shading; minor source matte remains a beta limitation. Other region bosses are not replaced by unrelated board creatures. Existing Act I enemies/Grump/Hoard Dragon are unchanged.
- No original source art or provenance evidence was deleted. No audio assets changed.
- Optional image-generation extraction returned a service usage-limit error: **no generated artwork was produced or shipped**. Only the explicitly permitted mechanical exports above are included.

`ASSET_NEEDED_PHASE2.md` remains the final production contract. Beta availability does not remove final clean-export requests.

## Shared UI / resident continuation

`tools/extract_presentation_beta.gd` mechanically exports gold ornament from HUD/material board rectangle (351,1017,214,52) and dark material (1048,351,250,182), blended at 25% into existing leather/relic panel interiors. Original PNGs/caps are preserved; derived assets live at `art/ui/beta/`. The shared renderer adds bounded top/bottom ornament draws. Original currency/rarity icons, states and meter logic remain intact.

Three deliberate adult **bust portraits**, not full-body crops, come from `lootlings_heroes_creatures_demon_cutout_reference.png`: Patch (748,37,230,290), Sera (1124,29,268,310), Ilex (55,556,230,300). Edge-connected black backdrop only is removed, then resized to 256×320; paths `art/sprites/npcs/beta/{patch,sera,ilex}_portrait.png`. Original painted adult hero appearances serve the existing resident roles for beta. No canonical Lootling design is substituted; no new playable humanoid is implied. Portrait stations are framed intentionally; clean full-body resident exports remain outstanding.

## Remaining region beta compositions

`tools/compose_region_beta.gd` records exact untouched source panels and prop placements. All results are 480×568 under `art/backgrounds/beta/`; no source board labels/borders are included. Small source scenes are deliberately softer backdrops, not high-resolution final environment delivery.

| File | Source/composition |
| --- | --- |
| `moonfen_marsh.png` | `lootlings_worlds_loot_and_adventure.png` moonlit marsh panel (1234,88,201,224) |
| `starfall_sanctum.png` | Same board, sanctuary panel (1030,90,188,222) |
| `skyhook_city.png` | Same board, sunlit city panel (410,91,191,221) |
| `nullglass_gate.png` | Sanctuary backdrop plus blue portal from approved props board (900,350,391,368), at (70,42,340,350) |
| `gearworks_foundry.png` | Existing Salvage Warrens painting plus forge from props board (180,731,281,330), at (283,40,176,246); lower sanctuary water strip forms the flooded canal |
| `first_hoard_throne.png` | Existing Stash Vault painting plus trophy throne from props board (317,347,253,363), at (110,30,260,340) |

Props use edge-connected black removal plus largest connected body to reject detached neighbouring fragments. No palette-swap region is claimed as new scenery. All nine expanded regions use unique imported compositions without additional tint; the common painted contact platform keeps feet readable. Props are inert scenery, not invented encounters/rewards. Act I's three original environments remain unchanged. Higher-resolution coherent world-specific backgrounds remain a final production request.

## Weapon-family continuation

`tools/extract_weapon_beta.gd` exports four additional original cutouts from `lootlings_weapon_families_reference.png`: spear (1234,0,214,474), crossbow (698,501,306,281), claws (12,778,246,308), wand (1218,474,230,310). Largest connected foreground preserves the body while rejecting detached neighbours; no redesign. Claw pixels rotate 90° counterclockwise so wrist is left/talons right; crossbow is not mirrored. Bodies fit 432px within transparent 512×512 at `art/sprites/weapons/{spear,crossbow,claws,wand}_held.png`.

Runtime rects/angles were fitted at native phone scale; spear/wand lean clear of the face, claw wrist meets the front paw, crossbow muzzle points toward the enemy. Crossbow/wand visual projectile sockets match these sprites; damage/travel timing unchanged. Eleven families now have distinct silhouettes through new assets or established Maul/Bow/Staff/Daggers sprites. The Relic Sling still uses its documented class fallback: a flail trial was rejected/deleted because it would misrepresent the family. Required final asset: `art/sprites/weapons/sling_held.png`, transparent 1024×1024, oversized original treasure sling with readable stone cup/loop and grip on the left, release toward the right; optional charged cup separate. Stage-specific weapon art remains missing, not manufactured via percentage scaling.
