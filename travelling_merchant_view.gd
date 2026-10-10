extends Control
# Real service keyframes, not a complete articulated animation cycle.
const Art=preload("res://resident_art_catalog.gd")
var game
var activity: String="rest"
var facing: String="right"
var elapsed: float=0.0
var last_open: bool=false
var qa_state: String=""
var qa_facing: String=""
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
func _process(delta: float) -> void:
 if game==null:return
 if game.merchant_panel.visible and not last_open:elapsed=0
 last_open=game.merchant_panel.visible
 if not last_open:return
 elapsed+=delta
 activity="talk" if elapsed<1.0 else "rest"
 if game.merchant_selection>=0:activity="offer"
 if is_instance_valid(game.touch_ux.dialog):activity="inspect"
 if game.merchant_continue_button.is_hovered() or game.merchant_continue_button.has_focus():activity="return"
 facing="right"
 if OS.get_environment("LOOTLINGS_QA")=="1":
  if not qa_state.is_empty():activity=qa_state
  if not qa_facing.is_empty():facing=qa_facing
 queue_redraw()
func _draw() -> void:
 var frame:Dictionary=Art.body_frame("pack_peddler",activity,facing)
 if frame.is_empty():return
 var region:Array=frame.row.content_rect
 var scale:float=minf(size.x/region[2],(size.y-6)/region[3])
 var extent:Vector2=Vector2(region[2],region[3])*scale
 var ground:=Vector2(size.x*.5,size.y-4)
 draw_set_transform(ground,0,Vector2(1,.22));draw_circle(Vector2.ZERO,23,Color(0,0,0,.23));draw_set_transform(Vector2.ZERO)
 var reduced:bool=game.audio_settings.get("cinematic_reduced_motion",false)
 var breathe:float=1.0 if reduced else 1.0+sin(elapsed*1.65)*.003
 draw_set_transform(ground,0,Vector2(1,breathe))
 draw_texture_rect(frame.texture,Rect2(Vector2(-extent.x*.5,-extent.y),extent),false)
 draw_set_transform(Vector2.ZERO)
