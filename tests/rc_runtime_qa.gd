extends SceneTree
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("review")

func review() -> void:
	var logger := preload("res://analytics_logger.gd")
	var path := "user://bounded_diagnostics.jsonl"
	for rotation in range(2):
		var file := FileAccess.open(path,FileAccess.WRITE)
		file.store_string("x".repeat(logger.MAX_LOG_BYTES)); file.close()
		logger.log_event(path,"boundary",{"rotation":rotation,"display_name":"private"})
		file = FileAccess.open(path,FileAccess.READ)
		assert(file.get_length() < logger.MAX_LOG_BYTES)
		var entry = JSON.parse_string(file.get_line()); file.close()
		assert(entry.data.rotation == rotation and not entry.data.has("display_name"))
		assert(FileAccess.file_exists(path + ".previous"))
	var root_children := root.get_child_count()
	var samples := []
	for iteration in range(12):
		var game = load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
		game.set_process(false); game.audio_settings.cinematic_first_time = false
		game.start_run(); game.show_hideout(); game.hideout_ui.show_stash()
		game.hideout_ui.show_shop(); game.hideout_ui.show_upgrades()
		game.queue_free(); await process_frame; await process_frame
		assert(root.get_child_count() == root_children)
		samples.append({"iteration":iteration,"static_bytes":Performance.get_monitor(Performance.MEMORY_STATIC),"nodes":Performance.get_monitor(Performance.OBJECT_NODE_COUNT),"orphan_nodes":Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)})
	print("RC_RUNTIME " + JSON.stringify(samples))
	print("RC RUNTIME QA PASSED: bounded diagnostics/privacy, 12 scene/menu construction and cleanup cycles; memory observations are desktop counters")
	quit()
