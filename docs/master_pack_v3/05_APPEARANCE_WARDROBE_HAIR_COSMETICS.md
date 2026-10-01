# APPEARANCE, WARDROBE, HAIR & COSMETICS

## Principle
Players should be able to make a character they love looking at.
Appearance is expression, not power.

Human/humanoid customisation applies only to clearly adult player characters. Lootling customisation remains creature-appropriate and separate.

## Humanoid appearance schema
identity:
- display_name
- pronoun_set
- origin_id
- avatar_kind=humanoid

body:
- frame: light / medium / heavy / tall
- skin_tone_id
- face_preset_id
- eye_shape_id
- eye_colour_id
- brow_id
- ear_variant_id
- optional cosmetic Core-mark style

details:
- freckles
- moles
- scars
- tattoos
- warpaint
- occult_marks
- makeup_style
- makeup_intensity
- piercings

hair:
- hair_style_id
- hair_colour_a
- hair_colour_b
- brow_colour
- facial_hair_id
- hair_accessory_id

wardrobe:
- underlayer
- head
- chest
- legs
- gloves
- boots
- shoulders
- cape_or_scarf
- belt_or_satchel
- neck
- ears
- wrists
- rings
- dye_a
- dye_b
- dye_c

presentation:
- portrait_frame
- title
- banner
- aura
- trail
- victory_pose
- emote

## Initial hairstyle library
Stable planned IDs:
hair_shaved_clean
hair_buzz_fade
hair_undercut_swept
hair_undercut_braids
hair_short_messy
hair_short_curls
hair_sidepart
hair_bob_blunt
hair_bob_wavy
hair_shag_layered
hair_mohawk_braided
hair_cornrows_short
hair_cornrows_long
hair_box_braids
hair_twists
hair_loc_bob
hair_loc_long
hair_afro_short
hair_afro_full
hair_ponytail_high
hair_ponytail_low
hair_braid_single
hair_braids_twin
hair_long_straight
hair_long_wavy
hair_long_curls
hair_half_up
hair_topknot
hair_witch_waves
hair_warrior_mane

No hairstyle is gender-locked.

## Facial hair IDs
beard_none
beard_stubble
beard_short
beard_boxed
beard_full
beard_braided
beard_goatee
beard_moustache
beard_handlebar
beard_sideburns
beard_shadow
beard_wild

## Outfit families
Each family can have Practical / Glamorous / Daring / Armoured variants when art exists.

outfit_salvager
outfit_lantern_hunter
outfit_moonfen_rogue
outfit_starfall_witch
outfit_quillkeeper_scholar
outfit_cinder_berserker
outfit_cinder_battle_glamour
outfit_frostbell_arcane
outfit_mossglass_wild
outfit_skyhook_warden
outfit_gearworks_tinker
outfit_nullglass_occult
outfit_relic_priest
outfit_hollow_court_spoils
outfit_first_hoard_ceremonial
outfit_hideout_casual

Adult Daring variants may include exposed midriff, deep/open necklines, high slits, crop jackets, open coats, fitted harnesses, thigh-high boots, shirtless/open-shirt masculine looks, fitted leather/cloth/metal and glamorous jewellery. Keep nipples/genitals covered. Do not use youthful sexualisation.

## Cosmetic tone mix
Not every unlock should be sexy.
Maintain a healthy spread:
- cute/charming
- practical/lived-in
- glamorous/sexy
- brutal/badass
- occult/mysterious
- funny/oddball
- regal/ceremonial
- demonic/corrupted-looking without implying evil mechanics

## Lootling cosmetics
skin
head
horn_or_ear_accessory
scarf_or_cape
partial_armour
satchel
core_effect
weapon_skin
aura
trail
victory
emote
icon
title
banner

Do not apply adult humanoid wardrobe geometry to Lootlings.

## Wardrobe service
Mira Threadlock handles wardrobe/hair/dyes cosmetically.
Oren Valeglass handles broader appearance edits.
Talli Nock previews weapon skins/poses/VFX for free.
Cosmetic preview should never charge currency merely to inspect an owned look.

## Transmog rule
Power item and appearance item are separate IDs.
Equipping a stronger weapon must not force the player to abandon a preferred unlocked weapon skin.
Likewise armour stats do not dictate the visible outfit once transmog is unlocked.

## Save-safe recommendation
Store cosmetics under one additive appearance block with stable string IDs.
Unknown future cosmetic IDs should fall back visually without deleting ownership data.
