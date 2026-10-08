extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through native helpers. Neutral previews never enable pets.
func review() -> void:
	for viewport in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=viewport;folder="res://.godot_test_data/companion-idle/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
		game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.show_hideout();game.show_personal_home("companions");await process_frame
		var catalog=preload("res://companion_catalog.gd")
		var partial: Array=catalog.manifest_entries().filter(func(row):return row.get("actor","")=="puffnest" and row.get("state","")=="idle" and row.get("facing","")=="right")
		assert(not catalog.complete_states("puffnest",catalog.FOLLOWER_STATES,partial),"One neutral frame must not enable equip/follower")
		var before=game.profile.duplicate(true);var attacks=game.attack_sequence
		var scroll=game.hideout_ui.companion_collection_content.get_child(3).get_child(0)
		var list=scroll.get_child(0)
		for index in range(catalog.known_ids().size()):
			var id=catalog.known_ids()[index]
			if id in ["stonekith","puffnest"]:
				var body=load(catalog.runtime_path(id,"idle","right"));assert(body is Texture2D and body.get_size()==Vector2(256,256))
				# Inspect before acceptance without bypassing the actual equip gate.
				if catalog.idle_preview(id)!=null:assert(list.get_child(index).get_child(0).texture==body)
				else:list.get_child(index).get_child(0).texture=body
			assert(game.hideout_ui.companion_buttons[id].disabled)
		await capture("collection_neutral_stonekith_preview")
		scroll.scroll_vertical=400;await capture("collection_neutral_puffnest_preview")
		game.navigate_back();game.navigate_back();await capture("personal_home_no_unequipped_pet")
		assert(game.profile==before and game.attack_sequence==attacks)
		assert(game.profile.companion.equipped_id.is_empty())
		game.free();await process_frame
	print("COMPANION NEUTRAL NATIVE PASS: exact right-idle exports, phone/tablet collection previews, incomplete follower sets gated and unowned pets disabled, no profile/input changes")
	quit()
