extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through isolated native capture helper.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	assert(DisplayServer.get_name()!="headless");call_deferred("review_reuse")
func review_reuse() -> void:
	game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
	var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
	for layout in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=layout
		var actors: Array=preload("res://wanderer_catalog.gd").selectable_ids()
		actors.append_array(["relic_beast","emberhorn","mosskin","pebblewyrm","glimmerfin","gloomlet"])
		for actor in actors:
			var weapons: Array=["wand","daggers","sling"] if preload("res://wanderer_catalog.gd").PRESETS.has(actor) else ["sling"]
			for weapon in weapons:
				helper.prepare(actor,weapon);game.enemy_stage_x=355;game.enemy_entry_anim=0;game.enemy_flash=0;game.player_flash=0;game.forced_facing_test=0
				var pose=preload("res://weapon_fit_catalog.gd").sample(game)
				var stage="after" if pose.extracted_idle else "before"
				folder="res://.godot_test_data/phase4e/reuse-canon/"+stage+"/"+str(layout.x)+"x"+str(layout.y)+"/";DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
				await capture(actor+"_"+weapon+"_target_right")
				if weapon=="sling" and actor in ["emberhorn","mosskin"]:
					game.enemy_stage_x=30
					assert(preload("res://weapon_fit_catalog.gd").sample(game).extracted_idle)
					await capture(actor+"_sling_target_left")
	game.free();helper.free();print("REUSE CANON NATIVE: five established Wanderers, one-hand and paired neutral sockets, phone/tablet; real target facing");quit()
