extends SceneTree

const ItemCatalog = preload("res://item_catalog.gd")

const WEAPONS := {
	"VANGUARD":"scrapfang_blade",
	"RANGER":"bonebow",
	"MAGE":"glimmerstaff",
	"ROGUE":"moonbite_daggers"
}
const CORES := ["Fire", "Lightning", "Poison", "Physical"]
const SEEDS_PER_PAIR := 6

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
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
			totals[key] = {"runs":0, "wins":0, "time":0.0, "wave":0, "level":0, "hp":0.0, "damage_taken":0.0, "earned":0, "spent":0, "left":0, "scrap":0, "kills":0, "purchases":0, "rerolls":0, "xp":0.0, "upgrades":0, "awaken":0.0, "ascend":0.0, "lifesteal":0.0, "regen":0.0, "plague":0}
			for sample in range(SEEDS_PER_PAIR):
				game.inventory.reset_to_starter()
				game.inventory.equip(ItemCatalog.create_item(WEAPONS[weapon_family], "COMMON", 700000 + completed))
				game.meta_power = 0
				game.meta_shards = 0
				game.gold_upgrades = {"bedroll":0, "whetstone":0, "pouch":0}
				seed(510000 + completed)
				game.start_run()
				game.rng.seed = 610000 + completed
				game.loot_system.rng.seed = 710000 + completed
				var elapsed := 0.0
				var tap_clock := 0.0
				var purchases := 0
				var rerolls := 0
				var purchases_by_wave := {}
				var rerolled_waves := {}
				var awaken_time := -1.0
				var ascend_time := -1.0
				while game.state != "result" and elapsed < 300.0:
					match game.state:
						"upgrade": game.choose_upgrade(pick_core_upgrade(game, core_identity))
						"item": game.accept_item_scrap()
						"boss_reward": game.choose_boss_reward(0)
						"hoard_chest":
							game._process(0.08)
							if game.hoard_chest_phase == "ready":
								game.open_hoard_chest()
						"merchant":
							var buys_this_stop := int(purchases_by_wave.get(game.wave, 0))
							var affordable_index := cheapest_affordable_offer(game)
							if buys_this_stop < 2 and affordable_index >= 0:
								game.buy_merchant_item(affordable_index)
								purchases_by_wave[game.wave] = buys_this_stop + 1
								purchases += 1
							elif buys_this_stop < 2 and not rerolled_waves.has(game.wave) and game.coins >= game.shop.reroll_cost(game.wave):
								game.reroll_merchant()
								rerolled_waves[game.wave] = true
								rerolls += 1
							else:
								game.leave_merchant()
						_:
							game._process(0.05)
							tap_clock += 0.05
							if tap_clock >= 0.22:
								tap_clock = 0.0
								game.perform_player_attack(true)
					if awaken_time < 0.0 and game.build.tier(core_identity) >= 1:
						awaken_time = elapsed
					if ascend_time < 0.0 and game.build.tier(core_identity) >= 2:
						ascend_time = elapsed
					elapsed += 0.05
				var row: Dictionary = totals[key]
				row.runs += 1
				row.wins += 1 if game.state == "result" and game.run_won else 0
				row.time += elapsed
				row.wave += game.wave
				row.level += game.level
				row.hp += game.player_hp
				row.damage_taken += game.run_damage_taken
				row.earned += game.run_coins_earned
				row.spent += game.run_coins_spent
				row.left += game.coins
				row.scrap += game.inventory.scrap
				row.kills += game.total_kills
				row.purchases += purchases
				row.rerolls += rerolls
				row.xp += game.xp
				row.upgrades += game.build.upgrade_total
				row.awaken += awaken_time if awaken_time >= 0.0 else elapsed
				row.ascend += ascend_time if ascend_time >= 0.0 else elapsed
				row.lifesteal += game.life_steal
				row.regen += game.regen_per_second
				row.plague += game.plague_power
				totals[key] = row
				completed += 1
	for key in totals:
		var row: Dictionary = totals[key]
		var count := float(row.runs)
		print("AUDIT %s runs=%d wins=%d avg_time=%.1fs wave=%.1f level=%.1f hp=%.1f dmg_taken=%.1f earned=%.1f spent=%.1f left=%.1f buys=%.1f rerolls=%.1f scrap=%.1f xp=%.1f upgrades=%.1f awaken=%.1fs ascend=%.1fs leech=%.3f regen=%.2f plague=%.1f" % [key, row.runs, row.wins, row.time / count, float(row.wave) / count, float(row.level) / count, row.hp / count, row.damage_taken / count, float(row.earned) / count, float(row.spent) / count, float(row.left) / count, float(row.purchases) / count, float(row.rerolls) / count, float(row.scrap) / count, row.xp / count, float(row.upgrades) / count, row.awaken / count, row.ascend / count, row.lifesteal / count, row.regen / count, float(row.plague) / count])
	game.queue_free()
	await process_frame
	print("BALANCE AUDIT COMPLETE: %d deterministic runs" % completed)
	quit(0 if completed == WEAPONS.size() * CORES.size() * SEEDS_PER_PAIR else 1)

func pick_core_upgrade(game, core_identity: String) -> int:
	for index in range(game.selected_upgrades.size()):
		if core_identity in game.selected_upgrades[index].tags:
			return index
	return 0

func cheapest_affordable_offer(game) -> int:
	var result := -1
	var lowest_price := 999999
	for offer_index in range(game.shop.stock.size()):
		var price := int(game.shop.stock[offer_index].price)
		if price <= game.coins and price < lowest_price:
			lowest_price = price
			result = offer_index
	return result
