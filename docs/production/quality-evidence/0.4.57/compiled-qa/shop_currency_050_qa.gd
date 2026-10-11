extends SceneTree
const HomeShop=preload("res://hideout_shop_system.gd")
func _initialize() -> void:
 if not preload("C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-fixtures-057/test_safety.gd").require_isolated(self):return
 call_deferred("review")
func review() -> void:
 # Existing v2 stock reprices deterministically without replacing items,
 # resetting sold slots, cycling stock, charging a wallet or repeating caches.
 for seed_value in range(1000):
  var shop=HomeShop.new(seed_value+1);shop.ensure_stock();var original:Array=shop.stock.duplicate(true)
  shop.stock[1]={};shop.cache_bought_this_cycle=true;shop.reveal_gold_cache();var pending:Dictionary=shop.pending_cache_item.duplicate(true)
  assert(shop.save("user://shop.cfg")==OK)
  var config:=ConfigFile.new();assert(config.load("user://shop.cfg")==OK)
  var stock:Array=config.get_value("shop","stock");stock[0].price=12;config.set_value("shop","stock",stock);assert(config.save("user://shop.cfg")==OK)
  var restored=HomeShop.new(222);restored.load("user://shop.cfg")
  assert(restored.cycle==shop.cycle and restored.stock[1].is_empty() and restored.cache_bought_this_cycle)
  assert(restored.stock[0].id==original[0].id and restored.stock[0].serial==original[0].serial)
  assert(restored.stock[0].price==restored.equipment_price(restored.stock[0]) and restored.pending_cache_item==pending and restored.pending_cache_currency=="gold")
 var game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.show_hideout();game.gold=2000;game.inventory.scrap=999;assert(game.save_hideout_economy())
 var prior:int=game.gold;game.buy_stash_expansion();assert(game.gold==prior-450 and game.inventory.scrap==999 and game.inventory.stash_capacity==18)
 prior=game.gold;game.buy_stash_expansion();assert(game.gold==prior-900 and game.inventory.stash_capacity==24)
 prior=game.gold;game.buy_stash_expansion();assert(game.gold==prior)
 game.reroll_hideout_shop();assert(game.gold==prior-60 and game.inventory.scrap==999);prior=game.gold;game.reroll_hideout_shop();assert(game.gold==prior)
 # A pre-paid legacy Scrap cache is still claimable without any new debit.
 game.hideout_shop.refresh_stock();game.hideout_shop.reveal_cache();var reserved:Dictionary=game.hideout_shop.pending_cache_item.duplicate(true);assert(game.save_hideout_economy())
 game.use_mystery_cache();assert(game.gold==prior and game.inventory.scrap==999 and game.inventory.stash.any(func(item):return item.serial==reserved.serial))
 var size:int=game.inventory.stash.size();game.use_mystery_cache();assert(game.inventory.stash.size()==size and game.gold==prior)
 game.load_meta();game.inventory.load(game.INVENTORY_SAVE_PATH);assert(game.gold==prior and game.inventory.stash_capacity==24)
 assert(HomeShop.EQUIPMENT_PRICES==[90,180,420,900] and HomeShop.EQUIPMENT_PRICES[0]<250 and HomeShop.EQUIPMENT_PRICES[2]>250)
 print("SHOP CURRENCY 050 PASS: 1000 existing-stock migrations, same identities/sold slots/caches, atomic expansions/reroll, caps, legacy paid-cache claim once, restart and spend/save price ladder")
 game.free();quit()
