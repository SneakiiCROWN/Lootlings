extends RefCounted
# Local provider seam: future cloud transport can wrap snapshots; no credentials or online calls.
const Safe = preload("res://safe_config.gd")
func load_snapshot(path: String, section: String) -> Dictionary:
	var cfg:=ConfigFile.new()
	if Safe.load_config(cfg,path,section)!=OK: return {}
	return cfg.get_value(section,"snapshot",{}) if cfg.get_value(section,"snapshot",{}) is Dictionary else {}
func save_snapshot(path: String, section: String, snapshot: Dictionary) -> Error:
	var cfg:=ConfigFile.new(); cfg.set_value(section,"snapshot",snapshot)
	return Safe.save_config(cfg,path)
