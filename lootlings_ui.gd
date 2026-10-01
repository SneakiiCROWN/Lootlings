extends RefCounted

const TextureSkin = preload("res://ui_surface_style.gd")
const WeaponArt = preload("res://weapon_catalog.gd")
const ITEM_ART := {
	"cursed_ring":"cursed_ring", "hoarders_locket":"hoard_locket",
	"relic_magnet_charm":"relic_orbit", "vault_receipt":"vault_scroll",
	"ember_pop":"ember_stone", "stormspark":"storm_crystal",
	"toxic_burst":"nature_pendant", "mire_rune":"nature_pendant",
	"ground_slam":"ember_stone", "bossbane_sigil":"ember_stone",
	"echo_rune":"storm_crystal",
}

const NAVY := Color("#0b1430")
const NAVY_DEEP := Color("#071027")
const GOLD := Color("#d1a85a")
const GOLD_BRIGHT := Color("#ffe178")
const TEXT := Color("#e7edff")
const TEXT_MUTED := Color("#9fb3d8")
const WORDMARK = preload("res://art/ui/brand/lootlings_wordmark.png")
static var skin_cache: Dictionary = {}
static var icon_cache: Dictionary = {}

static func item_texture(item: Dictionary) -> Texture2D:
	if item.get("slot", "") == "Weapon":
		var family := str(item.get("family", "VANGUARD"))
		var fallback_path: String = {"RANGER":"ranger_bow", "MAGE":"mage_staff", "ROGUE":"rogue_daggers"}.get(family, "vanguard_hammer")
		return WeaponArt.runtime_texture(str(item.get("weapon_type", "")), icon("res://art/sprites/weapons/%s.png" % fallback_path), int(item.get("evolution_stage", 0)))
	var id := str(item.get("id", ""))
	if ITEM_ART.has(id):
		return icon("res://art/sprites/items/beta/%s.png" % ITEM_ART[id])
	var slot := str(item.get("slot", "Relic"))
	return icon("gear_%s" % ("armour" if slot == "Armour" else "rune" if slot == "Rune" else "charm"))

static func icon(name: String) -> Texture2D:
	var path := name if name.begins_with("res://") else "res://art/ui/icons/%s.png" % name
	if not icon_cache.has(path):
		icon_cache[path] = load(path)
	return icon_cache[path]

static func draw_icon(canvas: RID, texture: Texture2D, rect: Rect2) -> void:
	var extent := texture.get_size() * minf(rect.size.x / texture.get_width(), rect.size.y / texture.get_height())
	RenderingServer.canvas_item_add_texture_rect(canvas, Rect2(rect.get_center() - extent * 0.5, extent), texture.get_rid(), false, Color.WHITE)

static func add_icon(parent: Control, rect: Rect2, name: String) -> TextureRect:
	var image := TextureRect.new()
	image.texture = icon(name)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.position = rect.position
	image.size = rect.size
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	return image

static func inline_icon(name: String, extent: int = 16) -> String:
	return "[img=%dx%d]res://art/ui/icons/%s.png[/img]" % [extent, extent, name]

static func rich_label(parent: Control, rect: Rect2, font_size: int, color: Color) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.position = rect.position
	label.size = rect.size
	label.bbcode_enabled = true
	label.scroll_active = false
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("normal_font_size", font_size)
	label.add_theme_color_override("default_color", color)
	parent.add_child(label)
	return label

static func skin_style(filename: String, protected_margin: float = 32.0, vertical_margin: float = -1.0) -> StyleBox:
	var key := "%s:%s:%s" % [filename, protected_margin, vertical_margin]
	if not skin_cache.has(key):
		var box := TextureSkin.new()
		var beta_path := "res://art/ui/beta/%s.png" % filename
		box.texture = load(beta_path if ResourceLoader.exists(beta_path) else "res://art/ui/skins/%s.png" % filename)
		if filename.begins_with("panel_") or filename.begins_with("hud_"):
			box.ornament = load("res://art/ui/beta/ornament_gold.png")
		box.protected_margin = Vector2(protected_margin, protected_margin if vertical_margin < 0 else vertical_margin)
		box.content_margin_left = 12
		box.content_margin_right = 12
		box.content_margin_top = 0
		box.content_margin_bottom = 0
		skin_cache[key] = box
	return skin_cache[key]

# Existing signatures remain compatible; color arguments no longer synthesize art.
static func panel_style(_fill: Color = NAVY, _border: Color = GOLD, _radius: int = 20) -> StyleBox:
	return material_style("leather")

static func material_style(material: String, _radius: int = 20) -> StyleBox:
	return skin_style("panel_%s_9slice" % material)

static func apply_material(panel: Control, material: String, radius: int = 20) -> void:
	panel.add_theme_stylebox_override("panel", material_style(material, radius))

static func button_style(_fill: Color, _border: Color, state_name: String = "normal", intent: String = "secondary") -> StyleBox:
	return skin_style("button_%s_%s" % [intent, state_name], 24)

static func apply_button(button: Button, fill: Color, border: Color) -> void:
	var intent := str(button.get_meta("ui_intent", "secondary"))
	var action := button.text.to_upper()
	if action.begins_with("SCRAP") or action in ["ABANDON RUN", "RETURN HOME"]:
		intent = "destructive"
	elif action.begins_with("EQUIP") or action.begins_with("SAVE") or action.begins_with("CHOOSE") or action in ["ENTER THE HIDEOUT", "TAP TO BEGIN", "CONTINUE", "RESUME", "UPGRADE", "RETURN TO HIDEOUT", "TAP TO OPEN\nHOARD CHEST"]:
		intent = "primary"
	for state_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state_name, button_style(fill, border, state_name, intent))
	button.add_theme_color_override("font_disabled_color", Color("#a0a6b3"))
	button.add_theme_color_override("font_color", Color("#edf0f7"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color("#fff1cd"))
	button.add_theme_color_override("font_shadow_color", Color("#030812"))
	button.add_theme_constant_override("shadow_offset_y", 1)

static func draw_meter(canvas: RID, rect: Rect2, ratio: float, kind: String) -> void:
	var cap := 18.0 if kind == "xp" else 22.0 if kind == "enemy" else 26.0
	var frame := skin_style("bar_%s_frame" % kind, cap, 0)
	var fill := skin_style("bar_%s_fill" % kind, cap, 0)
	frame.draw(canvas, rect)
	var inner := rect.grow(-2)
	var width := inner.size.x * clampf(ratio, 0.0, 1.0)
	if width > 0.0:
		fill.draw(canvas, Rect2(inner.position, Vector2(width, inner.size.y)))

static func apply_input(input: LineEdit) -> void:
	input.add_theme_stylebox_override("normal", skin_style("input_normal", 24))
	input.add_theme_stylebox_override("focus", skin_style("input_focus", 24))
	input.add_theme_color_override("font_color", TEXT)
	input.add_theme_color_override("font_placeholder_color", TEXT_MUTED)
	input.add_theme_color_override("caret_color", GOLD_BRIGHT)
	input.add_theme_color_override("selection_color", Color("#554275"))

static func add_wordmark(parent: Control, rect: Rect2) -> TextureRect:
	var image := TextureRect.new()
	image.texture = WORDMARK
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.position = rect.position
	image.size = rect.size
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	return image

static func add_divider(parent: Control, rect: Rect2, material: String) -> TextureRect:
	var image := TextureRect.new()
	image.texture = load("res://art/ui/skins/divider_%s.png" % material)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_SCALE
	image.position = rect.position
	image.size = rect.size
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	return image
