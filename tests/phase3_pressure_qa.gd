extends SceneTree
const DPS = preload("res://tests/phase3_dps.gd")
const Items = preload("res://item_catalog.gd")
const Traits = preload("res://character_traits.gd")

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("measure")

func measure() -> void:
	var helper := DPS.new(); helper.packed = load("res://main.tscn")
	helper.harness_root = root
	for actor in Traits.TRAITS:
		var row := helper.sample(Traits.TRAITS[actor].starter,"tap","Neutral",[],{"actor":actor})
		row.actor = actor
		print("PHASE3_IDENTITY_DPS " + JSON.stringify(row))
	for weapon in preload("res://weapon_catalog.gd").live_ids():
		var id := str(preload("res://tests/evolution_qa.gd").base_id(weapon))
		var normal := helper.sample(id,"tap","Neutral",[])
		var no_crit := helper.sample(id,"tap","Neutral",[],{"no_crit":true})
		var cores := {}
		for core in ["Physical","Fire","Lightning","Poison"]:
			cores[core] = helper.sample(id,"tap",core,[]).sustained_dps-normal.sustained_dps
		print("PHASE3_MARGINAL " + JSON.stringify({"weapon":weapon,"neutral":normal.sustained_dps,"without_crits":no_crit.sustained_dps,"crit_delta":normal.sustained_dps-no_crit.sustained_dps,"core_delta":cores}))
	helper.free()
	for campaign in preload("res://campaign_system.gd").ORDER:
		for wave in [1,5,8,12,15]:
			for role in (["boss"] if wave in [8,15] else ["skirmisher","tank","hexer"]):
				pressure(campaign,wave,role)
	print("PHASE3_PRESSURE COMPLETE: 12 identity DPS, 12 crit/Core marginal tests, 110 role/special pressure samples")
	quit()

func pressure(campaign: String, wave: int, role: String) -> void:
	var game = load("res://main.tscn").instantiate(); root.add_child(game); game.set_process(false)
	game.inventory.reset_to_starter(); game.meta_power = 0; game.gold_upgrades = {"bedroll":0,"whetstone":0,"pouch":0}
	game.campaign_id = campaign; game.dungeon.active = false; game.grouped_patrols = false
	game.profile.avatar_mode = "lootling"; game.profile.current_lootling_id = "relic_beast"
	seed(81932); game.rng.seed = 31928; game.loot_system.rng.seed = 91283
	game.start_run(); game.wave = wave; game.wave_kills = 0; game.spawn_enemy()
	if role != "boss":
		game.wave_kills = game.wave_composition.find(role)
		if game.wave_kills < 0: game.wave_composition[0] = role; game.wave_kills = 0
		game.spawn_single_enemy()
	game.enemy_variant_id = ""; game.enemy_variant_guarded = false
	game.enemy_entry_anim = 0; game.special_intro_timer = 0; game.wave_banner_timer = 0
	game.player_hp = 1000000; game.player_max_hp = 1000000; game.attack_clock = 10000
	var starting_hp: float = game.player_hp
	for index in range(1200): game._process(.05)
	var damage: float = starting_hp-game.player_hp
	assert(damage >= 0 and game.state == "playing")
	print("PHASE3_PRESSURE " + JSON.stringify({"campaign":campaign,"wave":wave,"role":role,"name":game.enemy_name,"hp":game.enemy_max_hp,"hit":game.enemy_damage,"interval":game.enemy_attack_interval,"incoming_dps":damage/60,"estimated_100hp_ttk":100/maxf(.001,damage/60),"attacks":game.enemy_attack_count,"recovery_seconds":game.boss_recovery}))
	game.free()
