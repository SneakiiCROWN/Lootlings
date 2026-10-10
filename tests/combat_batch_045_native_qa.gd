extends "res://tests/phase4b_native_qa.gd"
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(180).timeout.connect(func():push_error("Combat batch 045 timeout");quit(1));call_deferred("review")
func review() -> void:
 var manifest:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/production/phase4e/player_combat_045_manifest.json"));var records:=[]
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/combat-batch-045/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
  var prior:=""
  for row in manifest.entries:
   var weapon:String=row.weapon_types[0];var key:String=row.actor+":"+weapon
   if key!=prior:
    helper.prepare(row.actor,weapon);game.presentation_director.finish_travel();game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.hide()
    if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
    game.enemy_encounter.clear();game.enemy_entry_anim=0;prior=key
   var interval:float=game.current_attack_interval();var damage:float=game.base_damage;var held_rng=game.rng.state;var loot_rng=game.loot_system.rng.state
   var facing:int=-1 if row.facing=="left_only" else 1;game.forced_facing_test=facing;game.enemy_stage_x=372 if facing==1 else 60;game.player_x=game.target_player_x()
   game.attack_anim=.21 if row.phase=="ATTACK" else .045 if row.phase=="RECOVER" else 0;game.attack_clock=.025 if row.phase=="ANTICIPATE" else interval;game.player_flash=.18 if row.phase=="HURT" else 0
   var pose=preload("res://weapon_fit_catalog.gd").sample(game,row.phase=="HURT")
   assert(not pose.sprite_rig and pose.texture.resource_path==row.asset_path,"Exact source not selected: "+row.contract_slot_id)
   if row.weapon_overrides.has(weapon):assert(is_equal_approx(pose.geometry.angle,float(row.weapon_overrides[weapon].angle)),"Wrong cached weapon geometry: "+row.contract_slot_id)
   assert(pose.authored_facing==row.facing);assert(pose.foreground!=null if weapon=="wand" else true)
   assert(game.rng.state==held_rng and game.loot_system.rng.state==loot_rng and game.current_attack_interval()==interval and game.base_damage==damage)
   var name:String=row.contract_slot_id.replace(":","_");records.append({"slot_id":row.contract_slot_id,"viewport":str(viewport),"source":pose.texture.resource_path,"support":pose.support_status,"primary":str(pose.primary_hand),"projectile":str(pose.projectile),"fallback":pose.sprite_rig})
   if viewport.x==1080 or (row.phase=="ATTACK" and weapon=="wand") or (row.phase=="HURT" and weapon=="orb"):await capture(name)
  # Actual attacks and hit reactions continue to use the existing gameplay path.
  for actor in ["emberhorn","mosskin","glimmerfin","vault_runner"]:
   helper.prepare(actor,"orb");game.presentation_director.finish_travel();game.enemy_hp=10000;game.enemy_max_hp=10000;game.player_x=game.target_player_x();game.attack_anim=0;game.attack_clock=0
   var seq:int=game.attack_sequence;game.perform_player_attack(false);assert(not game.attack_projectiles.is_empty());game.resolve_player_attack(false);assert(game.attack_sequence==seq+1);await capture(actor+"_actual_attack")
  helper.free();game.free();await process_frame
 var f=FileAccess.open("res://.godot_test_data/combat-batch-045/PROBES.json",FileAccess.WRITE);f.store_string(JSON.stringify({"probes":records,"total_probes":records.size(),"three_viewports":true,"complete_fluid_animation":false,"physical_device_tested":false},"\t"));f.close()
 print("COMBAT BATCH 045 NATIVE PASS: ",records.size()," exact actor/phase/facing/weapon probes and real attacks; unchanged clocks/stats/RNG; full fluid continuity and professional acceptance remain open");quit()
