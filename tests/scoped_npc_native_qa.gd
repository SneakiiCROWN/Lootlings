extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through native helpers; approved panels are not full bodies.
func review() -> void:
	for viewport in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=viewport;folder="res://.godot_test_data/scoped-npc/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
		game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false;game.show_hideout()
		await capture("hub_scoped_patch_ilex")
		var economy=[game.gold,game.meta_shards,game.inventory.scrap,game.inventory.equipped.duplicate(true),game.inventory.stash.duplicate(true)]
		for entry in [["patch","Salvager"],["ilex","Archivist"],["sera","Relic Keeper"]]:
			game.meet_resident(entry[1]);await capture(entry[0]+"_canonical_memory");game.presentation_director.vignette.finish()
			game.hideout_ui.request_dialogue("idle",entry[1]);await capture(entry[0]+"_canonical_dialogue");game.hideout_ui.dismiss_dialogue()
			var memory=preload("res://vignette_catalog.gd").entry("resident/"+entry[0])
			if entry[0] in ["patch","ilex"]:assert(memory.actor.ends_with("_canonical_station_panel.png") and memory.actor_kind=="portrait")
			else:assert(memory.actor.ends_with("sera_idle.png") and memory.actor_kind=="adult")
			game.replay_memory("resident/"+entry[0]);await capture(entry[0]+"_canonical_memory_replay");game.presentation_director.vignette.finish()
		game.hideout_ui.show_memories();await capture("memory_archive_canonical_thumbnails")
		game.hideout_ui.show_lore()
		for id in ["patch","ilex"]:
			game.hideout_ui.lore_index=game.hideout_ui.lore_entries.find(game.hideout_ui.lore_entries.filter(func(page):return page.id=="resident/"+id)[0]);game.hideout_ui.cycle_lore(0)
			assert(game.hideout_ui.lore_art.texture.resource_path==preload("res://resident_art_catalog.gd").portrait_path(id))
			await capture(id+"_canonical_field_notes")
		game.show_hideout();game.hideout_ui.show_shop();assert(game.hideout_ui.background_for_screen()==game.hideout_ui.HIDEOUT_BACKGROUND);await capture("salvager_no_superseded_baked_actor")
		game.show_hideout();game.show_personal_home();await capture("personal_home_architecture_preserved");game.navigate_back();assert(game.state=="hideout")
		assert([game.gold,game.meta_shards,game.inventory.scrap,game.inventory.equipped,game.inventory.stash]==economy)
		game.free();await process_frame
	print("SCOPED NPC NATIVE PASS: two corrected identities in Hub/dialogue/memory/replay, Sera preserved, separate Home retained, no economy changes; source body states remain open");quit()
