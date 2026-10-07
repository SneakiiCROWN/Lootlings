extends RefCounted
# Exact owner-approved export routing; no board textures, mirroring or state fallback.
static var entries: Array = []
static var initialized := false
static var textures: Dictionary = {}
static func frame(actor: String, state: String, facing: String) -> Dictionary:
	if not initialized:
		initialized=true
		var data=JSON.parse_string(FileAccess.get_file_as_string("res://art/production/phase4e/approved_missing_runtime_manifest.json"))
		if data is Dictionary: entries=data.get("entries",[])
	for entry in entries:
		if entry.actor==actor and entry.state==state and entry.facing==facing and entry.get("native_validated",false):
			var path: String=entry.asset_path
			if not textures.has(path):textures[path]=load(path)
			return {"texture":textures[path],"path":path,"source_facing":facing,"status":"Canonical source export / LIVE_BETA; this exact state/view only"}
	return {}
static func enemy_neutral(g, x: float) -> Dictionary:
	if not g.enemy_alive or g.enemy_flash>0 or g.enemy_death_anim>0 or g.enemy_attack_anim>0 or g.enemy_attack_clock<.30 or g.enemy_entry_anim>0:return {}
	return frame(g.enemy_name.to_lower().replace(" ","_"),"idle","right" if g.enemy_facing_at(x)>0 else "left")
