extends SceneTree
class FailingInventory:
	extends "res://inventory_system.gd"
	func save(path: String) -> Error:
		if path.ends_with(".stage"):return ERR_CANT_CREATE
		return super.save(path)
func _initialize() -> void:
	if not preload("C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-fixtures-058/test_safety.gd").require_isolated(self):return
	call_deferred("review")
func review() -> void:
	var game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.show_hideout()
	game.inventory.scrap=2000;game.gold=2000;game.save_meta();assert(game.inventory.save(game.INVENTORY_SAVE_PATH)==OK)
	var offer: Dictionary=game.hideout_shop.stock[0].duplicate(true);var price: int=offer.price
	var count: int=game.inventory.stash.size();game.buy_hideout_offer(0)
	assert(game.inventory.scrap==2000 and game.gold==2000-price and game.inventory.stash.size()==count+1 and game.hideout_shop.stock[0].is_empty())
	game.buy_hideout_offer(0);assert(game.inventory.stash.size()==count+1)
	var inventory=preload("res://inventory_system.gd").new();inventory.load(game.INVENTORY_SAVE_PATH)
	var shop=preload("res://hideout_shop_system.gd").new();shop.load(game.HIDEOUT_SHOP_SAVE_PATH)
	assert(inventory.scrap==game.inventory.scrap and shop.stock[0].is_empty() and same_saved_value(inventory.stash,game.inventory.stash))
	var before: int=game.gold;game.use_gold_cache();assert(game.gold==before-game.hideout_shop.GOLD_CACHE_COST and not game.hideout_shop.pending_cache_item.is_empty())
	var reserved: Dictionary=game.hideout_shop.pending_cache_item.duplicate(true);shop.load(game.HIDEOUT_SHOP_SAVE_PATH);assert(shop.pending_cache_item==reserved)
	game.use_gold_cache();assert(game.gold==before-game.hideout_shop.GOLD_CACHE_COST and game.inventory.stash.any(func(item):return item.serial==reserved.serial))
	var meta: Dictionary=preload("res://meta_store.gd").load_progress(game.SAVE_PATH);assert(meta.gold==game.gold)
	var size: int=game.inventory.stash.size();game.use_gold_cache();assert(game.inventory.stash.size()==size and game.gold==meta.gold)
	game.contracts.counts.kill=12;var initial: int=game.gold;game.claim_contract(0);assert(game.gold==initial+10);game.claim_contract(0);assert(game.gold==initial+10)
	var restored=preload("res://contract_system.gd").new();restored.load_progress("user://contracts.cfg");assert(restored.offer(0).event=="boss" and restored.claim(0)==0)
	var old_gold: int=game.gold;var old_scrap: int=game.inventory.scrap;var old_stash: Array=game.inventory.stash.duplicate(true);var old_offer: Dictionary=game.hideout_shop.stock[1].duplicate(true)
	game.inventory=FailingInventory.new();game.inventory.load(game.INVENTORY_SAVE_PATH);game.buy_hideout_offer(1)
	assert(game.gold==old_gold and game.inventory.scrap==old_scrap and same_saved_value(game.inventory.stash,old_stash) and same_saved_value(game.hideout_shop.stock[1],old_offer))
	game.contracts.counts.boss=1;game.contracts.save("user://contracts.cfg");var old_contracts: Array=game.contracts.active.duplicate(true);game.claim_contract(0)
	assert(game.gold==old_gold and game.contracts.active==old_contracts and game.contracts.offer(0).progress==1)
	# A corrupted journal cannot redirect or partially apply writes.
	var journal:=ConfigFile.new();var writes: Dictionary={};var hashes: Dictionary={}
	for path in preload("res://economy_transaction.gd").STORES:
		writes[path]=FileAccess.get_file_as_string(path);hashes[path]=str(writes[path]).sha256_text()
	writes[game.SAVE_PATH]+="\n; corrupted snapshot";journal.set_value("transaction","version",1);journal.set_value("transaction","writes",writes);journal.set_value("transaction","sha256",hashes);assert(journal.save(preload("res://economy_transaction.gd").PATH)==OK)
	var source_hash: String=FileAccess.get_sha256(game.SAVE_PATH)
	assert(preload("res://economy_transaction.gd").recover()==ERR_FILE_CORRUPT and FileAccess.get_sha256(game.SAVE_PATH)==source_hash)
	assert(DirAccess.remove_absolute(preload("res://economy_transaction.gd").PATH)==OK)
	game.free();await process_frame;print("COMPLETION ECONOMY PASS: Lootcoin offers, unchanged cache/contract prices, no duplicates, same debit/delivery generation, corrupt journal fail-closed");quit()

func same_saved_value(actual: Variant, expected: Variant) -> bool:
	# ConfigFile writes decimal floats; a rare affix's binary roundoff must not
	# masquerade as a lost item. IDs, serials, counts and non-float fields stay exact.
	if actual is float and expected is float:return absf(actual-expected)<1e-12
	if actual is Dictionary and expected is Dictionary:
		if actual.size()!=expected.size():return false
		for key in expected:
			if not actual.has(key) or not same_saved_value(actual[key],expected[key]):return false
		return true
	if actual is Array and expected is Array:
		if actual.size()!=expected.size():return false
		for i in actual.size():
			if not same_saved_value(actual[i],expected[i]):return false
		return true
	return actual==expected
