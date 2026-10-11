extends SceneTree
const Tx=preload("res://economy_transaction.gd")
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 call_deferred("review")
func review() -> void:
 var cut:int=int(OS.get_environment("LOOTLINGS_CUT"))
 if OS.get_environment("LOOTLINGS_RESTART_PHASE")=="write":
  var game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
  game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
  game.gold=1000+cut;game.inventory.scrap=200+cut
  assert(Tx.commit(game,cut)==ERR_BUSY)
  var marker=FileAccess.open(OS.get_environment("LOOTLINGS_READY"),FileAccess.WRITE)
  marker.store_string("ready");marker.close()
  # Parent forcibly terminates this disposable process at a persisted journal boundary.
  await create_timer(90).timeout;push_error("Process cut was not delivered");quit(1)
 else:
  assert(Tx.recover()==OK and Tx.recover()==OK)
  var progress:Dictionary=preload("res://meta_store.gd").load_progress("user://lootlings_save.cfg")
  var inv=preload("res://inventory_system.gd").new();inv.load("user://lootlings_inventory.cfg")
  assert(progress.gold==1000+cut and inv.scrap==200+cut and not FileAccess.file_exists(Tx.PATH))
  print("ACTUAL PROCESS CUT RECOVERY PASS boundary ",cut);quit()
