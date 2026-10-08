extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree via native helper.
func review() -> void:
	for viewport in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=viewport;folder="res://.godot_test_data/completion-home/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder));game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.show_hideout();await process_frame
		game.hideout_ui.visible=false;game.startup_ui.visible=true;game.startup_ui.show_title();await capture("completion_title_canonical_ensemble")
		var portraits:=0
		for child in game.startup_ui.title_content.get_children():
			if child.name.begins_with("FranchisePortrait_"):
				assert(child.texture!=null and child.mouse_filter==Control.MOUSE_FILTER_IGNORE)
				assert(child.size==Vector2(46,46),"Canonical portrait must fit the title strip")
				assert(child.position.y==533 and child.position.x+child.size.x<=434)
				portraits+=1
		assert(portraits==7 and game.startup_ui.title_roster_buttons.size()==7)
		var saved_profile: String=JSON.stringify(game.startup_ui.profile)
		assert(game.startup_ui.title_roster_buttons.relic_beast.get_meta("ui_selected",false))
		await tap(game.startup_ui.title_roster_buttons.moonkip)
		assert(game.startup_ui.current_screen=="lootling_select" and game.startup_ui.selected_lootling_id=="moonkip")
		assert(JSON.stringify(game.startup_ui.profile)==saved_profile,"Title preview must not change saved actor")
		game.show_hideout()
		var attacks: int=game.attack_sequence
		var home_entry: Button
		for child in game.hideout_ui.home_content.get_children():
			if child is Button and child.text.to_upper()=="HOME":home_entry=child
		assert(home_entry!=null);await tap(home_entry)
		assert(game.state=="personal_home" and game.personal_home.visible and not game.hideout_ui.visible and game.personal_home.scene_file_path=="res://personal_home.tscn")
		assert(game.hideout_ui.home_settings_content.get_parent()==game.personal_home)
		await capture("completion_separate_home_room")
		game.hideout_ui.show_home_settings();await capture("completion_home_preferences")
		game.hideout_ui.show_companion_collection();await capture("completion_companion_collection");assert(game.hideout_ui.companion_buttons.size()==6)
		for b in game.hideout_ui.companion_buttons.values():assert(b.disabled)
		game.hideout_ui.companion_collection_content.get_child(3).get_child(0).scroll_vertical=400;await capture("completion_companion_collection_scrolled")
		game.navigate_back();assert(game.hideout_ui.current_screen=="home_settings")
		await tap(game.hideout_ui.home_display_buttons.scroll);assert(game.profile.homestead.display=="scroll");game.navigate_back();assert(game.personal_home.view=="room");await capture("completion_home_recovered_plans")
		game.hideout_ui.show_home_settings();await tap(game.hideout_ui.home_display_buttons.trophy);game.navigate_back();await capture("completion_home_trophy_stand");assert(game.profile.homestead.display=="trophy")
		game.hideout_ui.show_home_settings();await tap(game.hideout_ui.home_display_buttons.none);game.navigate_back();await capture("completion_home_clear_shelf");assert(game.profile.homestead.display=="none")
		game.hideout_ui.show_home_settings();await tap(game.hideout_ui.home_display_buttons.weapon);game.navigate_back();assert(game.hideout_ui.home_weapon.visible);await capture("completion_home_weapon_display")
		await tap(game.personal_home.buttons.gear);assert(game.state=="hideout" and game.hideout_ui.current_screen=="stash");game.navigate_back();assert(game.state=="personal_home")
		await tap(game.personal_home.buttons.character);assert(game.personal_profile_return and game.startup_ui.visible);game.navigate_back();assert(game.state=="personal_home" and not game.startup_ui.visible)
		await tap(game.personal_home.buttons.leave);assert(game.state=="hideout" and game.hideout_ui.current_screen=="home" and not game.personal_home.visible);await capture("completion_return_main_hub")
		assert(game.attack_sequence==attacks);game.free();await process_frame
	print("COMPLETION HOME NATIVE PASS: phone/tablet preferences, touch isolation, Back, saved display choices; companion unlock ownership preserved");quit()
