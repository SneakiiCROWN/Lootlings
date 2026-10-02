> Planning/historical continuity document. Current status and production order: [AUDIT_REPORT.md](../../AUDIT_REPORT.md) and [MASTER_ROADMAP.md](../../MASTER_ROADMAP.md). Earlier counts/claims here do not supersede those sources.

# Current Live State Snapshot

Reference base: commit `11964ee8b2f52fbb2226c6e014af3580aab2330d`.

## Confirmed live foundations

### Playable Lootlings
Stable IDs:
- `relic_beast`
- `emberhorn`
- `mosskin`
- `moonkip`
- `pebblewyrm`
- `glimmerfin`
- `gloomlet`

All seven remain selectable by contract. Relic Beast is the canonical neutral mascot. Five named beta cutouts have existed in prior checkpoints; Gloomlet may require a temporary stand-in depending on the local art state. Missing final art must never silently remove a playable identity.

### Campaign
Order:
1. `act_i`
2. `mossglass_wilds`
3. `moonfen`
4. `frostbell_hollows`
5. `sunken_gearworks`
6. `cinder_crown`
7. `starfall_archive`
8. `nullglass_expanse`
9. `skyhook_bastion`
10. `first_hoard`

Existing region mechanics, unlock order, enemy-role mixes, loot pools and persistence remain authoritative.

### Weapon families
Stable family IDs:
- `greatsword`
- `greataxe`
- `maul`
- `spear`
- `daggers`
- `claws`
- `bow`
- `crossbow`
- `sling`
- `staff`
- `wand`
- `orb`

All twelve have gameplay contracts. Art readiness varies. Evolution lines already exist in `weapon_catalog.gd`; do not rename them merely for style.

### Existing item categories
Live slots:
- Weapon
- Armour
- Relic / Charm
- Rune

Existing named bases and their effects live in `item_catalog.gd`. New art can map to them without inventing new stats.

### Residents / story voices
Current named resident roles:
- Patch Brasswick — Salvager / tinker
- Ilex Quill — Archivist
- Sera Vey — Relic Keeper
- Merrow Vane — Pack Peddler (world-bible role; fuller presentation may remain pending)

### Current gameplay expansion
At the latest confirmed pushed checkpoint:
- bounded group patrol combat exists behind an expedition option;
- foes have independent HP/status/attack clocks;
- targeting works per foe;
- ranged projectiles retain launched targets;
- bounded AoE exists for selected combat patterns;
- solo balance/RNG path remains preserved.

The owner's latest screenshot shows Codex continuing from this into seeded route rooms, with room choices between fights and existing merchant/loot decisions reused.

## Do not regress
- Existing solo path.
- Existing save migrations.
- Existing economy / reward RNG.
- Existing Forge acquisition.
- Existing campaign unlock order.
- Existing chest claim semantics.
- Existing seven Lootling availability.
- Existing canonical Relic Beast.
- Existing shipped art hashes unless deliberately replacing a documented beta asset.

## Major planned gaps this pack addresses
- Fully playable adult humanoid character branch with robust appearance customisation.
- Shared humanoid weapon grip/pose system for all 12 weapon families.
- Outfit/armour cosmetic layering independent from stats.
- Hair, face, skin tone, body presentation and accessory options.
- More adult NPCs, side characters, shops, faction members and dialogue.
- Character-select presentation that makes Lootlings and humanoids feel equally first-class.
- Boss/NPC/enemy visual production manifest.
- Larger dialogue/on-screen text library.
- Asset naming and folder rules that Codex can ingest without guessing.
