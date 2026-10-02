extends SceneTree
const Routes = preload("res://dungeon_route.gd")
var game
var native := false

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	native = "--visual" in OS.get_cmdline_user_args()
	call_deferred("run_qa")

func run_qa() -> void:
	var route := Routes.new()
	route.setup(4917)
	var original: Array = route.map.duplicate(true)
	route.setup(4917)
	assert(route.map == original)
	route.setup(4918)
	assert(route.map != original)
	assert(route.choose(-1).is_empty() and route.depth == -1)
	assert(Routes.reward_caps(0, false).gold == 0 and Routes.reward_caps(0, false).shards == 0)
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.show_hideout()
	game.campaign.completed.clear()
	game.start_dungeon()
	assert(game.state == "hideout" and not game.dungeon.active)
	game.campaign.finish("act_i")
	game.hideout_ui.show_campaign()
	game.hideout_ui.dungeon_requested.emit()
	await create_timer(0.8).timeout
	assert(game.state == "route" and not game.enemy_alive)
	var before_gold: int = game.gold
	var before_shards: int = game.meta_shards
	game.end_run(false)
	assert(game.gold == before_gold and game.meta_shards == before_shards)
	var campaign_before: Array = game.campaign.completed.duplicate()
	for path in range(2):
		game.show_hideout()
		game.inventory.reset_to_starter()
		game.dungeon.setup(4917 + path)
		game.start_run()
		if native: await capture("route_choices")
		if path == 0:
			game.reseed_route()
			assert(game.dungeon.seed_value == 4918 and game.dungeon.depth == -1)
		var desired := ["Combat", "Rest", "Elite", "Treasure" if path == 0 else "Shrine", "Risk", "Merchant", "Elite", "Boss"]
		for layer in range(8):
			assert(game.state == "route")
			var index := 0
			for candidate in range(game.dungeon.choices().size()):
				if game.dungeon.choices()[candidate].kind == desired[layer]: index = candidate
			game.choose_route_room(index)
			var depth: int = game.dungeon.depth
			game.choose_route_room(index)
			assert(game.dungeon.depth == depth, "Double tap cannot enter twice")
			await create_timer(0.5).timeout
			assert(game.dungeon.room.kind == desired[layer])
			if native and desired[layer] in ["Merchant", "Shrine"]: await capture("route_" + str(desired[layer]).to_lower())
			if native and desired[layer] == "Treasure":
				game._process(0.30)
				await capture("route_treasure")
			var guard := 0
			while not game.state in ["route", "result"] and guard < 160:
				guard += 1
				match game.state:
					"upgrade": game.choose_upgrade(0)
					"item": game.accept_item_scrap()
					"merchant": game.leave_merchant()
					"boss_reward":
						assert(game.boss_reward_options.size() == 3)
						for item in game.boss_reward_options: assert(item.rarity in ["EPIC", "LEGENDARY"])
						if native: await capture("route_boss_hoard")
						game.choose_boss_reward(0)
					"hoard_chest":
						game._process(0.7)
						if game.hoard_chest_phase == "ready": game.open_hoard_chest()
					_:
						if game.enemy_alive: game.damage_enemy(game.enemy_hp * 10.0 + 1, false, false)
						game._process(0.2)
				assert(guard < 160, "Room softlock: " + str(desired[layer]))
		assert(game.state == "result" and game.player_hp > 0)
		assert(not game.pause_button.visible)
		assert(game.campaign.completed == campaign_before)
		assert(game.run_gold_earned <= Routes.reward_caps(game.total_kills, true).gold)
		var final_gold: int = game.gold
		game.end_run(true)
		assert(game.gold == final_gold, "Results cannot award twice")
		if native: await capture("route_results")
	game.show_hideout()
	assert(not game.dungeon.active and not game.route_panel.visible)
	game.start_run()
	assert(game.state == "playing" and game.wave == 1 and not game.dungeon.active)
	game.queue_free()
	await process_frame
	print("DUNGEON QA PASSED: seeded map, meaningful first fork, eight room kinds, no double entry/payout, all decisions/chest paths, proportional rewards, no campaign unlock, clean return to normal run")
	quit(0)

func capture(label: String) -> void:
	game.queue_redraw()
	await create_timer(0.25).timeout
	await RenderingServer.frame_post_draw
	var shot := root.get_texture().get_image()
	assert(shot.get_size() == Vector2i(480, 854))
	assert(shot.save_png("res://.godot_test_data/%s_qa.png" % label) == OK)
