extends RefCounted
# Existing canonical resident idle exports, already used by their memory scenes.
# They are complete bodies, never pieces cut from a reference board.
const IDS={"Salvager":"patch","Relic Keeper":"sera","Archivist":"ilex"}
const BODIES={
	"patch":preload("res://art/sprites/npcs/beta/patch_idle.png"),
	"sera":preload("res://art/sprites/npcs/beta/sera_idle.png"),
	"ilex":preload("res://art/sprites/npcs/beta/ilex_idle.png")}
static func presentation(speaker: String, bounds: Rect2) -> Dictionary:
	if not IDS.has(speaker):return {}
	var texture: Texture2D=BODIES[IDS[speaker]]
	var extent: Vector2=texture.get_size()*minf(bounds.size.x/texture.get_width(),bounds.size.y/texture.get_height())
	return {"id":IDS[speaker],"texture":texture,"rect":Rect2(Vector2(bounds.get_center().x-extent.x*.5,bounds.end.y-extent.y),extent),"export_state":"idle","activity_states":"TEMP: authored route/work/inspect/talk/sit exports pending"}
static func draw(home, speaker: String, bounds: Rect2) -> void:
	var entry:=presentation(speaker,bounds)
	if entry.is_empty():return
	home.draw_set_transform(Vector2.ZERO)
	home.draw_texture_rect(entry.texture,entry.rect,false,Color.WHITE)
