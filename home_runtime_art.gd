extends RefCounted
# Only reviewed exact Home deliveries may enter ordinary player routes.
const MANIFEST = "res://art/production/phase4e/home_runtime_manifest.json"
const REVISIONS="res://art/production/phase4e/home_world_revisions.json"
static var textures := {}
static var registered_paths := {}
static var review_assets := {}
static func texture(slot: String) -> Texture2D:
	var path := ""
	var boundary: String=ProjectSettings.globalize_path("res://.godot_test_data/isolated/").replace("\\","/").to_lower()
	if OS.get_environment("LOOTLINGS_QA")=="1" and OS.get_user_data_dir().replace("\\","/").to_lower().begins_with(boundary):
		path=str(review_assets.get(slot,""))
	var cached:bool=registered_paths.has(slot)
	if path.is_empty() and cached:path=str(registered_paths[slot])
	if path.is_empty() and not cached and FileAccess.file_exists(REVISIONS):
		var revisions=JSON.parse_string(FileAccess.get_file_as_string(REVISIONS))
		if revisions is Dictionary:
			for row in revisions.get("entries",[]):
				if row is Dictionary and row.get("master_artist_slot_id","")==slot and row.get("native_validated",false)==true:
					var candidate:String=str(row.get("asset_path",""))
					if candidate.begins_with("res://art/production/phase4e/") and ".." not in candidate and ResourceLoader.exists(candidate):
						var accepted:Texture2D=load(candidate)
						var pixels:Image=accepted.get_image() if accepted!=null else null
						if pixels!=null:
							pixels.convert(Image.FORMAT_RGBA8)
							var digest:=HashingContext.new();digest.start(HashingContext.HASH_SHA256);digest.update(pixels.get_data())
							if digest.finish().hex_encode()==row.get("pixel_sha256",""):path=candidate;textures[candidate]=accepted
					break
	if path.is_empty() and not cached and FileAccess.file_exists(MANIFEST):
		var data=JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
		if data is Dictionary:
			for row in data.get("entries",[]):
				if row is Dictionary and row.get("master_artist_slot_id","")==slot and row.get("native_validated",false)==true:
					path=str(row.get("asset_path",""));break
	# Resolve and verify once; redraws never rehash megabytes of room art.
	if not cached and not review_assets.has(slot):registered_paths[slot]=path
	if path.is_empty() or not path.begins_with("res://art/production/phase4e/") or ".." in path or not ResourceLoader.exists(path):return null
	if not textures.has(path):textures[path]=load(path)
	return textures[path] if textures[path] is Texture2D else null
