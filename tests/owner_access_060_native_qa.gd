extends "res://tests/phase4b_native_qa.gd"
const Scope=preload("res://save_scope.gd")
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 OS.set_environment("LOOTLINGS_OWNER_TEST","1");create_timer(180).timeout.connect(func():push_error("Owner access timeout");quit(1));call_deferred("review")
func finger(point:Vector2,down:bool,index:int=0) -> void:
 var event:=InputEventScreenTouch.new();event.index=index;event.pressed=down;event.position=root.get_screen_transform()*point-Vector2(root.position);Input.parse_input_event(event);Input.flush_buffered_events();await process_frame
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/owner-060/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  Scope.active=false;Scope.transitioning=false;preload("res://owner_test_access.gd").unlocked=false
  game=load("res://main.tscn").instantiate();root.add_child(game);current_scene=game;await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  game.gold=321;game.meta_shards=17;game.app_lifecycle.persist()
  var normal:Dictionary={}
  for name in ["lootlings_save.cfg","lootlings_inventory.cfg","lootlings_profile.cfg","lootlings_settings.cfg","endgame.cfg","campaign.cfg","contracts.cfg","lootlings_hideout_shop.cfg","expedition_progress.cfg","lootlings_achievements.cfg"]:normal[name]=FileAccess.get_file_as_bytes("user://"+name)
  game.startup_ui.show_title();game.state="startup";await process_frame;await process_frame
  var crystal:Vector2=game.startup_ui.title_wordmark.get_global_rect().get_center()
  await finger(crystal,true);await create_timer(.85).timeout;await finger(crystal,false);assert(not Scope.active)
  await finger(crystal,true);await create_timer(2.05).timeout;await finger(crystal,false)
  await process_frame;await process_frame;game=current_scene
  assert(Scope.active and is_instance_valid(game.debug_panel) and game.debug_panel.visible and game.input_surface()==game.debug_panel)
  game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
  var panel=game.debug_panel
  for tab in range(4):panel.filter_sections(tab);await capture("tab_"+str(tab))
  panel.filter_sections(2)
  var gold_button:Button
  for button in panel.find_children("*","Button",true,false):
   if button.get_meta("debug_action","")=="gold":gold_button=button
  var before:int=game.gold;await tap(gold_button);assert(game.gold==before+500)
  game.inventory.stash.clear() # Disposable fixture inventory; test profile intentionally persists across viewport reloads.
  for id in preload("res://mythical_collection.gd").IDS:
   var result:String=game.debug_action("item_id",id);print("MYTHICAL GRANT ",id," ",result," stash ",game.inventory.stash.size(),"/",game.inventory.stash_capacity);assert("Granted" in result,result)
  assert(game.inventory.stash.size()==8)
  game.debug_action("sigils",10);assert(game.rift_progress.sigils>=10)
  game.debug_action("ward",100);assert(game.player_ward>=100)
  game.debug_action("save_test",null)
  # Confirmation cancel does not delete test progress.
  panel.run_action("reset",null);assert(is_instance_valid(game.touch_ux.dialog) and game.input_surface()==game.touch_ux.dialog);game.touch_ux.close_dialog()
  for name in normal:assert(FileAccess.get_file_as_bytes("user://"+name)==normal[name],"Normal save changed: "+name)
  panel.close();assert(not paused and not panel.visible)
  game.owner_test_access.update_layout();assert(game.owner_test_access.shortcut.visible)
  var state_before:String=game.state
  await tap(game.owner_test_access.shortcut);assert(panel.visible and game.state==state_before)
  panel.close();assert(game.state==state_before)
  await capture("ssh_title")
  panel.run_action("relock",null);assert(not preload("res://owner_test_access.gd").unlocked and not game.owner_test_access.shortcut.visible and Scope.active)
  game.owner_test_access.show_activation_title();await process_frame;await process_frame;crystal=game.startup_ui.title_wordmark.get_global_rect().get_center()
  await finger(crystal,true);await create_timer(2.05).timeout;await finger(crystal,false);await process_frame;await process_frame;await create_timer(.1).timeout;assert(panel.visible)
  panel.close();game.owner_test_access.update_layout();assert(game.owner_test_access.shortcut.visible)
  var access=game.owner_test_access;var start:Vector2=access.shortcut.get_global_rect().get_center()
  await finger(start,true);await create_timer(1.05).timeout
  var drag:=InputEventScreenDrag.new();drag.index=0;drag.position=root.get_screen_transform()*(game.get_global_transform_with_canvas()*Vector2(420,700))-Vector2(root.position);Input.parse_input_event(drag);Input.flush_buffered_events();await process_frame
  await finger(game.get_global_transform_with_canvas()*Vector2(420,700),false)
  assert(not panel.visible and access.saved_position)
  var preferred:Vector2=access.preferred;var cfg:=ConfigFile.new();assert(cfg.load(access.PREFS)==OK and cfg.get_value("owner","position")==preferred)
  access.preferred=Vector2.ZERO;access.load_preferences();assert(access.preferred==preferred and preload("res://owner_test_access.gd").unlocked)
  assert(Rect2(Vector2.ZERO,Vector2(480,854)).encloses(Rect2(access.shortcut.position,access.shortcut.size)))
  access.reset_position();assert(not access.saved_position);access.hide_shortcut();assert(not access.shortcut.visible)
  game.startup_ui.show_settings();game.startup_ui.support_panel.show();assert(game.startup_ui.support_panel.find_children("*","Button",true,false).any(func(b):return b.text=="OWNER TOOLS"))
  var backup:Button
  for child in game.startup_ui.support_panel.find_children("*","Button",true,false):
   if child.text=="OWNER TOOLS":backup=child
  assert(backup!=null);await tap(backup);await process_frame;assert(panel.visible);panel.close();game.show_hideout();access.update_layout();assert(access.shortcut.visible)
  var hub_state:String=game.state;await tap(game.owner_test_access.shortcut);assert(panel.visible and game.state==hub_state);panel.close();await capture("shh_hub")
  game.show_hideout();game.start_run();game.set_process(false);game.presentation_director.finish_travel();game.presentation_director.vignette.finish()
  var attack:Vector2=game.combat_controls.attack.get_global_rect().get_center();var balance:int=game.gold
  await finger(attack,true,1);panel.open();await finger(attack,false,1)
  for i in range(12):await finger(attack,true);await finger(attack,false)
  assert(game.gold==balance and game.state=="playing")
  for scroll in panel.find_children("*","ScrollContainer",true,false):assert(not scroll.get_global_rect().intersects(game.combat_controls.attack.get_global_rect()))
  panel.close()
  # Returning reloads normal objects, not just their visible labels.
  Scope.switch_profile(self,false);await process_frame;await process_frame;game=current_scene;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
  assert(not Scope.active and game.gold==321 and game.meta_shards==17 and game.inventory.stash.is_empty())
  for name in normal:assert(FileAccess.get_file_as_bytes("user://"+name)==normal[name])
  game.free();current_scene=null;await process_frame
 print("OWNER ACCESS 060 NATIVE PASS: independent visible logo center two-second hold, short hold rejection, saved normalized hold-drag/no accidental open/reset/hide/backup route; persistent SHH reopen/return, same F1 panel four tabs, real touch currency command, all eight Mythicals, Ward/Sigils, reset cancel, sandbox/normal reload and byte-identical normal stores; three layouts")
 quit()
