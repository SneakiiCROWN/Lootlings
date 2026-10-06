extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through isolated native fixture.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	assert(DisplayServer.get_name()!="headless");call_deferred("review_master")
func review_master() -> void:
	game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
	game.inventory.stash.clear()
	for id in ["ember_pop","stormspark","toxic_burst","winter_clause","echo_invoice","storm_ledger","critical_script","frostbell_seal","mire_rune","threefold_ink","shelter_script","fault_script"]:
		assert(game.inventory.keep(preload("res://item_catalog.gd").create_item(id,"RARE",91)))
	for layout in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=layout;folder="res://.godot_test_data/phase4e/master-continuation/"+str(layout.x)+"x"+str(layout.y)+"/";DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game.show_hideout();game.hideout_ui.show_home();await capture("home_preserved")
		game.hideout_ui.show_stash()
		for scroll in [0,260,520,900]:
			game.hideout_ui.stash_scroll.scroll_vertical=scroll;await capture("rune_gear_"+str(scroll))
		game.hideout_ui.show_shop();await capture("merchant_preserved")
		game.hideout_ui.show_home();await capture("return_home_preserved")
		for id in ["ember_pop","winter_clause","echo_invoice"]:
			game.start_run();game.set_process(false)
			game.pending_items=[preload("res://item_catalog.gd").create_item(id,"EPIC",91)]
			game.show_next_item();assert(game.current_item.id==id);await capture("reward_"+id)
	game.free();print("MASTER NATIVE: semantic rune Glyph Gear scroll, merchant and Home return,phone/tablet");quit()
