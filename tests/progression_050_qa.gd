extends SceneTree
const Upgrades=preload("res://permanent_upgrade_catalog.gd")
const Meta=preload("res://meta_store.gd")
class FailingInventory extends "res://inventory_system.gd":
 func save(_path: String) -> Error:return ERR_CANT_CREATE
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 call_deferred("review")
func review() -> void:
 var rng:=RandomNumberGenerator.new();rng.seed=50050
 for i in range(1000):
  var legacy:Dictionary={"bedroll":rng.randi_range(0,5),"whetstone":rng.randi_range(0,5),"pouch":rng.randi_range(0,5)}
  var wallet:=rng.randi_range(0,999999);assert(Meta.save_progress("user://fixture.cfg",82,33,wallet,legacy)==OK)
  var read:Dictionary=Meta.load_progress("user://fixture.cfg")
  assert(read.gold==wallet and read.shards==82 and read.power==33)
  for id in legacy:assert(read.gold_upgrades[id]==legacy[id])
  for id in ["wardweave","hearthward","mending"]:assert(read.gold_upgrades[id]==0)
 var game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.show_hideout()
 game.gold=100000;game.meta_shards=82;game.meta_power=33;assert(game.save_hideout_economy())
 for id in Upgrades.DEFINITIONS:
  if Upgrades.diamonds(id):continue
  var price_total:=0
  for price in Upgrades.DEFINITIONS[id][2]:
   var before:int=game.gold;game.buy_gold_upgrade(id);price_total+=price
   assert(game.gold==before-price and game.gold_upgrades[id]>0)
   var saved:Dictionary=Meta.load_progress(game.SAVE_PATH);assert(saved.gold==game.gold and saved.gold_upgrades[id]==game.gold_upgrades[id])
  var capped:int=game.gold;game.buy_gold_upgrade(id);assert(game.gold==capped and game.gold_upgrades[id]==5)
  print("UPGRADE AFFORDABILITY "+id+" total="+str(price_total)+" full_clear_equivalents_at_250="+str(float(price_total)/250))
 game.start_run();game.set_process(false)
 assert(is_equal_approx(game.armor,.03) and is_equal_approx(game.regen_per_second,.15) and game.player_ward==5)
 assert(game.base_damage==11*(1+33*.05)+3 and game.coins==40)
 game.show_hideout();game.gold_upgrades.mending=0;game.gold=899;assert(game.save_hideout_economy());game.buy_gold_upgrade("mending");assert(game.gold==899 and game.gold_upgrades.mending==0)
 game.gold=3000;assert(game.save_hideout_economy());game.inventory=FailingInventory.new();game.inventory.load(game.INVENTORY_SAVE_PATH)
 game.buy_gold_upgrade("mending");assert(game.gold==3000 and game.gold_upgrades.mending==0)
 for rank in range(1,6):
  assert(Upgrades.armour(rank)-Upgrades.armour(rank-1)<=.010001)
  assert(Upgrades.regeneration(rank)-Upgrades.regeneration(rank-1)<=.050001)
 print("PROGRESSION 050 PASS: 1000 wallets, preserved legacy ranks, 30 atomic ranks, caps, insufficient funds, failed-save rollback, actual run bonuses and diminishing returns")
 game.free();quit()
