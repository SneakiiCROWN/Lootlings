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
var target_card := -1
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
# All physical contacts survive screen changes until their own release.
var slider_touch: Slider
var active_contacts: Dictionary = {}
var surface_token := ""
var release_barrier := false
var press_token := ""
var input_generation:=0

func current_surface_token() -> String:
	var surface: Control=game.input_surface()
	var token: String=game.state+":"+str(surface.get_instance_id() if surface!=null else 0)+":"+str(input_generation)
	if game.state=="hideout":token+=":"+game.hideout_ui.current_screen
	if game.state=="personal_home":token+=":"+game.personal_home.view
	return token

func renew_surface() -> void:
	# Reused reward/perk panels are new input surfaces even with the same node ID.
	input_generation+=1
	sync_surface()

func sync_surface() -> void:
	if game==null:return
	var next_token:=current_surface_token()
	if next_token==surface_token:return
	surface_token=next_token
	release_barrier=not active_contacts.is_empty()
	finger=-1;arena=false;dragged=false;scroll=null;inertia=null;velocity=0;slider_touch=null
	if is_instance_valid(owned_button):owned_button.set_pressed_no_signal(false)
	owned_button=null
	game.tap_buffer_timer=0;game.tap_buffer_flash=0
	for button in game.find_children("*","BaseButton",true,false):
		if not button.toggle_mode:button.set_pressed_no_signal(false)

func pointer_gate(event: InputEvent) -> bool:
	sync_surface()
	var key: int=-999
	var pressed:=false
	if event is InputEventScreenTouch:key=event.index;pressed=event.pressed
	elif event is InputEventMouseButton and event.device!=-1 and event.button_index==MOUSE_BUTTON_LEFT:key=-100;pressed=event.pressed
	if key!=-999:
		if pressed:
			if active_contacts.has(key):get_viewport().set_input_as_handled();return false
			active_contacts[key]=surface_token
		else:active_contacts.erase(key)
		if release_barrier:
			if active_contacts.is_empty():release_barrier=false
			block_mouse_until=Time.get_ticks_msec()+200
			get_viewport().set_input_as_handled();return false
	if release_barrier:
		get_viewport().set_input_as_handled();return false
	return true

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
	if not control.is_visible_in_tree():return false
	var surface: Control=game.input_surface()
	if surface!=null and surface!=control and not surface.is_ancestor_of(control):return false
	var parent:=control.get_parent()
	while parent is Control:
		if parent.clip_contents and not Rect2(Vector2.ZERO,parent.size).has_point(parent.get_global_transform_with_canvas().affine_inverse()*point):return false
		parent=parent.get_parent()
	return Rect2(Vector2.ZERO,control.size).has_point(control.get_global_transform_with_canvas().affine_inverse()*point)

func scroller_at(point: Vector2) -> Control:
	var found: Control
	for node in game.find_children("*","Control",true,false):
		if (node is ScrollContainer or (node is RichTextLabel and node.scroll_active)) and hit(node,point): found = node
	return found

func ui_at(point: Vector2) -> bool:
	if is_instance_valid(dialog): return true
	if game.input_surface()!=null: return true
	for node in game.find_children("*","Control",true,false):
		if (node is BaseButton or node is Range or node is LineEdit or node is ScrollContainer or node is RichTextLabel) and node.mouse_filter != Control.MOUSE_FILTER_IGNORE and hit(node,point): return true
	return false

func shift(target: Control, amount: float) -> void:
	if not is_instance_valid(target): return
	if target is ScrollContainer: target.scroll_vertical += int(round(amount))
	elif target is RichTextLabel: target.get_v_scroll_bar().value += amount

func _process(delta: float) -> void:
	sync_surface()
	if is_instance_valid(inertia) and inertia.is_visible_in_tree() and absf(velocity) > 8:
		shift(inertia,velocity*delta)
		velocity *= exp(-delta*9)
	else: inertia = null

func _input(event: InputEvent) -> void:
	if game == null: return
	if is_instance_valid(game.owner_test_access) and game.owner_test_access.observe(event):get_viewport().set_input_as_handled();return
	if event is InputEventScreenTouch and event.index!=0 and is_instance_valid(game.startup_ui):game.startup_ui.showcase_cancelled=true
	if not pointer_gate(event):return
	if is_instance_valid(game.startup_ui) and game.startup_ui.observe_showcase(event):
		block_mouse_until=Time.get_ticks_msec()+300
		get_viewport().set_input_as_handled();return
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
				register_button(button)
			for node in game.find_children("*","Range",true,false):
				if node is Slider and not node is ScrollBar and hit(node,event.position):
					slider_touch=node;finger=event.index
					set_slider_value(event.position)
					block_mouse_until=Time.get_ticks_msec()+300
					get_viewport().set_input_as_handled();return
			finger = event.index
			start = event.position
			previous = start
			dragged = false
			inertia = null
			velocity = 0
			scroll = scroller_at(start)
			start_state = game.state
			press_token=surface_token
			# These contextual buttons change screens on release. Own the touch
			# directly rather than delegating it to synthetic mouse ordering.
			if not game.presentation_director.travel_active and not game.presentation_director.vignette.active:
				var best_z: int=-4096
				for button in game.find_children("*","Button",true,false):
					if button.disabled or not hit(button,start): continue
					var z:=0; var ancestor: Node=button
					while ancestor is CanvasItem:
						z+=ancestor.z_index; ancestor=ancestor.get_parent()
					if z>=best_z: owned_button=button; best_z=z
				if is_instance_valid(owned_button) and not owned_button in owned_buttons: owned_button=null
				if is_instance_valid(owned_button):
					owned_button.set_pressed_no_signal(true)
					block_mouse_until=Time.get_ticks_msec()+300; get_viewport().set_input_as_handled()
			var local: Vector2 = game.get_global_transform_with_canvas().affine_inverse()*start
			target_card=game.enemy_encounter.card_at(local) if game.state=="playing" else -1
			arena = game.state == "playing" and (Rect2(0,310,480,344).has_point(local) or target_card>=0) and not ui_at(start) and not game.presentation_director.vignette.active and not game.presentation_director.travel_active
			if arena:
				block_mouse_until = Time.get_ticks_msec()+300
				get_viewport().set_input_as_handled()
		elif finger == event.index:
			if is_instance_valid(slider_touch):
				if not event.canceled:set_slider_value(event.position)
				slider_touch=null;finger=-1;block_mouse_until=Time.get_ticks_msec()+200
				get_viewport().set_input_as_handled();return
			if is_instance_valid(owned_button):
				var button: Button=owned_button
				owned_button=null
				button.set_pressed_no_signal(false)
				block_mouse_until=Time.get_ticks_msec()+200
				get_viewport().set_input_as_handled()
				if not dragged and not event.canceled and game.state==start_state and press_token==current_surface_token() and not button.disabled and hit(button,event.position):
					button.pressed.emit()
					sync_surface()
			elif arena:
				block_mouse_until = Time.get_ticks_msec()+200
				if not dragged and not event.canceled and game.state == start_state and not is_instance_valid(dialog):
					var local: Vector2 = game.get_global_transform_with_canvas().affine_inverse()*event.position
					var released_card: int=game.enemy_encounter.card_at(local)
					if target_card>=0:
						if released_card==target_card: game.enemy_encounter.select(game,target_card)
					elif released_card<0:
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
		if is_instance_valid(slider_touch):
			set_slider_value(event.position);block_mouse_until=Time.get_ticks_msec()+300
			get_viewport().set_input_as_handled();return
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
	sync_surface()
	pending = Callable()
	block_mouse_until = Time.get_ticks_msec()+160

func request(title: String, detail: String, action: Callable, comparison: Dictionary = {}) -> void:
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
	body.bbcode_enabled=true;body.scroll_active=true
	body.text = detail
	body.position = Vector2(22,102)
	body.size = Vector2(388,196)
	body.add_theme_font_size_override("normal_font_size",18)
	panel.add_child(body)
	var action_y:=328
	if not comparison.is_empty():
		panel.position.y=120;panel.size.y=626;body.size.y=422;action_y=548
		preload("res://quick_comparison.gd").install(body,game,comparison,game.inventory.equipped_item(str(comparison.get("slot","Weapon"))))
		body.set_meta("hoard_preview",true)
	game.make_action_button(panel,"BACK",Vector2(22,action_y),Vector2(180,58),Color("#263b58"),Color("#79a9d9"),close_dialog)
	confirm_button = game.make_action_button(panel,"CONFIRM",Vector2(230,action_y),Vector2(180,58),Color("#285c4c"),Color("#69e6b0"),func():
		if Time.get_ticks_msec()-dialog_opened < 180: return
		var callback := pending
		close_dialog()
		game.play_audio_event("ui_press")
		if callback.is_valid(): callback.call()
	)
	sync_surface()


func set_slider_value(point: Vector2) -> void:
	var local: Vector2=slider_touch.get_global_transform_with_canvas().affine_inverse()*point
	var ratio: float=clampf(local.x/maxf(1,slider_touch.size.x),0,1) if slider_touch is HSlider else 1-clampf(local.y/maxf(1,slider_touch.size.y),0,1)
	slider_touch.value=lerpf(slider_touch.min_value,slider_touch.max_value,ratio)
