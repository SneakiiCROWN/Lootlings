extends SceneTree
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	OS.set_environment("LOOTLINGS_MOBILE_TEST", "1")
	call_deferred("run_qa")
func run_qa() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	assert(game.mobile_test_monitor != null)
	game.app_lifecycle.platform_notifications_enabled = false
	game.audio_settings.cinematic_first_time = false
	game.start_run()
	for i in range(120): await process_frame
	game.pause_run()
	game.mobile_test_monitor.show_report()
	await process_frame
	if "--visual" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png("res://.godot_test_data/android_monitor_report.png") == OK)
	var file := FileAccess.open("user://device_test_report.json", FileAccess.READ)
	assert(file != null)
	var data = JSON.parse_string(file.get_as_text())
	assert(data.test_build and data.samples >= 120 and data.combat_samples >= 100)
	assert(data.state == "paused" and data.frame_p99_ms >= data.frame_p95_ms)
	game.mobile_test_monitor._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	game.mobile_test_monitor._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	assert(game.mobile_test_monitor.report().lifecycle.paused == 1)
	assert(game.mobile_test_monitor.report().lifecycle.resumed == 1)
	print("MONITOR NATIVE QA PASSED: rooted game integration, rendered test panel, valid on-device report schema, combat frame samples, lifecycle counters")
	game.queue_free()
	await process_frame
	quit()
