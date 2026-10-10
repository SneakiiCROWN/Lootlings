extends "res://tests/phase4b_native_qa.gd"
var actions := 0
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(180).timeout.connect(func():push_error("Input 049 timeout");quit(1))
 call_deferred("review")
func contact(point:Vector2,down:bool,index:int=0) -> void:
 var e:=InputEventScreenTouch.new();e.index=index;e.pressed=down;e.position=root.get_screen_transform()*point-Vector2(root.position);Input.parse_input_event(e);await process_frame
func mouse(point:Vector2,down:bool) -> void:
 var e:=InputEventMouseButton.new();e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;e.position=point;Input.parse_input_event(e);await process_frame
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/input-049/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.audio_settings.cinematic_first_time=false;game.app_lifecycle.platform_notifications_enabled=false
  for mode in ["merchant","upgrade","item","boss_reward","result","route","relic_spinner"]:
   game.show_hideout();game.start_run();game.set_process(false);game.presentation_director.finish_travel();game.presentation_director.vignette.finish();game.enemy_encounter.clear();game.enemy_hp=100000;game.player_x=game.target_player_x();await process_frame
   var point:Vector2=game.combat_controls.attack.get_global_rect().get_center()
   var start_actions:=actions;var economy=[game.gold,game.inventory.scrap,game.meta_shards]
   await contact(point,true);await contact(point,true,1)
   game.tap_buffer_timer=.4;game.state=mode
   var surface:Control=game.input_surface();surface.show()
   var trap:=Button.new();trap.text="Inherited input must never activate";trap.size=Vector2(300,64);surface.add_child(trap);trap.global_position=point-trap.size*.5;trap.pressed.connect(func():actions+=1)
   # No intervening frame: the release itself must observe the changed surface.
   await contact(point,false)
   assert(game.touch_ux.release_barrier and game.tap_buffer_timer==0)
   for repeat in range(12):await contact(point,true);await contact(point,true);await contact(point,false)
   assert(actions==start_actions and game.touch_ux.release_barrier)
   await contact(point,false,1);assert(not game.touch_ux.release_barrier)
   assert(actions==start_actions and [game.gold,game.inventory.scrap,game.meta_shards]==economy)
   await contact(point,true);await contact(point,false);assert(actions==start_actions+1,"Fresh deliberate press lost")
   trap.queue_free();surface.hide();await process_frame
  # A new modal in the SAME game state must fence both touch and real mouse.
  game.show_hideout();await process_frame
  var point:Vector2=game.hideout_ui.hub_navigation.world_buttons["ForgeStation"].get_global_rect().get_center()
  await contact(point,true);game.touch_ux.request("Test named purchase","No balance change",func():actions+=10)
  await contact(game.touch_ux.confirm_button.get_global_rect().get_center(),false);assert(not game.touch_ux.release_barrier)
  var before:=actions;await create_timer(.2).timeout;assert(actions==before)
  await capture("named_confirmation");game.touch_ux.close_dialog();await process_frame
  await mouse(point,true);game.touch_ux.request("Second surface","Held mouse cannot confirm",func():actions+=10)
  await mouse(game.touch_ux.confirm_button.get_global_rect().get_center(),false);assert(actions==before)
  game.touch_ux.close_dialog();game.free();await process_frame
 print("INPUT 049 NATIVE PASS: 7 screen types, repeated/held/multitouch and frame-perfect transitions, same-state modal/mouse fencing; fresh press works; zero inherited actions; three layouts.")
 quit()
