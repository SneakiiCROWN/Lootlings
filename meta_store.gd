extends RefCounted

static func load_progress(path: String) -> Dictionary:
	var result := {"shards": 0, "power": 0, "gold": 0, "gold_upgrades":{"bedroll":0, "whetstone":0, "pouch":0}}
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return result
	result.shards = clampi(int(config.get_value("progress", "shards", 0)), 0, 999999)
	result.power = clampi(int(config.get_value("progress", "power", 0)), 0, 100)
	result.gold = clampi(int(config.get_value("progress", "gold", 0)), 0, 999999999)
	var saved_upgrades = config.get_value("progress", "gold_upgrades", {})
	if saved_upgrades is Dictionary:
		for upgrade_id in result.gold_upgrades:
			result.gold_upgrades[upgrade_id] = clampi(int(saved_upgrades.get(upgrade_id, 0)), 0, 5)
	return result

static func save_progress(path: String, shards: int, power: int, gold: int = 0, gold_upgrades: Dictionary = {}) -> Error:
	var config := ConfigFile.new()
	config.set_value("progress", "version", 3)
	config.set_value("progress", "shards", clampi(shards, 0, 999999))
	config.set_value("progress", "power", clampi(power, 0, 100))
	config.set_value("progress", "gold", clampi(gold, 0, 999999999))
	var safe_upgrades := {"bedroll":0, "whetstone":0, "pouch":0}
	for upgrade_id in safe_upgrades:
		safe_upgrades[upgrade_id] = clampi(int(gold_upgrades.get(upgrade_id, 0)), 0, 5)
	config.set_value("progress", "gold_upgrades", safe_upgrades)
	return config.save(path)
