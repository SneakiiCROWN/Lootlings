extends SceneTree
const Items = preload("res://item_catalog.gd")
var game
var folder: String
var seen := {}
var real_trace := {}

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	assert(DisplayServer.get_name() != "headless")
	OS.set_environment("LOOTLINGS_MOBILE_TEST","1")
	call_deferred("review")

func capture(label: String) -> void:
	await create_timer(.4).timeout # Inspect the settled card, not its fade-in.
	game.queue_redraw(); await process_frame; await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(folder+label+".png") == OK)

func tap(control: Control) -> void:
	var physical: Vector2 = root.get_screen_transform()*control.get_global_rect().get_center()-Vector2(root.position)
	for pressed in [true,false]:
		var event := InputEventScreenTouch.new(); event.index = 0; event.pressed = pressed; event.position = physical
		Input.parse_input_event(event); await process_frame

func review() -> void:
	game = load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.app_lifecycle.platform_notifications_enabled = false; game.audio_settings.cinematic_first_time = false
	var size := OS.get_environment("LOOTLINGS_CAPTURE_SIZE").split("x")
	root.size = Vector2i(int(size[0]),int(size[1])); await process_frame
	folder = "res://.godot_test_data/rc/%dx%d/" % [root.size.x,root.size.y]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	# One full real-clock desktop run. Tablet reuses the unchanged combat
	# evidence and reviews only changed layouts/transactions, avoiding duplication.
	if root.size.x < 1500:
		game.inventory.reset_to_starter(); game.meta_power = 0
		game.gold_upgrades = {"bedroll":0,"whetstone":0,"pouch":0}
		seed(19283); game.rng.seed = 38192; game.loot_system.rng.seed = 81923
		game.start_run()
		var started := Time.get_ticks_msec(); var next_tap := 0
		var helper := preload("res://tests/combat_seed_diagnostics.gd").new()
		while game.state != "result" and Time.get_ticks_msec()-started < 240000:
			await process_frame
			var key := "%02d_%s" % [game.wave,game.state]
			if game.state in ["upgrade","event","merchant","boss_reward","hoard_chest"] and not seen.has(key):
				seen[key] = true; await capture("trace_"+key)
			match game.state:
				"upgrade": game.choose_upgrade(helper.pick_upgrade(game))
				"item":
					if game.current_item.slot != "Weapon" and Items.rarity_rank(game.current_item.rarity) >= Items.rarity_rank(game.inventory.equipped_item(game.current_item.slot).get("rarity","COMMON")): game.accept_item_equip()
					else: game.accept_item_scrap()
				"merchant":
					var index: int = helper.cheapest_affordable(game)
					if index >= 0 and game.shop.stock[index].slot != "Weapon": game.buy_merchant_item(index)
					else: game.leave_merchant()
				"event": game.choose_expedition_event(0 if not game.event_buttons[0].disabled else 2)
				"boss_reward": game.choose_boss_reward(0)
				"hoard_chest":
					if game.hoard_chest_phase == "ready": game.open_hoard_chest()
				"playing":
					if Time.get_ticks_msec() >= next_tap:
						game.request_tap_attack(); next_tap = Time.get_ticks_msec()+250
		assert(game.state == "result","Real-clock native trace must end without a softlock; a loss is a valid result")
		real_trace = {"seconds":(Time.get_ticks_msec()-started)/1000.0,"won":game.run_won,"wave":game.wave,"damage_taken":game.run_damage_taken,"report":game.mobile_test_monitor.report(),"qualification":"Native desktop real-clock run with scripted choices/taps; capture I/O and any concurrent QA affect timing. Not manual feel, listening or phone FPS."}
		helper.free(); await capture("trace_result")
	game.set_process(false); game.start_run(); game.wave_banner_timer = 0
	var attacks: int = game.attack_sequence
	await tap(game.pause_button); assert(game.state == "paused" and game.attack_sequence == attacks)
	await capture("pause_target")
	game.mobile_test_monitor.show_report(); await capture("device_report")
	game.mobile_test_monitor.report_panel.queue_free(); await process_frame; game.resume_run()
	game.enemy_alive = false; game.loot_drops.clear(); game.coins = 987654321; game.wave = 6
	game.show_merchant(); await capture("one_purchase_merchant")
	var coins: int = game.coins
	await tap(game.merchant_buttons[0]); assert(game.coins == coins and game.merchant_selection == 0)
	await capture("purchase_consequence")
	await create_timer(.3).timeout; await tap(game.merchant_buy_button)
	assert(game.state == "item" and game.attack_sequence == attacks)
	game.accept_item_scrap(); assert(game.state == "playing")
	game.pending_items = [Items.create_item("bonebow","RARE",991),Items.create_item("mossguard_harness","EPIC",992)]
	game.enemy_alive = false; game.item_review_due = true; game._process(.05)
	assert(game.normal_loot_choice and game.boss_reward_buttons[0].visible and not game.boss_reward_buttons[2].visible)
	await capture("two_wave_finds")
	await tap(game.boss_reward_buttons[1]); assert(is_instance_valid(game.touch_ux.dialog))
	await capture("find_consequence")
	await create_timer(.3).timeout; await tap(game.touch_ux.confirm_button)
	assert(game.current_item.serial == 992 and game.attack_sequence == attacks)
	game.accept_item_keep(); assert(game.pending_items.is_empty())
	game.prepare_hoard_chest(); game.show_boss_reward()
	# Large rune/armour icons previously covered the first rarity glyphs.
	for index in range(3):
		var icon_rect: Rect2 = game.boss_reward_icons[index].get_global_rect()
		var text_rect: Rect2 = game.boss_reward_visuals[index].kicker.get_global_rect()
		assert(icon_rect.end.x < text_rect.position.x)
	await capture("boss_hoard_icon_lane")
	if root.size.x >= 1500:
		var original_size := root.size; var original_folder := folder
		root.size = Vector2i(1080,2316); await process_frame; await process_frame
		folder = "res://.godot_test_data/rc/1080x2316/"
		await capture("boss_hoard_icon_lane")
		root.size = original_size; folder = original_folder
		await process_frame; await process_frame
	var file := FileAccess.open(folder+"review.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"real_trace":real_trace,"size":str(root.size),"seen":seen,"changed_touch_contracts":true},"  ")); file.close()
	game.free(); await process_frame
	print("RC NATIVE REVIEW PASSED: real-clock trace where requested, changed reward/confirmation/Pause/report screens and actual touch ownership")
	quit()
