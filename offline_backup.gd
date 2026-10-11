extends RefCounted
# Fixed destinations only. Integrity hashes detect damage, not intentional cheating.
const Safe=preload("res://safe_config.gd")
const Scope=preload("res://save_scope.gd")
const JOURNAL="user://lootlings_restore.cfg"
const STORES={"lootlings_save.cfg":"progress","lootlings_inventory.cfg":"inventory","lootlings_hideout_shop.cfg":"shop","lootlings_profile.cfg":"profile","lootlings_settings.cfg":"audio","lootlings_achievements.cfg":"achievements","campaign.cfg":"campaign","contracts.cfg":"contracts","endgame.cfg":"endgame","expedition_progress.cfg":"expedition","lootlings_tutorials.cfg":"guide"}
static func snapshot(game) -> Dictionary:
	if preload("res://economy_transaction.gd").recover()!=OK:return {}
	if game.app_lifecycle.persist()!=OK:return {}
	if game.contextual_guide.persist()!=OK:return {}
	var writes:Dictionary={};var hashes:Dictionary={}
	for name in STORES:
		var config:=ConfigFile.new()
		if Safe.load_config(config,"user://"+name,STORES[name])!=OK:return {}
		writes[name]=config.encode_to_text();hashes[name]=str(writes[name]).sha256_text()
	return {"format":"Lootlings local backup","version":1,"scope":"owner" if Scope.active else "normal","created":int(Time.get_unix_time_from_system()),"writes":writes,"sha256":hashes}
static func validate(bundle:Dictionary) -> Error:
	if bundle.get("format","")!="Lootlings local backup" or bundle.get("version",0)!=1:return ERR_FILE_UNRECOGNIZED
	if bundle.get("scope","")!=("owner" if Scope.active else "normal"):return ERR_UNAUTHORIZED
	var writes=bundle.get("writes",null);var hashes=bundle.get("sha256",null)
	if not writes is Dictionary or not hashes is Dictionary or writes.size()!=STORES.size():return ERR_FILE_CORRUPT
	for name in STORES:
		if not writes.get(name,null) is String or writes[name].length()>4000000 or hashes.get(name,"")!=str(writes[name]).sha256_text():return ERR_FILE_CORRUPT
		var config:=ConfigFile.new()
		if config.parse(writes[name])!=OK or not config.has_section(STORES[name]):return ERR_FILE_CORRUPT
	return OK
static func save_bundle(bundle:Dictionary,path:String) -> Error:
	var error:=validate(bundle)
	if error!=OK:return error
	if not path.ends_with(".lootlings-backup"):return ERR_INVALID_PARAMETER
	if path.begins_with("user://"):
		if not path.begins_with("user://backups/") or ".." in path:return ERR_INVALID_PARAMETER
		error=DirAccess.make_dir_recursive_absolute(Scope.path(path).get_base_dir())
		if error!=OK:return error
	var config:=ConfigFile.new();config.set_value("backup","bundle",bundle)
	if path.begins_with("user://"):return Safe.save_config(config,path)
	var file:=FileAccess.open(path,FileAccess.WRITE)
	if file==null:return FileAccess.get_open_error()
	file.store_string(config.encode_to_text());file.flush();file.close()
	return OK if read_bundle(path)==bundle else ERR_FILE_CORRUPT
static func read_bundle(path:String) -> Dictionary:
	var file:=FileAccess.open(Scope.path(path),FileAccess.READ)
	if file==null or file.get_length()>8000000:return {}
	var config:=ConfigFile.new()
	if config.parse(file.get_as_text())!=OK:return {}
	var bundle=config.get_value("backup","bundle",{})
	return bundle if bundle is Dictionary and validate(bundle)==OK else {}
static func restore(bundle:Dictionary,stop_after:int=-1) -> Error:
	var error:=validate(bundle)
	if error!=OK:return error
	if preload("res://economy_transaction.gd").recover()!=OK:return ERR_BUSY
	if FileAccess.file_exists(Scope.path(JOURNAL)) and recover()!=OK:return ERR_BUSY
	var journal:=ConfigFile.new();journal.set_value("restore","bundle",bundle)
	error=Safe.save_config(journal,JOURNAL)
	if error!=OK:return error
	return recover(stop_after)
static func recover(stop_after:int=-1) -> Error:
	if not FileAccess.file_exists(Scope.path(JOURNAL)):return OK
	var journal:=ConfigFile.new()
	if journal.load(Scope.path(JOURNAL))!=OK:return ERR_FILE_CORRUPT
	var bundle=journal.get_value("restore","bundle",{})
	if not bundle is Dictionary:return ERR_FILE_CORRUPT
	var error:=validate(bundle)
	if error!=OK:return error
	var completed:=0
	for name in STORES:
		if OS.get_environment("LOOTLINGS_QA")=="1" and completed==stop_after:return ERR_BUSY
		var config:=ConfigFile.new();config.parse(bundle.writes[name])
		error=Safe.save_config(config,"user://"+name)
		if error!=OK:return error
		completed+=1
	return DirAccess.remove_absolute(Scope.path(JOURNAL))
