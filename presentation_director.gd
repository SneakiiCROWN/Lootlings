extends Control

signal travel_midpoint
signal travel_finished

var veil: ColorRect
var travel_panel: Panel
var travel_title: Label
var travel_subtitle: Label
var travel_progress: ProgressBar
var accent_bar: ColorRect
var active_tween: Tween
var flash_tween: Tween
var control_tweens := {}
var travel_active := false
var toast_panel: Panel
var toast_title: Label
var toast_subtitle: Label
var toast_tween: Tween

func _ready() -> void:
	name = "PresentationDirector"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 900
	build_overlay()

func build_overlay() -> void:
	veil = ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color("#04081700")
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)
	travel_panel = Panel.new()
	travel_panel.position = Vector2(30, 318)
	travel_panel.size = Vector2(420, 214)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#091127f2")
	panel_style.border_color = Color("#d1a85a")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(20)
	panel_style.shadow_color = Color("#02040bb8")
	panel_style.shadow_size = 14
	travel_panel.add_theme_stylebox_override("panel", panel_style)
	travel_panel.visible = false
	add_child(travel_panel)
	accent_bar = ColorRect.new()
	accent_bar.position = Vector2(34, 24)
	accent_bar.size = Vector2(352, 3)
	accent_bar.color = Color("#ffe178")
	travel_panel.add_child(accent_bar)
	travel_title = Label.new()
	travel_title.position = Vector2(24, 48)
	travel_title.size = Vector2(372, 48)
	travel_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	travel_title.add_theme_font_size_override("font_size", 27)
	travel_title.add_theme_color_override("font_color", Color("#ffe178"))
	travel_panel.add_child(travel_title)
	travel_subtitle = Label.new()
	travel_subtitle.position = Vector2(30, 101)
	travel_subtitle.size = Vector2(360, 58)
	travel_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	travel_subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	travel_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	travel_subtitle.add_theme_font_size_override("font_size", 14)
	travel_subtitle.add_theme_color_override("font_color", Color("#c7d5ef"))
	travel_panel.add_child(travel_subtitle)
	travel_progress = ProgressBar.new()
	travel_progress.position = Vector2(70, 174)
	travel_progress.size = Vector2(280, 8)
	travel_progress.min_value = 0.0
	travel_progress.max_value = 1.0
	travel_progress.value = 1.0
	travel_progress.show_percentage = false
	travel_progress.visible = false
	travel_panel.add_child(travel_progress)
	toast_panel = Panel.new()
	toast_panel.position = Vector2(56, 92)
	toast_panel.size = Vector2(368, 90)
	var toast_style := StyleBoxFlat.new()
	toast_style.bg_color = Color("#091127f2")
	toast_style.border_color = Color("#ffd36a")
	toast_style.set_border_width_all(2)
	toast_style.set_corner_radius_all(16)
	toast_style.shadow_color = Color("#02040bb0")
	toast_style.shadow_size = 10
	toast_panel.add_theme_stylebox_override("panel", toast_style)
	toast_panel.visible = false
	add_child(toast_panel)
	toast_title = Label.new()
	toast_title.position = Vector2(18, 12)
	toast_title.size = Vector2(332, 28)
	toast_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_title.add_theme_font_size_override("font_size", 17)
	toast_title.add_theme_color_override("font_color", Color("#ffe178"))
	toast_panel.add_child(toast_title)
	toast_subtitle = Label.new()
	toast_subtitle.position = Vector2(18, 43)
	toast_subtitle.size = Vector2(332, 30)
	toast_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_subtitle.add_theme_font_size_override("font_size", 12)
	toast_subtitle.add_theme_color_override("font_color", Color("#d9e5ff"))
	toast_panel.add_child(toast_subtitle)

func switch_screen(screens: Array, active: Control, duration: float = 0.22) -> void:
	for screen in screens:
		if screen != null:
			screen.visible = screen == active
	if active == null:
		return
	var target_position := prepare_control(active)
	active.modulate.a = 0.0
	active.scale = Vector2(0.985, 0.985)
	active.pivot_offset = active.size * 0.5
	active.position = target_position + Vector2(0, 8)
	var tween := create_tween().set_parallel(true)
	control_tweens[active.get_instance_id()] = tween
	tween.tween_property(active, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(active, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(active, "position", target_position, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	flash(Color("#6f8fc0"), minf(0.18, duration))

func present_card(control: Control, accent: Color = Color("#d1a85a"), duration: float = 0.24, delay: float = 0.0) -> void:
	if control == null:
		return
	var target_position := prepare_control(control)
	control.visible = true
	control.pivot_offset = control.size * 0.5
	control.scale = Vector2(0.97, 0.97)
	control.modulate = Color(1, 1, 1, 0)
	control.position = target_position + Vector2(0, 10)
	var tween := create_tween().set_parallel(true)
	control_tweens[control.get_instance_id()] = tween
	tween.tween_property(control, "modulate", Color.WHITE, duration).set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(control, "scale", Vector2.ONE, duration).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(control, "position", target_position, duration).set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	flash(accent, minf(0.16, duration))

func present_toast(title: String, subtitle: String, accent: Color = Color("#ffd36a")) -> void:
	if toast_tween != null and toast_tween.is_valid():
		toast_tween.kill()
	toast_title.text = title
	toast_title.add_theme_color_override("font_color", accent.lightened(0.18))
	toast_subtitle.text = subtitle
	var style: StyleBoxFlat = toast_panel.get_theme_stylebox("panel").duplicate()
	style.border_color = accent
	toast_panel.add_theme_stylebox_override("panel", style)
	toast_panel.visible = true
	toast_panel.position = Vector2(56, 70)
	toast_panel.modulate = Color(1, 1, 1, 0)
	toast_tween = create_tween()
	toast_tween.set_parallel(true)
	toast_tween.tween_property(toast_panel, "position:y", 92.0, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	toast_tween.tween_property(toast_panel, "modulate:a", 1.0, 0.18)
	toast_tween.set_parallel(false)
	toast_tween.tween_interval(2.2)
	toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.25)
	toast_tween.tween_callback(func(): toast_panel.visible = false)

func flash(accent: Color, duration: float = 0.18) -> void:
	if travel_active or veil == null:
		return
	if flash_tween != null and flash_tween.is_valid():
		flash_tween.kill()
	veil.visible = true
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	veil.color = Color(accent.r, accent.g, accent.b, 0.12)
	flash_tween = create_tween()
	flash_tween.tween_property(veil, "color:a", 0.0, maxf(0.08, duration)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	flash_tween.tween_callback(func():
		veil.visible = false
		veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	)

func prepare_control(control: Control) -> Vector2:
	var key := control.get_instance_id()
	if control_tweens.has(key):
		var prior: Tween = control_tweens[key]
		if prior != null and prior.is_valid():
			prior.kill()
	if not control.has_meta("presentation_base_position"):
		control.set_meta("presentation_base_position", control.position)
	var base_position: Vector2 = control.get_meta("presentation_base_position")
	control.position = base_position
	control.scale = Vector2.ONE
	control.modulate = Color.WHITE
	return base_position

func play_travel(title: String, subtitle: String, accent: Color, midpoint: Callable = Callable(), duration: float = 0.62) -> void:
	if active_tween != null and active_tween.is_valid():
		active_tween.kill()
	travel_active = true
	veil.visible = true
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	veil.color = Color("#04081700")
	travel_panel.visible = true
	travel_panel.modulate = Color(1, 1, 1, 0)
	travel_panel.scale = Vector2(0.97, 0.97)
	travel_panel.pivot_offset = travel_panel.size * 0.5
	travel_title.text = title
	travel_subtitle.text = subtitle
	travel_title.add_theme_color_override("font_color", accent.lightened(0.28))
	accent_bar.color = accent
	travel_progress.visible = false
	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.tween_property(veil, "color", Color("#040817e8"), duration * 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	active_tween.tween_property(travel_panel, "modulate", Color.WHITE, duration * 0.28)
	active_tween.tween_property(travel_panel, "scale", Vector2.ONE, duration * 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	active_tween.set_parallel(false)
	active_tween.tween_callback(func():
		travel_midpoint.emit()
		if midpoint.is_valid(): midpoint.call()
	)
	active_tween.tween_interval(duration * 0.30)
	active_tween.set_parallel(true)
	active_tween.tween_property(travel_panel, "modulate:a", 0.0, duration * 0.42)
	active_tween.tween_property(veil, "color:a", 0.0, duration * 0.42)
	active_tween.set_parallel(false)
	active_tween.tween_callback(finish_travel)

func set_loading_progress(value: float, label: String = "") -> void:
	travel_progress.visible = true
	travel_progress.value = clampf(value, 0.0, 1.0)
	if not label.is_empty():
		travel_subtitle.text = label

func finish_travel() -> void:
	travel_active = false
	travel_panel.visible = false
	veil.visible = false
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	travel_finished.emit()

func bind_buttons(root: Node) -> void:
	for child in root.get_children():
		if child is Button:
			bind_button(child)
		bind_buttons(child)

func bind_button(button: Button) -> void:
	if button.has_meta("presentation_bound"):
		return
	button.set_meta("presentation_bound", true)
	button.button_down.connect(func(): animate_button(button, Vector2(0.965, 0.965), 0.07))
	button.button_up.connect(func(): animate_button(button, Vector2.ONE, 0.10))
	button.mouse_exited.connect(func():
		if not button.button_pressed: animate_button(button, Vector2.ONE, 0.10)
	)

func animate_button(button: Button, target_scale: Vector2, duration: float) -> void:
	if not is_instance_valid(button):
		return
	button.pivot_offset = button.size * 0.5
	create_tween().tween_property(button, "scale", target_scale, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
