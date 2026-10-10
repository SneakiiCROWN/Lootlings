extends RefCounted
# Bounded cosmetic tap/hover feedback inside existing comfortable hit areas.
static func bind(button: Button) -> void:
 if button.has_meta("world_feedback_bound"):return
 button.set_meta("world_feedback_bound",true);button.set_meta("world_feedback_strength",0.0)
 button.button_down.connect(func():
  button.set_meta("world_feedback_point",button.get_local_mouse_position().clamp(Vector2(12,12),button.size-Vector2(12,12)))
  button.set_meta("world_feedback_strength",1.0)
  var tween:=button.create_tween()
  tween.tween_method(func(value:float):button.set_meta("world_feedback_strength",value);button.queue_redraw(),1.0,0.0,.4))
 button.mouse_entered.connect(func():button.queue_redraw())
 button.mouse_exited.connect(func():button.queue_redraw())
 button.draw.connect(func():
  var strength:float=button.get_meta("world_feedback_strength",0.0)
  if strength>0:
   var point:Vector2=button.get_meta("world_feedback_point",button.size*.5)
   button.draw_arc(point,7+(1-strength)*18,0,TAU,20,Color(.55,.85,1,strength*.5),1.4,true)
  if button.is_hovered() and not button.disabled:
   var point:=Vector2(button.size.x*.5,button.size.y-42)
   button.draw_line(point+Vector2(-5,-5),point+Vector2(5,-5),Color(1,.85,.5,.65),1.2,true))
