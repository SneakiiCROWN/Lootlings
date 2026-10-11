extends "res://tests/typography_combat_061_native_qa.gd"
func review() -> void:
	var evidence:Array=[]
	for viewport in [Vector2i(360,640),Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
		root.size=viewport;folder="res://.godot_test_data/issue6-062/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
		game.show_hideout();game.contextual_guide.toggle.button_pressed=true;game.contextual_guide.read_ids.clear();await process_frame
		await tap(game.contextual_guide.chip);assert(game.contextual_guide.panel.visible and game.input_surface()==game.contextual_guide.panel and paused)
		await capture("welcome_guide")
		game.contextual_guide.acknowledge();assert(not paused and "welcome" in game.contextual_guide.read_ids)
		game.start_run();game.enemy_encounter.clear();game.enemy_entry_anim=0;game.special_intro_timer=0;game.wave_banner_timer=0;game.enemy_alive=true
		game.enemy_name="Ancient Crystal-Spined Guardian of the Forgotten Vault";game.enemy_is_boss=true;game.enemy_variant_id="";game.enemy_hp=game.enemy_max_hp;game.enemy_attack_clock=.4
		var layout:Dictionary=game.combat_presentation.enemy_name_layout(game)
		assert(layout.font_size==17 and layout.lines.size()>1)
		for line in layout.lines:assert(game.body_font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,layout.font_size).x<=398.1)
		Numbers.clear(game);Numbers.add(game,30,"Fire",false,true)
		var receipt:Dictionary=game.floating_texts.back();Numbers.step(game,receipt,.8)
		assert(receipt.pos.y>=game.combat_presentation.cue_label_rect(game).end.y+30)
		await capture("boss_long_name")
		game.enemy_is_boss=false;game.enemy_name="Overcharged Lantern Hexer of the Forgotten Marsh";game.enemy_variant_id="overcharged";Numbers.clear(game);Numbers.add(game,5,"Lightning");await capture("enemy_long_name")
		game.enemy_variant_id="";game.player_hp=game.player_max_hp;game.player_ward=0;game.contextual_guide.last_context="";await process_frame
		game.contextual_guide.open("combat");var attacks:int=game.attack_sequence
		await tap(game.combat_controls.attack);assert(game.attack_sequence==attacks)
		if not game.contextual_guide.panel.visible:game.contextual_guide.open("combat")
		await capture("combat_guide");game.navigate_back();assert(not game.contextual_guide.panel.visible and not paused)
		game.player_x=game.target_player_x();game.tap_input_cooldown=0;game.contextual_guide.open("combat");game.contextual_guide.acknowledge();await process_frame;await tap(game.combat_controls.attack);await process_frame;assert("combat" in game.contextual_guide.practised_ids)
		game.contextual_guide.open("currencies");game.contextual_guide.toggle.button_pressed=false;game.contextual_guide.close();await process_frame;assert(not game.contextual_guide.chip.visible)
		var loaded=load("res://contextual_guide.gd").new();game.add_child(loaded);loaded.configure(game);assert(not loaded.enabled and "combat" in loaded.read_ids and "combat" in loaded.practised_ids);loaded.queue_free()
		game.show_hideout();game.hideout_ui.request_dialogue("tapped","Salvager");game.hideout_ui.speech_label.text="A longer test conversation. ".repeat(45);await capture("scrollable_dialogue");assert(game.hideout_ui.speech_label.scroll_active)
		game.hideout_ui.dismiss_dialogue();game.backup_menu.open();assert(game.backup_menu.create_backup()==OK);await capture("local_backup_preview");assert(not game.backup_menu.bundle.is_empty());game.backup_menu.request_restore();assert(is_instance_valid(game.touch_ux.dialog));game.touch_ux.close_dialog();game.backup_menu.close();assert(not paused)
		game.debug_enabled=true
		for field in ["sigils","xp","wave"]:
			var result:String=game.debug_adjust_value({"field":field,"operation":"set","amount":3});assert(not result.begins_with("Invalid"))
		assert(game.rift_progress.sigils==3 and game.wave==3)
		var config:=ConfigFile.new();assert(preload("res://safe_config.gd").load_config(config,game.SAVE_PATH,"progress")==OK)
		evidence.append({"viewport":str(viewport),"boss_wrap_first":true,"receipt_clear_of_cue":true,"guide_modal_no_attack":true,"guide_saved_optional_replay":true,"first_strike_observed":true,"dialogue_scroll":true,"exact_owner_fields":3,"professional_acceptance":false})
		paused=false;game.queue_free();await process_frame;await process_frame
	var file:=FileAccess.open("res://.godot_test_data/issue6-062/NATIVE.json",FileAccess.WRITE);file.store_string(JSON.stringify(evidence,"\t"));file.close()
	print("CONTINUATION 062 NATIVE PASS: wrap-first boss/variant labels, safe hit receipts, optional saved guide, modal touch fencing, dialogue scroll and real owner fields.");quit()
