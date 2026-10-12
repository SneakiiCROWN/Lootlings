extends SceneTree
const Manager=preload("res://achievement_manager.gd")
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 call_deferred("review")
func review() -> void:
 var manager=Manager.new("user://process-award.cfg")
 if OS.get_environment("LOOTLINGS_RESTART_PHASE")=="write":
  manager.qa_stop_stage=int(OS.get_environment("LOOTLINGS_CUT"))
  assert(not manager.add_progress("hoard_dragon") and not manager.is_unlocked("hoard_dragon"))
  var ready=FileAccess.open(OS.get_environment("LOOTLINGS_READY"),FileAccess.WRITE)
  ready.store_string("ready");ready.close()
  await create_timer(90).timeout;push_error("Process cut was not delivered");quit(1)
 else:
  assert(manager.is_unlocked("hoard_dragon") and manager.progress.hoard_dragon==1)
  var timestamp:int=manager.unlocked.hoard_dragon
  assert(not manager.add_progress("hoard_dragon") and manager.unlocked.hoard_dragon==timestamp)
  assert(not FileAccess.file_exists("user://process-award.cfg.pending"))
  var reload=Manager.new("user://process-award.cfg")
  assert(reload.unlocked.hoard_dragon==timestamp and reload.progress.hoard_dragon==1)
  print("ACHIEVEMENT ACTUAL PROCESS CUT PASS ",OS.get_environment("LOOTLINGS_CUT"));quit()
