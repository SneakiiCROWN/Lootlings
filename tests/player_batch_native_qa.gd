extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through isolated native tap/capture helpers.
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(160).timeout.connect(func():push_error("Player combat batch timeout");quit(1))
 call_deferred("review")
func review() -> void:
 var stage:=OS.get_environment("LOOTLINGS_PLAYER_BATCH_STAGE")
 assert(stage in ["before","preview","after"])
 var probes:=[]
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/player-batch-043/"+stage+"/%dx%d/" % [viewport.x,viewport.y]
  DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
  game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
  for pair in [["gloomlet","bow"],["moonkip","wand"],["moonkip","orb"]]:
   helper.prepare(pair[0],pair[1]);game.presentation_director.finish_travel()
   game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.hide()
   if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
   game.enemy_encounter.clear();game.enemy_entry_anim=0;game.forced_facing_test=0
   var interval:float=game.current_attack_interval();var damage:float=game.base_damage
   var held_rng=game.rng.state;var loot_rng=game.loot_system.rng.state
   for facing in [1,-1]:
    game.enemy_stage_x=372 if facing==1 else 60;game.player_x=game.target_player_x()
    for action in ["idle","windup","commit","follow","recovery","hurt"]:
     game.attack_anim=.21 if action=="commit" else .12 if action=="follow" else .045 if action in ["recovery","hurt"] else 0
     game.attack_clock=.025 if action=="windup" else interval;game.player_flash=.18 if action=="hurt" else 0
     var pose=preload("res://weapon_fit_catalog.gd").sample(game,action=="hurt")
     var name:="%s_%s_%s_%s" % [pair[0],pair[1],action,"right" if facing==1 else "left"]
     probes.append({"viewport":str(viewport),"probe":name,"reference_fallback":pose.sprite_rig,"source":pose.texture.resource_path,"support_status":pose.support_status,"primary":str(pose.primary_hand),"projectile_origin":str(pose.projectile)})
     if stage!="before":
      assert(not pose.sprite_rig,"Reference fallback remains: "+name)
      assert(pose.authored_facing==("right_only" if facing==1 else "left_only"))
     await capture(name)
    # Moving remains explicitly unfulfilled; neutral must never masquerade as locomotion.
    game.attack_anim=0;game.attack_clock=interval;game.player_flash=0;game.player_x-=30*facing
    assert(preload("res://weapon_fit_catalog.gd").sample(game,false).sprite_rig)
   assert(game.rng.state==held_rng and game.loot_system.rng.state==loot_rng and game.current_attack_interval()==interval and game.base_damage==damage)
   game.enemy_stage_x=372;game.player_x=game.target_player_x();game.enemy_hp=10000;game.enemy_max_hp=10000;game.attack_anim=0;game.attack_clock=0;game.player_flash=0
   var sequence:int=game.attack_sequence
   game.perform_player_attack(false);assert(not game.attack_projectiles.is_empty())
   game.resolve_player_attack(false);assert(game.attack_sequence==sequence+1)
   await capture(pair[0]+"_"+pair[1]+"_actual_attack")
  helper.free();game.free();await process_frame
 var blocked=probes.filter(func(p):return p.reference_fallback)
 var file=FileAccess.open("res://.godot_test_data/player-batch-043/"+stage+"/PROBES.json",FileAccess.WRITE)
 file.store_string(JSON.stringify({"probes":probes,"reference_fallback_incidents":blocked.size(),"total_probes":probes.size(),"movement":"OPEN; neutral is not locomotion","full_motion_family_accepted":false},"\t"));file.close()
 print("PLAYER BATCH NATIVE PASS: ",probes.size()," exact native probes; reference fallback incidents ",blocked.size(),"; real attacks, unchanged timing/stats/RNG, three viewports; movement remains open")
 quit()
