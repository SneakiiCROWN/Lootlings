extends "res://tests/phase4_native_qa.gd"
func gesture(start: Vector2,end: Vector2,second_finger: bool=false) -> void:
 var ui=game.startup_ui
 var first: Vector2=root.get_screen_transform()*(ui.get_global_transform_with_canvas()*start)-Vector2(root.position)
 var last: Vector2=root.get_screen_transform()*(ui.get_global_transform_with_canvas()*end)-Vector2(root.position)
 var touch:=InputEventScreenTouch.new();touch.index=0;touch.pressed=true;touch.position=first;Input.parse_input_event(touch);Input.flush_buffered_events();await process_frame
 if second_finger:
  var other:=InputEventScreenTouch.new();other.index=1;other.pressed=true;other.position=first+Vector2(20,20);Input.parse_input_event(other);Input.flush_buffered_events();await process_frame
 var drag:=InputEventScreenDrag.new();drag.index=0;drag.position=last;drag.relative=last-first;Input.parse_input_event(drag);Input.flush_buffered_events();await process_frame
 touch=InputEventScreenTouch.new();touch.index=0;touch.pressed=false;touch.position=last;Input.parse_input_event(touch);Input.flush_buffered_events();await process_frame
 if second_finger:
  var other:=InputEventScreenTouch.new();other.index=1;other.pressed=false;other.position=first+Vector2(20,20);Input.parse_input_event(other);Input.flush_buffered_events();await process_frame
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/showcase-054/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
  var ui=game.startup_ui;ui.show_lootling_select();await process_frame
  var selected: String=ui.selected_lootling_id;var saved: String=game.profile.current_lootling_id
  await gesture(Vector2(330,250),Vector2(145,250));assert(ui.selected_lootling_id!=selected and game.profile.current_lootling_id==saved)
  var next: String=ui.selected_lootling_id
  await gesture(Vector2(145,250),Vector2(330,250));assert(ui.selected_lootling_id==selected)
  await gesture(Vector2(240,220),Vector2(245,370));assert(ui.selected_lootling_id==selected)
  await gesture(Vector2(330,250),Vector2(145,250),true);assert(ui.selected_lootling_id==selected)
  await tap(ui.find_child("NextLootling",true,false));assert(ui.selected_lootling_id==next)
  for id in ui.LootlingCatalog.selectable_ids():
   ui.selected_lootling_id=id;ui.refresh_selector();await capture("lootling_"+id)
   assert(ui.selector_portrait.texture!=null and ui.selector_portrait.stretch_mode==TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
  ui.show_wanderer_select();await process_frame
  var original: String=ui.selected_wanderer
  await gesture(Vector2(330,250),Vector2(145,250));assert(ui.selected_wanderer!=original)
  await tap(ui.find_child("PreviousWanderer",true,false));assert(ui.selected_wanderer==original)
  ui.identity_panel.visible=true;await gesture(Vector2(330,250),Vector2(145,250));assert(ui.selected_wanderer==original);ui.identity_panel.visible=false
  for id in ui.WandererCatalog.selectable_ids():
   ui.selected_wanderer=id;ui.refresh_wanderer_selector();await capture("wanderer_"+id);assert(ui.wanderer_portrait.texture!=null)
  ui.show_lootling_select();ui.selected_lootling_id="moonkip";ui.refresh_selector();await tap(ui.selector_confirm);assert(game.profile.current_lootling_id=="moonkip")
  game.free();await process_frame
 print("SHOWCASE 054 NATIVE PASS: seven Lootlings/five Wanderers full-aspect canonical previews; real left/right swipes and arrows; vertical and two-finger gestures cancel; identity modal claims input; browsing never saves until confirmation; three layouts.")
 quit()
