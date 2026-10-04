extends SceneTree
const Diagnostic=preload("res://tests/combat_seed_diagnostics.gd")
var helper
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	create_timer(150).timeout.connect(func(): push_error("Phase4B runs timeout"); quit(1))
	call_deferred("measure")
func measure() -> void:
	helper=Diagnostic.new()
	var actors: Array=preload("res://lootling_catalog.gd").selectable_ids(); actors.append_array(preload("res://wanderer_catalog.gd").selectable_ids())
	for actor in actors:
		print("PHASE4B_RUN "+JSON.stringify(simulate(actor,0,"siege",10)))
	for seed_index in range(4):
		print("PHASE4B_RUN "+JSON.stringify(simulate("relic_beast",seed_index,"siege",20)))
		print("PHASE4B_RUN "+JSON.stringify(simulate("relic_beast",seed_index,"dungeon",0)))
	print("PHASE4B_RUN "+JSON.stringify(simulate("relic_beast",4,"siege",40)))
	helper.free(); quit()
func simulate(actor: String, sample: int, mode: String, extract_at: int) -> Dictionary:
	var directory:=DirAccess.open(OS.get_user_data_dir())
	for file in directory.get_files(): directory.remove(file)
	var game=load("res://main.tscn").instantiate(); root.add_child(game); game.set_process(false)
	game.meta_power=0; game.gold_upgrades={"bedroll":0,"whetstone":0,"pouch":0}; game.inventory.reset_to_starter()
	game.profile.avatar_mode="lootling" if preload("res://lootling_catalog.gd").ENTRIES.has(actor) else "wanderer"
	game.profile.current_lootling_id=actor; game.profile.wanderer.preset_id=actor
	game.inventory.equip(game.ItemCatalog.create_item(game.CharacterTraits.TRAITS[actor].starter,"COMMON",-1))
	game.rng.seed=19231+sample; game.loot_system.rng.seed=49121+sample; seed(81132+sample)
	game.retention.siege=mode=="siege"
	if mode=="dungeon": game.retention.setup_targeted(71231+sample)
	game.start_run(); game.set_process(false)
	var seconds:=0.0; var tap_clock:=0.0; var lowest:=1.0; var ttk:=[]; var foe_start:=0.0; var serial: int=game.enemy_serial; var elites:=0; var checkpoints:=[]
	while game.state!="result" and seconds<700:
		if game.enemy_alive and game.enemy_serial!=serial:
			serial=game.enemy_serial; foe_start=seconds
			if not game.enemy_variant_id.is_empty(): elites+=1
		match game.state:
			"siege_checkpoint":
				checkpoints.append(game.wave); game.retention.selected_at=0; game.retention.choose(0 if game.wave>=extract_at else 1)
			"siege_service": game.retention.selected_at=0; game.retention.choose(0 if game.coins>=110+mini(180,game.wave*4) else 3)
			"route":
				var options: Array=game.dungeon.choices(); var chosen:=0
				for i in range(options.size()):
					if options[i].kind in ["Rest","Shrine","Combat"]: chosen=i; break
				game.dungeon.choose(chosen); game.route_panel.visible=false; game.enter_route_room()
			"upgrade": game.choose_upgrade(helper.pick_upgrade(game))
			"item":
				if game.current_item.slot!="Weapon": game.accept_item_equip()
				else: game.accept_item_scrap()
			"boss_reward": game.choose_boss_reward(0)
			"merchant": game.leave_merchant()
			"hoard_chest":
				game._process(.05); seconds+=.05
				if game.hoard_chest_phase=="ready": game.open_hoard_chest()
			_:
				var alive: bool=game.enemy_alive; game._process(.05); seconds+=.05; tap_clock+=.05
				if tap_clock>=.25: tap_clock=0; game.request_tap_attack()
				if alive and not game.enemy_alive: ttk.append(seconds-foe_start)
		lowest=minf(lowest,game.player_hp/game.player_max_hp)
	var row: Dictionary={"actor":actor,"sample":sample,"mode":mode,"extract_at":extract_at,"won":game.run_won,"round":game.wave,"kills":game.total_kills,"seconds":seconds,"damage":game.run_damage_taken,"lowest_hp":lowest,"earned":game.run_coins_earned,"spent":game.run_coins_spent,"left":game.coins,"gold":game.run_gold_earned,"materials":game.expedition_progress.run_materials,"red":game.retention.progress.data.red_fragments,"elites":elites,"checkpoints":checkpoints,"ttk":ttk}
	assert(game.state=="result","Run should end rather than time out")
	game.free(); return row
