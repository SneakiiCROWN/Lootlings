extends RefCounted

const ItemCatalog = preload("res://item_catalog.gd")

var stock: Array = []
var rerolls := 0

func generate_stock(loot_system, wave: int) -> void:
	stock.clear()
	var minimum := "RARE" if wave >= 11 else "COMMON"
	# Three clear gear lanes plus the existing reroll utility make four shop actions.
	for slot in ["Weapon", "Armour", "Relic"]:
		var item: Dictionary = loot_system.generate_shop_item_for_slot(slot, minimum if slot == "Weapon" else "COMMON")
		item.price = price_for(item, wave)
		stock.append(item)

func price_for(item: Dictionary, wave: int) -> int:
	# Run Scrip is plentiful by design; meaningful rarity steps make each of the two stops a choice.
	return [58, 108, 185, 320][ItemCatalog.rarity_rank(item.get("rarity", "COMMON"))] + wave * 6

func reroll_cost(wave: int) -> int:
	return 55 + wave * 6 + rerolls * 25

func reroll(loot_system, wave: int) -> void:
	rerolls += 1
	generate_stock(loot_system, wave)

func take(index: int) -> Dictionary:
	if index < 0 or index >= stock.size():
		return {}
	var item: Dictionary = stock[index]
	stock.remove_at(index)
	return item
