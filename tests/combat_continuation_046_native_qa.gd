extends "res://tests/phase4b_native_qa.gd"
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(240).timeout.connect(func():push_error("Combat 046 timeout");quit(1));call_deferred("review")
func review() -> void:
 var manifest:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/production/phase4e/player_combat_046_manifest.json"));var enemy:Dictionary={"entries":[]}
 var installed:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/production_enemy_manifest.json"))
 for row in installed.entries:
  if row.actor=="dew_hexer" and "combat_046/" in row.asset_path:enemy.entries.append(row)
 if enemy.entries.is_empty() and OS.get_environment("LOOTLINGS_QA_ENEMY_PREVIEW")=="1":enemy=JSON.parse_string(FileAccess.get_file_as_string("res://art/source/combat_continuation_046/ENEMY_CANDIDATE_MANIFEST.json"))
 var records:=[];var failures:={}
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/combat-continuation-046/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
  for row in manifest.entries:
   helper.prepare(row.actor,row.weapon_types[0]);game.presentation_director.finish_travel();game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.hide()
   if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
   game.enemy_encounter.clear();game.enemy_entry_anim=0
   var interval:float=game.current_attack_interval();var damage:float=game.base_damage;var held_rng=game.rng.state;var loot_rng=game.loot_system.rng.state
   var facing:int=-1 if row.facing=="left_only" else 1;game.forced_facing_test=facing;game.enemy_stage_x=372 if facing==1 else 60;game.player_x=game.target_player_x()
   game.attack_anim=.21 if row.phase=="ATTACK" else 0;game.attack_clock=.025 if row.phase=="ANTICIPATE" else interval;game.player_flash=.18 if row.phase=="HURT" else 0
   var pose=preload("res://weapon_fit_catalog.gd").sample(game,row.phase=="HURT")
   var exact:bool=not pose.sprite_rig and pose.texture.resource_path==row.asset_path
   var contact:bool=pose.support_status=="authored_two_hand" and pose.secondary_hand.distance_to(pose.secondary_grip)<.001
   if not exact or not contact:failures[row.contract_slot_id]={"exact":exact,"support":pose.support_status,"distance":pose.secondary_hand.distance_to(pose.secondary_grip)}
   assert(game.rng.state==held_rng and game.loot_system.rng.state==loot_rng and game.current_attack_interval()==interval and game.base_damage==damage)
   var transform:Transform2D=pose.root*Transform2D(pose.weapon_rotation,pose.weapon_scale,0,pose.hand)
   var socket:Vector2=pose.weapon_rect.position+Vector2(pose.geometry.socket)*pose.weapon_rect.size
   assert((transform*socket).distance_to(pose.projectile)<.001)
   records.append({"slot_id":row.contract_slot_id,"viewport":str(viewport),"source":pose.texture.resource_path,"support":pose.support_status,"exact":exact,"contact":contact})
   await capture(row.contract_slot_id.replace(":","_"))
  helper.prepare("emberhorn","greatsword");game.campaign_id="mossglass_wilds";game.wave=1;game.spawn_enemy();game.enemy_name="Dew Hexer";game.enemy_archetype="hexer";game.enemy_is_boss=false;game.enemy_is_miniboss=false;game.enemy_entry_anim=0;game.special_intro_timer=0;game.wave_banner_timer=0
  game.presentation_director.finish_travel();game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.hide()
  for row in enemy.entries:
   var face:String=row.facing;var phase:String=row.state
   game.player_x=120 if face=="left" else 355;game.enemy_stage_x=355 if face=="left" else 140
   game.enemy_hp=10000;game.enemy_max_hp=10000;game.enemy_alive=phase!="defeat";game.enemy_flash=.1 if phase=="hurt" else 0;game.enemy_death_anim=.62 if phase=="defeat" else 0
   game.enemy_attack_anim=.16 if phase=="role commit" else .04 if phase=="recovery" else 0;game.enemy_attack_clock=.12 if phase=="role windup" else game.enemy_attack_interval
   var frame:=preload("res://approved_missing_runtime_art.gd").enemy_neutral(game,game.enemy_stage_x)
   assert(frame.get("authored_state","")==phase and frame.source_facing==face and frame.path==row.asset_path,"Enemy exact state/view missing: "+row.contract_slot_id)
   records.append({"slot_id":row.contract_slot_id,"viewport":str(viewport),"source":frame.path,"exact":true,"contact":true})
   await capture(row.contract_slot_id.replace(":","_"))
  game.enemy_alive=true;game.enemy_flash=0;game.enemy_death_anim=0;game.player_hp=10000;game.player_max_hp=10000;game.enemy_attack_anim=0
  game.debug_god_mode=false;game.player_ward=0;game.enemy_attack_count=0
  var hp:float=game.player_hp;game.perform_enemy_attack();assert(game.player_hp<hp);await capture("dew_hexer_actual_attack")
  for actor in ["emberhorn","pebblewyrm"]:
   helper.prepare(actor,"greatsword");game.enemy_hp=10000;game.enemy_max_hp=10000;game.player_x=game.target_player_x();game.attack_anim=0;game.attack_clock=0
   var seq:int=game.attack_sequence;var enemy_hp:float=game.enemy_hp;game.perform_player_attack(false);assert(game.attack_sequence==seq+1 and game.enemy_hp<enemy_hp);await capture(actor+"_actual_attack")
  print("COMBAT 046 VIEWPORT ",viewport," failures ",JSON.stringify(failures))
  var progress=FileAccess.open("res://.godot_test_data/combat-continuation-046/PROBES.json",FileAccess.WRITE);progress.store_string(JSON.stringify({"probes":records,"failures":failures},"\t"));progress.close()
  helper.free();game.free();await process_frame
 var f=FileAccess.open("res://.godot_test_data/combat-continuation-046/PROBES.json",FileAccess.WRITE);f.store_string(JSON.stringify({"probes":records,"failures":failures,"physical_device_tested":false,"complete_fluid_animation":false},"\t"));f.close()
 print("COMBAT CONTINUATION 046 NATIVE: ",records.size()," probes; failures ",JSON.stringify(failures))
 quit(0 if failures.is_empty() else 1)
