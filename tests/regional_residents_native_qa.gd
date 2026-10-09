extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through the isolated native input/capture helper.
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 OS.set_environment("LOOTLINGS_QA_NPC_PREVIEW","1")
 create_timer(100).timeout.connect(func():push_error("Regional residents timeout");quit(1));call_deferred("review")
func capture(label: String) -> void:
 game.hideout_ui.queue_redraw()
 await super.capture(label)
func review() -> void:
 var catalog=preload("res://resident_art_catalog.gd")
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/regional-residents/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
  game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false;game.set_process(false);game.show_hideout();await create_timer(.5).timeout
  var hub=game.hideout_ui;hub.set_process(false);hub.dismiss_dialogue()
  if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
  var original=[game.gold,game.inventory.scrap,game.inventory.stash.duplicate(true),game.rng.state,game.attack_sequence]
  for speaker in ["Salvager","Archivist"]:
   for facing in ["left","right"]:
    for state in ["rest","inspect","talk"]:
     var entry:Dictionary=catalog.presentation(speaker,Rect2(337,350,74,136),state,facing)
     assert(entry.get("full_body",false) and entry.export_state==state and entry.facing==facing)
     assert(entry.rect.end.y<=490 and entry.rect.size.y>100)
   assert(catalog.presentation(speaker,Rect2(337,350,74,136),"walk").export_state=="rest")
  hub.scene_time=0;await capture("hub_patch_rest_ilex_inspect")
  hub.scene_time=40;await capture("hub_patch_inspect_ilex_rest")
  for id in ["patch","ilex"]:
   var speaker:String="Salvager" if id=="patch" else "Archivist"
   await tap(hub.hub_navigation.talk_buttons[id]);await create_timer(.12).timeout
   if game.presentation_director.vignette.active:game.presentation_director.vignette.finish();await process_frame
   assert(hub.speech_panel.visible and hub.speech_speaker==speaker)
   assert(catalog.presentation(speaker,Rect2(337,350,74,136),hub.resident_activity(speaker)).export_state=="talk")
   await capture(id+"_talk")
   var prior:String=hub.current_screen
   await tap(hub.hub_navigation.world_buttons.ForgeStation);assert(hub.current_screen==prior and hub.speech_panel.visible)
   game.navigate_back();await process_frame;assert(not hub.speech_panel.visible)
  for station in ["ShopEntrance","ArchiveDesk"]:
   await tap(hub.hub_navigation.world_buttons[station])
   assert(hub.current_screen==("shop" if station=="ShopEntrance" else "workshop"))
   game.navigate_back();await process_frame;assert(hub.current_screen=="home")
  assert([game.gold,game.inventory.scrap,game.inventory.stash,game.rng.state,game.attack_sequence]==original)
  assert(FileAccess.get_sha256("res://art/audio/production/music/title.ogg")=="7d53beed1a8ba204fb9fc7809a659ca73c755f328c7c8e456b9a037db65ec9a7")
  game.free();await process_frame
 print("REGIONAL RESIDENTS NATIVE PASS: twelve exact rest/inspect/talk states across both independent views, stable feet pivots, Patch/Ilex Hub bodies, comfortable original talk/station taps, modal isolation, natural returns, unchanged economy/RNG/title; three viewports");quit()
