extends SceneTree
const QA = preload("res://tests/evolution_qa.gd")
const Weapons = preload("res://weapon_catalog.gd")
const Items = preload("res://item_catalog.gd")
const Forge = preload("res://forge_system.gd")
var game

func _initialize() -> void:
	call_deferred("run_qa")

func simulate(family: String, stage: int) -> Dictionary:
	game.show_hideout()
	game.inventory.reset_to_starter()
	var item := Items.create_item(QA.base_id(family), "COMMON", 71)
	for step in range(stage): item = Forge.evolve(item)
	game.inventory.equip(item)
	game.campaign_id = "act_i"
	game.grouped_patrols = true
	game.meta_power = 0
	game.gold_upgrades = {"bedroll":0, "whetstone":0, "pouch":0}
	seed(91713)
	game.start_run()
	game.rng.seed = 91713
	game.loot_system.rng.seed = 81713
	game.tap_combo = 0
	game.combo_clock = 0
	var elapsed := 0.0
	var tap_clock := 0.0
	while game.state != "result" and elapsed < 320:
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
				tap_clock += 0.05
				if tap_clock >= 0.22:
					tap_clock = 0
					game.perform_player_attack(true)
		elapsed += 0.05
	assert(game.state == "result", "Evolution softlock: " + family)
	return {"victory":game.run_won, "hp":game.player_hp, "wave":game.wave, "time":elapsed, "kills":game.total_kills, "coins":game.coins}

func run_qa() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	var wins := [0, 0]
	for family in Weapons.live_ids():
		for stage in [0, 2]:
			var result := simulate(family, stage)
			assert(result == simulate(family, stage), "Non-deterministic evolution run: " + family)
			if result.victory: wins[0 if stage == 0 else 1] += 1
			print("EVOLUTION RUN %s stage=%d %s" % [family, stage, str(result)])
	print("EVOLUTION MATRIX PASSED: 48 complete seeded runs/repeats; stage-zero wins=%d/12 stage-two wins=%d/12" % [wins[0], wins[1]])
	game.queue_free()
	await process_frame
	quit(0)
