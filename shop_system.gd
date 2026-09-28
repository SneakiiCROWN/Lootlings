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
	return [18, 34, 62, 105][ItemCatalog.rarity_rank(item.get("rarity", "COMMON"))] + wave * 2

func reroll_cost(wave: int) -> int:
	return 12 + wave * 2 + rerolls * 7

func reroll(loot_system, wave: int) -> void:
	rerolls += 1
	generate_stock(loot_system, wave)

func take(index: int) -> Dictionary:
	if index < 0 or index >= stock.size():
		return {}
	var item: Dictionary = stock[index]
	stock.remove_at(index)
	return item
