extends Node
# One gesture owner: scroll starts over cards as well as empty list space.
# Consequential actions keep their existing guarded gameplay callbacks.
const DEADZONE := 12.0
var game
var finger := -1
var start := Vector2.ZERO
var previous := Vector2.ZERO
var dragged := false
var arena := false
var start_state := ""
var scroll: Control
var velocity := 0.0
var inertia: Control
var block_mouse_until := 0
var dialog: Control
var pending := Callable()
var confirm_button: Button
var dialog_opened := 0
var owned_buttons: Array[Button] = []
var owned_button: Button

func register_button(button: Button) -> void:
	if not button in owned_buttons: owned_buttons.append(button)

func configure(target) -> void:
	game = target
	process_mode = Node.PROCESS_MODE_ALWAYS
	for node in game.find_children("*","ScrollContainer",true,false):
		node.scroll_deadzone = int(DEADZONE)
		node.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		# Keep a subtle position indicator, without requiring its handle.
		node.get_v_scroll_bar().mouse_filter = Control.MOUSE_FILTER_IGNORE

func hit(control: Control, point: Vector2) -> bool:
	return control.is_visible_in_tree() and Rect2(Vector2.ZERO,control.size).has_point(control.get_global_transform_with_canvas().affine_inverse()*point)

func scroller_at(point: Vector2) -> Control:
	var found: Control
	for node in game.find_children("*","Control",true,false):
		if (node is ScrollContainer or (node is RichTextLabel and node.scroll_active)) and hit(node,point): found = node
	return found

func ui_at(point: Vector2) -> bool:
	if is_instance_valid(dialog): return true
	for node in game.find_children("*","Control",true,false):
		if (node is BaseButton or node is Range or node is LineEdit or node is ScrollContainer or node is RichTextLabel) and node.mouse_filter != Control.MOUSE_FILTER_IGNORE and hit(node,point): return true
	return false

func shift(target: Control, amount: float) -> void:
	if not is_instance_valid(target): return
	if target is ScrollContainer: target.scroll_vertical += int(round(amount))
	elif target is RichTextLabel: target.get_v_scroll_bar().value += amount

func _process(delta: float) -> void:
	if is_instance_valid(inertia) and inertia.is_visible_in_tree() and absf(velocity) > 8:
		shift(inertia,velocity*delta)
		velocity *= exp(-delta*9)
	else: inertia = null

func _input(event: InputEvent) -> void:
	if game == null: return
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if event.device == -1 and Time.get_ticks_msec() < block_mouse_until:
			get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenTouch:
		if event.index != 0:
			get_viewport().set_input_as_handled()
			return
		if event.pressed:
			block_mouse_until = 0 # a new finger press owns a new gesture
			owned_button = null
			owned_buttons=owned_buttons.filter(func(button): return is_instance_valid(button))
			# Destination cards are rebuilt when the region list refreshes.
			for button in game.find_children("*","Button",true,false):
				if button.get_meta("gesture_release_owned",false): register_button(button)
			for node in game.find_children("*","Range",true,false):
				if not node is ScrollBar and hit(node,event.position):
					finger = -1 # sliders retain their native drag interaction
					return
			finger = event.index
			start = event.position
			previous = start
			dragged = false
			inertia = null
			velocity = 0
			scroll = scroller_at(start)
			start_state = game.state
			# These contextual buttons change screens on release. Own the touch
			# directly rather than delegating it to synthetic mouse ordering.
			if not game.presentation_director.travel_active and not game.presentation_director.vignette.active and not is_instance_valid(dialog):
				for button in owned_buttons:
					if is_instance_valid(button) and not button.disabled and hit(button,start):
						owned_button=button
						button.set_pressed_no_signal(true)
						block_mouse_until=Time.get_ticks_msec()+300
						get_viewport().set_input_as_handled()
						break
			var local: Vector2 = game.get_global_transform_with_canvas().affine_inverse()*start
			arena = game.state == "playing" and Rect2(0,310,480,344).has_point(local) and not ui_at(start) and not game.presentation_director.vignette.active and not game.presentation_director.travel_active
			if arena:
				block_mouse_until = Time.get_ticks_msec()+300
				get_viewport().set_input_as_handled()
		elif finger == event.index:
			if is_instance_valid(owned_button):
				var button: Button=owned_button
				owned_button=null
				button.set_pressed_no_signal(false)
				block_mouse_until=Time.get_ticks_msec()+200
				get_viewport().set_input_as_handled()
				if not dragged and not event.canceled and game.state==start_state and not button.disabled and hit(button,event.position):
					button.pressed.emit()
			elif arena:
				block_mouse_until = Time.get_ticks_msec()+200
				if not dragged and not event.canceled and game.state == start_state and not is_instance_valid(dialog):
					var local: Vector2 = game.get_global_transform_with_canvas().affine_inverse()*event.position
					if game.enemy_encounter.active: game.enemy_encounter.select_at(game,local)
					game.request_tap_attack()
				get_viewport().set_input_as_handled()
			elif dragged:
				block_mouse_until = Time.get_ticks_msec()+200
				inertia = scroll
				get_viewport().set_input_as_handled()
			if dragged:
				for node in game.find_children("*","BaseButton",true,false):
					if not node.toggle_mode: node.set_pressed_no_signal(false)
			finger = -1
	if event is InputEventScreenDrag and event.index == finger:
		if event.position.distance_to(start) >= DEADZONE: dragged = true
		if dragged:
			block_mouse_until = Time.get_ticks_msec()+300
			if is_instance_valid(scroll):
				var transform := scroll.get_global_transform_with_canvas().affine_inverse()
				var amount: float = (transform*previous-transform*event.position).y
				shift(scroll,amount)
				velocity = clampf(amount/maxf(get_process_delta_time(),.008),-1500,1500)
			get_viewport().set_input_as_handled()
		previous = event.position

func close_dialog() -> void:
	if is_instance_valid(dialog): dialog.queue_free()
	dialog = null
	pending = Callable()
	block_mouse_until = Time.get_ticks_msec()+160

func request(title: String, detail: String, action: Callable) -> void:
	if is_instance_valid(dialog): return
	game.play_audio_event("menu_open")
	pending = action
	dialog_opened = Time.get_ticks_msec()
	dialog = Control.new()
	dialog.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dialog.z_index = 200
	game.add_child(dialog)
	var veil := ColorRect.new()
	veil.color = Color("#050a17dd")
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dialog.add_child(veil)
	var panel := Panel.new()
	panel.position = Vector2(24,214)
	panel.size = Vector2(432,410)
	panel.add_theme_stylebox_override("panel",preload("res://lootlings_ui.gd").panel_style(Color("#13233b")))
	dialog.add_child(panel)
	var heading := Label.new()
	heading.text = title
	heading.position = Vector2(22,24)
	heading.size = Vector2(388,66)
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.add_theme_font_size_override("font_size",23)
	panel.add_child(heading)
	var body := RichTextLabel.new()
	body.text = detail
	body.position = Vector2(22,102)
	body.size = Vector2(388,196)
	body.add_theme_font_size_override("normal_font_size",18)
	panel.add_child(body)
	game.make_action_button(panel,"BACK",Vector2(22,328),Vector2(180,58),Color("#263b58"),Color("#79a9d9"),close_dialog)
	confirm_button = game.make_action_button(panel,"CONFIRM",Vector2(230,328),Vector2(180,58),Color("#285c4c"),Color("#69e6b0"),func():
		if Time.get_ticks_msec()-dialog_opened < 180: return
		var callback := pending
		close_dialog()
		game.play_audio_event("ui_press")
		if callback.is_valid(): callback.call()
	)
