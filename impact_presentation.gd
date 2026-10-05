extends RefCounted
# Original compact material contacts and elemental shapes, capped at 9 strokes.
static func contact(g, pos: Vector2) -> void:
	if g.enemy_flash<=0: return
	var life: float=clampf(g.enemy_flash/.13,0,1)
	var material:=preload("res://regional_enemy_presentation.gd").material(g)
	var heavy: bool=g.inventory.equipped_item("Weapon").get("weapon_type","") in ["greatsword","greataxe","maul"]
	var critical: bool=g.crit_flash>0
	var count: int=9 if critical or heavy else 5
	var tint: Color={"armour":Color("#fff0ad"),"glass":Color("#b5f5ff"),"stone":Color("#bbb7bb"),"wood":Color("#b5d28c"),"flesh":Color("#ecc39c"),"molten":Color("#ffbb62"),"ethereal":Color("#cab6ff")}[material]
	for i in range(count):
		var direction:=Vector2.RIGHT.rotated(-2.85+i*1.35/float(count))*Vector2(-g.enemy_facing_at(pos.x),1)
		var travel: float=(1-life)*(26+(i%3)*10)*(1.15 if heavy else 1)
		var start:=pos+direction*(8+travel)
		var end:=start+direction*(8+(i%2)*5)*life
		if material in ["armour","glass","molten"]:
			g.draw_line(start,end,Color(tint,life),2.4 if i<3 else 1.2,true)
			if i<3: g.draw_circle(end,1.4,Color("#fff6d4",life))
		else:
			g.draw_colored_polygon(PackedVector2Array([start,start+Vector2(4,1),start+Vector2(1,5)]),Color(tint,life*.85))

static func element(g,pos: Vector2,identity: String,ratio: float) -> void:
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
