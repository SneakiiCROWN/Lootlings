extends SceneTree
const Meta=preload("res://meta_store.gd")
const Upgrades=preload("res://permanent_upgrade_catalog.gd")
const Progress=preload("res://endgame_progress.gd")
class FailingProvider:
 extends "res://local_save_provider.gd"
 func save_snapshot(_path: String,_section: String,_snapshot: Dictionary) -> Error:return ERR_CANT_CREATE
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 call_deferred("review")
func review() -> void:
 var expected: int=0
 for rank in range(6):
  if rank>0:expected+=int(Upgrades.DEFINITIONS.pouch[2][rank-1])
  var cfg:=ConfigFile.new();cfg.set_value("progress","gold",400);cfg.set_value("progress","shards",17);cfg.set_value("progress","power",9)
  cfg.set_value("progress","gold_upgrades",{"pouch":rank,"bedroll":2,"wardweave":3});cfg.set_value("owner","reference","untouched")
  var path: String="user://pouch_%d.cfg" % rank;assert(cfg.save(path)==OK)
  var result: Dictionary=Meta.load_progress(path)
  assert(result.gold==400+expected and result.shards==17 and result.power==9 and result.gold_upgrades.pouch==0 and result.gold_upgrades.bedroll==2 and result.gold_upgrades.wardweave==3)
  assert(Meta.load_progress(path).gold==result.gold)
  assert(Meta.save_progress(path,result.shards,result.power,result.gold,result.gold_upgrades,result.rift)==OK)
  assert(Meta.load_progress(path).gold==result.gold)
 var cfg:=ConfigFile.new();cfg.set_value("progress","gold",400);cfg.set_value("progress","gold_upgrades",{"pouch":3});assert(cfg.save("user://blocked.cfg")==OK)
 var before: String=FileAccess.get_sha256("user://blocked.cfg")
 preload("res://save_scope.gd").transitioning=true
 var blocked: Dictionary=Meta.load_progress("user://blocked.cfg")
 preload("res://save_scope.gd").transitioning=false
 assert(blocked.gold==400 and blocked.gold_upgrades.pouch==3 and FileAccess.get_sha256("user://blocked.cfg")==before)
 assert(Meta.load_progress("user://blocked.cfg").gold==1675)
 for spent in range(4):
  var old=Progress.new();old.data.merge({"free_spins":12,"free_run_grants":3,"earned_receipts":[]},false);old.data.spin_wallet=999999;old.data.spins=spent;old.data.session="old-session"
  assert(old.save()==OK)
  var migrated=Progress.new();migrated.load_progress()
  assert(migrated.data.spin_wallet==0 and migrated.data.legacy_spins==3-spent and migrated.data.free_spins==12 and migrated.data.wallet_retired)
  var again=Progress.new();again.load_progress();assert(again.data.legacy_spins==migrated.data.legacy_spins)
  migrated.settle(999999,100);assert(migrated.data.legacy_spins==3-spent and migrated.data.free_spins==12)
 var old=Progress.new();old.data.spin_wallet=400;old.data.spins=1;old.data.merge({"legacy_spins":0,"wallet_retired":false},false);old.provider=FailingProvider.new()
 var snapshot: Dictionary=old.data.duplicate(true);assert(old.migrate_legacy_wallet()!=OK and old.data==snapshot)
 old.provider=preload("res://local_save_provider.gd").new();assert(old.migrate_legacy_wallet()==OK and old.data.legacy_spins==1)
 var rng:=RandomNumberGenerator.new();rng.seed=54054;var rng_before: int=rng.state
 old.provider=FailingProvider.new();snapshot=old.data.duplicate(true);old.spin(rng,"relic_beast","greatsword");assert(old.data==snapshot and rng.state==rng_before)
 old.provider=preload("res://local_save_provider.gd").new();old.spin(rng,"relic_beast","greatsword");assert(old.data.legacy_spins==0 and old.data.pending.size()==1)
 old.spin(rng,"relic_beast","greatsword");assert(old.data.pending.size()==1)
 var game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.start_run();game.set_process(false)
 game.gold=321;game.coins=0;game.show_merchant();assert(game.shop.stock.size()==3 and game.shop.stock.all(func(item):return item.price==0))
 game.reroll_merchant();assert(game.shop.rerolls==1 and not game.shop.can_reroll());var stock: Array=game.shop.stock.duplicate(true);game.reroll_merchant();assert(game.shop.stock==stock)
 game.buy_merchant_item(0);assert(game.state=="item" and game.shop.purchase_taken and game.gold==321 and game.coins==0)
 var item: Dictionary=game.current_item.duplicate(true);game.buy_merchant_item(1);assert(game.current_item==item)
 game.accept_item_keep();game.leave_merchant();game.start_run();game.set_process(false);game.spawn_enemy();game.kill_enemy()
 assert(game.coins==0 and game.run_coins_earned==0 and game.run_coins_spent==0 and not game.reward_pickups.any(func(pickup):return pickup.kind=="coin"))
 assert(not game.format_result_summary(false,1,1,999,100,899,1,1,"None",2).contains("SCRIP"))
 for id in preload("res://expedition_event_catalog.gd").EVENTS:
  for wave in [1,15]:
   for choice in preload("res://expedition_event_catalog.gd").choices_for(id,wave):assert(not choice.has("scrip") and not str(choice.desc).contains("Scrip"))
 var gear: Dictionary=game.ItemCatalog.create_item("hoarders_locket","EPIC",42);gear.desc="More Run Scrip";var effects: Dictionary=gear.effects.duplicate(true)
 var clean: Dictionary=preload("res://inventory_system.gd").sanitize_saved_item(gear);assert(clean.effects==effects and clean.serial==42 and not clean.desc.contains("Scrip"))
 game.free();await process_frame
 print("SCRIP RETIREMENT 054 PASS: all six pouch ranks exact/idempotent refunds; failed migration unchanged; legacy spin entitlements preserved outside bank cap; spin failure RNG rollback; one free gear choice/one redraw; no normal-run wallet/pickups; event and item compatibility.")
 quit()
