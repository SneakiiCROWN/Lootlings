extends "C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-fixtures-058/phase4_native_qa.gd"
func wait_real(ms: int) -> void:
 var until:=Time.get_ticks_msec()+ms
 while Time.get_ticks_msec()<until:await process_frame
func review() -> void:
 var d:=OS.get_environment("LOOTLINGS_CAPTURE_SIZE").split("x");root.size=Vector2i(int(d[0]),int(d[1]))
 game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false)
 game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
 folder="C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-058/rare-currency-050/%sx%s/" % [d[0],d[1]];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
 game.gold=10000;game.meta_shards=1000;game.rift_progress.sigils=2;game.campaign.completed.append("act_i");assert(game.save_hideout_economy())
 game.show_hideout();game.hideout_ui.show_upgrades();await wait_real(230)
 var scroll:ScrollContainer=game.hideout_ui.gold_upgrade_buttons.heartprism.get_parent().get_parent();scroll.scroll_vertical=scroll.get_v_scroll_bar().max_value;await process_frame
 await capture("diamond_specializations")
 var before:int=game.meta_shards;await tap(game.hideout_ui.gold_upgrade_buttons.aegisprism);assert(is_instance_valid(game.touch_ux.dialog));await capture("diamond_confirmation")
 await wait_real(230);await tap(game.touch_ux.confirm_button);assert(game.meta_shards==before-50 and game.gold_upgrades.aegisprism==1 and game.gold==10000)
 game.hideout_ui.show_home();game.retention.show_modes("dungeons");await wait_real(230);await capture("optional_rift_routes")
 for i in [1,2,3,4,5]:assert(game.retention.buttons[i].visible and game.retention.buttons[i].position.y+game.retention.buttons[i].size.y<=game.retention.panel.size.y)
 await tap(game.retention.buttons[5]);assert(is_instance_valid(game.touch_ux.dialog) and game.rift_progress.sigils==2);await capture("rift_entry_confirmation")
 game.touch_ux.close_dialog();assert(game.rift_progress.sigils==2)
 await wait_real(230);await tap(game.retention.buttons[5]);await wait_real(230);await tap(game.touch_ux.confirm_button)
 var limit:=Time.get_ticks_msec()+5000
 while game.state!="route" and Time.get_ticks_msec()<limit:await process_frame
 assert(game.state=="route" and game.retention.rift_active and game.rift_progress.sigils==0)
 await capture("rift_room_choice");await wait_real(230);await tap(game.route_buttons[0]);assert(game.state=="playing")
 await capture("rift_combat")
 assert(game.dungeon.map[0][0].wave==6 and game.dungeon.map[7][0].wave==19)
 game.total_kills=8;game.end_run(true);await capture("rift_rewards")
 assert(game.rift_progress.sigils==1 and game.rift_progress.entry.is_empty())
 var wallet:int=game.gold;game.end_run(true);assert(game.gold==wallet)
 print("RARE CURRENCY NATIVE PASS: real Diamond confirmation and spend, five reachable dungeon actions, cancel without charge, actual travel into harder Rift combat and one-time controlled victory settlement")
 game.free();quit()
