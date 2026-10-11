extends RefCounted
const UI = preload("res://lootlings_ui.gd")

static func draw_reward(g, pickup: Dictionary) -> void:
	var pop := clampf(float(pickup.life)/float(pickup.max_life)*2,0,1)
	if pop <= .01: return
	var pos: Vector2 = pickup.pos
	if pickup.kind == "coin":
		# Siege-only Ember pickups; normal expeditions show XP wisps.
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
	var reduced: bool = g.audio_settings.get("cinematic_reduced_motion",false)
	var pulse := 1.0 if reduced else 1+sin(g.run_time*3+pos.x)*.035
	# Real item cutout dominates; low ellipse and rarity seal replace debug badges.
	g.draw_set_transform(pos+Vector2(0,18),0,Vector2(1,.24))
	g.draw_circle(Vector2.ZERO,24,Color("#07122588"))
	g.draw_arc(Vector2.ZERO,27,0,TAU,28,Color(color.r,color.g,color.b,.55),2,true)
	g.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
	if rank > 0:
		var beam := Color(color.r,color.g,color.b,.07+rank*.035)
		g.draw_colored_polygon(PackedVector2Array([pos+Vector2(-15,14),pos+Vector2(-3,-48-rank*17),pos+Vector2(3,-48-rank*17),pos+Vector2(15,14)]),beam)
		for i in range(rank+1):
			var star := pos+Vector2((i-float(rank)*.5)*12,-22-(0 if reduced else sin(g.run_time*2+i)*9))
			g.draw_line(star-Vector2(0,3),star+Vector2(0,3),color.lightened(.4),1.5,true)
			g.draw_line(star-Vector2(3,0),star+Vector2(3,0),color.lightened(.4),1.5,true)
	UI.draw_icon(g.get_canvas_item(),UI.item_texture(drop.item),Rect2(pos-Vector2(25,25)*pulse,Vector2(50,50)*pulse))
	if rarity=="RED":
		g.draw_arc(pos,29*pulse,-2.5,-.6,18,color,2.5,true)
		g.draw_arc(pos,29*pulse,.65,2.5,18,color,2.5,true)
	if rarity == "MYTHICAL SHINY":
		# Original prismatic seal; the approved item remains the centrepiece.
		for i in range(6):
			var tint := Color.from_hsv(float(i)/6, .35, 1)
			g.draw_arc(pos, 30*pulse, i*TAU/6+.05, (i+1)*TAU/6-.05, 6, tint, 2.5, true)
	if int(drop.get("bounces",0)) > 0 or float(drop.get("pickup",1)) < .58:
		var caption := caption_rect(drop)
		g.draw_rect(caption, Color("#071027dd"))
		g.draw_line(caption.position, caption.position+Vector2(caption.size.x,0), color, 1.5, true)
		var name: String = str(drop.item.get("name","Treasure"))
		var name_size := UI.fitted_font_size(g.body_font,name,caption.size.x-8,13,9)
		g.draw_string(g.body_font,caption.position+Vector2(4,14),name,HORIZONTAL_ALIGNMENT_CENTER,caption.size.x-8,name_size,color.lightened(.3))
		var type_text: String = rarity.capitalize()+" · "+g.ItemCatalog.display_slot(drop.item.get("slot","Relic"))
		var type_size := UI.fitted_font_size(g.body_font,type_text,caption.size.x-8,12,9)
		g.draw_string(g.body_font,caption.position+Vector2(4,29),type_text,HORIZONTAL_ALIGNMENT_CENTER,caption.size.x-8,type_size,Color("#e6edff"))

static func caption_rect(drop: Dictionary) -> Rect2:
	if bool(drop.get("boss_choice",false)):
		# Fixed, separated lanes for a three-item hoard, below the landing plane.
		return Rect2(12+clampi(int(drop.get("visual_slot",0)),0,2)*156,610,144,34)
	var pos: Vector2 = drop.pos
	return Rect2(clampf(pos.x-113,7,247),clampf(pos.y+28,360,610),226,34)
