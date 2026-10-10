extends RefCounted
# Exact authored enemy state/facing exports; missing poses remain explicit.
static var entries: Array = []
static var initialized := false
static var textures: Dictionary = {}
static func state_for(g) -> String:
	if not g.enemy_alive:return "defeat"
	if g.enemy_flash>0:return "hurt"
	if g.enemy_attack_anim>.06:return "role commit"
	if g.enemy_attack_anim>0:return "recovery"
	if preload("res://combat_presentation.gd").attack_cue(g).visible:return "role windup"
	return "idle"
static func frame(actor: String, state: String, facing: String) -> Dictionary:
	if not initialized:
		initialized=true
		var data=JSON.parse_string(FileAccess.get_file_as_string("res://art/production_enemy_manifest.json"))
		if data is Dictionary:entries=data.get("entries",[])
		var continuation:="res://art/source/combat_continuation_046/ENEMY_CANDIDATE_MANIFEST.json"
		if OS.get_environment("LOOTLINGS_QA")=="1" and OS.get_environment("LOOTLINGS_QA_ENEMY_PREVIEW")=="1" and FileAccess.file_exists(continuation):
			var preview_data:Variant=JSON.parse_string(FileAccess.get_file_as_string(continuation))
			if preview_data is Dictionary:entries.append_array(preview_data.get("entries",[]))
	for row in entries:
		if row.actor!=actor or row.state!=state or row.facing!=facing:continue
		var accepted: bool=row.get("native_validated",false) and row.get("production_status","")=="canon_validated_runtime"
		var preview: bool=OS.get_environment("LOOTLINGS_QA")=="1" and OS.get_environment("LOOTLINGS_QA_ENEMY_PREVIEW")=="1"
		if not accepted and not preview:continue
		var path: String=row.asset_path
		if not path.begins_with("res://art/production/phase4e/enemies/") or ".." in path:continue
		if not textures.has(path):
			var region: Array=row.content_rect
			var atlas:=AtlasTexture.new();atlas.atlas=load(path);atlas.region=Rect2(region[0],region[1],region[2],region[3]);textures[path]=atlas
		return {"texture":textures[path],"path":path,"source_facing":facing,"authored_state":state,"display_size":Vector2(row.content_rect[2],row.content_rect[3])*float(row.native_pixel_scale),"status":"Canon-validated exact enemy action/facing"}
	return {}
