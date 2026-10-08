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
	if game.startup_ui.visible and game.startup_ui.current_screen=="title":
		# One continuous artwork layer; no repeated sky or character crops.
		draw_rect(Rect2(Vector2.ZERO,size),Color(.012,.028,.055,1))
		var art:Texture2D=game.startup_ui.TITLE_ART
		var art_width:float=game.size.x*game.scale.x
		draw_texture_rect(art,Rect2(game.position.x,0,art_width,art_width*art.get_height()/art.get_width()),false)
		return
	var texture: Texture2D = game.current_zone.get("background",game.ZoneCatalog.OUTER_RUINS_BACKGROUND)
	if game.state == "hideout": texture = game.hideout_ui.background_for_screen()
	elif game.state=="personal_home":texture=game.personal_home.background()
	elif game.state=="mode_menu":texture=preload("res://beta_art_catalog.gd").FIRST_HOARD if game.retention.mode_tab=="siege" else preload("res://beta_art_catalog.gd").GROVE
	elif game.state=="relic_spinner" and game.retention.spinner_from_home:texture=preload("res://art/backgrounds/lootlings_hideout.png")
	elif game.startup_ui.visible: texture = game.startup_ui.BACKGROUND
	var extent := texture.get_size()
	var scale_factor := maxf(size.x/extent.x,size.y/extent.y)
	var scaled := extent*scale_factor
	draw_texture_rect(texture,Rect2((size-scaled)*.5,scaled),false)
	# World art shares the actual interaction frame. Full-viewport cover alone
	# moves furniture away from its hotspots on tall phones and wide desktops.
	if game.state in ["hideout","personal_home"] and (game.state=="personal_home" or game.hideout_ui.current_screen=="home"):
		var world_frame:=Rect2(game.position,game.size*game.scale)
		# Extend the outermost painted pixels beyond the safe area. This keeps
		# the room continuous without duplicating its ceiling/floor at the seam.
		if world_frame.position.y>0:
			draw_texture_rect_region(texture,Rect2(world_frame.position.x,0,world_frame.size.x,world_frame.position.y),Rect2(0,0,extent.x,1))
		if world_frame.end.y<size.y:
			draw_texture_rect_region(texture,Rect2(world_frame.position.x,world_frame.end.y,world_frame.size.x,size.y-world_frame.end.y),Rect2(0,extent.y-1,extent.x,1))
		if world_frame.position.x>0:
			draw_rect(Rect2(0,0,world_frame.position.x,size.y),Color("#081127bb"))
		if world_frame.end.x<size.x:
			draw_rect(Rect2(world_frame.end.x,0,size.x-world_frame.end.x,size.y),Color("#081127bb"))
		draw_texture_rect(texture,world_frame,false)
	draw_rect(Rect2(Vector2.ZERO,size),Color("#08112735"))
	if game.audio_settings.get("cinematic_reduced_motion",false): return
	var core := Rect2(game.position,game.size*game.scale)
	for index in range(12):
		var point := Vector2(fmod(index*97.0+clock*(2+index%3),size.x),fmod(index*131.0+clock*3,size.y))
		if not core.has_point(point): draw_circle(point,1.5,Color("#bca5ed65"))
