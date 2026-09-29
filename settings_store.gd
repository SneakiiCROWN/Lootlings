extends RefCounted

const CHANNELS := ["master", "music", "sfx", "ui", "ambience"]

static func defaults() -> Dictionary:
	return {
		"version":1,
		"master":0.85, "music":0.65, "sfx":0.85, "ui":0.80, "ambience":0.55,
		"master_muted":false, "music_muted":false, "sfx_muted":false,
		"ui_muted":false, "ambience_muted":false
	}

static func load_settings(path: String) -> Dictionary:
	var result := defaults()
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return result
	for key in result:
		result[key] = config.get_value("audio", key, result[key])
	for channel in CHANNELS:
		result[channel] = clampf(float(result[channel]), 0.0, 1.0)
		result[channel + "_muted"] = bool(result[channel + "_muted"])
	return result

static func save_settings(path: String, settings: Dictionary) -> Error:
	var config := ConfigFile.new()
	var safe := defaults()
	for key in safe:
		safe[key] = settings.get(key, safe[key])
	for channel in CHANNELS:
		safe[channel] = clampf(float(safe[channel]), 0.0, 1.0)
		safe[channel + "_muted"] = bool(safe[channel + "_muted"])
	for key in safe:
		config.set_value("audio", key, safe[key])
	return config.save(path)
