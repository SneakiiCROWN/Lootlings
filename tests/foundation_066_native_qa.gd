extends "res://tests/phase4b_native_qa.gd"
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/foundation066/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
  for pair in [["dawnweave","hearthpearl"],["tidestar","mirrorwake"],["aurora_thread","bloomward"],["prismsong","starfold"]]:
   game.inventory.reset_to_starter();game.inventory.equip(game.ItemCatalog.create_item(pair[0],"MYTHICAL SHINY",66001));game.inventory.equip(game.ItemCatalog.create_item(pair[1],"MYTHICAL SHINY",66002));game.inventory.equip(game.ItemCatalog.create_item("mossguard_harness","LEGENDARY",66003));game.inventory.equip(game.ItemCatalog.create_item("toxic_burst","RED",66004))
   game.start_run();game.set_process(false);game.wave=15;game.spawn_enemy();game.wave_banner_timer=0;game.enemy_entry_anim=0;game.player_x=game.target_player_x();game.enemy_hp=game.enemy_max_hp
   for id in ["venom","ignite","plague"]:
    for up in game.UPGRADES:
     if up.id==id:game.apply_upgrade_effect(up);break
   game.perform_player_attack(true)
   for i in range(24):game._process(1.0/60)
   game.update_elemental_damage(.8);await capture("combat_"+pair[0])
   assert(game.state=="playing" and game.enemy_alive and game.enemy_poison_stacks<=4+game.build.count("Poison")*3)
   game.show_hideout();game.hideout_ui.show_stash();await process_frame;await tap(game.hideout_ui.stash_list.get_child(0));await capture("gear_"+pair[0])
  game.free();await process_frame
 print("FOUNDATION 066 NATIVE PASS: actual four Mythical weapons/four floating shields, Legendary armour/RED rune, status feedback and Stash on phone/tablet/desktop. Existing animation/contact artistic debt remains open.");quit()
