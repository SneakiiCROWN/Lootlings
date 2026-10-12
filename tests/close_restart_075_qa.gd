extends SceneTree
const Scope=preload("res://save_scope.gd")
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(35).timeout.connect(func():push_error("Close restart timeout");quit(1));call_deferred("review")
func review() -> void:
 Scope.active=OS.get_environment("LOOTLINGS_CLOSE_SANDBOX")=="1"
 var g=load("res://main.tscn").instantiate();root.add_child(g);await process_frame;g.set_process(false);g.app_lifecycle.platform_notifications_enabled=false
 if OS.get_environment("LOOTLINGS_CLOSE_RESTART")=="1":
  assert(g.gold==6789 and g.meta_shards==23 and g.inventory.scrap==451)
  print("CLOSE RESTART 075 PASS: fresh process recovered wallet/diamonds/scrap after actual close-request retry.");g.free();quit();return
 g.gold=3456;assert(g.app_lifecycle.persist()==OK);g.gold=6789;g.meta_shards=23;g.inventory.scrap=451
 Scope.transitioning=true;g.app_lifecycle.platform_notifications_enabled=true;g.app_lifecycle.notification(Node.NOTIFICATION_WM_CLOSE_REQUEST);g.app_lifecycle.platform_notifications_enabled=false
 assert(is_instance_valid(g.touch_ux.dialog) and g.gold==6789)
 Scope.transitioning=false
 # Simulate storage availability returning, then the player's retry action.
 g.touch_ux.close_dialog();print("CLOSE RETRY 075: actual app lifecycle will save and quit now.")
 assert(g.app_lifecycle.request_close()==OK)
