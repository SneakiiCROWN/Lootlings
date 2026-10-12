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
	{"id":"gold_hoard", "name":"Shiny Problem", "category":"Collection", "desc":"Hold 1,000 Lootcoins at once.", "target":1000},
	{"id":"scrap_hoard", "name":"Useful Eventually", "category":"Collection", "desc":"Hold 250 Scrap at once.", "target":250},
	{"id":"hideout_social", "name":"Everybody Knows Your Name", "category":"Hideout", "desc":"Visit 5 different Hideout destinations.", "target":5},
	{"id":"relic_student", "name":"Core Curriculum", "category":"Mastery", "desc":"Reach a Relic Training milestone.", "target":1},
	{"id":"bonk_nothing", "name":"Strategic Air Bonk", "category":"Secret", "desc":"???", "revealed_desc":"Try to attack while no foe is present.", "target":1, "secret":true},
	{"id":"thousand_kills", "name":"Local Ecosystem Concern", "category":"Combat", "desc":"Defeat 1,000 enemies.", "target":1000},
	{"id":"variant_hunter", "name":"Variant Hunter", "category":"Combat", "desc":"Defeat every live enemy variant.", "target":8},
	{"id":"gilded_first", "name":"Shiny Target", "category":"Combat", "desc":"Defeat a Gilded enemy.", "target":1},
	{"id":"first_frostbitten", "name":"Cold Reception", "category":"Combat", "desc":"Defeat a Frostbitten enemy.", "target":1},
	{"id":"signature_set", "name":"Autograph Collector", "category":"Loot", "desc":"Discover 6 different Signature effects.", "target":6},
	{"id":"chest_50", "name":"Chronic Curiosity", "category":"Loot", "desc":"Open 50 chests.", "target":50},
	{"id":"hoard_legendary", "name":"The Good Noise", "category":"Loot", "desc":"Reveal a Legendary from a Hoard Chest.", "target":1},
	{"id":"weapon_families", "name":"Try Everything Once", "category":"Collection", "desc":"Equip 4 different weapon families.", "target":4},
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
	pending_snapshot.clear();pending_corrupt=false
	progress.clear()
	unlocked.clear()
	unique_keys.clear()
	var config := ConfigFile.new()
	if preload("res://safe_config.gd").load_config(config,path,"achievements")==OK:
		progress=config.get_value("achievements","progress",{}).duplicate(true)
		unlocked=config.get_value("achievements","unlocked",{}).duplicate(true)
		unique_keys=config.get_value("achievements","unique_keys",{}).duplicate(true)
	recover_award()

var pending_snapshot := {}
var pending_corrupt := false
var last_save_error: Error = OK
var qa_stop_stage := -1

func snapshot() -> Dictionary:
	return {"progress":progress.duplicate(true),"unlocked":unlocked.duplicate(true),"unique_keys":unique_keys.duplicate(true)}

func apply_snapshot(value: Dictionary) -> void:
	progress=value.progress.duplicate(true);unlocked=value.unlocked.duplicate(true);unique_keys=value.unique_keys.duplicate(true)

func write_snapshot(value: Dictionary) -> Error:
	var config:=ConfigFile.new()
	config.set_value("achievements","schema_version",SCHEMA_VERSION)
	for field in ["progress","unlocked","unique_keys"]:config.set_value("achievements",field,value[field])
	return preload("res://safe_config.gd").save_config(config,path)

func save_state() -> Error:
	if FileAccess.file_exists(preload("res://save_scope.gd").path("user://lootlings_restore.cfg")):return ERR_BUSY
	if pending_corrupt:return ERR_FILE_CORRUPT
	var target:Dictionary=snapshot() if pending_snapshot.is_empty() else pending_snapshot.duplicate(true)
	var journal:=ConfigFile.new();journal.set_value("award","version",1);journal.set_value("award","snapshot",target)
	journal.set_value("award","sha256",JSON.stringify(target).sha256_text())
	var error:Error=preload("res://safe_config.gd").save_config(journal,path+".pending")
	if error==OK and OS.get_environment("LOOTLINGS_QA")=="1" and qa_stop_stage==1:error=ERR_BUSY
	if error==OK:error=write_snapshot(target)
	if error==OK and OS.get_environment("LOOTLINGS_QA")=="1" and qa_stop_stage==2:error=ERR_BUSY
	last_save_error=error
	if error!=OK:pending_snapshot=target;return error
	apply_snapshot(target);pending_snapshot.clear()
	# A leftover committed journal is safe: recovery replays identical values,
	# never another payout, counter increment or separately stored entitlement.
	DirAccess.remove_absolute(preload("res://save_scope.gd").path(path+".pending"))
	return OK

func recover_award() -> void:
	if FileAccess.file_exists(preload("res://save_scope.gd").path("user://lootlings_restore.cfg")):last_save_error=ERR_BUSY;return
	var scoped: String=preload("res://save_scope.gd").path(path+".pending")
	if not FileAccess.file_exists(scoped):return
	var journal:=ConfigFile.new()
	if journal.load(scoped)!=OK:pending_corrupt=true;last_save_error=ERR_FILE_CORRUPT;return
	var target=journal.get_value("award","snapshot",{})
	var valid:bool=journal.get_value("award","version",0)==1 and target is Dictionary
	if not valid:pending_corrupt=true;last_save_error=ERR_FILE_CORRUPT;return
	for field in ["progress","unlocked","unique_keys"]:valid=valid and target.get(field,null) is Dictionary
	valid=valid and journal.get_value("award","sha256","")==JSON.stringify(target).sha256_text()
	if not valid:pending_corrupt=true;last_save_error=ERR_FILE_CORRUPT;return
	pending_snapshot=target.duplicate(true)
	save_state()

func retry_pending() -> Array:
	if pending_snapshot.is_empty():return []
	var before:Dictionary=unlocked.duplicate(true)
	if save_state()!=OK:return []
	return unlocked.keys().filter(func(id):return not before.has(id))

func change(kind: String,id: String,value: int=1,key: String="") -> bool:
	var definition:=definition_for(id)
	if definition.is_empty() or pending_corrupt:return false
	var before:=snapshot()
	if not pending_snapshot.is_empty():apply_snapshot(pending_snapshot)
	if is_unlocked(id):apply_snapshot(before);return false
	if kind=="unique":
		var keys:Array=unique_keys.get(id,[]).duplicate()
		if key.is_empty() or key in keys:apply_snapshot(before);return false
		keys.append(key);unique_keys[id]=keys;progress[id]=keys.size()
	elif kind=="unlock":progress[id]=int(definition.get("target",1))
	elif kind=="set":progress[id]=maxi(int(progress.get(id,0)),value)
	else:progress[id]=int(progress.get(id,0))+maxi(0,value)
	var earned:bool=int(progress[id])>=int(definition.get("target",1))
	if earned:unlocked[id]=int(Time.get_unix_time_from_system())
	pending_snapshot=snapshot()
	if save_state()!=OK:apply_snapshot(before);return false
	return earned

func add_progress(id: String,amount: int=1) -> bool:return change("add",id,amount)
func set_progress(id: String,value: int) -> bool:return change("set",id,value)
func unlock(id: String) -> bool:return change("unlock",id)
func mark_unique(id: String,key: String) -> bool:return change("unique",id,1,key)

func is_unlocked(id: String) -> bool:
	return unlocked.has(id)

func reset() -> void:
	pending_snapshot.clear();pending_corrupt=false
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
