extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through the isolated native fixture.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	assert(DisplayServer.get_name()!="headless"); call_deferred("review_portraits")
func review_portraits() -> void:
	game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.set_process(false); game.app_lifecycle.platform_notifications_enabled=false
	for layout in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=layout; game.show_hideout(); game.hideout_ui.show_lore()
		game.hideout_ui.lore_filter="CAST"; game.hideout_ui.refresh_lore()
		for id in preload("res://wanderer_catalog.gd").PRESETS:
			for index in range(game.hideout_ui.lore_entries.size()):
				if game.hideout_ui.lore_entries[index].id=="wanderer/"+id:
					game.hideout_ui.lore_index=index; break
			game.hideout_ui.cycle_lore(0)
			var portrait: Texture2D=game.hideout_ui.lore_art.texture
			var version: String="after" if portrait is AtlasTexture else "before"
			if portrait is AtlasTexture:
				assert(portrait.atlas==preload("res://wanderer_catalog.gd").runtime_texture(id))
				assert(portrait.region.size.x>0 and portrait.region.size.y>0)
			assert(game.hideout_ui.lore_heading.text==preload("res://wanderer_catalog.gd").definition(id).display_name)
			folder="res://.godot_test_data/phase4e/canon-lock/%dx%d/%s/" % [layout.x,layout.y,version]
			DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
			await capture("archive_"+id)
	game.free(); print("CANON LOCK NATIVE PASS: five accepted Wanderer identities in phone/tablet Archive; source atlas retained"); quit()
