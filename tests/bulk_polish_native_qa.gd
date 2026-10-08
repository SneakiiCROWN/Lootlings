extends "res://tests/full_completion_ui_native_qa.gd"
# extends SceneTree via the existing fresh-profile native touch harness.
func review() -> void:
	for size in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=size;game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
		game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
		folder="res://.godot_test_data/bulk_polish/%dx%d/" % [size.x,size.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game.show_hideout();await capture("hub")
		var ui=game.hideout_ui
		ui.show_stash();ui.set_stash_filter("WEAPON");assert(not ui.filter_buttons.WEAPON.disabled and ui.filter_buttons.WEAPON.get_meta("ui_selected",false));await capture("stash_filter")
		game.show_personal_home();await capture("home")
		var saved: String=JSON.stringify(game.profile.homestead)
		var gear: String=JSON.stringify(game.inventory.equipped)
		var gold: int=game.gold;var attacks: int=game.attack_sequence
		await tap(game.personal_home.buttons.display);assert(game.personal_home.view=="decor" and game.input_surface()==game.personal_home.decor_panel)
		assert(game.personal_home.decor_tabs["home.floor_perch"].disabled and game.personal_home.decor_tabs["home.wall_perch"].disabled)
		await tap(game.personal_home.decor_list.get_child(1));await capture("decor_trophy_preview")
		assert(JSON.stringify(game.profile.homestead)==saved);game.navigate_back();assert(game.personal_home.view=="room" and JSON.stringify(game.profile.homestead)==saved)
		await tap(game.personal_home.buttons.display);await tap(game.personal_home.decor_list.get_child(1));await tap(game.personal_home.decor_panel.get_node("ApplyDecor"))
		assert(game.personal_home.view=="room" and game.profile.homestead.home_layout.placements["home.wall_display"]=="home_trophy");await capture("home_trophy_saved")
		game.profile=preload("res://profile_store.gd").load_profile(game.PROFILE_SAVE_PATH);game.show_personal_home()
		assert(game.profile.homestead.home_layout.placements["home.wall_display"]=="home_trophy")
		await tap(game.personal_home.buttons.display);await tap(game.personal_home.decor_tabs["home.wall_light"]);await tap(game.personal_home.decor_list.get_child(1));await tap(game.personal_home.decor_panel.get_node("ApplyDecor"))
		assert(game.profile.homestead.home_layout.placements["home.wall_light"]=="")
		game.personal_home.open("preferences");await tap(ui.home_display_buttons.scroll)
		assert(game.profile.homestead.home_layout.placements["home.wall_display"]==null and game.profile.homestead.display=="scroll")
		game.navigate_back();await capture("home_plans_saved")
		await tap(game.personal_home.buttons.archive);assert(game.state=="hideout" and ui.current_screen=="memories" and ui.private_return)
		await capture("personal_memories");game.navigate_back();assert(game.state=="personal_home" and not ui.visible)
		await tap(game.personal_home.buttons.nook);assert(game.personal_home.view=="companions");await capture("companion_collection");game.navigate_back();assert(game.personal_home.view=="room")
		assert(game.inventory.equipped.size()>0 and JSON.stringify(game.inventory.equipped)==gear and game.gold==gold and game.attack_sequence==attacks)
		game.navigate_back();assert(game.state=="hideout" and not game.personal_home.visible)
		game.free();await process_frame
	print("BULK POLISH NATIVE PASS: Hub station framing; phone/tablet Home props, draft/cancel/apply/reload, unavailable perch gate, display binding, personal Archive Back, nook collection; no combat/economy mutation")
	quit()
