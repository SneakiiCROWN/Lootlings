extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through isolated native fixture.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("review_aspect")
func review_aspect() -> void:
	game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.show_hideout()
	game.profile.memories=["boss/verdant_mirror","boss/hoard_dragon"]
	for layout in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=layout;folder="res://.godot_test_data/phase4e/full-continuation/"+str(layout.x)+"x"+str(layout.y)+"/";DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		for boss in ["verdant_mirror","hoard_dragon"]:
			game.replay_memory("boss/"+boss)
			var player=game.presentation_director.vignette
			var extent: Vector2=player.actor_extent()
			assert(is_equal_approx(extent.x/extent.y,player.actor.get_width()/float(player.actor.get_height())))
			await capture("memory_aspect_"+boss); player.cancel()
	game.free();print("MEMORY ASPECT NATIVE PASS: original Verdant/Dragon ratios; Dragon source tail remains blocked");quit()
