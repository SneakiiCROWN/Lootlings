extends "res://tests/phase4b_native_qa.gd"
const Fit=preload("res://weapon_fit_catalog.gd")
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(240).timeout.connect(func():push_error("Polearm 051 timeout");quit(1));call_deferred("review")
func review() -> void:
 var manifest:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/production/phase4e/player_polearm_051_manifest.json"))
 var records:Array=[];var failures:Dictionary={}
 for viewport in [Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/polearm-051/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
  for row in manifest.entries:
   for mythical in [false,true]:
    helper.prepare(row.actor,row.weapon_types[0]);game.presentation_director.finish_travel();game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.hide()
    if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
    if mythical:game.inventory.equipped.Weapon=game.ItemCatalog.create_item("prismsong" if row.weapon_types[0]=="staff" else "tidestar","MYTHICAL SHINY",51)
    game.enemy_encounter.clear();game.enemy_entry_anim=0;game.special_intro_timer=0;game.wave_banner_timer=0
    var interval:float=game.current_attack_interval();var damage:float=game.base_damage;var random_state:int=game.rng.state;var loot_state:int=game.loot_system.rng.state
    var facing:int=-1 if row.facing=="left_only" else 1;game.forced_facing_test=facing;game.player_facing=facing;game.enemy_stage_x=372 if facing==1 else 60;game.player_x=game.target_player_x()
    game.attack_anim=.21 if row.phase=="ATTACK" else .04 if row.phase=="RECOVER" else 0;game.attack_clock=.025 if row.phase=="ANTICIPATE" else interval
    var pose:Dictionary=Fit.sample(game,false)
    var exact:bool=not pose.sprite_rig and pose.texture.resource_path==row.asset_path
    var contact:bool=pose.support_status=="authored_two_hand" and pose.secondary_hand.distance_to(pose.secondary_grip)<.001
    if not exact or not contact:failures[row.contract_slot_id+str(mythical)]={"exact":exact,"support":pose.support_status,"distance":pose.secondary_hand.distance_to(pose.secondary_grip)}
    assert(game.rng.state==random_state and game.loot_system.rng.state==loot_state and game.current_attack_interval()==interval and game.base_damage==damage)
    var transform:Transform2D=pose.root*Transform2D(pose.weapon_rotation,pose.weapon_scale,0,pose.hand)
    var grip:Vector2=pose.weapon_rect.position+Vector2(pose.geometry.grip)*pose.weapon_rect.size
    assert((transform*grip).distance_to(pose.root*pose.hand)<.001)
    var socket:Vector2=pose.weapon_rect.position+Vector2(pose.geometry.socket)*pose.weapon_rect.size
    assert((transform*socket).distance_to(pose.projectile)<.001)
    records.append({"slot_id":row.contract_slot_id,"viewport":str(viewport),"mythical":mythical,"source":pose.texture.resource_path,"exact":exact,"contact":contact})
    if mythical:await capture(row.contract_slot_id.replace(":","_"))
  for actor in ["relic_beast","glimmerfin"]:
   for weapon in ["staff","spear"]:
    helper.prepare(actor,weapon);game.enemy_hp=10000;game.enemy_max_hp=10000;game.enemy_entry_anim=0;game.player_x=game.target_player_x();game.attack_anim=0;game.attack_clock=0
    var seq:int=game.attack_sequence;var enemy_hp:float=game.enemy_hp;game.perform_player_attack(false)
    if weapon=="staff":game.update_attack_projectiles(1.0)
    assert(game.attack_sequence==seq+1 and game.enemy_hp<enemy_hp);await capture(actor+"_"+weapon+"_actual_attack")
  helper.free();game.free();await process_frame
 var file=FileAccess.open("res://.godot_test_data/polearm-051/PROBES.json",FileAccess.WRITE);file.store_string(JSON.stringify({"probes":records,"failures":failures,"physical_device_tested":false,"complete_fluid_animation":false},"  "));file.close()
 print("POLEARM 051 NATIVE: ",records.size()," probes; failures ",JSON.stringify(failures));quit(0 if failures.is_empty() else 1)
