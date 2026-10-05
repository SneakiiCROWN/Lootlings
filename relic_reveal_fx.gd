extends Control
# Original bounded screen lighting and machine emphasis. Decorative, no input.
var machine: Control
var panel: Control
var card: Control
var reduced_motion:=false
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
func _process(_delta: float) -> void:
	if machine==null: return
	reduced_motion=machine.reduced_motion
	var tier: int=preload("res://relic_spin_catalog.gd").tier(machine.rarity)
	var intensity: float=machine.burst if machine.stage=="reveal" else 0.0
	panel.pivot_offset=panel.size*.5
	var emphasis: float=[0.0,.005,.018,.03,.05,.075][tier]*intensity
	panel.scale=Vector2.ONE*(1+emphasis*(.2 if reduced_motion else 1))
	card.pivot_offset=card.size*.5
	card.scale=Vector2.ONE*(1+intensity*(.025 if tier<3 else .055 if tier<5 else .09)) if not reduced_motion else Vector2.ONE
	queue_redraw()
func _draw() -> void:
	if machine==null or not machine.visible or not panel.visible: return
	var tier: int=preload("res://relic_spin_catalog.gd").tier(machine.rarity)
	if tier<2: return
	var tint: Color=preload("res://relic_spin_catalog.gd").color(machine.rarity)
	var charge: float=clampf((machine.elapsed-machine.reel_seconds)/maxf(.1,preload("res://relic_spin_catalog.gd").anticipation(machine.rarity)),0,1) if machine.stage=="anticipation" else 0.0
	var energy: float=machine.burst if machine.stage=="reveal" else charge*.35
	if energy<=0: return
	var center:=Vector2(240,400)
	if tier>=3:
		draw_rect(Rect2(Vector2.ZERO,size),Color(tint,energy*.08))
		for edge in [0,1]:
			for band in range(6):
				var width: float=5+band*7
				var x: float=0 if edge==0 else size.x-width
				draw_rect(Rect2(x,0,width,size.y),Color(tint,energy*.035))
	if tier>=4:
		for ray in range(14 if tier==4 else 22):
			var angle: float=TAU*ray/(14 if tier==4 else 22)
			var direction:=Vector2.RIGHT.rotated(angle)
			var distance: float=110+(1-energy)*180
			draw_line(center+direction*distance,center+direction*(distance+35+tier*6),Color(tint,energy*.7),3 if tier==4 else 4,true)
	if tier==5:
		# A branching crown/root frame is exclusive to RED, distinct from gold rays.
		for side in [-1,1]:
			var x: float=240+side*210
			for root in range(6):
				var y: float=220+root*75
				draw_polyline(PackedVector2Array([Vector2(x,y+30),Vector2(x-side*12,y+17),Vector2(x+side*4,y+4),Vector2(x-side*16,y-9)]),Color(tint,energy*.9),3,true)
