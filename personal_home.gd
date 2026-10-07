extends Control
# Separate personal area. Hub residents/stations are never drawn or parented here.
const BACKGROUND=preload("res://art/backgrounds/stash_vault.png")
const UI=preload("res://lootlings_ui.gd")
var game
var view := "room"
var room: Control
var title: Label
var time := 0.0
var follower:=preload("res://companion_presentation.gd").new()
var buttons := {}

func configure(target) -> void:
	game=target;visible=false;mouse_filter=Control.MOUSE_FILTER_STOP
	room=Control.new();room.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(room)
	button("leave","‹ MAIN HUB",Rect2(20,20,160,48),func():game.show_hideout())
	title=Label.new();title.position=Vector2(24,98);title.size=Vector2(432,46);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;title.add_theme_font_size_override("font_size",27);title.add_theme_color_override("font_color",Color("#ffe3ac"));room.add_child(title)
	button("character","CHARACTER & STYLE",Rect2(22,622,210,60),func():game.show_profile_from_personal_home())
	button("gear","GEAR / STASH",Rect2(248,622,210,60),func():game.show_personal_stash())
	button("display","PERSONAL DISPLAYS",Rect2(22,698,210,60),func():open("preferences"))
	button("companions","COMPANIONS",Rect2(248,698,210,60),func():open("companions"))
	# Reuse existing safe menu components, but physically move them into this
	# PackedScene. They cannot remain active beneath the Hub.
	game.hideout_ui.home_settings_content.reparent(self)
	game.hideout_ui.companion_collection_content.reparent(self)

func button(id: String,text: String,rect: Rect2,action: Callable) -> void:
	var b: Button=game.hideout_ui.make_button(room,text,rect,Color("#192936ef"),Color("#dcb973"),15)
	b.set_meta("gesture_release_owned",true);buttons[id]=b;b.pressed.connect(action)

func open(next: String="room") -> void:
	game.state="personal_home";game.hideout_ui.visible=false;game.startup_ui.visible=false
	game.hideout_ui.dismiss_dialogue();game.hideout_ui.loadout_panel.visible=false
	visible=true;view=next;room.visible=view=="room"
	game.hideout_ui.home_settings_content.visible=view=="preferences"
	game.hideout_ui.companion_collection_content.visible=view=="companions"
	game.hideout_ui.current_screen="home_settings" if view=="preferences" else "companion_collection" if view=="companions" else "personal_home"
	game.hideout_ui.profile=game.profile.duplicate(true);game.hideout_ui.refresh_home_settings()
	title.text="YOUR HOME";follower.react("return");queue_redraw();game.queue_redraw()

func go_back() -> void:
	if view=="companions":open("preferences")
	elif view=="preferences":open("room")
	else:game.show_hideout()

func _process(delta: float) -> void:
	if not visible:return
	time+=delta;follower.update(delta,Vector2(240,570));queue_redraw()

func _draw() -> void:
	if game==null or not visible:return
	# Existing accepted private storage interior; full-screen scene backdrop,
	# not the Hub's painting with a menu over its NPCs.
	if game.responsive_backdrop==null:draw_texture_rect(BACKGROUND,Rect2(0,0,480,854),false)
	draw_rect(Rect2(0,0,480,80),Color("#091124d0"))
	if view!="room":return
	draw_set_transform(Vector2(240,570),0,Vector2(1,.18));draw_circle(Vector2.ZERO,50,Color("#03071166"));draw_set_transform(Vector2.ZERO)
	UI.draw_icon(get_canvas_item(),game.hideout_ui.actor_texture(),Rect2(148,394,184,188))
	var display: String=game.profile.get("homestead",{}).get("display","weapon")
	var art: Texture2D=null
	if display=="weapon":art=UI.item_texture(game.inventory.equipped_item("Weapon"))
	elif display=="scroll":art=preload("res://art/production/phase4e/items/recipe_scroll.png")
	elif display=="trophy":art=preload("res://art/production/phase4e/props/trophy_dais.png")
	UI.draw_icon(get_canvas_item(),art,Rect2(351,267,70,70))
	follower.draw_home(self,preload("res://companion_catalog.gd").sanitize(game.profile.get("companion",{})))
