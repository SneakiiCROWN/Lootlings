extends Control
# A thin cooldown track with no theme/font minimum size.
var value:=0.0:
	set(next): value=next;queue_redraw()
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color("#071324"))
	draw_rect(Rect2(Vector2.ZERO,Vector2(size.x*clampf(value,0,1),size.y)),Color("#edc878"))
