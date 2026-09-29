extends SceneTree

const ItemCatalog = preload("res://item_catalog.gd")

const WEAPONS := {
	"VANGUARD":"scrapfang_blade",
	"RANGER":"bonebow",
	"MAGE":"glimmerstaff",
	"ROGUE":"moonbite_daggers"
}
const CORES := ["Fire", "Lightning", "Poison", "Physical"]
const SEEDS_PER_PAIR := 3

func _initialize() -> void:
	call_deferred("run_audit")

func run_audit() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	var totals := {}
	var completed := 0
	for weapon_family in WEAPONS:
		for core_identity in CORES:
			var key := "%s/%s" % [weapon_family, core_identity]
			totals[key] = {"runs":0, "wins":0, "time":0.0, "level":0, "hp":0.0, "coins":0, "spent":0, "scrap":0, "kills":0, "purchases":0}
			for sample in range(SEEDS_PER_PAIR):
				game.inventory.reset_to_starter()
				game.inventory.equip(ItemCatalog.create_item(WEAPONS[weapon_family], "COMMON", 700000 + completed))
				game.meta_power = 0
				game.meta_shards = 0
				seed(510000 + completed)
				game.start_run()
				game.rng.seed = 610000 + completed
				game.loot_system.rng.seed = 710000 + completed
				var elapsed := 0.0
				var tap_clock := 0.0
				var purchased_wave := -1
				var purchases := 0
				while game.state != "result" and elapsed < 300.0:
					match game.state:
						"upgrade": game.choose_upgrade(pick_core_upgrade(game, core_identity))
						"item": game.accept_item_scrap()
						"boss_reward": game.choose_boss_reward(0)
						"merchant":
							var bought := false
							if purchased_wave != game.wave:
								for offer_index in range(game.shop.stock.size()):
									if int(game.shop.stock[offer_index].price) <= game.coins:
										game.buy_merchant_item(offer_index)
										purchased_wave = game.wave
										purchases += 1
										bought = true
										break
							if not bought:
								game.leave_merchant()
						_:
							game._process(0.05)
							tap_clock += 0.05
							if tap_clock >= 0.22:
								tap_clock = 0.0
								game.perform_player_attack(true)
					elapsed += 0.05
				var row: Dictionary = totals[key]
				row.runs += 1
				row.wins += 1 if game.state == "result" and game.player_hp > 0.0 and game.wave == game.RUN_LAST_WAVE else 0
				row.time += elapsed
				row.level += game.level
				row.hp += game.player_hp
				row.coins += game.run_coins_earned
				row.spent += game.run_coins_spent
				row.scrap += game.inventory.scrap
				row.kills += game.total_kills
				row.purchases += purchases
				totals[key] = row
				completed += 1
	for key in totals:
		var row: Dictionary = totals[key]
		var count := float(row.runs)
		print("AUDIT %s runs=%d wins=%d avg_time=%.1fs avg_level=%.1f avg_hp=%.1f avg_coins=%.1f avg_spent=%.1f avg_scrap=%.1f avg_kills=%.1f purchases=%d" % [key, row.runs, row.wins, row.time / count, float(row.level) / count, row.hp / count, float(row.coins) / count, float(row.spent) / count, float(row.scrap) / count, float(row.kills) / count, row.purchases])
	game.queue_free()
	await process_frame
	print("BALANCE AUDIT COMPLETE: %d deterministic runs" % completed)
	quit(0 if completed == WEAPONS.size() * CORES.size() * SEEDS_PER_PAIR else 1)

func pick_core_upgrade(game, core_identity: String) -> int:
	for index in range(game.selected_upgrades.size()):
		if core_identity in game.selected_upgrades[index].tags:
			return index
	return 0
