extends SceneTree
const Scope=preload("res://save_scope.gd")
const Tx=preload("res://economy_transaction.gd")
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(25).timeout.connect(func():push_error("Save boundary timeout");quit(1));call_deferred("review")
func review() -> void:
 var g=load("res://main.tscn").instantiate();root.add_child(g);await process_frame;g.set_process(false)
 g.gold=321;g.meta_shards=17;g.save_meta();assert(FileAccess.file_exists(g.SAVE_PATH))
 var hash:String=FileAccess.get_sha256(g.SAVE_PATH)
 Scope.transitioning=true
 assert(g.debug_wallet_change(100,30).contains("unchanged") and g.gold==321 and g.meta_shards==17)
 Scope.transitioning=false;assert(FileAccess.get_sha256(g.SAVE_PATH)==hash)
 for cut in range(5):
  g.gold=1000+cut;g.inventory.scrap=200+cut
  var result:Error=Tx.commit(g,cut)
  assert(result==ERR_BUSY if cut<4 else result==OK)
  # Emulate a restart at each cross-store journal write boundary.
  assert(Tx.recover()==OK and Tx.recover()==OK)
  var progress:Dictionary=g.MetaStore.load_progress(g.SAVE_PATH)
  var restored=preload("res://inventory_system.gd").new();restored.load(g.INVENTORY_SAVE_PATH)
  assert(progress.gold==1000+cut and restored.scrap==200+cut)
  assert(not FileAccess.file_exists(Tx.PATH))
 g.free();await process_frame
 print("SAVE BOUNDARY 059 PASS: refused wallet write restores memory and unchanged file; four journal interruption boundaries and completed transaction recover consistent stores once. Simulated restart, not OS process-kill test.");quit()
