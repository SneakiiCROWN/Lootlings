extends "res://tests/phase4b_native_qa.gd"
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 assert(DisplayServer.get_name()!="headless")
 create_timer(180).timeout.connect(func():push_error("Regional atmosphere timeout");quit(1))
 call_deferred("review")
func review() -> void:
 var fx=preload("res://regional_atmosphere.gd")
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/region-atmosphere-048/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
  game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  for region in game.CampaignSystem.ORDER:
   game.campaign_id=region;game.start_run();game.set_process(false);game.wave_banner_timer=0;game.special_intro_timer=0;game.presentation_director.finish_travel();game.run_time=10
   var invariants=[game.rng.state,game.loot_system.rng.state,game.enemy_hp,game.player_hp,game.attack_sequence,game.gold]
   var points:Array=fx.points(region,10);assert(points.size()==6)
   for point in points:assert(point.x>=18 and point.x<=462 and point.y>=322 and point.y<=420)
   assert(fx.points(region,10,true).is_empty())
   await capture(region)
   assert([game.rng.state,game.loot_system.rng.state,game.enemy_hp,game.player_hp,game.attack_sequence,game.gold]==invariants)
  game.free();await process_frame
 print("REGIONAL ATMOSPHERE NATIVE PASS: ten original regions, bounded six background details, reduced motion disables, unchanged HP/economy/RNG; three layouts.")
 quit()
