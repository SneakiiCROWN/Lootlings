extends RefCounted
const UI = preload("res://lootlings_ui.gd")

static func draw_reward(g, pickup: Dictionary) -> void:
	var pop := clampf(float(pickup.life)/float(pickup.max_life)*2,0,1)
	if pop <= .01: return
	var pos: Vector2 = pickup.pos
	if pickup.kind == "coin":
		# These pickups are Run Scrip, not permanent Gold. Use its real icon.
		UI.draw_icon(g.get_canvas_item(),UI.icon("currency_run_scrip"),Rect2(pos-Vector2(13,13)*pop,Vector2(26,26)*pop))
	else:
		# Experience is a memory wisp, visually distinct from spendable Star Shards.
		g.draw_arc(pos,8*pop,-1.9,.9,12,Color(.4,.86,1,.24*pop),2,true)
		g.draw_circle(pos,4*pop,Color("#65c5e7"))
		g.draw_circle(pos+Vector2(-1,-1)*pop,1.6*pop,Color("#e4ffff"))
		g.draw_line(pos+Vector2(-3,3)*pop,pos+Vector2(-10,9)*pop,Color(.3,.78,1,.4*pop),2*pop,true)

static func draw_item(g, drop: Dictionary) -> void:
	var pos: Vector2 = drop.pos
	var color: Color = drop.color
	var rarity: String = drop.get("rarity",drop.item.get("rarity","COMMON"))
	var rank: int = preload("res://item_catalog.gd").rarity_rank(rarity)
	var pulse := 1+sin(g.run_time*3+pos.x)*.035
	# Real item cutout dominates; low ellipse and rarity seal replace debug badges.
	g.draw_set_transform(pos+Vector2(0,18),0,Vector2(1,.24))
	g.draw_circle(Vector2.ZERO,24,Color("#07122588"))
	g.draw_arc(Vector2.ZERO,27,0,TAU,28,Color(color.r,color.g,color.b,.55),2,true)
	g.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
	if rank > 0:
		var beam := Color(color.r,color.g,color.b,.07+rank*.035)
		g.draw_colored_polygon(PackedVector2Array([pos+Vector2(-15,14),pos+Vector2(-3,-48-rank*17),pos+Vector2(3,-48-rank*17),pos+Vector2(15,14)]),beam)
		for i in range(rank+1):
			var star := pos+Vector2(-22+i*16,-22-sin(g.run_time*2+i)*9)
			g.draw_line(star-Vector2(0,3),star+Vector2(0,3),color.lightened(.4),1.5,true)
			g.draw_line(star-Vector2(3,0),star+Vector2(3,0),color.lightened(.4),1.5,true)
	UI.draw_icon(g.get_canvas_item(),UI.item_texture(drop.item),Rect2(pos-Vector2(25,25)*pulse,Vector2(50,50)*pulse))
	if rarity=="RED":
		g.draw_arc(pos,29*pulse,-2.5,-.6,18,color,2.5,true)
		g.draw_arc(pos,29*pulse,.65,2.5,18,color,2.5,true)
	if int(drop.get("bounces",0)) > 0 or float(drop.get("pickup",1)) < .58:
		var name_x := clampf(pos.x-110,10,250)
		var name_pos := Vector2(name_x,pos.y+42)
		# A compact ink backing keeps labels readable over bright floors/enemies.
		g.draw_rect(Rect2(name_x-3,pos.y+28,226,34),Color("#071027dd"))
		var name: String = str(drop.item.get("name","Treasure"))
		g.draw_string_outline(g.body_font,name_pos,name,HORIZONTAL_ALIGNMENT_CENTER,220,13,3,Color("#071027"))
		g.draw_string(g.body_font,name_pos,name,HORIZONTAL_ALIGNMENT_CENTER,220,13,color.lightened(.3))
		var type_text: String = rarity.capitalize()+" · "+g.ItemCatalog.display_slot(drop.item.get("slot","Relic"))
		g.draw_string_outline(g.body_font,Vector2(name_x,pos.y+57),type_text,HORIZONTAL_ALIGNMENT_CENTER,220,12,3,Color("#071027"))
		g.draw_string(g.body_font,Vector2(name_x,pos.y+57),type_text,HORIZONTAL_ALIGNMENT_CENTER,220,12,Color("#e6edff"))
