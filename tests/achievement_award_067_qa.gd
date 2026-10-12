extends SceneTree
const Manager=preload("res://achievement_manager.gd")
const Scope=preload("res://save_scope.gd")
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 call_deferred("review")
func review() -> void:
 var rows:Array=[]
 for stage in [1,2]:
  var path:="user://award-stage-%d.cfg" % stage
  var manager=Manager.new(path);manager.qa_stop_stage=stage
  assert(not manager.add_progress("hoard_dragon") and not manager.is_unlocked("hoard_dragon"))
  assert(FileAccess.file_exists(path+".pending"))
  var recovered=Manager.new(path);assert(recovered.is_unlocked("hoard_dragon") and recovered.progress.hoard_dragon==1)
  var timestamp:int=recovered.unlocked.hoard_dragon
  assert(not recovered.add_progress("hoard_dragon") and recovered.unlocked.hoard_dragon==timestamp)
  assert(not FileAccess.file_exists(path+".pending"))
  rows.append({"interruption_stage":stage,"journal_recovered":true,"duplicate_unlock":false})
 var manager=Manager.new("user://award-refused.cfg");Scope.transitioning=true
 assert(not manager.add_progress("hoard_dragon") and not manager.is_unlocked("hoard_dragon"))
 assert(manager.last_save_error==ERR_BUSY and not manager.pending_snapshot.is_empty())
 Scope.transitioning=false;assert(manager.retry_pending()==["hoard_dragon"] and manager.retry_pending().is_empty())
 assert(not manager.unlock("not_a_real_achievement"))
 var normal:=FileAccess.get_file_as_bytes("user://award-refused.cfg")
 Scope.active=true;var owner=Manager.new("user://award-refused.cfg");assert(not owner.is_unlocked("hoard_dragon"));assert(owner.unlock("hoard_dragon"));Scope.active=false
 assert(FileAccess.get_file_as_bytes("user://award-refused.cfg")==normal)
 var corrupt:=ConfigFile.new();corrupt.set_value("award","version",1);corrupt.set_value("award","snapshot",{"progress":{},"unlocked":{"hoard_dragon":1},"unique_keys":{}});corrupt.set_value("award","sha256","wrong");assert(corrupt.save("user://corrupt-award.cfg.pending")==OK)
 var blocked=Manager.new("user://corrupt-award.cfg");assert(blocked.pending_corrupt and not blocked.is_unlocked("hoard_dragon") and blocked.save_state()==ERR_FILE_CORRUPT)
 var f=FileAccess.open("res://.godot_test_data/achievement-award-067.json",FileAccess.WRITE);f.store_string(JSON.stringify(rows,"  "));f.close()
 print("ACHIEVEMENT AWARD 067 PASS: journal and committed-store interruptions replay once, failed writes do not unlock, live retry, unknown ID rejection, corrupt journal retained, owner/normal isolation. No claim for permanently unwritable storage.");quit()
