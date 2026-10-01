extends SceneTree
const Weapons = preload("res://weapon_catalog.gd")
const Items = preload("res://item_catalog.gd")
var game

func _initialize() -> void:
	call_deferred("run_qa")

func prepare(weapon_type: String, sequence: int = 0) -> void:
	game.inventory.reset_to_starter()
	var item := Items.create_item(Weapons.starter(weapon_type).id, "COMMON", 200)
	game.inventory.equip(item)
	game.campaign_id = "act_i"
	game.start_run()
	game.enemy_hp = 10000.0
	game.enemy_max_hp = 10000.0
	game.enemy_hit_multiplier = 1.0
	game.enemy_variant_guarded = false
	game.enemy_variant_id = ""
	game.player_x = game.target_player_x()
	game.attack_sequence = sequence
	game.crit_chance = 0.0
	game.rng.seed = 777
	game.inventory.equipped.Weapon.effects = {}

func run_qa() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	prepare("greataxe", 2)
	game.resolve_player_attack(false)
	var chop: float = 10000.0 - game.enemy_hp
	prepare("greataxe", 0)
	game.resolve_player_attack(false)
	assert(is_equal_approx(chop / (10000.0 - game.enemy_hp), 1.45))
	prepare("spear")
	game.resolve_player_attack(false)
	var opening: float = 10000.0 - game.enemy_hp
	game.enemy_hp = 10000.0
	game.rng.seed = 777
	game.resolve_player_attack(false)
	assert(is_equal_approx(opening / (10000.0 - game.enemy_hp), 1.30))
	prepare("claws")
	game.resolve_player_attack(false)
	assert(game.floating_texts.size() >= 2)
	prepare("crossbow", 2)
	game.resolve_player_attack(false)
	assert(game.floating_texts.size() >= 2)
	prepare("sling", 2)
	game.enemy_attack_clock = 3.0
	game.resolve_player_attack(false)
	assert(is_equal_approx(game.enemy_attack_clock, 3.18))
	prepare("orb", 3)
	game.player_hp = 50.0
	game.resolve_player_attack(false)
	assert(is_equal_approx(game.player_hp, 52.0))
	prepare("wand", 2)
	game.inventory.equipped.Weapon.effects = {"repeat_every":3}
	game.resolve_player_attack(false)
	assert(10000.0 - game.enemy_hp > game.base_damage * 1.45)
	for weapon_type in Weapons.STARTERS:
		prepare(weapon_type)
		game.perform_player_attack(false)
		if game.current_weapon_family() in ["RANGER", "MAGE"]:
			assert(game.attack_projectiles.size() == 1)
			assert(game.attack_projectiles[0].weapon_type == weapon_type)
			game.update_attack_projectiles(0.5)
			assert(game.attack_projectiles.is_empty() and game.enemy_hp < 10000.0)
		if "--visual" in OS.get_cmdline_user_args():
			game.perform_player_attack(false)
			game.update_attack_projectiles(0.04)
			game.queue_redraw()
			for frame in range(30): await process_frame
			assert(root.get_texture().get_image().save_png("res://.godot_test_data/weapon_combat_" + weapon_type + "_qa.png") == OK)
			game.show_hideout()
			game.gold = 1000
			game.inventory.scrap = 100
			game.refresh_hideout()
			game.hideout_ui.show_forge()
			game.hideout_ui.select_forge_recipe(weapon_type)
			for frame in range(30): await process_frame
			assert(root.get_texture().get_image().save_png("res://.godot_test_data/weapon_" + weapon_type + "_qa.png") == OK)
	for weapon_type in Weapons.STARTERS:
		game.inventory.reset_to_starter()
		game.inventory.equip(Items.create_item(Weapons.starter(weapon_type).id, "COMMON", 400))
		game.meta_power = 0
		game.gold_upgrades = {"bedroll":0, "whetstone":0, "pouch":0}
		seed(91001)
		game.start_run()
		game.rng.seed = 91001
		game.loot_system.rng.seed = 81001
		var elapsed := 0.0
		var taps := 0.0
		while game.state != "result" and elapsed < 300.0:
			match game.state:
				"upgrade": game.choose_upgrade(0)
				"item": game.accept_item_scrap()
				"boss_reward": game.choose_boss_reward(0)
				"hoard_chest":
					game._process(0.08)
					if game.hoard_chest_phase == "ready": game.open_hoard_chest()
				"merchant": game.leave_merchant()
				_:
					game._process(0.05)
					taps += 0.05
					if taps >= 0.22:
						taps = 0.0
						game.perform_player_attack(true)
			elapsed += 0.05
		assert(game.state == "result", "New weapon softlock: " + weapon_type)
		print("WEAPON RUN %s wave=%d hp=%.1f time=%.1f" % [weapon_type, game.wave, game.player_hp, elapsed])
	print("WEAPON EXPANSION PASSED: seven actual hooks, per-foe opener, projectile resolution/origin profiles, Forge recipes and seven seeded complete runs")
	game.queue_free()
	await process_frame
	quit(0)
