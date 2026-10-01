extends RefCounted

const LAYERS := [
	["Combat", "Combat"], ["Rest", "Merchant"], ["Combat", "Elite"],
	["Treasure", "Shrine"], ["Combat", "Risk"], ["Rest", "Merchant"],
	["Elite", "Combat"], ["Boss"],
]
const ROOMS := {
	"Combat":{"icon":"res://art/ui/icons/upgrades/damage.png", "desc":"Three foes. Choose targets; clear the patrol.", "title":"PATROL CHAMBER"},
	"Elite":{"icon":"variant_armoured", "desc":"One tough guardian. Guaranteed equipment.", "title":"RELIC GUARDIAN"},
	"Treasure":{"icon":"gear_charm", "desc":"Open a Relic Chest. One guaranteed item.", "title":"SEALED TREASURY"},
	"Merchant":{"icon":"currency_run_scrip", "desc":"Spend your Run Scrip. Existing shop tradeoffs.", "title":"PACK PEDDLER"},
	"Shrine":{"icon":"core_neutral", "desc":"Choose one free run upgrade. No permanent stats.", "title":"RELIC SHRINE"},
	"Risk":{"icon":"variant_cursed", "desc":"A stronger three-foe patrol. Ordinary drop rules.", "title":"CURSED CROSSING"},
	"Rest":{"icon":"res://art/ui/icons/upgrades/regen.png", "desc":"Recover 22% of maximum HP. No currency cost.", "title":"QUIET CAMP"},
	"Boss":{"icon":"rarity_legendary", "desc":"Defeat the guardian. Open its three-choice Hoard.", "title":"THE FINAL VAULT"},
}
var active := false
var seed_value := 4917
var depth := -1
var map: Array = []
var history: Array[String] = []
var room: Dictionary = {}
var room_finished := false
var region_id := "act_i"

func setup(value: int, region: String = "act_i") -> void:
	active = true
	seed_value = value
	region_id = region
	depth = -1
	map.clear()
	history.clear()
	room.clear()
	room_finished = false
	var route_rng := RandomNumberGenerator.new()
	route_rng.seed = value
	for layer in range(LAYERS.size()):
		var choices: Array[Dictionary] = []
		for kind in LAYERS[layer]:
			var choice: Dictionary = ROOMS[kind].duplicate(true)
			choice.kind = kind
			choice.wave = 15 if kind == "Boss" else 8 if kind == "Elite" else [2, 4, 4, 6, 6, 10, 10, 15][layer]
			choice.members = ["tank", "hexer", "skirmisher"] if route_rng.randf() < 0.5 else ["skirmisher", "skirmisher", "hexer"]
			if kind in ["Combat", "Risk"]:
				choice.title = ("GUARD + CASTER" if choice.members[0] == "tank" else "SCRAPPER PATROL") if kind == "Combat" else choice.title
			choices.append(choice)
		if layer == 0:
			choices[1].members = ["skirmisher", "skirmisher", "hexer"] if choices[0].members[0] == "tank" else ["tank", "hexer", "skirmisher"]
			choices[1].title = "GUARD + CASTER" if choices[1].members[0] == "tank" else "SCRAPPER PATROL"
		if choices.size() == 2 and route_rng.randf() < 0.5:
			choices.reverse()
		map.append(choices)

func choices() -> Array:
	return map[depth + 1] if active and depth + 1 < map.size() else []

func choose(index: int) -> Dictionary:
	var options := choices()
	if index < 0 or index >= options.size(): return {}
	depth += 1
	room = options[index].duplicate(true)
	history.append(str(room.kind))
	room_finished = false
	return room

static func reward_caps(kills: int, victory: bool) -> Dictionary:
	# Short routes cannot claim a full 41-foe expedition payout, and entering /
	# leaving an empty route is not a Gold/Shard source.
	return {"gold":mini(100, maxi(0, kills) * 5), "shards":mini(18, maxi(0, kills) / 2 + (2 if victory and kills > 0 else 0))}
