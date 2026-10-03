extends SceneTree
const Items = preload("res://item_catalog.gd")
var game

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("run_qa")

func simulate(weapon: String, run_seed: int, groups: bool) -> Dictionary:
	game.inventory.reset_to_starter()
	game.inventory.equip(Items.create_item(weapon, "COMMON", 7))
	game.meta_power = 0
	game.gold_upgrades = {"bedroll":0, "whetstone":0, "pouch":0}
	game.campaign_id = "act_i"
	game.grouped_patrols = groups
	game.rng.seed = run_seed
	game.loot_system.rng.seed = run_seed + 200
	seed(run_seed)
	game.start_run()
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
			"event": game.choose_expedition_event(2)
			"merchant": game.leave_merchant()
			_:
				game._process(0.05)
				taps += 0.05
				if taps >= 0.22:
					taps = 0.0
					game.perform_player_attack(true)
		elapsed += 0.05
		assert(game.enemy_encounter.actors.size() <= 3)
	assert(game.state == "result", "Encounter softlock: " + weapon)
	return {"victory":game.run_won, "wave":game.wave, "hp":snappedf(game.player_hp, 0.01), "time":snappedf(elapsed, 0.01), "kills":game.total_kills, "coins":game.run_coins_earned, "scrap":game.inventory.scrap}

func run_qa() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	var solo_wins := 0
	var group_wins := 0
	for weapon in ["scrapfang_blade", "bonebow", "glimmerstaff", "moonbite_daggers"]:
		for sample in range(3):
			var run_seed := 71501 + sample
			var solo := simulate(weapon, run_seed, false)
			var group := simulate(weapon, run_seed, true)
			var repeat := simulate(weapon, run_seed, true)
			assert(group == repeat, "Group encounter must be deterministic independently of visual RNG")
			solo_wins += 1 if solo.victory else 0
			group_wins += 1 if group.victory else 0
			print("GROUP MATRIX %s/%d solo=%s group=%s" % [weapon, sample, solo, group])
	print("ENCOUNTER MATRIX PASSED: 12 solo + 24 group deterministic full runs; wins solo=%d/12 groups=%d/12" % [solo_wins, group_wins])
	game.queue_free()
	await process_frame
	quit(0)
