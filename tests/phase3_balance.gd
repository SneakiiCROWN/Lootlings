extends SceneTree

# Fresh-scene evidence, real combat/input/shop paths, fixed engine and seeds.
const Items = preload("res://item_catalog.gd")
const Weapons = preload("res://weapon_catalog.gd")
const Campaign = preload("res://campaign_system.gd")
const Diagnostic = preload("res://tests/combat_seed_diagnostics.gd")
const CORES := ["Physical", "Fire", "Lightning", "Poison"]
var helper
var packed: PackedScene
var completed := 0
var harness_root: Window

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("measure")

func measure() -> void:
	helper = Diagnostic.new()
	packed = load("res://main.tscn")
	for weapon in Weapons.live_ids():
		for core in CORES:
			for sample in range(8):
				var row := simulate(weapon, core, sample, "act_i", "relic_beast", "tap")
				print("PHASE3_RUN " + JSON.stringify(row))
	for campaign in Campaign.ORDER:
		for sample in range(8):
			print("PHASE3_RUN " + JSON.stringify(simulate("greatsword", "sustain", sample, campaign, "relic_beast", "tap")))
	var actors: Array = preload("res://lootling_catalog.gd").selectable_ids()
	actors.append_array(preload("res://wanderer_catalog.gd").selectable_ids())
	for actor in actors:
		for policy in ["idle", "tap"]:
			for sample in range(2):
				print("PHASE3_RUN " + JSON.stringify(simulate("greatsword", "sustain", sample, "act_i", actor, policy)))
	# Independent replays expose leaked state; not a victory quota.
	for weapon in ["greatsword", "bow", "orb"]:
		assert(simulate(weapon,"sustain",3,"act_i","relic_beast","tap") == simulate(weapon,"sustain",3,"act_i","relic_beast","tap"))
	helper.free()
	print("PHASE3_BALANCE COMPLETE: %d fresh runs" % completed)
	quit()

func simulate(weapon: String, core: String, sample: int, campaign: String, actor: String, policy: String) -> Dictionary:
	# The fixture guard has verified this disposable directory is in the
	# workspace. Remove previous fixture saves before _ready loads anything.
	var directory := DirAccess.open(OS.get_user_data_dir())
	if directory != null:
		for file in directory.get_files():
			# Every file belongs to this runner's guarded, disposable fixture profile.
			directory.remove(file)
	var game = packed.instantiate()
	(harness_root if harness_root != null else root).add_child(game)
	game.set_process(false)
	game.inventory.reset_to_starter()
	var item_id := ""
	for item in Items.ITEMS:
		if item.get("weapon_type", "") == weapon:
			item_id = item.id
			break
	if Weapons.STARTERS.has(weapon): item_id = Weapons.STARTERS[weapon].id
	game.inventory.equip(Items.create_item(item_id,"COMMON",-1))
	game.meta_power = 0; game.meta_shards = 0
	game.gold_upgrades = {"bedroll":0,"whetstone":0,"pouch":0}
	game.campaign_id = campaign
	game.profile.avatar_mode = "lootling" if preload("res://lootling_catalog.gd").ENTRIES.has(actor) else "wanderer"
	game.profile.current_lootling_id = actor
	game.profile.wanderer.preset_id = actor
	game.grouped_patrols = false; game.dungeon.active = false
	game.debug_god_mode = false; game.debug_weapon_family_override = ""
	var sample_seed := int(hash("phase3:%d" % sample))
	seed(sample_seed)
	game.rng.seed = hash("combat:%d" % sample)
	game.loot_system.rng.seed = hash("loot:%d" % sample)
	game.visual_rng.seed = hash("visual:%d" % sample)
	game.start_run()
	var seconds := 0.0
	var tap_clock := 0.0
	var buys := {}; var segments := []; var foes := []; var upgrades := []; var loot := []
	var serial := -1; var foe_time := 0.0; var foe := {}; var last_wave := -1
	var min_hp_ratio := 1.0
	var decisions := 0
	while game.state != "result" and seconds < 900:
		if game.wave != last_wave:
			last_wave = game.wave
			segments.append({"wave":game.wave,"seconds":seconds,"hp":game.player_hp,"earned":game.run_coins_earned,"spent":game.run_coins_spent,"held":game.coins})
		if game.enemy_alive and game.enemy_serial != serial:
			serial = game.enemy_serial; foe_time = seconds
			foe = {"wave":game.wave,"name":game.enemy_name,"variant":game.enemy_variant_id,"hp":game.enemy_max_hp,"damage":game.enemy_damage,"interval":game.enemy_attack_interval,"player_hp":game.player_hp}
		match game.state:
			"event":
				game.choose_expedition_event(event_choice(game)); decisions += 1
			"upgrade":
				var choice: int = helper.pick_upgrade(game)
				if core != "sustain":
					for index in range(game.selected_upgrades.size()):
						if core in game.selected_upgrades[index].tags:
							choice = index; break
				upgrades.append(game.selected_upgrades[choice].id)
				game.choose_upgrade(choice); decisions += 1
			"item":
				loot.append({"id":game.current_item.id,"rarity":game.current_item.rarity})
				# Preserve starting weapon so family comparison stays interpretable.
				if game.current_item.slot != "Weapon" and Items.rarity_rank(game.current_item.rarity) >= Items.rarity_rank(game.inventory.equipped_item(game.current_item.slot).get("rarity","COMMON")):
					game.accept_item_equip()
				else: game.accept_item_scrap()
				decisions += 1
			"boss_reward": game.choose_boss_reward(sample % game.boss_reward_options.size()); decisions += 1
			"hoard_chest":
				game._process(.05); seconds += .05
				if game.hoard_chest_phase == "ready": game.open_hoard_chest()
			"merchant":
				var offer: int = helper.cheapest_affordable(game)
				if int(buys.get(game.wave,0)) < 2 and offer >= 0 and game.shop.stock[offer].slot != "Weapon":
					buys[game.wave] = int(buys.get(game.wave,0)) + 1
					game.buy_merchant_item(offer); decisions += 1
				else: game.leave_merchant(); decisions += 1
			_:
				game._process(.05); seconds += .05
				if policy == "tap":
					tap_clock += .05
					if tap_clock >= .25:
						tap_clock -= .25; game.request_tap_attack()
		min_hp_ratio = minf(min_hp_ratio,game.player_hp / game.player_max_hp)
		if not foe.is_empty() and not game.enemy_alive:
			foe.ttk = seconds - foe_time
			foe.effective_dps = float(foe.hp) / maxf(.05,float(foe.ttk))
			foes.append(foe); foe = {}
	var row := {"weapon":weapon,"core":core,"sample":sample,"seed":sample_seed,"campaign":campaign,"actor":actor,"policy":policy,"won":game.run_won,"state":game.state,"seconds":seconds,"wave":game.wave,"kills":game.total_kills,"level":game.level,"damage_taken":game.run_damage_taken,"hp":game.player_hp,"min_hp_ratio":min_hp_ratio,"scrip_earned":game.run_coins_earned,"scrip_spent":game.run_coins_spent,"scrip_left":game.coins,"scrap":game.inventory.scrap,"gold":game.run_gold_earned,"shards":game.run_shards_earned,"buys":buys,"decisions":decisions,"segments":segments,"foes":foes,"upgrades":upgrades,"loot":loot}
	game.free(); completed += 1
	return row

func event_choice(_game) -> int:
	return 2
