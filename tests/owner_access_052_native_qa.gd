extends "res://tests/phase4b_native_qa.gd"
const Scope=preload("res://save_scope.gd")
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 OS.set_environment("LOOTLINGS_OWNER_TEST","1");create_timer(180).timeout.connect(func():push_error("Owner access timeout");quit(1));call_deferred("review")
func finger(point:Vector2,down:bool,index:int=0) -> void:
 var event:=InputEventScreenTouch.new();event.index=index;event.pressed=down;event.position=root.get_screen_transform()*point-Vector2(root.position);Input.parse_input_event(event);Input.flush_buffered_events();await process_frame
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/owner-052/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  Scope.active=false;Scope.transitioning=false
  game=load("res://main.tscn").instantiate();root.add_child(game);current_scene=game;await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  game.gold=321;game.meta_shards=17;game.app_lifecycle.persist()
  var normal:Dictionary={}
  for name in ["lootlings_save.cfg","lootlings_inventory.cfg","lootlings_profile.cfg","lootlings_settings.cfg","endgame.cfg","campaign.cfg","contracts.cfg","lootlings_hideout_shop.cfg","expedition_progress.cfg","lootlings_achievements.cfg"]:normal[name]=FileAccess.get_file_as_bytes("user://"+name)
  game.startup_ui.show_title();game.state="startup"
  var left:Vector2=game.get_global_transform()*Vector2(32,32);var right:Vector2=game.get_global_transform()*Vector2(448,32)
  for i in range(6):await finger(left,true);await finger(left,false)
  assert(not is_instance_valid(game.owner_test_access.prompt))
  await finger(left,true,0);await finger(right,true,1);await create_timer(2.65).timeout;await finger(left,false,0);assert(not is_instance_valid(game.owner_test_access.prompt));await finger(right,false,1)
  assert(is_instance_valid(game.owner_test_access.prompt));await capture("owner_pin_setup")
  assert(game.input_surface()==game.owner_test_access.prompt)
  assert(game.owner_test_access.backdrop.mouse_filter==Control.MOUSE_FILTER_STOP)
  # Fixture secret is generated for disposable storage, never shipped.
  var test_pin:String="%06d" % randi_range(100000,999999)
  if game.owner_test_access.configured():
   var config:=ConfigFile.new();config.set_value("access","salt","qa-only");config.set_value("access","digest",("qa-only"+test_pin).sha256_text());assert(config.save("user://lootlings_owner_access.cfg")==OK)
  game.owner_test_access.pin.text="12";await tap(game.owner_test_access.enter_button);assert(not Scope.active and is_instance_valid(game.owner_test_access.prompt))
  if game.owner_test_access.configured():
   game.owner_test_access.pin.text="000000" if test_pin!="000000" else "111111"
   await tap(game.owner_test_access.enter_button);assert(not Scope.active and "Incorrect" in game.owner_test_access.message.text)
  else:
   game.owner_test_access.pin.text=test_pin;game.owner_test_access.confirm_pin.text="wrong";await tap(game.owner_test_access.enter_button);assert(not Scope.active and not game.owner_test_access.configured())
  game.owner_test_access.pin.text=test_pin;game.owner_test_access.confirm_pin.text=test_pin
  await tap(game.owner_test_access.enter_button);await process_frame;await process_frame;game=current_scene
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
 print("OWNER ACCESS 052 NATIVE PASS: secret two-finger hold/release, on-device PIN, same F1 panel four tabs, real touch currency command, all eight Mythicals, Ward/Sigils, reset cancel, sandbox/normal reload and byte-identical normal stores; three layouts")
 quit()
