extends SceneTree
var game

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("review")

func capture(label: String) -> void:
	game.queue_redraw(); await process_frame; await RenderingServer.frame_post_draw
	var folder := "res://.godot_test_data/phase3_final_details/%dx%d/" % [root.size.x,root.size.y]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	assert(root.get_texture().get_image().save_png(folder+label+".png") == OK)

func review() -> void:
	assert(DisplayServer.get_name() != "headless")
	game = load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.set_process(false)
	var dimensions := OS.get_environment("LOOTLINGS_CAPTURE_SIZE").split("x")
	root.size = Vector2i(int(dimensions[0]),int(dimensions[1])); await process_frame
	game.app_lifecycle.platform_notifications_enabled = false
	game.audio_settings.cinematic_first_time = false
	seed(91823); game.rng.seed = 13891; game.loot_system.rng.seed = 34189
	game.start_run(); game.wave_banner_timer = 0; game.coins = 987654321
	game.pause_run(); await capture("pause_full_details")
	game.resume_run(); game.enemy_alive = false
	game.event_seen = preload("res://expedition_event_catalog.gd").EVENTS.keys().filter(func(id): return id != "cursed_coffer")
	game.show_expedition_event(); await capture("event_consequence")
	game.choose_expedition_event(2)
	game.pending_items.append(preload("res://item_catalog.gd").create_item("burden_bell","EPIC",719))
	game.show_next_item(); await capture("item_signature")
	game.gold = 987654321; game.inventory.scrap = 12345678; game.meta_shards = 987654
	game.show_hideout(); await capture("large_hideout")
	game.hideout_ui.show_shop(); await capture("large_shop")
	game.free(); await process_frame
	print("PHASE3 FINAL DETAILS PASSED: 5 native full-detail/wrapped consequence/large number screens")
	quit()
