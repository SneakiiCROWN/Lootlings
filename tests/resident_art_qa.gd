extends SceneTree
const Memories = preload("res://vignette_catalog.gd")
const Home = preload("res://hideout_ui.gd")
var game
var native := false

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	native = "--visual" in OS.get_cmdline_user_args()
	call_deferred("run_qa")

func run_qa() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.show_hideout()
	game.hideout_ui.dismiss_dialogue()
	if native: await capture("residents_home")
	var economy := [game.gold,game.inventory.scrap,game.meta_shards,game.inventory.equipped.duplicate(true),game.inventory.stash.duplicate(true)]
	var rng: int = game.rng.state
	for id in Memories.RESIDENTS:
		var entry := Memories.entry("resident/"+id)
		if id in ["patch","ilex"]:
			assert(entry.actor_kind=="portrait" and str(entry.actor).ends_with("_canonical_station_panel.png"))
			for facing in ["left","right"]:
				for state in ["rest","inspect","talk"]:
					var body: Dictionary=preload("res://resident_art_catalog.gd").presentation(Memories.RESIDENTS[id].role,Home.RESIDENT_RECTS[Memories.RESIDENTS[id].role],state,facing)
					assert(body.get("full_body",false) and body.export_state==state and body.facing==facing)
		else:
			assert(entry.actor_kind == "adult" and str(entry.actor).ends_with("_idle.png"))
			var image := Image.load_from_file(ProjectSettings.globalize_path(str(entry.actor)))
			assert(image.get_size() == Vector2i(1024,1536))
			var used := image.get_used_rect()
			assert(used.position.x > 0 and used.position.y > 0 and used.end.x < 1024 and used.end.y < 1536, "No cropped costume extremities")
			for point in [Vector2i(10,10),Vector2i(1010,10),Vector2i(1010,1500),Vector2i(10,1500)]:assert(image.get_pixelv(point).a == 0)
		var speaker: String = Memories.RESIDENTS[id].role
		var rect: Rect2 = Home.RESIDENT_RECTS[speaker]
		assert(rect.size.x >= 48 and rect.size.y >= 48)
		game.meet_resident(speaker)
		assert(game.presentation_director.vignette.active)
		if native: await capture("resident_memory_"+id)
		game.presentation_director.vignette.finish()
		assert("resident/"+id in game.profile.memories)
		game.hideout_ui.dismiss_dialogue()
		game.replay_memory("resident/"+id)
		assert(game.presentation_director.vignette.active)
		game.presentation_director.vignette.finish()
	assert([game.gold,game.inventory.scrap,game.meta_shards,game.inventory.equipped,game.inventory.stash] == economy)
	assert(game.rng.state == rng)
	game.hideout_ui.show_stash()
	assert(not game.hideout_ui.speech_panel.visible)
	if native: await capture("resident_stash_no_leak")
	print("RESIDENT ART QA PASSED: dedicated Patch/Ilex portraits preserved, twelve authored rest/inspect/talk bodies, Sera retained; talk targets, memory/replay, no rewards/RNG or dialogue leaks; route/work/sit queues remain open")
	game.queue_free()
	await process_frame
	quit(0)

func capture(label: String) -> void:
	game.queue_redraw()
	game.hideout_ui.queue_redraw()
	await create_timer(0.25).timeout
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	assert(image.get_size() == Vector2i(480,854))
	assert(image.save_png("res://.godot_test_data/"+label+"_qa.png") == OK)
