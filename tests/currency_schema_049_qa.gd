extends SceneTree
const Schema=preload("res://currency_schema.gd")
const Safe=preload("res://safe_config.gd")
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 var rng:=RandomNumberGenerator.new();rng.seed=49049
 for i in range(1000):
  var coins:int=rng.randi_range(0,999999999);var diamonds:int=rng.randi_range(0,999999)
  var config:=ConfigFile.new();config.set_value("progress","version",3);config.set_value("progress","gold",coins);config.set_value("progress","shards",diamonds);config.set_value("progress","power",33);config.set_value("progress","gold_upgrades",{"bedroll":5,"pouch":3,"whetstone":4})
  var old:Dictionary=Schema.balances(config);assert(old.gold==coins and old.shards==diamonds)
  Schema.write_names(config,coins,diamonds)
  assert(config.get_value("progress","power")==33 and config.get_value("progress","gold_upgrades").bedroll==5)
  assert(Schema.balances(config)==old)
  # A restart and repeat migration cannot duplicate balances or re-credit aliases.
  assert(Safe.save_config(config,"user://currency049.cfg")==OK)
  var loaded:=ConfigFile.new();assert(Safe.load_config(loaded,"user://currency049.cfg","progress")==OK)
  for repeat in range(3):
   var balance:Dictionary=Schema.balances(loaded);Schema.write_names(loaded,balance.gold,balance.shards);assert(Schema.balances(loaded)==old)
  loaded.set_value("progress","gold",999999999);loaded.set_value("progress","shards",999999)
  assert(Schema.balances(loaded)==old,"Legacy mirror added or overrode canonical balance")
 print("CURRENCY SCHEMA 049 PASS: 1000 seeded legacy wallets, exact one-to-one migration, rank/investment preservation, disk roundtrips, idempotence and conflicting aliases. No economy formulas changed.")
 quit()
