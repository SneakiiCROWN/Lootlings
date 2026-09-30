extends RefCounted

const SCHEMA_VERSION := 1
const PROVIDER_IDS := {
	"first_steps":{"google_play":"", "game_center":""}, "first_expedition":{"google_play":"", "game_center":""},
	"five_expeditions":{"google_play":"", "game_center":""}, "first_miniboss":{"google_play":"", "game_center":""},
	"hoard_dragon":{"google_play":"", "game_center":""}, "dragon_regular":{"google_play":"", "game_center":""},
	"hundred_kills":{"google_play":"", "game_center":""}, "close_call":{"google_play":"", "game_center":""},
	"first_epic":{"google_play":"", "game_center":""}, "first_legendary":{"google_play":"", "game_center":""},
	"ten_chests":{"google_play":"", "game_center":""}, "fully_equipped":{"google_play":"", "game_center":""},
	"signature_find":{"google_play":"", "game_center":""}, "gold_hoard":{"google_play":"", "game_center":""},
	"scrap_hoard":{"google_play":"", "game_center":""}, "hideout_social":{"google_play":"", "game_center":""},
	"relic_student":{"google_play":"", "game_center":""}, "bonk_nothing":{"google_play":"", "game_center":""}
}
const DEFINITIONS := [
	{"id":"first_steps", "name":"Out the Door", "category":"Adventure", "desc":"Begin an expedition.", "target":1},
	{"id":"first_expedition", "name":"Ruin Rummager", "category":"Adventure", "desc":"Complete your first expedition.", "target":1},
	{"id":"five_expeditions", "name":"Well Travelled", "category":"Adventure", "desc":"Complete 5 expeditions.", "target":5},
	{"id":"first_miniboss", "name":"Knight Night", "category":"Bosses", "desc":"Defeat your first miniboss.", "target":1},
	{"id":"hoard_dragon", "name":"Dragon, Dislodged", "category":"Bosses", "desc":"Defeat the Hoard Dragon.", "target":1},
	{"id":"dragon_regular", "name":"Frequent Flyer", "category":"Bosses", "desc":"Defeat the Hoard Dragon 5 times.", "target":5},
	{"id":"hundred_kills", "name":"Tiny Menace", "category":"Combat", "desc":"Defeat 100 enemies.", "target":100},
	{"id":"close_call", "name":"One More Bonk", "category":"Combat", "desc":"Win an expedition below 10% health.", "target":1},
	{"id":"first_epic", "name":"Purple Reign", "category":"Loot", "desc":"Find your first Epic item.", "target":1},
	{"id":"first_legendary", "name":"That Glow Means Trouble", "category":"Loot", "desc":"Find your first Legendary item.", "target":1},
	{"id":"ten_chests", "name":"Lid Lifter", "category":"Loot", "desc":"Open 10 chests.", "target":10},
	{"id":"fully_equipped", "name":"Pockets Full", "category":"Collection", "desc":"Equip all four gear slots.", "target":1},
	{"id":"signature_find", "name":"Now That's Weird", "category":"Loot", "desc":"Find an item with a Signature effect.", "target":1},
	{"id":"gold_hoard", "name":"Shiny Problem", "category":"Collection", "desc":"Hold 1,000 Gold at once.", "target":1000},
	{"id":"scrap_hoard", "name":"Useful Eventually", "category":"Collection", "desc":"Hold 250 Scrap at once.", "target":250},
	{"id":"hideout_social", "name":"Everybody Knows Your Name", "category":"Hideout", "desc":"Visit every Hideout destination.", "target":5},
	{"id":"relic_student", "name":"Core Curriculum", "category":"Mastery", "desc":"Reach a Relic Training milestone.", "target":1},
	{"id":"bonk_nothing", "name":"Strategic Air Bonk", "category":"Secret", "desc":"???", "revealed_desc":"Try to attack while no foe is present.", "target":1, "secret":true},
	{"id":"thousand_kills", "name":"Local Ecosystem Concern", "category":"Combat", "desc":"Defeat 1,000 enemies.", "target":1000},
	{"id":"variant_hunter", "name":"Variant Hunter", "category":"Combat", "desc":"Defeat every live enemy variant.", "target":8},
	{"id":"gilded_first", "name":"Shiny Target", "category":"Combat", "desc":"Defeat a Gilded enemy.", "target":1},
	{"id":"first_frostbitten", "name":"Cold Reception", "category":"Combat", "desc":"Defeat a Frostbitten enemy.", "target":1},
	{"id":"signature_set", "name":"Autograph Collector", "category":"Loot", "desc":"Discover all six live Signature effects.", "target":6},
	{"id":"chest_50", "name":"Chronic Curiosity", "category":"Loot", "desc":"Open 50 chests.", "target":50},
	{"id":"hoard_legendary", "name":"The Good Noise", "category":"Loot", "desc":"Reveal a Legendary from a Hoard Chest.", "target":1},
	{"id":"weapon_families", "name":"Try Everything Once", "category":"Collection", "desc":"Equip each current combat weapon family.", "target":4},
	{"id":"dragon_problem", "name":"Dragon Problem", "category":"Bosses", "desc":"Defeat the Hoard Dragon 10 times.", "target":10}
]

var path := "user://lootlings_achievements.cfg"
var progress := {}
var unlocked := {}
var unique_keys := {}

func _init(save_path: String = "user://lootlings_achievements.cfg") -> void:
	path = save_path
	load_state()

func load_state() -> void:
	progress.clear()
	unlocked.clear()
	unique_keys.clear()
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return
	progress = config.get_value("achievements", "progress", {}).duplicate(true)
	unlocked = config.get_value("achievements", "unlocked", {}).duplicate(true)
	unique_keys = config.get_value("achievements", "unique_keys", {}).duplicate(true)

func save_state() -> Error:
	var config := ConfigFile.new()
	config.set_value("achievements", "schema_version", SCHEMA_VERSION)
	config.set_value("achievements", "progress", progress)
	config.set_value("achievements", "unlocked", unlocked)
	config.set_value("achievements", "unique_keys", unique_keys)
	return config.save(path)

func add_progress(id: String, amount: int = 1) -> bool:
	var definition := definition_for(id)
	if definition.is_empty() or is_unlocked(id):
		return false
	progress[id] = int(progress.get(id, 0)) + amount
	if int(progress[id]) >= int(definition.get("target", 1)):
		unlocked[id] = int(Time.get_unix_time_from_system())
		save_state()
		return true
	save_state()
	return false

func set_progress(id: String, value: int) -> bool:
	var old := int(progress.get(id, 0))
	progress[id] = maxi(old, value)
	var definition := definition_for(id)
	if not definition.is_empty() and not is_unlocked(id) and int(progress[id]) >= int(definition.get("target", 1)):
		unlocked[id] = int(Time.get_unix_time_from_system())
		save_state()
		return true
	save_state()
	return false

func unlock(id: String) -> bool:
	var definition := definition_for(id)
	if definition.is_empty() or is_unlocked(id):
		return false
	progress[id] = int(definition.get("target", 1))
	unlocked[id] = int(Time.get_unix_time_from_system())
	save_state()
	return true

func mark_unique(id: String, key: String) -> bool:
	var definition := definition_for(id)
	if definition.is_empty() or is_unlocked(id) or key.is_empty():
		return false
	var keys: Array = unique_keys.get(id, []).duplicate()
	if key in keys:
		return false
	keys.append(key)
	unique_keys[id] = keys
	progress[id] = keys.size()
	if keys.size() >= int(definition.get("target", 1)):
		unlocked[id] = int(Time.get_unix_time_from_system())
		save_state()
		return true
	save_state()
	return false

func is_unlocked(id: String) -> bool:
	return unlocked.has(id)

func reset() -> void:
	progress.clear()
	unlocked.clear()
	unique_keys.clear()
	save_state()

static func definition_for(id: String) -> Dictionary:
	for entry in DEFINITIONS:
		if entry.id == id:
			var result: Dictionary = entry.duplicate(true)
			result.provider_ids = PROVIDER_IDS.get(id, {"google_play":"", "game_center":""}).duplicate(true)
			return result
	return {}

func display_description(entry: Dictionary) -> String:
	if bool(entry.get("secret", false)) and not is_unlocked(str(entry.id)):
		return "???"
	return str(entry.get("revealed_desc", entry.get("desc", "")))
