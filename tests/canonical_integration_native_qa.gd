extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree; staged native roster/weapon/region/boss integration evidence.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	assert(DisplayServer.get_name()!="headless");call_deferred("review")
func quiet() -> void:
	game.presentation_director.toast_queue.clear();game.presentation_director.active_toast.clear();game.presentation_director.toast_panel.visible=false
func review() -> void:
	root.size=Vector2i(1080,2340)
	game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false;game.set_process(false)
	folder="res://.godot_test_data/phase4e/canonical-integration/phone/";DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	game.show_hideout();quiet()
	for time in [3,38,66,94]:
		game.hideout_ui.scene_time=time;game.hideout_ui.queue_redraw();await capture("home_existing_idle_bodies_activity_"+str(time))
	for speaker in ["Patch","Sera","Ilex"]:
		game.hideout_ui.request_dialogue("idle",speaker);await capture("home_dialogue_"+speaker);game.hideout_ui.dismiss_dialogue()
	var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
	var actors: Array=preload("res://lootling_catalog.gd").selectable_ids()
	actors.append_array(preload("res://wanderer_catalog.gd").PRESETS.keys())
	for actor in actors:
		game.show_hideout();game.show_title_from_hideout()
		if preload("res://wanderer_catalog.gd").PRESETS.has(actor):
			game.startup_ui.show_wanderer_select();game.startup_ui.selected_wanderer=actor;game.startup_ui.refresh_wanderer_selector();assert(game.startup_ui.wanderer_content.is_visible_in_tree())
		else:
			game.startup_ui.show_lootling_select();game.startup_ui.selected_lootling_id=actor;game.startup_ui.refresh_selector();assert(game.startup_ui.lootling_content.is_visible_in_tree())
		await capture("select_"+actor);game.startup_ui.visible=false
		helper.prepare(actor,"greatsword");game.enemy_entry_anim=0;game.wave_banner_timer=0;game.xp=game.xp_needed*.6;quiet()
		for side in [1,-1]:
			game.forced_facing_test=0;game.player_x=160 if side>0 else 355;game.enemy_stage_x=355 if side>0 else 140
			await capture("combat_"+actor+"_"+str(side))
	for weapon in ["greatsword","greataxe","maul","spear","daggers","claws","bow","crossbow","sling","staff","wand","orb"]:
		helper.prepare("relic_beast",weapon);game.enemy_entry_anim=0;game.wave_banner_timer=0;quiet()
		for side in [1,-1]:
			game.player_x=160 if side>0 else 355;game.enemy_stage_x=355 if side>0 else 140;game.attack_anim=0;game.attack_projectiles.clear();game.projectile_impacts.clear()
			await capture("weapon_"+weapon+"_"+str(side)+"_ready");game.perform_player_attack(false);await capture("weapon_"+weapon+"_"+str(side)+"_actual_strike")
	for region in preload("res://campaign_system.gd").ORDER:
		helper.prepare("relic_beast","greatsword");game.campaign_id=region;game.wave=15;game.current_zone=game.run_zone_for_wave(15);game.current_zone_id=game.current_zone.id;game.spawn_enemy();game.enemy_entry_anim=0;game.special_intro_timer=0;game.player_x=160;quiet()
		await capture("boss_"+region+"_idle")
		game.player_x=355;game.enemy_stage_x=140;await capture("boss_"+region+"_opposite_target")
		game.player_x=160;game.enemy_stage_x=355;game.enemy_attack_clock=.08;await capture("boss_"+region+"_windup")
		game.perform_enemy_attack();game.enemy_attack_clock=game.enemy_attack_interval;await capture("boss_"+region+"_actual_attack")
		game.enemy_flash=.1;await capture("boss_"+region+"_hurt");game.enemy_flash=0;game.combat_presentation.boss_action_time=0;game.boss_recovery=.5;await capture("boss_"+region+"_recovery")
		game.enemy_death_anim=.4;game.enemy_alive=false;await capture("boss_"+region+"_defeat")
	for name in preload("res://regional_enemy_presentation.gd").ENTRIES:
		helper.prepare("relic_beast","greatsword")
		for region in preload("res://world_content_catalog.gd").FUTURE_ZONES:
			for source_name in preload("res://world_content_catalog.gd").FUTURE_ZONES[region].enemies:
				if str(source_name).to_upper()==name:game.campaign_id=region;game.current_zone=game.run_zone_for_wave(1);game.current_zone_id=game.current_zone.id
		game.enemy_name=name;game.enemy_is_boss=false;game.enemy_is_miniboss=false;game.enemy_entry_anim=0;game.wave_banner_timer=0;quiet()
		await capture("regional_"+name.to_snake_case()+"_EXISTING_TEMP")
	for region in preload("res://campaign_system.gd").ORDER:
		helper.prepare("relic_beast","greatsword");game.campaign_id=region;game.wave=6;game.current_zone=game.run_zone_for_wave(6);game.current_zone_id=game.current_zone.id;game.spawn_enemy();game.enemy_entry_anim=0;game.special_intro_timer=0;quiet();await capture("wave6_"+region+"_SEEDED_NOT_GUARANTEED_ELITE")
	game.show_hideout();game.hideout_ui.show_stash();await capture("gear");game.show_hideout();game.hideout_ui.show_shop();await capture("home_shop")
	game.state="result";game.coins=1000;game.retention.show_spinner();await capture("engine_preserved");game.retention.close_spinner();game.result_panel.visible=true;await capture("results_preserved")
	game.show_hideout();game.show_title_from_hideout();await capture("title_preserved")
	root.size=Vector2i(1200,1920);folder="res://.godot_test_data/phase4e/canonical-integration/tablet/";DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	game.startup_ui.visible=false;game.show_hideout();quiet();await capture("home_existing_idle_bodies")
	game.free();helper.free();print("CANONICAL NATIVE: all12 selectors/combat target relationships; all12 weapon families ready/executed strike; all10 boss states; all existing regional bodies explicitly TEMP; Home/menus/engine/title; phone and tablet Home");quit()
