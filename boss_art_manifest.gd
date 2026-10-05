extends RefCounted
# Approved full-frame exports only. Empty delivery leaves existing art untouched.
const PATH := "res://art/production_boss_manifest.json"
const Patterns = preload("res://boss_patterns.gd")
static var entries: Array = []
static var initialized := false

static func rows() -> Array:
	if not initialized:
		initialized=true
		var data: Variant=JSON.parse_string(FileAccess.get_file_as_string(PATH))
		if data is Dictionary: entries=data.get("entries",[])
	return entries

static func select_frame(region: String, state: String, action: String, facing: int) -> Dictionary:
	for row in rows():
		if not valid(row): continue
		if row.region!=region or row.state!=state or row.action!=action: continue
		if row.facing!=("left" if facing<0 else "right"): continue
		return row
	return {}

static func valid(row: Dictionary) -> bool:
	if row.get("production_status","")!="owner_approved_beta" or str(row.get("owner_approval","")).is_empty(): return false
	if not Patterns.PATTERNS.has(row.get("region","")): return false
	if row.get("state","") not in ["idle","windup","commit","hurt","recovery","defeat"]: return false
	if row.get("facing","") not in ["left","right"]: return false
	var path: String=str(row.get("asset_path",""))
	if not path.begins_with("res://art/sprites/enemies/approved/") or ".." in path or not path.ends_with(".png"): return false
	if not ResourceLoader.exists(path): return false
	if str(row.get("source_reference","")).contains("phase4e_handoff"): return false
	if str(row.get("source_sha256","")).length()!=64 or str(row.get("asset_sha256","")).length()!=64: return false
	var anchor: Variant=row.get("anchor",[])
	if not anchor is Array or anchor.size()!=2: return false
	for value in anchor:
		if not (value is float or value is int) or not is_finite(float(value)) or float(value)<0 or float(value)>1: return false
	var action: String=str(row.get("action",""))
	return action in Patterns.PATTERNS[row.region].calls if row.state in ["windup","commit"] else action.is_empty()

static func state_for(g) -> Dictionary:
	if not g.enemy_alive: return {"state":"defeat","action":""}
	if g.enemy_flash>0: return {"state":"hurt","action":""}
	if g.boss_recovery>0: return {"state":"recovery","action":""}
	if g.combat_presentation.boss_action_time>0:
		var action: String=g.combat_presentation.boss_action
		if action in ["RECOVER","COOLING"]: return {"state":"recovery","action":""}
		return {"state":"commit","action":action}
	var cue: Dictionary=preload("res://combat_presentation.gd").attack_cue(g)
	if cue.visible: return {"state":"windup","action":str(Patterns.next(g).text)}
	return {"state":"idle","action":""}
