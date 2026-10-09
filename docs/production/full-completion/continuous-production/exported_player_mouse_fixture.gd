extends SceneTree
var game
func _initialize() -> void:
 assert(OS.get_environment("LOOTLINGS_QA")=="1" and ".godot_test_data" in OS.get_user_data_dir());create_timer(35).timeout.connect(func():push_error("Mouse route timeout");quit(1));call_deferred("review")
func click(b:Control) -> void:
 root.grab_focus();await create_timer(.35).timeout
 var p:Vector2=root.get_screen_transform()*b.get_global_rect().get_center()-Vector2(root.position)
 var move:=InputEventMouseMotion.new();move.position=p;Input.parse_input_event(move);Input.flush_buffered_events();await process_frame
 for down in [true,false]:
  var e:=InputEventMouseButton.new();e.position=p;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;Input.parse_input_event(e);Input.flush_buffered_events();await create_timer(.07).timeout
func review() -> void:
 for viewport in [Vector2i(1920,1080)]:
  root.size=viewport;game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false;game.set_process(false);game.show_hideout();await create_timer(1.2).timeout
  var attacks:int=game.attack_sequence
  await click(game.hideout_ui.hub_navigation.world_buttons.ShopEntrance);assert(game.hideout_ui.current_screen=="shop")
  await click(game.hideout_ui.shop_offer_buttons[0]);assert(game.hideout_ui.selected_shop_offer==0)
  game.navigate_back();await process_frame;game.retention.progress.data.free_spins=1;game.retention.progress.save();await click(game.hideout_ui.engine_button);assert(game.state=="relic_spinner")
  var wallet:int=game.retention.progress.data.spin_wallet
  await click(game.retention.buttons[0]);assert(game.retention.spin_busy and game.retention.progress.data.free_spins==0 and game.retention.progress.data.spin_wallet==wallet)
  while game.retention.spin_busy:await process_frame
  await click(game.retention.buttons[1]);assert(game.state=="hideout" and game.attack_sequence==attacks)
  game.free();await process_frame
 print("EXPORTED MOUSE ROUTE PASS: cart Shop, item inspection, actual earned Spinner reward and Hub return at desktop resolution; no combat leaks");quit()
