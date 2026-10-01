# PLAYABLE ROSTER + CHARACTER CREATOR

## Player identity architecture
Two independent layers:

avatar_kind:
- lootling
- humanoid

combat_loadout:
- weapon
- armour
- charm
- rune
- Core/build

Changing appearance must never silently change HP, damage, loot odds, economy or unlock logic.

## Canonical Lootling roster — preserve
Relic Beast — adaptable neutral scavenger
Emberhorn — rescue-furnace spark
Mosskin — watchstone gardener
Moonkip — bell-tower locksmith
Pebblewyrm — discarded foundation
Glimmerfin — drowned encore
Gloomlet — unnoticed kindness

## Adult human/humanoid origin presets
These are planned player-facing IDs. Origin controls biography/presentation/dialogue hooks, not raw power.

### Aurelia Voss — Crystal Gunner
ID: human_aurelia_voss
Adult woman. Confident, playful, precision-obsessed. Former Lantern Compact surveyor who discovered crystal maps remembering roads that no longer exist. Bronze-skin presentation option, silver/rose hair family, blue-gold crystal hardware. Ranged/focus/crossbow flavour. Hook: a route marked only with RETURN.

### Kaien Rook — Blade Warden
ID: human_kaien_rook
Adult man. Rugged, calm, protective. Former sky-road escort. Fur, blackened steel, crimson cloth, dark-hair/beard families. Greatsword/spear/hammer flavour. Once abandoned cargo to save travellers and never regretted it.

### Selene Veyra — Arcane Huntress
ID: human_selene_veyra
Adult woman. Elegant, curious, unnervingly composed. Quillkeeper field researcher hunting living spell-echoes. Deep-brown-skin presentation option, silver/blue hair family, moon jewellery. Staff/wand/bow/focus flavour. Hears a song in broken Cores nobody else hears.

### Rex Calder — Void Slayer
ID: human_rex_calder
Adult man. Charismatic, dangerous-looking, methodical. Survived a Nullglass reflection that came home wearing his face. Lean/broad muscular frames, scars/cursed-mark options, black/crimson gear. Greatsword/claws/daggers flavour. Refuses to say which reflection won.

### Nessa Vale — Lantern Huntress
ID: human_nessa_vale
Existing world character; planned story-unlock playable origin.
Adult woman. Competitive, direct, protective of lost travellers. Moonfen indigo/crimson. Bow/crossbow/spear flavour.
Unlock direction: resolve the false-lantern trail.

### Corvin Ash — Broken Collector
ID: human_corvin_ash
Existing world character; planned story unlock.
Adult man. Former Hollow Court tribute collector. Strong, ashamed, blunt. Blackened steel/red cloth, beard/scar options. Hammer/greatsword/greataxe flavour.
Unlock direction: restitution chain after the Regent.

### Vesper Thread — Nullglass Guide
ID: human_vesper_thread
Existing world character; planned story unlock.
Adult woman. Glamorous shadow witch, ominous but surprisingly tender. Violet/black-glass jewellery, hood/no-hood, battle-witch and daring robe variants. Wand/focus/daggers flavour.
Unlock direction: recover a future she refused to sacrifice.

### Juno Brass — Gearworks Tinker
ID: human_juno_brass
New planned adult nonbinary preset. Copper-brown skin presentation option, undercut/braids, brass/teal rigging, goggles, cropped jacket or workcoat. Crossbow/sling/orb flavour. Rebuilding a machine that insists it remembers being a person.

### Custom Wanderer
ID: human_custom
Fully player-created adult humanoid with no fixed face, gender, skin tone or combat class.
Neutral intro: "A traveller who reached the Hideout carrying a Core that remembers a road no map admits existed."

## Character creator V1 slots
Identity:
display name
pronouns/text-address set
origin/custom
body frame: light / medium / heavy / tall

Body/face:
wide skin-tone palette
face preset
eye colour
brows
freckles/moles
scars
tattoos/warpaint
optional occult marks
makeup style/intensity

Hair:
hair style
hair colour A/B
facial hair
brow colour
hair accessory

Wardrobe:
base underlayer
head/hood/hat
chest/outfit appearance
legs
boots
gloves
shoulder/cape/scarf
belt/satchel
ear/neck/wrist/rings
dye A/B/C
aura/trail
victory pose
emote
portrait frame/title/banner

## Adult wardrobe freedom
Each major humanoid set should ultimately have:
Practical
Glamorous
Daring
Armoured

Do not gender-lock style. Fit by body-frame geometry.
Daring adult variants may use exposed midriff/chest, high slits, open coats, harnesses, crop jackets, thigh boots, shirtless/low-cut masculine looks and glamorous jewellery while keeping nipples/genitals covered.

## Lootling cosmetics remain separate
skin
head
horn/ear accessory
scarf/cape
partial armour appearance
satchel
Core effect
weapon skin
aura/trail
victory
emote
icon/title/banner

Never fit adult humanoid lingerie/plate geometry directly onto Lootlings.
