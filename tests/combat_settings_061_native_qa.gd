extends "res://tests/typography_combat_061_native_qa.gd"
func review() -> void:
	var results:Array=[]
	for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
		root.size=viewport;folder="res://.godot_test_data/issue6-061/settings/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
		var original_music:float=game.audio_settings.music
		game.startup_ui.show_settings();await capture("settings_presets")
		assert(is_equal_approx(game.startup_ui.setting_sliders.music.value,original_music))
		game.startup_ui.apply_audio_preset(3)
		assert(game.startup_ui.audio_preset.get_item_text(game.startup_ui.audio_preset.selected)=="Combat focus")
		assert(is_equal_approx(game.startup_ui.setting_sliders.ui.value,.42))
		game.startup_ui.setting_sliders.ui.value=.31;assert(game.startup_ui.audio_preset.selected==0)
		game.startup_ui.save_settings()
		var saved:Dictionary=Settings.load_settings(game.SETTINGS_SAVE_PATH)
		assert(saved.audio_preset=="Custom" and is_equal_approx(saved.ui,.31))
		game.audio_settings.cinematic_first_time=false;game.show_hideout();game.start_run();game.set_process(false)
		game.enemy_encounter.clear();game.enemy_entry_anim=0;game.special_intro_timer=0;game.enemy_alive=true;game.enemy_hp=100000;game.enemy_max_hp=100000;game.player_x=game.target_player_x()
		await process_frame;await process_frame
		var attack_before:int=game.attack_sequence
		var ui_before:int=game.audio_manager.last_event_msec.get("ui_press",-1)
		await tap(game.combat_controls.attack)
		assert(game.audio_manager.last_event_msec.get("ui_press",-1)==ui_before and game.attack_sequence>attack_before)
		var visible:Rect2=root.get_visible_rect()
		var safe:=Rect2(visible.position+Vector2(0,30),visible.size-Vector2(0,54))
		game.safe_area_layout.apply(safe)
		assert(safe.encloses(Rect2(game.position,game.size*game.scale)))
		await capture("cutout_hud")
		game.enemy_encounter.begin(game,3)
		for actor in game.enemy_encounter.actors:actor.enemy_hp=100000;actor.enemy_max_hp=100000
		game.enemy_encounter.load_actor(game,0);game.debug_enabled=true;game.debug_god_mode=true;game.wave_banner_timer=0
		game.audio_settings.combat_text_mode="Expressive";game.audio_settings.combat_text_size="Large"
		game.set_process(true)
		for warmup in range(120):await process_frame
		var start:int=Time.get_ticks_usec();var samples:Array=[];var intervals:Array=[];var previous_frame:int=start
		for frame in range(120):
			if frame%6==0:
				game.enemy_encounter.select(game,(frame/6 as int)%3)
				game.deal_elemental_hit(2,["Fire","Lightning","Poison"][(frame/6 as int)%3],frame%12==0)
			await process_frame
			samples.append(Performance.get_monitor(Performance.TIME_PROCESS)*1000)
			var now:int=Time.get_ticks_usec();intervals.append((now-previous_frame)/1000.0);previous_frame=now
		await capture("live_three_enemy_combat")
		var seconds:float=(Time.get_ticks_usec()-start)/1000000.0
		game.set_process(false);samples.sort();intervals.sort()
		assert(game.floating_texts.filter(func(x):return x.has("number_kind")).size()<=8)
		results.append({"viewport":str(viewport),"frames":120,"seconds_including_capture":seconds,"process_ms_p95":samples[int(samples.size()*.95)],"frame_interval_ms_p95":intervals[int(intervals.size()*.95)],"warmup_frames":120,"desktop_fps_monitor":Performance.get_monitor(Performance.TIME_FPS),"actual_enemy_count":3,"receipt_limit":8,"attack_menu_click_suppressed":true,"audio_preset_save_reload":true,"simulated_cutout":true,"physical_device":false,"professional_audio_acceptance":false})
		game.free();await process_frame
		game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
		assert(game.audio_settings.audio_preset=="Custom" and is_equal_approx(game.audio_settings.ui,.31))
		game.free();await process_frame
	var file=FileAccess.open("res://.godot_test_data/issue6-061/BATCH_D1_NATIVE.json",FileAccess.WRITE);file.store_string(JSON.stringify(results,"  "));file.close()
	print("D1 061 NATIVE PASS: saved opt-in mix presets, manual Custom values, no Attack UI click, simulated cutout and real three-enemy combat stress/performance across phone/tablet/desktop. Not physical/mobile performance acceptance.")
	quit()
