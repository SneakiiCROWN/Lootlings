extends Control

# One bounded living-painting player, hosted by PresentationDirector.
# It knows nothing about inventory, campaign, rewards, saves or gameplay RNG.
const UI = preload("res://lootlings_ui.gd")
signal finished(id: String, mode: String)
signal sound_requested(event_name: String)
signal active_changed(playing: bool)
var active := false
var current_id := ""
var mode := "replay"
var elapsed := 0.0
var duration := 0.0
var reduced_motion := false
var subtitles := true
var data := {}
var background: Texture2D
var actor: Texture2D
var title: Label
var category: Label
var caption: Label
var status: Label
var close: Button
var handoff: Callable
var caption_panel: Panel
var caption_index := -1
var portrait_frame: StyleBox

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 20
	visible = false
	portrait_frame = UI.material_style("relic")
	category = label(Rect2(28,76,424,30), 13, Color("#c8afff"))
	title = label(Rect2(26,113,428,94), 29, Color("#ffe178"))
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption_panel = Panel.new()
	caption_panel.position = Vector2(26, 623)
	caption_panel.size = Vector2(428,157)
	UI.apply_material(caption_panel, "relic")
	add_child(caption_panel)
	caption = label(Rect2(50,640,380,105), 19, Color("#edf2ff"))
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status = label(Rect2(47,745,386,22), 10, Color("#a4b6d9"))
	close = Button.new()
	close.position = Vector2(270, 792)
	close.size = Vector2(184,48)
	close.text = "SKIP ›"
	close.add_theme_font_size_override("font_size", 16)
	UI.apply_button(close, Color("#17294b"), Color("#72c8ff"))
	close.pressed.connect(finish)
	add_child(close)
	set_process(false)

func label(rect: Rect2, size_value: int, color: Color) -> Label:
	var node := Label.new()
	node.position = rect.position
	node.size = rect.size
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.add_theme_font_size_override("font_size",size_value)
	node.add_theme_color_override("font_color",color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(node)
	return node

func play(entry: Dictionary, settings: Dictionary, playback_mode: String, callback: Callable = Callable(), abbreviated: bool = false) -> bool:
	if active or entry.is_empty(): return false
	data = entry
	current_id = str(entry.id)
	mode = playback_mode
	handoff = callback if playback_mode == "discovery" else Callable()
	duration = 1.4 if abbreviated else float(entry.duration)
	reduced_motion = bool(settings.get("cinematic_reduced_motion", false))
	subtitles = bool(settings.get("cinematic_subtitles", true))
	background = load(str(entry.background))
	actor = load(str(entry.actor)) if not str(entry.actor).is_empty() and ResourceLoader.exists(str(entry.actor)) else null
	title.text = str(entry.name).to_upper()
	category.text = "%s • %s" % [str(entry.category).to_upper(), "ARCHIVE REPLAY" if mode == "replay" else "STORY PREVIEW" if mode == "preview" else "DISCOVERED MEMORY"]
	status.text = str(entry.category).to_upper()
	close.text = "CLOSE ›" if mode in ["replay","preview"] else "SKIP ›"
	caption_panel.visible = subtitles
	caption.visible = subtitles
	status.visible = subtitles
	elapsed = 0
	caption_index = -1
	active = true
	active_changed.emit(true)
	visible = true
	set_process(true)
	update_caption()
	sound_requested.emit(str(entry.sound))
	queue_redraw()
	return true

func update_caption() -> void:
	var lines: Array = data.lines
	var weights: Array[float] = []
	var total := 0.0
	for line in lines:
		var weight := maxf(2.0,str(line).length()*.045+1.0)
		weights.append(weight)
		total += weight
	var cursor := elapsed/maxf(.01,duration)*total
	var index := 0
	while index < weights.size()-1 and cursor >= weights[index]:
		cursor -= weights[index]
		index += 1
	if index != caption_index:
		caption_index = index
		caption.text = str(lines[index]) if not lines.is_empty() else ""

func _process(delta: float) -> void:
	if not active: return
	elapsed += delta
	update_caption()
	queue_redraw()
	if elapsed >= duration: finish()

func finish() -> void:
	if not active: return
	var callback := handoff
	var finished_id := current_id
	var finished_mode := mode
	cancel()
	finished.emit(finished_id, finished_mode)
	if callback.is_valid(): callback.call()

func cancel() -> void:
	var was_active := active
	active = false
	visible = false
	handoff = Callable()
	set_process(false)
	# Cached ResourceLoader resources can be shared; no uncontrolled nodes/timers.
	background = null
	actor = null
	if was_active: active_changed.emit(false)

func _input(event: InputEvent) -> void:
	if not active: return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ESCAPE,KEY_SPACE,KEY_ENTER]:
		finish()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.keycode == KEY_F1:
		get_viewport().set_input_as_handled()

func actor_extent() -> Vector2:
	if actor==null: return Vector2.ZERO
	var bounds:=Vector2(306,306)
	if data.actor_kind=="adult": bounds=Vector2(234,351)
	elif data.actor_kind=="boss": bounds=Vector2(360,320)
	elif data.actor_kind=="portrait": bounds=Vector2(286,286)
	var source:=actor.get_size()
	return source*minf(bounds.x/source.x,bounds.y/source.y)

func _draw() -> void:
	if not active or background == null: return
	var progress := clampf(elapsed / maxf(duration, 0.01), 0, 1)
	var zoom := 1.0 if reduced_motion else 1.0 + progress * 0.035
	var source_size := background.get_size()
	var crop_height := minf(source_size.y, source_size.x * 854.0 / 480.0)
	var source := Rect2(0,(source_size.y-crop_height)*0.5,source_size.x,crop_height)
	draw_set_transform(Vector2(240,427),0,Vector2.ONE*zoom)
	draw_texture_rect_region(background,Rect2(-240,-427,480,854),source)
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
	draw_rect(Rect2(0,0,480,854),Color("#070a204a"))
	draw_rect(Rect2(0,0,480,62),Color("#040716df"))
	draw_rect(Rect2(0,786,480,68),Color("#040716df"))
	draw_line(Vector2(26,67),Vector2(454,67),Color("#d1a85a"),1)
	if actor != null:
		var extent := actor_extent()
		var bob := 0.0 if reduced_motion else sin(elapsed*1.7)*2.0
		var arrival := 0.0 if reduced_motion else (1.0-clampf(elapsed/0.45,0,1))*18.0
		var center := Vector2(240,416+bob+arrival)
		if data.actor_kind == "portrait":
			draw_style_box(portrait_frame,Rect2(center-extent*0.5-Vector2(10,10),extent+Vector2(20,20)))
		draw_texture_rect(actor,Rect2(center-extent*0.5,extent),false,Color(data.actor_tint))
	if not reduced_motion:
		for index in range(6):
			var p := Vector2(46+index*76,535+sin(elapsed*0.6+index)*19)
			draw_circle(p,1.4,Color(0.7,0.85,1.0,0.25))
	draw_line(Vector2(28,810),Vector2(220,810),Color("#4b4162"),3)
	draw_line(Vector2(28,810),Vector2(28+192*progress,810),Color("#c6a0ee"),3)
