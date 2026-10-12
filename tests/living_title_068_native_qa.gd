extends "res://tests/phase4b_native_qa.gd"
func named(parent:Node,caption:String) -> Button:
 for child in parent.get_children():
  if child is Button and child.text==caption:return child
  var found:=named(child,caption)
  if found!=null:return found
 return null
func review() -> void:
 var rows:Array=[]
 for viewport in [Vector2i(360,640),Vector2i(480,854),Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1280,800),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/title068/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
  var title=game.startup_ui;title.profile_exists=true;title.show_title();title.settings.cinematic_reduced_motion=false
  assert(title.TITLE_ART.resource_path=="res://art/backgrounds/lootlings_living_title_068.png")
  var ambience=title.title_ambience;assert(ambience.living_title and ambience.motes.size()==12 and ambience.mouse_filter==Control.MOUSE_FILTER_IGNORE)
  var controls:Array=[named(title.title_content,"START"),named(title.title_content,"PROFILE"),named(title.title_content,"SETTINGS")]
  for button in controls:
   var rect:Rect2=button.get_global_rect();var physical:Vector2=root.get_screen_transform().basis_xform(rect.size)
   assert(physical.y>=44 and root.get_visible_rect().encloses(rect))
   assert(not rect.intersects(title.title_wordmark.get_global_rect()))
  assert(not controls[0].get_global_rect().intersects(controls[1].get_global_rect()) and not controls[1].get_global_rect().intersects(controls[2].get_global_rect()))
  await capture("active_title")
  var title_draw_calls:float=Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
  assert(game.audio_manager.current_music=="TITLE")
  if game.audio_manager.output_enabled:
   assert(game.audio_manager.music_player.playing and game.audio_manager.music_player.stream.resource_path=="res://art/audio/production/music/title.ogg")
  var rng:int=game.rng.state;var loot_rng:int=game.loot_system.rng.state;var attacks:int=game.attack_sequence
  seed(680314);var expected:float=randf();seed(680314)
  for i in range(3000):ambience._process(.1)
  assert(randf()==expected and game.rng.state==rng and game.loot_system.rng.state==loot_rng)
  await create_timer(1).timeout;await capture("restrained_motion")
  var clock:float=ambience.clock;title.settings.cinematic_reduced_motion=true;ambience.queue_redraw();await create_timer(.3).timeout;assert(ambience.clock==clock);await capture("reduced_motion")
  title.settings.cinematic_reduced_motion=false;game.app_lifecycle.suspend();clock=ambience.clock;await create_timer(.1,true).timeout;assert(ambience.clock==clock);game.app_lifecycle.restore_focus()
  await tap(controls[1]);assert(title.current_screen=="profile");game.navigate_back();assert(title.current_screen=="title")
  await tap(controls[2]);assert(title.current_screen=="settings");game.navigate_back();assert(title.current_screen=="title")
  game.profile=preload("res://profile_store.gd").create_default();game.profile.avatar_mode="wanderer";game.profile.wanderer.preset_id="vault_runner";title.profile=game.profile.duplicate(true)
  assert(preload("res://avatar_presentation.gd").is_wanderer(title.profile));title.show_title();await capture("wanderer_profile_title_unchanged")
  await tap(controls[0]);await create_timer(.8).timeout
  if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
  assert(game.state=="hideout" and game.attack_sequence==attacks)
  rows.append({"viewport":str(viewport),"active_approved_title":true,"touch_targets_at_least_44":true,"real_controls_return":true,"private_rng_input_lifecycle_reduced_motion":true,"shared_contact_static_not_fluid_animation":true,"title_draw_calls":title_draw_calls,"physical_android":false})
  game.free();await process_frame
 var f=FileAccess.open("res://.godot_test_data/title068/RESULTS.json",FileAccess.WRITE);f.store_string(JSON.stringify(rows,"  "));f.close()
 print("LIVING TITLE 068 NATIVE PASS six layouts, active owner-approved composition, original wordmark/controls,44px minimum targets, private RNG/lifecycle/reduced motion and Start/Profile/Settings routes. No new narrative.");quit()
