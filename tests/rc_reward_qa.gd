extends SceneTree
const Items = preload("res://item_catalog.gd")
var game

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("review")

func review() -> void:
	game = load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.set_process(false); game.audio_settings.cinematic_first_time = false
	seed(18291); game.rng.seed = 39182; game.loot_system.rng.seed = 71291
	game.start_run(); game.coins = 10000; game.wave = 6; game.show_merchant()
	if "--baseline" in OS.get_cmdline_user_args():
		var purchases := 0
		while purchases < 6 and game.state == "merchant" and not game.shop.stock.is_empty():
			game.buy_merchant_item(0); purchases += 1; game.accept_item_scrap()
		print("RC BASELINE: one merchant visit permits %d purchases; first redraw cost %d" % [purchases,game.shop.reroll_cost(6)])
		game.free(); quit(); return
	# Reroll is an alternative before the one free choice; duplicate requests
	# during disposition cannot charge again, even with effectively unlimited money.
	var first_reroll: int = game.shop.reroll_cost(6)
	var coins: int = game.coins
	game.reroll_merchant(); assert(game.coins == coins-first_reroll)
	var price: int = game.shop.stock[0].price
	game.buy_merchant_item(0); assert(game.state == "item" and game.coins == coins-first_reroll-price)
	var paid: int = game.coins
	game.buy_merchant_item(1); game.reroll_merchant(); assert(game.coins == paid)
	game.accept_item_scrap(); assert(game.state == "playing" and game.shop.purchase_taken)
	assert(game.shop.take(0).is_empty())
	# A genuinely new stop restores its one choice and limited redraw.
	game.wave = 11; game.show_merchant(); assert(not game.shop.purchase_taken and game.shop.rerolls == 0)
	game.leave_merchant()
	# Multiple recovered finds from a wave are alternatives, never a queue of
	# free equipment acquisitions. Item disposition follows the chosen acquisition.
	game.pending_items = [Items.create_item("bonebow","RARE",501),Items.create_item("mossguard_harness","EPIC",502),Items.create_item("scrapfang_blade","LEGENDARY",503)]
	game.enemy_alive = false; game.loot_drops.clear(); game.item_review_due = true
	game._process(.05); assert(game.state == "boss_reward" and game.normal_loot_choice)
	assert(game.boss_reward_options.size() == 3 and game.pending_items.is_empty())
	game.choose_boss_reward(1); assert(game.current_item.serial == 502 and game.boss_reward_options.is_empty())
	game.choose_boss_reward(0); assert(game.current_item.serial == 502)
	game.accept_item_keep(); assert(game.state == "playing" and game.pending_items.is_empty())
	assert(game.inventory.stash.size() == 1 and game.inventory.stash[0].serial == 502)
	# Boss rewards keep their own title/source and three-way contract.
	game.prepare_hoard_chest(); game.show_boss_reward(); assert(not game.normal_loot_choice)
	assert(game.boss_reward_heading.text == "BOSS HOARD")
	game.free(); await process_frame
	print("RC REWARD QA PASSED: one free choice/stop, one wave find, reroll/duplicate/next-stop/boss boundaries")
	quit()
