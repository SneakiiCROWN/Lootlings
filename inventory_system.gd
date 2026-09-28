extends RefCounted

const ItemCatalog = preload("res://item_catalog.gd")
const SLOTS := ["Weapon", "Armour", "Relic", "Rune"]
const MAX_STASH := 12

var equipped := {}
var stash: Array = []
var scrap := 0

func _init() -> void:
	reset_to_starter()

func reset_to_starter() -> void:
	equipped.clear()
	for slot in SLOTS:
		equipped[slot] = {}
	equipped.Weapon = ItemCatalog.create_item("scrapfang_blade", "COMMON", -1)
	stash.clear()
	scrap = 0

func equip(item: Dictionary) -> Dictionary:
	var slot: String = item.get("slot", "")
	if not slot in SLOTS:
		return {"old":{}, "scrapped":0}
	var old: Dictionary = equipped.get(slot, {})
	var auto_scrap := 0
	if not old.is_empty() and old.get("serial", 0) != -1:
		if stash.size() < MAX_STASH:
			stash.append(old.duplicate(true))
		else:
			auto_scrap = ItemCatalog.scrap_value(old)
			scrap += auto_scrap
	equipped[slot] = item.duplicate(true)
	return {"old":old, "scrapped":auto_scrap}

func keep(item: Dictionary) -> bool:
	if stash.size() >= MAX_STASH:
		return false
	stash.append(item.duplicate(true))
	return true

func salvage(item: Dictionary) -> int:
	var value := ItemCatalog.scrap_value(item)
	scrap += value
	return value

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

func save(path: String) -> Error:
	var config := ConfigFile.new()
	config.set_value("inventory", "version", 1)
	config.set_value("inventory", "scrap", clampi(scrap, 0, 999999))
	config.set_value("inventory", "stash", stash.slice(0, MAX_STASH))
	config.set_value("inventory", "equipped", equipped)
	return config.save(path)

func load(path: String) -> void:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return
	scrap = clampi(int(config.get_value("inventory", "scrap", 0)), 0, 999999)
	var loaded_stash = config.get_value("inventory", "stash", [])
	stash = loaded_stash.slice(0, MAX_STASH) if loaded_stash is Array else []
	var loaded_equipped = config.get_value("inventory", "equipped", {})
	if loaded_equipped is Dictionary:
		for slot in SLOTS:
			var item = loaded_equipped.get(slot, {})
			if item is Dictionary and (item.is_empty() or item.get("slot", slot) == slot):
				equipped[slot] = item
	if equipped_item("Weapon").is_empty():
		equipped.Weapon = ItemCatalog.create_item("scrapfang_blade", "COMMON", -1)
