# Customisation, Outfits and Style Production Contract

## Goal

Players should be able to make a character they genuinely like looking at: cute, badass, sexy, rugged, glamorous, demonic, arcane, practical, ridiculous or some mixture of those.

## Separation of systems

### Lootlings
Canonical body identity remains intact. Cosmetic slots may include:
- skin/palette variant
- hood/headpiece
- horn/ear accessory
- scarf/cape
- satchel
- partial armour shell
- Core ornament
- weapon skin
- aura/trail
- emote
- victory pose
- profile icon/banner

Do not dress Lootlings in scaled-down adult lingerie/plate silhouettes from humanoid boards.

### Wanderers
Layered humanoid cosmetic system:
1. base body
2. skin/marking layer
3. hair
4. face accessory
5. underlayer
6. torso outfit/armour
7. legs
8. boots
9. gloves
10. shoulder/cape
11. jewellery
12. weapon
13. weapon VFX
14. aura/trail

## Outfit families

Each family should eventually have at least three presentation variants:
- practical
- heroic/glamorous
- revealing/raunchy adult variant

### Rogue / Leather
Black/brown leather, belts, knives, hood options, exposed-midriff or open-shirt variants, long-coat alternatives.

### Witch / Arcane
Blue/violet/black, crystal jewellery, fitted robes, split-skirt variants, high-neck scholarly version, dramatic glamorous version.

### Hunter / Ranger
Green/red/brown field gear, fur, straps, boots, cape, sleeveless and cropped variants, weathered practical set.

### Knight / Warden
Blackened steel, blue/gold or red/gold, full plate through open-arm/open-chest glamour variants. Keep weapon clearance around shoulders.

### Berserker / Ashmarked
Heavy boots, wraps, fur, black metal, glowing red accents. Shirtless masculine, cropped/strapped feminine and covered variants all supported.

### Priest / Relic Keeper
White/gold/crystal, ceremonial drape, fitted armour, robes, exposed shoulder/back variants.

### Tinker / Gearworks
Teal/brass/brown, goggles, utility harnesses, mechanic coat, shorts/trousers/skirts, corset-like tool harness variant.

### Nullglass / Occult
Purple/black/gold, feathers, layered mesh/cloth, dramatic horns, thigh-highs or long robes, masculine open-coat versions.

## Hair catalogue starter target

Production-ready first wave should aim for 24 styles:
- short crop
- buzz
- shaved sides
- messy short
- swept medium
- shoulder-length
- long straight
- long wavy
- ponytail high
- ponytail low
- braid single
- braids twin
- undercut braid
- afro short
- afro large
- locs short
- locs long
- curls short
- curls long
- bob
- mohawk
- bald
- horn-compatible swept
- hood-compatible tucked

Hair colours: black, dark brown, brown, auburn, blonde, platinum, grey, white, red, orange, green, cyan, blue, purple, pink plus custom tint later.

## Armour appearance vs item stats

Item stats remain data-driven. Cosmetic appearance is a separate field.

An equipped `ironpaw_plate` can display:
- its default look;
- an unlocked plate glamour;
- a themed skin;
- hidden armour if the player wants their outfit visible.

Never force players to wear ugly stat gear. Never let a sexy cosmetic secretly lower defence.

## Dyes

Initial channels:
- primary cloth
- secondary cloth/leather
- metal accent
- crystal/Core glow

Dyes are cosmetic. Region palettes may unlock themed dye presets.

## Wardrobe UI

At the Hideout:
- body / face
- hair
- outfit
- armour appearance
- accessories
- weapon skin
- colours
- idle pose
- victory pose
- save look preset

Include "randomise" and "reset category", not only "reset everything".

## Minimum art requirement for first humanoid beta

Rather than trying to ship thousands of combinations immediately, first beta can use:
- 4 body frames;
- 8 face presets;
- 12 hairstyles;
- 10 skin tones;
- 4 outfit families × 3 variants;
- 12 weapon-family compatible poses;
- 6 jewellery pieces;
- 6 scars/marks;
- 5 horn/ear options.

The data model should already support expansion beyond that first set.
