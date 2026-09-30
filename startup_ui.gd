extends Control

signal enter_hideout
signal profile_completed
signal profile_changed(profile: Dictionary)
signal settings_changed(settings: Dictionary)
signal ui_event(event_name: String)

const ProfileStore = preload("res://profile_store.gd")
const SettingsStore = preload("res://settings_store.gd")
const LootlingsUI = preload("res://lootlings_ui.gd")
const PresentationDirector = preload("res://presentation_director.gd")
const LootlingCatalog = preload("res://lootling_catalog.gd")
const MASCOT_TEXTURE = preload("res://art/sprites/relic_beast_base.png")
const BACKGROUND = preload("res://art/backgrounds/treasure_ruins_arena.png")

var profile := {}
var settings := {}
var profile_exists := false
var current_screen := "boot"
var boot_timer := 0.0
var scene_time := 0.0
var boot_content: Control
var title_content: Control
var profile_content: Control
var settings_content: Control
var lootling_content: Control
var name_edit: LineEdit
var nickname_edit: LineEdit
var profile_heading: Label
var profile_id_label: Label
var setting_sliders := {}
var setting_mutes := {}
var presentation

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	build_boot()
	build_title()
	build_profile()
	build_lootling_select()
	build_settings()
	presentation = PresentationDirector.new()
	add_child(presentation)
	presentation.bind_buttons(self)
	set_process(true)

func configure(profile_data: Dictionary, has_profile: bool, settings_data: Dictionary) -> void:
	profile = profile_data.duplicate(true)
	profile_exists = has_profile
	settings = settings_data.duplicate(true)
	refresh_profile()
	refresh_settings()
	show_boot()

func build_boot() -> void:
	boot_content = Control.new()
	boot_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(boot_content)
	var core := make_label(boot_content, "◇", 82, Rect2(160, 270, 160, 110), HORIZONTAL_ALIGNMENT_CENTER, Color("#c9a2ff"))
	core.name = "CoreGlyph"
	make_label(boot_content, "LOOTLINGS", 43, Rect2(30, 390, 420, 58), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	make_label(boot_content, "RELIC CORE AWAKENING", 14, Rect2(40, 448, 400, 30), HORIZONTAL_ALIGNMENT_CENTER, Color("#b9c9ee"))
	var skip := make_button(boot_content, "TAP TO BEGIN", Rect2(120, 696, 240, 58), Color("#142144dd"), Color("#d1a85a"), 16)
	skip.pressed.connect(skip_boot)

func build_title() -> void:
	title_content = Control.new()
	title_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title_content.visible = false
	add_child(title_content)
	make_label(title_content, "LOOTLINGS", 48, Rect2(24, 45, 432, 66), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	make_label(title_content, "RELICS. RUINS. RIDICULOUS WEAPONS.", 13, Rect2(30, 108, 420, 28), HORIZONTAL_ALIGNMENT_CENTER, Color("#d7e5ff"))
	var play := make_button(title_content, "ENTER THE HIDEOUT", Rect2(68, 596, 344, 76), Color("#6f4b1fef"), Color("#ffda72"), 21)
	play.pressed.connect(request_play)
	var profile_button := make_button(title_content, "PROFILE", Rect2(68, 692, 160, 62), Color("#17294be8"), Color("#72c8ff"), 17)
	profile_button.pressed.connect(func(): ui_event.emit("menu_open"); show_profile(false))
	var settings_button := make_button(title_content, "SETTINGS", Rect2(252, 692, 160, 62), Color("#17294be8"), Color("#c99cff"), 17)
	settings_button.pressed.connect(func(): ui_event.emit("menu_open"); show_settings())
	make_label(title_content, "THE HOARD IS WAITING", 12, Rect2(80, 776, 320, 26), HORIZONTAL_ALIGNMENT_CENTER, Color("#c9b47c"))

func build_profile() -> void:
	profile_content = Control.new()
	profile_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	profile_content.visible = false
	add_child(profile_content)
	var panel := make_panel(profile_content, Rect2(34, 102, 412, 650), Color("#0b1430f2"), Color("#d1a85a"))
	profile_heading = make_label(panel, "YOUR LOOTLINGS PROFILE", 26, Rect2(20, 28, 372, 45), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	make_label(panel, "DISPLAY NAME", 13, Rect2(38, 103, 336, 24), HORIZONTAL_ALIGNMENT_LEFT, Color("#9fb3d8"))
	name_edit = LineEdit.new()
	name_edit.position = Vector2(38, 130)
	name_edit.size = Vector2(336, 56)
	name_edit.max_length = 20
	name_edit.placeholder_text = "Treasure Seeker"
	name_edit.add_theme_font_size_override("font_size", 19)
	panel.add_child(name_edit)
	make_label(panel, "LOOTLING NICKNAME  •  OPTIONAL", 13, Rect2(38, 211, 336, 24), HORIZONTAL_ALIGNMENT_LEFT, Color("#9fb3d8"))
	nickname_edit = LineEdit.new()
	nickname_edit.position = Vector2(38, 238)
	nickname_edit.size = Vector2(336, 56)
	nickname_edit.max_length = 20
	nickname_edit.placeholder_text = "Leave blank for now"
	nickname_edit.add_theme_font_size_override("font_size", 18)
	panel.add_child(nickname_edit)
	make_label(panel, "PLAYER CARD", 13, Rect2(38, 326, 336, 24), HORIZONTAL_ALIGNMENT_LEFT, Color("#9fb3d8"))
	make_label(panel, "◈  RELIC BEAST     •     RUIN ROOKIE", 15, Rect2(38, 355, 336, 38), HORIZONTAL_ALIGNMENT_CENTER, Color("#e7edff"))
	var identity_card := make_label(panel, "BANNER  •  OUTER RUINS\nCURRENT LOOTLING  •  RELIC BEAST", 11, Rect2(38, 395, 336, 44), HORIZONTAL_ALIGNMENT_CENTER, Color("#b8c7e7"))
	identity_card.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	profile_id_label = make_label(panel, "", 10, Rect2(38, 444, 336, 30), HORIZONTAL_ALIGNMENT_CENTER, Color("#7183a8"))
	profile_id_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var identity_note := make_label(panel, "Names can be changed here.\nYour support ID stays private.", 13, Rect2(45, 476, 322, 54), HORIZONTAL_ALIGNMENT_CENTER, Color("#b9c7e3"))
	identity_note.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	identity_note.clip_text = true
	var save := make_button(panel, "SAVE PROFILE", Rect2(40, 553, 332, 66), Color("#285c4c"), Color("#69e6b0"), 19)
	save.pressed.connect(save_profile)

func build_settings() -> void:
	settings_content = Control.new()
	settings_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_content.visible = false
	add_child(settings_content)
	var panel := make_panel(settings_content, Rect2(28, 75, 424, 710), Color("#0b1430f4"), Color("#c99cff"))
	make_label(panel, "AUDIO SETTINGS", 29, Rect2(20, 24, 384, 46), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	var channels := SettingsStore.CHANNELS
	for index in range(channels.size()):
		var channel: String = channels[index]
		var y := 92 + index * 103
		make_label(panel, channel.to_upper(), 14, Rect2(30, y, 120, 24), HORIZONTAL_ALIGNMENT_LEFT, Color("#d9e5ff"))
		var slider := HSlider.new()
		slider.position = Vector2(30, y + 29)
		slider.size = Vector2(258, 38)
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.01
		panel.add_child(slider)
		setting_sliders[channel] = slider
		var mute := CheckButton.new()
		mute.text = "MUTE"
		mute.position = Vector2(300, y + 22)
		mute.size = Vector2(96, 44)
		mute.add_theme_font_size_override("font_size", 12)
		panel.add_child(mute)
		setting_mutes[channel] = mute
	var back := make_button(panel, "SAVE & RETURN", Rect2(42, 624, 340, 62), Color("#49346b"), Color("#d19cff"), 18)
	back.pressed.connect(save_settings)

func build_lootling_select() -> void:
	lootling_content = Control.new()
	lootling_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lootling_content.visible = false
	add_child(lootling_content)
	var panel := make_panel(lootling_content, Rect2(24, 66, 432, 730), Color("#0b1430f4"), Color("#d1a85a"))
	make_label(panel, "CHOOSE YOUR LOOTLING", 27, Rect2(20, 24, 392, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	make_label(panel, "Your first expedition begins with the Relic Beast.", 13, Rect2(30, 69, 372, 30), HORIZONTAL_ALIGNMENT_CENTER, Color("#b9c9ee"))
	var portrait := TextureRect.new()
	portrait.texture = MASCOT_TEXTURE
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.position = Vector2(92, 102)
	portrait.size = Vector2(248, 244)
	panel.add_child(portrait)
	make_label(panel, "RELIC BEAST", 25, Rect2(40, 346, 352, 36), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe6a0"))
	make_label(panel, str(LootlingCatalog.definition("relic_beast").lore), 14, Rect2(48, 384, 336, 44), HORIZONTAL_ALIGNMENT_CENTER, Color("#d9e5ff"))
	var locked_text := "COMING WITH CLEAN RUNTIME ART\nEmberhorn  •  Mosskin  •  Moonkip\nPebblewyrm  •  Glimmerfin  •  Gloomlet"
	var locked := make_label(panel, locked_text, 10, Rect2(35, 459, 362, 88), HORIZONTAL_ALIGNMENT_CENTER, Color("#7f91b5"))
	locked.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	locked.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var confirm := make_button(panel, "CHOOSE RELIC BEAST", Rect2(48, 600, 336, 72), Color("#285c4c"), Color("#69e6b0"), 19)
	confirm.pressed.connect(confirm_lootling)

func show_lootling_select() -> void:
	current_screen = "lootling_select"
	set_screen(lootling_content)

func confirm_lootling() -> void:
	profile.current_lootling_id = "relic_beast"
	profile_changed.emit(profile.duplicate(true))
	ui_event.emit("upgrade_select")
	profile_completed.emit()

func show_boot() -> void:
	current_screen = "boot"
	boot_timer = 0.0
	set_screen(boot_content)
	ui_event.emit("menu_transition")

func skip_boot() -> void:
	ui_event.emit("ui_press")
	show_title()

func request_play() -> void:
	ui_event.emit("ui_press")
	if profile_exists:
		enter_hideout.emit()
	else:
		show_profile(true)

func show_title() -> void:
	current_screen = "title"
	set_screen(title_content)
	ui_event.emit("menu_transition")

func show_profile(first_launch: bool) -> void:
	current_screen = "profile_create" if first_launch else "profile"
	profile_heading.text = "WELCOME, TREASURE SEEKER" if first_launch else "YOUR LOOTLINGS PROFILE"
	refresh_profile()
	set_screen(profile_content)

func show_settings() -> void:
	current_screen = "settings"
	refresh_settings()
	set_screen(settings_content)

func save_profile() -> void:
	var cleaned_name := ProfileStore.sanitize_name(name_edit.text)
	if cleaned_name.is_empty():
		name_edit.placeholder_text = "Choose a display name first"
		name_edit.grab_focus()
		return
	var previous_name := str(profile.get("display_name", ""))
	profile.display_name = cleaned_name
	profile.lootling_nickname = ProfileStore.sanitize_name(nickname_edit.text)
	if not previous_name.is_empty() and previous_name != cleaned_name:
		profile.rename_metadata.last_rename_unix = int(Time.get_unix_time_from_system())
		profile.rename_metadata.rename_count = int(profile.rename_metadata.get("rename_count", 0)) + 1
	var was_first_launch := not profile_exists
	profile_exists = true
	profile_changed.emit(profile.duplicate(true))
	ui_event.emit("upgrade_select")
	if was_first_launch:
		show_lootling_select()
	else:
		show_title()

func save_settings() -> void:
	for channel in SettingsStore.CHANNELS:
		settings[channel] = float(setting_sliders[channel].value)
		settings[channel + "_muted"] = bool(setting_mutes[channel].button_pressed)
	settings_changed.emit(settings.duplicate(true))
	ui_event.emit("menu_close")
	show_title()

func refresh_profile() -> void:
	if name_edit == null:
		return
	name_edit.text = str(profile.get("display_name", ""))
	nickname_edit.text = str(profile.get("lootling_nickname", ""))
	var uuid := str(profile.get("player_uuid", ""))
	profile_id_label.text = "ACCOUNT INFO  •  SUPPORT ID …%s" % uuid.right(8)

func refresh_settings() -> void:
	if setting_sliders.is_empty():
		return
	for channel in SettingsStore.CHANNELS:
		setting_sliders[channel].value = float(settings.get(channel, 0.8))
		setting_mutes[channel].button_pressed = bool(settings.get(channel + "_muted", false))

func set_screen(active: Control) -> void:
	var screens := [boot_content, title_content, profile_content, settings_content, lootling_content]
	if presentation != null:
		presentation.switch_screen(screens, active, 0.24)
	else:
		for screen in screens:
			screen.visible = screen == active
	queue_redraw()

func _process(delta: float) -> void:
	scene_time += delta
	if current_screen == "boot":
		boot_timer += delta
		var glyph := boot_content.get_node_or_null("CoreGlyph") as Label
		if glyph != null:
			glyph.modulate.a = 0.55 + sin(scene_time * 6.0) * 0.25
			glyph.scale = Vector2.ONE * (1.0 + sin(scene_time * 4.0) * 0.035)
		if boot_timer >= 1.35:
			skip_boot()
	queue_redraw()

func _draw() -> void:
	var texture_size := BACKGROUND.get_size()
	var crop_height := texture_size.x * 854.0 / 480.0
	var source := Rect2(0, maxf(0.0, (texture_size.y - crop_height) * 0.5), texture_size.x, minf(texture_size.y, crop_height))
	draw_texture_rect_region(BACKGROUND, Rect2(0, 0, 480, 854), source)
	draw_rect(Rect2(0, 0, 480, 854), Color("#0610298c"), true)
	if current_screen == "title":
		var bob := sin(scene_time * 2.0) * 5.0
		var breathe := 1.0 + sin(scene_time * 1.7) * 0.012
		draw_set_transform(Vector2(240, 425 + bob), 0.0, Vector2(1.0, 0.28))
		draw_circle(Vector2.ZERO, 88, Color("#020615a8"))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		draw_set_transform(Vector2(240, 370 + bob), sin(scene_time * 1.15) * 0.008, Vector2(breathe, 1.0 / breathe))
		draw_texture_rect(MASCOT_TEXTURE, Rect2(-125, -125, 250, 250), false, Color.WHITE)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		var core_alpha := 0.14 + maxf(0.0, sin(scene_time * 2.8)) * 0.16
		draw_circle(Vector2(241, 395 + bob), 13.0 + sin(scene_time * 2.8) * 2.0, Color(0.76, 0.52, 1.0, core_alpha))
		for index in range(10):
			var angle := scene_time * (0.18 + index * 0.006) + index * 0.63
			var radius := 118.0 + (index % 3) * 26.0
			draw_circle(Vector2(240, 390) + Vector2.RIGHT.rotated(angle) * radius, 1.5 + index % 2, Color(0.95, 0.75, 0.34, 0.30))
		for glint in range(3):
			var glint_pos := Vector2(75 + glint * 165, 190 + glint * 82)
			var glint_alpha := maxf(0.0, sin(scene_time * 1.4 + glint * 2.1)) * 0.45
			draw_line(glint_pos + Vector2(-5, 0), glint_pos + Vector2(5, 0), Color(1.0, 0.84, 0.42, glint_alpha), 1.5)
			draw_line(glint_pos + Vector2(0, -5), glint_pos + Vector2(0, 5), Color(1.0, 0.84, 0.42, glint_alpha), 1.5)
	elif current_screen in ["profile", "profile_create", "settings"]:
		draw_texture_rect(MASCOT_TEXTURE, Rect2(352, 4, 116, 116), false, Color(1, 1, 1, 0.86))
	draw_rect(Rect2(0, 0, 480, 5), Color("#d4a856"), true)

func make_panel(parent: Node, rect: Rect2, fill: Color, border: Color) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.add_theme_stylebox_override("panel", LootlingsUI.panel_style(fill, border, 22))
	parent.add_child(panel)
	return panel

func make_label(parent: Node, value: String, font_size: int, rect: Rect2, alignment: HorizontalAlignment, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = alignment
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func make_button(parent: Node, value: String, rect: Rect2, fill: Color, border: Color, font_size: int) -> Button:
	var button := Button.new()
	button.text = value
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size", font_size)
	LootlingsUI.apply_button(button, fill, border)
	parent.add_child(button)
	return button
