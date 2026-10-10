extends "res://tests/phase4b_native_qa.gd"
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(120).timeout.connect(func():push_error("Chase guidance timeout");quit(1));call_deferred("review")
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/chase-guidance-051/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  game.campaign.completed.append("act_i");game.rift_progress.sigils=2;game.show_hideout()
  for state in [{"collection":0,"pity":0,"pending":[]},{"collection":3,"pity":23,"pending":[]},{"collection":8,"pity":12,"pending":[{"id":"dawnweave","receipt":"qa-reserved"}]}]:
   for key in state:game.rift_progress[key]=state[key]
   var before:Dictionary=game.rift_progress.duplicate(true);var wallet:Array=[game.gold,game.meta_shards];var random_state:int=game.rng.state;var loot_state:int=game.loot_system.rng.state
   var summary:Dictionary=preload("res://rift_progress.gd").chase_summary(before)
   assert(summary.discovered==mini(8,state.collection) and summary.clears_remaining==24-state.pity)
   game.retention.show_modes("dungeons");assert(game.retention.mythical_chase.visible and game.retention.mythical_chase.mouse_filter==Control.MOUSE_FILTER_IGNORE)
   await capture("collection_"+str(state.collection))
   assert(game.rift_progress==before and [game.gold,game.meta_shards]==wallet and game.rng.state==random_state and game.loot_system.rng.state==loot_state)
   assert(game.retention.mythical_chase.position.y+game.retention.mythical_chase.size.y<=game.retention.detail.position.y)
   assert(game.retention.detail.position.y+game.retention.detail.size.y<=game.retention.buttons[1].position.y)
   for i in [1,2,3,4,5]:assert(game.retention.buttons[i].visible and game.retention.buttons[i].size.y>=48)
   game.retention.show_modes("siege");assert(not game.retention.mythical_chase.visible and "Crownroot" in game.retention.detail.text and "Gravebloom" in game.retention.detail.text)
  game.retention.show_modes("dungeons");await create_timer(.25).timeout;await tap(game.retention.buttons[5]);assert(is_instance_valid(game.touch_ux.dialog) and game.rift_progress.sigils==2)
  await capture("entry_confirmation");game.touch_ux.close_dialog();assert(game.rift_progress.sigils==2)
  game.free();await process_frame
 print("CHASE GUIDANCE 051 NATIVE PASS: honest 0/3/8 collection and 24/1/12 clear counters, three viewports, passive icons, unchanged wallets/RNG/progress, complete routes and cancel without spend")
 quit()
