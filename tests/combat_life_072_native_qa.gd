extends "res://tests/phase4b_native_qa.gd"
func review() -> void:
 var records:Array=[];var installed:bool=FileAccess.file_exists("res://art/production/phase4e/player_combat_072_manifest.json");var preview:bool=not installed and FileAccess.file_exists("res://art/source/relic_combat_072/CANDIDATES.json")
 OS.set_environment("LOOTLINGS_RELIC_072_PREVIEW","1" if preview else "")
 for viewport in [Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/combat072/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game;helper.prepare("relic_beast","greatsword");game.presentation_director.finish_travel();game.presentation_director.vignette.finish();game.enemy_encounter.clear();game.enemy_entry_anim=0;game.wave_banner_timer=0
  if preview or installed:
   game.forced_facing_test=-1;game.enemy_stage_x=80;game.player_x=game.target_player_x()
   for value in [["windup",0,.02],["strike",.22,2],["follow",.13,2],["recover",.06,2]]:
    game.attack_anim=value[1];game.attack_clock=value[2];game.player_flash=0
    var pose:Dictionary=preload("res://weapon_fit_catalog.gd").sample(game,false);print("POSE072 ",value[0]," ",pose.texture.resource_path," ",pose.support_status," separation ",pose.secondary_hand.distance_to(pose.secondary_grip))
    assert(pose.texture.resource_path.contains("combat_072") and pose.support_status=="authored_two_hand" and pose.secondary_hand.distance_to(pose.secondary_grip)<.1)
    await capture("candidate_"+value[0])
  game.forced_facing_test=0;game.enemy_stage_x=360;game.player_x=game.target_player_x();game.attack_anim=0
  game.rng.seed=720012;game.enemy_encounter.begin(game,3)
  for actor in game.enemy_encounter.actors:actor.enemy_hp=10000;actor.enemy_max_hp=10000;actor.enemy_entry_anim=0
  for index in range(3):
   game.enemy_encounter.load_actor(game,index);await capture("pack_"+str(index))
   var hp:float=game.enemy_hp;game.rng.seed=72001;var rng:int=game.rng.state;game.damage_enemy(10,false,true)
   assert(is_equal_approx(game.enemy_hp,hp-10*game.enemy_hit_multiplier))
   if game.combat_presentation.has_method("contact_position"):
    var contact:Vector2=game.combat_presentation.contacts.back().pos;var bounds:Rect2=game.combat_presentation.rendered_bodies[game.enemy_serial];assert(bounds.has_point(contact));assert(game.particles.back().pos.distance_to(contact)<1)
   records.append({"viewport":str(viewport),"serial":game.enemy_serial,"hp_removed":hp-game.enemy_hp,"rng_before":rng,"rng_after":game.rng.state})
   await capture("impact_"+str(index));game.enemy_encounter.capture(game)
  game.enemy_encounter.clear();game.campaign_id="mossglass_wilds";game.wave=15;game.spawn_enemy();game.enemy_entry_anim=0;game.boss_recovery=.4;await capture("verdant_recovery")
  game.audio_settings.cinematic_reduced_motion=true;await capture("reduced_motion")
  if viewport.x==1920:await sample_performance("combat_geometry",true)
  helper.free();game.free();await process_frame
 var file=FileAccess.open("res://.godot_test_data/combat072/RESULTS.json",FileAccess.WRITE);file.store_string(JSON.stringify(records,"  "));file.close()
 print("COMBAT072 NATIVE PASS actual damage/contact/particles3 pack targets; phone/tablet/desktop; staged pose evidence not acceptance.");quit()
