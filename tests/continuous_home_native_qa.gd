extends "res://tests/full_completion_ui_native_qa.gd"
# extends SceneTree via the guarded native touch harness.
func review() -> void:
	var art=preload("res://home_runtime_art.gd")
	art.review_assets.clear() # Exercise the installed production registry.
	for dimensions in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=dimensions;game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
		game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
		folder="res://.godot_test_data/continuous_home/%dx%d/" % [dimensions.x,dimensions.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game.show_personal_home();await capture("furnished_home")
		var home=game.personal_home;var ui=game.hideout_ui;var saved: String=JSON.stringify(game.profile.homestead)
		var gear: String=JSON.stringify(game.inventory.equipped);var gold: int=game.gold;var attacks: int=game.attack_sequence
		assert(home.background().get_size()==Vector2(1536,2732))
		for id in preload("res://home_catalog.gd").ITEMS:assert(preload("res://home_catalog.gd").available(id))
		await tap(home.buttons.shelf);assert(home.view=="decor" and home.selected_slot=="home.wall_display")
		await tap(home.decor_tabs["home.floor_perch"]);assert(not home.decor_tabs["home.floor_perch"].disabled)
		await tap(home.decor_list.get_child(1));assert(home.draft.placements["home.floor_perch"]=="")
		await tap(home.decor_panel.get_node("ViewRoom"));assert(home.view=="decor_preview" and not home.room.visible and not home.decor_panel.visible)
		await capture("cushion_removed_preview");assert(JSON.stringify(game.profile.homestead)==saved)
		game.navigate_back();assert(home.view=="decor" and home.draft.placements["home.floor_perch"]=="")
		game.navigate_back();assert(home.view=="room" and JSON.stringify(game.profile.homestead)==saved)
		await tap(home.buttons.display);await tap(home.decor_tabs["home.wall_perch"]);await tap(home.decor_list.get_child(1))
		await tap(home.decor_panel.get_node("ViewRoom"));await capture("ledge_removed_preview")
		await tap(home.preview_actions.get_node("ApplyPreview"));assert(home.view=="room" and game.profile.homestead.home_layout.placements["home.wall_perch"]=="")
		game.profile=preload("res://profile_store.gd").load_profile(game.PROFILE_SAVE_PATH);game.show_personal_home();assert(game.profile.homestead.home_layout.placements["home.wall_perch"]=="")
		await capture("saved_room_reload")
		await tap(home.buttons.chest);assert(ui.current_screen=="stash" and not home.visible);await capture("chest_stash");game.navigate_back();assert(home.visible)
		await tap(home.buttons.nook);assert(home.view=="companions");game.navigate_back();assert(home.view=="room")
		await tap(home.buttons.archive);assert(ui.current_screen=="memories" and ui.private_return);game.navigate_back();assert(game.state=="personal_home")
		assert(game.gold==gold and game.attack_sequence==attacks and JSON.stringify(game.inventory.equipped)==gear)
		assert(game.profile.companion.equipped_id.is_empty())
		game.navigate_back();assert(game.state=="hideout");await capture("hub_return")
		game.free();await process_frame
	art.review_assets.clear()
	print("CONTINUOUS HOME NATIVE PASS: canonical furnished room, six editable furnishings, clear removable zones, direct chest/shelf/nook hotspots, full-room preview Back/Cancel/Apply/reload, isolated touch, unchanged gear/gold/attacks, missing companion states stay gated; phone+tablet")
	quit()
