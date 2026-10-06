extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through native helper; test-only isolated inventory.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	assert(DisplayServer.get_name()!="headless"); call_deferred("review_icons")
func review_icons() -> void:
	game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.set_process(false); game.app_lifecycle.platform_notifications_enabled=false
	game.inventory.stash.clear()
	for family in preload("res://weapon_catalog.gd").FAMILIES.keys():
		assert(game.inventory.keep(preload("res://item_catalog.gd").create_item(preload("res://tests/evolution_qa.gd").base_id(family),"RARE",91)))
	for layout in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=layout; folder="res://.godot_test_data/phase4e/extracted-icons/"+str(layout.x)+"x"+str(layout.y)+"/"; DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game.show_hideout(); game.hideout_ui.show_stash()
		for scroll in [0,280,560,900]:
			game.hideout_ui.stash_scroll.scroll_vertical=scroll; await capture("gear_scroll_"+str(scroll))
		game.show_hideout(); game.hideout_ui.show_shop(); await capture("merchant")
	game.free(); print("EXTRACTED ICONS NATIVE: twelve original weapon icons, isolated Gear inventory scroll and merchant phone/tablet"); quit()

