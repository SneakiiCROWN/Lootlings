extends RefCounted
# Only explicitly approved, authored companion exports may populate this catalog.
# No creature/enemy image is silently repurposed as a pet identity.
const ENTRIES := {}

static func available_ids() -> Array[String]:
	var result: Array[String] = []
	for id in ENTRIES:
		var entry: Dictionary = ENTRIES[id]
		var complete: bool=entry.get("owner_approved",false)==true
		for state in ["idle","move","reaction"]:
			for facing in ["right","left"]:complete=complete and ResourceLoader.exists(str(entry.get(state+"_"+facing,"")))
		if complete:result.append(id)
	return result

static func sanitize(value: Variant) -> Dictionary:
	var result := {"equipped_id":"", "owned_ids":[], "accompany":false}
	if not value is Dictionary: return result
	for id in value.get("owned_ids",[]) if value.get("owned_ids",[]) is Array else []:
		if id is String and id in available_ids() and not id in result.owned_ids: result.owned_ids.append(id)
	var selected = value.get("equipped_id","")
	if selected is String and selected in result.owned_ids: result.equipped_id=selected
	result.accompany=value.get("accompany",false)==true
	return result

static func texture(id: String, state: String, facing: String) -> Texture2D:
	if id not in available_ids(): return null
	var path: String=ENTRIES[id].get(state+"_"+facing,"")
	return load(path) if not path.is_empty() and ResourceLoader.exists(path) else null
