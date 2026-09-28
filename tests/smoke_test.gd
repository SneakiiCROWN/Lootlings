extends SceneTree

const BuildSystem = preload("res://build_system.gd")
const GameCatalog = preload("res://game_catalog.gd")
const ItemCatalog = preload("res://item_catalog.gd")
const LootSystem = preload("res://loot_system.gd")
const InventorySystem = preload("res://inventory_system.gd")
const ShopSystem = preload("res://shop_system.gd")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error("SMOKE TEST: " + message)

func run_tests() -> void:
	var packed := load("res://main.tscn") as PackedScene
	check(packed != null, "main scene loads")
	if packed == null:
		quit(1)
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	game.inventory.reset_to_starter()
	game.start_run()
	var identity_build = BuildSystem.new()
	identity_build.add_upgrade(upgrade_by_id("ignite"))
	identity_build.add_upgrade(upgrade_by_id("wildfire"))
	check(identity_build.dominant() == "Fire" and identity_build.tier() == 1, "build tags produce a Fire evolution threshold")
	check(BuildSystem.COLORS.Fire != BuildSystem.COLORS.Lightning and BuildSystem.COLORS.Poison != BuildSystem.COLORS.Physical, "implemented identities have distinct visual palettes")
	check(identity_build.class_influence("Neutral") == "Main Mascot RelicBeast", "neutral player identity remains separate from Emberhorn")
	check(identity_build.class_influence("Fire") == "Emberhorn", "Fire visuals can reference Emberhorn without replacing the mascot")
	var test_loot = LootSystem.new(8844)
	for rarity_index in range(100):
		var bounded_item: Dictionary = test_loot.generate_shop_item()
		check(ItemCatalog.rarity_rank(bounded_item.rarity) in range(4), "generated item rarity stays inside catalog bounds")
	for drop_index in range(25):
		var miniboss_drop: Dictionary = test_loot.roll_drop(true, false)
		check(not miniboss_drop.is_empty() and ItemCatalog.rarity_rank(miniboss_drop.rarity) >= 1, "miniboss loot is guaranteed Rare or better")
	var boss_drop: Dictionary = test_loot.roll_drop(false, true)
	check(not boss_drop.is_empty() and ItemCatalog.rarity_rank(boss_drop.rarity) >= 2, "boss loot is guaranteed Epic or better")
	var test_inventory = InventorySystem.new()
	var rare_bow := ItemCatalog.create_item("bonebow", "RARE", 777)
	test_inventory.equip(rare_bow)
	check(test_inventory.weapon_family() == "RANGER" and test_inventory.effect_total("crit") > 0.0, "equipped weapon exposes its combat family and affixes")
	check(test_inventory.keep(ItemCatalog.create_item("mossguard_harness", "COMMON", 778)), "found gear can be kept in the stash")
	var scrap_before: int = test_inventory.scrap
	test_inventory.salvage(ItemCatalog.create_item("ember_pop", "EPIC", 779))
	check(test_inventory.scrap > scrap_before, "salvaging converts gear into persistent scrap")
	var inventory_test_path := "user://lootlings_inventory_smoke.cfg"
	check(test_inventory.save(inventory_test_path) == OK, "inventory and scrap save successfully")
	var loaded_inventory = InventorySystem.new()
	loaded_inventory.load(inventory_test_path)
	check(loaded_inventory.weapon_family() == "RANGER" and loaded_inventory.stash.size() == 1 and loaded_inventory.scrap == test_inventory.scrap, "equipped gear, stash, and scrap persist through save/load")
	var test_shop = ShopSystem.new()
	test_shop.generate_stock(test_loot, 6)
	check(test_shop.stock.size() == 3 and int(test_shop.stock[0].price) > 0, "merchant generates three priced choices")
	var first_serial: int = test_shop.stock[0].serial
	test_shop.reroll(test_loot, 6)
	check(test_shop.stock.size() == 3 and int(test_shop.stock[0].serial) != first_serial, "merchant reroll replaces its stock")
	var original_equipped: Dictionary = game.inventory.equipped.duplicate(true)
	game.inventory.equip(ItemCatalog.create_item("scrapfang_blade", "COMMON", 880))
	var vanguard_interval: float = game.current_attack_interval()
	game.inventory.equip(ItemCatalog.create_item("bonebow", "COMMON", 881))
	check(game.current_attack_interval() < vanguard_interval and game.target_player_x() < game.PLAYER_ATTACK_X, "Ranger weapons attack faster from a readable ranged position")
	game.inventory.equip(ItemCatalog.create_item("moonbite_daggers", "COMMON", 882))
	check(game.effective_crit_chance() > game.crit_chance and game.current_attack_interval() < vanguard_interval, "Rogue weapons provide fast crit-focused combat")
	game.inventory.equip(ItemCatalog.create_item("glimmerstaff", "COMMON", 883))
	check(game.target_player_x() < game.PLAYER_ATTACK_X, "Mage weapons maintain ranged spellcaster spacing")
	game.inventory.equipped = original_equipped
	game.start_run()
	game.coins = 999
	game.wave = 6
	game.show_merchant()
	var coins_before_purchase: int = game.coins
	var purchase_price: int = game.shop.stock[0].price
	game.buy_merchant_item(0)
	check(game.coins == coins_before_purchase - purchase_price and game.state == "item", "merchant purchase spends Coins and opens the item decision")
	game.accept_item_scrap()
	check(game.state == "merchant", "merchant purchase returns safely to the shop")
	var coins_before_reroll: int = game.coins
	game.reroll_merchant()
	check(game.coins < coins_before_reroll and game.shop.rerolls == 1, "merchant reroll spends Coins")
	game.leave_merchant()
	for mechanic_id in ["ignite", "storm", "venom", "heavy"]:
		game.start_run()
		game.apply_upgrade_effect(upgrade_by_id(mechanic_id))
		game.player_x = game.PLAYER_ATTACK_X
		game.enemy_max_hp = 99999.0
		game.enemy_hp = game.enemy_max_hp
		game.enemy_hit_multiplier = 1.0
		if mechanic_id == "storm":
			game.attack_sequence = 3
		elif mechanic_id == "heavy":
			game.attack_sequence = 4
		var hp_before: float = game.enemy_hp
		game.perform_player_attack(false)
		match mechanic_id:
			"ignite": check(game.enemy_burn_dps > 0.0, "Fire upgrades ignite enemies")
			"storm": check(hp_before - game.enemy_hp > game.base_damage * 1.2, "Lightning upgrades trigger chain damage")
			"venom": check(game.enemy_poison_stacks > 0, "Poison upgrades stack damage over time")
			"heavy": check(hp_before - game.enemy_hp > game.base_damage * 1.7, "Physical upgrades trigger heavy rhythm hits")
	game.start_run()
	check(game.state == "playing", "a run starts in gameplay")
	check(game.enemy_alive and game.enemy_hp > 0.0, "first enemy spawns with health")
	game.player_x = game.PLAYER_ATTACK_X
	game.perform_player_attack(true)
	check(game.enemy_hp < game.enemy_max_hp, "tap attack damages the enemy")
	check(game.attack_anim > 0.0 and game.enemy_recoil > 0.0, "attacks trigger readable impact animation")
	var coins_before_kill: int = game.coins
	game.damage_enemy(game.enemy_max_hp * 10.0, false, false)
	check(game.enemy_death_anim > 0.0 and not game.reward_pickups.is_empty(), "enemy death launches reward feedback")
	check(game.coins > coins_before_kill, "enemy kills award in-run Coins")
	var guard := 0
	while game.state != "result" and guard < 100:
		guard += 1
		resolve_interstitials(game, 0)
		if game.state == "result":
			break
		if not game.enemy_alive:
			game.spawn_enemy()
		game.damage_enemy(game.enemy_hp + 1.0, false, false)
		resolve_interstitials(game, 0)
	check(guard < 100, "complete run does not softlock")
	check(game.state == "result" and game.wave == game.RUN_LAST_WAVE, "boss victory reaches results")
	check(game.total_kills >= 40, "waves and miniboss produced the expected enemy sequence")
	check(game.meta_shards > 0, "run rewards permanent-progression currency")
	game.start_run()
	check(game.state == "playing" and game.wave == 1 and game.enemy_alive, "another run restarts cleanly")
	game.player_hp = 1.0
	game.enemy_damage = 999.0
	game.perform_enemy_attack()
	check(game.state == "result" and game.player_hp == 0.0, "defeat reaches results without a softlock")
	seed(424242)
	var victories := 0
	for run_index in range(5):
		game.inventory.reset_to_starter()
		game.start_run()
		game.rng.seed = 1000 + run_index
		game.loot_system.rng.seed = 2000 + run_index
		var elapsed := 0.0
		var tap_clock := 0.0
		while game.state != "result" and elapsed < 300.0:
			if game.state == "upgrade":
				game.choose_upgrade((run_index + game.level) % 3)
			elif game.state == "item":
				game.accept_item_equip()
			elif game.state == "merchant":
				game.leave_merchant()
			else:
				game._process(0.05)
				tap_clock += 0.05
				if tap_clock >= 0.22:
					tap_clock = 0.0
					game.perform_player_attack(true)
			elapsed += 0.05
		if game.state == "result" and game.player_hp > 0.0 and game.wave == game.RUN_LAST_WAVE:
			victories += 1
		print("BALANCE RUN %d: wave=%d level=%d hp=%.0f time=%.1fs" % [run_index + 1, game.wave, game.level, game.player_hp, elapsed])
	check(victories >= 1, "a modest tapping strategy can complete a balanced run")
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("SMOKE TEST PASSED: full loop plus %d/5 simulated tapping victories" % victories)
		quit(0)
	else:
		print("SMOKE TEST FAILED: %d issue(s)" % failures.size())
		quit(1)

func upgrade_by_id(id: String) -> Dictionary:
	for upgrade in GameCatalog.UPGRADES:
		if upgrade.id == id:
			return upgrade
	return {}

func resolve_interstitials(game, upgrade_index: int) -> void:
	for drop in game.loot_drops:
		game.pending_items.append(drop.item)
	game.loot_drops.clear()
	var safety := 0
	while safety < 30:
		safety += 1
		if game.state == "upgrade":
			check(game.selected_upgrades.size() == 3, "level-up offers three upgrades")
			game.choose_upgrade(upgrade_index)
		elif game.state == "item":
			game.accept_item_scrap()
		elif game.state == "merchant":
			game.leave_merchant()
		elif not game.pending_items.is_empty():
			game.show_next_item()
		elif game.pending_victory:
			game.end_run(true)
		else:
			break
