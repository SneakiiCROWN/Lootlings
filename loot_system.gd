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
var regular_drought := 0
var recent_items: Array = []
var boss_pool: Array = []
var boss_seen: Array = []
var target_drought := 0

func reset_run(campaign: String) -> void:
	regular_drought = 0; recent_items.clear(); boss_seen.clear()
	target_drought = 0
	boss_pool = preload("res://phase3_item_catalog.gd").BOSS_POOLS.get(campaign,[]).duplicate()

func _init(seed_value: int = 0) -> void:
	if seed_value == 0:
		rng.randomize()
	else:
		rng.seed = seed_value

func roll_drop(is_miniboss: bool, is_boss: bool) -> Dictionary:
	if not is_miniboss and not is_boss:
		regular_drought += 1
		if rng.randf() > NORMAL_DROP_CHANCE and regular_drought < 18: return {}
		regular_drought = 0
	var weights := BOSS_RARITY_WEIGHTS if is_boss else MINIBOSS_RARITY_WEIGHTS if is_miniboss else NORMAL_RARITY_WEIGHTS
	var rarity := weighted_rarity(weights)
	var pool := eligible_items(is_boss)
	var source: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
	if is_boss and not boss_pool.is_empty() and rng.randf() < .45:
		source = ItemCatalog.definition(str(boss_pool[rng.randi_range(0,boss_pool.size()-1)]))
	# Farm identity covers every region; named loot changes the prior loot stream.
	if not is_boss and not region_pool.is_empty() and (rng.randf() < 0.45 or target_drought >= 3):
		source = ItemCatalog.definition(str(region_pool[rng.randi_range(0, region_pool.size() - 1)]))
		target_drought = 0
	elif not is_boss: target_drought += 1
	# Same-rarity alternatives still feel different. Boss choices cannot repeat
	# a base; ordinary drops avoid the immediately previous two identities.
	var exclusions: Array = boss_seen if is_boss else recent_items
	if source.id in exclusions:
		var target_candidates: Array = region_pool.filter(func(id): return not id in exclusions)
		if not is_boss and target_candidates.is_empty() and not region_pool.is_empty():
			target_candidates = region_pool.filter(func(id): return recent_items.is_empty() or id != recent_items.back())
		var candidates: Array = pool.filter(func(item): return not item.id in exclusions)
		if not is_boss and not target_candidates.is_empty(): candidates = target_candidates.map(func(id): return ItemCatalog.definition(str(id)))
		source = candidates[rng.randi_range(0,candidates.size()-1)]
	if is_boss: boss_seen.append(source.id)
	else:
		recent_items.append(source.id)
		if recent_items.size() > 2: recent_items.pop_front()
	var result := ItemCatalog.create_item(source.id, rarity, serial)
	result = AffixCatalog.apply(result, AffixCatalog.roll_for_item(result, rng))
	serial += 1
	return result

func generate_shop_item(minimum_rarity: String = "COMMON") -> Dictionary:
	var minimum_rank := ItemCatalog.rarity_rank(minimum_rarity)
	var rarity := weighted_rarity([58.0, 31.0, 9.0, 2.0])
	if ItemCatalog.rarity_rank(rarity) < minimum_rank:
		rarity = minimum_rarity
	var pool := eligible_items(false)
	var source: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
	var result := ItemCatalog.create_item(source.id, rarity, serial)
	result = AffixCatalog.apply(result, AffixCatalog.roll_for_item(result, rng))
	serial += 1
	return result

func generate_shop_item_for_slot(slot: String, minimum_rarity: String = "COMMON", preferred_family: String = "") -> Dictionary:
	var pool: Array = []
	for source in eligible_items(false):
		if source.get("slot", "") == slot:
			pool.append(source)
	if pool.is_empty():
		return generate_shop_item(minimum_rarity)
	if not preferred_family.is_empty() and rng.randf() < .35:
		var matching := pool.filter(func(item): return item.get("family","") == preferred_family)
		if not matching.is_empty(): pool = matching
	var rarity := weighted_rarity([58.0, 31.0, 9.0, 2.0])
	if ItemCatalog.rarity_rank(rarity) < ItemCatalog.rarity_rank(minimum_rarity):
		rarity = minimum_rarity
	var source: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
	var result := ItemCatalog.create_item(source.id, rarity, serial)
	result = AffixCatalog.apply(result, AffixCatalog.roll_for_item(result, rng))
	serial += 1
	return result

func eligible_items(boss: bool) -> Array:
	# Named boss finds cannot leak through merchants, event caches or ordinary
	# drops. Random signature affixes still permit other routes to the build.
	var exclusive: Array = preload("res://phase3_item_catalog.gd").BOSS_ONLY + preload("res://phase4b_catalog.gd").EXCLUSIVE
	return ItemCatalog.ITEMS.filter(func(item): return not item.id in preload("res://mythical_collection.gd").IDS and (not item.id in exclusive or (boss and item.id in boss_pool)))

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
