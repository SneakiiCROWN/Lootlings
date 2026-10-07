extends RefCounted
# Narrow owner rejection boundary. Historical files remain preserved.
static var loaded := false
static var actors := {}
static func corrected_actor(id: String) -> bool:
	if not loaded:
		loaded=true
		var data: Variant=JSON.parse_string(FileAccess.get_file_as_string("res://art/actor_identity_corrections.json"))
		if data is Dictionary:actors=data.get("actors",{})
	return actors.has(id) and actors[id].status == "TARGET_REFERENCE_CONFIRMATION_PENDING"
static func allowed(id: String,path: String) -> bool:
	if not corrected_actor(id):return true
	return path in actors[id].get("approved_runtime_exports",[])
