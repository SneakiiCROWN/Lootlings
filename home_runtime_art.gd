extends RefCounted
# Only reviewed exact Home deliveries may enter ordinary player routes.
const MANIFEST = "res://art/production/phase4e/home_runtime_manifest.json"
const REVISIONS="res://art/production/phase4e/home_world_revisions.json"
static var textures := {}
static var review_assets := {}
static func texture(slot: String) -> Texture2D:
	var path := ""
	var boundary: String=ProjectSettings.globalize_path("res://.godot_test_data/isolated/").replace("\\","/").to_lower()
	if OS.get_environment("LOOTLINGS_QA")=="1" and OS.get_user_data_dir().replace("\\","/").to_lower().begins_with(boundary):
		path=str(review_assets.get(slot,""))
	if path.is_empty() and FileAccess.file_exists(REVISIONS):
		var revisions=JSON.parse_string(FileAccess.get_file_as_string(REVISIONS))
		if revisions is Dictionary:
			for row in revisions.get("entries",[]):
				if row is Dictionary and row.get("master_artist_slot_id","")==slot and row.get("native_validated",false)==true:
					var candidate:String=str(row.get("asset_path",""))
					if FileAccess.get_sha256(candidate)==row.get("asset_sha256",""):path=candidate
					break
	if path.is_empty() and FileAccess.file_exists(MANIFEST):
		var data=JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
		if data is Dictionary:
			for row in data.get("entries",[]):
				if row is Dictionary and row.get("master_artist_slot_id","")==slot and row.get("native_validated",false)==true:
					path=str(row.get("asset_path",""));break
	if path.is_empty() or not path.begins_with("res://art/production/phase4e/") or ".." in path or not ResourceLoader.exists(path):return null
	if not textures.has(path):textures[path]=load(path)
	return textures[path] if textures[path] is Texture2D else null
