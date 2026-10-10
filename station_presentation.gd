extends RefCounted
# Original UI materials. Shared only by the stations that need this identity;
# no global theme replacement and no changes to prices, selection or gestures.
static func paper() -> StyleBoxFlat:
	var style:=StyleBoxFlat.new(); style.bg_color=Color("#cfbc98"); style.border_color=Color("#80664a"); style.set_border_width_all(2); style.set_corner_radius_all(5)
	style.shadow_color=Color("#090b1680"); style.shadow_size=4; style.shadow_offset=Vector2(0,3)
	return style
static func metal() -> StyleBoxFlat:
	var style:=StyleBoxFlat.new(); style.bg_color=Color("#16262ddf"); style.border_color=Color("#ac8c5b"); style.set_border_width_all(2); style.set_corner_radius_all(7)
	style.shadow_color=Color("#090b1680"); style.shadow_size=3
	return style
static func paper_button(button: Button) -> void:
	preload("res://lootlings_ui.gd").apply_rarity_card(button,Color("#d4ad65"))
