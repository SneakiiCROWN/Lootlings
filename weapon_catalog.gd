extends RefCounted

# Master Production Handoff v2 weapon source of truth. `live` means the family
# has a safe runtime presentation today; locked families remain replacement-ready data.
const FAMILIES := {
	"greatsword":{"name":"Greatsword", "combat_family":"VANGUARD", "projectile":"", "live":true, "held_angle":25.0, "motion":"load back -> diagonal cleave -> recoil settle", "bases":["Rustcleaver", "Moonsteel Slab", "Mimic Blade", "Grump Greatblade"], "evolutions":[["Rustcleaver", "Vaultcleaver", "Crowncleaver"], ["Moonsteel Slab", "Starbreaker", "Sky-Sunder"], ["Mimic Blade", "Hungry Edge", "Maw of Plenty"]]},
	"greataxe":{"name":"Greataxe", "combat_family":"VANGUARD", "projectile":"", "live":false, "held_angle":35.0, "motion":"high load -> overhead chop -> heavy follow-through", "bases":["Scrap Axe", "Rootsplitter", "Coinchop", "Kiln Reaver"], "evolutions":[["Scrap Axe", "Furnace Axe", "Cinder Crown"], ["Rootsplitter", "Wildsplitter", "Worldsplitter"], ["Coinchop", "Gilded Guillotine", "Hoard Harvester"]]},
	"maul":{"name":"Maul", "combat_family":"VANGUARD", "projectile":"", "live":true, "held_angle":20.0, "motion":"compress -> impact swing -> ground settle", "bases":["Mimic Mallet", "Pebble Pounder", "Bell Maul", "Scrap Sledge"], "evolutions":[["Mimic Mallet", "Vault Mallet", "Hoardhammer"], ["Pebble Pounder", "Faultmaker", "Worldknocker"], ["Bell Maul", "Resonant Maul", "Cathedral Bell"]]},
	"spear":{"name":"Spear / Halberd", "combat_family":"VANGUARD", "projectile":"", "live":false, "held_angle":12.0, "motion":"brace -> thrust or hook -> snap recovery", "bases":["Ruin Pike", "Moonhook", "Thorn Lance", "Gear Halberd"], "evolutions":[["Ruin Pike", "Vault Pike", "First Spear"], ["Moonhook", "Crescent Hook", "Eclipse Halberd"], ["Thorn Lance", "Briar Lance", "Verdant Needle"]]},
	"daggers":{"name":"Twin Daggers", "combat_family":"ROGUE", "projectile":"", "live":true, "held_angle":20.0, "motion":"low crouch -> crossing slash -> spring back", "bases":["Moonbite Daggers", "Scrap Shivs", "Gilded Knives", "Mossfang Pair"], "evolutions":[["Moonbite Daggers", "Moonfangs", "Night's Receipt"], ["Scrap Shivs", "Rivet Fangs", "Geargrin"], ["Gilded Knives", "King's Change", "Crown Tax"]]},
	"claws":{"name":"Claws / Gauntlets", "combat_family":"ROGUE", "projectile":"", "live":false, "held_angle":0.0, "motion":"double swipe -> uppercut -> sharp recovery", "bases":["Ruin Claws", "Cinder Knuckles", "Shade Claws", "Barkfist"], "evolutions":[["Ruin Claws", "Vault Talons", "Relic Rippers"], ["Cinder Knuckles", "Furnace Fists", "Caldera Hands"], ["Shade Claws", "Gloom Talons", "Null Rake"]]},
	"bow":{"name":"Bow", "combat_family":"RANGER", "projectile":"arrow", "live":true, "held_angle":7.0, "motion":"brace -> draw -> release recoil", "bases":["Crooked Bow", "Moonbranch", "Gilded Shortbow", "Warrens Longbow"], "evolutions":[["Crooked Bow", "Ruin Longbow", "Starstring"], ["Moonbranch", "Crescent Bow", "Fullmoon Arc"], ["Gilded Shortbow", "Hoardbow", "King's Dividend"]]},
	"crossbow":{"name":"Crossbow", "combat_family":"RANGER", "projectile":"bolt", "live":false, "held_angle":0.0, "motion":"raise -> lock -> bolt recoil", "bases":["Scrap Repeater", "Vault Crossbow", "Needlecaster", "Cinder Boltthrower"], "evolutions":[["Scrap Repeater", "Gear Repeater", "Storm Repeater"], ["Vault Crossbow", "Lockbreaker", "Door Argument"], ["Needlecaster", "Quillstorm", "Index Eraser"]]},
	"sling":{"name":"Relic Sling", "combat_family":"RANGER", "projectile":"sling_stone", "live":false, "held_angle":0.0, "motion":"spin -> arcing release -> follow-through", "bases":["Pebble Sling", "Coin Slinger", "Spore Sling", "Glass Pellet Sling"], "evolutions":[["Pebble Sling", "Geode Sling", "Meteor Pocket"], ["Coin Slinger", "Goldspinner", "Treasury Problem"], ["Spore Sling", "Bloomlobber", "Mossburst"]]},
	"staff":{"name":"Staff", "combat_family":"MAGE", "projectile":"magic_orb", "live":true, "held_angle":30.0, "motion":"plant -> charge -> arcing cast -> magical settle", "bases":["Glimmerstaff", "Cinder Staff", "Moss Staff", "Shardseer Staff"], "evolutions":[["Glimmerstaff", "Starstaff", "Observatory Spine"], ["Cinder Staff", "Furnace Rod", "Crownfire Branch"], ["Moss Staff", "Verdant Rod", "Root of the Vault"]]},
	"wand":{"name":"Wand", "combat_family":"MAGE", "projectile":"wand_spark", "live":false, "held_angle":15.0, "motion":"point -> flick -> fast spark recoil", "bases":["Ruin Wand", "Bubble Wand", "Hexstick", "Bell Wand"], "evolutions":[["Ruin Wand", "Vault Wand", "First Spark"], ["Bubble Wand", "Tide Wand", "Deepglow"], ["Hexstick", "Cursebranch", "Null Needle"]]},
	"orb":{"name":"Orb / Focus", "combat_family":"MAGE", "projectile":"focus_shard", "live":false, "held_angle":0.0, "motion":"orbit compresses -> focus flash -> orbit expands", "bases":["Relic Orb", "Mirror Focus", "Storm Pearl", "Ink Sphere"], "evolutions":[["Relic Orb", "Vault Sphere", "Core Satellite"], ["Mirror Focus", "Echo Focus", "Unchosen Eye"], ["Storm Pearl", "Tempest Pearl", "Skyheart"]]}
}

const PROJECTILES := {
	"arrow":{"source":"bow", "speed":860.0, "arc":0.02, "impact":"stick_spark"},
	"bolt":{"source":"crossbow", "speed":1080.0, "arc":0.0, "impact":"mechanical_thunk"},
	"sling_stone":{"source":"sling", "speed":610.0, "arc":0.32, "impact":"dust_chip"},
	"magic_orb":{"source":"staff", "speed":520.0, "arc":0.16, "impact":"element_burst"},
	"wand_spark":{"source":"wand", "speed":920.0, "arc":0.04, "impact":"sharp_spark"},
	"focus_shard":{"source":"orb", "speed":700.0, "arc":0.10, "impact":"clean_pulse"}
}

# Additional approved bases are Forge-acquired, not silently added to Act I drops.
const STARTERS := {
	"greataxe":{"id":"scrap_axe", "desc":"Every third attack chops for +45% damage.", "effects":{"damage_mult":0.05}},
	"spear":{"id":"ruin_pike", "desc":"The opening strike against each foe deals +30% damage.", "effects":{"boss_damage":0.05}},
	"claws":{"id":"ruin_claws", "desc":"Two fast swipes, each at 55% damage.", "effects":{"crit":0.025}},
	"crossbow":{"id":"scrap_repeater", "desc":"Every third trigger fires two hits at 64% each.", "effects":{"crit":0.025}},
	"sling":{"id":"pebble_sling", "desc":"Every third shot staggers the foe by 0.18s. Arcing stones.", "effects":{"damage_mult":0.05}},
	"wand":{"id":"ruin_wand", "desc":"Fast sparks. Every third cast repeats its element.", "effects":{"repeat_every":3}},
	"orb":{"id":"relic_orb", "desc":"Every fourth release restores 2 HP.", "effects":{"max_hp":8.0}}
}
static var texture_cache := {}

static func starter(id: String) -> Dictionary:
	if not STARTERS.has(id):
		return {}
	var data: Dictionary = STARTERS[id].duplicate(true)
	var definition: Dictionary = FAMILIES[id]
	data.name = definition.bases[0]
	data.slot = "Weapon"
	data.family = definition.combat_family
	data.weapon_type = id
	data.projectile = definition.projectile
	data.evolution_path = definition.evolutions[0].slice(1)
	data.icon = definition.name
	data.temp_art = not ResourceLoader.exists("res://art/sprites/weapons/%s_held.png" % id)
	return data

static func runtime_texture(id: String, fallback: Texture2D, stage: int = 0) -> Texture2D:
	# Legacy saves may predate weapon_type. Never cache one class's fallback
	# under a shared empty key and accidentally render it for another class.
	if id.is_empty():
		return fallback
	var key := "%s_%d" % [id, clampi(stage, 0, 2)]
	if texture_cache.has(key):
		return texture_cache[key]
	var path := "res://art/sprites/weapons/%s_held.png" % id
	var evolved := "res://art/sprites/weapons/%s_stage%d_held.png" % [id, clampi(stage, 0, 2)]
	if stage > 0 and ResourceLoader.exists(evolved): path = evolved
	texture_cache[key] = load(path) if ResourceLoader.exists(path) else fallback
	return texture_cache[key]

static func held_rect(id: String, fallback: Rect2) -> Rect2:
	match id:
		"greatsword", "greataxe": return Rect2(-58, -122, 128, 140)
		"orb": return Rect2(-33, -53, 98, 98)
		"spear": return Rect2(-27, -163, 126, 172)
		"crossbow": return Rect2(-20, -56, 144, 100)
		"claws": return Rect2(-16, -35, 118, 95)
		"wand": return Rect2(-22, -110, 100, 118)
		_: return fallback

static func definition(id: String) -> Dictionary:
	var data: Dictionary = FAMILIES.get(id, {}).duplicate(true)
	if STARTERS.has(id):
		data.live = true
	return data

static func live_ids() -> Array[String]:
	var result: Array[String] = []
	for id in FAMILIES:
		if bool(FAMILIES[id].live) or STARTERS.has(id):
			result.append(id)
	return result

static func evolution_for(id: String, base_name: String) -> Array:
	for line in FAMILIES.get(id, {}).get("evolutions", []):
		if not line.is_empty() and str(line[0]) == base_name:
			return line.duplicate()
	return []
