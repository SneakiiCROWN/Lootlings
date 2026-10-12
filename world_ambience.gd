extends Control
# Decorative only: private seeded layout, no physics, inputs, gameplay RNG or audio.
var clock := 0.0
var motes: Array[Dictionary] = []
var settings_provider: Callable
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
	for mote in motes:
		var phase:float=mote.phase
		var t:float=phase if reduced else clock*mote.speed+phase
		var point:Vector2=mote.point+Vector2(sin(t)*9,cos(t*.73+phase)*7)
		var alpha:float=.35 if reduced else .22+(.5+.5*sin(t*.91+phase))*.34
		draw_circle(point,mote.radius*4,Color(1,.77,.32,alpha*.07))
		draw_circle(point,mote.radius*2,Color(1,.82,.44,alpha*.18))
		draw_circle(point,mote.radius,Color(1,.92,.62,alpha))
