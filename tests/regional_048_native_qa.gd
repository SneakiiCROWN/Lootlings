extends "res://tests/phase4b_native_qa.gd"
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 assert(DisplayServer.get_name()!="headless")
 if OS.get_environment("LOOTLINGS_048_ENEMY_PREVIEW")=="1":OS.set_environment("LOOTLINGS_QA_ENEMY_PREVIEW","1")
 create_timer(180).timeout.connect(func():push_error("Regional 048 timeout");quit(1));call_deferred("review")
func review() -> void:
 var data:Dictionary={"entries":[]}
 if FileAccess.file_exists("res://art/source/regional_048/CANDIDATES.json"):
  data=JSON.parse_string(FileAccess.get_file_as_string("res://art/source/regional_048/CANDIDATES.json"))
 else:
  data={"entries":[]}
  var installed:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/production_enemy_manifest.json"))
  for row in installed.entries:
   if "/regional_048/" in row.asset_path:data.entries.append(row)
 var records=[]
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/regional-048/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game;helper.prepare("relic_beast","wand")
  game.campaign_id="starfall_archive";game.start_run();game.set_process(false);game.wave_banner_timer=0;game.special_intro_timer=0;game.presentation_director.finish_travel();game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.hide();game.enemy_encounter.clear();game.enemy_entry_anim=0
  for row in data.entries:
   game.enemy_name="Inkling" if row.actor=="inkling" else "Margin Imp";game.enemy_archetype="hexer" if row.actor=="inkling" else "striker";game.enemy_is_boss=false;game.enemy_is_miniboss=false
   var phase:String=row.state;var face:String=row.facing
   game.player_x=120 if face=="left" else 355;game.enemy_stage_x=355 if face=="left" else 140
   game.enemy_hp=10000;game.enemy_max_hp=10000;game.enemy_alive=phase!="defeat";game.enemy_flash=0;game.enemy_death_anim=.4 if phase=="defeat" else 0
   game.enemy_attack_anim=.04 if phase=="recovery" else 0;game.enemy_attack_clock=.12 if phase=="role windup" else game.enemy_attack_interval
   var invariants=[game.rng.state,game.loot_system.rng.state,game.attack_sequence,game.gold]
   var frame:Dictionary=preload("res://approved_missing_runtime_art.gd").enemy_neutral(game,game.enemy_stage_x)
   assert(frame.get("authored_state","")==phase and frame.source_facing==face and frame.path==row.asset_path,"Exact regional state missing: "+row.contract_slot_id)
   await capture(row.contract_slot_id.replace(":","_"));assert([game.rng.state,game.loot_system.rng.state,game.attack_sequence,game.gold]==invariants)
   records.append({"slot_id":row.contract_slot_id,"viewport":str(viewport),"exact":true,"facing":face,"path":frame.path})
   if phase=="role windup":
    var label:Rect2=game.combat_presentation.cue_label_rect(game)
    assert(label.position.y>=370 and label.end.y<=410 and label.size.x==195)
   if phase=="idle":
    game.enemy_name="Overcharged Inkling" if row.actor=="inkling" else "Hasty Margin Imp"
    var variant:Dictionary=preload("res://approved_missing_runtime_art.gd").enemy_neutral(game,game.enemy_stage_x)
    assert(variant.path==row.asset_path and variant.source_facing==face)
    await capture("variant_"+row.actor+"_"+face)

  helper.free();game.free();await process_frame
 var report=FileAccess.open("res://.godot_test_data/regional-048/PROBES.json",FileAccess.WRITE);report.store_string(JSON.stringify({"probes":records,"full_fluid_animation_accepted":false,"physical_device_tested":false},"\t"));report.close()
 print("REGIONAL 048 NATIVE PASS: ",records.size()," exact state/view probes, both original canonical creature identities, unchanged cosmetic RNG/economy; three viewports.")
 quit()
