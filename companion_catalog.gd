extends RefCounted
# Only explicitly approved, authored companion exports may populate this catalog.
# No creature/enemy image is silently repurposed as a pet identity.
const REFERENCE_ROOT="res://art/reference/canonical/companions/"
const RUNTIME_MANIFEST="res://art/production/companions/runtime_manifest.json"
const ENTRIES := {
	"auricub":{"name":"Auricub","unlock_id":"sunfeather_relic","unlock_name":"Sunfeather Relic","voice":"Curious hearts find the brightest things."},
	"stonekith":{"name":"Stonekith","unlock_id":"terrastone_core","unlock_name":"Terrastone Core","voice":"Small protector. Serious loyalty."},
	"pixrask":{"name":"Pixrask","unlock_id":"shadowflame_ember","unlock_name":"Shadowflame Ember","voice":"Chaos finds the cutest form."},
	"lunarwisp":{"name":"Lunarwisp","unlock_id":"moonlantern_shard","unlock_name":"Moonlantern Shard","voice":"Guided by moonlight, adorned by starlight."},
	"puffnest":{"name":"Puffnest","unlock_id":"bloomnest_seed","unlock_name":"Bloomnest Seed","voice":"Small homes make the coziest adventures."},
	"breezewyn":{"name":"Breezewyn","unlock_id":"skybell_orbit","unlock_name":"Skybell Orbit","voice":"Playful winds. Brighter days."},
}

static func known_ids() -> Array:
	return ENTRIES.keys()

static func id_for_unlock(item_id: String) -> String:
	for id in ENTRIES:
		if ENTRIES[id].unlock_id==item_id:return id
	return ""

static func preview(id: String, unlock: bool=false) -> Texture2D:
	if id not in ENTRIES:return null
	return load("res://art/production/companions/previews/"+id+("_unlock.png" if unlock else "_portrait.png"))

static var textures := {}
static var review_assets := {}
const FOLLOWER_STATES := ["idle","move","reaction"]
const PERCH_STATES := ["perch_rest","perch_interact"]

static func manifest_entries() -> Array:
	if not FileAccess.file_exists(RUNTIME_MANIFEST):return []
	var manifest=JSON.parse_string(FileAccess.get_file_as_string(RUNTIME_MANIFEST))
	return manifest.entries if manifest is Dictionary and manifest.get("entries",null) is Array else []

static func accepted_frame(id: String, state: String, facing: String, entries: Array) -> Texture2D:
	var path:=runtime_path(id,state,facing)
	if path.is_empty():return null
	var boundary: String=ProjectSettings.globalize_path("res://.godot_test_data/isolated/").replace("\\","/").to_lower()
	if OS.get_environment("LOOTLINGS_QA")=="1" and OS.get_user_data_dir().replace("\\","/").to_lower().begins_with(boundary):
		var staged: String=str(review_assets.get(id+":"+state+":"+facing,""))
		if staged.begins_with("res://art/source/master_artist_delivery/art/source/companions/") and ".." not in staged and FileAccess.file_exists(staged):
			if not textures.has(staged):
				var pixels:=Image.load_from_file(staged)
				if pixels==null or pixels.get_size()!=Vector2i(256,256):return null
				textures[staged]=ImageTexture.create_from_image(pixels)
			var candidate=textures[staged]
			return candidate if candidate is Texture2D and candidate.get_size()==Vector2(256,256) else null
	var accepted: bool=entries.any(func(row):return row is Dictionary and row.get("actor","")==id and row.get("state","")==state and row.get("facing","")==facing and row.get("asset_path","")==path and row.get("owner_approved",false)==true and row.get("native_validated",false)==true)
	if not accepted or not ResourceLoader.exists(path):return null
	if not textures.has(path):textures[path]=load(path)
	var result=textures[path]
	return result if result is Texture2D and result.get_size()==Vector2(256,256) else null

static func idle_preview(id: String) -> Texture2D:
	# Partial neutral art may preview the collection; it cannot enable equipment.
	return accepted_frame(id,"idle","right",manifest_entries())

static func complete_states(id: String, states: Array, entries: Array) -> bool:
	if id not in ENTRIES:return false
	for state in states:
		for facing in ["right","left"]:
			if accepted_frame(id,state,facing,entries)==null:return false
	return true

static func available_ids() -> Array[String]:
	var result: Array[String]=[]
	var entries:=manifest_entries()
	for id in ENTRIES:
		if complete_states(id,FOLLOWER_STATES,entries):result.append(id)
	return result

static func can_perch(id: String) -> bool:
	var entries:=manifest_entries()
	return complete_states(id,FOLLOWER_STATES,entries) and complete_states(id,PERCH_STATES,entries)

static func sanitize(value: Variant) -> Dictionary:
	var result := {"equipped_id":"", "owned_ids":[], "accompany":false}
	if not value is Dictionary: return result
	for id in value.get("owned_ids",[]) if value.get("owned_ids",[]) is Array else []:
		if id is String and id in known_ids() and not id in result.owned_ids: result.owned_ids.append(id)
	var selected = value.get("equipped_id","")
	if selected is String and selected in result.owned_ids and selected in available_ids(): result.equipped_id=selected
	result.accompany=value.get("accompany",false)==true
	return result

static func texture(id: String, state: String, facing: String) -> Texture2D:
	var entries:=manifest_entries()
	if not complete_states(id,FOLLOWER_STATES,entries):return null
	if state in PERCH_STATES and not complete_states(id,PERCH_STATES,entries):return null
	return accepted_frame(id,state,facing,entries)

static func runtime_path(id: String, state: String, facing: String) -> String:
	if id not in ENTRIES or (state not in FOLLOWER_STATES and state not in PERCH_STATES) or facing not in ["right","left"]:return ""
	return "res://art/production/companions/"+id+"/"+id+"_"+state+"_"+facing+".png"
