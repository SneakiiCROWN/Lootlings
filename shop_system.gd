extends RefCounted

const ItemCatalog = preload("res://item_catalog.gd")

var stock: Array = []
var rerolls := 0
var stock_style := "Roadside goods"
var discount := 1.0
var purchase_taken := false
var preferred_family := ""

func begin_visit(loot_system, wave: int, family: String = "") -> void:
	purchase_taken = false
	rerolls = 0
	preferred_family = family
	generate_stock(loot_system, wave, family)

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
	# One purchase per stop; rarity and reroll costs create alternatives.
	return [58, 108, 185, 320][ItemCatalog.rarity_rank(item.get("rarity", "COMMON"))] + wave * 6

func reroll_cost(wave: int) -> int:
	return 18 + wave * 3 + rerolls * 18

func reroll(loot_system, wave: int) -> void:
	if purchase_taken: return
	rerolls += 1
	generate_stock(loot_system, wave, preferred_family)

func take(index: int) -> Dictionary:
	if purchase_taken or index < 0 or index >= stock.size():
		return {}
	var item: Dictionary = stock[index]
	purchase_taken = true
	stock.remove_at(index)
	return item
