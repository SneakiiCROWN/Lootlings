extends "res://tests/input_transition_049_native_qa.gd"
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.show_hideout();game.presentation_director.finish_travel();game.presentation_director.vignette.finish();game.hideout_ui.show_forge()
  game.touch_ux.request("First","Next modal",func():print("FIRST FIRED");game.touch_ux.request("Second","Fresh press only",func():actions+=100))
  await wait_real(300)
  var id:int=game.touch_ux.dialog.get_instance_id();var confirm=game.touch_ux.confirm_button
  var point:Vector2=confirm.get_global_rect().get_center()
  print("BEFORE ",id," confirm ",confirm," rect ",confirm.get_global_rect()," age ",Time.get_ticks_msec()-game.touch_ux.dialog_opened)
  await contact(point,true,1);await contact(point,true)
  print("OWNED ",game.touch_ux.owned_button," text ",game.touch_ux.owned_button.text if is_instance_valid(game.touch_ux.owned_button) else "none"," press ",game.touch_ux.press_token," surface ",game.touch_ux.current_surface_token())
  await contact(point,false)
  print("AFTER ",game.touch_ux.dialog.get_instance_id() if is_instance_valid(game.touch_ux.dialog) else 0," barrier ",game.touch_ux.release_barrier," contacts ",game.touch_ux.active_contacts)
  assert(is_instance_valid(game.touch_ux.dialog) and game.touch_ux.dialog.get_instance_id()!=id and game.touch_ux.release_barrier)
  await contact(point,false,1);await wait_real(250);await tap(game.touch_ux.confirm_button);assert(actions%100==0)
  game.free();await process_frame
 print("MODAL CHAIN NATIVE PASS");quit()
