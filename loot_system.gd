extends RefCounted

const ItemCatalog = preload("res://item_catalog.gd")
const AffixCatalog = preload("res://affix_catalog.gd")

const NORMAL_DROP_CHANCE := 0.07
const NORMAL_RARITY_WEIGHTS := [70.0, 24.0, 5.0, 1.0]
const MINIBOSS_RARITY_WEIGHTS := [0.0, 74.0, 23.0, 3.0]
const BOSS_RARITY_WEIGHTS := [0.0, 0.0, 88.0, 12.0]

var rng := RandomNumberGenerator.new()
var serial := 1
var region_pool: Array = []

func _init(seed_value: int = 0) -> void:
	if seed_value == 0:
		rng.randomize()
	else:
		rng.seed = seed_value

func roll_drop(is_miniboss: bool, is_boss: bool) -> Dictionary:
	if not is_miniboss and not is_boss and rng.randf() > NORMAL_DROP_CHANCE:
		return {}
	var weights := BOSS_RARITY_WEIGHTS if is_boss else MINIBOSS_RARITY_WEIGHTS if is_miniboss else NORMAL_RARITY_WEIGHTS
	var rarity := weighted_rarity(weights)
	var source: Dictionary = ItemCatalog.ITEMS[rng.randi_range(0, ItemCatalog.ITEMS.size() - 1)]
	# New-region identity only; Act I consumes exactly its original RNG sequence.
	if not region_pool.is_empty() and rng.randf() < 0.45:
		source = ItemCatalog.definition(str(region_pool[rng.randi_range(0, region_pool.size() - 1)]))
	var result := ItemCatalog.create_item(source.id, rarity, serial)
	result = AffixCatalog.apply(result, AffixCatalog.roll_for_item(result, rng))
	serial += 1
	return result

func generate_shop_item(minimum_rarity: String = "COMMON") -> Dictionary:
	var minimum_rank := ItemCatalog.rarity_rank(minimum_rarity)
	var rarity := weighted_rarity([58.0, 31.0, 9.0, 2.0])
	if ItemCatalog.rarity_rank(rarity) < minimum_rank:
		rarity = minimum_rarity
	var source: Dictionary = ItemCatalog.ITEMS[rng.randi_range(0, ItemCatalog.ITEMS.size() - 1)]
	var result := ItemCatalog.create_item(source.id, rarity, serial)
	result = AffixCatalog.apply(result, AffixCatalog.roll_for_item(result, rng))
	serial += 1
	return result

func generate_shop_item_for_slot(slot: String, minimum_rarity: String = "COMMON") -> Dictionary:
	var pool: Array = []
	for source in ItemCatalog.ITEMS:
		if source.get("slot", "") == slot:
			pool.append(source)
	if pool.is_empty():
		return generate_shop_item(minimum_rarity)
	var rarity := weighted_rarity([58.0, 31.0, 9.0, 2.0])
	if ItemCatalog.rarity_rank(rarity) < ItemCatalog.rarity_rank(minimum_rarity):
		rarity = minimum_rarity
	var source: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
	var result := ItemCatalog.create_item(source.id, rarity, serial)
	result = AffixCatalog.apply(result, AffixCatalog.roll_for_item(result, rng))
	serial += 1
	return result

func weighted_rarity(weights: Array) -> String:
	var total := 0.0
	for weight in weights:
		total += float(weight)
	var roll := rng.randf() * total
	for i in range(weights.size()):
		roll -= float(weights[i])
		if roll <= 0.0:
			return ItemCatalog.RARITIES[i]
	return ItemCatalog.RARITIES.back()
