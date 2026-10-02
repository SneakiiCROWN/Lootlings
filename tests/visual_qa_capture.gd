extends SceneTree

const ItemCatalog = preload("res://item_catalog.gd")
const AffixCatalog = preload("res://affix_catalog.gd")
const FoundationUI = preload("res://lootlings_ui.gd")

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("capture_screens")

func capture_screens() -> void:
	var packed := load("res://main.tscn") as PackedScene
	if packed == null:
		quit(1)
		return
	var game = packed.instantiate()
	root.add_child(game)
	await wait_frames(4)
	game.show_startup()
	game.startup_ui.show_boot()
	await create_timer(0.35).timeout
	await wait_frames(8)
	if not save_viewport("boot_qa.png"):
		quit(1)
		return
	game.startup_ui.show_title()
	await wait_frames(24)
	if not save_viewport("title_qa.png"):
		quit(1)
		return
	game.startup_ui.show_profile(false)
	await wait_frames(24)
	if not save_viewport("profile_qa.png"):
		quit(1)
		return
	game.startup_ui.name_edit.grab_focus()
	await wait_frames(4)
	if not save_viewport("profile_focus_qa.png"):
		quit(1)
		return
	game.startup_ui.name_edit.release_focus()
	game.startup_ui.show_settings()
	await wait_frames(24)
	if not save_viewport("settings_qa.png"):
		quit(1)
		return
	game.startup_ui.show_lootling_select()
	await wait_frames(24)
	if not save_viewport("lootling_select_qa.png"):
		quit(1)
		return
	game.show_hideout()
	await wait_frames(24)
	if not save_viewport("hideout_home_qa.png"):
		quit(1)
		return
	game.hideout_ui.show_achievements()
	game.achievements.unlock("first_steps")
	game.hideout_ui.refresh_achievements()
	await wait_frames(24)
	if not save_viewport("trophy_archive_qa.png"):
		quit(1)
		return
	game.hideout_ui.select_achievement("hideout_social")
	await wait_frames(2)
	if not save_viewport("trophy_long_detail_qa.png"):
		quit(1)
		return
	game.hideout_ui.show_shop()
	await wait_frames(24)
	if not save_viewport("hideout_shop_qa.png"):
		quit(1)
		return
	game.hideout_ui.select_shop_offer(0)
	await wait_frames(24)
	if not save_viewport("shop_selected_qa.png"):
		quit(1)
		return
	game.hideout_ui.show_stash()
	await wait_frames(24)
	if not save_viewport("stash_qa.png"):
		quit(1)
		return
	game.hideout_ui.show_upgrades()
	await wait_frames(24)
	if not save_viewport("relic_training_qa.png"):
		quit(1)
		return
	for destination in ["campaign","forge","contracts","memories","lore"]:
		game.hideout_ui.call("show_"+destination)
		await wait_frames(24)
		if not save_viewport("material_%s_qa.png" % destination):
			quit(1)
			return
	game.start_run()
	game.wave = 12
	game.wave_kills = 0
	game.last_spawned_wave = 0
	game.spawn_enemy()
	game.debug_force_variant("rootbound")
	game.wave_banner_timer = 0.0
	await wait_frames(12)
	if not save_viewport("combat_variant_qa.png"):
		quit(1)
		return
	game.set_process(false)
	game.enemy_burn_dps = 1.0
	game.enemy_poison_stacks = 3
	game.add_float("CRIT! 123", Vector2(270, 388), Color("#ffe178"), 24)
	game.add_float("QUAKE 87", Vector2(240, 430), Color("#edbfff"), 20)
	game.queue_redraw()
	await wait_frames(2)
	await RenderingServer.frame_post_draw
	if not save_viewport("wave2_status_feedback_qa.png"):
		quit(1)
		return
	game.enemy_burn_dps = 0.0
	game.enemy_poison_stacks = 0
	game.floating_texts.clear()
	game.set_process(false)
	var old_hp: float = game.player_hp
	var old_xp: float = game.xp
	var old_enemy_hp: float = game.enemy_hp
	for ratio in [0.0, 0.01, 0.5]:
		game.player_hp = game.player_max_hp * ratio
		game.xp = game.xp_needed * ratio
		game.enemy_hp = game.enemy_max_hp * ratio
		game.queue_redraw()
		await wait_frames(2)
		await RenderingServer.frame_post_draw
		if not save_viewport("meter_%d_qa.png" % int(ratio * 100)):
			quit(1)
			return
	game.player_hp = old_hp
	game.xp = old_xp
	game.enemy_hp = old_enemy_hp
	game.debug_weapon_family_override = "RANGER"
	game.set_process(false)
	game.player_x = game.target_player_x()
	game.perform_player_attack(false)
	game.update_attack_projectiles(0.095)
	if game.attack_projectiles.is_empty():
		push_error("VISUAL QA: Ranger release did not produce an arrow")
		quit(1)
		return
	game.queue_redraw()
	await wait_frames(2)
	await RenderingServer.frame_post_draw
	if not save_viewport("ranger_release_qa.png"):
		quit(1)
		return
	game.attack_projectiles.clear()
	game.debug_weapon_family_override = "MAGE"
	game.perform_player_attack(false)
	game.update_attack_projectiles(0.10)
	game.queue_redraw()
	await wait_frames(2)
	await RenderingServer.frame_post_draw
	if not save_viewport("mage_release_qa.png"):
		quit(1)
		return
	game.attack_projectiles.clear()
	game.set_process(true)
	game.show_upgrade_choices()
	await wait_frames(24)
	if not save_viewport("level_up_qa.png"):
		quit(1)
		return
	game.upgrade_panel.visible = false
	game.state = "playing"
	game.show_merchant()
	await wait_frames(24)
	if not save_viewport("pack_peddler_qa.png"):
		quit(1)
		return
	game.merchant_panel.visible = false
	game.state = "playing"
	game.pause_run()
	await wait_frames(8)
	if not save_viewport("pause_qa.png"):
		quit(1)
		return
	game.resume_run()
	var preview := ItemCatalog.create_item("moonbranch", "LEGENDARY", 99002)
	preview = AffixCatalog.apply(preview, ["keen", "frostbell_chime"])
	game.pending_items = [preview]
	game.show_next_item()
	await wait_frames(24)
	if not save_viewport("signature_loot_qa.png"):
		quit(1)
		return
	game.item_panel.visible = false
	game.state = "playing"
	game.debug_action("hoard", null)
	game.update_hoard_chest(0.62)
	await wait_frames(8)
	if not save_viewport("hoard_chest_qa.png"):
		quit(1)
		return
	game.set_process(false)
	game.open_hoard_chest()
	game.update_hoard_chest(0.30)
	game.queue_redraw()
	await wait_frames(2)
	await RenderingServer.frame_post_draw
	if not save_viewport("hoard_windup_qa.png"):
		quit(1)
		return
	game.update_hoard_chest(1.0)
	game.update_hoard_chest(1.0)
	if game.loot_drops.size() != 3:
		push_error("VISUAL QA: Hoard opening did not eject exactly three rewards")
		quit(1)
		return
	game.update_effects(0.20)
	game.queue_redraw()
	await wait_frames(2)
	await RenderingServer.frame_post_draw
	if not save_viewport("hoard_ejection_qa.png"):
		quit(1)
		return
	game.loot_drops.clear()
	game.set_process(true)
	game.show_boss_reward()
	await wait_frames(24)
	if not save_viewport("boss_hoard_qa.png"):
		quit(1)
		return
	game.boss_reward_panel.visible = false
	game.debug_show_result(true)
	# Exercise real summary typography with large totals without granting rewards.
	game.result_summary.text = game.style_result_summary(game.format_result_summary(true, 15, 46, 9999, 8888, 1111, 7777, 6666, "A Very Long Legendary Item Name", 9999))
	await wait_frames(8)
	if not save_viewport("results_qa.png"):
		quit(1)
		return
	game.debug_show_result(false)
	game.result_summary.text = game.style_result_summary(game.format_result_summary(false, 8, 24, 352, 190, 162, 21, 4, "None", 75))
	await wait_frames(8)
	if not save_viewport("defeat_qa.png"):
		quit(1)
		return
	var fixture := Control.new()
	fixture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game.add_child(fixture)
	var background := ColorRect.new()
	background.color = Color("#0b1430")
	background.size = Vector2(480, 854)
	fixture.add_child(background)
	var intents := ["primary", "secondary", "destructive"]
	var states := ["normal", "hover", "pressed", "disabled", "focus"]
	for column in range(3):
		for row in range(5):
			var button := Button.new()
			button.position = Vector2(14 + column * 154, 30 + row * 159)
			button.size = Vector2(140, 126)
			button.text = "%s\n%s" % [intents[column].to_upper(), states[row].to_upper()]
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.add_theme_font_size_override("font_size", 12)
			button.set_meta("ui_intent", intents[column])
			FoundationUI.apply_button(button, Color.WHITE, Color.WHITE)
			button.add_theme_stylebox_override("normal", button.get_theme_stylebox(states[row]))
			button.disabled = states[row] == "disabled"
			fixture.add_child(button)
	await wait_frames(4)
	if not save_viewport("foundation_button_states_qa.png"):
		quit(1)
		return
	fixture.queue_free()
	print("VISUAL QA CAPTURED: major Hideout, combat, reward, pause and results states at %s" % root.content_scale_size)
	game.queue_free()
	await process_frame
	await process_frame
	quit(0)

func wait_frames(count: int) -> void:
	# Observe settled production surfaces instead of a partially faded transition.
	if count >= 8:
		await create_timer(0.36).timeout
	for frame in range(count):
		await process_frame
		# Forced state jumps happen faster than a real run; unrelated pending
		# achievement toasts must not conceal the screen under review.
		var game = root.get_child(root.get_child_count() - 1)
		if game.presentation_director.toast_tween != null:
			game.presentation_director.toast_tween.kill()
		game.presentation_director.toast_panel.visible = false

func save_viewport(file_name: String) -> bool:
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("VISUAL QA: viewport image unavailable")
		return false
	var path := ProjectSettings.globalize_path("res://.godot_test_data/%s" % file_name)
	var error := image.save_png(path)
	if error != OK:
		push_error("VISUAL QA: failed to save %s (%d)" % [path, error])
		return false
	return true
