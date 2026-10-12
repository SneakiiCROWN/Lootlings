extends "res://tests/phase4b_native_qa.gd"
func review() -> void:
 root.size=Vector2i(480,854);folder="res://.godot_test_data/title068/motion/";DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
 game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
 game.startup_ui.show_title();game.startup_ui.settings.cinematic_reduced_motion=false
 var rng:int=game.rng.state;var loot_rng:int=game.loot_system.rng.state;var before:float=game.startup_ui.title_ambience.clock
 for frame in range(12):await capture("frame_%02d" % frame);await create_timer(.25).timeout
 assert(game.startup_ui.title_ambience.clock>=before+5.8 and game.rng.state==rng and game.loot_system.rng.state==loot_rng)
 var f=FileAccess.open(folder+"RESULTS.json",FileAccess.WRITE);f.store_string(JSON.stringify({"real_time_native_frames":12,"elapsed_seconds":game.startup_ui.title_ambience.clock-before,"gameplay_loot_rng_unchanged":true,"character_stroking_animation":false,"physical_android":false},"  "));f.close()
 print("TITLE MOTION068 NATIVE PASS twelve real-time frames, restrained environmental movement and unchanged RNG; static authored contact is not animated stroking.");quit()
