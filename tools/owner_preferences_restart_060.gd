extends SceneTree
# Two fresh processes, same disposable owner store. Run via guarded delivery runner.
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 OS.set_environment("LOOTLINGS_OWNER_TEST","1")
 preload("res://save_scope.gd").active=true
 call_deferred("review")
func review() -> void:
 var game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
 game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
 var owner=game.owner_test_access
 assert(owner!=null and owner.enabled())
 if OS.get_environment("LOOTLINGS_RESTART_PHASE")=="write":
  owner.unlocked=true;owner.shortcut_hidden=true;owner.saved_position=true;owner.preferred=Vector2(.31,.57)
  assert(owner.save_preferences()==OK)
  print("OWNER PREFERENCES RESTART WRITE PASS")
 elif OS.get_environment("LOOTLINGS_RESTART_PHASE")=="read":
  assert(owner.unlocked and owner.shortcut_hidden and owner.saved_position and owner.preferred.is_equal_approx(Vector2(.31,.57)))
  owner.reset_position();assert(not owner.shortcut_hidden and not owner.saved_position)
  print("OWNER PREFERENCES FRESH PROCESS READ PASS")
 else:push_error("Restart stage not specified");quit(1);return
 quit()
