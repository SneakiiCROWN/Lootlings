# Lootlings master artist delivery guide

This is an external-art contract, not a runtime patch or a declaration that Phase4E is complete. Read the exact cell JSON and identity lock before authoring. Dedicated entity sheets win over broad boards. All paths are repository-relative; package references preserve those paths under references/repository.

## Counts

```json
{
  "missing_actor_cells": 3048,
  "missing_playable_cells_including_wanderers": 2311,
  "missing_lootling_cells": 1456,
  "missing_wanderer_cells": 855,
  "missing_enemy_cells": 323,
  "missing_boss_cells": 368,
  "missing_npc_cells_including_merchant": 46,
  "missing_companion_cells": 58,
  "support_packages": 165,
  "support_deliverables": 1616,
  "support_foreground_PNGs": 2110,
  "support_package_sidecars": 165,
  "environment_Home_deliverables": 8,
  "environment_Home_images": 5,
  "missing_UI_VFX_artist_files": 0,
  "total_artist_files": 8495,
  "total_artist_PNGs": 5221,
  "total_artist_sidecars": 3274,
  "already_complete_exact_registered_cells": 283,
  "reference_only_inventory_records_not_finished": 825,
  "reference_only_original_records": 598,
  "rejected_inventory_records": 6,
  "body_view_packages": 106,
  "outstanding_contract_records": 3274,
  "support_package_linked_foreground_PNGs": 1451,
  "other_playable_foreground_PNGs": 659,
  "companion_follower_cells": 34,
  "companion_perch_cells": 24,
  "launch_decor_catalogue_entries": 6,
  "reused_launch_decor_entries": 4,
  "new_launch_perch_props": 2,
  "home_added_artist_files": 6,
  "new_companion_perch_artist_files": 48
}
```

## Delivery format

Individually named images and measured sidecars. Deliver to the source paths in DELIVERY_FOLDER_TREE.txt; Codex installs to the explicit runtime paths AFTER validation. No dummy images are included. For every pixel value unavailable before drawing, MEASURE_FROM_DELIVERED_PIXELS gives the exact measurement method. Accepted state/body references are not new art requests.

## Playable Lootlings

- relic_beast: 206 exact cells; states: idle, movement, windup, strike_or_cast, follow_through, recovery, hurt, defeat, victory_return. See canon_locks/relic_beast.json and master exact paths.
- emberhorn: 205 exact cells; states: idle, movement, windup, strike_or_cast, follow_through, recovery, hurt, defeat, victory_return. See canon_locks/emberhorn.json and master exact paths.
- mosskin: 211 exact cells; states: idle, movement, windup, strike_or_cast, follow_through, recovery, hurt, defeat, victory_return. See canon_locks/mosskin.json and master exact paths.
- moonkip: 212 exact cells; states: idle, movement, windup, strike_or_cast, follow_through, recovery, hurt, defeat, victory_return. See canon_locks/moonkip.json and master exact paths.
- pebblewyrm: 210 exact cells; states: idle, movement, windup, strike_or_cast, follow_through, recovery, hurt, defeat, victory_return. See canon_locks/pebblewyrm.json and master exact paths.
- glimmerfin: 206 exact cells; states: idle, movement, windup, strike_or_cast, follow_through, recovery, hurt, defeat, victory_return. See canon_locks/glimmerfin.json and master exact paths.
- gloomlet: 206 exact cells; states: idle, movement, windup, strike_or_cast, follow_through, recovery, hurt, defeat, victory_return. See canon_locks/gloomlet.json and master exact paths.

## Wanderers

- vault_runner: 171 exact cells; states: idle, movement, windup, strike_or_cast, follow_through, recovery, hurt, defeat, victory_return. See canon_locks/vault_runner.json and master exact paths.
- ruin_warden: 171 exact cells; states: idle, movement, windup, strike_or_cast, follow_through, recovery, hurt, defeat, victory_return. See canon_locks/ruin_warden.json and master exact paths.
- nightstage_drifter: 171 exact cells; states: idle, movement, windup, strike_or_cast, follow_through, recovery, hurt, defeat, victory_return. See canon_locks/nightstage_drifter.json and master exact paths.
- velvet_astrologer: 171 exact cells; states: idle, movement, windup, strike_or_cast, follow_through, recovery, hurt, defeat, victory_return. See canon_locks/velvet_astrologer.json and master exact paths.
- ashtrail_hunter: 171 exact cells; states: idle, movement, windup, strike_or_cast, follow_through, recovery, hurt, defeat, victory_return. See canon_locks/ashtrail_hunter.json and master exact paths.

## Enemies / elites / miniboss

- mossmaw: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/mossmaw.json and master exact paths.
- glasswing: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/glasswing.json and master exact paths.
- dew_hexer: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/dew_hexer.json and master exact paths.
- fen_sneak: 11 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/fen_sneak.json and master exact paths.
- lantern_toad: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/lantern_toad.json and master exact paths.
- mudcloak: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/mudcloak.json and master exact paths.
- bell_bat: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/bell_bat.json and master exact paths.
- rime_pup: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/rime_pup.json and master exact paths.
- icicle_imp: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/icicle_imp.json and master exact paths.
- sluice_crab: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/sluice_crab.json and master exact paths.
- pressure_sprite: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/pressure_sprite.json and master exact paths.
- brassback: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/brassback.json and master exact paths.
- coal_pup: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/coal_pup.json and master exact paths.
- slag_knight: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/slag_knight.json and master exact paths.
- forge_beetle: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/forge_beetle.json and master exact paths.
- inkling: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/inkling.json and master exact paths.
- margin_imp: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/margin_imp.json and master exact paths.
- pagewyrm: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/pagewyrm.json and master exact paths.
- null_hound: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/null_hound.json and master exact paths.
- echo_imp: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/echo_imp.json and master exact paths.
- mirror_knight: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/mirror_knight.json and master exact paths.
- hookwing: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/hookwing.json and master exact paths.
- chain_guard: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/chain_guard.json and master exact paths.
- deck_hexer: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/deck_hexer.json and master exact paths.
- first_guard: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/first_guard.json and master exact paths.
- crown_shard: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/crown_shard.json and master exact paths.
- hoard_echo: 12 exact cells; states: idle, role windup, role commit, hurt, recovery, defeat. See canon_locks/hoard_echo.json and master exact paths.

The current eleven elite modifiers and Grump Knight miniboss retain existing base bodies/mechanics. No separately registered authored elite/miniboss export debt exists; reuse existing assets and overlays. Regional generic proxy art is not authority. Movement/root approach uses current presentation; no additional authored movement cell is registered for nonplayable enemies. If separate locomotion animations are required later, their frame/timing contract must be approved rather than fabricated here.

## Bosses

- act_i: 38 exact cells; states: idle, phase transition, hurt, vulnerability, recovery, defeat, CLAWS windup, CLAWS commit, CLAWS recovery, BRACE windup, BRACE commit, BRACE recovery, COIN BREATH windup, COIN BREATH commit, COIN BREATH recovery, RECOVER recovery, TAIL SWEEP windup, TAIL SWEEP commit, TAIL SWEEP recovery. See canon_locks/act_i.json and master exact paths.
- mossglass_wilds: 32 exact cells; states: idle, phase transition, hurt, vulnerability, recovery, defeat, ROOT SWEEP windup, ROOT SWEEP commit, ROOT SWEEP recovery, MIRROR CHARGE windup, MIRROR CHARGE commit, MIRROR CHARGE recovery, THORN CAST windup, THORN CAST commit, THORN CAST recovery, RECOVER recovery. See canon_locks/mossglass_wilds.json and master exact paths.
- cinder_crown: 38 exact cells; states: idle, phase transition, hurt, vulnerability, recovery, defeat, HAMMER windup, HAMMER commit, HAMMER recovery, COAL BREATH windup, COAL BREATH commit, COAL BREATH recovery, TRIBUTE FLARE windup, TRIBUTE FLARE commit, TRIBUTE FLARE recovery, RECOVER recovery, CINDER SWEEP windup, CINDER SWEEP commit, CINDER SWEEP recovery. See canon_locks/cinder_crown.json and master exact paths.
- moonfen: 38 exact cells; states: idle, phase transition, hurt, vulnerability, recovery, defeat, POUNCE windup, POUNCE commit, POUNCE recovery, FEINT windup, FEINT commit, FEINT recovery, LANTERN BITE windup, LANTERN BITE commit, LANTERN BITE recovery, RECOVER recovery, BITE windup, BITE commit, BITE recovery. See canon_locks/moonfen.json and master exact paths.
- frostbell_hollows: 32 exact cells; states: idle, phase transition, hurt, vulnerability, recovery, defeat, BELL STRIKE windup, BELL STRIKE commit, BELL STRIKE recovery, RIME BREATH windup, RIME BREATH commit, RIME BREATH recovery, CHIME windup, CHIME commit, CHIME recovery, RECOVER recovery. See canon_locks/frostbell_hollows.json and master exact paths.
- sunken_gearworks: 38 exact cells; states: idle, phase transition, hurt, vulnerability, recovery, defeat, PISTON windup, PISTON commit, PISTON recovery, PRESSURE RISE windup, PRESSURE RISE commit, PRESSURE RISE recovery, STEAM VENT windup, STEAM VENT commit, STEAM VENT recovery, COOLING recovery, GEAR SWEEP windup, GEAR SWEEP commit, GEAR SWEEP recovery. See canon_locks/sunken_gearworks.json and master exact paths.
- starfall_archive: 38 exact cells; states: idle, phase transition, hurt, vulnerability, recovery, defeat, INK STRIKE windup, INK STRIKE commit, INK STRIKE recovery, ANNOTATE windup, ANNOTATE commit, ANNOTATE recovery, ERASE windup, ERASE commit, ERASE recovery, RECOVER recovery, PAGE CUT windup, PAGE CUT commit, PAGE CUT recovery. See canon_locks/starfall_archive.json and master exact paths.
- nullglass_expanse: 38 exact cells; states: idle, phase transition, hurt, vulnerability, recovery, defeat, ECHO windup, ECHO commit, ECHO recovery, REFRACT windup, REFRACT commit, REFRACT recovery, GLASS CUT windup, GLASS CUT commit, GLASS CUT recovery, RECOVER recovery, SHATTER windup, SHATTER commit, SHATTER recovery. See canon_locks/nullglass_expanse.json and master exact paths.
- skyhook_bastion: 38 exact cells; states: idle, phase transition, hurt, vulnerability, recovery, defeat, CHAIN SWEEP windup, CHAIN SWEEP commit, CHAIN SWEEP recovery, REEL IN windup, REEL IN commit, REEL IN recovery, ANCHOR SLAM windup, ANCHOR SLAM commit, ANCHOR SLAM recovery, RECOVER recovery, HOOK windup, HOOK commit, HOOK recovery. See canon_locks/skyhook_bastion.json and master exact paths.
- first_hoard: 38 exact cells; states: idle, phase transition, hurt, vulnerability, recovery, defeat, CROWN STRIKE windup, CROWN STRIKE commit, CROWN STRIKE recovery, CLAIM windup, CLAIM commit, CLAIM recovery, VAULT SEAL windup, VAULT SEAL commit, VAULT SEAL recovery, RECOVER recovery, COLLECT windup, COLLECT commit, COLLECT recovery. See canon_locks/first_hoard.json and master exact paths.

Boss stable runtime IDs are region keys; identity_id names the actual boss. act_i is Hoard Dragon, NOT Grump Knight. Every named attack windup/commit/recovery and phase transition/vulnerability is separately listed. One full continuous tail is part of each Dragon body, not a floating tail patch hiding malformed source.

## NPCs / merchant

- patch: 12 exact cells; states: rest, route/walk, work/read/tend, inspect, talk, sit. See canon_locks/patch.json and master exact paths.
- sera: 12 exact cells; states: rest, route/walk, work/read/tend, inspect, talk, sit. See canon_locks/sera.json and master exact paths.
- ilex: 12 exact cells; states: rest, route/walk, work/read/tend, inspect, talk, sit. See canon_locks/ilex.json and master exact paths.
- pack_peddler: 10 exact cells; states: rest, talk, offer, inspect, return. See canon_locks/pack_peddler.json and master exact paths.

Patch Brasswick and Ilex Quill approved panels remain preserved for dialogue/portraits. Request full body/activity states only, not replacement portraits. Resident work/read/tend labels denote that same NPC's activity, never a new NPC. Prop contacts measured; current stations remain in Hub, not Home.

## Companions

- auricub: 10 exact cells; states: idle, move, reaction, perch_rest, perch_interact. See canon_locks/auricub.json and master exact paths.
- stonekith: 9 exact cells; states: idle, move, reaction, perch_rest, perch_interact. See canon_locks/stonekith.json and master exact paths.
- pixrask: 10 exact cells; states: idle, move, reaction, perch_rest, perch_interact. See canon_locks/pixrask.json and master exact paths.
- lunarwisp: 10 exact cells; states: idle, move, reaction, perch_rest, perch_interact. See canon_locks/lunarwisp.json and master exact paths.
- puffnest: 9 exact cells; states: idle, move, reaction, perch_rest, perch_interact. See canon_locks/puffnest.json and master exact paths.
- breezewyn: 10 exact cells; states: idle, move, reaction, perch_rest, perch_interact. See canon_locks/breezewyn.json and master exact paths.

Stonekith and Puffnest right-idle exports are already accepted and excluded. Each companion needs idle/move/reaction in both views to equip. Follower return uses reaction; the new approved launch perch feature additionally requires perch_rest and perch_interact in both views. Cosmetic only.

## Home

- personal_home: 3 exact production units; states: all linked states. See canon_locks/personal_home.json and master exact paths.

See master Home object for1536x2732 background, exact480x854 design UI exclusions, character/display/follower anchors and accepted reusable decorations. Main Hub and personal Home remain separate. Both are now closed by the owner-authorised minimum launch contracts: HOME_LAUNCH_SYSTEMS.md and associated JSON.

## World / support

- ashtrail_hunter: 8 family support packages; states: all linked states. See canon_locks/ashtrail_hunter.json and master exact paths.
- emberhorn: 18 family support packages; states: all linked states. See canon_locks/emberhorn.json and master exact paths.
- glimmerfin: 18 family support packages; states: all linked states. See canon_locks/glimmerfin.json and master exact paths.
- gloomlet: 18 family support packages; states: all linked states. See canon_locks/gloomlet.json and master exact paths.
- moonkip: 18 family support packages; states: all linked states. See canon_locks/moonkip.json and master exact paths.
- mosskin: 18 family support packages; states: all linked states. See canon_locks/mosskin.json and master exact paths.
- nightstage_drifter: 8 family support packages; states: all linked states. See canon_locks/nightstage_drifter.json and master exact paths.
- pebblewyrm: 18 family support packages; states: all linked states. See canon_locks/pebblewyrm.json and master exact paths.
- relic_beast: 17 family support packages; states: all linked states. See canon_locks/relic_beast.json and master exact paths.
- ruin_warden: 8 family support packages; states: all linked states. See canon_locks/ruin_warden.json and master exact paths.
- vault_runner: 8 family support packages; states: all linked states. See canon_locks/vault_runner.json and master exact paths.
- velvet_astrologer: 8 family support packages; states: all linked states. See canon_locks/velvet_astrologer.json and master exact paths.

## UI / presentation

Existing accepted HUD/icons/menus/cards/reward machine/station/display assets are classified REUSE_EXISTING in the ledger and relevant byte-identical examples are supplied. No additional specifically registered new UI art file exists in the frozen queue; visual final owner acceptance is still open. Do not turn beta status alone into an art remake.

## VFX / projectiles

Fifteen existing authored effect exports and seven runtime projectile identities are reused. New actor attack/charge origin coordinates are in each sidecar; temporary effects must remain separate. No additional authored VFX sheet is specified by the current gap register. State-specific layer routing is integration work, not an invented effect-image request.

## Miscellaneous remaining blockers

NEEDS_AUTHORITY_REVIEW.json is empty: the minimum Home perch/decor contract is fully decided. New geometry coordinates are measured after drawing; they are not canon ambiguity. Source delivery is never native acceptance: exact selector/manifest adapter work remains after files arrive. Existing save/audio/device/visual acceptance gates remain outside this artist package.

## Counts and overlap

Support165 packages link owning state images and foreground layers; those images are counted once. File totals include bodyPNG, mandatory combined foregroundPNG and one pose sidecar, plus companion follower/perch body/sidecar, Home background/metadata,2 removable perch body/front/metadata packages, and165 family-index sidecars. Optional split support PNG or separate VFX are not mandatory new assets and are excluded from fixed totals. No approved idle is automatically accepted for another family/state.


## Final Home launch closure

Read HOME_LAUNCH_SYSTEMS.md and the five HOME_* JSON files.24new companion pose cells and6new perch asset files bring total artist files to8495. Existing actor gaps and accepted art are unchanged. These are production specifications, not completed runtime features.
