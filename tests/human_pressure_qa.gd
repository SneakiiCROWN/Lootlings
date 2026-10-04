extends SceneTree
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	assert(DisplayServer.get_name() != "headless")
	OS.set_environment("LOOTLINGS_MOBILE_TEST","1")
	call_deferred("review")
func review() -> void:
	var game = load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.audio_settings.cinematic_first_time = false; game.app_lifecycle.platform_notifications_enabled = false
	seed(91823); game.rng.seed = 39128; game.start_run()
	var start := Time.get_ticks_msec(); var next_tap := start
	var max_text := 0; var max_particles := 0
	while Time.get_ticks_msec()-start < 10000:
		await process_frame
		match game.state:
			"upgrade": game.choose_upgrade(0)
			"item": game.accept_item_scrap()
			"boss_reward": game.choose_boss_reward(0)
			"event": game.choose_expedition_event(2)
			"merchant": game.leave_merchant()
			"playing":
				if Time.get_ticks_msec() >= next_tap: game.request_tap_attack(); next_tap = Time.get_ticks_msec()+250
		max_text = maxi(max_text,game.floating_texts.size()); max_particles = maxi(max_particles,game.particles.size())
	var report: Dictionary = game.mobile_test_monitor.report()
	report.qualification = "10 seconds native desktop real-clock scripted play; no phone FPS/thermal claim. Includes loading and state transitions."
	report.max_floating_text = max_text; report.max_particles = max_particles
	print("HUMAN_PRESSURE "+JSON.stringify(report))
	assert(max_text <= 3)
	assert(report.combat_samples > 100)
	game.set_process(false); game.start_run(); game.set_process(false); game.wave_banner_timer = 0
	for size in [Vector2i(1080,2316),Vector2i(1600,2560)]:
		root.size = size; await process_frame; await process_frame
		var folder := "res://.godot_test_data/humanqa/%dx%d/" % [size.x,size.y]
		game.add_float("ARC",Vector2.ZERO,Color.WHITE,16); game.queue_redraw()
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(folder+"combat_final.png") == OK)
	game.free(); quit()
