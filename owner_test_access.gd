extends Control
# Per-install owner PIN; build boundary is protection, not the secret gesture.
const Scope=preload("res://save_scope.gd")
const PIN_PATH="user://lootlings_owner_access.cfg"
var game
var contacts:Dictionary={}
var held_since:int=0
var ready_to_open:bool=false
var prompt:Panel
var backdrop:ColorRect
var pin:LineEdit
var confirm_pin:LineEdit
var message:Label
var enter_button:Button
var attempts:int=0
var locked_until:int=0
static func enabled() -> bool:
 return OS.is_debug_build() and (OS.has_feature("owner_test") or OS.get_environment("LOOTLINGS_QA")=="1" and OS.get_environment("LOOTLINGS_OWNER_TEST")=="1")
func configure(target) -> void:
 game=target;mouse_filter=Control.MOUSE_FILTER_IGNORE;process_mode=Node.PROCESS_MODE_ALWAYS;z_index=1100
 if Scope.active:
  var badge:=Label.new();badge.position=Vector2(12,0);badge.size=Vector2(456,20);badge.text="OWNER TEST PROFILE - SEPARATE SAVES";badge.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;badge.mouse_filter=Control.MOUSE_FILTER_IGNORE;badge.add_theme_font_size_override("font_size",10);badge.add_theme_color_override("font_color",Color("#ffe39a"));add_child(badge)
func observe(event: InputEvent) -> bool:
 if not enabled() or is_instance_valid(prompt):return false
 if game.state!="startup" or game.startup_ui.current_screen!="title":contacts.clear();held_since=0;ready_to_open=false;return false
 if event is InputEventScreenDrag:
  var owned:bool=contacts.has(event.index)
  if owned and event.position.distance_to(contacts[event.index])>14:contacts.clear();held_since=0;ready_to_open=false
  return owned
 if not event is InputEventScreenTouch:return false
 var point:Vector2=game.get_global_transform_with_canvas().affine_inverse()*event.position
 if event.pressed:
  if point.y>72 or not (point.x<64 or point.x>416):contacts.clear();held_since=0;ready_to_open=false;return false
  if contacts.has(event.index):return true
  contacts[event.index]=event.position
  if contacts.size()==2:
   var points:Array=contacts.values();var p0:Vector2=game.get_global_transform_with_canvas().affine_inverse()*points[0];var p1:Vector2=game.get_global_transform_with_canvas().affine_inverse()*points[1]
   if (p0.x<64 and p1.x>416) or (p1.x<64 and p0.x>416):held_since=Time.get_ticks_msec()
  elif contacts.size()>2:held_since=0;ready_to_open=false
  return true
 elif contacts.has(event.index):
  contacts.erase(event.index)
  if contacts.is_empty():
   if ready_to_open:show_prompt()
   held_since=0;ready_to_open=false
  return true
 return false
func _process(_delta:float) -> void:
 if held_since>0 and contacts.size()==2 and Time.get_ticks_msec()-held_since>=2500:ready_to_open=true
func configured() -> bool:
 var config:=ConfigFile.new();return config.load(PIN_PATH)==OK and not str(config.get_value("access","digest","")).is_empty()
func show_prompt() -> void:
 if not enabled() or is_instance_valid(prompt):return
 backdrop=ColorRect.new();backdrop.position=Vector2.ZERO;backdrop.size=Vector2(480,854);backdrop.color=Color("#030714b0");backdrop.mouse_filter=Control.MOUSE_FILTER_STOP;add_child(backdrop)
 prompt=Panel.new();prompt.position=Vector2(24,218);prompt.size=Vector2(432,398);prompt.mouse_filter=Control.MOUSE_FILTER_STOP;prompt.add_theme_stylebox_override("panel",preload("res://lootlings_ui.gd").material_style("leather"));add_child(prompt)
 message=Label.new();message.position=Vector2(20,18);message.size=Vector2(392,100);message.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;message.text="OWNER TEST BUILD\nEnter your PIN. Cheats use isolated test saves." if configured() else "SET OWNER PIN\nChoose 6-12 digits on this device. No shared PIN is shipped.";prompt.add_child(message)
 pin=LineEdit.new();pin.position=Vector2(20,132);pin.size=Vector2(392,50);pin.secret=true;pin.virtual_keyboard_type=LineEdit.KEYBOARD_TYPE_NUMBER;pin.placeholder_text="6-12 digit PIN";prompt.add_child(pin)
 confirm_pin=LineEdit.new();confirm_pin.position=Vector2(20,192);confirm_pin.size=Vector2(392,50);confirm_pin.secret=true;confirm_pin.virtual_keyboard_type=LineEdit.KEYBOARD_TYPE_NUMBER;confirm_pin.placeholder_text="Repeat new PIN";confirm_pin.visible=not configured();prompt.add_child(confirm_pin)
 enter_button=Button.new();enter_button.position=Vector2(20,264);enter_button.size=Vector2(392,52);enter_button.text="ENTER ISOLATED TEST PROFILE";enter_button.pressed.connect(unlock);prompt.add_child(enter_button)
 var cancel:=Button.new();cancel.position=Vector2(20,326);cancel.size=Vector2(392,48);cancel.text="CANCEL";cancel.pressed.connect(close_prompt);prompt.add_child(cancel)
 game.touch_ux.renew_surface()
func close_prompt() -> void:
 if is_instance_valid(backdrop):backdrop.queue_free();backdrop=null
 if is_instance_valid(prompt):prompt.queue_free();prompt=null
 game.touch_ux.renew_surface()
func unlock() -> void:
 if not enabled() or not is_instance_valid(prompt):return
 if Time.get_ticks_msec()<locked_until:message.text="Wait 30 seconds before trying again.";return
 var value:String=pin.text
 if value.length()<6 or value.length()>12 or not value.is_valid_int() or value.begins_with("-") or value.begins_with("+"):message.text="Use 6-12 digits.";return
 var config:=ConfigFile.new()
 if not configured():
  if value!=confirm_pin.text:message.text="The two PINs must match.";return
  var salt:String=Crypto.new().generate_random_bytes(32).hex_encode();config.set_value("access","salt",salt);config.set_value("access","digest",(salt+value).sha256_text())
  if config.save(PIN_PATH)!=OK:message.text="PIN could not be saved. No profile switch.";return
 else:
  config.load(PIN_PATH)
  if (str(config.get_value("access","salt",""))+value).sha256_text()!=str(config.get_value("access","digest","")):
   attempts+=1;message.text="Incorrect PIN."
   if attempts>=5:locked_until=Time.get_ticks_msec()+30000;attempts=0
   return
 pin.text="";confirm_pin.text=""
 Scope.switch_profile(get_tree(),true)
