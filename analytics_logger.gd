extends RefCounted

const SCHEMA_VERSION := 1

static func log_event(path: String, event_name: String, data: Dictionary = {}) -> void:
	var safe_data := data.duplicate(true)
	for forbidden in ["display_name", "lootling_nickname", "provider_player_id"]:
		safe_data.erase(forbidden)
	var entry := {
		"schema_version":SCHEMA_VERSION,
		"event":event_name,
		"unix_time":int(Time.get_unix_time_from_system()),
		"data":safe_data
	}
	var file := FileAccess.open(path, FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.seek_end()
	file.store_line(JSON.stringify(entry))
