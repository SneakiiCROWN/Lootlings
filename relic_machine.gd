extends Control
const UI=preload("res://lootlings_ui.gd")
var elapsed:=0.0
var rolling:=false
var reward_kind:=""
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE; set_process(false)
func wind_up() -> void:
	elapsed=0; rolling=true; set_process(true); queue_redraw()
func reveal(kind: String) -> void:
	reward_kind=kind; rolling=false; set_process(false); queue_redraw()
func _process(delta: float) -> void:
	elapsed+=delta; queue_redraw()
func _draw() -> void:
	var center:=size*.5
	draw_style_box(UI.panel_style(Color("#101527"),Color("#b99759"),14),Rect2(Vector2.ZERO,size))
	draw_arc(center,76,0,TAU,48,Color("#d8bd7b"),3)
	draw_arc(center,86,elapsed*5,elapsed*5+2.2,32,Color("#78e4ff"),3)
	for index in range(6):
		var point:=center+Vector2.RIGHT.rotated(index*TAU/6)*86
		draw_circle(point,4,Color("#d8bd7b"))
	var icons: Array[String]=["currency_scrap","currency_star_shard","gear_rune"]
	var icon_name: String=icons[int(elapsed*16)%3] if rolling else {"material":"currency_scrap","mastery":"currency_star_shard","blueprint":"gear_rune"}.get(reward_kind,"gear_charm")
	UI.draw_icon(get_canvas_item(),UI.icon(icon_name),Rect2(center-Vector2(34,34),Vector2(68,68)))
	draw_string(ThemeDB.fallback_font,Vector2(12,size.y-12),"RELIC ENGINE",HORIZONTAL_ALIGNMENT_CENTER,size.x-24,12,Color("#d8bd7b"))
