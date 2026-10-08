extends SceneTree
var game
var folder:String
func _initialize() -> void:
 assert(OS.get_environment("LOOTLINGS_QA")=="1" and ".godot_test_data" in OS.get_user_data_dir())
 create_timer(90).timeout.connect(func():push_error("EXPORTED OWNER ROUTE timeout");quit(1))
 OS.set_environment("LOOTLINGS_MOBILE_TEST","1")
 call_deferred("review")
func capture(label:String) -> void:
 await create_timer(.3).timeout;await RenderingServer.frame_post_draw
 assert(root.get_texture().get_image().save_png(folder+label+".png")==OK)
func tap(control: Control) -> void:
 root.grab_focus(); await process_frame
 var point: Vector2=root.get_screen_transform()*control.get_global_rect().get_center()-Vector2(root.position)
 var motion:=InputEventMouseMotion.new(); motion.position=point; Input.parse_input_event(motion); Input.flush_buffered_events(); await process_frame
 var event:=InputEventScreenTouch.new(); event.index=0; event.pressed=true; event.position=point
 Input.parse_input_event(event); Input.flush_buffered_events(); await create_timer(.07).timeout
 event=InputEventScreenTouch.new(); event.index=0; event.pressed=false; event.position=point
 Input.parse_input_event(event); Input.flush_buffered_events(); await process_frame; await process_frame

func find_button(parent:Node,text:String) -> Button:
 for n in parent.get_children():
  if n is Button and n.text==text:return n
  var found:=find_button(n,text)
  if found!=null:return found
 return null
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder=OS.get_environment("LOOTLINGS_EXPORT_CAPTURE")+"/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
  game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  for id in preload("res://lootlings_ui.gd").ARMOUR_IDS:
   var item:Dictionary=game.ItemCatalog.create_item(id,"EPIC",9901)
   assert(preload("res://lootlings_ui.gd").item_texture(item).resource_path.ends_with("/armour_inventory_v1/"+id+".png"))
  game.start_run();game.set_process(false);game.wave_banner_timer=0;game.special_intro_timer=0;game.enemy_entry_anim=0;game.player_x=game.target_player_x()
  game.presentation_director.finish_travel();game.presentation_director.toast_panel.hide();game.presentation_director.active_toast.clear();game.presentation_director.toast_queue.clear()
  game.player_hp=game.player_max_hp*.53;game.player_ward=12;game.xp=game.xp_needed*.65
  await capture("combat")
  game.wave=15;game.last_spawned_wave=0;game.spawn_enemy();game.enemy_entry_anim=0;game.special_intro_timer=0;game.wave_banner_timer=0;game.enemy_attack_clock=.3
  await capture("boss")
  game.pending_levels=1;game.show_upgrade_choices();await create_timer(.4).timeout
  await tap(game.upgrade_buttons[0]);assert(game.upgrade_buttons[0].get_meta("ui_selected"))
  await tap(game.upgrade_buttons[1]);assert(not game.upgrade_buttons[0].get_meta("ui_selected") and game.upgrade_buttons[1].get_meta("ui_selected"))
  await capture("perks");game.skip_upgrade()
  game.pending_items=[game.ItemCatalog.create_item("bonebow","RARE",9501),game.ItemCatalog.create_item("mossguard_harness","EPIC",9502),game.ItemCatalog.create_item("scrapfang_blade","LEGENDARY",9503)]
  game.boss_reward_options=game.pending_items.duplicate(true);game.pending_items.clear();game.normal_loot_choice=true;game.show_boss_reward()
  await capture("finds")
  game.choose_boss_reward(1);game.accept_item_keep()
  assert(game.inventory.stash.any(func(item):return item.serial==9502))
  game.total_kills=12;game.end_run(false)
  var secured:Array=[game.gold,game.meta_shards,game.inventory.scrap]
  game.end_run(false);assert(secured==[game.gold,game.meta_shards,game.inventory.scrap],"Result must never pay twice")
  await capture("result")
  await tap(game.restart_button);assert(game.state=="hideout")
  for destination in ["upgrades","stash","shop","forge"]:
   game.hideout_ui.call("show_"+destination);await capture(destination)
   if destination=="stash":
    var hub=game.hideout_ui
    await tap(hub.stash_list.get_child(0));assert(hub.stash_list.get_child(0).get_meta("ui_selected"))
    game.navigate_back();await process_frame
    await tap(hub.stash_list.get_child(1));assert(not hub.stash_list.get_child(0).get_meta("ui_selected") and hub.stash_list.get_child(1).get_meta("ui_selected"))
    assert(hub.stash_list.get_child(1).get_theme_stylebox("normal").content_margin_left>=58)
    assert(hub.stash_list.get_child(1).get_theme_stylebox("normal").texture!=null,"Selected nine-patch must retain its real texture")
    await capture("stash_compare")
    game.navigate_back();await process_frame;assert(not hub.stash_list.get_child(1).get_meta("ui_selected"))
   game.navigate_back();await process_frame;assert(game.hideout_ui.current_screen=="home")
  game.start_run();game.set_process(false);game.wave_banner_timer=0;game.special_intro_timer=0;game.enemy_entry_anim=0
  game.player_x=game.target_player_x()
  if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
  game.presentation_director.finish_travel()
  var hp:float=game.enemy_hp
  game.request_tap_attack()
  for frame in range(12):game._process(.05)
  assert(game.enemy_hp<hp or not game.enemy_alive,"A real tap must resolve damage through current combat")
  assert(game.audio_manager.music_source_path("TITLE")=="res://art/audio/production/music/title.ogg")
  game.queue_free();await process_frame
 print("GAMEPLAY FAMILY NATIVE PASS: three viewport combat/boss/find/result/upgrade/stash/shop/forge routes; secured rewards once; natural Hub return")
 quit()
