extends Control
# A genuinely thin meter; the platform ProgressBar's font minimum must not
# inflate an eight-unit track into a solid block on a portrait phone.
var max_value:=288.0
var value:=0.0:
	set(next): value=next; queue_redraw()
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
	draw_style_box(preload("res://relic_spin_catalog.gd").flat_style(Color("#192238"),Color("#8c5664"),3),Rect2(Vector2.ZERO,size))
	var ratio:=clampf(value/maxf(1,max_value),0,1)
	if ratio>0:
		draw_style_box(preload("res://relic_spin_catalog.gd").flat_style(Color("#de526b"),Color("#de526b"),3),Rect2(Vector2.ZERO,Vector2(size.x*ratio,size.y)))
