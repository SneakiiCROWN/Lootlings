extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through guarded native capture/touch helpers.
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(285).timeout.connect(func():push_error("Motion batch timeout");quit(1))
 call_deferred("review")
func review() -> void:
 var records:=[]
 var manifest:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/production/phase4e/player_motion_044_manifest.json"))
 var actors:=[]
 for row in manifest.entries:
  if row.actor not in actors:actors.append(row.actor)
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/motion-batch-044/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
  game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
  for actor in actors:
   for weapon in ["wand","orb"]:
    helper.prepare(actor,weapon)
    if preload("res://wanderer_catalog.gd").PRESETS.has(actor):game.profile.wanderer=preload("res://wanderer_catalog.gd").sanitize(game.profile.wanderer)
    game.presentation_director.finish_travel();game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.hide()
    if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
    game.enemy_encounter.clear();game.enemy_entry_anim=0
    var interval:float=game.current_attack_interval();var damage:float=game.base_damage;var held_rng=game.rng.state;var loot_rng=game.loot_system.rng.state
    for facing in [1,-1]:
     game.forced_facing_test=facing;game.enemy_stage_x=372 if facing==1 else 60
     game.player_x=game.target_player_x()-30*facing;game.attack_anim=0;game.attack_clock=interval;game.player_flash=0
     var previous:=""
     for frame in [0,1]:
      game.run_time=frame*.18
      var pose=preload("res://weapon_fit_catalog.gd").sample(game,false)
      assert(not pose.sprite_rig and pose.motion_phase=="MOVE",actor+" movement missing")
      assert(pose.frame_index==frame and pose.texture.resource_path!=previous)
      assert(pose.authored_facing==("right_only" if facing==1 else "left_only"))
      assert(absf((pose.root*Vector2(0,pose.feet_baseline)).y-pose.feet_baseline)<.01)
      previous=pose.texture.resource_path
      var name:="%s_%s_walk_%s_%d" % [actor,weapon,"right" if facing==1 else "left",frame]
      records.append({"viewport":str(viewport),"probe":name,"source":previous,"phase":pose.motion_phase,"frame_index":frame,"fallback":pose.sprite_rig,"support":pose.support_status})
      if viewport.x==1080 or (weapon=="wand" and facing==1):await capture(name)
     assert(game.rng.state==held_rng and game.loot_system.rng.state==loot_rng and game.current_attack_interval()==interval and game.base_damage==damage)
     # Actual action still wins while approaching the enemy: no walk substitutes a release.
     game.attack_anim=.21
     assert(preload("res://weapon_fit_catalog.gd").sample(game,false).motion_phase!="MOVE")
     game.attack_anim=0
    for victory in [true,false]:
     if not victory and weapon=="wand":continue
     if victory and actor=="velvet_astrologer" and weapon=="wand":continue
     helper.prepare(actor,weapon)
     if preload("res://wanderer_catalog.gd").PRESETS.has(actor):game.profile.wanderer=preload("res://wanderer_catalog.gd").sanitize(game.profile.wanderer)
     game.presentation_director.finish_travel();game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.hide()
     if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
     game.end_run(victory);game.set_process(false)
     for facing in [1,-1]:
      game.forced_facing_test=facing
      var pose=preload("res://weapon_fit_catalog.gd").sample(game,false)
      assert(not pose.sprite_rig and pose.motion_phase==("VICTORY" if victory else "DEFEAT"))
      assert(game.result_panel.visible and game.restart_button.visible and game.result_summary.scroll_active)
      var name:="%s_%s_%s_%s" % [actor,weapon,"victory" if victory else "defeat","right" if facing==1 else "left"]
      records.append({"viewport":str(viewport),"probe":name,"source":pose.texture.resource_path,"phase":pose.motion_phase,"fallback":pose.sprite_rig})
      if viewport.x==1080 or (weapon=="orb" and facing==1):await capture(name)
     var paid:int=game.gold;game.end_run(victory);assert(game.gold==paid,"Repeated outcome must not repay")
     await tap(game.restart_button);assert(game.state=="hideout","Result return state: "+game.state)
   print("MOTION NATIVE actor reviewed: ",actor," at ",viewport)
  helper.free();game.free();await process_frame
 var file=FileAccess.open("res://.godot_test_data/motion-batch-044/PROBES.json",FileAccess.WRITE);file.store_string(JSON.stringify({"probes":records,"total_probes":records.size(),"actor_count":actors.size(),"three_viewports":true,"complete_fluid_animation":false,"physical_device_tested":false},"\t"));file.close()
 print("MOTION BATCH NATIVE PASS: ",records.size()," body/frame/weapon/outcome probes, real outcome/return routes, unchanged timing/stats/RNG, three native viewports")
 quit()