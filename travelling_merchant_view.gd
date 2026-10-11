extends Control
# Real service keyframes, not a complete articulated animation cycle.
const Art=preload("res://resident_art_catalog.gd")
var game
var activity: String="rest"
var facing: String="right"
var elapsed: float=0.0
var last_open: bool=false
var previous_frame:Dictionary={}
var active_frame:Dictionary={}
var transition:float=1.0
var last_activity:String=""
var last_selection:int=-1
var reaction_time:float=0.0
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
 if game.merchant_selection!=last_selection:
  reaction_time=.65;last_selection=game.merchant_selection
 reaction_time=maxf(0,reaction_time-delta)
 if game.merchant_selection>=0:activity="inspect" if reaction_time>0 else "offer"
 if is_instance_valid(game.touch_ux.dialog):activity="inspect"
 if game.merchant_continue_button.is_hovered() or game.merchant_continue_button.has_focus():activity="return"
 facing="right"
 if OS.get_environment("LOOTLINGS_QA")=="1":
  if not qa_state.is_empty():activity=qa_state
  if not qa_facing.is_empty():facing=qa_facing
 if activity+facing!=last_activity:
  previous_frame=active_frame;active_frame=Art.body_frame("pack_peddler",activity,facing);transition=0;last_activity=activity+facing
 transition=1.0 if game.audio_settings.get("cinematic_reduced_motion",false) else minf(1,transition+delta/.18)
 queue_redraw()
func _draw() -> void:
 if active_frame.is_empty():return
 var ground:=Vector2(size.x*.5,size.y-4)
 draw_set_transform(ground,0,Vector2(1,.22));draw_circle(Vector2.ZERO,23,Color(0,0,0,.23));draw_set_transform(Vector2.ZERO)
 var reduced:bool=game.audio_settings.get("cinematic_reduced_motion",false)
 var breathe:float=1.0 if reduced else 1.0+sin(elapsed*1.65)*.003
 draw_set_transform(ground,0,Vector2(1,breathe))
 if transition<1 and not previous_frame.is_empty():draw_body(previous_frame,1-transition)
 draw_body(active_frame,transition)
 draw_set_transform(Vector2.ZERO)
func draw_body(frame:Dictionary,alpha:float) -> void:
 var region:Array=frame.row.content_rect
 var scale:float=minf(size.x/region[2],(size.y-6)/region[3])
 var extent:Vector2=Vector2(region[2],region[3])*scale
 draw_texture_rect(frame.texture,Rect2(Vector2(-extent.x*.5,-extent.y),extent),false,Color(1,1,1,alpha))
