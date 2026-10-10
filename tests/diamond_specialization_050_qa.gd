extends SceneTree
const Upgrades=preload("res://permanent_upgrade_catalog.gd")
const Meta=preload("res://meta_store.gd")
class FailingInventory extends "res://inventory_system.gd":
 func save(_path: String) -> Error:return ERR_CANT_CREATE
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 call_deferred("review")
func review() -> void:
 var rng:=RandomNumberGenerator.new();rng.seed=50501
 for i in range(1000):
  var legacy:Dictionary={"bedroll":rng.randi_range(0,5),"whetstone":rng.randi_range(0,5),"pouch":rng.randi_range(0,5)}
  var diamonds:=rng.randi_range(0,999999);var coins:=rng.randi_range(0,999999999);var power:=rng.randi_range(0,100)
  assert(Meta.save_progress("user://fixture.cfg",diamonds,power,coins,legacy)==OK)
  var saved:Dictionary=Meta.load_progress("user://fixture.cfg")
  assert(saved.shards==diamonds and saved.gold==coins and saved.power==power)
  for id in legacy:assert(saved.gold_upgrades[id]==legacy[id])
  for id in ["heartprism","keenprism","aegisprism"]:assert(saved.gold_upgrades[id]==0)
 var game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.show_hideout()
 game.gold=12345;game.meta_shards=2000;game.meta_power=33;assert(game.save_hideout_economy())
 for id in ["heartprism","keenprism","aegisprism"]:
  for rank in range(3):
   var before:int=game.meta_shards;game.buy_gold_upgrade(id)
   assert(game.meta_shards==before-Upgrades.DEFINITIONS[id][2][rank] and game.gold==12345 and game.meta_power==33)
   assert(game.gold_upgrades[id]==rank+1)
   var saved:Dictionary=Meta.load_progress(game.SAVE_PATH);assert(saved.shards==game.meta_shards and saved.gold_upgrades[id]==rank+1)
  var before:int=game.meta_shards;game.buy_gold_upgrade(id);assert(game.meta_shards==before and game.gold_upgrades[id]==3)
 game.start_run();game.set_process(false)
 assert(is_equal_approx(game.crit_chance,.1025) and game.player_ward==4)
 assert(game.player_max_hp==100*(1+33*.05)+int(game.character_trait.hp)+12)
 assert(game.base_damage==11*(1+33*.05))
 game.show_hideout();game.gold_upgrades.heartprism=0;game.meta_shards=59;assert(game.save_hideout_economy());game.buy_gold_upgrade("heartprism");assert(game.meta_shards==59 and game.gold_upgrades.heartprism==0)
 game.meta_shards=100;assert(game.save_hideout_economy());game.inventory=FailingInventory.new();game.inventory.load(game.INVENTORY_SAVE_PATH)
 game.buy_gold_upgrade("heartprism");assert(game.meta_shards==100 and game.gold_upgrades.heartprism==0 and game.gold==12345)
 for rank in range(1,4):
  assert(Upgrades.heart(rank)-Upgrades.heart(rank-1)<=6)
  assert(Upgrades.keen(rank)-Upgrades.keen(rank-1)<=.010001)
  assert(Upgrades.aegis(rank)-Upgrades.aegis(rank-1)<=2)
 print("DIAMOND SPECIALIZATION PASS: 1000 lossless legacy wallets, nine atomic ranks, three caps, actual combat bonuses, insufficient funds and failed-save rollback; old Power retained")
 game.free();quit()
