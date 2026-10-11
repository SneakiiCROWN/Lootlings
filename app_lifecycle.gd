extends Node
# Small lifecycle adapter; no changes to combat, rewards, or run-save semantics.
var game
var suspended := false
var platform_notifications_enabled := true
var previous_pause := false
var presentation_mode := Node.PROCESS_MODE_ALWAYS

func configure(target) -> void:
	game = target
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().auto_accept_quit = false
	get_tree().quit_on_go_back = false

func _notification(what: int) -> void:
	if game == null or not platform_notifications_enabled: return
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED:
			suspend()
		NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_APPLICATION_RESUMED:
			restore_focus()
		NOTIFICATION_WM_CLOSE_REQUEST:
			persist()
			get_tree().quit()
		NOTIFICATION_WM_GO_BACK_REQUEST:
			game.navigate_back()

func suspend() -> void:
	if suspended: return
	previous_pause = get_tree().paused
	if game.state == "playing": game.pause_run()
	persist()
	presentation_mode = game.presentation_director.process_mode
	game.presentation_director.process_mode = Node.PROCESS_MODE_DISABLED
	suspended = true
	get_tree().paused = true

func restore_focus() -> void:
	if not suspended: return
	game.presentation_director.process_mode = presentation_mode
	get_tree().paused = previous_pause
	suspended = false
	# Combat stays on the existing Pause screen until the player resumes.

func persist() -> Error:
	if FileAccess.file_exists(preload("res://save_scope.gd").path(preload("res://offline_backup.gd").JOURNAL)):return ERR_BUSY
	if preload("res://economy_transaction.gd").recover()!=OK:return ERR_BUSY
	var writes:Array=[
		func():return game.retention.progress.save(),
		func():return game.expedition_progress.save(),
		func():return preload("res://meta_store.gd").save_progress(game.SAVE_PATH,game.meta_shards,game.meta_power,game.gold,game.gold_upgrades,game.rift_progress),
		func():return game.inventory.save(game.INVENTORY_SAVE_PATH),
		func():return game.hideout_shop.save(game.HIDEOUT_SHOP_SAVE_PATH),
		func():return preload("res://profile_store.gd").save_profile(game.PROFILE_SAVE_PATH,game.profile),
		func():return preload("res://settings_store.gd").save_settings(game.SETTINGS_SAVE_PATH,game.audio_settings),
		func():return game.achievements.save_state(),
		func():return game.campaign.save("user://campaign.cfg"),
		func():return game.contracts.save("user://contracts.cfg")]
	for write in writes:
		var error:Error=write.call()
		if error!=OK:return error
	return OK
