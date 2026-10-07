extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through native helper. No forced facing or prototype opt-in.
const Fit=preload("res://weapon_fit_catalog.gd")
const CASES=[["gloomlet","claws"],["relic_beast","greatsword"],["emberhorn","claws"],["mosskin","maul"],["moonkip","daggers"],["pebblewyrm","claws"],["glimmerfin","orb"],["vault_runner","greatsword"],["ruin_warden","greatsword"],["nightstage_drifter","greatsword"],["velvet_astrologer","greatsword"],["ashtrail_hunter","greatsword"]]
func review() -> void:
	assert(OS.get_environment("LOOTLINGS_QA_RIG_PREVIEW")=="")
	var observed:=[]
	for viewport in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=viewport;folder="res://.godot_test_data/identity-runtime/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
		game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
		var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
		for entry in CASES:
			helper.prepare(entry[0],entry[1]);game.forced_facing_test=0;game.enemy_entry_anim=0;game.player_flash=0
			game.presentation_director.set_process(false);game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.hide()
			var rng=game.rng.state;var loot_rng=game.loot_system.rng.state;var damage=game.base_damage;var interval=game.current_attack_interval()
			for state in ["idle","strike","recovery","hurt","left_strike"]:
				game.player_x=game.target_player_x();game.attack_clock=interval;game.attack_anim=0;game.player_flash=0
				if state in ["strike","left_strike"]:game.attack_anim=.18
				if state=="recovery":game.attack_anim=.05
				if state=="hurt":game.player_flash=.3
				if state=="left_strike":game.enemy_stage_x=50;game.player_x=350
				else:game.enemy_stage_x=372
				var pose=Fit.sample(game,state=="hurt")
				assert(pose.actor_id==entry[0]);assert(game.combat_facing()==(-1 if state=="left_strike" else 1))
				observed.append({"actor":entry[0],"weapon":entry[1],"state":state,"layout":str(viewport),"source":pose.texture.resource_path,"missing_exact_art":pose.sprite_rig,"presentation":"REFERENCE_UI_NOT_BODY" if pose.sprite_rig else "ACCEPTED_RUNTIME_POSE"})
				await capture("%s_%s_%s" % [entry[0],entry[1],state])
			# Reproduce the owner-visible loss: attack root has not yet reached lane.
			game.enemy_stage_x=372;game.player_x=game.target_player_x()-25;game.player_flash=0;game.attack_anim=.18
			var moving=Fit.sample(game)
			if entry[0] in ["gloomlet","emberhorn","moonkip","glimmerfin"]:
				assert(moving.extracted_pose and not moving.sprite_rig,"Accepted action must not disappear while root moves")
				await capture(entry[0]+"_committed_action_moving")
			assert(game.rng.state==rng and game.loot_system.rng.state==loot_rng and game.base_damage==damage and game.current_attack_interval()==interval)
		# Current names stay canonical; long modifiers fit a bounded two-line HUD.
		helper.prepare("gloomlet","claws");game.enemy_name="ARMOURED MOSSBACK BRUTE";game.enemy_entry_anim=0;game.enemy_poison_stacks=4;game.enemy_burn_dps=1
		var lines=preload("res://combat_presentation.gd").name_lines(game.body_font,game.enemy_name,193,14)
		assert(lines.size()==2)
		for line in lines:assert(game.body_font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,14).x<=193)
		await capture("long_enemy_name_statuses")
		helper.free();game.free();await process_frame
	var file=FileAccess.open("res://.godot_test_data/identity-runtime/STATE_COVERAGE.json",FileAccess.WRITE);file.store_string(JSON.stringify(observed,"\t"));file.close()
	print("IDENTITY RUNTIME NATIVE PASS: twelve actors, five states, two native layouts; moving accepted actions retained; missing frames exposed as reference UI, no fake body closure; balance/RNG unchanged");quit()
