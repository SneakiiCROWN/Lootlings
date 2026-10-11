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
	control.theme = shared_theme

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
