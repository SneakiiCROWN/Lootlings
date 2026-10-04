extends RefCounted

const SCHEMA_VERSION := 1
const MAX_LOG_BYTES := 256 * 1024

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
	var line := JSON.stringify(entry)
	if line.to_utf8_buffer().size() + 1 > MAX_LOG_BYTES: return
	var file := FileAccess.open(path, FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	if file.get_length() + line.to_utf8_buffer().size() + 1 > MAX_LOG_BYTES:
		file.close()
		# Optional local diagnostics are not a save store. Keep one prior log;
		# file rename replaces the prior file, avoiding a growing history or copy.
		if DirAccess.rename_absolute(path,path + ".previous") != OK: return
		file = FileAccess.open(path,FileAccess.WRITE)
		if file == null: return
	file.seek_end()
	file.store_line(line)
