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

static func idle_preview(id: String) -> Texture2D:
	# Partial validated neutral art is a collection preview, never an equip gate.
	if id not in ENTRIES or not FileAccess.file_exists(RUNTIME_MANIFEST):return null
	var manifest=JSON.parse_string(FileAccess.get_file_as_string(RUNTIME_MANIFEST))
	if not manifest is Dictionary or not manifest.get("entries",null) is Array:return null
	var path:=runtime_path(id,"idle","right")
	for row in manifest.entries:
		if row is Dictionary and row.get("actor","")==id and row.get("state","")=="idle" and row.get("facing","")=="right" and row.get("asset_path","")==path and row.get("owner_approved",false)==true and row.get("native_validated",false)==true:
			if ResourceLoader.exists(path):
				var result=load(path)
				return result if result is Texture2D and result.get_size()==Vector2(256,256) else null
	return null

static func available_ids() -> Array[String]:
	var result: Array[String] = []
	# Merely dropping PNGs into the folder does not approve body-state anatomy.
	if not FileAccess.file_exists(RUNTIME_MANIFEST):return result
	var manifest=JSON.parse_string(FileAccess.get_file_as_string(RUNTIME_MANIFEST))
	if not manifest is Dictionary or not manifest.get("entries",null) is Array:return result
	for id in ENTRIES:
		var entry: Dictionary = ENTRIES[id]
		# Named reference authority approves identity; the six authored frames are
		# a separate availability gate. UI board crops never satisfy that gate.
		var complete: bool=true
		for state in ["idle","move","reaction"]:
			for facing in ["right","left"]:
				var path: String=runtime_path(id,state,facing)
				var accepted: bool=manifest.entries.any(func(row):return row is Dictionary and row.get("actor","")==id and row.get("state","")==state and row.get("facing","")==facing and row.get("asset_path","")==path and row.get("owner_approved",false)==true and row.get("native_validated",false)==true)
				complete=complete and accepted
				if not ResourceLoader.exists(path):complete=false
				elif not load(path) is Texture2D or load(path).get_size()!=Vector2(256,256):complete=false
		if complete:result.append(id)
	return result

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
	if id not in available_ids(): return null
	var path: String=runtime_path(id,state,facing)
	if path.is_empty() or not ResourceLoader.exists(path):return null
	var result: Texture2D=load(path)
	return result if result.get_size()==Vector2(256,256) else null

static func runtime_path(id: String, state: String, facing: String) -> String:
	if id not in ENTRIES or state not in ["idle","move","reaction"] or facing not in ["right","left"]:return ""
	return "res://art/production/companions/"+id+"/"+id+"_"+state+"_"+facing+".png"
