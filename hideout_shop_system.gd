extends RefCounted

const ItemCatalog = preload("res://item_catalog.gd")

# Persistent-shop economy tuning lives here so it can change without touching combat drops.
const OFFER_SLOTS := ["Weapon", "Armour"]
const THIRD_OFFER_SLOTS := ["Relic", "Rune"]
const OFFER_RARITY_WEIGHTS := [72.0, 25.0, 3.0, 0.0]
const CACHE_RARITY_WEIGHTS := [82.0, 16.0, 2.0, 0.0]
const EQUIPMENT_PRICES := [90, 180, 420, 900]
const CACHE_COST := 20
const GOLD_CACHE_COST := 180
const REROLL_COST := 60
const EXPANSION_COSTS := {12:450, 18:900}

var stock: Array = []
var cycle := 0
var rerolled_this_cycle := false
var cache_bought_this_cycle := false
var gold_cache_bought_this_cycle := false
var pending_cache_currency := ""
var pending_cache_item: Dictionary = {}
var blocked_cache: Variant = null
var rng := RandomNumberGenerator.new()

func _init(seed_value: int = 0) -> void:
	if seed_value == 0:
		rng.randomize()
	else:
		rng.seed = seed_value

func ensure_stock() -> void:
	if cycle <= 0:
		refresh_stock()

func refresh_stock() -> void:
	cycle += 1
	rerolled_this_cycle = false
	cache_bought_this_cycle = false
	gold_cache_bought_this_cycle = false
	stock.clear()
	var slots := OFFER_SLOTS.duplicate()
	slots.append(THIRD_OFFER_SLOTS[(cycle - 1) % THIRD_OFFER_SLOTS.size()])
	for index in range(slots.size()):
		var item := generate_item_for_slot(slots[index], OFFER_RARITY_WEIGHTS, serial_for(index))
		item.price = equipment_price(item)
		stock.append(item)

func reroll() -> bool:
	if rerolled_this_cycle or not pending_cache_item.is_empty():
		return false
	rerolled_this_cycle = true
	stock.clear()
	var slots := OFFER_SLOTS.duplicate()
	slots.append(THIRD_OFFER_SLOTS[cycle % THIRD_OFFER_SLOTS.size()])
	for index in range(slots.size()):
		var item := generate_item_for_slot(slots[index], OFFER_RARITY_WEIGHTS, serial_for(index + 4))
		item.price = equipment_price(item)
		stock.append(item)
	return true

func take_offer(index: int) -> Dictionary:
	if index < 0 or index >= stock.size():
		return {}
	var item: Dictionary = stock[index]
	stock[index] = {}
	return item

func reveal_cache() -> Dictionary:
	if not pending_cache_item.is_empty():
		return pending_cache_item
	if cache_bought_this_cycle:
		return {}
	var pool := public_items()
	var source: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
	var rarity := weighted_rarity(CACHE_RARITY_WEIGHTS)
	pending_cache_item = ItemCatalog.create_item(source.id, rarity, serial_for(9))
	cache_bought_this_cycle = true
	pending_cache_currency = "scrap"
	return pending_cache_item

func reveal_gold_cache() -> Dictionary:
	if not pending_cache_item.is_empty() or gold_cache_bought_this_cycle:
		return {}
	var pool := public_items()
	var source: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
	var rarity := weighted_rarity(CACHE_RARITY_WEIGHTS)
	pending_cache_item = ItemCatalog.create_item(source.id, rarity, serial_for(10))
	gold_cache_bought_this_cycle = true
	pending_cache_currency = "gold"
	return pending_cache_item

func claim_cache() -> Dictionary:
	var item := pending_cache_item.duplicate(true)
	pending_cache_item.clear()
	pending_cache_currency = ""
	return item

func equipment_price(item: Dictionary) -> int:
	return EQUIPMENT_PRICES[ItemCatalog.rarity_rank(item.get("rarity", "COMMON"))]

func expansion_cost(capacity: int) -> int:
	return int(EXPANSION_COSTS.get(capacity, 0))

func save(path: String) -> Error:
	var config := ConfigFile.new()
	config.set_value("shop", "version", 2)
	config.set_value("shop", "cycle", maxi(0, cycle))
	config.set_value("shop", "rerolled", rerolled_this_cycle)
	config.set_value("shop", "cache_bought", cache_bought_this_cycle)
	config.set_value("shop", "gold_cache_bought", gold_cache_bought_this_cycle)
	config.set_value("shop", "pending_cache_currency", pending_cache_currency)
	config.set_value("shop", "stock", stock)
	config.set_value("shop", "pending_cache", pending_cache_item if blocked_cache==null else blocked_cache)
	return preload("res://safe_config.gd").save_config(config, path)

func load(path: String) -> void:
	var config := ConfigFile.new()
	if preload("res://safe_config.gd").load_config(config, path, "shop") != OK:
		ensure_stock()
		return
	cycle = clampi(preload("res://safe_config.gd").int_value(config.get_value("shop", "cycle", 0)),0,999999)
	rerolled_this_cycle = config.get_value("shop", "rerolled", false)==true
	cache_bought_this_cycle = config.get_value("shop", "cache_bought", false)==true
	gold_cache_bought_this_cycle = config.get_value("shop", "gold_cache_bought", false)==true
	pending_cache_currency = str(config.get_value("shop", "pending_cache_currency", "scrap" if config.get_value("shop", "cache_bought", false)==true else ""))
	stock = validated_items(config.get_value("shop", "stock", []), true)
	var raw_pending=config.get_value("shop", "pending_cache", {})
	var pending := validated_items([raw_pending], false)
	blocked_cache={"malformed_original":null} if raw_pending==null else raw_pending if pending.is_empty() and raw_pending!={} else null
	pending_cache_item = pending[0] if not pending.is_empty() else {}
	if pending_cache_item.is_empty():
		pending_cache_currency = ""
	ensure_stock()

func generate_item_for_slot(slot: String, weights: Array, serial: int) -> Dictionary:
	var pool: Array = []
	for source in public_items():
		if source.get("slot", "") == slot:
			pool.append(source)
	var source: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
	return ItemCatalog.create_item(source.id, weighted_rarity(weights), serial)

func public_items() -> Array:
	return ItemCatalog.ITEMS.filter(func(item): return not item.id in preload("res://phase3_item_catalog.gd").BOSS_ONLY)

func weighted_rarity(weights: Array) -> String:
	var total := 0.0
	for weight in weights:
		total += float(weight)
	var roll := rng.randf() * total
	for index in range(weights.size()):
		roll -= float(weights[index])
		if roll <= 0.0:
			return ItemCatalog.RARITIES[index]
	return "COMMON"

func validated_items(raw_items, include_price: bool) -> Array:
	var result: Array = []
	if not raw_items is Array:
		return result
	for raw_item in raw_items:
		if not raw_item is Dictionary or raw_item.is_empty():
			if include_price:
				result.append({})
			continue
		if not raw_item.get("id",null) is String or not raw_item.get("rarity","COMMON") is String:continue
		var definition := ItemCatalog.definition(raw_item.get("id", ""))
		var rarity: String = raw_item.get("rarity", "COMMON")
		if definition.is_empty() or rarity == "LEGENDARY" or not rarity in ItemCatalog.RARITIES:
			continue
		var item := ItemCatalog.create_item(definition.id, rarity, preload("res://safe_config.gd").int_value(raw_item.get("serial", 0)))
		if include_price:
			item.price = equipment_price(item)
		result.append(item)
		if include_price and result.size() >= 3:
			break
	while include_price and result.size() < 3:
		result.append({})
	return result

func serial_for(offset: int) -> int:
	return 100000 + cycle * 20 + offset

func requires_review() -> bool:
	return blocked_cache!=null
