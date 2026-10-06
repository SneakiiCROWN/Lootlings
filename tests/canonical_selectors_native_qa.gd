extends "res://tests/canonical_integration_native_qa.gd"
# extends SceneTree; actual visible selectors and wrapped trait clearance.
func review() -> void:
	for size in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=size;game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
		game.app_lifecycle.platform_notifications_enabled=false;game.set_process(false)
		folder="res://.godot_test_data/phase4e/canonical-selectors-final/%dx%d/" % [size.x,size.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		var actors: Array=preload("res://lootling_catalog.gd").selectable_ids();actors.append_array(preload("res://wanderer_catalog.gd").PRESETS.keys())
		for actor in actors:
			game.show_hideout();game.show_title_from_hideout()
			var text: Label
			if preload("res://wanderer_catalog.gd").PRESETS.has(actor):
				game.startup_ui.show_wanderer_select();game.startup_ui.selected_wanderer=actor;game.startup_ui.refresh_wanderer_selector();text=game.startup_ui.wanderer_lore
			else:
				game.startup_ui.show_lootling_select();game.startup_ui.selected_lootling_id=actor;game.startup_ui.refresh_selector();text=game.startup_ui.selector_note
			await capture("select_"+actor)
			assert(text.is_visible_in_tree() and text.get_rect().end.y<486 and text.get_minimum_size().y<=68)
		game.free()
	print("CANONICAL SELECTORS: all12 actual previews phone/tablet; wrapped traits fit before affinity/reminder; large scroll cards and confirm buttons preserved");quit()
