extends RefCounted
# Asset manifest adapter for the existing WeaponFit registration system.
const PATH := "res://art/production_pose_manifest.json"
static var entries: Array = []
static var initialized := false
static var extracted_rows: Array = []
static var extracted_loaded := false
static var extracted_resolved := {}

static func extracted_phase(actor: String, subtype: String, phase: String, facing: float, clock: float = 0.0) -> Dictionary:
	if not extracted_loaded:
		extracted_loaded = true
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://art/production/phase4e/runtime_manifest.json"))
		if data is Dictionary: extracted_rows = data.get("entries",[])
		var reuse: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://art/production/phase4e/reuse_manifest.json"))
		if reuse is Dictionary: extracted_rows.append_array(reuse.get("entries",[]))
		var combat_batch_path := "res://art/production/phase4e/player_batch_043_manifest.json"
		if FileAccess.file_exists(combat_batch_path):
			var combat_batch: Variant = JSON.parse_string(FileAccess.get_file_as_string(combat_batch_path))
			if combat_batch is Dictionary:
				for row in combat_batch.get("entries",[]):
					if (row.get("native_validated",false) and row.get("production_status","")=="canon_validated_runtime") or OS.get_environment("LOOTLINGS_PLAYER_BATCH_PREVIEW")=="1": extracted_rows.append(row)
		var motion_path := "res://art/production/phase4e/player_motion_044_manifest.json"
		if FileAccess.file_exists(motion_path):
			var motion: Variant=JSON.parse_string(FileAccess.get_file_as_string(motion_path))
			if motion is Dictionary:
				for row in motion.get("entries",[]):
					if (row.get("native_validated",false) and row.get("production_status","")=="canon_validated_runtime") or (OS.get_environment("LOOTLINGS_QA")=="1" and OS.get_environment("LOOTLINGS_MOTION_BATCH_PREVIEW")=="1"):extracted_rows.append(row)
		var new_combat_path:="res://art/production/phase4e/player_combat_045_manifest.json"
		if FileAccess.file_exists(new_combat_path):
			var combat:Variant=JSON.parse_string(FileAccess.get_file_as_string(new_combat_path))
			if combat is Dictionary:
				for row in combat.get("entries",[]):
					if (row.get("native_validated",false) and row.get("production_status","")=="canon_validated_runtime") or (OS.get_environment("LOOTLINGS_QA")=="1" and OS.get_environment("LOOTLINGS_COMBAT_BATCH_PREVIEW")=="1"):extracted_rows.append(row)
		var heavy_path:="res://art/production/phase4e/player_combat_046_manifest.json"
		if FileAccess.file_exists(heavy_path):
			var heavy:Variant=JSON.parse_string(FileAccess.get_file_as_string(heavy_path))
			if heavy is Dictionary:
				for row in heavy.get("entries",[]):
					if (row.get("native_validated",false) and row.get("production_status","")=="canon_validated_runtime") or (OS.get_environment("LOOTLINGS_QA")=="1" and OS.get_environment("LOOTLINGS_COMBAT_BATCH_PREVIEW")=="1"):extracted_rows.append(row)
		var bow_slice: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://art/production/phase4e/lootlings/gloomlet/bow/bow_slice_manifest.json"))
		if bow_slice is Dictionary:
			for row in bow_slice.get("entries",[]):
				if row.get("native_validated",false) and row.get("production_status","")=="validated_beta_windup_only": extracted_rows.append(row)
	for row in extracted_rows:
		if not preload("res://actor_identity_corrections.gd").allowed(str(row.actor),str(row.asset_path)):continue
		if row.actor == actor and subtype in row.weapon_types and row.phase == phase and row.facing == ("left_only" if facing<0 else "right_only"):
			if int(row.get("frame_count",1))>1 and int(row.get("frame_index",0))!=posmod(int(floor(clock*float(row.get("fps",6)))),int(row.frame_count)):continue
			# Canvas commands retain RIDs, not this local Texture2D reference.
			# Keep source textures alive across frames, not just QA sampling.
			var cache_key:String=str(row.asset_path)+":"+subtype+":"+phase+":"+str(row.facing)
			if not extracted_resolved.has(cache_key):
				var result := resolve(row)
				result.baked_weapon = row.get("baked_weapon","")
				result.extracted_idle = phase == "IDLE"
				result.extracted_pose = true
				result.combat_batch_045=str(row.get("source","")).begins_with("art/source/player_combat_045/")
				result.combat_batch_046=str(row.get("source","")).begins_with("art/source/combat_continuation_046/")
				result.motion_phase = phase if phase in ["MOVE","VICTORY","DEFEAT"] else ""
				result.frame_index = int(row.get("frame_index",0))
				extracted_resolved[cache_key] = result
			return extracted_resolved[cache_key]
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
		if not preload("res://actor_identity_corrections.gd").allowed(str(row.actor),str(row.asset_path)):continue
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
	if not (path.begins_with("res://art/sprites/") or path.begins_with("res://art/production/phase4e/lootlings/") or path.begins_with("res://art/production/phase4e/wanderers/")) or ".." in path: return {}
	if not ResourceLoader.exists(str(row.asset_path)): return {}
	var rect := Rect2(Vector2(row.body_rect[0],row.body_rect[1]),Vector2(row.body_rect[2],row.body_rect[3]))
	var result := {"texture":load(str(row.asset_path)),"body_rect":rect,
		"primary_hand":rect.position+Vector2(row.primary_anchor[0],row.primary_anchor[1])*rect.size,
		"secondary_hand":rect.position+Vector2(row.secondary_anchor[0],row.secondary_anchor[1])*rect.size,
		"core":rect.position+Vector2(row.core_anchor[0],row.core_anchor[1])*rect.size,
		"supports_two_hand":bool(row.supports_two_hand),"depth":str(row.draw_depth),
		"facing_support":str(row.facing),"wardrobe_requires":row.wardrobe_requires,
		"feet_baseline":float(row.feet_baseline),"weapon_types":row.get("weapon_types",[]),"weapon_overrides":{}}
	result.bow_draw_contact = bool(row.get("bow_draw_contact",false))
	result.bow_primary_contact = bool(row.get("bow_primary_contact",false))
	result.bow_rest_angle = float(row.get("bow_rest_angle",.65))
	if not str(row.foreground_layer).is_empty() and ResourceLoader.exists(row.foreground_layer):
		result.foreground = load(row.foreground_layer)
	for id in row.weapon_overrides:
		var source: Dictionary = row.weapon_overrides[id]
		result.weapon_overrides[id] = {"size":Vector2(source.size[0],source.size[1]),
			"grip":Vector2(source.grip[0],source.grip[1]),"secondary_grip":Vector2(source.secondary_grip[0],source.secondary_grip[1]),
			"socket":Vector2(source.socket[0],source.socket[1]),"angle":float(source.angle),"held_path":str(source.held_path)}
	return result
