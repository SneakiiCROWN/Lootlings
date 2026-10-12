extends "res://tests/phase4b_native_qa.gd"
const Scope=preload("res://save_scope.gd")
class ObservedLifecycle extends "res://app_lifecycle.gd":
 var quit_count:=0
 func quit_application() -> void: quit_count+=1

func review() -> void:
 var cases:=0
 for viewport in [Vector2i(360,640),Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/close075/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
  game.show_hideout();var lifecycle=ObservedLifecycle.new();game.add_child(lifecycle);lifecycle.configure(game);lifecycle.platform_notifications_enabled=false
  game.app_lifecycle=lifecycle
  for sandbox in [false,true]:
   Scope.active=sandbox;game.gold=4321;assert(lifecycle.persist()==OK)
   var path:String=Scope.path(game.SAVE_PATH);var hash:String=FileAccess.get_sha256(path);game.gold=9876
   # A real unwritable temporary target, confined to this isolated profile.
   var blocked:String=Scope.path(game.retention.progress.PATH)+".tmp"
   assert(not FileAccess.file_exists(blocked) and not DirAccess.dir_exists_absolute(blocked))
   assert(DirAccess.make_dir_absolute(blocked)==OK)
   assert(lifecycle.request_close()!=OK and lifecycle.quit_count==0)
   assert(FileAccess.get_sha256(path)==hash and game.gold==9876)
   assert(game.input_surface()==game.touch_ux.dialog)
   await capture("save_failure_owner" if sandbox else "save_failure_normal")
   var panel:Panel=game.touch_ux.confirm_button.get_parent();var back:Button;var unsaved:Button
   for child in panel.get_children():
    if child is Button and child.text=="KEEP OPEN":back=child
    if child is Button and child.text=="CLOSE WITHOUT SAVING…":unsaved=child
   assert(back!=null and unsaved!=null and not back.get_global_rect().intersects(unsaved.get_global_rect()))
   await tap(unsaved);assert(lifecycle.quit_count==0 and game.touch_ux.confirm_button.text=="CLOSE UNSAVED")
   game.navigate_back();assert(lifecycle.quit_count==0 and not is_instance_valid(game.touch_ux.dialog))
   # Retrying while storage is still blocked also keeps the app open.
   assert(lifecycle.request_close()!=OK);await create_timer(.2).timeout;await tap(game.touch_ux.confirm_button);assert(lifecycle.quit_count==0 and is_instance_valid(game.touch_ux.dialog))
   assert(DirAccess.remove_absolute(blocked)==OK)
   await create_timer(.2).timeout;await tap(game.touch_ux.confirm_button)
   assert(lifecycle.quit_count==1 and not is_instance_valid(game.touch_ux.dialog))
   assert(preload("res://meta_store.gd").load_progress(game.SAVE_PATH).gold==9876)
   lifecycle.confirm_unsaved_close();await create_timer(.2).timeout;await tap(game.touch_ux.confirm_button)
   assert(lifecycle.quit_count==2 and not is_instance_valid(game.touch_ux.dialog))
   lifecycle.quit_count=0;cases+=1
  Scope.active=false;Scope.transitioning=true;lifecycle.suspend();assert(paused and lifecycle.suspended)
  assert(lifecycle.request_close()==ERR_BUSY);await capture("save_failure_suspended")
  var paused_back:Button
  for child in game.touch_ux.confirm_button.get_parent().get_children():
   if child is Button and child.text=="KEEP OPEN":paused_back=child
  await tap(paused_back);assert(not is_instance_valid(game.touch_ux.dialog) and lifecycle.quit_count==0)
  lifecycle.restore_focus();Scope.transitioning=false;assert(not paused and not lifecycle.suspended)
  game.free();await process_frame
 print("CLOSE SAVE 075 NATIVE PASS:8 real write refusals/unchanged saved wallet, keep-open, explicit unsaved-close cancellation, failed retry and successful retry;4 layouts, normal/owner isolated profiles. Quit intercepted only for this UI fixture.")
 quit()
