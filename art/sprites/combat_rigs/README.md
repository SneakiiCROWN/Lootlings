# Original Phase 4E combat layers

These 15 original SVG torso/head/tail layers are authored with explicit vector paths in `tools/build_combat_rigs.py`. No image-generation service, external character, or franchise artwork is used. Seven Lootlings and five Wanderer presets use articulated limbs in `combat_sprite_rig.gd`; three residents use `resident_sprite_rig.gd`. Canonical menu portraits and good existing heavy-weapon exports are preserved.

Combat layers face right in their local coordinates. The actor root follows the live target relationship. Limbs, feet, grip occlusion and bowstring support are drawn from that same local transform. Paired blades have independent contacts. The long polearm support reach is bounded by moving both grips together, rather than detaching a hand.

These are **POSE / RIG PROTOTYPES ONLY**, rejected for canonical player-facing art quality. They close unsupported socket/anatomy staging for technical testing. They must not establish new character designs: Gloomlet's foxlike prototype is specifically unsuitable as a canonical reference. Approved character combat art must replace these layers through the existing stance contracts while preserving target-facing and grips. Native contact PASS is not visual acceptance.

Regenerate: bundled/local Python `tools/build_combat_rigs.py`, then Godot editor import. Named regional attachments and two boss silhouette candidates are authored separately in `tools/build_regional_variants.py` and `tools/build_boss_silhouettes.py`. They never modify hitboxes or stats.
