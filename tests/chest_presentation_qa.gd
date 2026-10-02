extends SceneTree
var native := false
var game

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	native = "--visual" in OS.get_cmdline_user_args()
	call_deferred("run_qa")

func run_qa() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.show_hideout()
	game.gold = 1200
	game.hideout_shop.gold_cache_bought_this_cycle = false
	game.hideout_shop.pending_cache_item.clear()
	game.hideout_ui.show_shop()
	await create_timer(0.3).timeout
	var rng_before: int = game.rng.state
	game.use_gold_cache()
	assert(game.gold == 1200 - game.hideout_shop.GOLD_CACHE_COST)
	assert(not game.hideout_shop.pending_cache_item.is_empty())
	assert(game.rng.state == rng_before)
	assert(game.hideout_ui.presentation.chest_showcase_timer > 0.0)
	game.hideout_ui.presentation.set_process(false)
	for phase in [0.18, 0.52]:
		game.hideout_ui.presentation.chest_showcase_timer = 0.90 - phase
		game.hideout_ui.presentation.queue_redraw()
		if native: await capture("scavenged_closed" if phase < 0.2 else "scavenged_open")
	var pending: Dictionary = game.hideout_shop.pending_cache_item.duplicate(true)
	var count: int = game.inventory.stash.size()
	game.use_gold_cache()
	assert(game.inventory.stash.size() == count + 1)
	assert(game.inventory.stash.back().id == pending.id)
	assert(game.hideout_shop.pending_cache_item.is_empty())
	game.hideout_ui.show_stash()
	assert(game.hideout_ui.presentation.chest_showcase_timer == 0.0)
	game.start_run()
	game.set_process(false)
	game.wave = 8
	game.wave_kills = 0
	game.spawn_enemy()
	assert(game.enemy_is_miniboss)
	game.enemy_hp = 0
	game.kill_enemy()
	game.upgrade_panel.visible = false
	game.state = "playing"
	assert(game.loot_drops.size() == 1)
	assert(game.loot_drops[0].relic_chest)
	assert(game.loot_drops[0].pickup == 1.15)
	game.wave_banner_timer = 0
	game.presentation_director.toast_panel.visible = false
	for phase in [0.2, 0.55]:
		game.loot_drops[0].pickup = 1.15 * (1.0 - phase)
		game.enemy_death_anim = maxf(0.0, 0.68 - 1.15 * phase)
		game.queue_redraw()
		if native: await capture("relic_closed" if phase < 0.3 else "relic_open")
	game.loot_drops[0].pickup = 0.01
	game.update_effects(0.02)
	assert(game.loot_drops.is_empty() and game.pending_items.size() == 1)
	game.queue_free()
	await process_frame
	print("CHEST PRESENTATION QA PASSED: unchanged cache price/claim and RNG, no overlay leak, one miniboss item with original pickup deadline")
	quit(0)

func capture(label: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var shot := root.get_texture().get_image()
	assert(shot.get_size() == Vector2i(480, 854))
	assert(shot.save_png("res://.godot_test_data/%s_qa.png" % label) == OK)
