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
var follower:=preload("res://companion_presentation.gd").new()
var buttons := {}
var decor_panel: Panel
var decor_list: VBoxContainer
var decor_tabs := {}
var decor_status: RichTextLabel
var home_summary: RichTextLabel
var draft := {}
var selected_slot := "home.wall_display"

func configure(target) -> void:
	game=target;visible=false;mouse_filter=Control.MOUSE_FILTER_STOP
	room=Control.new();room.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(room)
	button("leave","‹ MAIN HUB",Rect2(20,20,160,48),func():game.show_hideout())
	title=Label.new();title.position=Vector2(24,98);title.size=Vector2(432,46);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;title.add_theme_font_size_override("font_size",27);title.add_theme_color_override("font_color",Color("#ffe3ac"));room.add_child(title)
	button("character","CHARACTER & STYLE",Rect2(22,622,210,60),func():game.show_profile_from_personal_home())
	button("gear","GEAR / STASH",Rect2(248,622,210,60),func():game.show_personal_stash())
	button("display","PERSONAL DISPLAYS",Rect2(22,698,210,60),func():open("decor"))
	button("companions","COMPANIONS",Rect2(248,698,210,60),func():open("companions"))
	# Reuse existing safe menu components, but physically move them into this
	# PackedScene. They cannot remain active beneath the Hub.
	game.hideout_ui.home_settings_content.reparent(self)
	game.hideout_ui.companion_collection_content.reparent(self)
	home_summary=UI.rich_label(room,Rect2(32,294,276,76),14,Color("#ffe3ac"))
	button("archive","PERSONAL COLLECTION / MEMORIES",Rect2(22,774,436,48),open_collection)
	var nook: Button=game.hideout_ui.make_button(room,"COMPANION
NOOK",Rect2(30,532,116,70),Color("#192936ef"),Color("#dcb973"),12)
	nook.pressed.connect(func():open("companions"));buttons.nook=nook
	build_decor_editor()

func button(id: String,text: String,rect: Rect2,action: Callable) -> void:
	var b: Button=game.hideout_ui.make_button(room,text,rect,Color("#192936ef"),Color("#dcb973"),15)
	b.set_meta("gesture_release_owned",true);buttons[id]=b;b.pressed.connect(action)

func open(next: String="room") -> void:
	if next=="decor":draft=Decor.sanitize(game.profile.get("homestead",{})).home_layout.duplicate(true)
	if next=="companions" and view!="companions":
		companion_parent=view if visible and view in ["room","preferences"] else "room"
	game.state="personal_home";game.hideout_ui.visible=false;game.startup_ui.visible=false
	game.hideout_ui.dismiss_dialogue();game.hideout_ui.loadout_panel.visible=false
	visible=true;view=next;room.visible=view=="room"
	decor_panel.visible=view=="decor"
	if view=="decor":refresh_decor_editor()
	game.hideout_ui.home_settings_content.visible=view=="preferences"
	game.hideout_ui.companion_collection_content.visible=view=="companions"
	game.hideout_ui.current_screen="home_settings" if view=="preferences" else "companion_collection" if view=="companions" else "personal_home"
	game.hideout_ui.profile=game.profile.duplicate(true);game.hideout_ui.refresh_home_settings()
	var who: String=str(game.profile.get("display_name",""))
	title.text="YOUR HOME" if who.is_empty() else who+"'s Home"
	home_summary.text="[b]YOUR PREPARATION CORNER[/b]
%s
Stash: %d / %d  •  Memories: %d" % [str(game.inventory.equipped_item("Weapon").get("name","No weapon equipped")),game.inventory.stash.size(),game.inventory.stash_capacity,game.profile.get("memories",[]).size()]
	follower.react("return");queue_redraw();game.queue_redraw()

func go_back() -> void:
	if view=="companions":open(companion_parent)
	elif view in ["preferences","decor"]:draft.clear();open("room")
	else:game.show_hideout()

func _process(delta: float) -> void:
	if not visible:return
	time+=delta;follower.update(delta,Vector2(240,570),Vector2(-130,32));queue_redraw()

func _draw() -> void:
	if game==null or not visible:return
	# Existing accepted private storage interior; full-screen scene backdrop,
	# not the Hub's painting with a menu over its NPCs.
	if game.responsive_backdrop==null:draw_texture_rect(BACKGROUND,Rect2(0,0,480,854),false)
	draw_rect(Rect2(0,0,480,80),Color("#091124d0"))
	if view not in ["room","decor"]:return
	var home: Dictionary=Decor.sanitize(game.profile.get("homestead",{}))
	var layout: Dictionary=draft if view=="decor" else home.home_layout
	Decor.draw(self,layout)
	if layout.placements.get("home.wall_light","")=="home_lantern":
		for radius in [36,24,12]:draw_circle(Vector2(388,208),radius,Color(1,.7,.3,.025))
	draw_set_transform(Vector2(240,570),0,Vector2(1,.18));draw_circle(Vector2.ZERO,50,Color("#03071166"));draw_set_transform(Vector2.ZERO)
	UI.draw_icon(get_canvas_item(),game.hideout_ui.actor_texture(),Rect2(148,394,184,188))
	if view=="room":draw_style_box(UI.material_style("leather"),Rect2(18,284,304,96))
	var display: String=home.display if layout.placements.get("home.wall_display",null)==null else "none"
	var art: Texture2D=null
	if display=="weapon":art=UI.item_texture(game.inventory.equipped_item("Weapon"))
	elif display=="scroll":art=preload("res://art/production/phase4e/items/recipe_scroll.png")
	elif display=="trophy":art=preload("res://art/production/phase4e/props/trophy_dais.png")
	UI.draw_icon(get_canvas_item(),art,Rect2(351,267,70,70))
	follower.draw_home(self,preload("res://companion_catalog.gd").sanitize(game.profile.get("companion",{})))
	if view=="decor":draw_rect(Rect2(0,0,480,854),Color("#050a1788"))

func input_surface() -> Control:
	return decor_panel if view=="decor" else self

func build_decor_editor() -> void:
	decor_panel=game.hideout_ui.make_panel(self,Rect2(20,180,440,620),Color("#10162ff2"),Color("#dcb973"));decor_panel.z_index=90;decor_panel.visible=false
	game.hideout_ui.make_label(decor_panel,"MAKE IT YOURS",24,Rect2(18,16,404,40),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe3ac"))
	var slots: Array=["home.wall_display","home.wall_banner","home.wall_light","home.floor_perch","home.wall_perch"]
	for index in range(slots.size()):
		var id: String=slots[index];var second_row: bool=index>=3
		var rect:=Rect2(14+(index-3)*210 if second_row else 14+index*138,132 if second_row else 74,202 if second_row else 130,48)
		var tab: Button=game.hideout_ui.make_button(decor_panel,Decor.SLOT_NAMES[id],rect,Color("#192936ef"),Color("#dcb973"),13)
		tab.disabled=second_row;tab.tooltip_text="Perches unlock when their companion art is ready." if second_row else "Free to rearrange"
		tab.pressed.connect(func():selected_slot=id;refresh_decor_editor());decor_tabs[id]=tab
	var scroll:=ScrollContainer.new();scroll.position=Vector2(20,200);scroll.size=Vector2(400,218);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;decor_panel.add_child(scroll)
	decor_list=VBoxContainer.new();decor_list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;decor_list.add_theme_constant_override("separation",8);scroll.add_child(decor_list)
	decor_status=UI.rich_label(decor_panel,Rect2(20,430,400,62),14,Color("#dce6ff"))
	game.hideout_ui.make_button(decor_panel,"CANCEL",Rect2(20,506,190,52),Color("#172442"),Color("#7087ae"),16).pressed.connect(func():go_back())
	var apply_button: Button=game.hideout_ui.make_button(decor_panel,"APPLY / FREE",Rect2(230,506,190,52),Color("#172442"),Color("#dcb973"),16);apply_button.name="ApplyDecor";apply_button.pressed.connect(apply_decor)
	game.hideout_ui.make_button(decor_panel,"DISPLAY SETTINGS",Rect2(20,564,190,48),Color("#172442"),Color("#7087ae"),13).pressed.connect(func():draft.clear();open("preferences"))

	game.hideout_ui.make_button(decor_panel,"RESET PREVIEW",Rect2(230,564,190,48),Color("#172442"),Color("#7087ae"),13).pressed.connect(func():draft=Decor.defaults(game.profile.homestead.display);refresh_decor_editor();queue_redraw())

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
	decor_status.text="Free furnishings • no items spent.
Apply saves. Back / Cancel discards."

func apply_decor() -> void:
	if view!="decor":return
	var home: Dictionary=game.profile.get("homestead",{}).duplicate(true);home.home_layout=draft.duplicate(true)
	if not game.save_home_preferences(home,game.profile.get("companion",{})):return
	draft.clear();open("room")

func open_collection() -> void:
	visible=false;game.state="hideout";game.hideout_ui.visible=true;game.hideout_ui.private_return=true;game.hideout_ui.show_memories()
