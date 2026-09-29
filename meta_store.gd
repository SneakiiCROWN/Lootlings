extends RefCounted

static func load_progress(path: String) -> Dictionary:
	var result := {"shards": 0, "power": 0, "gold": 0}
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return result
	result.shards = clampi(int(config.get_value("progress", "shards", 0)), 0, 999999)
	result.power = clampi(int(config.get_value("progress", "power", 0)), 0, 100)
	result.gold = clampi(int(config.get_value("progress", "gold", 0)), 0, 999999999)
	return result

static func save_progress(path: String, shards: int, power: int, gold: int = 0) -> Error:
	var config := ConfigFile.new()
	config.set_value("progress", "version", 2)
	config.set_value("progress", "shards", clampi(shards, 0, 999999))
	config.set_value("progress", "power", clampi(power, 0, 100))
	config.set_value("progress", "gold", clampi(gold, 0, 999999999))
	return config.save(path)
