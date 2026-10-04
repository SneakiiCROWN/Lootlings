extends RefCounted
static func int_value(value: Variant, fallback: int = 0) -> int:
	if value is int: return value
	if value is float and is_finite(value): return int(value)
	if value is String and value.is_valid_int(): return int(value)
	return fallback

# A verified temporary file plus one previous parseable generation per store.
# This is per-file recovery, not a cross-store transaction or a resumable run.
static func load_config(config: ConfigFile, path: String, section: String) -> Error:
	var error := config.load(path)
	if error == OK and config.has_section(section): return OK
	for suffix in [".bak", ".tmp"]:
		var recovered := ConfigFile.new()
		if recovered.load(path + suffix) == OK and recovered.has_section(section):
			for key in recovered.get_section_keys(section):
				config.set_value(section, key, recovered.get_value(section, key))
			push_warning("Recovered save store %s from %s" % [path, suffix])
			return OK
	return error if error != OK else ERR_FILE_CORRUPT

static func save_config(config: ConfigFile, path: String) -> Error:
	var temp := path + ".tmp"
	var error := config.save(temp)
	if error != OK: return report(path, error)
	var verified := ConfigFile.new()
	error = verified.load(temp)
	if error != OK: return report(path, error)
	var previous := ConfigFile.new()
	if previous.load(path) == OK and previous.get_sections() == config.get_sections():
		error = DirAccess.copy_absolute(path, path + ".bak.tmp")
		if error != OK: return report(path, error)
		error = DirAccess.rename_absolute(path + ".bak.tmp", path + ".bak")
		if error != OK: return report(path, error)
	error = DirAccess.rename_absolute(temp, path)
	return report(path, error)

static func report(path: String, error: Error) -> Error:
	if error != OK: push_error("Save failed for %s (error %d); previous generation retained." % [path, error])
	return error
