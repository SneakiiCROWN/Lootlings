extends RefCounted

static func load_progress(path: String) -> Dictionary:
	var result := {"shards": 0, "power": 0, "gold": 0, "gold_upgrades":preload("res://permanent_upgrade_catalog.gd").defaults(),"rift":preload("res://rift_progress.gd").defaults()}
	var config := ConfigFile.new()
	if preload("res://safe_config.gd").load_config(config, path, "progress") != OK:
		return result
	var balances:Dictionary=preload("res://currency_schema.gd").balances(config)
	result.shards=balances.shards;result.gold=balances.gold
	result.power = clampi(preload("res://safe_config.gd").int_value(config.get_value("progress", "power", 0)), 0, 100)
	var saved_upgrades = config.get_value("progress", "gold_upgrades", {})
	if saved_upgrades is Dictionary:
		for upgrade_id in result.gold_upgrades:
			result.gold_upgrades[upgrade_id] = clampi(preload("res://safe_config.gd").int_value(saved_upgrades.get(upgrade_id, 0)), 0, preload("res://permanent_upgrade_catalog.gd").DEFINITIONS[upgrade_id][2].size())
	var rift = config.get_value("progress", "rift", {})
	if rift is Dictionary:result.rift=preload("res://rift_progress.gd").sanitize(rift)
	return result

static func save_progress(path: String, shards: int, power: int, gold: int = 0, gold_upgrades: Dictionary = {}, rift: Dictionary = {}) -> Error:
	var config := ConfigFile.new()
	config.set_value("progress", "version", 3)
	config.set_value("progress", "shards", clampi(shards, 0, 999999))
	config.set_value("progress", "power", clampi(power, 0, 100))
	config.set_value("progress", "gold", clampi(gold, 0, 999999999))
	var safe_upgrades := preload("res://permanent_upgrade_catalog.gd").defaults()
	for upgrade_id in safe_upgrades:
		safe_upgrades[upgrade_id] = clampi(int(gold_upgrades.get(upgrade_id, 0)), 0, preload("res://permanent_upgrade_catalog.gd").DEFINITIONS[upgrade_id][2].size())
	config.set_value("progress", "gold_upgrades", safe_upgrades)
	config.set_value("progress", "rift", preload("res://rift_progress.gd").sanitize(rift))
	preload("res://currency_schema.gd").write_names(config,gold,shards)
	return preload("res://safe_config.gd").save_config(config, path)
