extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree via isolated native capture/touch helpers.
func review() -> void:
	var stage: String=OS.get_environment("LOOTLINGS_4D_STAGE"); if stage.is_empty(): stage="before"
	var dimensions: PackedStringArray=OS.get_environment("LOOTLINGS_CAPTURE_SIZE").split("x")
	var viewport_size:=Vector2i(int(dimensions[0]),int(dimensions[1])); root.size=viewport_size
	game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.set_process(false); game.app_lifecycle.platform_notifications_enabled=false; game.audio_settings.cinematic_first_time=false
	folder="res://.godot_test_data/phase4d/%s/%dx%d/" % [stage,viewport_size.x,viewport_size.y]; DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	game.show_hideout(); game.hideout_ui.scene_time=3.2; await capture("home")
	for speaker in ["Salvager","Relic Keeper","Archivist"]:
		game.hideout_ui.dismiss_dialogue(); game.hideout_ui.request_dialogue("tapped",speaker); await capture({"Salvager":"patch","Relic Keeper":"sera","Archivist":"ilex"}[speaker])
	game.hideout_ui.show_campaign(); await capture("regions")
	game.retention.show_modes(); await capture("siege"); game.show_hideout(); game.retention.show_modes("dungeons"); await capture("dungeon"); game.show_hideout()
	game.hideout_ui.show_stash(); await capture("gear")
	game.hideout_ui.show_forge(); await capture("forge")
	game.hideout_ui.show_phase4("archive"); await capture("archive")
	game.hideout_ui.show_contracts(); await capture("contracts")
	game.hideout_ui.visible=false; game.startup_ui.visible=true; game.startup_ui.show_lootling_select(); await capture("lootlings")
	game.startup_ui.show_wanderer_select(); await capture("wanderers")
	game.startup_ui.visible=false; game.campaign_id="act_i"; game.start_run(); game.set_process(false); game.wave_banner_timer=0; game.player_x=game.target_player_x(); clear_toast(); await capture("combat")
	game.wave=15; game.spawn_enemy(); settle_enemy(); await capture("boss")
	game.campaign_id="mossglass_wilds"; game.spawn_enemy(); settle_enemy(); await capture("verdant")
	game.coins=1000; game.show_merchant(); game.inspect_merchant_item(0); await capture("merchant")
	game.merchant_panel.visible=false; game.state="playing"; game.show_upgrade_choices(); await capture("level_up"); game.upgrade_panel.visible=false
	game.state="playing"; game.total_kills=20; game.coins=1000; game.end_run(false); clear_toast(); await capture("results")
	game.retention.show_spinner(); await capture("spinner")
	if stage=="after":
		await tap(game.retention.buttons[0]); while game.retention.spin_busy: await process_frame
		await capture("spinner_result"); await tap(game.retention.buttons[1]); assert(game.state=="result")
		game.show_hideout(); await create_timer(.22).timeout
		for speaker in ["Salvager","Relic Keeper","Archivist"]: game.hideout_ui.request_dialogue("tapped",speaker)
		assert(game.hideout_ui.speech_speaker=="Archivist"); game.navigate_back(); assert(not game.hideout_ui.speech_panel.visible)
		game.hideout_ui.show_stash(); var before: int=game.hideout_ui.selected_entry
		await swipe(game.hideout_ui.stash_list.get_child(0)); assert(game.hideout_ui.selected_entry==before); game.touch_ux.inertia=null
		await tap(game.hideout_ui.stash_list.get_child(0)); assert(game.hideout_ui.stash_detail_panel.visible); await capture("gear_detail")
		game.hideout_ui.show_campaign(); await tap(game.hideout_ui.campaign_list.get_child(0)); assert(game.hideout_ui.region_sheet.visible); await capture("region_detail")
		game.navigate_back(); assert(not game.hideout_ui.region_sheet.visible)
		game.show_hideout(); await create_timer(.25).timeout
		var attack_count: int=game.attack_sequence
		await tap(game.hideout_ui.home_content.get_node("GateEntrance")); assert(game.hideout_ui.current_screen=="campaign" and game.attack_sequence==attack_count)
		game.show_hideout(); await create_timer(.25).timeout
		await tap(game.hideout_ui.home_content.get_node("StorageChest")); assert(game.hideout_ui.current_screen=="stash" and game.attack_sequence==attack_count)
		game.show_hideout(); await sample_performance("phase4d_home",false)
	game.free(); print("PHASE4D NATIVE PASS "+stage+" "+str(viewport_size)+": 20 presentation screens; isolated saves"); quit()
func clear_toast() -> void:
	game.presentation_director.toast_queue.clear(); game.presentation_director.active_toast.clear(); game.presentation_director.toast_panel.visible=false
func settle_enemy() -> void:
	game.wave_banner_timer=0; game.enemy_entry_anim=0; game.special_intro_timer=0; game.state="playing"; clear_toast()
