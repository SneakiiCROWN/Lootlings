extends "res://tests/phase4b_native_qa.gd"
func changed_pixels(a:Image,b:Image) -> int:
 var count:=0
 for y in range(0,a.get_height(),8):
  for x in range(0,a.get_width(),8):
   var ca:=a.get_pixel(x,y);var cb:=b.get_pixel(x,y)
   if absf(ca.r-cb.r)+absf(ca.g-cb.g)+absf(ca.b-cb.b)>.006:count+=1
 return count
func review() -> void:
 var rows:Array=[]
 for viewport in [Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/world072/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
  var rng:int=game.rng.state;var loot_rng:int=game.loot_system.rng.state;var wallet:int=game.gold
  var results:Dictionary={"viewport":str(viewport),"physical_android":false,"professional_acceptance":false,"new_character_animation":false}
  for space in ["title","hub","home"]:
   if space=="title":game.startup_ui.show_title();game.startup_ui.settings.cinematic_reduced_motion=false
   elif space=="hub":game.show_hideout();game.audio_settings.cinematic_reduced_motion=false
   else:game.show_personal_home();game.audio_settings.cinematic_reduced_motion=false
   await capture(space+"_motion_a");var a:Image=root.get_texture().get_image()
   await create_timer(1.2).timeout
   await capture(space+"_motion_b");var b:Image=root.get_texture().get_image();var changes:=changed_pixels(a,b)
   assert(changes>0,space+" has no real rendered movement")
   results[space+"_changed_sample_pixels"]=changes
   assert(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)<220)
   if space=="title":
    var ambience=game.startup_ui.title_ambience;assert(ambience.mouse_filter==Control.MOUSE_FILTER_IGNORE)
    game.startup_ui.settings.cinematic_reduced_motion=true;var clock:float=ambience.clock;await create_timer(.25).timeout;assert(ambience.clock==clock)
   else:game.audio_settings.cinematic_reduced_motion=true
   await capture(space+"_reduced_motion")
  assert(game.rng.state==rng and game.loot_system.rng.state==loot_rng and game.gold==wallet)
  await tap(game.personal_home.buttons.leave);assert(game.state=="hideout")
  results["private_rng_wallet_navigation"]=true;rows.append(results);game.free();await process_frame
 var f=FileAccess.open("res://.godot_test_data/world072/RESULTS.json",FileAccess.WRITE);f.store_string(JSON.stringify(rows,"  "));f.close()
 print("WORLD072 MOTION NATIVE PASS real separated frames in Title/Hub/Home,3 layouts, reduced motion, input-ignore, unchanged RNG/wallet and Home return; authored characters remain sparse keyframes, not fabricated animation.");quit()
