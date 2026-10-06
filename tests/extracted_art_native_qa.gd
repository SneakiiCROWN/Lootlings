extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree; actual extracted idle selection with safe fallback views.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	assert(DisplayServer.get_name()!="headless");call_deferred("review_extracted")
func review_extracted() -> void:
	game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	game.app_lifecycle.platform_notifications_enabled=false;game.set_process(false)
	var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
	for layout in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=layout;folder="res://.godot_test_data/phase4e/extracted-art/"+str(layout.x)+"x"+str(layout.y)+"/";DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		for actor in preload("res://lootling_catalog.gd").selectable_ids():
			var weapons: Array=["daggers"] if actor=="moonkip" else ["wand","orb"] if actor=="mosskin" else ["wand","orb","daggers","claws"]
			for weapon in weapons:
				helper.prepare(actor,weapon);game.player_x=game.target_player_x();game.enemy_stage_x=355;game.enemy_entry_anim=0;game.wave_banner_timer=0;game.special_intro_timer=0;game.enemy_flash=0;game.player_flash=0;game.forced_facing_test=0
				var pose=preload("res://weapon_fit_catalog.gd").sample(game)
				assert(pose.extracted_idle and not pose.sprite_rig)
				await capture(actor+"_"+weapon+"_source_idle_right")
				if actor=="gloomlet" and weapon=="claws":
					game.attack_clock=.01;assert(preload("res://weapon_fit_catalog.gd").sample(game).extracted_pose)
					await capture("gloomlet_claws_source_windup_right")
					game.attack_clock=game.current_attack_interval()
				game.perform_player_attack(false)
				assert(not preload("res://weapon_fit_catalog.gd").sample(game).extracted_idle)
				await capture(actor+"_"+weapon+"_attack_TEMP_preserved")
				game.attack_anim=0;game.attack_clock=game.current_attack_interval();game.enemy_stage_x=30
				var left_pose=preload("res://weapon_fit_catalog.gd").sample(game)
				assert(left_pose.extracted_idle == (actor in ["emberhorn","mosskin"] and weapon in ["wand","orb"]))
				await capture(actor+"_"+weapon+("_source_idle_left" if left_pose.extracted_idle else "_left_TEMP_preserved"))
			game.show_hideout();game.show_title_from_hideout();game.startup_ui.show_lootling_select();game.startup_ui.selected_lootling_id=actor;game.startup_ui.refresh_selector();await capture(actor+"_selector_preserved")
		game.show_hideout();game.hideout_ui.show_stash();await capture("gear_icons")
		game.show_hideout();game.hideout_ui.show_shop();await capture("merchant_icons")
	game.free();helper.free();print("EXTRACTED NATIVE:23 source right idles,4 source left idles, executed attacks and missing-view TEMP fallbacks,7 selectors,phone/tablet");quit()
