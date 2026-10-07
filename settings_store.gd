extends RefCounted

const CHANNELS := ["master", "music", "sfx", "ui", "ambience"]

static func defaults() -> Dictionary:
	return {
		"version":1,
		"master":0.90, "music":0.58, "sfx":0.92, "ui":0.84, "ambience":0.62,
		"master_muted":false, "music_muted":false, "sfx_muted":false,
		"ui_muted":false, "ambience_muted":false,
		"cinematic_first_time":true, "cinematic_repeat_boss":true,
		"cinematic_auto_skip":true, "cinematic_reduced_motion":false,
		"cinematic_subtitles":true
	}

static func load_settings(path: String) -> Dictionary:
	var result := defaults()
	var config := ConfigFile.new()
	if preload("res://safe_config.gd").load_config(config, path, "audio") != OK:
		return result
	for key in result:
		result[key] = config.get_value("audio", key, result[key])
	return sanitize(result)

static func save_settings(path: String, settings: Dictionary) -> Error:
	var config := ConfigFile.new()
	var safe := defaults()
	for key in safe:
		safe[key] = settings.get(key, safe[key])
	safe=sanitize(safe)
	for key in safe:
		config.set_value("audio", key, safe[key])
	return preload("res://safe_config.gd").save_config(config, path)

static func sanitize(value: Dictionary) -> Dictionary:
	var result:=defaults()
	for key in result:
		var candidate=value.get(key,result[key])
		if key in CHANNELS:
			if (candidate is float or candidate is int) and is_finite(float(candidate)):result[key]=clampf(float(candidate),0,1)
		elif typeof(candidate)==typeof(result[key]):result[key]=candidate
	return result
