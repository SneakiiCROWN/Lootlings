extends Control
const UI=preload("res://lootlings_ui.gd")
const Catalog=preload("res://relic_spin_catalog.gd")
signal locked
signal completed
signal cue(event: String)
var elapsed:=0.0
var rolling:=false
var reward_kind:=""
var rarity:="COMMON"
var stage:="idle"
var reel_seconds:=1.65
var fast:=false
var reduced_motion:=false
var tick_at:=0.0
var progress:=0.0
var burst:=0.0
var aperture_layer: Control
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE; clip_contents=true; set_process(false)
	aperture_layer=Control.new(); aperture_layer.mouse_filter=Control.MOUSE_FILTER_IGNORE; aperture_layer.clip_contents=true; add_child(aperture_layer)
	aperture_layer.draw.connect(draw_reels)
func wind_up(kind: String="material", tier: String="COMMON", quick: bool=false) -> void:
	reward_kind=kind; rarity=tier if tier in Catalog.TIERS else "COMMON"
	fast=quick and Catalog.tier(rarity)<3
	reel_seconds=Catalog.spin_seconds(rarity,fast)
	elapsed=0; tick_at=0; progress=0; burst=0; rolling=true; stage="rolling"
	set_process(true); queue_redraw(); cue.emit("chest_windup")
func skip() -> bool:
	if not rolling or Catalog.tier(rarity)>=3: return false
	elapsed=reel_seconds+Catalog.anticipation(rarity); lock_result(); return true
func lock_result() -> void:
	if stage=="reveal" or stage=="settled": return
	stage="reveal"; progress=1; burst=1; rolling=false
	cue.emit(Catalog.sound(rarity)); locked.emit(); queue_redraw()
func reveal(kind: String) -> void:
	reward_kind=kind; rolling=false; stage="settled"; burst=0; progress=1; set_process(false); queue_redraw()
func stop() -> void:
	rolling=false; stage="idle"; elapsed=0; burst=0; set_process(false); queue_redraw()
func _process(delta: float) -> void:
	elapsed+=delta
	if stage=="rolling":
		progress=minf(1,elapsed/reel_seconds)
		if elapsed>=tick_at:
			cue.emit("equip"); tick_at=elapsed+lerpf(.09,.28,progress*progress)
		if progress>=1:
			stage="anticipation"; cue.emit("chest_land")
	elif stage=="anticipation" and elapsed>=reel_seconds+Catalog.anticipation(rarity): lock_result()
	elif stage=="reveal":
		var hold:=.26 if Catalog.tier(rarity)==5 else .18 if Catalog.tier(rarity)==4 else 0.0
		burst=clampf(1-(elapsed-reel_seconds-Catalog.anticipation(rarity)-hold)/Catalog.reveal_seconds(rarity),0,1)
		if burst<=0:
			stage="settled"; set_process(false); completed.emit()
	queue_redraw()
func _draw() -> void:
	var tier:=Catalog.tier(rarity)
	var tint:=Catalog.color(rarity) if stage not in ["idle","rolling"] else Color("#bca873")
	var center:=size*.5
	draw_style_box(UI.panel_style(Color("#070e20"),Color("#b99759"),14),Rect2(Vector2.ZERO,size))
	# Mechanical cheeks, axle bolts and reel rims distinguish the engine from
	# an ordinary reward menu without new raster art or an extra particle node.
	for side in [0,1]:
		var x: float=9 if side==0 else size.x-9
		draw_line(Vector2(x,44),Vector2(x,size.y-41),Color("#725e40"),5,true)
		for y in [48.0,size.y-46]:
			draw_circle(Vector2(x,y),3.5,Color("#c9aa66"))
			draw_line(Vector2(x-2,y),Vector2(x+2,y),Color("#433e38"),1,true)
	# Premium lighting stays on the machine, visible above the modal background.
	var charge: float=clampf((elapsed-reel_seconds)/maxf(.1,Catalog.anticipation(rarity)),0,1) if stage=="anticipation" else 0
	var energy: float=burst if stage=="reveal" else charge
	if tier>=3 and energy>0:
		for side in [0,1]:
			var x: float=6 if side==0 else size.x-6
			for light in range(7):
				var y: float=48+light*(size.y-92)/6
				var lit: float=1 if stage=="reveal" or float(light)/7<=charge else .12
				draw_circle(Vector2(x,y),4.5,Color(tint,lit*energy))
				draw_circle(Vector2(x,y),2,Color("#fff1cf").lerp(tint,.35))
		if tier>=4:
			# Crown teeth distinguish a jackpot from the ordinary six-colour frame.
			var crest:=PackedVector2Array([Vector2(center.x-32,35),Vector2(center.x-39,8),Vector2(center.x-14,22),Vector2(center.x,3),Vector2(center.x+14,22),Vector2(center.x+39,8),Vector2(center.x+32,35)])
			draw_colored_polygon(crest,Color(tint,energy*.85))
			draw_polyline(crest,Color("#fff0cb",energy*.75),1.5,true)
	var aperture:=Rect2(18,38,size.x-36,size.y-66)
	draw_style_box(Catalog.flat_style(Color("#030917"),tint.darkened(.3)),aperture)
	aperture_layer.position=aperture.position+Vector2(2,2); aperture_layer.size=aperture.size-Vector2(4,4); aperture_layer.queue_redraw()
	draw_rect(Rect2(19,39,size.x-38,24),Color(0.02,.04,.08,.7))
	draw_rect(Rect2(19,size.y-49,size.x-38,20),Color(0.02,.04,.08,.7))
	draw_line(Vector2(7,center.y),Vector2(17,center.y),Color("#ffda72"),4)
	draw_line(Vector2(size.x-17,center.y),Vector2(size.x-7,center.y),Color("#ffda72"),4)
	if stage=="anticipation":
		draw_arc(center,42,0,TAU,48,Color(tint,.35),3)
		if tier>=3:
			draw_style_box(Catalog.flat_style(Color(tint,.06+.018*tier),tint),Rect2(1,1,size.x-2,size.y-2))
		if tier==5:
			for branch in range(4):
				var point:=Vector2(10+branch*(size.x-20)/3,34)
				draw_polyline(PackedVector2Array([point,point+Vector2(8,12),point+Vector2(2,17),point+Vector2(11,22)]),Color(tint,.8),2,true)
	if burst>0:
		var count: int=mini(6,[0,6,10,16,22,26][tier]) if reduced_motion else [0,6,10,16,22,26][tier]
		var radius:=30+(1-burst)*95
		for particle in range(count):
			var angle:=particle*TAU/maxi(1,count)+particle*.17
			var point:=center+Vector2.RIGHT.rotated(angle)*radius
			draw_line(point,point+Vector2.RIGHT.rotated(angle)*(4+tier*2),Color(tint,burst*.8),2)
		for halo in range(3 if tier>=3 else 1 if tier>0 else 0): draw_arc(center,42+halo*6+(1-burst)*12,0,TAU,48,Color(tint,burst*.15),3)
		if tier==5:
			var points:=PackedVector2Array([center+Vector2(-65,-35),center+Vector2(-40,-42),center+Vector2(-45,-20),center+Vector2(-14,-35)])
			draw_polyline(points,Color(tint,burst),2)
	var caption: String="CROWNROOT AWAKENS" if tier==5 and stage in ["reveal","settled"] else ""
	draw_string(ThemeDB.fallback_font,Vector2(10,25),caption,HORIZONTAL_ALIGNMENT_CENTER,size.x-20,14,tint)
	var status: String="TURN THE SEALS" if stage=="idle" else "SEALS ALIGNING…" if stage=="rolling" else "HOLD…" if stage=="anticipation" else rarity
	draw_string(ThemeDB.fallback_font,Vector2(10,size.y-20),status,HORIZONTAL_ALIGNMENT_CENTER,size.x-20,13,tint)
func draw_reels() -> void:
	var tier:=Catalog.tier(rarity)
	var tint:=Catalog.color(rarity) if stage not in ["idle","rolling"] else Color("#bca873")
	var center:=aperture_layer.size*.5
	var width:=aperture_layer.size.x/3
	if tier>=4 and stage=="reveal" and burst>0:
		var count: int=6 if reduced_motion else 18 if tier==5 else 12
		for ray in range(count):
			var direction:=Vector2.RIGHT.rotated(ray*TAU/count)
			if tier==5:
				var start:=center+direction*36
				var end:=center+direction*(80+(1-burst)*25)
				aperture_layer.draw_polyline(PackedVector2Array([start,start.lerp(end,.35)+direction.orthogonal()*8,start.lerp(end,.6)-direction.orthogonal()*5,end]),Color(tint,burst*.7),2,true)
			else: aperture_layer.draw_line(center+direction*18,center+direction*(70+(1-burst)*32),Color(tint,burst*.42),3,true)
	var eased:=1-pow(1-progress,3)
	for reel in range(3):
		var turns: float=(14+reel)*eased
		var x:=width*(reel+.5)
		for edge in [-1,1]:
			aperture_layer.draw_line(Vector2(x+edge*(width*.5-4),0),Vector2(x+edge*(width*.5-4),aperture_layer.size.y),Color("#514b415c"),3,true)
		var displacement:=fposmod(turns,1.0)*76.0
		if stage=="rolling":
			for row in range(-1,3):
				var y:=aperture_layer.size.y*.5+row*76-displacement
				if y < -32 or y > aperture_layer.size.y+32: continue
				var passing: int=posmod(int(turns)+row+reel*2,6)
				var landing: bool=int(turns)+row==14+reel
				draw_seal(aperture_layer,Vector2(x,y),30 if landing else 24,Catalog.color(rarity) if landing else Catalog.COLORS[passing],Catalog.icon_for(reward_kind) if landing else Catalog.icon_for(["material","mastery","blueprint","material","material","item"][passing]))
		else:
			var punch: float=1+burst*[.015,.03,.05,.075,.10,.14][tier] if not reduced_motion else 1.0
			var shake:=Vector2(sin(elapsed*35)*2*burst,0) if tier==5 and not reduced_motion else Vector2.ZERO
			draw_seal(aperture_layer,Vector2(x,aperture_layer.size.y*.5)+shake,30*punch,tint,Catalog.icon_for(reward_kind) if stage!="idle" else "gear_rune")
		if reel<2: aperture_layer.draw_line(Vector2(x+width*.5,0),Vector2(x+width*.5,aperture_layer.size.y),Color("#22304b"),1)
func draw_seal(layer: Control, point: Vector2, radius: float, tint: Color, icon_name: String) -> void:
	var diamond:=PackedVector2Array([point+Vector2(0,-radius),point+Vector2(radius,0),point+Vector2(0,radius),point+Vector2(-radius,0)])
	layer.draw_colored_polygon(diamond,tint.darkened(.75))
	layer.draw_polyline(PackedVector2Array([diamond[0],diamond[1],diamond[2],diamond[3],diamond[0]]),tint,2)
	UI.draw_icon(layer.get_canvas_item(),UI.icon(icon_name),Rect2(point-Vector2.ONE*radius*.60,Vector2.ONE*radius*1.2))
