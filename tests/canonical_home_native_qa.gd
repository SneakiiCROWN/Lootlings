extends "res://tests/canonical_integration_native_qa.gd"
# extends SceneTree; final resident/XP and explicitly staged modifier evidence.
func review() -> void:
	for size in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=size;game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
		game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false;game.set_process(false)
		folder="res://.godot_test_data/phase4e/canonical-integration-final/%dx%d/" % [size.x,size.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game.show_hideout();quiet()
		for time in [3,38,66,94]:
			game.hideout_ui.scene_time=time;game.hideout_ui.queue_redraw();await capture("home_existing_idle_bodies_activity_"+str(time))
		for speaker in ["Patch","Sera","Ilex"]:
			game.hideout_ui.request_dialogue("idle",speaker);await capture("home_dialogue_"+speaker);game.hideout_ui.dismiss_dialogue()
		var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
		for ratio in [0.0,0.5,1.0]:
			helper.prepare("relic_beast","greatsword");game.enemy_entry_anim=0;game.wave_banner_timer=0;game.xp=game.xp_needed*ratio;quiet();await capture("xp_"+str(ratio))
		if size.x==1080:
			for actor in ["nightstage_drifter","velvet_astrologer"]:
				helper.prepare(actor,"greatsword");game.enemy_entry_anim=0;game.wave_banner_timer=0;quiet();await capture("hud_full_name_"+actor)
			for region in preload("res://campaign_system.gd").ORDER:
				helper.prepare("relic_beast","greatsword");game.campaign_id=region;game.wave=6;game.current_zone=game.run_zone_for_wave(6);game.current_zone_id=game.current_zone.id;game.spawn_enemy();game.debug_force_variant("armoured");assert(game.enemy_variant_id=="armoured");game.enemy_entry_anim=0;game.special_intro_timer=0;game.wave_banner_timer=0;quiet();await capture("variant_"+region+"_FORCED_MODIFIER_TEST")
		game.free();helper.free()
	print("CANONICAL HOME: final unclipped existing resident idle art, no detached fake work props; phone/tablet dialogue and XP 0/50/100; all10 explicitly forced existing armoured modifier presentations");quit()
