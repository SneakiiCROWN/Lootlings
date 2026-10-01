extends RefCounted

const SurfaceStyle = preload("res://ui_surface_style.gd")

const NAVY := Color("#0b1430")
const NAVY_DEEP := Color("#071027")
const GOLD := Color("#d1a85a")
const GOLD_BRIGHT := Color("#ffe178")
const TEXT := Color("#e7edff")
const TEXT_MUTED := Color("#9fb3d8")
const MATERIALS := {
	"relic":{"fill":Color("#211735"), "edge":Color("#a786d1")},
	"salvage":{"fill":Color("#28221b"), "edge":Color("#bd955e")},
	"leather":{"fill":Color("#201e29"), "edge":Color("#ae906c")},
	"hoard":{"fill":Color("#232137"), "edge":Color("#e4bd66")},
	"danger":{"fill":Color("#2d1c25"), "edge":Color("#cf7882")}
}

static func panel_style(fill: Color = NAVY, border: Color = GOLD, radius: int = 20) -> StyleBox:
	var box := SurfaceStyle.new()
	box.fill = Color(fill, maxf(0.94, fill.a))
	box.edge = border
	box.cut = clampf(radius * 0.65, 6.0, 14.0)
	return box

static func material_style(material: String, radius: int = 20) -> StyleBox:
	var palette: Dictionary = MATERIALS.get(material, MATERIALS.leather)
	var box := panel_style(palette.fill, palette.edge, radius)
	box.content_margin_left = 4
	box.content_margin_right = 4
	box.content_margin_top = 4
	box.content_margin_bottom = 4
	return box

static func apply_material(panel: Control, material: String, radius: int = 20) -> void:
	panel.add_theme_stylebox_override("panel", material_style(material, radius))

static func button_style(fill: Color, border: Color, state_name: String = "normal") -> StyleBox:
	var box := SurfaceStyle.new()
	box.fill = Color(fill.lightened(0.14) if state_name in ["hover", "focus"] else fill.darkened(0.13) if state_name == "pressed" else fill.darkened(0.38) if state_name == "disabled" else fill, 1.0)
	box.edge = border.darkened(0.52) if state_name == "disabled" else border.lightened(0.18) if state_name in ["hover", "focus"] else border
	box.cut = 8.0
	box.recessed = state_name == "pressed"
	box.muted = state_name == "disabled"
	box.shadow = state_name != "pressed"
	box.content_margin_left = 16
	box.content_margin_right = 16
	return box

static func apply_button(button: Button, fill: Color, border: Color) -> void:
	for state_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state_name, button_style(fill, border, state_name))
	button.add_theme_color_override("font_disabled_color", Color("#77819a"))
	button.add_theme_color_override("font_color", Color("#edf0f7"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color("#fff1cd"))
	button.add_theme_color_override("font_shadow_color", Color("#030812"))
	button.add_theme_constant_override("shadow_offset_y", 1)

static func draw_meter(canvas: RID, rect: Rect2, ratio: float, fill: Color, edge: Color) -> void:
	RenderingServer.canvas_item_add_polygon(canvas, SurfaceStyle.outline(Rect2(rect.position + Vector2(0, 2), rect.size), 4), PackedColorArray([Color("#02050cc0")]))
	RenderingServer.canvas_item_add_polygon(canvas, SurfaceStyle.outline(rect, 4), SurfaceStyle.vertical_colors(edge, edge.darkened(0.50)))
	RenderingServer.canvas_item_add_polygon(canvas, SurfaceStyle.outline(rect.grow(-1.5), 3), PackedColorArray([Color("#080e1b")]))
	var width := (rect.size.x - 6) * clampf(ratio, 0.0, 1.0)
	if width > 1.0:
		var filled := Rect2(rect.position + Vector2(3, 3), Vector2(width, rect.size.y - 6))
		RenderingServer.canvas_item_add_polygon(canvas, SurfaceStyle.outline(filled, minf(2.0, width * 0.4)), SurfaceStyle.vertical_colors(fill.lightened(0.30), fill.darkened(0.32)))

static func apply_input(input: LineEdit) -> void:
	var inset := button_style(NAVY_DEEP, Color("#6b7190"), "pressed")
	inset.content_margin_left = 14
	inset.content_margin_right = 14
	input.add_theme_stylebox_override("normal", inset)
	input.add_theme_stylebox_override("focus", button_style(NAVY_DEEP, GOLD_BRIGHT, "focus"))
	input.add_theme_color_override("font_color", TEXT)
	input.add_theme_color_override("font_placeholder_color", TEXT_MUTED)
	input.add_theme_color_override("caret_color", GOLD_BRIGHT)
	input.add_theme_color_override("selection_color", Color("#554275"))
