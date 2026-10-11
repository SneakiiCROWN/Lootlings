extends SceneTree
var game
var folder := ""
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	assert(DisplayServer.get_name()!="headless")
	OS.set_environment("LOOTLINGS_MOBILE_TEST","1")
	create_timer(100).timeout.connect(func():push_error("Full completion native timeout");quit(1))
	call_deferred("review")
func capture(label: String) -> void:
	await create_timer(.35).timeout
	game.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(folder+label+".png")==OK)
func tap(control: Control) -> void:
	root.grab_focus();await process_frame
	var point: Vector2=root.get_screen_transform()*control.get_global_rect().get_center()-Vector2(root.position)
	var motion:=InputEventMouseMotion.new();motion.position=point;Input.parse_input_event(motion);Input.flush_buffered_events();await process_frame
	var event:=InputEventScreenTouch.new();event.index=0;event.pressed=true;event.position=point
	Input.parse_input_event(event);Input.flush_buffered_events();await create_timer(.07).timeout
	event=InputEventScreenTouch.new();event.index=0;event.pressed=false;event.position=point
	Input.parse_input_event(event);Input.flush_buffered_events();await process_frame;await process_frame
func selected_count(buttons: Array) -> int:
	var count:=0
	for b in buttons:
		if b.get_meta("ui_selected",false):count+=1
	return count
func review() -> void:
	for size in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=size;game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
		game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
		folder="res://.godot_test_data/full_completion/%dx%d/" % [size.x,size.y]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game.show_hideout();await capture("hub")
		var ui=game.hideout_ui
		ui.loadout_panel.visible=true;game.navigate_back();assert(game.state=="hideout" and not ui.loadout_panel.visible)
		game.expedition_tier=2;ui.show_campaign();assert(ui.selected_tier==2 and selected_count(ui.tier_buttons)==1)
		game.expedition_tier=0;ui.show_campaign();assert(ui.selected_tier==0)
		await tap(ui.campaign_list.get_child(0));assert(ui.region_sheet.visible and game.input_surface()==ui.region_sheet)
		assert(selected_count(ui.campaign_list.get_children())==1);await capture("region_selection")
		game.navigate_back();assert(not ui.region_sheet.visible and ui.current_screen=="campaign")
		game.retention.show_modes("dungeons");assert(not ui.visible and selected_count(game.retention.mode_tabs)==1);await capture("dungeons")
		game.retention.show_modes("siege");assert(selected_count(game.retention.mode_tabs)==1);await capture("siege")
		game.navigate_back();assert(game.state=="hideout" and not game.retention.panel.visible and ui.current_screen=="campaign")
		ui.show_phase4("blueprints");await tap(ui.phase4_list.get_child(1))
		var selected: String=ui.phase4_selected;assert(not selected.is_empty())
		ui.refresh_phase4();assert(ui.phase4_selected==selected and selected_count(ui.phase4_list.get_children())==1)
		await capture("blueprints")
		ui.show_phase4("archive");await tap(ui.phase4_list.get_child(1));ui.refresh_phase4()
		assert(selected_count(ui.phase4_list.get_children())==1)
		assert(ui.phase4_list.get_child(1).get_theme_stylebox("normal") is StyleBox)
		await capture("field_notes")
		game.show_personal_home();await tap(game.personal_home.buttons.companions)
		assert(game.personal_home.view=="companions" and not ui.visible)
		for b in ui.companion_buttons.values():assert(b.get_meta("gesture_release_owned",false) and b.size.y>=48)
		await capture("companions");game.navigate_back();assert(game.personal_home.view=="room")
		game.personal_home.open("preferences");game.personal_home.open("companions");game.navigate_back();assert(game.personal_home.view=="preferences")
		await tap(ui.home_display_buttons.trophy);assert(game.profile.homestead.display=="trophy" and selected_count(ui.home_display_buttons.values())==1)
		game.profile=preload("res://profile_store.gd").load_profile(game.PROFILE_SAVE_PATH)
		game.personal_home.open("preferences");assert(ui.home_display_buttons.trophy.get_meta("ui_selected",false))
		await capture("home_preferences")
		var attacks: int=game.attack_sequence
		game.touch_ux.request("Leave Home?","Modal input isolation test",func():push_error("Unexpected confirmation"))
		assert(game.input_surface()==game.touch_ux.dialog);await capture("home_confirmation")
		game.navigate_back();assert(not is_instance_valid(game.touch_ux.dialog) and game.personal_home.view=="preferences" and game.attack_sequence==attacks)
		game.navigate_back();assert(game.personal_home.view=="room");await capture("home")
		game.show_profile_from_personal_home();game.startup_ui.show_lootling_select()
		var before_actor: String=game.startup_ui.selected_lootling_id
		await tap(game.startup_ui.find_child("NextLootling",true,false))
		assert(game.startup_ui.selected_lootling_id!=before_actor and game.startup_ui.selector_portrait.texture!=null)
		game.startup_ui.refresh_selector();assert(game.startup_ui.selector_portrait.texture!=null);await capture("lootling_selection")
		game.navigate_back();assert(game.startup_ui.current_screen=="profile")
		game.startup_ui.show_wanderer_select();assert(game.startup_ui.wanderer_portrait.texture!=null);await capture("wanderer_selection")
		game.startup_ui.identity_panel.visible=true;assert(game.input_surface()==game.startup_ui.identity_panel);game.navigate_back();assert(not game.startup_ui.identity_panel.visible and game.startup_ui.current_screen=="wanderer_select")
		game.navigate_back();game.navigate_back();assert(game.state=="personal_home")
		game.navigate_back();assert(game.state=="hideout" and not game.personal_home.visible)
		ui.show_memories();assert(selected_count(ui.memory_filter_buttons.values())==1);await capture("memory_archive")
		ui.show_lore();assert(selected_count(ui.lore_filter_buttons)==1);await capture("field_notes_filters")
		game.show_hideout();ui.show_campaign();await tap(ui.campaign_list.get_child(0));await tap(ui.region_depart)
		await create_timer(.3).timeout
		if game.presentation_director.vignette.active:
			await capture("region_intro");game.presentation_director.vignette.finish()
		await create_timer(.3).timeout;assert(game.state=="playing")
		game.set_process(false);game.player_x=game.target_player_x();game.wave_banner_timer=0;await capture("combat")
		game.tap_input_cooldown=0;var before_attack: int=game.attack_sequence
		await tap(game.combat_controls.attack);assert(game.attack_sequence==before_attack+1);await capture("attack")
		game.pause_run();await capture("pause");game.navigate_back();assert(game.state=="playing")
		game.show_merchant();await process_frame;await tap(game.merchant_buttons[0]);await tap(game.merchant_buttons[1])
		assert(game.merchant_selection==1 and selected_count(game.merchant_buttons)==1)
		var coins_before: int=game.coins;var equipment_before: String=JSON.stringify(game.inventory.equipped)
		assert(game.merchant_detail.text.contains("IF EQUIPPED:") and game.merchant_detail.text.contains("CURRENTLY EQUIPPED"))
		await capture("merchant_comparison");game.navigate_back();assert(game.coins==coins_before and JSON.stringify(game.inventory.equipped)==equipment_before)
		game.pending_levels=1;game.show_upgrade_choices();await process_frame;await tap(game.upgrade_buttons[0]);await tap(game.upgrade_buttons[1])
		assert(game.upgrade_selection==1 and selected_count(game.upgrade_buttons)==1);await capture("perk_comparison")
		game.navigate_back();assert(game.state=="playing")
		game.show_upgrade_choices();assert(selected_count(game.upgrade_buttons)==0);game.navigate_back()
		game.pending_items.append(game.ItemCatalog.create_item("scrapfang_blade","RARE",8181));game.show_next_item();await capture("reward_keep_skip")
		assert(game.item_compare.text.contains("CURRENTLY EQUIPPED"));game.navigate_back();assert(JSON.stringify(game.inventory.equipped)==equipment_before)
		game.end_run(false);assert(game.state=="result");await capture("results")
		game.navigate_back();assert(game.state=="hideout");ui.show_shop();await capture("hub_shop")
		game.navigate_back();ui.show_stash();await capture("stash");game.navigate_back()
		assert(game.state=="hideout" and ui.current_screen=="home")
		game.free();await process_frame
	print("FULL COMPLETION UI NATIVE PASS: portrait phone/tablet, current difficulty, unique selection, refresh, mode layering, Home parents, persisted display, modal priority, companion touch ownership, roster preview/Back")
	quit()
