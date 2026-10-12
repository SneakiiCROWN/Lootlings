extends "res://tests/phase4b_native_qa.gd"
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 assert(DisplayServer.get_name()!="headless")
 create_timer(235).timeout.connect(func():push_error("Title idle timeout");quit(1));call_deferred("review")
func review() -> void:
 root.size=Vector2i(1080,2340);folder="res://.godot_test_data/title-idle066/";DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
 game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
 var title=game.startup_ui;title.show_title();title.settings.cinematic_reduced_motion=false
 await capture("initial");var started:int=Time.get_ticks_msec();var before:float=title.title_ambience.clock;var rng:int=game.rng.state;var loot_rng:int=game.loot_system.rng.state
 await create_timer(180).timeout;await capture("after_three_real_minutes")
 assert(title.title_ambience.clock>=before+175 and game.rng.state==rng and game.loot_system.rng.state==loot_rng and game.attack_sequence==0)
 title.settings.cinematic_reduced_motion=true;title.title_ambience.queue_redraw();await capture("reduced_motion")
 var clock:float=title.title_ambience.clock;await create_timer(2).timeout;assert(title.title_ambience.clock==clock)
 var row:={"real_idle_seconds":(Time.get_ticks_msec()-started)/1000.0,"motes":title.title_ambience.motes.size(),"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"static_bytes":Performance.get_monitor(Performance.MEMORY_STATIC),"reduced_motion_freezes_clock":true,"gameplay_rng_unchanged":true,"android_execution":false,"artistic_acceptance":false}
 var f=FileAccess.open(folder+"RESULTS.json",FileAccess.WRITE);f.store_string(JSON.stringify(row,"  "));f.close()
 game.free();print("TITLE IDLE 066 NATIVE PASS: 180 real seconds, stable bounded input-free ambience, unchanged gameplay/loot RNG, reduced-motion freeze; exported screenshot evidence, no physical Android acceptance.");quit()
