# Lootlings Asset Provenance

## Master Production Handoff v2 (reference only)

- `art/reference/docs/` and `art/reference/source/production_boards/` were supplied directly by the project owner as the authoritative pre-production content/art handoff for this repository.
- Their large visual boards, canonical sheets, catalogs and manifest are design references, not runtime sprites. None are loaded by game code.
- Runtime activation remains gated by `CONTENT_IMPLEMENTATION_STATUS.md`; dedicated transparent assets are required before named Lootlings, locked weapon families, future chests or future zones become player-facing.

This file records important runtime assets. Canonical reference art remains the project owner's source of truth and is not automatically licensed for redistribution outside the project.

| Asset/path | Purpose | Creator/source | Licence/permission record | Date added | Status |
|---|---|---|---|---|---|
| `art/reference/canonical/characters/` | Unchanged canonical Lootlings identity sheets | Supplied by project owner | Project-provided; internal source of truth | Existing | Canonical reference |
| `art/sprites/relic_beast_base.png` | Exact neutral mascot gameplay cutout | Derived only from project-provided canonical mascot by background extraction | Project-provided source; no external asset | Existing | Production-direction placeholder/canonical cutout |
| `art/sprites/enemies/` | Current regular/miniboss/boss painted cutouts | Existing Lootlings project assets | Project asset; provenance inherited from repository history | Existing | Replacement-ready runtime art |
| `art/sprites/weapons/` | Four oversized weapon-family cutouts | Existing Lootlings project assets | Project asset; provenance inherited from repository history | Existing | Replacement-ready runtime art |
| `art/backgrounds/` | Combat zones and Hideout destination scenes | Existing Lootlings project assets | Project asset; provenance inherited from repository history | Existing | Replacement-ready runtime art |
| Runtime procedural drawing | UI frames, particles, loot glyphs, glows, ambient critter | Lootlings project code | Original project work | 2026-09-30 or earlier | Placeholder/runtime |
| `item_icon.gd` | Shared Armour, Charm, and Rune silhouettes used in reward/shop/inventory UI | Lootlings project code-native drawing | Original project work; no external asset | 2026-09-30 | Replacement-ready runtime art |
| `art/sprites/rewards/hoard_chest.png` | Final-boss Hoard Chest cutout | OpenAI built-in image generation, project-directed original prompt | Original commissioned project output; no external/source asset input | 2026-10-01 | Replacement-ready runtime art |
| Runtime procedural drawing | Three-arc item markers, Salvager visitor, Relic Keeper, Archivist, contextual ambient props/effects | Lootlings project code | Original project work; no external asset | 2026-09-30 | Replacement-ready runtime art |
| Runtime procedural audio + `art/audio/music/` | Runtime event SFX plus prebaked 48-second Title/Hideout/zone/Boss/result score cues | Lootlings project procedural synthesis; no external source | Original project work | 2026-09-30 | Production-direction placeholder |

No new external visual or audio downloads were introduced in the live-loot checkpoint. The canonical mascot, accepted enemies/bosses, painted weapons, and accepted backgrounds were not regenerated or repainted. Future external assets require creator, direct source, exact licence, acquisition date, attribution/modification notes, and placeholder/final status before use.
