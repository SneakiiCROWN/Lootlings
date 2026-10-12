extends RefCounted
const UI=preload("res://lootlings_ui.gd")
const Type=preload("res://lootlings_typography.gd")
static func decorate(panel:Panel, title:String, subtitle:String, icon:String) -> void:
	UI.apply_material(panel,"leather")
	UI.add_icon(panel,Rect2(28,40,34,34),icon)
	var heading:=Label.new();heading.text=title;heading.position=Vector2(74,36);heading.size=Vector2(378,48);Type.label(heading,24);heading.add_theme_color_override("font_color",UI.GOLD_BRIGHT);panel.add_child(heading)
	var caption:=Label.new();caption.text=subtitle;caption.position=Vector2(28,92);caption.size=Vector2(424,34);Type.label(caption,15);caption.add_theme_color_override("font_color",UI.TEXT_MUTED);panel.add_child(caption)
static func inset(panel:Panel, rect:Rect2) -> void:
	var card:=Panel.new();card.position=rect.position;card.size=rect.size;card.mouse_filter=Control.MOUSE_FILTER_IGNORE
	card.add_theme_stylebox_override("panel",Type.control_surface(Color("#0b1929e8"),Color("#52617a"),12));panel.add_child(card)
static func button(control:Button, primary:bool=false) -> void:
	control.set_meta("ui_intent","primary" if primary else "secondary");UI.apply_button(control,UI.NAVY,UI.GOLD)
