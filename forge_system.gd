extends RefCounted

# Additive, capped evolution: never rescales rarity, affixes, or existing effects.
const GOLD_COSTS := [180, 420]
const SCRAP_COSTS := [8, 18]
const BONUS_PER_STAGE := 0.04

static func stage(item: Dictionary) -> int:
	return clampi(int(item.get("evolution_stage", 0)), 0, 2)

static func offer(item: Dictionary) -> Dictionary:
	var level := stage(item)
	var path: Array = item.get("evolution_path", [])
	if item.get("slot", "") != "Weapon" or level >= mini(2, path.size()):
		return {}
	return {"name":str(path[level]), "gold":GOLD_COSTS[level], "scrap":SCRAP_COSTS[level], "stage":level + 1}

static func evolve(item: Dictionary) -> Dictionary:
	var next := offer(item)
	if next.is_empty():
		return {}
	var result := item.duplicate(true)
	result.evolution_stage = next.stage
	result.name = next.name
	result.effects.damage_mult = float(result.effects.get("damage_mult", 0.0)) + BONUS_PER_STAGE
	return result

static func purchase(inventory, gold: int, stash_index: int) -> Dictionary:
	# -1 means equipped; other values address the actual stash, not filtered rows.
	if stash_index < -1 or stash_index >= inventory.stash.size():
		return {"ok":false, "gold":gold}
	var item: Dictionary = inventory.equipped_item("Weapon") if stash_index == -1 else inventory.stash[stash_index]
	var next := offer(item)
	if next.is_empty() or gold < int(next.gold) or inventory.scrap < int(next.scrap):
		return {"ok":false, "gold":gold}
	var evolved := evolve(item)
	if stash_index == -1:
		inventory.equipped.Weapon = evolved
	else:
		inventory.stash[stash_index] = evolved
	inventory.scrap -= int(next.scrap)
	return {"ok":true, "gold":gold - int(next.gold), "item":evolved}
