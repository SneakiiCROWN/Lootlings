extends Control

const UI = preload("res://lootlings_ui.gd")
const VignettePlayer = preload("res://vignette_player.gd")
const SCAVENGED_CHEST = preload("res://art/sprites/rewards/scavenged_chest_beta.png")
const RELIC_CHEST = preload("res://art/sprites/rewards/relic_chest_beta.png")

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
var chest_showcase_timer := 0.0
var chest_showcase_kind := "scavenged"
var chest_showcase_center := Vector2(240, 428)
var chest_showcase_color := Color("#ffd36a")
var chest_showcase_item: Texture2D
var vignette

func _ready() -> void:
	name = "PresentationDirector"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 900
	build_overlay()
	vignette = VignettePlayer.new()
	add_child(vignette)
	set_process(false)

func build_overlay() -> void:
	veil = ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color("#04081700")
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)
	travel_panel = Panel.new()
	travel_panel.position = Vector2(30, 318)
	travel_panel.size = Vector2(420, 214)
	travel_panel.add_theme_stylebox_override("panel", UI.material_style("relic"))
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
	toast_panel.add_theme_stylebox_override("panel", UI.material_style("relic"))
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
	fit_title(toast_title, title, 17)
	toast_title.add_theme_color_override("font_color", accent.lightened(0.18))
	toast_subtitle.text = subtitle
	# The painted shared frame stays intact; title/flash carry event accent.
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
	cancel_chest_showcase()
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
	fit_title(travel_title, title, 27)
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

func play_chest_showcase(kind: String, center: Vector2, color: Color, item_texture: Texture2D = null) -> void:
	chest_showcase_kind = kind
	chest_showcase_center = center
	chest_showcase_color = color
	chest_showcase_item = item_texture
	chest_showcase_timer = 0.90
	set_process(true)
	queue_redraw()

func cancel_chest_showcase() -> void:
	chest_showcase_timer = 0.0
	chest_showcase_item = null
	set_process(false)
	queue_redraw()

func _process(delta: float) -> void:
	chest_showcase_timer = maxf(0.0, chest_showcase_timer - delta)
	if chest_showcase_timer <= 0.0:
		cancel_chest_showcase()
	else:
		queue_redraw()

func _draw() -> void:
	if chest_showcase_timer <= 0.0: return
	var elapsed := 0.90 - chest_showcase_timer
	var land := clampf(elapsed / 0.18, 0.0, 1.0)
	var opening := clampf((elapsed - 0.22) / 0.30, 0.0, 1.0)
	var alpha := minf(1.0, chest_showcase_timer / 0.20)
	var center := chest_showcase_center + Vector2(0, -36.0 * (1.0 - land * land))
	draw_chest(self, center, chest_showcase_kind, opening, alpha, 1.0, sin(clampf((elapsed - 0.18) / 0.10, 0, 1) * PI))
	if elapsed > 0.42 and chest_showcase_item != null:
		var arc := clampf((elapsed - 0.42) / 0.30, 0, 1)
		var item_center := center + Vector2(0, -24 - sin(arc * PI * 0.7) * 96)
		draw_circle(item_center, 30, Color(chest_showcase_color, alpha * 0.18))
		UI.draw_icon(get_canvas_item(), chest_showcase_item, Rect2(item_center - Vector2(26, 26), Vector2(52, 52)))

static func draw_chest(canvas: CanvasItem, center: Vector2, kind: String, opening: float, alpha: float = 1.0, scale_factor: float = 1.0, squash: float = 0.0) -> void:
	var texture: Texture2D = RELIC_CHEST if kind == "relic" else SCAVENGED_CHEST
	var color := Color(1, 1, 1, clampf(alpha, 0, 1))
	canvas.draw_set_transform(center, 0, Vector2(scale_factor * (1.0 + squash * 0.12), scale_factor * (1.0 - squash * 0.08)))
	canvas.draw_circle(Vector2(0, -12), 44 + opening * 14, Color(0.72, 0.48, 1.0, alpha * (0.10 + opening * 0.18)))
	# Preserve the complete painted silhouette; a genuine hinged-open frame is
	# a production-art requirement, not two arbitrary slices of the closed art.
	canvas.draw_texture_rect(texture, Rect2(-80, -76 - sin(opening * PI) * 5, 160, 140), false, color)
	canvas.draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

func fit_title(label: Label, text: String, maximum: int) -> void:
	var font := label.get_theme_font("font")
	var font_size := maximum
	while font_size > 14 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > label.size.x:
		font_size -= 1
	label.add_theme_font_size_override("font_size", font_size)
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.clip_text = true
