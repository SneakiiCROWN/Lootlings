extends StyleBox

# UI surface treatment only: no invented illustrations, item icons or faux
# painted textures. Production nine-slice art can replace this StyleBox later.
var fill := Color("#101626")
var edge := Color("#b89b66")
var cut := 10.0
var recessed := false
var muted := false
var shadow := true

func _draw(canvas: RID, rect: Rect2) -> void:
	if rect.size.x < 2.0 or rect.size.y < 2.0:
		return
	var bevel := minf(cut, minf(rect.size.x, rect.size.y) * 0.22)
	if shadow:
		RenderingServer.canvas_item_add_polygon(canvas, outline(Rect2(rect.position + Vector2(0, 5), rect.size).grow(3), bevel + 3), PackedColorArray([Color(0.01, 0.02, 0.04, 0.32)]))
		RenderingServer.canvas_item_add_polygon(canvas, outline(Rect2(rect.position + Vector2(0, 3), rect.size), bevel), PackedColorArray([Color(0.01, 0.02, 0.04, 0.55)]))
	var rim_top := edge.lightened(0.18) if not muted else edge
	var rim_bottom := edge.darkened(0.58)
	RenderingServer.canvas_item_add_polygon(canvas, outline(rect, bevel), vertical_colors(rim_top, rim_bottom))
	var inset := rect.grow(-1.5)
	RenderingServer.canvas_item_add_polygon(canvas, outline(inset, maxf(1.0, bevel - 1.5)), PackedColorArray([Color("#030813")]))
	var surface := rect.grow(-3)
	var upper := fill.lightened(0.12) if not recessed else fill.darkened(0.10)
	var lower := fill.darkened(0.42) if not recessed else fill
	RenderingServer.canvas_item_add_polygon(canvas, outline(surface, maxf(1.0, bevel - 3)), vertical_colors(upper, lower))
	var shine := Color(edge, 0.46 if not muted else 0.12)
	RenderingServer.canvas_item_add_line(canvas, Vector2(rect.position.x + bevel + 4, rect.position.y + 4), Vector2(rect.end.x - bevel - 4, rect.position.y + 4), shine, 1.0, true)
	RenderingServer.canvas_item_add_line(canvas, Vector2(rect.position.x + bevel + 4, rect.end.y - 4), Vector2(rect.end.x - bevel - 4, rect.end.y - 4), Color(0, 0, 0, 0.38), 1.0, true)

static func outline(rect: Rect2, bevel: float) -> PackedVector2Array:
	var p := rect.position
	var e := rect.end
	return PackedVector2Array([Vector2(p.x + bevel, p.y), Vector2(e.x - bevel, p.y), Vector2(e.x, p.y + bevel), Vector2(e.x, e.y - bevel), Vector2(e.x - bevel, e.y), Vector2(p.x + bevel, e.y), Vector2(p.x, e.y - bevel), Vector2(p.x, p.y + bevel)])

static func vertical_colors(top: Color, bottom: Color) -> PackedColorArray:
	return PackedColorArray([top, top, top, bottom, bottom, bottom, bottom, top])
