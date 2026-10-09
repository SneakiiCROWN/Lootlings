extends RefCounted
# Direct world interactions. No directory, navigation dock or duplicate services.
const UI=preload("res://lootlings_ui.gd")
var owner
var buttons:Dictionary={}
var world_buttons:Dictionary={}
var talk_buttons:Dictionary={}
var engine_hint:Label
var archive_talk:Button

func build(hub) -> void:
 owner=hub
 var surface:Control=hub.home_content
 text(surface,"MAIN HUB",Rect2(120,14,240,28),19,Color("#ffe3ac"))
 hub.resource_label=UI.rich_label(surface,Rect2(100,42,280,25),12,Color("#dce6f5"))
 world_buttons.GateEntrance=feature(surface,"GateEntrance",Rect2(148,100,184,232),"ENTER THE GATE  ›","Choose an expedition",func():hub.play_requested.emit(),17)
 # The same shrine hit area includes Sera; one service, one named world location.
 world_buttons.ShrineProp=feature(surface,"ShrineProp",Rect2(12,208,128,304),"Sera · Upgrades","Permanent power",hub.show_upgrades)
 talk_buttons.sera=talk_badge(world_buttons.ShrineProp,Rect2(76,130,48,48),"Relic Keeper")
 world_buttons.ShopEntrance=feature(surface,"ShopEntrance",Rect2(332,320,144,192),"Patch · Shop","Gear & caches",hub.show_shop)
 talk_buttons.patch=talk_badge(world_buttons.ShopEntrance,Rect2(76,8,48,48),"Salvager")
 world_buttons.ContractBoard=feature(surface,"ContractBoard",Rect2(342,166,122,152),"Quest board","Jobs & bounties",hub.show_contracts)
 world_buttons.StorageChest=feature(surface,"StorageChest",Rect2(12,514,136,122),"Gear & Stash","Equip & compare",hub.show_stash)
 world_buttons.ForgeStation=feature(surface,"ForgeStation",Rect2(12,642,136,106),"Forge","Craft & evolve",hub.show_forge)
 world_buttons.ArchiveDesk=feature(surface,"ArchiveDesk",Rect2(332,528,132,126),"Ilex · Archive","Records & stories",func():hub.show_phase4("archive"))
 talk_buttons.ilex=talk_badge(world_buttons.ArchiveDesk,Rect2(80,6,48,48),"Archivist")
 world_buttons.RelicEngine=feature(surface,"RelicEngine",Rect2(332,668,132,98),"Relic Engine","Secured rewards",func():hub.engine_requested.emit())
 hub.engine_button=world_buttons.RelicEngine;engine_hint=world_buttons.RelicEngine.get_node("Purpose")
 world_buttons.Mascot=feature(surface,"YourLootling",Rect2(158,334,164,218),"Talk  ›","",func():hub.request_dialogue("tapped","Mascot"),12)
 # Only essential shortcuts stay at the edge, below the living scene.
 buttons.home=shortcut(surface,"Home",Rect2(24,782,136,52),func():hub.get_parent().show_personal_home(),"Your separate private den")
 buttons.character=shortcut(surface,"Character",Rect2(172,782,136,52),func():hub.profile_requested.emit(),"Character and profile")
 buttons.title=shortcut(surface,"Main menu",Rect2(320,782,136,52),func():hub.title_requested.emit(),"Return to the title screen")
 buttons.gate=world_buttons.GateEntrance;buttons.engine=world_buttons.RelicEngine;buttons.gear=world_buttons.StorageChest
 hub.loadout_panel=hub.make_panel(surface,Rect2(24,640,432,84),Color("#0c1430f5"),Color("#7087ae"));hub.loadout_panel.visible=false
 hub.loadout_label=UI.rich_label(hub.loadout_panel,Rect2(14,10,404,64),14,Color("#e6edff"))
 hub.home_weapon=preload("res://item_icon.gd").new();hub.home_weapon.size=Vector2(40,40);hub.home_weapon.mouse_filter=Control.MOUSE_FILTER_IGNORE;hub.loadout_panel.add_child(hub.home_weapon)
 hub.home_weapon_name=hub.make_label(hub.loadout_panel,"",13,Rect2(56,10,354,44),HORIZONTAL_ALIGNMENT_LEFT,Color("#ffe6ad"));hub.home_weapon_name.hide()

func text(parent:Node,value:String,rect:Rect2,font:int=13,color:Color=Color("#ffe9ba")) -> Label:
 var l:Label=owner.make_label(parent,value,font,rect,HORIZONTAL_ALIGNMENT_CENTER,color);l.mouse_filter=Control.MOUSE_FILTER_IGNORE;l.add_theme_color_override("font_outline_color",Color("#04101fed"));l.add_theme_constant_override("outline_size",4);return l

func feature(parent:Node,id:String,rect:Rect2,name:String,purpose:String,action:Callable,font:int=13) -> Button:
 var b:Button=owner.make_button(parent,"",rect,Color.TRANSPARENT,Color.TRANSPARENT,font);b.name=id;b.flat=true;b.tooltip_text=name+" · "+purpose;b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 skin(b)
 var caption:=text(b,name,Rect2(0,rect.size.y-43,rect.size.x,24),font);caption.name="FeatureName"
 var hint:=text(b,purpose,Rect2(0,rect.size.y-22,rect.size.x,18),11,Color("#d6e8f5"));hint.name="Purpose";hint.visible=false
 b.mouse_entered.connect(func():hint.visible=not purpose.is_empty())
 b.mouse_exited.connect(func():hint.hide())
 b.focus_entered.connect(func():hint.visible=not purpose.is_empty())
 b.focus_exited.connect(func():hint.hide())
 b.pressed.connect(action);return b

func skin(b:Button) -> void:
 for state in ["normal","hover","pressed","focus"]:
  var box:=StyleBoxFlat.new();box.bg_color=Color.TRANSPARENT if state=="normal" else Color("#82c7fb0c") if state=="hover" else Color("#ffe39c18") if state=="pressed" else Color.TRANSPARENT
  box.border_color=Color.TRANSPARENT if state=="normal" else Color("#e9ce8180") if state=="hover" else Color("#94ddf7")
  box.set_border_width_all(0 if state=="normal" else 1);box.set_corner_radius_all(16);b.add_theme_stylebox_override(state,box)

func shortcut(parent:Node,name:String,rect:Rect2,action:Callable,hint:String) -> Button:
 var b:Button=owner.make_button(parent,name,rect,Color("#0c1b2b99"),Color("#a98b5c88"),13);b.tooltip_text=hint;b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 for state in ["normal","hover","pressed","focus"]:
  var box:=StyleBoxFlat.new();box.bg_color=Color("#0c1b2b88") if state=="normal" else Color("#244660bb");box.border_color=Color("#bba06a66") if state=="normal" else Color("#a4dcf4");box.set_border_width_all(1);box.set_corner_radius_all(20);b.add_theme_stylebox_override(state,box)
 b.pressed.connect(action);return b

func talk_badge(parent:Node,rect:Rect2,speaker:String) -> Button:
 var b:Button=owner.make_button(parent,"Talk",rect,Color.TRANSPARENT,Color.TRANSPARENT,11);b.flat=true;b.tooltip_text="Talk to "+preload("res://world_story.gd").SPEAKERS[speaker];skin(b);b.add_theme_color_override("font_outline_color",Color("#051224"));b.add_theme_constant_override("outline_size",4)
 b.pressed.connect(func():owner.resident_meeting_requested.emit(speaker));return b

func finish_details() -> void:
 for row in [[owner.shop_content,"Salvager"],[owner.forge_content,"Salvager"],[owner.upgrade_content,"Relic Keeper"],[owner.phase4_content,"Archivist"]]:
  var surface:Control=row[0];var speaker:String=row[1]
  for child in surface.get_children():
   if child is Label and child.position.y>=20 and child.position.y<30 and child.position.x>=145:child.size.x=242;child.add_theme_font_size_override("font_size",22)
  var talk:=shortcut(surface,"Talk",Rect2(404,20,60,48),func():owner.resident_meeting_requested.emit(speaker),"Talk to "+preload("res://world_story.gd").SPEAKERS[speaker])
  if surface==owner.phase4_content:archive_talk=talk;archive_talk.hide()

func refresh() -> void:
 var count:int=int(owner.endgame_progress.data.get("free_spins",0)) if owner.endgame_progress!=null else 0
 engine_hint.text="Free spins: %d" % count if count>0 else "Secured rewards"
