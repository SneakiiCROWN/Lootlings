extends Control
# Paint outside the safe design frame without changing combat geometry.
var game
var clock := 0.0
func configure(target) -> void:
	game = target
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
func _process(delta: float) -> void:
	clock += delta
	size = get_viewport_rect().size
	queue_redraw()
func _draw() -> void:
	if game == null: return
	var texture: Texture2D = game.current_zone.get("background",game.ZoneCatalog.OUTER_RUINS_BACKGROUND)
	if game.state == "hideout": texture = game.hideout_ui.background_for_screen()
	elif game.startup_ui.visible: texture = game.startup_ui.BACKGROUND
	var extent := texture.get_size()
	var scale_factor := maxf(size.x/extent.x,size.y/extent.y)
	var scaled := extent*scale_factor
	draw_texture_rect(texture,Rect2((size-scaled)*.5,scaled),false)
	draw_rect(Rect2(Vector2.ZERO,size),Color("#08112735"))
	if game.audio_settings.get("cinematic_reduced_motion",false): return
	var core := Rect2(game.position,game.size*game.scale)
	for index in range(12):
		var point := Vector2(fmod(index*97.0+clock*(2+index%3),size.x),fmod(index*131.0+clock*3,size.y))
		if not core.has_point(point): draw_circle(point,1.5,Color("#bca5ed65"))
