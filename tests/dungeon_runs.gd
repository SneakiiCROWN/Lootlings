extends SceneTree
const Items = preload("res://item_catalog.gd")
var game

func _initialize() -> void:
	call_deferred("run_qa")

func simulate(weapon: String, run_seed: int, greedy: bool = false) -> Dictionary:
	game.show_hideout()
	game.inventory.reset_to_starter()
	game.inventory.equip(Items.create_item(weapon, "COMMON", 7))
	game.meta_power = 0
	game.gold_upgrades = {"bedroll":0, "whetstone":0, "pouch":0}
	game.campaign_id = "act_i"
	game.grouped_patrols = false
	game.dungeon.setup(run_seed)
	game.start_run()
	var elapsed := 0.0
	var taps := 0.0
	var wanted := ["Combat", "Rest", "Elite", "Shrine", "Combat", "Rest", "Combat", "Boss"]
	if greedy: wanted = ["Combat", "Merchant", "Elite", "Treasure", "Risk", "Merchant", "Elite", "Boss"]
	var bought_rooms: Dictionary = {}
	while game.state != "result" and elapsed < 300:
		match game.state:
			"route":
				var index := 0
				var options: Array = game.dungeon.choices()
				for candidate in range(options.size()):
					if options[candidate].kind == wanted[game.dungeon.depth + 1]: index = candidate
				# Simulations omit only the presentation tween, not room semantics.
				game.dungeon.choose(index)
				game.route_panel.visible = false
				game.enter_route_room()
			"upgrade": game.choose_upgrade(0)
			"item": game.accept_item_equip()
			"boss_reward": game.choose_boss_reward(0)
			"merchant":
				var purchase := -1
				if not bought_rooms.has(game.dungeon.depth):
					for index in range(game.shop.stock.size()):
						if game.shop.stock[index].price <= game.coins: purchase = index
				bought_rooms[game.dungeon.depth] = true
				if purchase >= 0: game.buy_merchant_item(purchase)
				else: game.leave_merchant()
			"hoard_chest":
				game._process(0.08)
				if game.hoard_chest_phase == "ready": game.open_hoard_chest()
			_:
				game._process(0.05)
				taps += 0.05
				if taps >= 0.22:
					taps = 0
					game.perform_player_attack(true)
		elapsed += 0.05
	assert(game.state == "result", "Seeded route softlock: " + weapon)
	return {"room":game.dungeon.depth + 1, "hp":snappedf(game.player_hp, 0.01), "time":snappedf(elapsed, 0.01), "kills":game.total_kills, "gold":game.run_gold_earned, "shards":game.run_shards_earned}

func run_qa() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	var wins := 0
	var greedy_wins := 0
	for weapon in ["scrapfang_blade", "bonebow", "glimmerstaff", "moonbite_daggers"]:
		for sample in range(3):
			var result := simulate(weapon, 4917 + sample)
			var repeated := simulate(weapon, 4917 + sample)
			assert(result == repeated, "Route must repeat: %s vs %s" % [result, repeated])
			wins += 1 if result.hp > 0 else 0
			print("ROUTE RUN %s/%d %s" % [weapon, sample, result])
			var greedy := simulate(weapon, 4917 + sample, true)
			assert(greedy == simulate(weapon, 4917 + sample, true))
			greedy_wins += 1 if greedy.hp > 0 else 0
			print("GREEDY ROUTE %s/%d %s" % [weapon, sample, greedy])
	print("DUNGEON MATRIX PASSED: 48 seeded full runs/repeats; balanced wins=%d/12 greedy wins=%d/12" % [wins, greedy_wins])
	game.queue_free()
	await process_frame
	quit(0)
