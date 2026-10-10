extends RefCounted
# Cosmetic follower only: never touches combat RNG, stats, rewards or collision.
var position := Vector2(140,540)
var facing := "right"
var state := "idle"
var reaction_timer := 0.0
var initialized := false
var motion_clock := 0.0
var last_drawn_asset := ""

func react(context: String) -> void:
	if context in ["return", "reward", "talk"]:
		state="reaction"; reaction_timer=.75

func update(delta: float, owner_position: Vector2, offset: Vector2=Vector2(-72,45)) -> void:
	motion_clock+=clampf(delta,0,.1)
	var target:=owner_position+offset
	if not initialized: position=target; initialized=true
	var distance:=target-position
	if absf(distance.x)>3: facing="right" if distance.x>0 else "left"
	position=position.move_toward(target,90*clampf(delta,0,.1))
	reaction_timer=maxf(0,reaction_timer-delta)
	state="reaction" if reaction_timer>0 else "move" if distance.length()>8 else "idle"

func update_home(delta: float, selection: Dictionary, layout: Dictionary) -> void:
	var catalog=preload("res://companion_catalog.gd")
	var decor=preload("res://home_catalog.gd")
	var id: String=str(selection.get("equipped_id",""))
	var perching: bool=layout.get("companion_mode","")=="perch" and catalog.can_perch(id)
	var slot: String=str(layout.get("companion_perch_slot","home.floor_perch"))
	perching=perching and decor.SLOTS.has(slot) and id in decor.SLOTS[slot].allowed_companions and decor.available(str(layout.get("placements",{}).get(slot,"")))
	var final_target:=Vector2(110,602)
	if perching:final_target=Vector2(decor.SLOTS[slot].companion_pivot_design[0],decor.SLOTS[slot].companion_pivot_design[1])
	if not initialized:position=Vector2(110,602);initialized=true
	var waypoint:=final_target
	if perching and slot=="home.wall_perch" and absf(position.x-final_target.x)>1:waypoint=Vector2(final_target.x,602)
	elif not perching and position.y<593:waypoint=Vector2(position.x,602)
	update(delta,waypoint,Vector2.ZERO)
	if position.distance_to(final_target)<=1:
		position=final_target
		if perching:
			facing=str(decor.SLOTS[slot].facing_default)
			state="perch_interact" if reaction_timer>0 else "perch_rest"

func draw_world(canvas: Control, selection: Dictionary, reduced_motion: bool=false) -> void:
	if not selection.get("accompany",false):last_drawn_asset="";return
	draw_home(canvas,selection,reduced_motion)

func draw_home(canvas: Control, selection: Dictionary, reduced_motion: bool=false) -> void:
	var id: String=selection.get("equipped_id","")
	last_drawn_asset=""
	if id.is_empty():return
	var texture:=preload("res://companion_catalog.gd").texture(id,state,facing)
	# Missing action/opposite view remains absent, never a fake idle or mirror.
	if texture==null:return
	last_drawn_asset=texture.resource_path
	var hover:float=sin(motion_clock*1.8)*1.2 if not reduced_motion and id in ["lunarwisp","breezewyn"] and state=="idle" else 0.0
	canvas.draw_set_transform(position,0,Vector2(1,.18));canvas.draw_circle(Vector2.ZERO,16,Color("#03071145"));canvas.draw_set_transform(Vector2.ZERO)
	var breath:float=1.0+sin(motion_clock*1.7)*.004 if not reduced_motion and state in ["idle","perch_rest"] else 1.0
	if state=="perch_interact":
		var prop:=preload("res://companion_catalog.gd").preview(id,true)
		var point:=position+Vector2(22 if facing=="right" else -22,-16)
		preload("res://lootlings_ui.gd").draw_icon(canvas.get_canvas_item(),prop,Rect2(point-Vector2(10,10),Vector2(20,20)))
	canvas.draw_set_transform(position+Vector2(0,hover),0,Vector2(1,breath))
	canvas.draw_texture_rect(texture,Rect2(-Vector2(128,224)*(56.0/256.0),Vector2(56,56)),false)
	canvas.draw_set_transform(Vector2.ZERO)
