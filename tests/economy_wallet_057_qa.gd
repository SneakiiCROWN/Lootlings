extends SceneTree
const Scope=preload("res://save_scope.gd")
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(25).timeout.connect(func():push_error("Wallet timeout");quit(1));call_deferred("review")
func review() -> void:
 var g=load("res://main.tscn").instantiate();root.add_child(g);await process_frame;g.set_process(false)
 g.gold=321;g.meta_shards=17;g.save_meta();var normal:PackedByteArray=FileAccess.get_file_as_bytes(g.SAVE_PATH)
 g.debug_panel.run_action("gold",500);assert(g.gold==321)
 Scope.active=true;g.gold=100;g.meta_shards=20
 assert(g.debug_action("gold",500).contains("saved") and g.gold==600)
 assert(g.debug_action("shards",-50).contains("saved") and g.meta_shards==0)
 g.debug_action("gold",-900);assert(g.gold==0)
 g.debug_action("gold",2000000000);g.debug_action("shards",2000000000)
 assert(g.gold==999999999 and g.meta_shards==999999)
 var loaded:Dictionary=g.MetaStore.load_progress(g.SAVE_PATH);assert(loaded.gold==g.gold and loaded.shards==g.meta_shards)
 g.debug_panel.run_action("wallet_reset",null);assert(is_instance_valid(g.touch_ux.dialog) and g.gold==999999999)
 g.touch_ux.dialog.queue_free();await process_frame
 g.debug_action("wallet_reset",null);assert(g.gold==0 and g.meta_shards==0)
 assert(FileAccess.get_file_as_bytes("user://lootlings_save.cfg")==normal)
 Scope.active=false;g.free();print("ECONOMY WALLET 057 PASS: normal-profile UI guard, saved adds/removes, both caps, reset confirmation and untouched normal save.");quit()
