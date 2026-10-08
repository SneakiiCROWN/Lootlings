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
	# A missing authored action never licenses an alternate identity. Keep the
	# accepted facing's neutral body through the visual clocks, explicitly as
	# reused idle art, not a completed authored attack/hurt/defeat delivery.
	var actor: String=g.enemy_name.to_lower().replace(" ","_")
	var facing: String="right" if g.enemy_facing_at(x)>0 else "left"
	var result:=preload("res://enemy_art_manifest.gd").frame(actor,preload("res://enemy_art_manifest.gd").state_for(g),facing)
	if not result.is_empty():return result
	result=preload("res://enemy_art_manifest.gd").frame(actor,"idle",facing)
	if result.is_empty():result=frame(actor,"idle",facing)
	if not result.is_empty():result["reused_idle_for_missing_action"]=true
	return result
