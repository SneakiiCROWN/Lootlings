extends "res://tests/phase4_native_qa.gd"
const Collection=preload("res://mythical_collection.gd")
const Fit=preload("res://weapon_fit_catalog.gd")
func review() -> void:
 var dims:=OS.get_environment("LOOTLINGS_CAPTURE_SIZE").split("x");root.size=Vector2i(int(dims[0]),int(dims[1]))
 game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false)
 game.app_lifecycle.platform_notifications_enabled=false
 folder="res://.godot_test_data/equipment-feedback-050/%sx%s/" % [dims[0],dims[1]];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
 var cases:=0;var fallbacks:=0;var matrix:Array=[]
 for mode in ["lootling","wanderer"]:
  var actors:Array=game.LootlingCatalog.ENTRIES.keys() if mode=="lootling" else game.Phase4.HUMANS.keys()
  for actor in actors:
   game.profile.avatar_mode=mode
   if mode=="lootling":game.profile.current_lootling_id=actor
   else:game.profile.wanderer.preset_id=actor
   for index in range(4):
    game.inventory.equipped.Weapon=game.ItemCatalog.create_item(Collection.IDS[index],"MYTHICAL SHINY",51)
    game.inventory.equipped.Relic=game.ItemCatalog.create_item(Collection.IDS[index+4],"MYTHICAL SHINY",51)
    game.start_run();game.set_process(false);game.special_intro_timer=0;game.wave_banner_timer=0;game.wave=2;game.spawn_enemy()
    for facing in [1,-1]:
     game.forced_facing_test=facing;game.player_facing=facing;game.attack_anim=.12;game.run_time=1.5
     var pose:Dictionary=Fit.sample(game,false);var pos:Vector2=Fit.world_position(game)
     var shield:Vector2=Collection.shield_position(pos,pose,facing,game.run_time,true)
     assert(shield.x>=28 and shield.x<=452)
     var expected:float=clampf(pos.x+float(pose.root.origin.x)-65*facing,28,452)
     assert(is_equal_approx(shield.x,expected))
     assert(Collection.shield_position(pos,pose,facing,0,true)==Collection.shield_position(pos,pose,facing,10,true))
     if pose.get("sprite_rig",false):fallbacks+=1
     matrix.append({"actor":actor,"mode":mode,"weapon":Collection.IDS[index],"facing":facing,"body_fallback":pose.get("sprite_rig",false),"review":"geometry tested; professional animation acceptance open"})
     cases+=1
 game.profile.avatar_mode="wanderer";game.profile.wanderer.preset_id="vault_runner"
 game.inventory.equipped.Weapon=game.ItemCatalog.create_item("tidestar","MYTHICAL SHINY",51)
 game.inventory.equipped.Relic=game.ItemCatalog.create_item("mirrorwake","MYTHICAL SHINY",51)
 game.start_run();game.set_process(false);game.wave=2;game.spawn_enemy();game.wave_banner_timer=0;game.special_intro_timer=0
 game.player_ward=0;game.combat_presentation.reset();game.combat_presentation.step(game,.01);assert(game.combat_presentation.ward_gain_life==0)
 var hp:float=game.player_hp;var random_state:int=game.rng.state;var damage:float=game.base_damage
 game.player_ward=4;game.combat_presentation.step(game,.01)
 assert(is_equal_approx(game.combat_presentation.ward_gain,4) and game.combat_presentation.ward_gain_life>.4)
 assert(game.player_hp==hp and game.base_damage==damage and game.rng.state==random_state)
 await capture("ward_gain")
 for facing in [1,-1]:
  game.player_facing=facing;game.forced_facing_test=facing;game.attack_anim=.12
  game.combat_presentation.record_incoming(game,3,0)
  await capture("shield_absorb_"+str(facing))
 game.combat_presentation.step(game,1);assert(game.combat_presentation.ward_gain_life==0 and game.combat_presentation.incoming_contacts.is_empty())
 game.player_ward=1;game.combat_presentation.step(game,.01);assert(game.combat_presentation.ward_gain_life==0)
 game.show_hideout();game.hideout_ui.show_stash();await capture("clean_inventory")
 print("EQUIPMENT FEEDBACK NATIVE PASS: "+str(cases)+" actor/weapon/facing geometry cases, bounded shields, actual Ward-only feedback, reduced motion and unchanged HP/damage/RNG. "+str(fallbacks)+" cases still use incomplete body fallbacks; no art contract closures.")
 var evidence:=FileAccess.open(folder+"contact_matrix.json",FileAccess.WRITE);assert(evidence!=null);evidence.store_string(JSON.stringify(matrix,"  "));evidence.close()
 game.free();quit()
