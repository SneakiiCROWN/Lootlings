extends RefCounted
# Asset manifest adapter for the existing WeaponFit registration system.
const PATH := "res://art/production_pose_manifest.json"
static var entries: Array = []
static var initialized := false
static var extracted_rows: Array = []
static var extracted_loaded := false
static var extracted_resolved := {}

static func extracted_phase(actor: String, subtype: String, phase: String, facing: float) -> Dictionary:
	if not extracted_loaded:
		extracted_loaded = true
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://art/production/phase4e/runtime_manifest.json"))
		if data is Dictionary: extracted_rows = data.get("entries",[])
		var reuse: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://art/production/phase4e/reuse_manifest.json"))
		if reuse is Dictionary: extracted_rows.append_array(reuse.get("entries",[]))
	for row in extracted_rows:
		if row.actor == actor and subtype in row.weapon_types and row.phase == phase and row.facing == ("left_only" if facing<0 else "right_only"):
			# Canvas commands retain RIDs, not this local Texture2D reference.
			# Keep source textures alive across frames, not just QA sampling.
			if not extracted_resolved.has(row.asset_path):
				var result := resolve(row)
				result.baked_weapon = row.get("baked_weapon","")
				result.extracted_idle = phase == "IDLE"
				result.extracted_pose = true
				extracted_resolved[row.asset_path] = result
			return extracted_resolved[row.asset_path]
	return {}
const PHASE_KEYS := {"IDLE":"IDLE","WINDUP":"ANTICIPATE","ANTICIPATE":"ANTICIPATE","STRIKE":"ATTACK","CAST":"ATTACK","ATTACK":"ATTACK","IMPACT":"IMPACT","RECOVER":"RECOVER","HURT":"HURT"}

static func rows() -> Array:
	if not initialized:
		initialized = true
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		if data is Dictionary: entries = data.get("entries",[])
	return entries

static func pack(actor: String, stance: String) -> Dictionary:
	var right := facing_pack(actor,stance,"right_only")
	if right.is_empty(): return {}
	var left := facing_pack(actor,stance,"left_only")
	if not left.is_empty(): right.facing_variants = {"left":left}
	return right

static func facing_pack(actor: String, stance: String, facing: String) -> Dictionary:
	var ready := {}
	var release := {}
	var additional := {}
	for row in rows():
		if row.actor != actor or row.stance != stance or row.production_status != "authored_beta" or row.facing != facing:
			continue
		if row.phase == "READY": ready = row
		elif row.phase == "RELEASE": release = row
		elif PHASE_KEYS.has(str(row.phase)): additional[PHASE_KEYS[str(row.phase)]]=row
	if ready.is_empty() or release.is_empty(): return {}
	var first := resolve(ready)
	var last := resolve(release)
	if first.is_empty() or last.is_empty(): return {}
	first.phase_variants = {"ATTACK":last,"IMPACT":last}
	if actor == "relic_beast" and stance == "heavy_two_hand":
		first.phase_variants["RECOVER"] = last
	# Approved phase exports ride the existing clocks/sockets. Missing optional
	# assets leave the good READY/RELEASE pair intact; no portrait-cutting fallback.
	for phase in additional:
		var resolved:=resolve(additional[phase])
		if not resolved.is_empty(): first.phase_variants[phase]=resolved
	return first

static func resolve(row: Dictionary) -> Dictionary:
	# Boards/reference crops must never become runtime bodies through a JSON edit.
	var path: String=str(row.asset_path)
	if not (path.begins_with("res://art/sprites/") or path.begins_with("res://art/production/phase4e/lootlings/")) or ".." in path: return {}
	if not ResourceLoader.exists(str(row.asset_path)): return {}
	var rect := Rect2(Vector2(row.body_rect[0],row.body_rect[1]),Vector2(row.body_rect[2],row.body_rect[3]))
	var result := {"texture":load(str(row.asset_path)),"body_rect":rect,
		"primary_hand":rect.position+Vector2(row.primary_anchor[0],row.primary_anchor[1])*rect.size,
		"secondary_hand":rect.position+Vector2(row.secondary_anchor[0],row.secondary_anchor[1])*rect.size,
		"core":rect.position+Vector2(row.core_anchor[0],row.core_anchor[1])*rect.size,
		"supports_two_hand":bool(row.supports_two_hand),"depth":str(row.draw_depth),
		"facing_support":str(row.facing),"wardrobe_requires":row.wardrobe_requires,
		"feet_baseline":float(row.feet_baseline),"weapon_types":row.get("weapon_types",[]),"weapon_overrides":{}}
	if not str(row.foreground_layer).is_empty() and ResourceLoader.exists(row.foreground_layer):
		result.foreground = load(row.foreground_layer)
	for id in row.weapon_overrides:
		var source: Dictionary = row.weapon_overrides[id]
		result.weapon_overrides[id] = {"size":Vector2(source.size[0],source.size[1]),
			"grip":Vector2(source.grip[0],source.grip[1]),"secondary_grip":Vector2(source.secondary_grip[0],source.secondary_grip[1]),
			"socket":Vector2(source.socket[0],source.socket[1]),"angle":float(source.angle),"held_path":str(source.held_path)}
	return result
