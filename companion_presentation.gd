extends RefCounted
# Cosmetic follower only: never touches combat RNG, stats, rewards or collision.
var position := Vector2(140,540)
var facing := "right"
var state := "idle"
var reaction_timer := 0.0
var initialized := false

func react(context: String) -> void:
	if context in ["return", "reward", "talk"]:
		state="reaction"; reaction_timer=.75

func update(delta: float, owner_position: Vector2) -> void:
	var target:=owner_position+Vector2(-72,45)
	if not initialized: position=target; initialized=true
	var distance:=target-position
	if absf(distance.x)>3: facing="right" if distance.x>0 else "left"
	position=position.move_toward(target,90*clampf(delta,0,.1))
	reaction_timer=maxf(0,reaction_timer-delta)
	state="reaction" if reaction_timer>0 else "move" if distance.length()>8 else "idle"

func draw_home(canvas: Control, selection: Dictionary) -> void:
	var id: String=selection.get("equipped_id","")
	if id.is_empty():return
	var texture:=preload("res://companion_catalog.gd").texture(id,state,facing)
	# Missing action/opposite view remains absent, never a fake idle or mirror.
	if texture==null:return
	preload("res://lootlings_ui.gd").draw_icon(canvas.get_canvas_item(),texture,Rect2(position-Vector2(128,224)*(56.0/256.0),Vector2(56,56)))
