extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through isolated native helper. Missing art is a failed
# delivery gate, not an excuse to fabricate bow states from claw attacks.
func review() -> void:
	var stage:=OS.get_environment("LOOTLINGS_GLOOMLET_STAGE")
	assert(stage in ["before","after"])
	var probes:=[]
	for viewport in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=viewport;folder="res://.godot_test_data/gloomlet-bow/"+stage+"/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
		game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
		var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game;helper.prepare("gloomlet","bow")
		game.inventory.equip(game.ItemCatalog.create_item("moonbranch","COMMON",82));game.enemy_entry_anim=0;game.forced_facing_test=0;game.wave_banner_timer=0
		game.presentation_director.set_process(false);game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.hide()
		var rng=game.rng.state;var loot_rng=game.loot_system.rng.state;var interval=game.current_attack_interval();var damage=game.base_damage
		for facing in [1,-1]:
			for state in ["idle","ready","move","draw","release","recovery","hurt"]:
				game.enemy_encounter.clear();game.enemy_stage_x=372 if facing==1 else 60;game.player_x=game.target_player_x() if facing==1 else 360
				game.attack_anim=.18 if state=="release" else .045 if state=="recovery" else 0;game.attack_clock=.025 if state=="draw" else interval;game.player_flash=.18 if state=="hurt" else 0
				if state=="move":game.player_x-=25*facing
				var pose=preload("res://weapon_fit_catalog.gd").sample(game,state=="hurt")
				assert(pose.actor_id=="gloomlet" and pose.weapon_type=="bow" and game.combat_facing()==facing)
				probes.append({"layout":str(viewport),"state":state,"facing":"right" if facing==1 else "left","sprite_rig":pose.sprite_rig,"canonical_bow_state_complete":not pose.sprite_rig,"source":pose.texture.resource_path,"primary_hand":str(pose.primary_hand),"draw_hand":str(pose.secondary_hand),"held_rect":str(pose.weapon_rect),"held_rotation":pose.weapon_rotation})
				if stage=="after":await capture(("BLOCKED_" if pose.sprite_rig else "ACCEPTED_")+"gloomlet_bow_"+state+("_right" if facing==1 else "_left"))
		assert(game.rng.state==rng and game.loot_system.rng.state==loot_rng and game.current_attack_interval()==interval and game.base_damage==damage)
		if stage=="after":
			for item_id in ["moonbranch","gilded_shortbow"]:
				game.inventory.equip(game.ItemCatalog.create_item(item_id,"COMMON",82))
				for facing in [1,-1]:
					game.enemy_encounter.clear();game.enemy_stage_x=372 if facing==1 else 60;game.player_x=game.target_player_x() if facing==1 else 360
					game.attack_anim=0;game.attack_clock=.025;game.player_flash=0
					var fit=preload("res://weapon_fit_catalog.gd").sample(game,false)
					assert(not fit.sprite_rig and fit.support_status=="authored_bow_draw")
					assert((fit.primary_hand+(fit.bow_nock*fit.weapon_scale).rotated(fit.weapon_rotation)).distance_to(fit.secondary_hand)<.001)
					assert((fit.bow_forward*fit.weapon_scale).rotated(fit.weapon_rotation).distance_to(Vector2(facing,0))<.001)
					assert(fit.authored_facing==("right_only" if facing==1 else "left_only"))
					await capture("BOW_FIT_"+item_id+("_right" if facing==1 else "_left"))
		game.enemy_stage_x=372;game.player_x=game.target_player_x();game.player_flash=0;game.attack_anim=0
		for count in [2,3]:
			game.enemy_encounter.begin(game,count)
			for index in range(count):
				game.enemy_encounter.actors[index].enemy_name=["VOLATILE MOSSBACK BRUTE","ARMOURED GEMFANG WYRMLING","LEECHING MOSSBACK BRUTE"][index]
				game.enemy_encounter.actors[index].enemy_burn_dps=1;game.enemy_encounter.actors[index].enemy_poison_stacks=12;game.enemy_encounter.actors[index].enemy_variant_id="volatile";game.enemy_encounter.actors[index].enemy_entry_anim=0
			game.enemy_encounter.load_actor(game,0);game.enemy_stage_x=game.enemy_encounter.target_position().x;game.player_x=game.target_player_x();await capture("long_names_%d_enemies" % count)
			# Exact current catalog names fit at readable size without elision.
			if stage=="after":
				for enemy in preload("res://zone_catalog.gd").ZONES:
					for entry in enemy.enemies.values():
						for variant in preload("res://enemy_variant_catalog.gd").VARIANTS.values():
							var text=(str(variant.name)+" "+str(entry.name)).to_upper();var box=game.enemy_encounter.hud_layout(game.body_font,text,0)
							assert(" ".join(box.lines)==text and box.lines.size()<=3)
							for line in box.lines:assert(game.body_font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,box.font_size).x<=box.name_width)
		game.enemy_encounter.clear();game.combat_controls._process(0);await capture("attack_control_ready")
		game.tap_input_cooldown=.09;game.combat_controls._process(0);await capture("attack_control_recharging")
		game.combat_controls.attack.button_pressed=true;game.combat_controls._process(0);await capture("attack_control_pressed");game.combat_controls.attack.button_pressed=false
		if stage=="after":
			game.enemy_is_miniboss=true;game.enemy_name="GRUMP KNIGHT";await capture("BLOCKED_grump_knight_bow_body");game.enemy_is_miniboss=false;game.current_zone_id="hoard_depths";await capture("BLOCKED_hoard_depths_bow_body")
		helper.free();game.free();await process_frame
	var file=FileAccess.open("res://.godot_test_data/gloomlet-bow/"+stage+"/ART_GATE.json",FileAccess.WRITE)
	var blocked=probes.filter(func(p):return not p.canonical_bow_state_complete)
	file.store_string(JSON.stringify({"apk_export_allowed":blocked.is_empty(),"missing_bow_probes":blocked.size(),"probes":probes,"defeat":"OPEN: no authored canonical downed source"},"\t"));file.close()
	print("GLOOMLET BOW NATIVE: HUD/control checks complete; missing canonical bow probes ",blocked.size(),"; APK gate ","HOLD" if not blocked.is_empty() else "PASS");quit()
