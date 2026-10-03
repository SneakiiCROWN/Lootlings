extends RefCounted

const ItemCatalog = preload("res://item_catalog.gd")

var stock: Array = []
var rerolls := 0
var stock_style := "Roadside goods"
var discount := 1.0

func generate_stock(loot_system, wave: int, preferred_family: String = "") -> void:
	stock.clear()
	var style_roll: float = loot_system.rng.randf()
	discount = .85 if style_roll < .20 else 1.0
	stock_style = "PATCHED PRICES • 15% OFF" if style_roll < .20 else "RELIC FINDER • RARE+ WEAPON" if style_roll > .85 else "ROADSIDE GOODS"
	if style_roll >= .65 and style_roll <= .85: stock_style = "RUNE COLLECTOR"
	var minimum := "RARE" if wave >= 11 else "COMMON"
	if style_roll > .85: minimum = "RARE"
	# Three clear gear lanes plus the existing reroll utility make four shop actions.
	for slot in ["Weapon", "Armour", "Rune" if stock_style == "RUNE COLLECTOR" else "Relic"]:
		var item: Dictionary = loot_system.generate_shop_item_for_slot(slot, minimum if slot == "Weapon" else "COMMON",preferred_family if slot == "Weapon" else "")
		item.price = maxi(1,roundi(price_for(item, wave)*discount))
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
