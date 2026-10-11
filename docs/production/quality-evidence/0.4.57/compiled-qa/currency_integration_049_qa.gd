extends SceneTree
const Meta=preload("res://meta_store.gd")
func _initialize() -> void:
 if not preload("C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-fixtures-057/test_safety.gd").require_isolated(self):return
 create_timer(25).timeout.connect(func():push_error("Currency integration timeout");quit(1))
 call_deferred("review")
func review() -> void:
 var path:="user://lootlings_save.cfg";var c:=ConfigFile.new()
 c.set_value("progress","version",3);c.set_value("progress","gold",1460);c.set_value("progress","shards",82);c.set_value("progress","power",33);c.set_value("progress","gold_upgrades",{"bedroll":5,"pouch":3,"whetstone":4});assert(c.save(path)==OK)
 var game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false)
 assert(game.gold==2735 and game.meta_shards==82 and game.meta_power==33 and game.gold_upgrades.bedroll==5 and game.gold_upgrades.pouch==0 and game.gold_upgrades.whetstone==4 and game.gold_upgrades.wardweave==0)
 game.save_meta();assert(c.load(path)==OK and c.get_value("progress","version")==4 and c.get_value("progress","lootcoins")==2735 and c.get_value("progress","loot_diamonds")==82)
 for i in range(10):game.load_meta();game.save_meta();assert(game.gold==2735 and game.meta_shards==82)
 game.show_hideout();game.gold=3000;game.inventory.scrap=3000;assert(game.save_hideout_economy())
 var before:Dictionary=Meta.load_progress(path);var price:int=game.hideout_shop.stock[0].price;game.buy_hideout_offer(0)
 var after:Dictionary=Meta.load_progress(path);assert(after.gold==before.gold-price and after.shards==before.shards)
 assert(c.load(path)==OK and c.get_value("progress","lootcoins")==game.gold)
 game.load_meta();assert(game.gold==3000-price and game.meta_power==33)
 assert(c.load(path+".bak")==OK and c.has_section_key("progress","lootcoins"))
 print("CURRENCY INTEGRATION 049 PASS: legacy wallet preserved plus exact 1275 retired-pouch refund, successful v4 save, ten restarts without duplicate balances, existing atomic purchase journal retains canonical fields and ranks; isolated saves only")
 game.free();quit()
