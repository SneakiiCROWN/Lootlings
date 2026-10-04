extends SceneTree

# Characterizes the old smoke bot; it is not a player win-rate target.
# All randomness is seeded BEFORE start_run, with a new game for every run.
const SEEDS := 5
var failures: Array[String] = []

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("run_diagnostics")

func run_diagnostics() -> void:
	var packed := load("res://main.tscn") as PackedScene
	for policy in ["smoke", "survival", "merchant"]:
		var first_pass: Array = []
		var wins := 0
		for repeat in range(2):
			for sample in range(SEEDS):
				var game = packed.instantiate()
				root.add_child(game)
				game.set_process(false)
				game.inventory.reset_to_starter()
				game.meta_power = 0
				game.meta_shards = 0
				game.gold_upgrades = {"bedroll":0, "whetstone":0, "pouch":0}
				game.campaign_id = "act_i"
				game.profile.avatar_mode = "lootling"
				game.profile.current_lootling_id = "relic_beast"
				game.grouped_patrols = false
				game.dungeon.active = false
				game.debug_god_mode = false
				game.debug_weapon_family_override = ""
				seed(424242 + sample)
				game.rng.seed = 1000 + sample
				game.loot_system.rng.seed = 2000 + sample
				game.visual_rng.seed = 3000 + sample
				game.start_run()
				var row := simulate(game, policy, sample)
				if repeat == 0:
					first_pass.append(row)
					wins += 1 if row.won else 0
					print("COMBAT_DIAGNOSTIC " + JSON.stringify(row))
				elif JSON.stringify(row) != JSON.stringify(first_pass[sample]):
					failures.append("%s seed %d differs across fresh-instance replays" % [policy, sample])
				game.free()
		print("COMBAT POLICY %s: %d/%d wins; two fresh-instance passes" % [policy, wins, SEEDS])
	if not failures.is_empty():
		for failure in failures: push_error(failure)
	print("COMBAT SEED DIAGNOSTICS: %s (30 runs; no difficulty changes)" % ("PASSED" if failures.is_empty() else "FAILED"))
	quit(0 if failures.is_empty() else 1)

func simulate(game, policy: String, sample: int) -> Dictionary:
	var elapsed := 0.0
	var tap_clock := 0.0
	var upgrades: Array = []
	var wave_entries: Array = []
	var items: Array = []
	var last_wave := -1
	var buys := {}
	while game.state != "result" and elapsed < 300.0:
		if game.wave != last_wave:
			last_wave = game.wave
			wave_entries.append({"wave":game.wave, "hp":snappedf(game.player_hp, 0.01), "max_hp":game.player_max_hp, "weapon":game.inventory.equipped.Weapon.id, "build":game.build.tags.duplicate()})
		match game.state:
			"upgrade":
				var choice: int = (sample + game.level) % 3 if policy == "smoke" else pick_upgrade(game)
				upgrades.append(game.selected_upgrades[choice].id)
				game.choose_upgrade(choice)
			"item":
				items.append({"id":game.current_item.id, "rarity":game.current_item.rarity, "slot":game.current_item.slot})
				game.accept_item_equip()
			"boss_reward": game.choose_boss_reward((sample + 1) % game.boss_reward_options.size())
			"hoard_chest":
				game._process(0.08)
				if game.hoard_chest_phase == "ready": game.open_hoard_chest()
			"event": game.choose_expedition_event(2)
			"merchant":
				var offer := cheapest_affordable(game)
				if policy == "merchant" and int(buys.get(game.wave, 0)) < 2 and offer >= 0:
					buys[game.wave] = int(buys.get(game.wave, 0)) + 1
					game.buy_merchant_item(offer)
				else: game.leave_merchant()
			_:
				game._process(0.05)
				tap_clock += 0.05
				# Original smoke's .22 threshold quantizes to .25 s at .05 steps.
				if tap_clock >= 0.22:
					tap_clock = 0.0
					game.perform_player_attack(true)
		elapsed += 0.05
	return {"policy":policy, "sample":sample, "game_seed":1000 + sample, "loot_seed":2000 + sample, "global_seed":424242 + sample, "won":game.run_won, "state":game.state, "wave":game.wave, "hp":snappedf(game.player_hp,0.01), "enemy":game.enemy_name, "enemy_hp":snappedf(game.enemy_hp,0.01), "elapsed":snappedf(elapsed,0.01), "damage_taken":snappedf(game.run_damage_taken,0.01), "upgrades":upgrades, "items":items, "buys":buys, "unspent_scrip":game.coins, "wave_entries":wave_entries}

func pick_upgrade(game) -> int:
	# Explicit, reproducible sustain-first policy: reads real offers, no injected stats.
	for id in ["regen", "vamp", "armor", "tap", "multi", "damage", "speed", "venom", "plague", "heavy", "ignite", "crit", "execute", "storm", "frenzy", "splash", "wildfire", "greed"]:
		for index in range(game.selected_upgrades.size()):
			if game.selected_upgrades[index].id == id: return index
	return 0

func cheapest_affordable(game) -> int:
	var choice := -1
	var price := 999999
	for index in range(game.shop.stock.size()):
		var offered := int(game.shop.stock[index].price)
		if offered <= game.coins and offered < price:
			price = offered
			choice = index
	return choice
