extends Control
# Decorative only: private seeded layout, no physics, inputs, gameplay RNG or audio.
var clock := 0.0
var motes: Array[Dictionary] = []
var settings_provider: Callable
var living_title:=false
func configure(bounds: Rect2, preferences: Callable) -> void:
	settings_provider = preferences
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	var cosmetic := RandomNumberGenerator.new()
	cosmetic.seed = 660314
	for index in range(12):
		motes.append({"point":Vector2(cosmetic.randf_range(bounds.position.x,bounds.end.x),cosmetic.randf_range(bounds.position.y,bounds.end.y)),"phase":cosmetic.randf_range(0,TAU),"speed":cosmetic.randf_range(.17,.31),"radius":cosmetic.randf_range(.65,1.1)})
func reduced_motion() -> bool:
	return settings_provider.is_valid() and settings_provider.call().get("cinematic_reduced_motion",false)
func _process(delta: float) -> void:
	if not is_visible_in_tree() or get_tree().paused:return
	if reduced_motion():return
	clock += delta
	queue_redraw()
func _draw() -> void:
	var reduced := reduced_motion()
	if living_title:draw_title_environment(reduced)
	for mote in motes:
		var phase:float=mote.phase
		var t:float=phase if reduced else clock*mote.speed+phase
		var point:Vector2=mote.point+Vector2(sin(t)*9,cos(t*.73+phase)*7)
		var alpha:float=.35 if reduced else .22+(.5+.5*sin(t*.91+phase))*.34
		draw_circle(point,mote.radius*4,Color(1,.77,.32,alpha*.07))
		draw_circle(point,mote.radius*2,Color(1,.82,.44,alpha*.18))
		draw_circle(point,mote.radius,Color(1,.92,.62,alpha))

func scene_point(normalized:Vector2) -> Vector2:
	return get_global_transform().affine_inverse()*(get_viewport_rect().position+normalized*get_viewport_rect().size)
func draw_title_environment(reduced:bool) -> void:
	if reduced:return
	var aspect:float=get_viewport_rect().size.x/get_viewport_rect().size.y
	var wide:bool=aspect>1.25
	var tall:bool=aspect<.51
	# Source-aligned reflections stay in actual painted water, outside navigation.
	for index in range(4):
		var phase:=clock*.55+index*1.7
		var normalized:=Vector2(.09+index*.012,.84+index*.016) if wide else Vector2(.10+index*.012,(.76+index*.024)*.82+.09 if tall else .76+index*.024)
		var center:=scene_point(normalized)
		var width:=10.0+sin(phase)*2
		draw_line(center-Vector2(width,0),center+Vector2(width,0),Color(.57,.79,1,.055+.015*sin(phase)),1,true)
	var lamps:Array=[Vector2(.24,.38),Vector2(.66,.45),Vector2(.90,.31)] if wide else [Vector2(.02,.27),Vector2(.943,.28),Vector2(.834,.512)]
	for point in lamps:
		if tall:point.y=point.y*.82+.09
		var intensity:=.009+.004*sin(clock*.75+point.x*20)
		var center:=scene_point(point)
		draw_circle(center,10,Color(1,.67,.28,intensity));draw_circle(center,5,Color(1,.82,.48,intensity*1.5))
	# Three quiet petals by the painted blossoms. The shared contact illustration
	# stays still; no warped limbs or invented stroking animation.
	for index in range(3):
		var cycle:=fmod(clock*.028+index*.31,1)
		var normalized:=Vector2((.22 if wide else .18)+index*.02+sin(cycle*TAU+index)*.008,(.14+cycle*.19) if wide else .22+cycle*.16)
		if tall:normalized.y=normalized.y*.82+.09
		var alpha:=sin(cycle*PI)*.20
		draw_set_transform(scene_point(normalized),sin(clock*.22+index)*.4,Vector2(1,.52));draw_circle(Vector2.ZERO,1.2,Color(1,.69,.79,alpha));draw_set_transform(Vector2.ZERO)
