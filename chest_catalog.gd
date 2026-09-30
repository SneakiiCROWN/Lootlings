extends RefCounted

const CHESTS := {
	"scavenged_cache":{
		"id":"scavenged_cache", "name":"SCAVENGED CACHE", "rarity_floor":"COMMON",
		"rolls":1, "special_pool":false, "accent":Color("#72c8ff")
	},
	"relic_chest":{
		"id":"relic_chest", "name":"RELIC CHEST", "rarity_floor":"RARE",
		"rolls":2, "special_pool":true, "accent":Color("#c99cff")
	},
	"hoard_chest":{
		"id":"hoard_chest", "name":"HOARD CHEST", "rarity_floor":"EPIC",
		"rolls":3, "special_pool":true, "accent":Color("#ffd36a")
	},
	"cursed_coffer":{
		"id":"cursed_coffer", "name":"CURSED COFFER", "rarity_floor":"RARE",
		"rolls":2, "special_pool":true, "accent":Color("#9d64e8"), "status":"DEFINED_DATA"
	},
	"mimic_husk":{
		"id":"mimic_husk", "name":"MIMIC HUSK", "rarity_floor":"RARE",
		"rolls":2, "special_pool":true, "accent":Color("#ff8a62"), "status":"ASSET_NEEDED"
	},
	"starfall_vault":{
		"id":"starfall_vault", "name":"STARFALL VAULT", "rarity_floor":"LEGENDARY",
		"rolls":3, "special_pool":true, "accent":Color("#fff2c4"), "status":"FUTURE"
	}
}

const PRESENTATION_PHASES := ["drop", "land", "anticipate", "open", "burst", "eject", "settle", "reveal"]

static func definition(chest_id: String) -> Dictionary:
	return CHESTS.get(chest_id, {}).duplicate(true)

static func is_valid(chest_id: String) -> bool:
	return CHESTS.has(chest_id)

static func future_sources() -> Array[String]:
	return ["boss", "run_milestone", "gold_purchase", "scrap_purchase", "quest", "dungeon", "world", "mimic", "event", "clan", "raid"]
