extends RefCounted
# Accepted Sera neutral body; owner-approved Patch/Ilex station illustrations.
# Station illustrations remain illustrations, not transparent body exports.
const IDS={"Salvager":"patch","Relic Keeper":"sera","Archivist":"ilex"}
const BODIES={
	"patch":preload("res://art/production/phase4e/npcs/patch_canonical_station_panel.png"),
	"sera":preload("res://art/sprites/npcs/beta/sera_idle.png"),
	"ilex":preload("res://art/production/phase4e/npcs/ilex_canonical_station_panel.png")}
static func portrait_path(id: String) -> String:
	return BODIES[id].resource_path if id in ["patch","ilex"] else "res://art/sprites/npcs/beta/%s_portrait.png" % id
static var authored_entries: Array=[]
static var authored_loaded:=false
static var authored_textures: Dictionary={}
static func body_frame(id: String, state: String, facing: String="left") -> Dictionary:
	if not authored_loaded:
		authored_loaded=true
		var data=JSON.parse_string(FileAccess.get_file_as_string("res://art/production_npc_manifest.json"))
		if data is Dictionary:authored_entries=data.get("entries",[])
	for row in authored_entries:
		if row.actor!=id or row.state!=state or row.facing!=facing:continue
		var accepted: bool=row.get("native_validated",false) and row.get("production_status","")=="canon_validated_runtime"
		var preview: bool=OS.get_environment("LOOTLINGS_QA")=="1" and OS.get_environment("LOOTLINGS_QA_NPC_PREVIEW")=="1"
		if not accepted and not preview:continue
		var path: String=row.asset_path
		if not (path.begins_with("res://art/production/phase4e/npcs/") or id=="sera" and path=="res://art/sprites/npcs/beta/sera_idle.png") or ".." in path:continue
		if not authored_textures.has(path):
			var region: Array=row.content_rect
			var atlas:=AtlasTexture.new();atlas.atlas=load(path);atlas.region=Rect2(region[0],region[1],region[2],region[3]);authored_textures[path]=atlas
		return {"texture":authored_textures[path],"row":row}
	return {}
static func has_body(speaker: String) -> bool:
	return IDS.has(speaker) and (not body_frame(IDS[speaker],"rest").is_empty() or not body_frame(IDS[speaker],"rest","right").is_empty())
static func presentation(speaker: String, bounds: Rect2, activity: String="rest", facing: String="left") -> Dictionary:
	if not IDS.has(speaker):return {}
	var id: String=IDS[speaker]
	var neutral:=body_frame(id,"rest",facing)
	if neutral.is_empty():
		facing="right";neutral=body_frame(id,"rest",facing)
	if not neutral.is_empty():
		var state: String="talk" if activity=="talk" else "inspect" if activity in ["inspect","read"] else "rest"
		var chosen:=body_frame(id,state,facing)
		if chosen.is_empty():chosen=neutral;state="rest"
		var row: Dictionary=chosen.row
		var rest_rect: Array=neutral.row.content_rect
		var scale: float=minf(bounds.size.y/rest_rect[3],bounds.size.x/rest_rect[2])
		var region: Array=row.content_rect
		var extent:=Vector2(region[2],region[3])*scale
		var ground:=Vector2(bounds.get_center().x,bounds.end.y)
		var position:=ground+Vector2(region[0]-row.pivot[0],region[1]-row.pivot[1])*scale
		return {"id":id,"texture":chosen.texture,"rect":Rect2(position,extent),"export_state":state,"facing":facing,"activity_states":"Authored rest/inspect/talk both views; route/work/sit remain missing","full_body":true}
	var texture: Texture2D=BODIES[IDS[speaker]]
	var extent: Vector2=texture.get_size()*minf(bounds.size.x/texture.get_width(),bounds.size.y/texture.get_height())
	var panel: bool=IDS[speaker] in ["patch","ilex"]
	return {"id":IDS[speaker],"texture":texture,"rect":Rect2(Vector2(bounds.get_center().x-extent.x*.5,bounds.end.y-extent.y),extent),"export_state":"canonical_station_panel" if panel else "idle","activity_states":"NEEDS_NEW_CANON_EXPORT: transparent full-body states" if panel else "TEMP: authored route/work/inspect/talk/sit exports pending"}
static func draw(home, speaker: String, bounds: Rect2, activity: String="rest", facing: String="left") -> void:
	var entry:=presentation(speaker,bounds,activity,facing)
	if entry.is_empty():return
	home.draw_set_transform(Vector2.ZERO)
	if entry.export_state=="canonical_station_panel":
		# An intentional, consistently framed service plaque replaces the pasted
		# rectangular artwork masquerading as a standing resident. Source intact.
		var UI=preload("res://lootlings_ui.gd")
		home.draw_style_box(UI.material_style("leather"),bounds)
		var image_bounds:=Rect2(bounds.position+Vector2(9,9),Vector2(bounds.size.x-18,bounds.size.y-42))
		UI.draw_icon(home.get_canvas_item(),entry.texture,image_bounds)
		var caption: String="PATCH" if entry.id=="patch" else "ILEX"
		home.draw_string(ThemeDB.fallback_font,Vector2(bounds.position.x+6,bounds.end.y-24),caption,HORIZONTAL_ALIGNMENT_CENTER,bounds.size.x-12,11,Color("#ffe3ac"))
		home.draw_string(ThemeDB.fallback_font,Vector2(bounds.position.x+6,bounds.end.y-11),"FORGE" if entry.id=="patch" else "NOTES",HORIZONTAL_ALIGNMENT_CENTER,bounds.size.x-12,9,Color("#dcb973"))
	else:
		if entry.get("full_body",false) and not home.get_parent().audio_settings.get("cinematic_reduced_motion",false):
			var ground:=Vector2(bounds.get_center().x,bounds.end.y)
			var breathe: float=1.0+sin(home.scene_time*1.65+(.7 if entry.id=="patch" else 2.1))*.003
			home.draw_set_transform(ground,0,Vector2(1,breathe))
			home.draw_texture_rect(entry.texture,Rect2(entry.rect.position-ground,entry.rect.size),false,Color.WHITE)
			home.draw_set_transform(Vector2.ZERO)
		else:home.draw_texture_rect(entry.texture,entry.rect,false,Color.WHITE)
