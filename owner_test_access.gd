extends Control
# Owner-only build feature. Secret gesture is convenience, not security.
const Scope=preload("res://save_scope.gd")
static var unlocked:bool=false
static var restore_title:bool=false
var game
var shortcut:Button
var badge:Label
var taps:int=0
var last_tap:int=0
var gesture_pointer:int=-1
var held_since:int=0
var holding_unlock:bool=false
var origin:Vector2
var cancelled:bool=false
var ssh_pointer:int=-1
var ssh_origin:Vector2
var ssh_cancelled:bool=false
var layout_timer:float=0.0
static func enabled() -> bool:
 return OS.is_debug_build() and (OS.has_feature("owner_test") or OS.get_environment("LOOTLINGS_QA")=="1" and OS.get_environment("LOOTLINGS_OWNER_TEST")=="1")
func configure(target) -> void:
 game=target;mouse_filter=Control.MOUSE_FILTER_IGNORE;process_mode=Node.PROCESS_MODE_ALWAYS;z_index=1100
 badge=Label.new();badge.position=Vector2(12,832);badge.size=Vector2(456,18);badge.text="OWNER TEST PROFILE - SEPARATE SAVES";badge.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;badge.mouse_filter=Control.MOUSE_FILTER_IGNORE;badge.add_theme_font_size_override("font_size",10);badge.add_theme_color_override("font_color",Color("#ffe39a"));add_child(badge)
 shortcut=Button.new();shortcut.name="OwnerSSH";shortcut.text="SHH";shortcut.icon=preload("res://art/ui/icons/owner_hush.svg");shortcut.expand_icon=true;shortcut.add_theme_constant_override("icon_max_width",16);shortcut.size=Vector2(52,44);shortcut.add_theme_font_size_override("font_size",11);shortcut.tooltip_text="SSSHHH! Don't tell anyone I'm cheating!\nOpen isolated test tools";shortcut.pressed.connect(open_tools);preload("res://lootlings_ui.gd").apply_button(shortcut,Color("#172442dd"),Color("#d4ad65"));add_child(shortcut)
 update_layout()
 if restore_title:restore_title=false;call_deferred("show_activation_title")
func show_activation_title() -> void:
 game.startup_ui.show_title();game.state="startup"
func relock() -> void:
 unlocked=false;taps=0;gesture_pointer=-1;held_since=0;shortcut.hide();game.debug_panel.close()
func modal_active() -> bool:
 return game.debug_panel.visible or (is_instance_valid(game.touch_ux) and is_instance_valid(game.touch_ux.dialog))
func update_layout() -> void:
 badge.visible=Scope.active
 shortcut.visible=unlocked and not modal_active()
 if not shortcut.visible:return
 # Fixed portrait world uses the already safe-area-fitted game transform.
 # Avoid visible controls and readable labels; hide temporarily if no spare area.
 var candidates:Array=[Vector2(8,134),Vector2(420,134),Vector2(8,792),Vector2(420,792),Vector2(8,172),Vector2(420,172),Vector2(8,680),Vector2(420,680)]
 if game.state=="startup" and game.startup_ui.current_screen=="title":candidates.push_front(Vector2(4,740))
 for point in candidates:
  var rect:=Rect2(game.get_global_transform()*point,game.get_global_transform().basis_xform(Vector2(52,44)))
  var blocked:bool=false
  for control in game.find_children("*","Control",true,false):
   if control==self or is_ancestor_of(control) or not control.is_visible_in_tree():continue
   if control is BaseButton or control is LineEdit or control is Range or control is ScrollContainer or control is Label or control is RichTextLabel:
    if control.get_global_rect().grow(4).intersects(rect):blocked=true;break
  if not blocked:shortcut.position=point;return
 shortcut.hide()
func open_tools() -> void:
 if not enabled() or not unlocked or modal_active():return
 if not Scope.active:restore_title=true;call_deferred("enter_sandbox");return
 game.debug_panel.open();update_layout()
func enter_sandbox() -> void:
 Scope.switch_profile(get_tree(),true)
func activate_secret() -> void:
 if Scope.active:restore_title=false;show_activation_title();game.debug_panel.open();update_layout()
 else:enter_sandbox()
func activation_rect() -> Rect2:
 var mark:TextureRect=game.startup_ui.title_wordmark
 var rect:Rect2=mark.get_global_rect();var source:Vector2=mark.texture.get_size()
 var factor:float=minf(rect.size.x/source.x,rect.size.y/source.y)
 var crystal:Vector2=rect.get_center()-source*factor*.5+source*Vector2(.414,.46)*factor
 var size:Vector2=Vector2(48,48)*game.scale
 return Rect2(crystal-size*.5,size)
func observe(event:InputEvent) -> bool:
 if not enabled():return false
 if event is InputEventScreenDrag:
  if event.index==ssh_pointer:
   if event.position.distance_to(ssh_origin)>14:ssh_cancelled=true
   return true
  if event.index==gesture_pointer:
   if event.position.distance_to(origin)>14:cancelled=true;taps=0
   return true
  return false
 if not event is InputEventScreenTouch:return false
 var point:Vector2=game.get_global_transform_with_canvas().affine_inverse()*event.position
 if event.pressed and shortcut.visible and not modal_active() and shortcut.get_global_rect().has_point(game.get_global_transform()*point):
  if ssh_pointer<0:ssh_pointer=event.index;ssh_origin=event.position;ssh_cancelled=false
  return true
 if not event.pressed and event.index==ssh_pointer:
  ssh_pointer=-1
  if not ssh_cancelled and event.position.distance_to(ssh_origin)<=14:open_tools()
  return true
 if game.state!="startup" or game.startup_ui.current_screen!="title" or unlocked:
  taps=0;gesture_pointer=-1;held_since=0;return false
 # Existing approved logo's blue crystal, not an extra visible button.
 var zone:Rect2=activation_rect()
 if event.pressed:
  if gesture_pointer>=0:cancelled=true;taps=0;return true
  if not zone.has_point(game.get_global_transform()*point):taps=0;return false
  if Time.get_ticks_msec()-last_tap>3000:taps=0
  gesture_pointer=event.index;origin=event.position;held_since=Time.get_ticks_msec();holding_unlock=taps==7;cancelled=false;return true
 if event.index==gesture_pointer:
  gesture_pointer=-1
  var elapsed:int=Time.get_ticks_msec()-held_since;held_since=0
  if cancelled:return true
  if holding_unlock and elapsed>=800:
   taps=0;unlocked=true;restore_title=true
   call_deferred("activate_secret")
  elif elapsed<500:taps=mini(7,taps+1);last_tap=Time.get_ticks_msec()
  else:taps=0
  return true
 return false
func _process(delta:float) -> void:
 layout_timer-=delta
 if layout_timer<=0:layout_timer=.25;update_layout()
