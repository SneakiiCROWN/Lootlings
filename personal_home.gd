extends Control
# Separate personal area. Hub residents/stations are never drawn or parented here.
const BACKGROUND=preload("res://art/backgrounds/stash_vault.png")
const Decor=preload("res://home_catalog.gd")
const UI=preload("res://lootlings_ui.gd")
var game
var view := "room"
var companion_parent := "room"
var room: Control
var title: Label
var time := 0.0
var warmth := 0.0
var home_reaction:Label
var companion_mode_buttons := {}
var follower:=preload("res://companion_presentation.gd").new()
var buttons := {}
var decor_panel: Panel
var decor_list: VBoxContainer
var decor_tabs := {}
var decor_status: RichTextLabel
var home_summary: RichTextLabel
var draft := {}
var selected_slot := "home.wall_display"
var preview_actions: Control
var summary_style: StyleBox=preload("res://station_presentation.gd").metal()
func background() -> Texture2D:
	var accepted:=preload("res://home_runtime_art.gd").texture("environment:personal_home:interior")
	return accepted if accepted!=null else BACKGROUND

func configure(target) -> void:
	game=target;visible=false;mouse_filter=Control.MOUSE_FILTER_STOP
	room=Control.new();room.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(room)
	var nav=game.hideout_ui.hub_navigation
	buttons.leave=nav.shortcut(room,"‹ Hub",Rect2(16,16,96,52),func():game.show_hideout(),"Return to the public Main Hub")
	buttons.display=nav.shortcut(room,"Decorate",Rect2(360,16,104,52),func():open("decor"),"Arrange your saved furnishings; Apply saves, Cancel discards")
	title=nav.text(room,"YOUR HOME",Rect2(116,22,236,32),19)
	game.hideout_ui.home_settings_content.reparent(self)
	game.hideout_ui.companion_collection_content.reparent(self)
	home_summary=UI.rich_label(room,Rect2(124,54,232,18),11,Color("#d9c9aa"))
	build_decor_editor()
	build_room_hotspots()
	home_reaction=nav.text(room,"",Rect2(160,650,184,54),12);home_reaction.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;home_reaction.hide()

func button(id: String,text: String,rect: Rect2,action: Callable) -> void:
	var b: Button=game.hideout_ui.make_button(room,text,rect,Color("#192936ef"),Color("#dcb973"),15)
	b.set_meta("gesture_release_owned",true);buttons[id]=b;b.pressed.connect(action)

func open(next: String="room") -> void:
	if get_parent().audio_manager != null: get_parent().audio_manager.set_music("HOME")
	if next=="decor" and view not in ["decor","decor_preview"]:draft=Decor.sanitize(game.profile.get("homestead",{}),str(game.profile.get("companion",{}).get("equipped_id",""))).home_layout.duplicate(true)
	if next=="companions" and view!="companions":
		companion_parent=view if visible and view in ["room","preferences"] else "room"
	game.state="personal_home";game.hideout_ui.visible=false;game.startup_ui.visible=false
	game.hideout_ui.dismiss_dialogue();game.hideout_ui.loadout_panel.visible=false
	visible=true;view=next;room.visible=view=="room"
	decor_panel.visible=view=="decor"
	preview_actions.visible=view=="decor_preview"
	if view=="decor":refresh_decor_editor()
	game.hideout_ui.home_settings_content.visible=view=="preferences"
	game.hideout_ui.companion_collection_content.visible=view=="companions"
	game.hideout_ui.current_screen="home_settings" if view=="preferences" else "companion_collection" if view=="companions" else "personal_home"
	game.hideout_ui.profile=game.profile.duplicate(true);game.hideout_ui.refresh_home_settings()
	var who: String=str(game.profile.get("display_name",""))
	title.text="YOUR HOME" if who.is_empty() else who+"'s Home"
	title.add_theme_font_size_override("font_size",UI.fitted_font_size(game.body_font,title.text,236,19,13))
	home_summary.text="[center]%d / %d stash   •   %d memories[/center]" % [game.inventory.stash.size(),game.inventory.stash_capacity,game.profile.get("memories",[]).size()]
	follower.react("return");queue_redraw();game.queue_redraw()

func go_back() -> void:
	if view=="decor_preview":open("decor")
	elif view=="companions":open(companion_parent)
	elif view in ["preferences","decor"]:draft.clear();open("room")
	else:game.show_hideout()

func _process(delta: float) -> void:
	if not visible:return
	time+=delta
	warmth=maxf(0,warmth-delta)
	if home_reaction!=null:home_reaction.visible=warmth>0
	var home: Dictionary=Decor.sanitize(game.profile.get("homestead",{}),str(game.profile.get("companion",{}).get("equipped_id","")))
	var layout: Dictionary=draft if view in ["decor","decor_preview"] else home.home_layout
	follower.update_home(delta,game.profile.get("companion",{}),layout);queue_redraw()

func _draw() -> void:
	if game==null or not visible:return
	# Existing accepted private storage interior; full-screen scene backdrop,
	# not the Hub's painting with a menu over its NPCs.
	var backdrop: Texture2D=background()
	var factor:=maxf(480.0/backdrop.get_width(),854.0/backdrop.get_height())
	var extent:=backdrop.get_size()*factor
	if game.responsive_backdrop==null:draw_texture_rect(backdrop,Rect2((Vector2(480,854)-extent)*.5,extent),false)
	draw_rect(Rect2(0,0,480,78),Color("#09112466"))
	if view not in ["room","decor","decor_preview"]:return
	var home: Dictionary=Decor.sanitize(game.profile.get("homestead",{}),str(game.profile.get("companion",{}).get("equipped_id","")))
	var layout: Dictionary=draft if view in ["decor","decor_preview"] else home.home_layout
	Decor.draw_display_shelf(self)
	Decor.draw(self,layout)
	if layout.placements.get("home.wall_light","")=="home_lantern":
		for radius in [36,24,12]:draw_circle(Vector2(388,208),radius,Color(1,.7,.3,.025))
	draw_set_transform(Vector2(240,570),0,Vector2(1,.18));draw_circle(Vector2.ZERO,50,Color("#03071166"));draw_set_transform(Vector2.ZERO)
	var motion:bool=not game.audio_settings.get("cinematic_reduced_motion",false)
	var breath:float=1.0+sin(time*1.7)*.006 if motion else 1.0
	draw_set_transform(Vector2(240,570),sin(time*.9)*.002 if motion else 0.0,Vector2(breath,1.0/breath))
	UI.draw_icon(get_canvas_item(),game.hideout_ui.actor_texture(),Rect2(-92,-176,184,188))
	draw_set_transform(Vector2.ZERO)
	if motion:
		# Light and rising embers originate in the actual fireplace opening.
		for radius in [34,22,12]:draw_circle(Vector2(442,469),radius,Color(1,.55,.18,.012+maxf(0,sin(time*3.7))*.005))
		for spark in range(4):
			var rise:=fmod(time*(6+spark)+spark*9,25.0)
			draw_circle(Vector2(440+sin(time*1.1+spark)*8,471-rise),.8,Color(1,.65,.25,(1-rise/25.0)*.35))
		for i in range(6):
			var pos:=Vector2(34+i*77+sin(time*.45+i)*7,655-fmod(time*(4+i*.3)+i*83,450))
			draw_circle(pos,1.2,Color(1,.77,.35,.12+maxf(0,sin(time*.8+i))*.14))
	var display: String=home.display if layout.placements.get("home.wall_display",null)==null else "none"
	var art: Texture2D=null
	if display=="weapon":art=UI.item_texture(game.inventory.equipped_item("Weapon"))
	elif display=="scroll":art=preload("res://art/production/phase4e/items/recipe_scroll.png")
	elif display=="trophy":art=preload("res://art/production/phase4e/props/trophy_dais.png")
	UI.draw_icon(get_canvas_item(),art,Rect2(351,267,70,70))
	follower.draw_home(self,preload("res://companion_catalog.gd").sanitize(game.profile.get("companion",{})))
	Decor.draw_foreground(self,layout)
	if view=="decor":draw_rect(Rect2(0,0,480,854),Color("#050a1788"))

func input_surface() -> Control:
	return decor_panel if view=="decor" else self

func build_room_hotspots() -> void:
	var nav=game.hideout_ui.hub_navigation
	buttons.bed=nav.feature(room,"HomeBed",Rect2(12,452,140,122),"Rest","",func():warmth=3.5;home_reaction.text="A quiet moment before the next adventure.",12)
	buttons.hearth=nav.feature(room,"HomeHearth",Rect2(352,452,112,106),"Hearth","",func():warmth=3.5;home_reaction.text="Warm embers, good company.",12)
	buttons.chest=nav.feature(room,"HomeChest",Rect2(98,298,112,120),"Stash","Prepare your gear",func():game.show_personal_stash())
	buttons.gear=buttons.chest
	buttons.archive=nav.feature(room,"HomeArchive",Rect2(8,318,84,116),"Memories","Your Archive",open_collection,12)
	buttons.shelf=nav.feature(room,"HomeDisplay",Rect2(338,246,108,112),"Display","Make it yours",func():selected_slot="home.wall_display";open("decor"))
	buttons.ledge=nav.feature(room,"HomeWallPerch",Rect2(326,364,110,86),"Perch","",func():greet_or_collection("home.wall_perch"),12)
	buttons.character=nav.feature(room,"HomeCharacter",Rect2(156,398,168,236),"Character","Your Lootling",func():game.show_profile_from_personal_home())
	buttons.nook=nav.feature(room,"HomeCompanionNook",Rect2(30,682,124,112),"Companions  ›","Rest & play",func():greet_or_collection("home.floor_perch"))
	# The companion itself reacts to a greeting; its unobtrusive name opens the
	# existing collection directly, even when an owned companion is resting.
	var collection:Button=game.hideout_ui.make_button(buttons.nook,"",Rect2(0,66,124,48),Color.TRANSPARENT,Color.TRANSPARENT,13)
	nav.skin(collection);collection.tooltip_text="Choose your companions";collection.pressed.connect(func():open("companions"));buttons.companions=collection
	preview_actions=Control.new();preview_actions.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);preview_actions.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(preview_actions);preview_actions.visible=false
	game.hideout_ui.make_button(preview_actions,"‹ EDIT",Rect2(20,20,122,48),Color("#192936ef"),Color("#dcb973"),15).pressed.connect(func():open("decor"))
	game.hideout_ui.make_label(preview_actions,"DECOR PREVIEW",27,Rect2(24,98,432,46),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe3ac"))
	game.hideout_ui.make_button(preview_actions,"CANCEL",Rect2(22,698,210,60),Color("#172442"),Color("#7087ae"),16).pressed.connect(func():draft.clear();open("room"))
	var apply_preview: Button=game.hideout_ui.make_button(preview_actions,"APPLY / FREE",Rect2(248,698,210,60),Color("#172442"),Color("#dcb973"),16);apply_preview.name="ApplyPreview";apply_preview.pressed.connect(apply_decor)
func room_hotspot(id: String,text: String,rect: Rect2,action: Callable) -> void:
	var control: Button=game.hideout_ui.make_button(room,text,rect,Color.TRANSPARENT,Color("#dcb973"),13)
	control.name=id;control.tooltip_text="Personal display" if id=="shelf" else "Open your stash";control.set_meta("gesture_release_owned",true);room_hotspot_skin(control);control.pressed.connect(action);buttons[id]=control
func room_hotspot_skin(control: Button) -> void:
	for state_name in ["normal","hover","pressed","focus"]:
		var skin:=StyleBoxFlat.new();skin.bg_color=Color(1,.8,.4,.08) if state_name=="pressed" else Color.TRANSPARENT;skin.border_color=Color("#e3c17799");skin.set_corner_radius_all(8);skin.set_border_width_all(2 if state_name in ["hover","focus"] else 0);control.add_theme_stylebox_override(state_name,skin)
func build_decor_editor() -> void:
	decor_panel=game.hideout_ui.make_panel(self,Rect2(20,180,440,620),Color("#10162ff2"),Color("#dcb973"));decor_panel.z_index=90;decor_panel.visible=false
	game.hideout_ui.make_label(decor_panel,"MAKE IT YOURS",20,Rect2(18,16,196,40),HORIZONTAL_ALIGNMENT_LEFT,Color("#ffe3ac"))
	var slots: Array=["home.wall_display","home.wall_banner","home.wall_light","home.floor_perch","home.wall_perch"]
	for index in range(slots.size()):
		var id: String=slots[index];var second_row: bool=index>=3
		var rect:=Rect2(14+(index-3)*210 if second_row else 14+index*138,132 if second_row else 74,202 if second_row else 130,48)
		var tab: Button=game.hideout_ui.make_button(decor_panel,Decor.SLOT_NAMES[id],rect,Color("#192936ef"),Color("#dcb973"),13)
		tab.disabled=second_row and not Decor.available(str(Decor.SLOTS[id].allowed_decor[0]));tab.tooltip_text="Furnishing art is not available yet." if tab.disabled else "Free to rearrange"
		tab.pressed.connect(func():selected_slot=id;refresh_decor_editor());decor_tabs[id]=tab
	var scroll:=ScrollContainer.new();scroll.position=Vector2(20,200);scroll.size=Vector2(400,218);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;decor_panel.add_child(scroll)
	decor_list=VBoxContainer.new();decor_list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;decor_list.add_theme_constant_override("separation",8);scroll.add_child(decor_list)
	decor_status=UI.rich_label(decor_panel,Rect2(20,484,400,20),11,Color("#dce6ff"))
	for mode in ["follow","perch"]:
		var b: Button=game.hideout_ui.make_button(decor_panel,"FOLLOW" if mode=="follow" else "REST HERE",Rect2(20 if mode=="follow" else 230,430,190,48),Color("#172442"),Color("#dcb973"),14)
		companion_mode_buttons[mode]=b
		b.pressed.connect(func():draft.companion_mode=mode;draft.companion_perch_slot=selected_slot if mode=="perch" else draft.companion_perch_slot;refresh_decor_editor();queue_redraw())
	game.hideout_ui.make_button(decor_panel,"CANCEL",Rect2(20,506,190,52),Color("#172442"),Color("#7087ae"),16).pressed.connect(func():go_back())
	var apply_button: Button=game.hideout_ui.make_button(decor_panel,"APPLY / FREE",Rect2(230,506,190,52),Color("#172442"),Color("#dcb973"),16);apply_button.name="ApplyDecor";apply_button.pressed.connect(apply_decor)
	game.hideout_ui.make_button(decor_panel,"DISPLAY SETTINGS",Rect2(20,564,190,48),Color("#172442"),Color("#7087ae"),13).pressed.connect(func():draft.clear();open("preferences"))

	game.hideout_ui.make_button(decor_panel,"RESET PREVIEW",Rect2(230,564,190,48),Color("#172442"),Color("#7087ae"),13).pressed.connect(func():draft=Decor.defaults(game.profile.homestead.display);refresh_decor_editor();queue_redraw())

	var preview_button: Button=game.hideout_ui.make_button(decor_panel,"VIEW ROOM",Rect2(230,16,190,40),Color("#172442"),Color("#7087ae"),13);preview_button.name="ViewRoom";preview_button.pressed.connect(func():open("decor_preview"))

func refresh_decor_editor() -> void:
	for id in decor_tabs:game.hideout_ui.apply_display_button_style(decor_tabs[id],Color("#dcb973"),id==selected_slot)
	for child in decor_list.get_children():decor_list.remove_child(child);child.queue_free()
	var options: Array=Decor.SLOTS[selected_slot].allowed_decor.duplicate()
	if selected_slot=="home.wall_display":options.push_front(null)
	options.append("")
	for id in options:
		var caption: String="Equipped weapon / shelf display" if id==null else "Clear this slot" if id=="" else str(Decor.ITEMS[id].display_name)
		var b: Button=game.hideout_ui.make_button(decor_list,caption,Rect2(0,0,380,48),Color("#172442"),Color("#dcb973"),15);b.custom_minimum_size=Vector2(380,48)
		b.disabled=id is String and not id.is_empty() and not Decor.available(id)
		if id is String and not id.is_empty():
			b.icon=Decor.texture(id);b.expand_icon=true;b.add_theme_constant_override("icon_max_width",40)
		b.set_meta("decor_id",id);game.hideout_ui.apply_display_button_style(b,Color("#dcb973"),draft.placements[selected_slot]==id)
		b.pressed.connect(func():draft.placements[selected_slot]=id;refresh_decor_editor();queue_redraw())
	var companion_id: String=str(game.profile.get("companion",{}).get("equipped_id",""))
	var perch_ready: bool=preload("res://companion_catalog.gd").can_perch(companion_id)
	var valid_slot: bool=selected_slot in ["home.floor_perch","home.wall_perch"] and companion_id in Decor.SLOTS[selected_slot].allowed_companions and Decor.available(str(draft.placements.get(selected_slot,"")))
	companion_mode_buttons.follow.disabled=companion_id.is_empty()
	companion_mode_buttons.perch.disabled=not perch_ready or not valid_slot
	companion_mode_buttons.perch.tooltip_text="Choose a compatible furnished perch and an equipped companion with complete perch art."
	for mode in companion_mode_buttons:game.hideout_ui.apply_display_button_style(companion_mode_buttons[mode],Color("#dcb973"),draft.companion_mode==mode and (mode=="follow" or draft.companion_perch_slot==selected_slot))
	decor_status.text="Free furnishings • Apply saves • Back / Cancel discards"

func apply_decor() -> void:
	if view not in ["decor","decor_preview"]:return
	var home: Dictionary=game.profile.get("homestead",{}).duplicate(true);home.home_layout=draft.duplicate(true)
	if not game.save_home_preferences(home,game.profile.get("companion",{})):return
	draft.clear();open("room")

func greet_or_collection(slot: String) -> void:
	var home: Dictionary=Decor.sanitize(game.profile.get("homestead",{}),str(game.profile.get("companion",{}).get("equipped_id","")))
	if home.home_layout.companion_mode=="perch" and home.home_layout.companion_perch_slot==slot and follower.state in ["perch_rest","perch_interact"]:follower.react("talk")
	else:open("companions")

func open_collection() -> void:
	visible=false;game.state="hideout";game.hideout_ui.visible=true;game.hideout_ui.private_return=true;game.hideout_ui.show_memories()
