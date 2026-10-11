extends SceneTree
const Backup=preload("res://offline_backup.gd")
const Scope=preload("res://save_scope.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	call_deferred("review")
func review() -> void:
	var game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
	game.gold=431;game.meta_shards=72;game.rift_progress.sigils=5
	var original:Dictionary=Backup.snapshot(game);assert(not original.is_empty() and Backup.validate(original)==OK)
	assert(Backup.save_bundle(original,"user://backups/roundtrip.lootlings-backup")==OK)
	assert(Backup.read_bundle("user://backups/roundtrip.lootlings-backup")==original)
	var poisoned:Dictionary=original.duplicate(true);poisoned.writes["lootlings_save.cfg"]+="\n";assert(Backup.validate(poisoned)!=OK)
	var foreign:Dictionary=original.duplicate(true);foreign.scope="owner";assert(Backup.validate(foreign)==ERR_UNAUTHORIZED)
	var extra:Dictionary=original.duplicate(true);extra.writes["../escape.cfg"]="evil";assert(Backup.validate(extra)!=OK)
	game.gold=876;game.meta_shards=91;game.rift_progress.sigils=8
	var newer:Dictionary=Backup.snapshot(game);assert(not newer.is_empty())
	for boundary in range(Backup.STORES.size()+1):
		assert(Backup.restore(newer)==OK)
		var result:Error=Backup.restore(original,boundary)
		assert(result==ERR_BUSY or result==OK)
		if result==ERR_BUSY:assert(game.app_lifecycle.persist()==ERR_BUSY)
		assert(Backup.recover()==OK)
		for name in Backup.STORES:
			var actual:=ConfigFile.new();assert(actual.load("user://"+name)==OK);assert(actual.encode_to_text()==original.writes[name])
	Scope.active=true;assert(Backup.validate(original)==ERR_UNAUTHORIZED);Scope.active=false
	assert(Backup.restore(newer)==OK)
	var current:Dictionary=preload("res://meta_store.gd").load_progress(game.SAVE_PATH);assert(current.gold==876 and current.shards==91 and current.rift.sigils==8)
	print("OFFLINE BACKUP 062 PASS: 11-store checksummed snapshot, exact roundtrip, 12 interruption boundaries, replay, scope/path/hash rejection and retained currency/Rift fields. No physical power-loss or cloud claim.");game.queue_free();quit()
