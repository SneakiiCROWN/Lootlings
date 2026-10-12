extends "res://tests/phase4b_native_qa.gd"
func review() -> void:
 var rows:Array=[]
 for viewport in [Vector2i(360,640),Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/branding073/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  var scene=load("res://launch_presentation.tscn").instantiate();root.add_child(scene);current_scene=scene;game=scene
  scene.set_process(false);scene.queue_redraw();await capture("illustrated_startup_layout")
  assert(scene.mouse_filter==Control.MOUSE_FILTER_STOP and scene.load_error.is_empty())
  var started:int=Time.get_ticks_msec();scene.set_process(true)
  while is_instance_valid(scene):await process_frame
  game=current_scene;await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
  assert(game.startup_ui.current_screen=="title" and game.audio_manager.current_music=="TITLE")
  assert(game.startup_ui.TITLE_ART.resource_path=="res://art/backgrounds/lootlings_living_title_068.png")
  await capture("unchanged_main_menu")
  rows.append({"viewport":str(viewport),"layout_capture_not_cold_start_timing":true,"automatic_transition_ms_after_capture":Time.get_ticks_msec()-started,"actual_scene_load_completed":true,"main_menu_music_identity_preserved":true,"physical_android":false})
  game.free();current_scene=null;await process_frame
 var f=FileAccess.open("res://.godot_test_data/branding073/RESULTS.json",FileAccess.WRITE);f.store_string(JSON.stringify(rows,"  "));f.close()
 print("BRANDING073 NATIVE PASS real launch scene cover layouts and real handoff to exact accepted title/music;4 sizes; captured layout held only in QA, no production delay; physical Android pending.");quit()
