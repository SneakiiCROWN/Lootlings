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
