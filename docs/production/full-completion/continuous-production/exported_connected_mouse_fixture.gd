extends SceneTree
var game
func _initialize() -> void:
 assert(OS.get_environment("LOOTLINGS_QA")=="1" and ".godot_test_data" in OS.get_user_data_dir())
 create_timer(35).timeout.connect(func():push_error("Connected mouse timeout");quit(1));call_deferred("review")
func click(b:Control) -> void:
 root.grab_focus();await create_timer(.35).timeout
 var p:Vector2=root.get_screen_transform()*b.get_global_rect().get_center()-Vector2(root.position)
 var move:=InputEventMouseMotion.new();move.position=p;Input.parse_input_event(move);Input.flush_buffered_events();await process_frame
 for down in [true,false]:
  var e:=InputEventMouseButton.new();e.position=p;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;Input.parse_input_event(e);Input.flush_buffered_events();await create_timer(.07).timeout
func review() -> void:
 root.size=Vector2i(1920,1080);game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
 game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false;game.set_process(false);game.show_hideout();await create_timer(1.3).timeout
 var h=game.hideout_ui
 h.request_dialogue("tapped","Salvager");await click(h.hub_navigation.world_buttons.GateEntrance);assert(h.current_screen=="home" and h.speech_panel.visible)
 await click(h.speech_role);assert(h.current_screen=="shop" and not h.get_node("DialogueVeil").visible)
 h.show_campaign();await process_frame;await click(h.campaign_list.get_child(1));assert(h.region_sheet.visible and h.region_depart.disabled)
 var selected:String=h.selected_region_id;await click(h.campaign_list.get_child(0));assert(h.selected_region_id==selected)
 game.navigate_back();assert(not h.region_sheet.visible and not h.campaign_content.get_node("RegionVeil").visible)
 await click(h.campaign_list.get_child(0));assert(h.region_sheet.visible and not h.region_depart.disabled)
 print("CONNECTED MOUSE PASS: NPC dialogue blocks world clicks, correct Shop return, region detail blocks underlying list, Back clears veil, available region remains selectable");quit()
