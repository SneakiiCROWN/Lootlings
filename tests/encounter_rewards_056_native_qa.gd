extends "res://tests/phase4_native_qa.gd"
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/encounter-056/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.start_run();game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.enemy_encounter.clear();game.wave_banner_timer=0;game.enemy_entry_anim=0;game.enemy_alive=true;game.enemy_attack_clock=.1;game.enemy_attack_count=2;game.enemy_is_boss=false;game.enemy_is_miniboss=false;game.enemy_archetype="hexer";game.enemy_name="Lantern Hexer";game.enemy_hp=80;game.enemy_max_hp=100
  await capture("hexer_mend_tell");game.perform_enemy_attack();await capture("hexer_mend_receipt")
  game.floating_texts.clear();game.particles.clear();game.enemy_is_boss=true;game.campaign_id="act_i";game.enemy_name="Hoard Dragon";game.boss_recovery=.7;game.enemy_attack_clock=3;await capture("dragon_opening")
  game.boss_recovery=0;game.enemy_is_boss=false;game.enemy_archetype="skirmisher";game.enemy_name="Razor Imp";game.enemy_hp=30;game.enemy_attack_count=2;game.enemy_attack_clock=.1
  for variant in ["overcharged","frostbitten","enraged","leeching"]:
   game.enemy_variant_id=variant;await capture("elite_"+variant)
  game.enemy_variant_id="";game.enemy_alive=false;game.loot_drops.clear();game.floating_texts.clear();game.particles.clear();game.presentation_director.toast_queue.clear();game.presentation_director.active_toast.clear();game.presentation_director.toast_panel.visible=false
  for slot in range(3):
   var item:Dictionary=game.ItemCatalog.create_item(["dawnweave","tidestar","prismsong"][slot],"MYTHICAL SHINY",slot)
   game.loot_drops.append({"item":item,"rarity":"MYTHICAL SHINY","boss_choice":true,"visual_slot":slot,"pos":Vector2(90+slot*150,580),"color":game.ItemCatalog.rarity_color("MYTHICAL SHINY"),"pickup":.3,"bounces":1})
  await capture("prismatic_hoard");game.audio_settings.cinematic_reduced_motion=true;await capture("prismatic_reduced_motion")
  game.free();await process_frame
 print("ENCOUNTER REWARDS 056 NATIVE PASS: mend, opening and three canonical prismatic drops at phone/tablet/desktop; artistic acceptance separate.");quit()
