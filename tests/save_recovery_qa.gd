extends SceneTree
const Store = preload("res://safe_config.gd")
const Meta = preload("res://meta_store.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("run_qa")
func run_qa() -> void:
	var path := "user://recovery.cfg"
	assert(Meta.save_progress(path, 17, 2, 90) == OK)
	assert(Meta.save_progress(path, 19, 3, 110) == OK)
	assert(Meta.load_progress(path).gold == 110)
	assert(FileAccess.file_exists(path + ".bak"))
	var corrupt := FileAccess.open(path, FileAccess.WRITE)
	corrupt.store_string("[broken invalid"); corrupt.close()
	assert(Meta.load_progress(path).gold == 90)
	# A successful save after recovery must preserve the good backup.
	assert(Meta.save_progress(path, 20, 4, 120) == OK)
	assert(Meta.load_progress(path).gold == 120)
	var backup := ConfigFile.new()
	assert(backup.load(path + ".bak") == OK and backup.get_value("progress", "gold") == 90)
	assert(DirAccess.remove_absolute(path) == OK)
	assert(Meta.load_progress(path).gold == 90)
	# Wrong-section primary data also recovers; no permanent reset.
	var wrong := ConfigFile.new(); wrong.set_value("unrelated", "value", 1)
	assert(wrong.save(path) == OK)
	assert(Meta.load_progress(path).gold == 90)
	var game = load("res://main.tscn").instantiate(); root.add_child(game)
	await process_frame
	game.start_run(); game.set_process(false)
	# The attack handler must honor a remapped key, not a hardcoded Space key.
	var bindings := InputMap.action_get_events("tap_attack")
	InputMap.action_erase_events("tap_attack")
	var key := InputEventKey.new(); key.physical_keycode = KEY_Z
	InputMap.action_add_event("tap_attack", key)
	var old_key := InputEventKey.new(); old_key.physical_keycode = KEY_SPACE; old_key.pressed = true
	game._unhandled_input(old_key); assert(game.tap_input_cooldown == 0.0)
	key.pressed = true; game._unhandled_input(key); assert(game.tap_input_cooldown > 0.0)
	InputMap.action_erase_events("tap_attack")
	for binding in bindings: InputMap.action_add_event("tap_attack", binding)
	var hp: float = game.player_hp
	game.app_lifecycle._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert(paused and game.state == "paused")
	assert(game.presentation_director.process_mode == Node.PROCESS_MODE_DISABLED)
	game.app_lifecycle._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	assert(not paused and game.state == "paused" and game.player_hp == hp)
	assert(game.presentation_director.process_mode == Node.PROCESS_MODE_ALWAYS)
	game.resume_run(); assert(game.state == "playing")
	paused = true; game.app_lifecycle.suspend(); game.app_lifecycle.restore_focus()
	assert(paused); paused = false
	assert(FileAccess.file_exists(game.PROFILE_SAVE_PATH))
	game.queue_free(); await process_frame
	print("SAVE RECOVERY / LIFECYCLE QA PASSED")
	quit(0)
