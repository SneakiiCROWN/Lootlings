extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through guarded native harness.
func review() -> void:
	for viewport in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=viewport;folder="res://.godot_test_data/premium-title/%dx%d/" % [viewport.x,viewport.y]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
		game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
		game.hideout_ui.visible=false;game.startup_ui.visible=true;game.startup_ui.profile_exists=true;game.startup_ui.show_title()
		await create_timer(.3).timeout;await capture("premium_title")
		var saved_profile:String=JSON.stringify(game.profile)
		var attacks:int=game.attack_sequence
		var buttons:Dictionary={}
		for child in game.startup_ui.title_content.get_children():
			if child is Button and not child.text.is_empty():buttons[child.text]=child
		assert(buttons.size()==3 and game.startup_ui.title_roster_buttons.size()==7)
		for button in buttons.values():
			assert(button.size.y>=56 and button.mouse_filter!=Control.MOUSE_FILTER_IGNORE)
			assert(Rect2(0,0,480,854).encloses(Rect2(button.position,button.size)))
		await tap(buttons.SETTINGS);assert(game.startup_ui.current_screen=="settings");await capture("settings_from_title")
		game.navigate_back();assert(game.startup_ui.current_screen=="title")
		await tap(buttons.PROFILE);assert(game.startup_ui.current_screen=="profile");await capture("profile_from_title")
		game.navigate_back();assert(game.startup_ui.current_screen=="title")
		await tap(game.startup_ui.title_roster_buttons.gloomlet)
		assert(game.startup_ui.current_screen=="lootling_select" and game.startup_ui.selected_lootling_id=="gloomlet")
		assert(JSON.stringify(game.profile)==saved_profile)
		game.navigate_back();assert(game.startup_ui.current_screen=="title")
		await tap(buttons["ENTER THE HIDEOUT"]);assert(game.state=="hideout" and not game.startup_ui.visible)
		assert(game.attack_sequence==attacks);await capture("hideout_from_title")
		saved_profile=JSON.stringify(game.profile)
		game.presentation_director.vignette.cancel()
		game.show_title_from_hideout()
		game.startup_ui.visible=true;game.hideout_ui.visible=false;game.startup_ui.profile_exists=false;game.startup_ui.show_title()
		await tap(buttons["ENTER THE HIDEOUT"]);assert(game.startup_ui.current_screen=="profile_create")
		assert(JSON.stringify(game.profile)==saved_profile and game.attack_sequence==attacks)
		game.free();await process_frame
	print("PREMIUM TITLE NATIVE PASS: phone/tablet real buttons, Settings/Profile Back, character preview, saved continue and first launch, touch isolation")
	quit()
