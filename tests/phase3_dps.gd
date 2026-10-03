extends SceneTree
const Items = preload("res://item_catalog.gd")
const Weapons = preload("res://weapon_catalog.gd")
var packed: PackedScene
var harness_root: Window

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("measure")

func measure() -> void:
	packed = load("res://main.tscn")
	for weapon in Weapons.live_ids():
		var id := str(Weapons.STARTERS[weapon].id) if Weapons.STARTERS.has(weapon) else ""
		if id.is_empty():
			for item in Items.ITEMS:
				if item.get("weapon_type","") == weapon:
					id = item.id; break
		for policy in ["idle","tap"]:
			for core in ["Neutral","Physical","Fire","Lightning","Poison"]:
				print("PHASE3_DPS " + JSON.stringify(sample(id,policy,core,[])))
	for upgrade in preload("res://game_catalog.gd").UPGRADES:
		print("PHASE3_DPS " + JSON.stringify(sample("scrapfang_blade","tap","Neutral",[upgrade.id])))
	for item in Items.ITEMS:
		if item.slot == "Weapon": continue
		print("PHASE3_DPS " + JSON.stringify(sample(item.id,"tap","Neutral",[])))
	print("PHASE3_DPS COMPLETE")
	quit()

func sample(item_id: String, policy: String, core: String, upgrades: Array, options: Dictionary = {}) -> Dictionary:
	var directory := DirAccess.open(OS.get_user_data_dir())
	if directory != null:
		for file in directory.get_files(): directory.remove(file)
	var game = packed.instantiate()
	(harness_root if harness_root != null else root).add_child(game); game.set_process(false)
	game.inventory.reset_to_starter()
	game.inventory.equip(Items.create_item(item_id,"COMMON",-1))
	game.meta_power = 0; game.gold_upgrades = {"bedroll":0,"whetstone":0,"pouch":0}
	game.campaign_id = "act_i"; game.grouped_patrols = false; game.dungeon.active = false
	game.profile.avatar_mode = "lootling"; game.profile.current_lootling_id = "relic_beast"
	seed(95812); game.rng.seed = 59813; game.loot_system.rng.seed = 15814
	game.start_run()
	if options.has("actor"):
		game.character_trait = preload("res://character_traits.gd").TRAITS[options.actor]
		game.player_max_hp += float(game.character_trait.hp)
		game.player_hp = game.player_max_hp
	if options.get("no_crit",false): game.crit_chance = -1.0
	for upgrade in preload("res://game_catalog.gd").UPGRADES:
		if upgrade.id in upgrades: game.apply_upgrade_effect(upgrade)
	game.build.tags[core] = 3 if core != "Neutral" else 0
	game.player_x = game.target_player_x()
	game.enemy_entry_anim = 0; game.enemy_hp = 1000000; game.enemy_max_hp = 1000000
	game.enemy_attack_clock = 10000; game.enemy_hit_multiplier = 1.0
	game.enemy_variant_id = ""; game.enemy_variant_guarded = false
	game.player_hp = game.player_max_hp * .5
	var burst := 0.0
	for step in range(600):
		game._process(.05)
		if policy == "tap" and step % 5 == 0: game.request_tap_attack()
		if step == 39: burst = (1000000.0 - game.enemy_hp) / 2.0
	var row := {"item":item_id,"policy":policy,"core":core,"upgrades":upgrades,"sustained_dps":(1000000.0-game.enemy_hp)/30.0,"burst_2s_dps":burst,"interval":game.current_attack_interval(),"crit":game.effective_crit_chance(),"regen":game.regen_per_second,"life_steal":game.life_steal,"hp_restored":game.player_hp-game.player_max_hp*.5,"armour":game.armor+game.inventory.effect_total("armor"),"hp":game.player_max_hp,"enemy_clock_delayed":game.enemy_attack_clock-9970.0}
	game.free()
	return row
