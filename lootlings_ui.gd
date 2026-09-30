extends RefCounted

const NAVY := Color("#0b1430")
const NAVY_DEEP := Color("#071027")
const GOLD := Color("#d1a85a")
const GOLD_BRIGHT := Color("#ffe178")
const TEXT := Color("#e7edff")
const TEXT_MUTED := Color("#9fb3d8")
const MATERIALS := {
	"relic":{"fill":Color("#171231f4"), "edge":Color("#b98cff"), "inner":Color("#63438e")},
	"salvage":{"fill":Color("#171821f4"), "edge":Color("#d3a45e"), "inner":Color("#6e4a2c")},
	"leather":{"fill":Color("#17192af4"), "edge":Color("#b99168"), "inner":Color("#55405c")},
	"hoard":{"fill":Color("#19152df8"), "edge":Color("#ffd36a"), "inner":Color("#8d6426")},
	"danger":{"fill":Color("#25152bf4"), "edge":Color("#ff8995"), "inner":Color("#823e52")}
}

static func panel_style(fill: Color = NAVY, border: Color = GOLD, radius: int = 20) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(3)
	box.set_corner_radius_all(radius)
	box.shadow_color = Color(0.01, 0.02, 0.07, 0.62)
	box.shadow_size = 12
	return box

static func material_style(material: String, radius: int = 20) -> StyleBoxFlat:
	var palette: Dictionary = MATERIALS.get(material, MATERIALS.leather)
	var box := panel_style(palette.fill, palette.edge, radius)
	box.set_border_width_all(3)
	box.border_width_top = 5
	box.shadow_color = Color(palette.inner.r, palette.inner.g, palette.inner.b, 0.30)
	box.shadow_size = 11
	box.content_margin_left = 4
	box.content_margin_right = 4
	box.content_margin_top = 4
	box.content_margin_bottom = 4
	return box

static func apply_material(panel: Control, material: String, radius: int = 20) -> void:
	panel.add_theme_stylebox_override("panel", material_style(material, radius))

static func button_style(fill: Color, border: Color, state_name: String = "normal") -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill.lightened(0.09) if state_name == "hover" else fill.darkened(0.12) if state_name == "pressed" else fill.darkened(0.28) if state_name == "disabled" else fill
	box.border_color = border.darkened(0.40) if state_name == "disabled" else border
	box.set_border_width_all(3 if state_name == "focus" else 2)
	box.set_corner_radius_all(16)
	box.content_margin_left = 14
	box.content_margin_right = 14
	box.shadow_color = Color(0.01, 0.02, 0.07, 0.52)
	box.shadow_size = 7
	return box

static func apply_button(button: Button, fill: Color, border: Color) -> void:
	for state_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state_name, button_style(fill, border, state_name))
	button.add_theme_color_override("font_disabled_color", Color("#77819a"))
