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
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE; clip_contents=true; set_process(false)
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
		burst=maxf(0,1-(elapsed-reel_seconds-Catalog.anticipation(rarity))/Catalog.reveal_seconds(rarity))
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
	var aperture:=Rect2(18,38,size.x-36,size.y-66)
	draw_style_box(Catalog.flat_style(Color("#030917"),tint.darkened(.3)),aperture)
	var width:=aperture.size.x/3
	var eased:=1-pow(1-progress,3)
	for reel in range(3):
		var turns: float=(14+reel)*eased
		var x:=aperture.position.x+width*(reel+.5)
		for edge in [-1,1]:
			draw_line(Vector2(x+edge*(width*.5-4),65),Vector2(x+edge*(width*.5-4),size.y-50),Color("#514b415c"),3,true)
		var displacement:=fposmod(turns,1.0)*76.0
		if stage=="rolling":
			for row in range(-1,3):
				var y:=center.y+row*76-displacement
				if y<60 or y>size.y-24: continue
				var passing: int=posmod(int(turns)+row+reel*2,6)
				var landing: bool=int(turns)+row==14+reel
				draw_seal(Vector2(x,y),30 if landing else 24,Catalog.color(rarity) if landing else Catalog.COLORS[passing],Catalog.icon_for(reward_kind) if landing else Catalog.icon_for(["material","mastery","blueprint","material","material","item"][passing]))
		else:
			var punch: float=1+burst*[.015,.03,.05,.075,.10,.14][tier] if not reduced_motion else 1.0
			var shake:=Vector2(sin(elapsed*35)*2*burst,0) if tier==5 and not reduced_motion else Vector2.ZERO
			draw_seal(Vector2(x,center.y)+shake,30*punch,tint,Catalog.icon_for(reward_kind) if stage!="idle" else "gear_rune")
		if reel<2: draw_line(Vector2(x+width*.5,48),Vector2(x+width*.5,size.y-25),Color("#22304b"),1)
	draw_rect(Rect2(19,39,size.x-38,24),Color(0.02,.04,.08,.7))
	draw_rect(Rect2(19,size.y-49,size.x-38,20),Color(0.02,.04,.08,.7))
	draw_line(Vector2(7,center.y),Vector2(17,center.y),Color("#ffda72"),4)
	draw_line(Vector2(size.x-17,center.y),Vector2(size.x-7,center.y),Color("#ffda72"),4)
	if stage=="anticipation": draw_arc(center,42,0,TAU,48,Color(tint,.35),3)
	if burst>0:
		var count: int=mini(6,[0,6,10,16,22,26][tier]) if reduced_motion else [0,6,10,16,22,26][tier]
		var radius:=30+(1-burst)*95
		for particle in range(count):
			var angle:=particle*TAU/maxi(1,count)+particle*.17
			var point:=center+Vector2.RIGHT.rotated(angle)*radius
			draw_line(point,point+Vector2.RIGHT.rotated(angle)*(4+tier*2),Color(tint,burst*.8),2)
		for halo in range(3): draw_arc(center,42+halo*6+(1-burst)*12,0,TAU,48,Color(tint,burst*.15),3)
		if tier==5:
			var points:=PackedVector2Array([center+Vector2(-65,-35),center+Vector2(-40,-42),center+Vector2(-45,-20),center+Vector2(-14,-35)])
			draw_polyline(points,Color(tint,burst),2)
	var caption: String="CROWNROOT AWAKENS" if tier==5 and stage in ["reveal","settled"] else "RELIC ENGINE"
	draw_string(ThemeDB.fallback_font,Vector2(10,25),caption,HORIZONTAL_ALIGNMENT_CENTER,size.x-20,14,tint)
	var status: String="TURN THE SEALS" if stage=="idle" else "SEALS ALIGNING…" if stage=="rolling" else "HOLD…" if stage=="anticipation" else rarity
	draw_string(ThemeDB.fallback_font,Vector2(10,size.y-20),status,HORIZONTAL_ALIGNMENT_CENTER,size.x-20,13,tint)
func draw_seal(point: Vector2, radius: float, tint: Color, icon_name: String) -> void:
	var diamond:=PackedVector2Array([point+Vector2(0,-radius),point+Vector2(radius,0),point+Vector2(0,radius),point+Vector2(-radius,0)])
	draw_colored_polygon(diamond,tint.darkened(.75))
	draw_polyline(PackedVector2Array([diamond[0],diamond[1],diamond[2],diamond[3],diamond[0]]),tint,2)
	UI.draw_icon(get_canvas_item(),UI.icon(icon_name),Rect2(point-Vector2.ONE*radius*.60,Vector2.ONE*radius*1.2))
