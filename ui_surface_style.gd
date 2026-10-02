extends StyleBox

# Supplied 2x production textures, not generated chrome. Draw the nine-patch
# in source-pixel space so protected caps stay intact at portrait phone scale.
var texture: Texture2D
var protected_margin := Vector2(32, 32)
var ornament: Texture2D
var compact_texture: Texture2D
var source_scale := 0.5
var tint := Color.WHITE

func _draw(canvas: RID, rect: Rect2) -> void:
	if texture == null or rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var scale := .25 if compact_texture != null and rect.size.y < 160 else source_scale
	var transform := Transform2D(Vector2(scale, 0), Vector2(0, scale), Vector2.ZERO)
	var active := compact_texture if compact_texture != null and rect.size.y < 160 else texture
	var margin := Vector2(64,48) if active == compact_texture else protected_margin
	margin.y = minf(margin.y, maxf(1.0,rect.size.y / scale * .5 - 1.0))
	margin.x = minf(margin.x, maxf(1.0,rect.size.x / scale * .5 - 1.0))
	RenderingServer.canvas_item_add_set_transform(canvas, transform)
	RenderingServer.canvas_item_add_nine_patch(canvas, Rect2(rect.position / scale, rect.size / scale), Rect2(Vector2.ZERO, active.get_size()), active.get_rid(), margin, margin, RenderingServer.NINE_PATCH_STRETCH, RenderingServer.NINE_PATCH_STRETCH, true, tint)
	RenderingServer.canvas_item_add_set_transform(canvas, Transform2D.IDENTITY)
	if ornament != null and rect.size.x >= 200 and rect.size.y >= 70:
		var width := minf(240.0, rect.size.x - 52.0)
		var center_x := rect.get_center().x - width * 0.5
		RenderingServer.canvas_item_add_texture_rect(canvas, Rect2(center_x, rect.position.y + 2, width, 13), ornament.get_rid(), false, Color.WHITE)
		RenderingServer.canvas_item_add_texture_rect(canvas, Rect2(center_x, rect.end.y - 14, width, 13), ornament.get_rid(), false, Color.WHITE)
