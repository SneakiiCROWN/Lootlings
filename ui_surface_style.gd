extends StyleBox

# Supplied 2x production textures, not generated chrome. Draw the nine-patch
# in source-pixel space so protected caps stay intact at portrait phone scale.
var texture: Texture2D
var protected_margin := Vector2(32, 32)
const SOURCE_SCALE := 0.5

func _draw(canvas: RID, rect: Rect2) -> void:
	if texture == null or rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var transform := Transform2D(Vector2(SOURCE_SCALE, 0), Vector2(0, SOURCE_SCALE), Vector2.ZERO)
	RenderingServer.canvas_item_add_set_transform(canvas, transform)
	RenderingServer.canvas_item_add_nine_patch(canvas, Rect2(rect.position / SOURCE_SCALE, rect.size / SOURCE_SCALE), Rect2(Vector2.ZERO, texture.get_size()), texture.get_rid(), protected_margin, protected_margin, RenderingServer.NINE_PATCH_STRETCH, RenderingServer.NINE_PATCH_STRETCH, true, Color.WHITE)
	RenderingServer.canvas_item_add_set_transform(canvas, Transform2D.IDENTITY)
