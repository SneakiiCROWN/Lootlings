extends "res://tests/phase4b_native_qa.gd"
func review() -> void:
	for viewport in [Vector2i(360,640), Vector2i(1080,2340), Vector2i(1200,1920), Vector2i(1920,1080)]:
		root.size = viewport
		folder = "res://.godot_test_data/stash064/%dx%d/" % [viewport.x,viewport.y]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game = load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
		game.set_process(false); game.app_lifecycle.platform_notifications_enabled = false
		game.show_hideout(); game.inventory.stash = [game.ItemCatalog.create_item("dawnweave", "MYTHICAL SHINY", 6401)]
		assert(game.inventory.save(game.INVENTORY_SAVE_PATH) == OK)
		game.hideout_ui.show_stash()
		var index := -1
		for i in range(game.hideout_ui.entries.size()):
			if int(game.hideout_ui.entries[i].stash_index) == 0: index = i
		assert(index >= 0); game.hideout_ui.select_entry(index)
		await create_timer(.3).timeout
		var attack_count: int = game.attack_sequence
		var before: Dictionary = game.inventory.equipped.duplicate(true)
		preload("res://save_scope.gd").transitioning = true
		await tap(game.hideout_ui.stash_equip_button)
		preload("res://save_scope.gd").transitioning = false
		assert(game.inventory.equipped == before and game.inventory.stash.size() == 1)
		assert(game.hideout_ui.stash_detail.text.contains("Could not save"))
		await capture("retained_gear_save_error")
		await tap(game.hideout_ui.stash_equip_button)
		assert(game.inventory.equipped.Weapon.id == "dawnweave" and game.attack_sequence == attack_count)
		await capture("saved_equipment")
		game.navigate_back(); assert(game.state == "hideout")
		game.free(); await process_frame
	print("STASH TRANSACTION 064 NATIVE PASS: four layouts, real touch equip failure/retry, retained gear, readable error and no combat leakage.")
	quit()
