extends RefCounted
# Original code-drawn fantasy motifs. Presentation only; no damage/RNG changes.
const COLORS := {"Physical":Color("#e9bd71"),"Fire":Color("#ff8151"),"Frost":Color("#b5f3ff"),"Lightning":Color("#72dbff"),"Poison":Color("#97e26b"),"Corruption":Color("#bf85ed"),"Arcane":Color("#a8acff")}

static func identity(g) -> String:
	var dominant: String = g.build.dominant()
	if dominant != "Neutral": return dominant
	if g.inventory.has_signature("frostbell_chime"): return "Frost"
	return "Arcane" if g.current_weapon_family() == "MAGE" else "Physical"

static func draw_arrow(g, tip: Vector2, direction: Vector2, element: String, scale: float = 1.0, trail: bool = true, bolt: bool = false) -> void:
	var d := direction.normalized()*scale
	var n := d.orthogonal()
	var color: Color = COLORS.get(element,COLORS.Physical)
	if trail: draw_trail(g,tip-d*33,d,element)
	# Bronze collar, dark shaft, split feather silhouette and recurved relic head.
	g.draw_line(tip-d*33,tip-d*5,Color("#0a1425"),5*scale,true)
	g.draw_line(tip-d*31,tip-d*5,Color("#d1ae77"),2*scale,true)
	var head := PackedVector2Array([tip,tip-d*11+n*5,tip-d*8,tip-d*11-n*5])
	g.draw_colored_polygon(head,color.lightened(.35))
	g.draw_polyline(PackedVector2Array([head[1],tip,head[3]]),Color("#152539"),1.2*scale,true)
	g.draw_line(tip-d*12-n*2,tip-d*12+n*2,Color("#ce9a4d"),3*scale,true)
	for side in [-1,1]:
		g.draw_colored_polygon(PackedVector2Array([tip-d*31,tip-d*36+n*5*side,tip-d*23+n*3*side,tip-d*21]),Color("#a2bfbe") if element == "Physical" else color)
	if bolt: g.draw_line(tip-d*23,tip-d*10,Color("#8a96ac"),3.5*scale,true)
	if element != "Physical": g.draw_circle(tip-d*6,2.2*scale,color)

static func draw_trail(g, pos: Vector2, d: Vector2, element: String) -> void:
	var n := d.orthogonal()
	var color: Color = COLORS.get(element,COLORS.Physical)
	var soft := color; soft.a = .32
	match element:
		"Lightning":
			g.draw_polyline(PackedVector2Array([pos,pos-d*9+n*4,pos-d*15-n*3,pos-d*27]),soft,2,true)
		"Fire":
			for i in range(3): g.draw_circle(pos-d*(5+i*9)+n*(i%2*3-1),2.6-i*.6,Color(1,.48,.19,.55-i*.12))
		"Poison","Corruption":
			for i in range(2):
				g.draw_circle(pos-d*(8+i*13)+n*(i*6-3),3-i,soft)
				g.draw_arc(pos-d*(8+i*13),5,0,PI,8,soft,1.0)
		"Frost":
			g.draw_line(pos-d*4,pos-d*27,soft,1.4,true)
			for i in range(2):
				var center := pos-d*(9+i*13)
				g.draw_line(center-n*3,center+n*3,soft,1.5,true)
		_:
			g.draw_line(pos,pos-d*22,soft,1.5,true)

static func draw_projectile(g, p: Dictionary) -> void:
	var pos: Vector2 = p.pos
	var d: Vector2 = (Vector2(p.target)-Vector2(p.start)).normalized()
	var element: String = p.get("element","Arcane" if p.family == "MAGE" else "Physical")
	var color: Color = COLORS.get(element,COLORS.Physical)
	if p.get("weapon_type","") == "sling":
		draw_trail(g,pos-d*7,d,element)
		g.draw_colored_polygon(PackedVector2Array([pos+Vector2(-6,-3),pos+Vector2(0,-7),pos+Vector2(7,-2),pos+Vector2(4,6),pos+Vector2(-5,5)]),Color("#b9b7a4"))
		g.draw_line(pos+Vector2(-3,-2),pos+Vector2(2,-4),Color("#f3e0b9"),2,true)
	elif p.family == "RANGER": draw_arrow(g,pos,d,element,1.0,true,p.get("weapon_type","") == "crossbow")
	else:
		draw_trail(g,pos-d*7,d,element)
		var radius := 6.0 if p.get("weapon_type","") == "wand" else 10.0
		if element in ["Frost","Fire","Arcane"]:
			# Approved flying motifs, not stationary wards or fabricated body poses.
			# Crystal/comet point up-right; fire points down-left. Rotate this layer;
			# actor facing and projectile origin/trajectory stay untouched.
			var motif: String={"Frost":"frost_projectile","Fire":"fire_missile","Arcane":"arcane_comet"}[element]
			g.draw_set_transform(pos,d.angle()+(-PI*.75 if element=="Fire" else PI/4),Vector2.ONE)
			preload("res://bible_runtime_art.gd").draw(g,motif,Rect2(-radius*1.8,-radius*1.1,radius*3.6,radius*2.2))
			g.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
			return
		if element in ["Arcane","Corruption"]:
			preload("res://bible_runtime_art.gd").draw(g,"shadow_orb" if element=="Corruption" else "crystal_ward",Rect2(pos-Vector2.ONE*radius*1.4,Vector2.ONE*radius*2.8))
			return
		g.draw_circle(pos,radius+3,Color(color.r,color.g,color.b,.14))
		g.draw_colored_polygon(PackedVector2Array([pos+d*radius*1.5,pos+n(d)*radius*.65,pos-d*radius,pos-n(d)*radius*.65]),color)
		g.draw_line(pos-d*radius*.4,pos+d*radius,Color("#fff1cf"),2,true)
		if p.get("weapon_type","") == "orb": g.draw_arc(pos,radius+6,g.run_time*3,g.run_time*3+4.2,18,color,1.5,true)

static func n(d: Vector2) -> Vector2:
	return d.orthogonal()

static func draw_impact(g, effect: Dictionary) -> void:
	var ratio := clampf(float(effect.life)/.24,0,1)
	var pos: Vector2 = effect.pos
	var element: String = effect.element
	var color: Color = COLORS.get(element,COLORS.Physical); color.a = ratio
	var radius := 5+(1-ratio)*21
	var direction: Vector2=effect.get("direction",Vector2.RIGHT)
	if direction.length_squared()<.001: direction=Vector2.RIGHT
	direction=direction.normalized()
	# The contact reads along the actual missile flight, even after target selection
	# changes. Keep it below floating numbers and inside a 42-unit footprint.
	var normal:=direction.orthogonal()
	var weapon: String=effect.get("weapon_type","bow")
	if element=="Physical":
		var material: String=effect.get("material","flesh")
		var contact_color: Color={"armour":Color("#ffe3a0"),"glass":Color("#b5f5ff"),"stone":Color("#beb5a7"),"wood":Color("#c9b18b"),"flesh":Color("#eed4a1"),"molten":Color("#ffb567"),"ethereal":Color("#cbb8ff")}.get(material,COLORS.Physical)
		for i in range(5):
			var d:=direction.rotated(-.9+i*.45)
			var point:=pos+d*(radius+float(i%2)*5)
			if material in ["armour","glass","molten"]:
				g.draw_line(point-d*6,point+d*3,Color(contact_color,ratio),2 if i%2==0 else 1,true)
			else:
				g.draw_colored_polygon(PackedVector2Array([point,point-d*6+d.orthogonal()*2,point-d*4-d.orthogonal()*2]),Color(contact_color,ratio*.8))
		if weapon=="sling":
			g.draw_arc(pos,radius*.8,-.3,3.6,16,Color(contact_color,ratio*.5),2,true)
		else:
			g.draw_line(pos-direction*9,pos+direction*7,Color("#fff0d0",ratio),2.5,true)
	elif element in ["Frost","Fire","Lightning","Poison","Corruption","Arcane"]:
		preload("res://impact_presentation.gd").element(g,pos,element,ratio)
		if element in ["Arcane","Corruption"]:
			g.draw_arc(pos,radius*.8,-.4,4.4,18,color,1.5,true)
		if element=="Frost":
			g.draw_line(pos-normal*8,pos+normal*8,Color("#f4ffff",ratio),1.5,true)
	# One white-hot contact core; no extra particles or simulation state.
	g.draw_circle(pos,2+ratio*2,Color("#fff2d5",ratio*.85))
