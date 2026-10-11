extends RefCounted

const ItemCatalog = preload("res://item_catalog.gd")
const SLOTS := ["Weapon", "Armour", "Relic", "Rune"]
const STASH_CAPACITY_STEPS := [12, 18, 24]
const DEFAULT_STASH_CAPACITY := 12

var equipped := {}
var stash: Array = []
var craft_receipts: Array[String] = []
var scrap := 0
var stash_capacity := DEFAULT_STASH_CAPACITY

func _init() -> void:
	reset_to_starter()

func reset_to_starter() -> void:
	equipped.clear()
	for slot in SLOTS:
		equipped[slot] = {}
	equipped.Weapon = ItemCatalog.create_item("scrapfang_blade", "COMMON", -1)
	stash.clear()
	craft_receipts.clear()
	scrap = 0
	stash_capacity = DEFAULT_STASH_CAPACITY

func equip(item: Dictionary) -> Dictionary:
	var slot: String = item.get("slot", "")
	if not slot in SLOTS:
		return {"old":{}, "scrapped":0}
	var old: Dictionary = equipped.get(slot, {})
	var auto_scrap := 0
	if not old.is_empty() and old.get("serial", 0) != -1:
		if stash.size() < stash_capacity:
			stash.append(old.duplicate(true))
		else:
			auto_scrap = ItemCatalog.scrap_value(old)
			scrap += auto_scrap
	equipped[slot] = item.duplicate(true)
	return {"old":old, "scrapped":auto_scrap}

func keep(item: Dictionary) -> bool:
	if stash.size() >= stash_capacity:
		return false
	stash.append(item.duplicate(true))
	return true

func equip_from_stash(index: int) -> bool:
	if index < 0 or index >= stash.size():
		return false
	var selected = stash[index]
	if not selected is Dictionary:
		return false
	var item: Dictionary = selected
	var slot: String = item.get("slot", "")
	if not slot in SLOTS:
		return false
	stash.remove_at(index)
	var old: Dictionary = equipped.get(slot, {})
	if not old.is_empty() and old.get("serial", 0) != -1:
		stash.append(old.duplicate(true))
	equipped[slot] = item.duplicate(true)
	return true

func scrap_from_stash(index: int) -> int:
	if index < 0 or index >= stash.size():
		return 0
	var selected = stash[index]
	if not selected is Dictionary:
		return 0
	var item: Dictionary = selected
	stash.remove_at(index)
	return salvage(item)

func salvage(item: Dictionary) -> int:
	var value := ItemCatalog.scrap_value(item)
	scrap += value
	return value

func can_expand_stash() -> bool:
	return stash_capacity < STASH_CAPACITY_STEPS.back()

func next_stash_capacity() -> int:
	for capacity in STASH_CAPACITY_STEPS:
		if capacity > stash_capacity:
			return capacity
	return stash_capacity

func expand_stash() -> bool:
	var next_capacity := next_stash_capacity()
	if next_capacity <= stash_capacity:
		return false
	stash_capacity = next_capacity
	return true

func equipped_item(slot: String) -> Dictionary:
	return equipped.get(slot, {})

func weapon_family() -> String:
	return equipped_item("Weapon").get("family", "VANGUARD")

func effect_total(key: String) -> float:
	var total := 0.0
	for slot in SLOTS:
		var item: Dictionary = equipped.get(slot, {})
		if item.get("effects", {}).has(key):
			total += float(item.effects[key])
	return total

func has_signature(hook: String) -> bool:
	for slot in SLOTS:
		var item: Dictionary = equipped.get(slot, {})
		if hook in item.get("signature_hooks", []):
			return true
	return false

func save(path: String) -> Error:
	var config := ConfigFile.new()
	config.set_value("inventory", "version", 3)
	config.set_value("inventory", "scrap", clampi(scrap, 0, 999999))
	config.set_value("inventory", "stash_capacity", stash_capacity)
	config.set_value("inventory", "stash", stash.slice(0, stash_capacity))
	config.set_value("inventory", "equipped", equipped)
	config.set_value("inventory", "craft_receipts", craft_receipts.slice(-256))
	return preload("res://safe_config.gd").save_config(config, path)

func load(path: String) -> void:
	var config := ConfigFile.new()
	if preload("res://safe_config.gd").load_config(config, path, "inventory") != OK:
		return
	craft_receipts.clear()
	var receipts = config.get_value("inventory","craft_receipts",[])
	if receipts is Array:
		for receipt in receipts.slice(-256):
			if receipt is String and receipt.length() <= 160 and not receipt in craft_receipts: craft_receipts.append(receipt)
	scrap = clampi(preload("res://safe_config.gd").int_value(config.get_value("inventory", "scrap", 0)), 0, 999999)
	var loaded_capacity := preload("res://safe_config.gd").int_value(config.get_value("inventory", "stash_capacity", DEFAULT_STASH_CAPACITY),DEFAULT_STASH_CAPACITY)
	stash_capacity = loaded_capacity if loaded_capacity in STASH_CAPACITY_STEPS else DEFAULT_STASH_CAPACITY
	var loaded_stash = config.get_value("inventory", "stash", [])
	stash.clear()
	if loaded_stash is Array:
		for record in loaded_stash:
			var item := sanitize_saved_item(record)
			if not item.is_empty() and stash.size() < stash_capacity: stash.append(item)
	var loaded_equipped = config.get_value("inventory", "equipped", {})
	if loaded_equipped is Dictionary:
		for slot in SLOTS:
			equipped[slot] = sanitize_saved_item(loaded_equipped.get(slot, {}),slot)
	if equipped_item("Weapon").is_empty():
		equipped.Weapon = ItemCatalog.create_item("scrapfang_blade", "COMMON", -1)
	# v1/v2 items retain their exact effects; missing evolution is stage zero.
	for item in stash:
		if item is Dictionary:
			item.evolution_stage = clampi(preload("res://safe_config.gd").int_value(item.get("evolution_stage", 0)), 0, 2)
	for slot in SLOTS:
		var item: Dictionary = equipped.get(slot, {})
		if not item.is_empty():
			item.evolution_stage = clampi(preload("res://safe_config.gd").int_value(item.get("evolution_stage", 0)), 0, 2)

static func sanitize_saved_item(record: Variant, expected_slot: String = "") -> Dictionary:
	if not record is Dictionary or record.is_empty(): return {}
	var slot = record.get("slot",expected_slot)
	if not slot is String or not slot in SLOTS or (not expected_slot.is_empty() and slot != expected_slot): return {}
	if not record.get("id",null) is String or not record.get("effects",{}) is Dictionary: return {}
	var item: Dictionary = record.duplicate(true)
	item.slot = slot
	for key in item.get("effects",{}):
		var value = item.effects[key]
		if not (value is int or value is float) or not is_finite(float(value)): return {}
	var defaults := ItemCatalog.definition(item.id)
	if str(item.get("desc","")).contains("Scrip") and not defaults.is_empty():item.desc=defaults.get("desc",item.get("desc",""))
	for key in ["name","desc","rarity","family","weapon_type","signature"]:
		if item.has(key) and not item[key] is String: item[key] = str(defaults.get(key,""))
	if item.has("signature_hooks"):
		item.signature_hooks = item.signature_hooks.filter(func(hook): return hook is String) if item.signature_hooks is Array else []
	if item.has("serial"): item.serial = preload("res://safe_config.gd").int_value(item.serial)
	return item
