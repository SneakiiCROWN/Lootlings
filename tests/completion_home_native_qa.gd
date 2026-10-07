extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree via native helper.
func review() -> void:
	for viewport in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=viewport;folder="res://.godot_test_data/completion-home/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder));game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.show_hideout();await process_frame
		var attacks: int=game.attack_sequence
		game.hideout_ui.show_home_settings();await capture("completion_home_preferences")
		await tap(game.hideout_ui.home_display_buttons.scroll);assert(game.profile.homestead.display=="scroll");game.navigate_back();assert(game.hideout_ui.current_screen=="home");await capture("completion_home_recovered_plans")
		game.hideout_ui.show_home_settings();await tap(game.hideout_ui.home_display_buttons.trophy);game.navigate_back();await capture("completion_home_trophy_stand");assert(game.profile.homestead.display=="trophy")
		game.hideout_ui.show_home_settings();await tap(game.hideout_ui.home_display_buttons.none);game.navigate_back();await capture("completion_home_clear_shelf");assert(not game.hideout_ui.home_weapon.visible and not game.hideout_ui.home_weapon_name.visible)
		game.hideout_ui.show_home_settings();await tap(game.hideout_ui.home_display_buttons.weapon);game.navigate_back();assert(game.hideout_ui.home_weapon.visible);await capture("completion_home_weapon_display")
		assert(game.attack_sequence==attacks);game.free();await process_frame
	print("COMPLETION HOME NATIVE PASS: phone/tablet preferences, touch isolation, Back, saved display choices; pet art still missing");quit()
