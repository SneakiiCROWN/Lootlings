extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree via guarded native viewport/tap helpers.
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(90).timeout.connect(func():push_error("Resident/outcome timeout");quit(1))
 call_deferred("review")
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/resident-outcome-044/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
  game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  game.show_hideout();game.presentation_director.finish_travel();game.presentation_director.toast_panel.hide();game.hideout_ui.set_process(false)
  for state in ["rest","inspect","talk"]:
   for face in ["left","right"]:
    var body:=preload("res://resident_art_catalog.gd").body_frame("sera",state,face);assert(not body.is_empty())
    var placement:=preload("res://resident_art_catalog.gd").presentation("Relic Keeper",game.hideout_ui.RESIDENT_RECTS["Relic Keeper"],state,face)
    assert(placement.full_body and placement.export_state==state and placement.facing==face)
   game.hideout_ui.scene_time=62 if state=="rest" else 0
   if state=="talk":game.hideout_ui.request_dialogue("tapped","Relic Keeper");assert(game.hideout_ui.speech_panel.visible and game.hideout_ui.speech_speaker=="Relic Keeper")
   for face in ["left","right"]:
    game.hideout_ui.resident_facing=face;game.hideout_ui.queue_redraw();await capture("sera_"+state+"_"+face)
   game.hideout_ui.resident_facing="left"
   if state=="talk":game.hideout_ui.dismiss_dialogue();assert(not game.hideout_ui.speech_panel.visible)
  # Actual inherited engine route and Home separation stay intact.
  game.hideout_ui.engine_requested.emit();await process_frame;assert(game.state=="relic_spinner");await capture("engine_route")
  game.show_hideout();game.hideout_ui.dismiss_dialogue();assert(game.state=="hideout")
  var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game;helper.prepare("moonkip","orb")
  game.presentation_director.finish_travel();game.presentation_director.toast_panel.hide();game.end_run(false)
  assert(game.result_panel.visible and game.result_summary.scroll_active);await capture("grounded_defeat_result")
  await tap(game.restart_button);assert(game.state=="hideout");helper.free();game.free();await process_frame
 print("RESIDENT OUTCOME NATIVE PASS: Sera rest/talk/inspect both views, actual dialogue/dismiss/engine/return, grounded defeat header, three native layouts; sit/work/walk and professional acceptance OPEN")
 quit()
