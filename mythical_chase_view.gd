extends Control
# Passive earned-collection display. No purchases, hit targets, RNG or save writes.
var game
var progress:Dictionary={}
func _ready() -> void:mouse_filter=Control.MOUSE_FILTER_IGNORE
func refresh(value:Dictionary) -> void:
 progress=value.duplicate(true);queue_redraw()
func _draw() -> void:
 if game==null:return
 var summary:Dictionary=preload("res://rift_progress.gd").chase_summary(progress)
 var style:StyleBox=preload("res://lootlings_ui.gd").material_style("leather")
 draw_style_box(style,Rect2(Vector2.ZERO,size))
 var font:Font=game.body_font
 draw_string(font,Vector2(10,18),"MYTHICAL SHINY  |  %d / 8 discovered" % summary.discovered,HORIZONTAL_ALIGNMENT_CENTER,size.x-20,13,Color("#ffe6ad"))
 var ids:Array=preload("res://mythical_collection.gd").IDS
 for i in range(ids.size()):
  var x:float=11+i*44
  var known:bool=i<int(summary.discovered)
  var next:bool=ids[i]==summary.next_id
  draw_texture_rect(preload("res://mythical_collection.gd").texture(ids[i]),Rect2(x+5,25,28,40),false,Color(1,1,1,1 if known or next else .28))
  if next:draw_rect(Rect2(x,23,38,44),Color("#90e9ff"),false,1.4)
  if known:draw_circle(Vector2(x+32,61),2,Color("#ffe6ad"))
 var footer:String="Next: %s | within %d elite %s" % [summary.next_name,summary.clears_remaining,"clear" if summary.clears_remaining==1 else "clears"]
 if summary.pending>0:footer="%d reward reserved | make room in Gear" % summary.pending
 draw_string(font,Vector2(8,82),footer,HORIZONTAL_ALIGNMENT_CENTER,size.x-16,12,Color("#dceaff"))
