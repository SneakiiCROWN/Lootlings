extends RefCounted
# Licensed local fonts, shared by native Controls and immediate-mode world HUDs.
static var body_face: FontVariation
static var bold_face: FontVariation
static var display_face: FontVariation
static var shared_theme: Theme

static func body() -> Font:
	if body_face == null:
		body_face = FontVariation.new()
		body_face.base_font = preload("res://art/fonts/nunitosans.ttf")
		body_face.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"):600}
		body_face.fallbacks = [preload("res://art/fonts/notosanssymbols2.ttf"), ThemeDB.fallback_font]
	return body_face

static func bold() -> Font:
	if bold_face == null:
		bold_face = FontVariation.new()
		body()
		bold_face.base_font = body_face.base_font
		bold_face.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"):800}
		bold_face.fallbacks = body().fallbacks
	return bold_face

static func heading() -> Font:
	if display_face == null:
		display_face = FontVariation.new()
		display_face.base_font = preload("res://art/fonts/cinzel.ttf")
		display_face.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"):650}
		display_face.fallbacks = [body()]
	return display_face

static func install(control: Control) -> void:
	if shared_theme == null:
		shared_theme = Theme.new()
		shared_theme.default_font = body()
		shared_theme.default_font_size = 16
		shared_theme.set_font("normal_font", "RichTextLabel", body())
		shared_theme.set_font("bold_font", "RichTextLabel", bold())
		shared_theme.set_font("font", "Button", bold())
		shared_theme.set_font("font", "OptionButton", bold())
		install_controls(shared_theme)
	control.theme = shared_theme

static func control_surface(fill:Color, edge:Color, inset:float=10) -> StyleBoxFlat:
	var surface:=StyleBoxFlat.new()
	surface.bg_color=fill;surface.border_color=edge;surface.set_border_width_all(1);surface.set_corner_radius_all(7)
	surface.content_margin_left=inset;surface.content_margin_right=inset;surface.content_margin_top=6;surface.content_margin_bottom=6
	return surface

static func install_controls(theme:Theme) -> void:
	# Control-local overrides remain authoritative. Previously unstyled utility
	# controls now share the same quiet navy, gold and crystal vocabulary.
	for type in ["Button","OptionButton","CheckButton","CheckBox"]:
		for state in ["normal","hover","pressed","disabled"]:
			var fill:Color=Color("#172940") if state=="normal" else Color("#253e58") if state=="hover" else Color("#0e1b2c")
			var edge:Color=Color("#987f51") if state!="disabled" else Color("#394959")
			theme.set_stylebox(state,type,control_surface(fill,edge))
		var focus:=control_surface(Color.TRANSPARENT,Color("#9bd8ed"));focus.set_border_width_all(2)
		theme.set_stylebox("focus",type,focus)
		theme.set_color("font_color",type,Color("#e7edff"));theme.set_color("font_hover_color",type,Color("#fff1cb"));theme.set_color("font_disabled_color",type,Color("#9aa9bd"))
		theme.set_color("icon_normal_color",type,Color("#e3c38a"));theme.set_color("icon_hover_color",type,Color("#fff1cb"))
	theme.set_stylebox("panel","PopupMenu",control_surface(Color("#0e1d31"),Color("#b49a62"),12))
	theme.set_stylebox("hover","PopupMenu",control_surface(Color("#27445c"),Color("#7099b6"),8))
	theme.set_font("font","PopupMenu",body());theme.set_font_size("font_size","PopupMenu",17)
	theme.set_color("font_color","PopupMenu",Color("#e7edff"));theme.set_color("font_hover_color","PopupMenu",Color("#fff1cb"));theme.set_constant("v_separation","PopupMenu",12)
	for type in ["VScrollBar","HScrollBar"]:
		var track:=control_surface(Color("#0b1626"),Color("#293c52"),0);track.set_corner_radius_all(4)
		track.content_margin_left=6;track.content_margin_right=6;track.content_margin_top=6;track.content_margin_bottom=6
		theme.set_stylebox("scroll",type,track)
		for state in ["grabber","grabber_highlight","grabber_pressed"]:
			var grip:=control_surface(Color("#a68b59") if state=="grabber" else Color("#e3c38a"),Color("#d5bd83"),0);grip.set_corner_radius_all(4)
			grip.content_margin_left=6;grip.content_margin_right=6;grip.content_margin_top=12;grip.content_margin_bottom=12
			theme.set_stylebox(state,type,grip)
	for type in ["HSlider","VSlider"]:
		theme.set_stylebox("slider",type,control_surface(Color("#101e30"),Color("#536780"),3))
		theme.set_stylebox("grabber_area",type,control_surface(Color("#7b9fb4"),Color("#a9cddd"),3))
		theme.set_stylebox("grabber_area_highlight",type,control_surface(Color("#b59b63"),Color("#f0d18b"),3))

static func label(label: Label, preferred_size: int) -> void:
	var face:Font=heading() if preferred_size>=23 else body()
	label.add_theme_font_override("font",face)
	if preferred_size>=23 and not label.text.is_empty():
		var fitted:int=preferred_size
		while fitted>18 and face.get_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,fitted).x>label.size.x:fitted-=1
		label.add_theme_font_size_override("font_size",fitted)
	# WORD_SMART also splits an unusually long word, preserving the whole name.
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
