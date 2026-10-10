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
const ARMOUR_IDS := ["mossguard_harness", "ironpaw_plate", "ruinweave_coat", "dragon_scale_patch", "patchplate_vest", "coin_stitch_coat", "thorn_receipt", "last_page", "second_skin", "warden_warranty", "scarlet_margin", "keeper_coat"]
const RUNE_GLYPHS := {
	"ember_pop":"rune_fire",
	"stormspark":"rune_lightning", "storm_ledger":"rune_lightning", "threefold_ink":"rune_lightning", "critical_script":"rune_lightning",
	"toxic_burst":"rune_poison", "mire_rune":"rune_poison", "shelter_script":"rune_poison",
	"winter_clause":"rune_frost", "frostbell_seal":"rune_frost",
}
const CANON_RELIC_ART := {
	"promise_bubble":"ward_orbit", "safe_aperture":"ward_orbit",
	"marsh_promise":"verdant_amulet", "receipt_ring":"obsidian_ring",
	"gilded_debt":"azure_ring",
	"coffer_key":"treasure_key", "courier_appetite":"treasure_key",
	"siege_receipt":"recipe_scroll",
}
const CANON_RUNE_ART := {"echo_invoice":"fault_seal", "fault_script":"fault_seal"}

const NAVY := Color("#0b1430")
const NAVY_DEEP := Color("#071027")
const GOLD := Color("#d1a85a")
const GOLD_BRIGHT := Color("#ffe178")
const TEXT := Color("#e7edff")
const TEXT_MUTED := Color("#9fb3d8")
const WORDMARK = preload("res://art/ui/brand/lootlings_wordmark.png")
static var skin_cache: Dictionary = {}
static var icon_cache: Dictionary = {}

static var item_region_cache: Dictionary={}
static func framed_item_texture(texture: Texture2D) -> Texture2D:
	if texture==null or texture is AtlasTexture:return texture
	var key:int=texture.get_instance_id()
	if item_region_cache.has(key):return item_region_cache[key]
	var image:=texture.get_image()
	if image==null or image.is_empty():return texture
	var used:=image.get_used_rect()
	if used.size.x<1 or used.size.y<1:return texture
	var padded:=used.grow(2).intersection(Rect2i(Vector2i.ZERO,image.get_size()))
	var atlas:=AtlasTexture.new();atlas.atlas=texture;atlas.region=Rect2(padded)
	item_region_cache[key]=atlas
	return atlas

static func item_texture(item: Dictionary) -> Texture2D:
	return framed_item_texture(raw_item_texture(item))

static func raw_item_texture(item: Dictionary) -> Texture2D:
	var mythical: Texture2D=preload("res://mythical_collection.gd").texture(str(item.get("id","")))
	if mythical!=null:return mythical
	if item.get("slot", "") == "Weapon":
		var family := str(item.get("family", "VANGUARD"))
		var fallback_path: String = {"RANGER":"ranger_bow", "MAGE":"mage_staff", "ROGUE":"rogue_daggers"}.get(family, "vanguard_hammer")
		var type := str(item.get("weapon_type", ""))
		var stage := int(item.get("evolution_stage", 0))
		var held := WeaponArt.runtime_texture(type, icon("res://art/sprites/weapons/%s.png" % fallback_path), stage)
		return WeaponArt.presentation_texture(type,"inventory",held,stage)
	var id := str(item.get("id", ""))
	var named:Texture2D=preload("res://named_item_art.gd").texture(id)
	if named!=null:return named
	if item.get("slot", "") == "Armour" and id in ARMOUR_IDS:
		var path := "res://art/production/phase4e/items/armour_inventory_v1/%s.png" % id
		if ResourceLoader.exists(path): return icon(path)
	if str(item.get("slot",""))=="Relic" and CANON_RELIC_ART.has(id): return icon("res://art/production/phase4e/items/%s.png" % CANON_RELIC_ART[id])
	if str(item.get("slot",""))=="Rune" and CANON_RUNE_ART.has(id): return icon("res://art/production/phase4e/items/%s.png" % CANON_RUNE_ART[id])
	if ITEM_ART.has(id):
		return icon("res://art/sprites/items/beta/%s.png" % ITEM_ART[id])
	if str(item.get("slot",""))=="Rune" and RUNE_GLYPHS.has(id): return icon(RUNE_GLYPHS[id])
	var slot := str(item.get("slot", "Relic"))
	if slot=="Rune": return icon("rune_arcane")
	return icon("gear_%s" % ("armour" if slot == "Armour" else "rune" if slot == "Rune" else "charm"))

static func icon(name: String) -> Texture2D:
	var path := name if name.begins_with("res://") else "res://art/ui/icons/%s.png" % name
	if name in ["currency_gold","currency_star_shard"]: path="res://art/production/phase4e/items/%s.png" % ("gold_hoard" if name=="currency_gold" else "star_shards")
	if name in ["core_fire","core_lightning","gear_rune","rune_fire","rune_frost","rune_poison","rune_lightning","rune_arcane"]: path="res://art/production/phase4e/hud/"+name+".png"
	if not icon_cache.has(path):
		icon_cache[path] = load(path)
	return icon_cache[path]

static func draw_icon(canvas: RID, texture: Texture2D, rect: Rect2) -> void:
	if texture == null:
		return
	var extent := texture.get_size() * minf(rect.size.x / texture.get_width(), rect.size.y / texture.get_height())
	var target := Rect2(rect.get_center() - extent * 0.5, extent)
	if texture is AtlasTexture:
		RenderingServer.canvas_item_add_texture_rect_region(canvas, target, texture.atlas.get_rid(), texture.region, Color.WHITE)
	else:
		RenderingServer.canvas_item_add_texture_rect(canvas, target, texture.get_rid(), false, Color.WHITE)

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
	return "[img=%dx%d]%s[/img]" % [extent, extent, icon(name).resource_path]

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
		if filename.begins_with("panel_") and filename != "panel_danger_9slice":
			box.texture = load("res://art/ui/production/%s.png" % ("relic" if filename == "panel_relic_9slice" else "panel"))
			box.protected_margin = Vector2(96,96)
			box.source_scale = .333333
			box.compact_texture = load("res://art/ui/production/hud.png")
			box.ornament = null
		elif filename.begins_with("hud_"):
			box.texture = load("res://art/ui/production/hud.png")
			box.protected_margin = Vector2(96,48)
			if filename == "hud_build_ribbon_9slice": box.source_scale = .25
			box.ornament = null
		elif filename.begins_with("button_"):
			var pieces := filename.split("_")
			box.texture = load("res://art/ui/production/button_%s.png" % pieces[1])
			box.protected_margin = Vector2(64,16)
			box.source_scale = .4
			box.tint = {"normal":Color.WHITE,"hover":Color(1.1,1.1,1.1),"focus":Color(1.16,1.16,1.16),
				"pressed":Color(.76,.76,.8),"disabled":Color(.48,.48,.55,.88)}.get(pieces[2],Color.WHITE)
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
	if intent in ["utility", "secondary"]:
		var box := StyleBoxFlat.new()
		box.bg_color = Color({"normal":"#192944","hover":"#2b4264","pressed":"#111d32","disabled":"#101827","focus":"#243957"}.get(state_name,"#192944"))
		box.border_color = Color("#49678e") if intent == "secondary" else Color("#7087ae")
		if state_name == "disabled": box.border_color=Color("#35445b")
		elif state_name == "focus": box.border_color=Color("#d1dff6")
		box.set_border_width_all(2 if intent == "secondary" else 1)
		box.set_corner_radius_all(10)
		box.content_margin_left = 8
		box.content_margin_right = 8
		return box
	return skin_style("button_%s_%s" % [intent, state_name], 24)

static func apply_button(button: Button, fill: Color, border: Color) -> void:
	var intent := str(button.get_meta("ui_intent", "secondary"))
	var action := button.text.to_upper()
	if action.begins_with("SCRAP") or action in ["ABANDON RUN", "RETURN HOME"]:
		intent = "destructive"
	elif not button.has_meta("ui_intent") and (action.begins_with("EQUIP") or action.begins_with("SAVE") or action.begins_with("CHOOSE") or action in ["ENTER THE HIDEOUT", "TAP TO BEGIN", "CONTINUE", "RESUME", "UPGRADE", "RETURN TO HIDEOUT", "TAP TO OPEN\nHOARD CHEST"]):
		intent = "primary"
	elif not button.has_meta("ui_intent") and (button.size.y <= 54 or action in ["PROFILE","TITLE","SETTINGS","DONE","ALL","STORY & MOTION"] or action.begins_with("‹")):
		intent = "utility"
	for state_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state_name, button_style(fill, border, state_name, intent))
	button.add_theme_color_override("font_disabled_color", Color("#a0a6b3"))
	button.add_theme_color_override("font_color", Color("#edf0f7"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color("#fff1cd"))
	button.add_theme_color_override("font_shadow_color", Color("#030812"))
	button.add_theme_constant_override("shadow_offset_y", 1)

static func meter_inner(rect: Rect2) -> Rect2:
	# A four-unit XP track must keep a visible fill instead of shrinking to zero.
	var inset:=Vector2(minf(2,rect.size.x*.25),minf(2,maxf(0,(rect.size.y-2)*.5)))
	return Rect2(rect.position+inset,rect.size-inset*2)

static func fitted_font_size(font: Font, text: String, width: float, preferred: int, minimum: int) -> int:
	var size:=preferred
	while size>minimum and font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x>width:
		size-=1
	return size

static func draw_meter(canvas: RID, rect: Rect2, ratio: float, kind: String, trail_ratio: float = -1.0) -> void:
	var cap := 18.0 if kind == "xp" else 22.0 if kind == "enemy" else 26.0
	var frame := skin_style("bar_%s_frame" % kind, cap, 0)
	var fill := skin_style("bar_%s_fill" % kind, cap, 0)
	frame.draw(canvas, rect)
	var inner := meter_inner(rect)
	var width := inner.size.x * clampf(ratio, 0.0, 1.0)
	var trail_width := inner.size.x * clampf(trail_ratio, 0.0, 1.0)
	if trail_width > width:
		RenderingServer.canvas_item_add_rect(canvas, Rect2(inner.position + Vector2(width, 0), Vector2(trail_width - width, inner.size.y)), Color("#f0ba6880"))
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

static func apply_rarity_card(button: Button, accent: Color) -> void:
	button.set_meta("rarity_accent", accent)
	apply_selection(button, bool(button.get_meta("ui_selected", false)))

static func rarity_card_style(accent: Color, state_name: String) -> StyleBox:
	# Approved cool crystal frame for all unselected gear/reward cards;
	# warm primary frame remains the persistent selected state.
	# Duplicate script fields so rarity tint never contaminates the shared cache.
	var source := skin_style("button_secondary_"+state_name,24)
	var box := inset_style(source,source.content_margin_left) as TextureSkin
	var rarity_tint := Color.WHITE.lerp(accent,.08)
	box.tint *= rarity_tint
	if state_name == "normal": box.tint *= Color(.88,.92,.98)
	return box

static func apply_selection(button: Button, selected: bool) -> void:
	# Preserve card typography/transparent semantic text; change skins only.
	button.set_meta("ui_selected",selected)
	if button.size.x >= 180 and button.size.y >= 56:
		var mark := button.get_node_or_null("SelectionMark") as Label
		if mark == null:
			mark=Label.new();mark.name="SelectionMark";mark.text="✓"
			mark.mouse_filter=Control.MOUSE_FILTER_IGNORE
			mark.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
			mark.add_theme_font_size_override("font_size",18)
			mark.add_theme_color_override("font_color",GOLD_BRIGHT)
			mark.add_theme_color_override("font_outline_color",NAVY_DEEP)
			mark.add_theme_constant_override("outline_size",3)
			button.add_child(mark)
		mark.position=Vector2(button.size.x-46,6);mark.size=Vector2(24,24)
		mark.visible=selected
	button.set_meta("ui_intent","primary" if selected else "secondary")
	for state_name in ["normal","hover","pressed","disabled"]:
		var style := button_style(Color.WHITE,Color.WHITE,state_name,"primary" if selected else "secondary")
		if not selected and button.has_meta("rarity_accent"):
			style = rarity_card_style(button.get_meta("rarity_accent"), state_name)
		if button.has_meta("card_text_inset"):
			style = inset_style(style,float(button.get_meta("card_text_inset")))
		button.add_theme_stylebox_override(state_name, style)
	var focus:=StyleBoxFlat.new();focus.bg_color=Color.TRANSPARENT;focus.border_color=Color("#d1dff6")
	focus.set_border_width_all(2);focus.set_corner_radius_all(10)
	button.add_theme_stylebox_override("focus",focus)

static func inset_style(original: StyleBox, left: float) -> StyleBox:
	var style := original.duplicate() as StyleBox
	# Script-backed nine-patch fields are not exported Resource properties.
	if original is TextureSkin:
		for property in ["texture","protected_margin","ornament","compact_texture","source_scale","tint"]:
			style.set(property,original.get(property))
	style.content_margin_left=left
	return style
