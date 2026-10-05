extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through isolated helper; actual target-facing, no override.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	assert(DisplayServer.get_name()!="headless")
	call_deferred("review")
func review() -> void:
	var dimensions:=OS.get_environment("LOOTLINGS_CAPTURE_SIZE").split("x")
	root.size=Vector2i(int(dimensions[0]),int(dimensions[1]))
	game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.app_lifecycle.platform_notifications_enabled=false
	game.audio_settings.cinematic_first_time=false
	var stage: String=OS.get_environment("LOOTLINGS_4E_STAGING_STAGE")
	assert(not stage.is_empty())
	folder="res://.godot_test_data/phase4e/staging/"+stage+"/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var helper=preload("res://tests/weapon_fit_qa.gd").new(); helper.game=game
	var actors: Array=["relic_beast"]
	if "before" not in stage:
		actors=preload("res://lootling_catalog.gd").selectable_ids()
		actors.append_array(preload("res://wanderer_catalog.gd").selectable_ids())
	if "packs" in stage: actors=[]
	if "fires" in stage: actors=["relic_beast"]
	if "contacts" in stage: actors=["relic_beast"]
	var rows: Array=[]
	for actor in actors:
		for facing in [1,-1]:
			var states: Array=["idle","player_melee","enemy_melee","bow_ready","bow_fire","orb_charge","orb_fire","hurt","recovery"] if actor=="relic_beast" else ["idle"]
			if "fires" in stage: states=["bow_fire","orb_fire"]
			if "contacts" in stage: states=["idle","player_melee","enemy_melee","recovery"]
			for state in states:
				var weapon: String="bow" if state.begins_with("bow") else "orb" if state.begins_with("orb") else "greatsword"
				helper.prepare(actor,weapon)
				game.enemy_encounter.active=false; game.enemy_is_boss=false; game.enemy_is_miniboss=false
				game.current_zone_id="outer_ruins"; game.enemy_name="RAZOR IMP"; game.enemy_archetype="skirmisher"
				game.enemy_entry_anim=0; game.special_intro_timer=0; game.forced_facing_test=0
				game.player_x=game.target_player_x() if facing>0 else 480-game.target_player_x()
				game.enemy_stage_x=372 if facing>0 else 108
				game.enemy_flash=0; game.enemy_recoil=0; game.enemy_attack_anim=.14 if state=="enemy_melee" else 0
				game.attack_anim=.18 if state in ["player_melee","bow_fire","orb_fire"] else .045 if state=="recovery" else 0
				game.attack_clock=.01 if state=="orb_charge" else game.current_attack_interval()
				game.player_flash=.12 if state=="hurt" else 0
				if "contacts" in stage and state in ["player_melee","enemy_melee"]:
					game.rng.seed=313
					if state=="player_melee": game.perform_player_attack(false);game.attack_anim=.18
					else: game.perform_enemy_attack()
				if state in ["bow_fire","orb_fire"]:
					game.attack_anim=0;game.perform_player_attack(false)
					assert(game.attack_projectiles.size()==1)
					var hp: float=game.enemy_hp
					game.update_attack_projectiles(float(game.attack_projectiles[0].max_life)*.4)
					assert(game.enemy_hp==hp and game.attack_projectiles.size()==1)
					game.attack_anim=.18
				game.presentation_director.toast_queue.clear(); game.presentation_director.active_toast.clear(); game.presentation_director.toast_panel.visible=false
				var pose: Dictionary=preload("res://weapon_fit_catalog.gd").sample(game,state=="hurt")
				var world: Vector2=preload("res://weapon_fit_catalog.gd").world_position(game)
				assert(game.combat_facing()==facing and game.enemy_facing_at(game.enemy_stage_x)==-facing)
				await capture("%s_%s_%s" % [actor,"right" if facing>0 else "left",state])
				rows.append({"actor":actor,"state":state,"weapon":weapon,"facing":facing,"forced_facing":0,"logical_player_x":game.player_x,"logical_enemy_x":game.enemy_stage_x,"player_origin":str(world),"body_rect":str(pose.body_rect),"prototype_body":pose.sprite_rig})
	if "before" not in stage:
		for count in [2,3]:
			helper.prepare("relic_beast","bow")
			game.enemy_encounter.begin(game,count);game.player_x=game.target_player_x();game.forced_facing_test=0
			for actor in game.enemy_encounter.actors: actor.enemy_entry_anim=0
			game.enemy_entry_anim=0;game.special_intro_timer=0
			game.presentation_director.toast_queue.clear();game.presentation_director.active_toast.clear();game.presentation_director.toast_panel.visible=false
			await capture("pack_%d_bow" % count)
			rows.append({"actor":"relic_beast","state":"pack_bow","count":count,"forced_facing":0})
	var file=FileAccess.open(folder+"report.json",FileAccess.WRITE);file.store_string(JSON.stringify({"note":"Normal melee logical range; opposite side mirrored for explicit real-target-facing regression. No forced facing. Prototype art is not accepted.","samples":rows},"\t"))
	helper.free();game.free();print("STAGING NATIVE: %d target-facing samples; owner case plus roster bounds; TEMP art remains unaccepted" % rows.size());quit()
