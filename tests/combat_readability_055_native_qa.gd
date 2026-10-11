extends "res://tests/phase4_native_qa.gd"
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/readability-055/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.start_run();game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
  game.enemy_encounter.clear();game.enemy_alive=true;game.enemy_hp=5000;game.enemy_max_hp=5000;game.enemy_entry_anim=0;game.enemy_hit_multiplier=1;game.wave_banner_timer=0;game.player_hp=65;game.player_max_hp=100;game.player_ward=12;game.floating_texts.clear()
  game.damage_enemy(12,true,true);game.deal_elemental_hit(3,"Fire");game.deal_elemental_hit(4,"Lightning");await capture("critical_elements")
  game.floating_texts.clear();game.enemy_damage=20;game.armor=.25;game.enemy_is_boss=false;game.enemy_is_miniboss=false;game.enemy_archetype="skirmisher";game.enemy_variant_id="";game.perform_enemy_attack();await capture("ward_armour_hp")
  game.floating_texts.clear();game.enemy_burn_dps=12;game.enemy_burn_time=3;game.build.tags["Poison"]=2;game.enemy_poison_stacks=3;game.enemy_poison_time=4;game.dot_tick_clock=0;game.update_elemental_damage(.016);await capture("burn_poison_ticks")
  game.show_merchant();await capture("merchant_greeting");await tap(game.merchant_buttons[0]);await capture("merchant_inspection")
  var peddler=game.merchant_panel.get_node("PackPeddlerBody");assert(not peddler.active_frame.is_empty() and peddler.transition>.9)
  game.free();await process_frame
 print("READABILITY 055 NATIVE PASS: resolved critical/element/mitigation/DOT receipts and merchant reactions on phone/tablet/desktop; artistic review separate.");quit()
