# ID Registry and Data Rules

## Existing stable IDs — do not casually rename

### Lootlings
`relic_beast`, `emberhorn`, `mosskin`, `moonkip`, `pebblewyrm`, `glimmerfin`, `gloomlet`

### Weapon families
`greatsword`, `greataxe`, `maul`, `spear`, `daggers`, `claws`, `bow`, `crossbow`, `sling`, `staff`, `wand`, `orb`

### Campaign
`act_i`, `mossglass_wilds`, `moonfen`, `frostbell_hollows`, `sunken_gearworks`, `cinder_crown`, `starfall_archive`, `nullglass_expanse`, `skyhook_bastion`, `first_hoard`

## Planned new namespace

To prevent collisions:
- humanoid cosmetics: `cos_wanderer_...`
- Lootling cosmetics: `cos_lootling_...`
- hair: `hair_...`
- face: `face_...`
- marking: `mark_...`
- outfit appearance: `outfit_...`
- NPCs: `npc_...`
- dialogue pools: `dlg_...`
- pose profiles: `pose_...`
- route rooms: `room_...`

## Planned NPC IDs
- `npc_patch_brasswick`
- `npc_ilex_quill`
- `npc_sera_vey`
- `npc_merrow_vane`
- `npc_nessa_vale`
- `npc_corvin_ash`
- `npc_vesper_thread`
- `npc_rook_marr`
- `npc_tamsin_coil`
- `npc_edda_sable`
- `npc_brother_kelm`
- `npc_pippa_voss`

Existing code may currently refer to role labels such as "Salvager" or "Archivist"; migration to IDs should be deliberate, not a blind search/replace.

## Data rules

1. Stable gameplay ID is not display text.
2. Art path is not the identity.
3. Cosmetic appearance does not define combat stats.
4. Story tags do not mutate reward RNG.
5. Missing art falls back visibly/explicitly in development; it does not delete content.
6. Old saves migrate forward.
7. New registries should have focused tests for duplicate IDs and missing required fields.
8. Runtime code must never scan giant reference boards during play.
9. Production cutouts belong in runtime folders.
10. Keep source/reference provenance.

## Character data split

Recommended future separation:
- `lootling_catalog.gd` — canonical Lootlings
- `wanderer_catalog.gd` — humanoid appearance options
- `pose_catalog.gd` — family/body attachment data
- `cosmetic_catalog.gd` — unlockable appearance pieces
- `npc_catalog.gd` — resident/side NPC display data
- `dialogue_catalog.gd` — tagged text pools or external data resource

Do not cram all humanoid customisation into `lootling_catalog.gd`.
