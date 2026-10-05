extends RefCounted
# Bounded original draw effects. Reads existing clocks; no damage or RNG.
static func glasswing(g) -> bool:
	return not g.enemy_is_boss and "GLASSWING" in str(g.enemy_name).to_upper()

static func draw_wings(g, pos: Vector2, scale_factor: float) -> void:
	g.draw_set_transform(pos+Vector2(0,-32),sin(g.run_time*4)*.025,Vector2.ONE*scale_factor)
	for side in [-1,1]:
		var flutter: float=sin(g.run_time*9)*7
		var points:=PackedVector2Array([Vector2(side*8,0),Vector2(side*65,-52-flutter),Vector2(side*54,8),Vector2(side*10,25)])
		g.draw_colored_polygon(points,Color("#88e6ef88"))
		g.draw_polyline(PackedVector2Array([points[0],points[1],points[2],points[3],points[0]]),Color("#ccfaff"),1.5,true)
		g.draw_line(points[0],points[2],Color("#bceaff"),1.2,true)
	g.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)

static func verdant(g, pos: Vector2) -> void:
	if not g.enemy_is_boss or g.campaign_id!="mossglass_wilds": return
	g.draw_set_transform(pos,0,Vector2(-g.enemy_facing_at(pos.x),1))
	pos=Vector2.ZERO
	var presentation=g.combat_presentation
	var active: float=clampf(presentation.boss_action_time/.55,0,1)
	var cue: Dictionary=preload("res://combat_presentation.gd").attack_cue(g)
	var action: String=presentation.boss_action if active>0 else str(preload("res://boss_patterns.gd").next(g).text)
	var charge: float=float(cue.progress) if cue.visible else 0
	var ground:=pos+Vector2(-10,53)
	match action:
		"ROOT SWEEP":
			for root in range(4):
				var reach: float=(1-active)*180 if active>0 else charge*35
				var start:=ground+Vector2(-root*7,root*4)
				var end:=start+Vector2(-reach,-4-root*3)
				g.draw_polyline(PackedVector2Array([start,start.lerp(end,.3)+Vector2(0,-9),start.lerp(end,.7)+Vector2(0,5),end]),Color("#416651"),5,true)
				g.draw_line(end,end+Vector2(-9,-13),Color("#a2d99a"),2,true)
		"THORN CAST":
			for thorn in range(5):
				var point:=pos+Vector2(-42,-70)+(Vector2(-130,-25+thorn*13)*(1-active) if active>0 else Vector2(thorn*7-14,-charge*13))
				g.draw_colored_polygon(PackedVector2Array([point+Vector2(-13,0),point+Vector2(8,-4),point+Vector2(4,5)]),Color("#9bdfa1"))
		"MIRROR CHARGE":
			var core:=pos+Vector2(-14,-91)
			for shard in range(7):
				var angle: float=shard*TAU/7+g.run_time*.8
				var point:=core+Vector2.RIGHT.rotated(angle)*(18+(1-charge)*38)
				g.draw_line(point,point+Vector2.RIGHT.rotated(angle)*7,Color("#96eeed"),2,true)
			g.draw_circle(core,7+charge*7,Color(.4,.9,.88,.22+charge*.25))
	if g.boss_recovery>0:
		g.draw_line(pos+Vector2(-30,-84),pos+Vector2(-12,-71),Color("#7a9fa888"),2,true)
	g.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
