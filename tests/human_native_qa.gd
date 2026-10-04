extends SceneTree
var game
var folder := ""
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	assert(DisplayServer.get_name() != "headless")
	OS.set_environment("LOOTLINGS_MOBILE_TEST","1")
	call_deferred("review")
func capture(label: String) -> void:
	await create_timer(.4).timeout
	game.queue_redraw(); await process_frame; await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(folder+label+".png") == OK)
func tap(control: Control) -> void:
	var physical: Vector2 = root.get_screen_transform()*control.get_global_rect().get_center()-Vector2(root.position)
	for pressed in [true,false]:
		var event := InputEventScreenTouch.new(); event.index = 0; event.pressed = pressed; event.position = physical
		Input.parse_input_event(event); Input.flush_buffered_events(); await process_frame
func review() -> void:
	for size in [Vector2i(1080,2316),Vector2i(1600,2560)]:
		root.size = size
		game = load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
		game.set_process(false); game.audio_settings.cinematic_first_time = false
		game.app_lifecycle.platform_notifications_enabled = false
		folder = "res://.godot_test_data/humanqa/%dx%d/" % [size.x,size.y]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game.show_hideout(); game.hideout_ui.show_home()
		assert(not game.hideout_ui.speech_panel.visible and not game.hideout_ui.loadout_panel.visible)
		await capture("hub")
		game.hideout_ui.request_dialogue("tapped","Mascot"); assert(game.hideout_ui.speech_panel.visible)
		await capture("selected_resident")
		game.hideout_ui.show_shop(); await capture("stall")
		assert(game.hideout_ui.shop_gold_cache_button.get_global_rect().end.x < game.hideout_ui.shop_cache_button.get_global_rect().position.x)
		assert(game.hideout_ui.shop_cache_button.get_global_rect().end.x < game.hideout_ui.shop_expansion_button.get_global_rect().position.x)
		game.hideout_ui.show_memories(); await capture("archive")
		game.show_profile_from_hideout(); await capture("profile")
		assert(not game.startup_ui.profile_id_label.is_visible_in_tree())
		game.startup_ui.show_settings(); await capture("settings")
		game.startup_ui.support_panel.visible = true; await capture("support")
		assert(game.startup_ui.profile_id_label.is_visible_in_tree())
		game.startup_ui.show_settings(); assert(not game.startup_ui.support_panel.visible)
		game.startup_ui.visible = false; game.hideout_ui.visible = false
		seed(28192); game.rng.seed = 31982; game.start_run(); game.set_process(false)
		game.wave_banner_timer = 0; game.player_x = game.target_player_x()
		game.perform_player_attack(false); game.add_float("ARC",Vector2.ZERO,Color.WHITE,16)
		await capture("combat")
		var attacks: int = game.attack_sequence
		game.show_upgrade_choices(); await capture("pick_one")
		await tap(game.upgrade_buttons[0]); assert(game.state == "upgrade" and game.upgrade_selection == 0 and not is_instance_valid(game.touch_ux.dialog))
		await tap(game.upgrade_take_button); assert(game.state == "upgrade")
		await capture("pick_selected"); await tap(game.upgrade_take_button)
		assert(game.state != "upgrade" and game.attack_sequence == attacks)
		game.wave = 6; game.coins = 1000; game.show_merchant()
		var original: int = game.coins; var cost: int = game.shop.reroll_cost(6)
		game.reroll_merchant(); assert(game.coins == original-cost and game.merchant_selection == -1)
		game.leave_merchant(); assert(game.state == "playing" and not game.shop.purchase_taken)
		game.wave = 11; game.show_merchant(); await capture("merchant")
		var held: int = game.coins; var price: int = game.shop.stock[2].price
		assert(game.ItemCatalog.rarity_rank(game.shop.stock[2].rarity) >= 2)
		await tap(game.merchant_buttons[2]); await tap(game.merchant_buttons[2]); assert(game.coins == held and not is_instance_valid(game.touch_ux.dialog))
		await tap(game.merchant_buy_button); assert(game.coins == held)
		await capture("merchant_selected"); await tap(game.merchant_buy_button)
		assert(game.state == "item" and game.coins == held-price)
		game.buy_selected_merchant(); game.buy_merchant_item(0); game.reroll_merchant(); assert(game.coins == held-price)
		game.accept_item_scrap(); assert(game.state == "playing" and game.shop.purchase_taken and game.attack_sequence == attacks)
		for id in ["sealed_cache","cursed_coffer"]:
			game.wave = 12; game.coins = 700; game.event_seen = game.ExpeditionEvents.EVENTS.keys().filter(func(key): return key != id)
			game.show_expedition_event(); assert(game.event_id == id)
			await capture("event_"+id)
			game.choose_expedition_event(1); var wallet: int = game.coins
			game.choose_expedition_event(1); assert(game.coins == wallet and game.event_risk == 1)
			assert(game.ItemCatalog.rarity_rank(game.pending_items.back().rarity) >= 2)
			game.pending_items.clear()
		game.free(); await process_frame; await process_frame
	print("HUMAN NATIVE QA PASSED: two layouts; touch selection/footer/debounce; reroll/skip/one purchase/resume; premium/events; quiet hub/profile; native captures")
	quit()
