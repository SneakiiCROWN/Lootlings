extends SceneTree
var game
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	assert(DisplayServer.get_name()!="headless"); call_deferred("review")
func review() -> void:
	for size in [Vector2i(1080,2316),Vector2i(1600,2560)]:
		root.size=size; game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
		game.set_process(false); game.start_run(); game.set_process(false)
		game.expedition_progress.run_materials=19
		game.expedition_progress.run_finds=["Warden Warranty • blueprint 3/3","Courier Pike • blueprint 3/3"]
		game.run_kept_loot.assign(["Warden Warranty", "Courier Pike"])
		game.end_run(false); await create_timer(.3).timeout
		await RenderingServer.frame_post_draw
		var path: String="res://.godot_test_data/phase4a/%dx%d/result_progress.png" % [size.x,size.y]
		assert(root.get_texture().get_image().save_png(path)==OK)
		assert(game.result_summary.scroll_active)
		game.free(); await process_frame
	print("PHASE4 RESULT NATIVE PASS: expanded progress stays in the scrollable result panel, phone/tablet")
	quit()
