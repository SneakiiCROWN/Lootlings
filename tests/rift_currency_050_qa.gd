extends SceneTree
const Rift=preload("res://rift_progress.gd")
const Meta=preload("res://meta_store.gd")
const Journal=preload("res://economy_transaction.gd")
class FailingInventory extends "res://inventory_system.gd":
 func save(_path: String) -> Error:return ERR_CANT_CREATE
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 call_deferred("review")
func review() -> void:
 var game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.show_hideout()
 assert(game.rift_progress.sigils==0 and game.rift_progress.entry.is_empty())
 game.gold=1000;game.meta_shards=82;game.meta_power=33;assert(game.save_hideout_economy())
 assert(not Rift.enter(game,"no-funds") and game.rift_progress.sigils==0)
 assert(Rift.settle(game,"empty",true,0,false).is_empty() and game.rift_progress.sigils==0)
 assert(Rift.settle(game,"short",true,7,false).is_empty() and game.rift_progress.sigils==0)
 Rift.settle(game,"ordinary-1",true,8,false);Rift.settle(game,"ordinary-1",true,8,false)
 assert(game.rift_progress.sigils==1 and game.gold==1000 and game.meta_shards==82)
 Rift.settle(game,"ordinary-2",true,14,false);assert(game.rift_progress.sigils==2)
 assert(Rift.enter(game,"entry-one") and game.rift_progress.sigils==0)
 assert(not Rift.enter(game,"double-entry"))
 Rift.settle(game,"elite-win",true,14,true);Rift.settle(game,"elite-win",true,14,true)
 assert(game.rift_progress.sigils==1 and game.gold==1250 and game.meta_shards==102 and game.rift_progress.entry.is_empty())
 Rift.settle(game,"ordinary-3",true,14,false);assert(Rift.enter(game,"entry-defeat"))
 Rift.settle(game,"elite-defeat",false,14,true);assert(game.rift_progress.sigils==0 and game.gold==1250 and game.meta_shards==102)
 game.rift_progress.sigils=2;assert(game.save_hideout_economy());var inventory=game.inventory
 game.inventory=FailingInventory.new();game.inventory.load(game.INVENTORY_SAVE_PATH)
 assert(not Rift.enter(game,"failed-entry"));assert(game.rift_progress.sigils==2 and game.rift_progress.entry.is_empty());game.inventory=inventory
 # Interrupt the existing four-store journal after each write; recovery repeats the snapshot.
 for stop in range(4):
  game.rift_progress.sigils=10+stop;game.rift_progress.entry="recover-"+str(stop)
  assert(Journal.commit(game,stop)==ERR_BUSY);assert(Journal.recover()==OK and Journal.recover()==OK)
  var saved:Dictionary=Meta.load_progress(game.SAVE_PATH);assert(saved.rift.sigils==10+stop and saved.rift.entry=="recover-"+str(stop))
 # Startup refunds an abandoned non-resumable entry exactly once.
 game.free();game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false)
 assert(game.rift_progress.sigils==15 and game.rift_progress.entry.is_empty());game.free()
 game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);assert(game.rift_progress.sigils==15)
 print("RIFT CURRENCY PASS: free regular routes, anti-empty farming, single earned receipts, atomic entry, exact bonus, defeat, failed-save rollback, four interrupted journal replays and one-time startup refund")
 game.free();quit()
