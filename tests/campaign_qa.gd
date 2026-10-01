extends SceneTree

const Campaign = preload("res://campaign_system.gd")
const Items = preload("res://item_catalog.gd")
var game
var native := false

func _initialize() -> void:
	native = "--visual" in OS.get_cmdline_user_args()
	call_deferred("run_qa")

func run_qa() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.show_hideout()
	game.gold = 1000
	game.inventory.scrap = 50
	game.refresh_hideout()
	game.hideout_ui.show_forge()
	if native:
		await capture("expansion_forge")
	game.hideout_ui.forge_confirm.pressed.emit()
	assert(game.hideout_ui.forge_armed)
	game.hideout_ui.forge_confirm.pressed.emit()
	assert(game.inventory.equipped_item("Weapon").evolution_stage == 1 and game.gold == 820)
	game.hideout_ui.show_campaign()
	assert(game.hideout_ui.campaign_list.get_child_count() == 10)
	if native:
		await capture("expansion_campaign")
		game.startup_ui.visible = true
		game.hideout_ui.visible = false
		game.startup_ui.show_lootling_select()
		game.startup_ui.cycle_lootling(1)
		await capture("expansion_character")
		game.startup_ui.visible = false
	game.show_hideout()
	game.campaign.completed.clear()
	game.campaign.finish("act_i")
	game.hideout_ui.show_campaign()
	game.hideout_ui.campaign_list.get_child(1).pressed.emit()
	assert(game.campaign_id == "mossglass_wilds", "Region card dispatches its own stable ID")
	await create_timer(1.0).timeout
	for region in Campaign.REGIONAL_VARIANTS:
		game.campaign_id = region
		game.wave = 3
		game.wave_kills = 0
		game.spawn_enemy()
		assert(game.enemy_variant_id == Campaign.REGIONAL_VARIANTS[region])
		if native: await capture("expansion_variant_" + region)
	if native and "--screens-only" in OS.get_cmdline_user_args():
		game.queue_free()
		await process_frame
		print("EXPANSION NATIVE SCREEN QA PASSED: Forge, campaign, identity and nine region variant cues")
		quit(0)
		return
	var weapons := ["scrapfang_blade", "bonebow", "glimmerstaff", "moonbite_daggers"]
	for region in Campaign.ORDER:
		if region == "act_i":
			continue
		var wins := 0
		for sample in range(4):
			game.inventory.reset_to_starter()
			game.inventory.equip(Items.create_item(weapons[sample], "COMMON", 500 + sample))
			game.meta_power = 0
			game.gold_upgrades = {"bedroll":0, "whetstone":0, "pouch":0}
			game.campaign_id = region
			seed(510000 + sample)
			game.start_run()
			game.rng.seed = 610000 + sample
			game.loot_system.rng.seed = 710000 + sample
			if native and sample == 0:
				await capture("expansion_" + region)
			var elapsed := 0.0
			var tap_clock := 0.0
			while game.state != "result" and elapsed < 300.0:
				match game.state:
					"upgrade": game.choose_upgrade(0)
					"item": game.accept_item_equip()
					"boss_reward": game.choose_boss_reward(0)
					"hoard_chest":
						game._process(0.08)
						if game.hoard_chest_phase == "ready": game.open_hoard_chest()
					"merchant": game.leave_merchant()
					_:
						game._process(0.05)
						tap_clock += 0.05
						if tap_clock >= 0.22:
							tap_clock = 0.0
							game.perform_player_attack(true)
				elapsed += 0.05
			assert(game.state == "result", "Campaign softlock: " + region)
			wins += 1 if game.player_hp > 0 else 0
			print("REGION RUN %s/%s wave=%d hp=%.1f time=%.1f" % [region, weapons[sample], game.wave, game.player_hp, elapsed])
		print("REGION TOTAL %s wins=%d/4" % [region, wins])
	# Controlled full victories verify every region's end/reward/unlock wiring.
	game.campaign.completed.clear()
	for region in Campaign.ORDER:
		game.campaign_id = region
		game.inventory.reset_to_starter()
		game.start_run()
		var guard := 0
		while game.state != "result" and guard < 1000:
			guard += 1
			match game.state:
				"upgrade": game.choose_upgrade(0)
				"item": game.accept_item_scrap()
				"boss_reward": game.choose_boss_reward(0)
				"hoard_chest":
					game._process(0.7)
					if game.hoard_chest_phase == "ready": game.open_hoard_chest()
				"merchant": game.leave_merchant()
				_:
					if game.enemy_alive: game.damage_enemy(game.enemy_hp * 10.0 + 1.0, false, false)
					game._process(0.2)
		assert(guard < 1000 and game.state == "result" and region in game.campaign.completed)
		game.show_hideout()
	print("CAMPAIGN QA PASSED: 36 seeded runs + 10 full reward/unlock paths; Forge UI confirmation")
	game.queue_free()
	await process_frame
	quit(0)

func capture(label: String) -> void:
	for frame in range(30): await process_frame
	var image := root.get_texture().get_image()
	assert(image.save_png("res://.godot_test_data/" + label + "_qa.png") == OK)
