extends Control
# Owner debug convenience only. Same F1 panel and sandbox; no networking.
const Scope=preload("res://save_scope.gd")
const PREFS="user://owner_sandbox/owner_tools.cfg"
static var unlocked:bool=false
static var restore_title:bool=false
var game
var shortcut:Button
var badge:Label
var progress:ProgressBar
var gesture_pointer:int=-1
var held_since:int=0
var secret_taps:=0
var secret_started:=0
var secret_last_tap:=0
var secret_hold_ready:=false
var origin:Vector2
var cancelled:bool=false
var ssh_pointer:int=-1
var ssh_origin:Vector2
var ssh_cancelled:bool=false
var ssh_since:int=0
var dragging:bool=false
var drag_offset:=Vector2.ZERO
var preferred:=Vector2(.90,.16)
var saved_position:bool=false
var shortcut_hidden:bool=false
var layout_timer:float=0.0
var layout_initialized:=false
static func enabled() -> bool:
 return OS.is_debug_build() and (OS.has_feature("owner_test") or OS.get_environment("LOOTLINGS_QA")=="1" and OS.get_environment("LOOTLINGS_OWNER_TEST")=="1")
func configure(target) -> void:
 game=target;mouse_filter=Control.MOUSE_FILTER_IGNORE;process_mode=Node.PROCESS_MODE_ALWAYS;z_index=1100
 load_preferences()
 badge=Label.new();badge.position=Vector2(12,832);badge.size=Vector2(456,18);badge.text="OWNER TEST PROFILE - SEPARATE SAVES";badge.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;badge.mouse_filter=Control.MOUSE_FILTER_IGNORE;badge.add_theme_font_size_override("font_size",10);badge.add_theme_color_override("font_color",Color("#ffe39a"));add_child(badge)
 shortcut=Button.new();shortcut.name="OwnerSHH";shortcut.text="SHH";shortcut.icon=preload("res://art/ui/icons/owner_hush.svg");shortcut.expand_icon=true;shortcut.add_theme_constant_override("icon_max_width",16);shortcut.size=Vector2(52,44);shortcut.add_theme_font_size_override("font_size",11);shortcut.tooltip_text="SSSHHH! Tap for tools. Hold one second, then drag to move.";shortcut.pressed.connect(open_tools);preload("res://lootlings_ui.gd").apply_button(shortcut,Color("#172442dd"),Color("#d4ad65"));add_child(shortcut)
 progress=ProgressBar.new();progress.size=Vector2(156,5);progress.max_value=.8;progress.show_percentage=false;progress.mouse_filter=Control.MOUSE_FILTER_IGNORE;progress.hide();add_child(progress)
 update_layout()
 if restore_title:restore_title=false;call_deferred("show_activation_title")
func load_preferences() -> void:
 var config:=ConfigFile.new()
 if config.load(PREFS)!=OK:return
 unlocked=bool(config.get_value("owner","unlocked",false));shortcut_hidden=bool(config.get_value("owner","hidden",false))
 var point=config.get_value("owner","position",Vector2(.9,.16))
 if point is Vector2 and is_finite(point.x) and is_finite(point.y):preferred=point.clamp(Vector2.ZERO,Vector2.ONE);saved_position=bool(config.get_value("owner","position_saved",false))
func save_preferences() -> Error:
 var config:=ConfigFile.new();config.set_value("owner","unlocked",unlocked);config.set_value("owner","hidden",shortcut_hidden);config.set_value("owner","position",preferred);config.set_value("owner","position_saved",saved_position)
 DirAccess.make_dir_recursive_absolute(PREFS.get_base_dir())
 return preload("res://safe_config.gd").save_config(config,PREFS)
func reset_position() -> void:
 saved_position=false;layout_initialized=false;preferred=Vector2(.9,.16);shortcut_hidden=false;save_preferences();update_layout()
func hide_shortcut() -> void:
 shortcut_hidden=true;save_preferences();shortcut.hide()
func show_activation_title() -> void:
 game.startup_ui.show_title();game.state="startup"
func relock() -> void:
 unlocked=false;shortcut_hidden=true;gesture_pointer=-1;held_since=0;save_preferences();shortcut.hide();game.debug_panel.close()
func modal_active() -> bool:
 return game.debug_panel.visible or (is_instance_valid(game.touch_ux) and is_instance_valid(game.touch_ux.dialog))
func clear_of_controls(point:Vector2) -> bool:
 var rect:=Rect2(game.get_global_transform()*point,game.get_global_transform().basis_xform(shortcut.size))
 for control in game.find_children("*","Control",true,false):
  if control==self or is_ancestor_of(control) or not control.is_visible_in_tree():continue
  if control is BaseButton or control is LineEdit or control is Range or control is ScrollContainer or control is Label or control is RichTextLabel:
   if control.get_global_rect().grow(4).intersects(rect):return false
 return true
func clamped(point:Vector2) -> Vector2:
 return point.clamp(Vector2(6,8),Vector2(422,780))
func update_layout() -> void:
 badge.visible=Scope.active and not game.debug_panel.visible;shortcut.visible=unlocked and not shortcut_hidden and not modal_active()
 if not shortcut.visible or ssh_pointer>=0:return
 var wanted:=clamped(preferred*Vector2(428,788))
 if saved_position and clear_of_controls(wanted):shortcut.position=wanted;layout_initialized=true;return
 # Keep a safe target stationary; hover captions must not make it chase the finger.
 if layout_initialized and clear_of_controls(shortcut.position):return
 var candidates:Array=[Vector2(8,134),Vector2(420,134),Vector2(8,792),Vector2(420,792),Vector2(8,172),Vector2(420,172),Vector2(8,680),Vector2(420,680)]
 if game.state in ["startup","boot"] and game.startup_ui.current_screen=="title":candidates.push_front(Vector2(4,740))
 for point in candidates:
  point=clamped(point)
  if clear_of_controls(point):shortcut.position=point;layout_initialized=true;return
 shortcut.hide()
func open_tools() -> void:
 if not enabled() or not unlocked or modal_active() or dragging:return
 shortcut_hidden=false;save_preferences()
 if not Scope.active:restore_title=true;call_deferred("enter_sandbox");return
 game.debug_panel.open();update_layout()
func enter_sandbox() -> void:
 Scope.switch_profile(get_tree(),true)
func backup_open() -> void:
 if not enabled():return
 unlocked=true;shortcut_hidden=false;save_preferences();open_tools()
func activate_secret() -> void:
 shortcut_hidden=false;save_preferences();game.play_audio_event("ui_press")
 if Scope.active:restore_title=false;show_activation_title();game.debug_panel.open();update_layout()
 else:enter_sandbox()
func activation_rect() -> Rect2:
 # Main blue crystal inset in the approved wordmark's second O.
 var mark:TextureRect=game.startup_ui.title_wordmark
 var rect:Rect2=mark.get_global_rect();var source:Vector2=mark.texture.get_size()
 var factor:float=minf(rect.size.x/source.x,rect.size.y/source.y)
 var painted:Vector2=source*factor;var start:Vector2=rect.get_center()-painted*.5
 return Rect2(start+painted*Vector2(.413,.46)-Vector2(30,30),Vector2(60,60))
func activation_areas() -> Array[Rect2]:
 var main:Rect2=activation_rect();var mark:TextureRect=game.startup_ui.title_wordmark
 var rect:Rect2=mark.get_global_rect();var source:Vector2=mark.texture.get_size();var factor:float=minf(rect.size.x/source.x,rect.size.y/source.y)
 var painted:Vector2=source*factor;var start:Vector2=rect.get_center()-painted*.5
 return [main,Rect2(start+painted*Vector2(.604,.15)-Vector2(30,30),Vector2(60,60))]
func reset_secret_sequence() -> void:
 secret_taps=0;secret_started=0;secret_last_tap=0;secret_hold_ready=false
func observe(event:InputEvent) -> bool:
 if not enabled():return false
 var local:Vector2
 if event is InputEventScreenTouch or event is InputEventScreenDrag:local=game.get_global_transform_with_canvas().affine_inverse()*event.position
 else:return false
 if event is InputEventScreenDrag:
  if event.index==ssh_pointer:
   if Time.get_ticks_msec()-ssh_since>=1000:
    dragging=true;shortcut.position=clamped(local-drag_offset)
   elif event.position.distance_to(ssh_origin)>14:ssh_cancelled=true
   return true
  if event.index==gesture_pointer:
   if event.position.distance_to(origin)>24:cancelled=true
   return true
  return false
 if event.pressed and shortcut.visible and not modal_active() and Rect2(shortcut.position,shortcut.size).has_point(local):
  if ssh_pointer<0:ssh_pointer=event.index;ssh_origin=event.position;ssh_since=Time.get_ticks_msec();ssh_cancelled=false;dragging=false;drag_offset=local-shortcut.position
  return true
 if not event.pressed and event.index==ssh_pointer:
  ssh_pointer=-1
  if dragging:
   preferred=(clamped(shortcut.position)/Vector2(428,788)).clamp(Vector2.ZERO,Vector2.ONE);saved_position=true;save_preferences()
  elif not ssh_cancelled and not event.canceled and event.position.distance_to(ssh_origin)<=14:open_tools()
  dragging=false;update_layout();return true
 if gesture_pointer==event.index and not event.pressed:
  gesture_pointer=-1;progress.hide()
  var elapsed:int=Time.get_ticks_msec()-held_since;held_since=0
  if cancelled or event.canceled:reset_secret_sequence()
  elif secret_hold_ready:
   if elapsed>=800:unlocked=true;restore_title=true;call_deferred("activate_secret")
   reset_secret_sequence()
  elif elapsed<800:
   if secret_started==0:secret_started=Time.get_ticks_msec()-elapsed
   if Time.get_ticks_msec()-secret_started<=3000:secret_taps+=1;secret_last_tap=Time.get_ticks_msec()
   else:reset_secret_sequence()
  else:reset_secret_sequence()
  return true
 if game.state not in ["startup","boot"] or game.startup_ui.current_screen!="title" or not game.startup_ui.visible or modal_active():return false
 if event.pressed and activation_areas().any(func(rect):return rect.has_point(game.get_global_transform()*local)):
  if gesture_pointer>=0:cancelled=true;return true
  if secret_started>0 and Time.get_ticks_msec()-secret_started>3000 and not (secret_taps==7 and Time.get_ticks_msec()-secret_last_tap<=500):reset_secret_sequence()
  secret_hold_ready=secret_taps==7
  gesture_pointer=event.index;origin=event.position;held_since=Time.get_ticks_msec();cancelled=false;progress.position=local+Vector2(-78,24);progress.value=0;progress.visible=secret_hold_ready;return true
 return false
func _process(delta:float) -> void:
 if gesture_pointer>=0:progress.value=(Time.get_ticks_msec()-held_since)/1000.0
 layout_timer-=delta
 if layout_timer<=0:layout_timer=.25;update_layout()
