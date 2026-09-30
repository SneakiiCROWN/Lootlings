extends RefCounted

const OUTER_RUINS_BACKGROUND = preload("res://art/backgrounds/treasure_ruins_arena.png")
const EMBERWORKS_BACKGROUND = preload("res://art/backgrounds/salvage_warrens_arena.png")
const HOARD_DEPTHS_BACKGROUND = preload("res://art/backgrounds/hoard_depths_arena.png")

const ZONES := [
	{
		"id":"outer_ruins", "name":"OUTER TREASURE RUINS", "waves":Vector2i(1, 5),
		"background":OUTER_RUINS_BACKGROUND, "accent":Color("#72c8ff"), "ambient":"motes",
		"entry":"THE EXPEDITION BEGINS", "future_music":"outer_ruins", "future_loot_theme":"relic_ruins",
		"variant_pool":["hasty", "armoured", "volatile", "gilded"], "hazard_hooks":["loose_coins", "cracked_pots"], "prop_hooks":["relic_arch", "market_stall", "hanging_vines"],
		"enemies":{
			"skirmisher":{"id":"razor_imp", "name":"RAZOR IMP"},
			"tank":{"id":"mossback_brute", "name":"MOSSBACK BRUTE"},
			"hexer":{"id":"lantern_hexer", "name":"LANTERN HEXER"}
		},
		"compositions":[["tank","hexer","skirmisher"],["skirmisher","skirmisher","tank"],["hexer","skirmisher","tank"],["tank","hexer","skirmisher"],["skirmisher","tank","hexer"]],
		"miniboss":"", "boss":""
	},
	{
		"id":"emberworks", "name":"SALVAGE WARRENS", "waves":Vector2i(6, 10),
		"background":EMBERWORKS_BACKGROUND, "accent":Color("#ff9b55"), "ambient":"embers",
		"entry":"DESCENDING INTO THE EMBERWORKS", "future_music":"emberworks", "future_loot_theme":"forge_salvage",
		"variant_pool":["hasty", "armoured", "volatile", "overcharged", "gilded"], "hazard_hooks":["steam_puff", "rolling_cart"], "prop_hooks":["gear_door", "chain_lift", "scrap_pile"],
		"enemies":{
			"skirmisher":{"id":"cinder_gnawer", "name":"CINDER GNAWER"},
			"tank":{"id":"scrap_golem", "name":"SCRAP GOLEM"},
			"hexer":{"id":"kiln_wisp", "name":"KILN WISP"}
		},
		"compositions":[["skirmisher","tank","hexer"],["skirmisher","skirmisher","tank"],["tank","hexer","skirmisher"],["hexer","skirmisher","tank"],["tank","hexer","hexer"]],
		"miniboss":"grump_knight", "boss":""
	},
	{
		"id":"hoard_depths", "name":"HOARD DEPTHS", "waves":Vector2i(11, 15),
		"background":HOARD_DEPTHS_BACKGROUND, "accent":Color("#d4a856"), "ambient":"glints",
		"entry":"THE VAULT OPENS", "future_music":"hoard_depths", "future_loot_theme":"ancient_hoard",
		"variant_pool":["armoured", "cursed", "frostbitten", "rootbound", "gilded"], "hazard_hooks":["coin_slide", "vault_pulse"], "prop_hooks":["giant_lock", "gem_tower", "dragon_marks"],
		"enemies":{
			"skirmisher":{"id":"gemfang_wyrmling", "name":"GEMFANG WYRMLING"},
			"tank":{"id":"vaultbound_sentinel", "name":"VAULTBOUND SENTINEL"},
			"hexer":{"id":"shardseer", "name":"SHARDSEER"}
		},
		"compositions":[["hexer","skirmisher","tank"],["skirmisher","skirmisher","tank"],["tank","hexer","skirmisher"],["skirmisher","tank","hexer"],["tank","hexer","hexer"]],
		"miniboss":"", "boss":"hoard_dragon"
	}
]

static func for_wave(wave: int) -> Dictionary:
	for zone in ZONES:
		var range: Vector2i = zone.waves
		if wave >= range.x and wave <= range.y:
			return zone
	return ZONES.back()

static func enemy_for(zone: Dictionary, archetype: String) -> Dictionary:
	return zone.enemies.get(archetype, zone.enemies.skirmisher)

static func composition_for(zone: Dictionary, wave: int) -> Array:
	var local_wave := clampi(wave - int(zone.waves.x), 0, zone.compositions.size() - 1)
	return zone.compositions[local_wave]

static func archetype_for(zone: Dictionary, wave: int, kill_index: int) -> String:
	var composition := composition_for(zone, wave)
	return composition[clampi(kill_index, 0, composition.size() - 1)]

# Encounter containers are intentionally solo today, but the stable shape supports
# deliberate duos/swarms later without changing zone or enemy IDs.
static func encounter_for(zone: Dictionary, wave: int, encounter_index: int) -> Dictionary:
	return {
		"id":"%s_w%02d_e%02d" % [zone.id, wave, encounter_index],
		"kind":"solo",
		"members":[archetype_for(zone, wave, encounter_index)],
		"targeting":"frontmost",
		"shared_reward":true
	}

static func supported_encounter_kinds() -> Array[String]:
	return ["solo", "duo", "small_swarm"]

static func variant_pool_for(zone: Dictionary) -> Array:
	return zone.get("variant_pool", []).duplicate()

static func all_zone_ids() -> Array[String]:
	var result: Array[String] = []
	for zone in ZONES:
		result.append(zone.id)
	return result
