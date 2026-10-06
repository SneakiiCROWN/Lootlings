extends RefCounted

const ItemCatalog = preload("res://item_catalog.gd")

const RARITY_PROFILES := {
	"COMMON":{"anticipation":0.24, "silence":0.04, "particles":10, "shake":0.015, "intensity":0.55},
	"RARE":{"anticipation":0.34, "silence":0.06, "particles":16, "shake":0.025, "intensity":0.75},
	"EPIC":{"anticipation":0.62, "silence":0.10, "particles":34, "shake":0.075, "intensity":1.0},
	"LEGENDARY":{"anticipation":0.82, "silence":0.12, "particles":48, "shake":0.11, "intensity":1.25},
	"RED":{"anticipation":1.02, "silence":0.14, "particles":56, "shake":0.12, "intensity":1.4}
}

const CHEST_PROFILES := {
	"scavenged_cache":{"name":"Scavenged Cache", "scale":0.82, "arc_count":1, "audio":"chest_open"},
	"relic_chest":{"name":"Relic Chest", "scale":1.0, "arc_count":1, "audio":"chest_open"},
	"hoard_chest":{"name":"Hoard Chest", "scale":1.12, "arc_count":3, "audio":"chest_open"},
	"cursed_coffer":{"name":"Cursed Coffer", "scale":1.05, "arc_count":2, "audio":"chest_open"},
	"mimic_husk":{"name":"Mimic Husk", "scale":1.0, "arc_count":2, "audio":"chest_open"},
	"starfall_vault":{"name":"Starfall Vault", "scale":1.18, "arc_count":3, "audio":"legendary_reveal"},
	"event_chest":{"name":"Event Chest", "scale":1.1, "arc_count":3, "audio":"chest_open"}
}

static func highest_rarity(items: Array) -> String:
	var result := "COMMON"
	for item in items:
		if item is Dictionary:
			var rarity := str(item.get("rarity", "COMMON"))
			if ItemCatalog.rarity_rank(rarity) > ItemCatalog.rarity_rank(result):
				result = rarity
	return result

static func for_rewards(chest_id: String, items: Array) -> Dictionary:
	var rarity := highest_rarity(items)
	var rarity_profile: Dictionary = RARITY_PROFILES.get(rarity, RARITY_PROFILES.COMMON)
	var chest: Dictionary = CHEST_PROFILES.get(chest_id, CHEST_PROFILES.relic_chest)
	var scale := float(chest.scale)
	return {
		"chest_id":chest_id,
		"name":chest.name,
		"rarity":rarity,
		"color":ItemCatalog.rarity_color(rarity),
		"anticipation":float(rarity_profile.anticipation) * scale,
		"silence":float(rarity_profile.silence),
		"particles":int(round(float(rarity_profile.particles) * scale)),
		"shake":float(rarity_profile.shake) * scale,
		"intensity":float(rarity_profile.intensity) * scale,
		"arc_count":int(chest.arc_count),
		"audio":"relic_red" if rarity=="RED" else str(chest.audio)
	}
