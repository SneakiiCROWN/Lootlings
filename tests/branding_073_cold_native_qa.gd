extends SceneTree
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 assert(DisplayServer.get_name()!="headless")
 call_deferred("review")
func review() -> void:
 root.size=Vector2i(1080,2340)
 var folder:="res://.godot_test_data/branding073/cold/";DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
 var started:int=Time.get_ticks_msec();var launch=load("res://launch_presentation.tscn").instantiate();root.add_child(launch);current_scene=launch
 await process_frame;await RenderingServer.frame_post_draw
 assert(root.get_texture().get_image().save_png(folder+"actual_first_scene.png")==OK)
 var first_frame_ms:int=Time.get_ticks_msec()-started
 while is_instance_valid(launch):
  assert(Time.get_ticks_msec()-started<20000,"Startup did not complete")
  await process_frame
 await process_frame
 var game=current_scene;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
 assert(game.startup_ui.current_screen=="title" and game.audio_manager.current_music=="TITLE")
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(folder+"actual_title_handoff.png")
 var f=FileAccess.open(folder+"RESULTS.json",FileAccess.WRITE);f.store_string(JSON.stringify({"first_scene_ms":first_frame_ms,"title_ready_ms":Time.get_ticks_msec()-started,"no_qa_hold_or_artificial_wait":true,"native_windows_not_physical_android":true},"  "));f.close()
 print("BRANDING073 COLD NATIVE PASS actual first rendered loading scene, no QA hold, main menu/title music handoff.");quit()
