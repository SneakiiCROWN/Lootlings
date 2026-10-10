extends RefCounted
# Write-ahead recovery for the existing Home economy stores. No schema,
# price or reward changes. Restart replays the same target snapshots idempotently.
const Safe=preload("res://safe_config.gd")
const PATH="user://home_economy_transaction.cfg"
const STORES={"user://lootlings_save.cfg":"progress","user://lootlings_inventory.cfg":"inventory","user://lootlings_hideout_shop.cfg":"shop","user://contracts.cfg":"contracts"}

static func commit(game, stop_after: int=-1) -> Error:
	if FileAccess.file_exists(PATH) and recover()!=OK:return ERR_BUSY
	var writes := {}
	var stages := {
		"user://lootlings_save.cfg":func(path):return preload("res://meta_store.gd").save_progress(path,game.meta_shards,game.meta_power,game.gold,game.gold_upgrades,game.rift_progress),
		"user://lootlings_inventory.cfg":func(path):return game.inventory.save(path),
		"user://lootlings_hideout_shop.cfg":func(path):return game.hideout_shop.save(path),
		"user://contracts.cfg":func(path):return game.contracts.save(path)
	}
	for path in STORES:
		var stage: String=path+".stage"
		var error: Error=stages[path].call(stage)
		if error!=OK:return error
		writes[path]=FileAccess.get_file_as_string(stage)
	var journal:=ConfigFile.new();journal.set_value("transaction","version",1);journal.set_value("transaction","writes",writes)
	var hashes: Dictionary={}
	for path in writes:hashes[path]=str(writes[path]).sha256_text()
	journal.set_value("transaction","sha256",hashes)
	var error:=Safe.save_config(journal,PATH)
	if error!=OK:return error
	return recover(stop_after)

static func recover(stop_after: int=-1) -> Error:
	if not FileAccess.file_exists(PATH):return OK
	var journal:=ConfigFile.new()
	if journal.load(PATH)!=OK or journal.get_value("transaction","version",0)!=1:return ERR_FILE_CORRUPT
	var writes=journal.get_value("transaction","writes",null)
	if not writes is Dictionary or writes.size()!=STORES.size():return ERR_FILE_CORRUPT
	var hashes=journal.get_value("transaction","sha256",{})
	if not hashes is Dictionary:return ERR_FILE_CORRUPT
	var configs := {}
	# Validate every destination before touching any live store; paths are fixed.
	for path in STORES:
		if not writes.get(path,null) is String or writes[path].length()>4000000:return ERR_FILE_CORRUPT
		if hashes.get(path,"")!=str(writes[path]).sha256_text():return ERR_FILE_CORRUPT
		var config:=ConfigFile.new()
		if config.parse(writes[path])!=OK or not config.has_section(STORES[path]):return ERR_FILE_CORRUPT
		configs[path]=config
	var completed:=0
	for path in STORES:
		if OS.get_environment("LOOTLINGS_QA")=="1" and completed==stop_after:return ERR_BUSY
		var error:=Safe.save_config(configs[path],path)
		if error!=OK:return error
		completed+=1
	return DirAccess.remove_absolute(PATH)
