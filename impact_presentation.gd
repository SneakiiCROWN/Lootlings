extends RefCounted
# Original compact material contacts and elemental shapes, capped at 9 strokes.
static func contact(g, _pos: Vector2 = Vector2.ZERO) -> void:
	for event in g.combat_presentation.contacts:
		draw_contact(g,event)
	for event in g.combat_presentation.incoming_contacts:
		var pos: Vector2=event.pos
		var life: float=clampf(float(event.life)/.18,0,1)
		var tint:=Color("#a6eaff") if event.ward else Color("#ffb197")
		g.draw_arc(pos,21,-PI*.8,PI*.8,18,Color(tint,life*.65),2,true)
		if event.damage:g.draw_line(pos+Vector2(-8,-5),pos+Vector2(10,7),Color("#ffe0bf",life),2,true)
		if not g.audio_settings.get("cinematic_reduced_motion",false):
			var origin: Vector2=event.origin
			g.draw_line(origin.lerp(pos,.72),pos,Color(tint,life*.26),1.4,true)

static func draw_contact(g, event: Dictionary) -> void:
	var pos: Vector2=event.pos
	var life: float=clampf(float(event.life)/float(event.duration),0,1)
	var material: String=event.material
	var heavy: bool=event.heavy
	var critical: bool=event.critical
	var reduced: bool=g.audio_settings.get("cinematic_reduced_motion",false)
	var count: int=3 if reduced else 9 if critical or heavy else 5
	var tint: Color={"armour":Color("#fff0ad"),"glass":Color("#b5f5ff"),"stone":Color("#bbb7bb"),"wood":Color("#b5d28c"),"flesh":Color("#ecc39c"),"molten":Color("#ffbb62"),"ethereal":Color("#cab6ff")}[material]
	# A short contact stroke bridges the real module socket and struck surface;
	# it never changes the held art, grip, hit timing or projectile simulation.
	if event.weapon in ["greatsword","greataxe","maul","spear","daggers","claws"]:
		var origin: Vector2=event.origin
		var distance: float=origin.distance_to(pos)
		if distance>3 and distance<240:
			var tangent: Vector2=(pos-origin).orthogonal().normalized()*(-8 if event.facing<0 else 8)
			g.draw_polyline(PackedVector2Array([origin,origin.lerp(pos,.55)+tangent,pos]),Color(tint,life*.42),3 if heavy else 1.7,true)
	if critical:
		g.draw_arc(pos,12 if reduced else 12+(1-life)*16,0,TAU,20,Color("#ffe494",life*.7),2,true)
	if heavy and not reduced:
		g.draw_arc(pos,10+(1-life)*22,-2.5,-.6,18,Color(tint,life*.35),2,true)
	for i in range(count):
		var direction:=Vector2.RIGHT.rotated(-2.85+i*1.35/float(count))*Vector2(-int(event.facing),1)
		var travel: float=0 if reduced else (1-life)*(26+(i%3)*10)*(1.15 if heavy else 1)
		var start:=pos+direction*(8+travel)
		var end:=start+direction*(8+(i%2)*5)*life
		if material=="glass":
			var across:=direction.orthogonal()*3
			g.draw_colored_polygon(PackedVector2Array([start-across,end+direction*5,start+across]),Color(tint,life*.72))
			g.draw_line(start,end,Color("#efffff",life),1,true)
		elif material=="wood":
			g.draw_line(start-direction*3,end+direction*3,Color("#6d482f",life),3,true)
			g.draw_line(start,end,Color(tint,life),1,true)
		elif material in ["armour","molten"]:
			g.draw_line(start,end,Color(tint,life),2.4 if i<3 else 1.2,true)
			if i<3:g.draw_circle(end,1.4,Color("#fff6d4",life))
		else:
			g.draw_colored_polygon(PackedVector2Array([start,start+Vector2(4,1),start+Vector2(1,5)]),Color(tint,life*.85))

static func element(g,pos: Vector2,identity: String,ratio: float) -> void:
	if preload("res://bible_runtime_art.gd").impact(g,pos,identity,ratio):return
	var tint: Color=preload("res://projectile_presentation.gd").COLORS.get(identity,Color("#b4b5ee"))
	match identity:
		"Fire":
			for i in range(4):
				var base:=pos+Vector2(-16+i*10,-(1-ratio)*28-i%2*5)
				var length: float=10+ratio*(10+i*3)
				g.draw_colored_polygon(PackedVector2Array([base+Vector2(-5,5),base+Vector2(-7,-5),base+Vector2(2,-length),base+Vector2(4,-5),base+Vector2(7,2)]),Color(tint,ratio*.85))
				g.draw_line(base,base+Vector2(1,-length*.65),Color("#fff1bb",ratio),2,true)
		"Frost","Ice":
			for i in range(5):
				var d:=Vector2.RIGHT.rotated(-2.6+i*.45)
				var point:=pos+d*(12+(1-ratio)*24)
				g.draw_colored_polygon(PackedVector2Array([point,point+d*12,point+d*4+d.orthogonal()*4]),Color(tint,ratio))
		"Lightning":
			for i in range(3):
				var start:=pos+Vector2(-20+i*16,-12+i*5)
				g.draw_polyline(PackedVector2Array([start,start+Vector2(9,-15),start+Vector2(3,-18),start+Vector2(14,-28)]),Color(tint,ratio),2.5,true)
		"Poison":
			for i in range(4):
				var point:=pos+Vector2(-16+i*12,8+(1-ratio)*17)
				g.draw_circle(point,3,Color(tint,ratio*.75))
				g.draw_arc(point,6,PI,TAU,8,Color(tint,ratio*.3),1,true)
		"Corruption","Dark":
			for i in range(3):
				var point:=pos+Vector2(-15+i*12,-(1-ratio)*24)
				g.draw_polyline(PackedVector2Array([point,point+Vector2(-4,-10),point+Vector2(4,-19)]),Color(tint,ratio*.6),3,true)
		"Arcane","Relic":
			for i in range(3):
				var point:=pos+Vector2(-18+i*18,-10-(1-ratio)*17)
				g.draw_polyline(PackedVector2Array([point+Vector2(-4,0),point+Vector2(0,-7),point+Vector2(4,0),point+Vector2(0,6)]),Color(tint,ratio),2,true)
