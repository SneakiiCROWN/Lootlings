extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through the native helper; isolated saves only.
func review() -> void:
	var stage:=OS.get_environment("LOOTLINGS_4C_STAGE")
	if stage.is_empty(): stage="before"
	for size in [Vector2i(1080,2316),Vector2i(1600,2560)]:
		root.size=size; game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
		game.set_process(false); game.app_lifecycle.platform_notifications_enabled=false; game.audio_settings.cinematic_first_time=false
		folder="res://.godot_test_data/phase4c/%s/%dx%d/" % [stage,size.x,size.y]; DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game.show_hideout(); await capture("home")
		game.hideout_ui.request_dialogue("tapped","Salvager"); await capture("dialogue")
		game.hideout_ui.show_campaign(); await capture("expeditions")
		game.retention.show_modes(); await capture("modes"); game.show_hideout()
		game.hideout_ui.show_stash(); await capture("stash")
		game.hideout_ui.show_forge(); await capture("forge")
		game.hideout_ui.show_phase4("blueprints"); await capture("blueprints")
		game.hideout_ui.show_phase4("archive"); await capture("archive")
		game.hideout_ui.show_contracts(); await capture("contracts")
		game.hideout_ui.visible=false; game.startup_ui.visible=true; game.startup_ui.show_lootling_select(); await capture("lootlings")
		game.startup_ui.show_wanderer_select(); await capture("wanderers")
		game.startup_ui.visible=false; game.campaign_id="act_i"; game.start_run(); game.set_process(false); game.wave_banner_timer=0; game.player_x=game.target_player_x(); game.presentation_director.toast_queue.clear(); game.presentation_director.active_toast.clear(); game.presentation_director.toast_panel.visible=false; await capture("combat")
		game.campaign_id="mossglass_wilds"; game.wave=15; game.spawn_enemy(); game.wave_banner_timer=0; game.enemy_entry_anim=0; game.special_intro_timer=0; game.state="playing"; await capture("verdant_mirror")
		game.coins=1000; game.show_merchant(); await capture("merchant")
		game.inspect_merchant_item(0); await capture("merchant_selected")
		game.merchant_panel.visible=false; game.state="playing"; game.show_upgrade_choices(); await capture("level_up"); game.upgrade_panel.visible=false
		game.state="playing"; game.total_kills=20; game.coins=1000; game.end_run(false); await capture("results")
		game.retention.show_spinner(); await capture("spinner")
		if stage=="after":
			game.retention.selected_at=0; await tap(game.retention.buttons[0]); await capture("spinner_windup"); await create_timer(.9).timeout; await capture("spinner_reveal")
			await tap(game.retention.buttons[1]); assert(game.state=="result")
			game.show_hideout(); await create_timer(.3).timeout
			for speaker in ["Salvager","Relic Keeper","Archivist"]:
				game.hideout_ui.request_dialogue("tapped",speaker)
			assert(game.hideout_ui.speech_speaker=="Archivist")
			game.navigate_back(); assert(not game.hideout_ui.speech_panel.visible and game.state=="hideout")
			game.hideout_ui.request_dialogue("tapped","Salvager"); await tap(game.hideout_ui.speech_role); assert(game.hideout_ui.current_screen=="forge")
			game.hideout_ui.show_stash(); await create_timer(.3).timeout; var before: int=game.hideout_ui.selected_entry
			await swipe(game.hideout_ui.stash_list.get_child(0)); assert(game.hideout_ui.selected_entry==before); game.touch_ux.inertia=null
			await tap(game.hideout_ui.stash_list.get_child(0)); assert(game.hideout_ui.stash_detail_panel.visible); await capture("stash_detail")
			game.hideout_ui.show_campaign(); await create_timer(.3).timeout; await tap(game.hideout_ui.campaign_list.get_child(0)); assert(game.hideout_ui.region_sheet.visible); await capture("region_detail")
			game.navigate_back(); assert(not game.hideout_ui.region_sheet.visible)
			game.campaign.finish("act_i"); game.retention.show_modes(); await capture("unlocked_modes"); game.state="hideout"; game.retention.show_modes("dungeons"); await capture("dungeon_navigation"); game.state="hideout"; game.retention.show_modes()
			await capture("siege_navigation"); await tap(game.retention.buttons[0]); await create_timer(1).timeout; assert(game.retention.siege and game.state=="playing"); game.set_process(false)
			game.wave=10; game.retention.round_rule=game.retention.Catalog.round_rule(10,game.retention.rng); game.spawn_enemy(); game.kill_enemy(); game.loot_drops.clear(); game.pending_items.clear()
			await capture("siege_continue"); await tap(game.retention.buttons[1]); assert(game.wave==11 and game.state=="playing")
			game.wave=20; game.retention.round_rule=game.retention.Catalog.round_rule(20,game.retention.rng); game.spawn_enemy(); game.kill_enemy(); game.loot_drops.clear(); game.pending_items.clear()
			await capture("siege_extract"); await tap(game.retention.buttons[0]); assert(game.state=="result")
			await sample_performance("home",false)

		game.free(); await process_frame
	print("PHASE4C NATIVE CAPTURE PASS "+stage); quit()
