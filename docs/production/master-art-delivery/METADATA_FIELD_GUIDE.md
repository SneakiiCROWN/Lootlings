# Metadata field guide

All delivered pixel anchors use final exported canvas coordinates. Null means physically absent/not applicable and needs a reason; it never means unmeasured. Actor sidecars use the full actor schema, with `contacts` conforming to weapon_socket for modular player equipment, `attack_anchors` conforming to enemy_attack_anchor for named hostile attacks, and `tail` conforming to boss_anchor_tail where applicable. Actor schema is a common envelope; nested field schemas and cross-field validation are mandatory in addition. Companion/environment/support package schemas are standalone. New master interchange is not a current engine input format.

- `schema_version`: Exact owning-cell value; see master cell.
- `slot_id`: Exact owning-cell value; see master cell.
- `entity_id`: Exact owning-cell value; see master cell.
- `state`: Exact owning-cell value; see master cell.
- `facing`: Exact owning-cell value; see master cell.
- `weapon_family`: Exact owning-cell value; see master cell.
- `identity_authority`: Exact controlling dedicated source paths, not guidance boards
- `body_filename`: Exact owning-cell value; see master cell.
- `source_sha256`: SHA256 of final body PNG bytes, AFTER final export
- `canvas`: [width,height] final export pixels
- `occupied_bounds`: [left,top,right,bottom], exclusive right/bottom actual occupied alpha
- `baseline_y`: Final canvas ground/hover boundary according to owning cell
- `pivot`: Owning cell origin, not automatically image centre
- `ground_or_hover_point`: Exact owning-cell value; see master cell.
- `primary_palm`: Exact owning-cell value; see master cell.
- `secondary_palm`: Exact owning-cell value; see master cell.
- `core_or_eye`: Exact owning-cell value; see master cell.
- `mirroring_allowed`: Exact owning-cell value; see master cell.
- `uniform_source_transform`: Single uniform scale + source crop + canvas offset; no anatomy warping
- `layers`: Exact filenames or null; foreground can include both contacting hands
- `baked_equipment`: Empty for new modular player bodies; permanent intrinsic entity equipment declared explicitly
- `baked_equipment_restrictions`: Exact owning-cell value; see master cell.
- `contacts`: Family-specific measured module grip/support/string/paired contact transform; nested weapon schema
- `attack_anchors`: Named attack and phase, real emission/contact/effect points; nested enemy schema
- `tail`: Boss tail/hip/centreline/width data where applicable; null for no tail
- `non_applicable_reasons`: Explain null anatomy/anchor/layer values

See weapon schema for module design size/UV vs pixel distinction. Bow REST/DRAWN requires measured nock; released hand is open and no longer a string contact. No inherited windup coordinates. Boss centreline ordered root→tip, width samples correspond one-to-one, tail count0 for no tail and1 for Dragon. Follower reaction remains existing reuse; base equip requires6 states/views. Perch requires4 additional state/views. Environment records current UI design exclusions and clear furniture/display/follower bounds. Support packages point to all linked exact body/layer/sidecar files and retain accepted existing states without reauthoring them.

## Home closure metadata

Companion perch sidecar adds perch_contact_anchor, perch_anchor_type, allowed_slots, interaction_prop_path and measured interaction_contact_anchor (null only for rest). Perch prop sidecar declares actual upper surface extent/anchor, pivot, body/front hashes and traced front-occlusion polygon; never cover face/Core. HOME_PLACEMENT_METADATA.json defines safe design slots, separate background source transform and layering. Home environment sidecar additionally declares launch_layout_metadata_path, exact movable_mounts_design and no_baked_movable_props=true. HOME_PERSISTENCE_CONTRACT.json is authoritative migration/sanitisation semantics; schema home_launch_placement validates stableIDs and slot restrictions.
