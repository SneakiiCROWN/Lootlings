extends SceneTree
const Loot = preload("res://loot_system.gd")
const Items = preload("res://item_catalog.gd")
const Shop = preload("res://shop_system.gd")
const HomeShop = preload("res://hideout_shop_system.gd")
const Forge = preload("res://forge_system.gd")

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	var loot := Loot.new(998176)
	var rarities := {}; var ordinary := 0; var drought := 0; var longest := 0; var duplicate := 0; var last_id := ""
	for index in range(10000):
		var item := loot.roll_drop(false,false)
		if item.is_empty():
			drought += 1; longest = maxi(longest,drought)
		else:
			ordinary += 1; drought = 0
			rarities[item.rarity] = int(rarities.get(item.rarity,0)) + 1
			duplicate += 1 if item.id == last_id else 0
			last_id = item.id
	var budgets := []
	var shop := Shop.new()
	for wave in [6,11]:
		for sample in range(2000):
			loot.rng.seed = hash("shop:%d:%d" % [wave,sample])
			shop.begin_visit(loot,wave)
			var total := 0
			var cheapest := 999999
			for item in shop.stock:
				assert(item.price == 0) # Roadside gear is a bounded free choice, not a permanent-currency shop.
				total += item.price; cheapest = mini(cheapest,item.price)
			assert(shop.can_reroll());shop.reroll(loot,wave);assert(not shop.can_reroll());var offers: Array=shop.stock.duplicate(true);shop.reroll(loot,wave);assert(shop.stock==offers)
			assert(not shop.take(0).is_empty() and shop.take(0).is_empty())
			budgets.append({"wave":wave,"sample":sample,"cheapest":cheapest,"total":total,"reroll":shop.reroll_cost(wave)})
	# Persistent buy -> salvage never prints currency. Cache expected salvage
	# is an intentional sink, not a profitable repeated lottery.
	var cache_salvage := 0.0
	for index in range(4):
		var value := Items.scrap_value(Items.create_item("bonebow",Items.RARITIES[index]))
		assert(HomeShop.EQUIPMENT_PRICES[index] > value)
		cache_salvage += HomeShop.CACHE_RARITY_WEIGHTS[index] * value / 100.0
	assert(cache_salvage < HomeShop.CACHE_COST)
	print("PHASE3_ECONOMY " + JSON.stringify({"trials":10000,"regular_drops":ordinary,"regular_rarities":rarities,"longest_drought":longest,"successive_duplicate":duplicate,"persistent_prices":HomeShop.EQUIPMENT_PRICES,"cache_cost":HomeShop.CACHE_COST,"cache_expected_salvage":cache_salvage,"gold_cache":HomeShop.GOLD_CACHE_COST,"persistent_reroll":HomeShop.REROLL_COST,"expansions":HomeShop.EXPANSION_COSTS,"forge_gold":Forge.GOLD_COSTS,"forge_scrap":Forge.SCRAP_COSTS,"budgets":budgets}))
	print("PHASE3_ECONOMY COMPLETE: 10000 drops, 4000 merchant inventories, all persistent buy/salvage sinks")
	quit()
