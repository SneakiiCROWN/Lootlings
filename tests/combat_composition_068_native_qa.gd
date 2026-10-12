extends "res://tests/phase4b_native_qa.gd"
const Numbers=preload("res://combat_numbers.gd")
func review() -> void:
 var stage:String=OS.get_environment("LOOTLINGS_COMPOSITION_STAGE")
 if stage.is_empty():stage="after"
 var rows:Array=[]
 for viewport in [Vector2i(480,854),Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/combat068/"+stage+"/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  game.start_run();game.set_process(false);game.enemy_encounter.clear();game.enemy_entry_anim=0;game.player_x=game.target_player_x()
  game.enemy_name="FROSTBITTEN CRYSTALBOUND THUNDERHIDE SENTINEL";game.enemy_variant_id="frostbitten";game.enemy_variant_name="Frostbitten"
  game.enemy_hp=999999;game.enemy_max_hp=1000000;game.player_hp=999999;game.player_max_hp=1000000;game.player_ward=300;game.xp=123456;game.xp_needed=200000
  game.enemy_burn_dps=10;game.enemy_poison_stacks=12;game.enemy_attack_clock=.05;game.wave_banner_timer=1;game.wave_banner_text="FIRE CHOSEN"
  var rng:int=game.rng.state;var loot_rng:int=game.loot_system.rng.state;var hp:float=game.enemy_hp
  game.audio_settings.combat_text_size="Large";game.audio_settings.combat_aggregate=false
  for kind in ["Physical","Fire_tick","Poison_tick"]:Numbers.add(game,123456,kind)
  assert(game.enemy_hp==hp and game.rng.state==rng and game.loot_system.rng.state==loot_rng)
  if stage=="after":
   var local:Array=game.floating_texts.filter(func(item):return item.has("number_kind"))
   for i in range(1,local.size()):assert(local[i].pos.y-local[i-1].pos.y>=26)
   assert(game.combat_presentation.cue_label_rect(game).end.y<360)
  await capture("solo_status_wave_numbers")
  Numbers.clear(game);game.campaign_id="act_i";game.wave=15;game.spawn_enemy();game.enemy_entry_anim=0;game.enemy_encounter.clear();game.special_intro_timer=0
  game.enemy_hp=9999999;game.enemy_max_hp=10000000;game.enemy_attack_clock=.05;game.enemy_burn_dps=10;game.enemy_poison_stacks=12;game.wave_banner_timer=1;game.wave_banner_text="FINAL WAVE"
  await capture("canonical_boss_tell")
  game.wave=7;game.wave_banner_timer=0;game.enemy_encounter.begin(game,3)
  for index in range(3):
   var actor:Dictionary=game.enemy_encounter.actors[index]
   actor.enemy_name=["FROSTBITTEN CRYSTALBOUND SENTINEL","UnbrokenCrystalboundThunderhide","GILDED DEW HEXER"][index];actor.enemy_hp=999999;actor.enemy_max_hp=1000000;actor.enemy_entry_anim=0;actor.enemy_attack_clock=.05;actor.enemy_burn_dps=10;actor.enemy_poison_stacks=12
  game.enemy_encounter.load_actor(game,0)
  if stage=="after":
   for index in range(3):
    var layout:Dictionary=game.enemy_encounter.hud_layout(game.body_font,game.enemy_encounter.actors[index].enemy_name,index)
    for line in layout.lines:assert(game.body_font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,layout.font_size).x<=layout.name_width)
    assert(layout.bar.position.y>layout.rect.position.y+23+(layout.lines.size()-1)*14)
  await capture("pack_names_bars_tells")
  assert(game.rng.state!=0 and game.loot_system.rng.state!=0)
  game.enemy_encounter.clear();game.enemy_hp=hp;game.rng.state=rng;game.loot_system.rng.state=loot_rng
  game.audio_settings.cinematic_reduced_motion=true;Numbers.clear(game);Numbers.add(game,123456,"critical",false,true);var point:Vector2=game.floating_texts.back().pos;game.update_effects(.1);assert(game.floating_texts.back().pos==point)
  rows.append({"viewport":str(viewport),"stage":stage,"controlled_high_values_and_extreme_names":true,"actual_art_preserved":true,"professional_acceptance":false})
  game.free();await process_frame
 var f=FileAccess.open("res://.godot_test_data/combat068/"+stage+"/RESULTS.json",FileAccess.WRITE);f.store_string(JSON.stringify(rows,"  "));f.close()
 print("COMBAT COMPOSITION 068 NATIVE PASS ",stage," four layouts; high-value HP, full names, status/telegraph separation and motion preference. Controlled layout fixture, not balance acceptance.");quit()
