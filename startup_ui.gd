extends Control

signal enter_hideout
signal profile_completed
signal profile_changed(profile: Dictionary)
signal settings_changed(settings: Dictionary)
signal ui_event(event_name: String)
signal story_preview_requested(id: String, preview_profile: Dictionary)

const ProfileStore = preload("res://profile_store.gd")
const SettingsStore = preload("res://settings_store.gd")
const LootlingsUI = preload("res://lootlings_ui.gd")
const PresentationDirector = preload("res://presentation_director.gd")
const LootlingCatalog = preload("res://lootling_catalog.gd")
const WandererCatalog = preload("res://wanderer_catalog.gd")
const Avatar = preload("res://avatar_presentation.gd")
const MASCOT_TEXTURE = preload("res://art/sprites/relic_beast_base.png")
const TITLE_ART = preload("res://art/backgrounds/lootlings_living_title_068.png")
const TITLE_TALL_ART=preload("res://art/backgrounds/lootlings_living_title_tall_068.png")
const TITLE_WIDE_ART=preload("res://art/backgrounds/lootlings_living_title_wide_068.png")
const BACKGROUND = preload("res://art/backgrounds/treasure_ruins_arena.png")

var profile := {}
var settings := {}
var settings_return_screen := "title"
var profile_exists := false
var current_screen := "boot"
var boot_timer := 0.0
var scene_time := 0.0
var boot_content: Control
var title_content: Control
var profile_content: Control
var settings_content: Control
var lootling_content: Control
var name_edit: LineEdit
var nickname_edit: LineEdit
var profile_heading: Label
var profile_id_label: Label
var support_panel: Panel
var setting_sliders := {}
var setting_mutes := {}
var audio_preset:OptionButton
var refreshing_settings := false
var combat_preferences: Panel
var combat_choices := {}
var combat_toggles := {}
var cinematic_preferences: Panel
var cinematic_toggles := {}
var presentation
var selected_lootling_id := "relic_beast"
var lootling_roster_buttons := {}
var wanderer_roster_buttons := {}
var selector_portrait: TextureRect
var selector_name: Label
var selector_lore: Label
var selector_note: Label
var selector_confirm: Button
var profile_identity: Label
var profile_actor_name: Label
var wanderer_content: Control
var wanderer_portrait: TextureRect
var wanderer_name: Label
var wanderer_lore: Label
var wanderer_origin: OptionButton
var wanderer_lineage: OptionButton
var wanderer_pronouns: LineEdit
var wanderer_voice: OptionButton
var selected_wanderer := "vault_runner"
var wanderer_confirm: Button
var title_wordmark:TextureRect
var title_ambience:Control
var title_tagline:Label
var title_roster_buttons := {}
var title_menu_buttons:Dictionary={}
var title_identity: Label
var title_personality: Label
var identity_panel: Panel
var wanderer_personality: Label
var wanderer_weapon: Label
var showcase_pages: Dictionary={}
var showcase_finger: int=-1
var showcase_start:=Vector2.ZERO
var showcase_screen: String=""
var showcase_cancelled: bool=false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	build_boot()
	build_title()
	build_profile()
	build_lootling_select()
	build_wanderer_select()
	build_settings()
	presentation = PresentationDirector.new()
	add_child(presentation)
	presentation.bind_buttons(self)
	set_process(true)

func configure(profile_data: Dictionary, has_profile: bool, settings_data: Dictionary) -> void:
	profile = profile_data.duplicate(true)
	profile_exists = has_profile
	settings = settings_data.duplicate(true)
	refresh_profile()
	refresh_settings()
	show_boot()

func build_boot() -> void:
	boot_content = Control.new()
	boot_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(boot_content)
	var core := LootlingsUI.add_icon(boot_content, Rect2(160, 270, 160, 110), "core_neutral")
	core.name = "CoreGlyph"
	LootlingsUI.add_wordmark(boot_content, Rect2(30, 350, 420, 100))
	make_label(boot_content, "PACK LIGHT. COME HOME HEAVY.", 14, Rect2(40, 448, 400, 30), HORIZONTAL_ALIGNMENT_CENTER, Color("#b9c9ee"))
	var skip := make_button(boot_content, "TAP TO BEGIN", Rect2(120, 696, 240, 58), Color("#142144dd"), Color("#d1a85a"), 16)
	skip.pressed.connect(skip_boot)

func build_title() -> void:
	title_content = Control.new()
	title_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title_content.visible = false
	add_child(title_content)
	title_ambience=preload("res://world_ambience.gd").new()
	title_ambience.configure(Rect2(28,250,424,345),func():return settings)
	title_ambience.living_title=true
	title_content.add_child(title_ambience)
	title_wordmark=LootlingsUI.add_wordmark(title_content, Rect2(24, 42, 432, 108))
	title_tagline=make_label(title_content, "PACK LIGHT. COME HOME HEAVY.", 14, Rect2(30, 492, 420, 28), HORIZONTAL_ALIGNMENT_CENTER, Color("#d7e5ff"))
	# Franchise ensemble uses the seven accepted canonical portrait sources,
	# never marketing boards or alternate actor designs.
	var index:=0
	for id in LootlingCatalog.selectable_ids():
		var tile:=make_button(title_content,"",Rect2(44+index*56,528,56,56),Color("#101d32e8"),Color("#6d84a5"),12)
		tile.tooltip_text="View "+str(LootlingCatalog.definition(id).display_name)
		title_roster_buttons[id]=tile
		tile.pressed.connect(func():show_lootling_select();selected_lootling_id=id;refresh_selector())
		var face:=TextureRect.new()
		face.name="FranchisePortrait_"+id
		# Set expansion before assigning a large atlas; otherwise its intrinsic
		# minimum expands the Control before the requested small size is applied.
		face.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		face.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		face.texture=Avatar.portrait({"current_lootling_id":id,"avatar_mode":"lootling"},"happy")
		face.position=Vector2(49+index*56,533)
		face.size=Vector2(46,46)
		face.mouse_filter=Control.MOUSE_FILTER_IGNORE
		face.tooltip_text=LootlingCatalog.definition(id).display_name
		title_content.add_child(face)
		index+=1
	title_identity=make_label(title_content,"",16,Rect2(38,589,404,28),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe3ac"))
	title_personality=make_label(title_content,"",12,Rect2(36,805,408,26),HORIZONTAL_ALIGNMENT_CENTER,Color("#d7e5ff"))
	var play := make_button(title_content, "START", Rect2(92, 622, 296, 72), Color("#6f4b1fef"), Color("#ffda72"), 21)
	play.pressed.connect(request_play)
	var profile_button := make_button(title_content, "PROFILE", Rect2(68, 712, 160, 60), Color("#17294be8"), Color("#72c8ff"), 17)
	profile_button.pressed.connect(func(): ui_event.emit("menu_open"); show_profile(false))
	var settings_button := make_button(title_content, "SETTINGS", Rect2(252, 712, 160, 60), Color("#17294be8"), Color("#c99cff"), 17)
	settings_button.pressed.connect(func(): ui_event.emit("menu_open"); show_settings())
	title_menu_buttons={"START":play,"PROFILE":profile_button,"SETTINGS":settings_button}
	style_title_button(play,true)
	style_title_button(profile_button,false)
	style_title_button(settings_button,false)
	# One approved environment and original logo. Selection galleries remain in
	# their existing flows; secondary controls stay quiet and directly reachable.
	for child in title_content.get_children():
		if child not in [title_wordmark,title_ambience,play,profile_button,settings_button]:child.hide()
	if OS.has_feature("windows") or OS.has_feature("linux") or OS.has_feature("macos"):
		var exit_button:=make_button(title_content,"EXIT",Rect2(184,786,112,60),Color("#17294b"),Color("#7087ae"),13)
		exit_button.pressed.connect(func():
			if get_parent().app_lifecycle.persist()==OK:get_tree().quit()
			else:exit_button.tooltip_text="Could not save. Retry Exit, or export a backup from Settings.")
		style_title_button(exit_button,false)
		title_menu_buttons["EXIT"]=exit_button


func build_profile() -> void:
	profile_content = Control.new()
	profile_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	profile_content.visible = false
	add_child(profile_content)
	make_button(profile_content, "‹ BACK", Rect2(24,20,112,52), Color("#17294b"), Color("#72c8ff"), 15).pressed.connect(func(): get_parent().navigate_back())
	make_button(profile_content, "SETTINGS", Rect2(320,20,136,52), Color("#17294b"), Color("#c99cff"), 15).pressed.connect(show_settings)
	var panel := make_panel(profile_content, Rect2(34, 102, 412, 650), Color("#0b1430f2"), Color("#d1a85a"))
	profile_heading = make_label(panel, "YOUR LOOTLINGS PROFILE", 26, Rect2(20, 28, 372, 45), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	make_label(panel, "DISPLAY NAME", 13, Rect2(38, 103, 336, 24), HORIZONTAL_ALIGNMENT_LEFT, Color("#9fb3d8"))
	name_edit = LineEdit.new()
	name_edit.position = Vector2(38, 130)
	name_edit.size = Vector2(336, 56)
	name_edit.max_length = 20
	name_edit.placeholder_text = "Treasure Seeker"
	name_edit.add_theme_font_size_override("font_size", 19)
	LootlingsUI.apply_input(name_edit)
	panel.add_child(name_edit)
	make_label(panel, "LOOTLING NICKNAME  •  OPTIONAL", 13, Rect2(38, 211, 336, 24), HORIZONTAL_ALIGNMENT_LEFT, Color("#9fb3d8"))
	nickname_edit = LineEdit.new()
	nickname_edit.position = Vector2(38, 238)
	nickname_edit.size = Vector2(336, 56)
	nickname_edit.max_length = 20
	nickname_edit.placeholder_text = "Leave blank for now"
	nickname_edit.add_theme_font_size_override("font_size", 18)
	LootlingsUI.apply_input(nickname_edit)
	panel.add_child(nickname_edit)
	LootlingsUI.add_divider(panel, Rect2(38, 304, 336, 10), "gold")
	make_label(panel, "PLAYER CARD", 13, Rect2(38, 326, 336, 24), HORIZONTAL_ALIGNMENT_LEFT, Color("#9fb3d8"))
	profile_actor_name = make_label(panel, "RELIC BEAST     •     RUIN ROOKIE", 15, Rect2(38, 355, 336, 38), HORIZONTAL_ALIGNMENT_CENTER, Color("#e7edff"))
	LootlingsUI.add_icon(panel, Rect2(65, 362, 24, 24), "core_neutral")
	var identity_card := make_label(panel, "BANNER  •  OUTER RUINS\nCURRENT LOOTLING  •  RELIC BEAST", 11, Rect2(38, 395, 336, 44), HORIZONTAL_ALIGNMENT_CENTER, Color("#b8c7e7"))
	profile_identity = identity_card
	identity_card.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var change := make_button(panel, "CHANGE AVATAR", Rect2(45, 482, 322, 54), Color("#17294b"), Color("#72c8ff"), 16)
	change.pressed.connect(func(): show_wanderer_select() if Avatar.is_wanderer(profile) else show_lootling_select())
	var save := make_button(panel, "SAVE PROFILE", Rect2(40, 553, 332, 66), Color("#285c4c"), Color("#69e6b0"), 19)
	save.pressed.connect(save_profile)

func build_settings() -> void:
	settings_content = Control.new()
	settings_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_content.visible = false
	add_child(settings_content)
	var panel := make_panel(settings_content, Rect2(28, 75, 424, 710), Color("#0b1430f4"), Color("#c99cff"))
	LootlingsUI.apply_material(panel, "relic")
	make_label(panel, "AUDIO & ACCESSIBILITY", 23, Rect2(20, 24, 384, 46), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	audio_preset=OptionButton.new();audio_preset.position=Vector2(30,76);audio_preset.size=Vector2(366,48)
	audio_preset.add_item("Custom")
	for preset in SettingsStore.AUDIO_PRESETS:audio_preset.add_item(preset)
	audio_preset.item_selected.connect(apply_audio_preset);panel.add_child(audio_preset)
	var channels := SettingsStore.CHANNELS
	for index in range(channels.size()):
		var channel: String = channels[index]
		var y := 137 + index * 89
		make_label(panel, {"master":"MASTER", "music":"MUSIC", "sfx":"SOUND EFFECTS", "ui":"MENU SOUNDS", "ambience":"AMBIENCE"}[channel], 14, Rect2(30, y, 120, 24), HORIZONTAL_ALIGNMENT_LEFT, Color("#d9e5ff"))
		var slider := HSlider.new()
		slider.position = Vector2(30, y + 29)
		slider.size = Vector2(258, 48)
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.01
		var handle = preload("res://art/ui/brand/slider_handle.svg")
		for state in ["grabber","grabber_highlight","grabber_disabled"]:
			slider.add_theme_icon_override(state,handle)
		var track := StyleBoxFlat.new()
		track.bg_color = Color("#233c63")
		track.content_margin_top = 5
		track.content_margin_bottom = 5
		track.corner_radius_top_left = 5
		track.corner_radius_top_right = 5
		track.corner_radius_bottom_left = 5
		track.corner_radius_bottom_right = 5
		slider.add_theme_stylebox_override("slider",track)
		var percentage := make_label(panel,"",14,Rect2(205,y,82,24),HORIZONTAL_ALIGNMENT_RIGHT,Color("#ffe178"))
		slider.value_changed.connect(func(value):
			percentage.text = "%d%%" % roundi(value*100)
			if not refreshing_settings:audio_preset.select(0))
		percentage.text = "%d%%" % roundi(slider.value*100)
		panel.add_child(slider)
		setting_sliders[channel] = slider
		var mute := CheckButton.new()
		mute.text = "MUTE"
		mute.position = Vector2(300, y + 22)
		mute.size = Vector2(96, 48)
		mute.add_theme_font_size_override("font_size", 12)
		panel.add_child(mute)
		setting_mutes[channel] = mute
	var story_settings := make_button(panel, "STORY", Rect2(26, 590, 114, 48), Color("#17294b"), Color("#c99cff"), 14)
	story_settings.pressed.connect(func(): cinematic_preferences.visible = true)
	make_button(panel,"COMBAT TEXT",Rect2(154,590,116,48),Color("#17294b"),Color("#72c8ff"),12).pressed.connect(func():combat_preferences.show())
	support_panel = make_panel(settings_content,Rect2(28,75,424,710),Color("#0b1430ff"),Color("#72c8ff"))
	support_panel.visible = false
	LootlingsUI.apply_material(support_panel,"leather")
	if preload("res://owner_test_access.gd").enabled():
		make_label(support_panel,"OWNER TEST BUILD • ISOLATED SAVES",14,Rect2(24,298,376,44),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe178"))
		make_button(support_panel,"OWNER TOOLS",Rect2(42,354,340,54),Color("#17294b"),Color("#72c8ff"),16).pressed.connect(func():get_parent().owner_test_access.backup_open())
	make_label(support_panel,"SUPPORT",26,Rect2(22,24,380,44),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe178"))
	profile_id_label = make_label(support_panel,"",14,Rect2(24,116,376,64),HORIZONTAL_ALIGNMENT_CENTER,Color("#b8c7e7"))
	profile_id_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	make_label(support_panel,"Keep your progress safe. Replay a guide, manage your backups, or include the ID above when reporting a problem.",16,Rect2(32,194,360,92),HORIZONTAL_ALIGNMENT_CENTER,Color("#d5e1f1"))
	make_button(support_panel,"FIELD GUIDE · REPLAY HELP",Rect2(42,438,340,54),Color("#17294b"),Color("#72c8ff"),16).pressed.connect(func():get_parent().contextual_guide.open())
	make_button(support_panel,"SAVES & BACKUPS",Rect2(42,508,340,54),Color("#17294b"),Color("#72c8ff"),16).pressed.connect(func():get_parent().backup_menu.open())
	var support_back := make_button(support_panel,"‹ SETTINGS",Rect2(42,638,340,54),Color("#17294b"),Color("#72c8ff"),16)
	support_back.pressed.connect(func(): support_panel.visible = false)
	var support := make_button(panel,"SUPPORT",Rect2(284,590,114,48),Color("#17294b"),Color("#72c8ff"),14)
	support.pressed.connect(func(): support_panel.visible = true)
	var back := make_button(panel, "SAVE & RETURN", Rect2(42, 638, 340, 54), Color("#49346b"), Color("#d19cff"), 18)
	back.pressed.connect(save_settings)
	cinematic_preferences = make_panel(settings_content, Rect2(28, 75, 424, 710), Color("#0b1430ff"), Color("#c99cff"))
	LootlingsUI.apply_material(cinematic_preferences, "relic")
	cinematic_preferences.visible = false
	make_label(cinematic_preferences, "STORY & MOTION", 26, Rect2(22,24,380,44), HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe178"))
	var options := {"cinematic_first_time":"First-time story moments", "cinematic_repeat_boss":"Short repeat boss stings", "cinematic_auto_skip":"Auto-skip viewed moments", "cinematic_reduced_motion":"Reduced cinematic motion", "cinematic_subtitles":"Story captions", "reward_announcements":"Reward voice announcements"}
	var index := 0
	for key in options:
		var toggle := CheckButton.new()
		toggle.text = str(options[key])
		toggle.position = Vector2(28,90+index*62)
		toggle.size = Vector2(368,54)
		toggle.add_theme_font_size_override("font_size",17)
		cinematic_preferences.add_child(toggle)
		cinematic_toggles[key] = toggle
		index += 1
	make_label(cinematic_preferences,"Every story moment can be skipped.\nArchive replays never grant rewards.",14,Rect2(26,478,372,46),HORIZONTAL_ALIGNMENT_CENTER,Color("#c9d8f0"))
	make_button(cinematic_preferences,"DONE",Rect2(42,544,340,52),Color("#17294b"),Color("#72c8ff"),17).pressed.connect(func(): cinematic_preferences.visible = false)


	combat_preferences = make_panel(settings_content,Rect2(28,75,424,710),Color("#0b1430ff"),Color("#72c8ff"))
	combat_preferences.visible = false
	make_label(combat_preferences,"COMBAT TEXT",26,Rect2(24,24,376,44),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe178"))
	make_label(combat_preferences,"Your hits. Your style.\nColours and words identify each damage type.",16,Rect2(28,80,368,64),HORIZONTAL_ALIGNMENT_CENTER,Color("#c9d8f0"))
	var choices := {"combat_text_mode":["Off","Minimal","Standard","Expressive"],"combat_text_size":["Small","Normal","Large"]}
	var row := 0
	for key in choices:
		make_label(combat_preferences,"AMOUNT OF FEEDBACK" if row==0 else "NUMBER SIZE",14,Rect2(28,160+row*108,368,26),HORIZONTAL_ALIGNMENT_LEFT,Color("#c9d8f0"))
		var choice := OptionButton.new()
		choice.position=Vector2(28,190+row*108);choice.size=Vector2(368,56)
		choice.add_theme_font_size_override("font_size",18)
		for value in choices[key]:choice.add_item(value)
		combat_preferences.add_child(choice);combat_choices[key]=choice
		row+=1
	for key in {"combat_crit_emphasis":"Emphasise critical hits","combat_aggregate":"Combine rapid repeated hits"}:
		var toggle := CheckButton.new()
		toggle.text="Emphasise critical hits" if key=="combat_crit_emphasis" else "Combine rapid repeated hits"
		toggle.position=Vector2(28,380 if key=="combat_crit_emphasis" else 444);toggle.size=Vector2(368,56)
		toggle.add_theme_font_size_override("font_size",17)
		combat_preferences.add_child(toggle);combat_toggles[key]=toggle
	make_label(combat_preferences,"Minimal keeps critical and defensive feedback.\nReduced motion in Story also stops text movement.\nChanges apply with Save & Return.",14,Rect2(28,522,368,88),HORIZONTAL_ALIGNMENT_CENTER,Color("#c9d8f0"))
	make_button(combat_preferences,"DONE",Rect2(42,638,340,54),Color("#17294b"),Color("#72c8ff"),17).pressed.connect(func():combat_preferences.hide())

func build_lootling_select() -> void:
	lootling_content=Control.new(); lootling_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); lootling_content.visible=false; add_child(lootling_content)
	add_roster_tabs(lootling_content,false)
	var panel:=make_panel(lootling_content,Rect2(24,82,432,758),Color("#0b1430ed"),Color("#d1a85a"))
	make_label(panel,"CHOOSE YOUR LOOTLING",21,Rect2(20,16,392,35),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe178"))
	style_hero_stage(panel)
	selector_portrait=TextureRect.new(); selector_portrait.position=Vector2(51,47); selector_portrait.size=Vector2(330,270); selector_portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; selector_portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; selector_portrait.mouse_filter=Control.MOUSE_FILTER_IGNORE; panel.add_child(selector_portrait)
	selector_name=make_label(panel,"",24,Rect2(24,319,384,38),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe6a0"))
	selector_lore=make_label(panel,"",15,Rect2(28,365,376,42),HORIZONTAL_ALIGNMENT_CENTER,Color("#d9e5ff")); selector_lore.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	selector_note=make_label(panel,"",14,Rect2(28,411,376,68),HORIZONTAL_ALIGNMENT_CENTER,Color("#b9c9ee")); selector_note.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	make_label(panel,"Your trait travels with every weapon.",12,Rect2(28,486,376,22),HORIZONTAL_ALIGNMENT_CENTER,Color("#d9cba8"))
	add_roster_strip(panel,false,Vector2(18,514))
	selector_confirm=make_button(panel,"CHOOSE",Rect2(26,644,380,56),Color("#285c4c"),Color("#69e6b0"),18); selector_confirm.pressed.connect(confirm_lootling)
	make_button(panel,"ORIGIN MEMORY",Rect2(26,706,380,48),Color("#17294b"),Color("#7087ae"),13).pressed.connect(func():
		var preview:=profile.duplicate(true); preview.current_lootling_id=selected_lootling_id; story_preview_requested.emit("character/"+selected_lootling_id,preview)
	)

func add_roster_tabs(parent: Control, human: bool) -> void:
	make_button(parent,"LOOTLINGS",Rect2(24,20,210,48),Color("#293a46") if not human else Color("#17294b"),Color("#e2b563") if not human else Color("#7087ae"),16).pressed.connect(show_lootling_select)
	make_button(parent,"WANDERERS",Rect2(246,20,210,48),Color("#293a46") if human else Color("#17294b"),Color("#e2b563") if human else Color("#7087ae"),15).pressed.connect(show_wanderer_select)

func add_roster_strip(parent: Control, human: bool, point: Vector2) -> void:
	# One character showcase; no small, vertically clipped roster grid.
	var previous:=make_button(parent,"<",Rect2(point+Vector2(0,16),Vector2(52,56)),Color("#17294b"),Color("#d1a85a"),24)
	var next:=make_button(parent,">",Rect2(point+Vector2(344,16),Vector2(52,56)),Color("#17294b"),Color("#d1a85a"),24)
	previous.name="PreviousWanderer" if human else "PreviousLootling"
	next.name="NextWanderer" if human else "NextLootling"
	previous.tooltip_text="Previous character";next.tooltip_text="Next character"
	previous.pressed.connect(func(): cycle_wanderer(-1) if human else cycle_lootling(-1))
	next.pressed.connect(func(): cycle_wanderer(1) if human else cycle_lootling(1))
	var page:=make_label(parent,"",14,Rect2(point+Vector2(60,19),Vector2(276,50)),HORIZONTAL_ALIGNMENT_CENTER,Color("#d9cba8"))
	page.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	showcase_pages["wanderer" if human else "lootling"]=page

func refresh_showcase_page(human: bool) -> void:
	var ids: Array=WandererCatalog.selectable_ids() if human else LootlingCatalog.selectable_ids()
	var id: String=selected_wanderer if human else selected_lootling_id
	var page: Label=showcase_pages["wanderer" if human else "lootling"]
	page.text="%d / %d\nSWIPE TO EXPLORE" % [ids.find(id)+1,ids.size()]
	if not settings.get("cinematic_reduced_motion",false):
		var portrait: TextureRect=wanderer_portrait if human else selector_portrait
		portrait.modulate.a=.75
		create_tween().tween_property(portrait,"modulate:a",1.0,.14)

func observe_showcase(event: InputEvent) -> bool:
	var game=get_parent()
	if not visible or current_screen not in ["lootling_select","wanderer_select"] or (game.input_surface()!=null and game.input_surface()!=self):
		showcase_finger=-1;return false
	if event is InputEventScreenTouch:
		if event.index!=0:
			showcase_cancelled=true;return false
		var point: Vector2=get_global_transform_with_canvas().affine_inverse()*event.position
		if event.pressed:
			if not Rect2(76,129,328,270).has_point(point):return false
			showcase_finger=0;showcase_start=point;showcase_screen=current_screen;showcase_cancelled=false
			return true
		if showcase_finger==event.index:
			showcase_finger=-1
			var delta: Vector2=point-showcase_start
			if not event.canceled and not showcase_cancelled and showcase_screen==current_screen and absf(delta.x)>=52 and absf(delta.x)>absf(delta.y)*1.5:
				if current_screen=="lootling_select":cycle_lootling(1 if delta.x<0 else -1)
				else:cycle_wanderer(1 if delta.x<0 else -1)
			return true
	if event is InputEventScreenDrag and event.index==showcase_finger:return true
	return false

func cycle_lootling(direction: int) -> void:
	var ids := LootlingCatalog.selectable_ids()
	selected_lootling_id = ids[posmod(ids.find(selected_lootling_id) + direction, ids.size())]
	refresh_selector()
	ui_event.emit("ui_press")

func refresh_selector() -> void:
	refresh_showcase_page(false)
	refresh_roster_selection(lootling_roster_buttons,selected_lootling_id)
	var entry := LootlingCatalog.definition(selected_lootling_id)
	selector_portrait.texture = preload("res://showcase_art.gd").texture(selected_lootling_id)
	selector_portrait.modulate = LootlingCatalog.presentation_tint(selected_lootling_id)
	selector_name.text = str(entry.display_name).to_upper()
	selector_lore.text = str(entry.personality)
	var trait_data: Dictionary = preload("res://character_traits.gd").TRAITS[selected_lootling_id]
	selector_note.text = "%s • %s" % [trait_data.name,trait_data.text]
	selector_confirm.disabled = not entry.available
	selector_confirm.text = "CHOOSE %s" % str(entry.display_name).to_upper()

func show_lootling_select() -> void:
	selected_lootling_id = str(profile.get("current_lootling_id", "relic_beast"))
	refresh_selector()
	current_screen = "lootling_select"
	set_screen(lootling_content)

func confirm_lootling() -> void:
	if not LootlingCatalog.definition(selected_lootling_id).available:
		return
	profile.current_lootling_id = selected_lootling_id
	profile.avatar_mode = "lootling"
	profile_changed.emit(profile.duplicate(true))
	ui_event.emit("upgrade_select")
	profile_completed.emit()

func build_wanderer_select() -> void:
	wanderer_content=Control.new(); wanderer_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); wanderer_content.visible=false; add_child(wanderer_content); add_roster_tabs(wanderer_content,true)
	var panel:=make_panel(wanderer_content,Rect2(24,82,432,758),Color("#0b1430ed"),Color("#d1a85a"))
	make_label(panel,"WANDERERS",21,Rect2(20,16,392,35),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe178"))
	style_hero_stage(panel)
	wanderer_portrait=TextureRect.new(); wanderer_portrait.position=Vector2(76,45); wanderer_portrait.size=Vector2(280,270); wanderer_portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; wanderer_portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; wanderer_portrait.mouse_filter=Control.MOUSE_FILTER_IGNORE; panel.add_child(wanderer_portrait)
	wanderer_name=make_label(panel,"",20,Rect2(20,319,392,32),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe6a0"))
	wanderer_personality=make_label(panel,"",14,Rect2(28,358,376,45),HORIZONTAL_ALIGNMENT_CENTER,Color("#d9e5ff")); wanderer_personality.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	wanderer_lore=make_label(panel,"",14,Rect2(28,411,376,68),HORIZONTAL_ALIGNMENT_CENTER,Color("#b9c9ee")); wanderer_lore.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	wanderer_weapon=make_label(panel,"",13,Rect2(28,486,376,22),HORIZONTAL_ALIGNMENT_CENTER,Color("#d9cba8"))
	add_roster_strip(panel,true,Vector2(18,514))
	wanderer_confirm=make_button(panel,"CHOOSE WANDERER",Rect2(26,644,380,56),Color("#285c4c"),Color("#69e6b0"),18); wanderer_confirm.pressed.connect(confirm_wanderer)
	make_button(panel,"IDENTITY & ORIGIN",Rect2(26,706,380,48),Color("#17294b"),Color("#7087ae"),13).pressed.connect(func(): identity_panel.visible=not identity_panel.visible)
	identity_panel=make_panel(wanderer_content,Rect2(24,260,432,566),Color("#10182bfa"),Color("#d8bd7b")); identity_panel.z_index=30; identity_panel.visible=false
	make_button(identity_panel,"DONE",Rect2(268,10,144,48),Color("#17294b"),Color("#7087ae"),14).pressed.connect(func(): identity_panel.visible=false)
	wanderer_origin=add_identity_choice(identity_panel,"ORIGIN",Rect2(24,74,384,48),WandererCatalog.ORIGINS)
	wanderer_lineage=add_identity_choice(identity_panel,"LINEAGE",Rect2(24,166,384,48),WandererCatalog.LINEAGES)
	wanderer_voice=add_identity_choice(identity_panel,"VOICE STYLE",Rect2(24,258,384,48),{"warm":"Warm","dry":"Dry","bold":"Bold","soft":"Soft","playful":"Playful","ominous":"Ominous"})
	make_label(identity_panel,"PRONOUNS",12,Rect2(24,347,384,24),HORIZONTAL_ALIGNMENT_LEFT,Color("#9fb3d8"))
	wanderer_pronouns=LineEdit.new(); wanderer_pronouns.position=Vector2(24,378); wanderer_pronouns.size=Vector2(384,48); wanderer_pronouns.max_length=24; LootlingsUI.apply_input(wanderer_pronouns); identity_panel.add_child(wanderer_pronouns)
	make_button(identity_panel,"ORIGIN MEMORY",Rect2(24,456,384,48),Color("#17294b"),Color("#7087ae"),14).pressed.connect(func():
		var preview:=profile.duplicate(true); preview.wanderer.preset_id=selected_wanderer; story_preview_requested.emit("origin/"+str(wanderer_origin.get_item_metadata(wanderer_origin.selected)),preview)
	)

func add_identity_choice(parent: Node, heading: String, rect: Rect2, entries: Dictionary) -> OptionButton:
	make_label(parent, heading, 12, Rect2(rect.position, Vector2(rect.size.x, 20)), HORIZONTAL_ALIGNMENT_LEFT, Color("#9fb3d8"))
	var choice := OptionButton.new()
	choice.position = rect.position + Vector2(0, 23)
	choice.size = rect.size
	choice.add_theme_font_size_override("font_size", 15)
	LootlingsUI.apply_button(choice, Color("#17294b"), Color("#72c8ff"))
	for id in entries:
		var value: Variant = entries[id]
		choice.add_item(str(value.name) if value is Dictionary else str(value))
		choice.set_item_metadata(choice.item_count - 1, id)
	parent.add_child(choice)
	return choice

func select_identity(choice: OptionButton, id: String) -> void:
	for index in range(choice.item_count):
		if str(choice.get_item_metadata(index)) == id:
			choice.select(index)
			return

func show_wanderer_select() -> void:
	var appearance := WandererCatalog.sanitize(profile.get("wanderer", {}))
	selected_wanderer = str(appearance.preset_id)
	select_identity(wanderer_origin, str(appearance.origin))
	select_identity(wanderer_lineage, str(appearance.lineage))
	select_identity(wanderer_voice, str(appearance.voice))
	wanderer_pronouns.text = str(appearance.pronouns)
	refresh_wanderer_selector()
	identity_panel.visible=false
	current_screen = "wanderer_select"
	set_screen(wanderer_content)

func cycle_wanderer(direction: int) -> void:
	var ids := WandererCatalog.selectable_ids()
	if ids.is_empty():
		return
	selected_wanderer = ids[posmod(ids.find(selected_wanderer) + direction, ids.size())]
	refresh_wanderer_selector()
	ui_event.emit("ui_press")

func refresh_wanderer_selector() -> void:
	refresh_showcase_page(true)
	refresh_roster_selection(wanderer_roster_buttons,selected_wanderer)
	wanderer_portrait.texture = preload("res://showcase_art.gd").texture(selected_wanderer,true)
	var ids := WandererCatalog.selectable_ids()
	wanderer_name.text = str(WandererCatalog.definition(selected_wanderer).display_name).to_upper()
	wanderer_confirm.disabled = wanderer_portrait.texture == null
	refresh_wanderer_lore()

func refresh_wanderer_lore() -> void:
	var id := str(wanderer_origin.get_item_metadata(wanderer_origin.selected))
	var trait_data: Dictionary = preload("res://character_traits.gd").TRAITS[selected_wanderer]
	wanderer_lore.text = str(trait_data.name) + " • " + str(trait_data.text)
	var cohort: Dictionary = preload("res://phase4_catalog.gd").HUMANS[selected_wanderer]
	wanderer_portrait.tooltip_text = "%s\n%s\nAffinity: %s. No weapon lock.\nMastery: %s" % [cohort.role,cohort.bio,cohort.affinity,cohort.mastery]
	wanderer_personality.text=str(preload("res://contextual_dialogue.gd").PERSONALITY[selected_wanderer])
	wanderer_weapon.text="Affinity: "+str(cohort.affinity)+" • any weapon"

func confirm_wanderer() -> void:
	if WandererCatalog.runtime_texture(selected_wanderer) == null:
		return
	var appearance := WandererCatalog.sanitize(profile.get("wanderer", {}))
	appearance.preset_id = selected_wanderer
	appearance.origin = str(wanderer_origin.get_item_metadata(wanderer_origin.selected))
	appearance.lineage = str(wanderer_lineage.get_item_metadata(wanderer_lineage.selected))
	appearance.voice = str(wanderer_voice.get_item_metadata(wanderer_voice.selected))
	appearance.pronouns = wanderer_pronouns.text
	profile.wanderer = WandererCatalog.sanitize(appearance)
	profile.avatar_mode = "wanderer"
	profile_changed.emit(profile.duplicate(true))
	ui_event.emit("upgrade_select")
	profile_completed.emit()

func show_boot() -> void:
	# Imported assets are ready; no simulated loading or skip screen.
	show_title()

func skip_boot() -> void:
	ui_event.emit("ui_press")
	show_title()

func request_play() -> void:
	ui_event.emit("ui_press")
	if profile_exists:
		enter_hideout.emit()
	else:
		show_profile(true)

func show_title() -> void:
	var actor_id: String=str(profile.get("current_lootling_id","relic_beast"))
	for id in title_roster_buttons:
		var chosen: bool=not Avatar.is_wanderer(profile) and id==actor_id
		var style:=StyleBoxFlat.new();style.bg_color=Color("#293946ef") if chosen else Color("#101d32e8");style.border_color=Color("#ffda72") if chosen else Color("#6d84a5");style.set_border_width_all(2 if chosen else 1);style.set_corner_radius_all(10)
		title_roster_buttons[id].add_theme_stylebox_override("normal",style)
		title_roster_buttons[id].set_meta("ui_selected",chosen)
	var nickname: String=str(profile.get("lootling_nickname",""))
	title_identity.text=Avatar.display_name(profile) if nickname.is_empty() else nickname+" • "+Avatar.display_name(profile)
	title_identity.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	title_personality.text=Avatar.identity_line(profile) if Avatar.is_wanderer(profile) else str(LootlingCatalog.definition(actor_id).personality)
	current_screen = "title"
	set_screen(title_content)
	ui_event.emit("menu_transition")

func show_profile(first_launch: bool) -> void:
	current_screen = "profile_create" if first_launch else "profile"
	profile_heading.text = "WELCOME, TREASURE SEEKER" if first_launch else "YOUR LOOTLINGS PROFILE"
	refresh_profile()
	set_screen(profile_content)

func show_settings() -> void:
	if current_screen != "settings": settings_return_screen = current_screen
	support_panel.visible = false
	current_screen = "settings"
	refresh_settings()
	cinematic_preferences.visible = false
	combat_preferences.hide()
	set_screen(settings_content)

func save_profile() -> void:
	var cleaned_name := ProfileStore.sanitize_name(name_edit.text)
	if cleaned_name.is_empty():
		name_edit.placeholder_text = "Choose a display name first"
		name_edit.grab_focus()
		return
	var previous_name := str(profile.get("display_name", ""))
	profile.display_name = cleaned_name
	profile.lootling_nickname = ProfileStore.sanitize_name(nickname_edit.text)
	if not previous_name.is_empty() and previous_name != cleaned_name:
		profile.rename_metadata.last_rename_unix = int(Time.get_unix_time_from_system())
		profile.rename_metadata.rename_count = int(profile.rename_metadata.get("rename_count", 0)) + 1
	var was_first_launch := not profile_exists
	profile_exists = true
	profile_changed.emit(profile.duplicate(true))
	ui_event.emit("upgrade_select")
	if was_first_launch:
		show_lootling_select()
	else:
		show_title()

func save_settings() -> void:
	settings.audio_preset=audio_preset.get_item_text(audio_preset.selected)
	for channel in SettingsStore.CHANNELS:
		settings[channel] = float(setting_sliders[channel].value)
		settings[channel + "_muted"] = bool(setting_mutes[channel].button_pressed)
	for key in cinematic_toggles: settings[key] = bool(cinematic_toggles[key].button_pressed)
	for key in combat_choices: settings[key]=combat_choices[key].get_item_text(combat_choices[key].selected)
	for key in combat_toggles: settings[key]=combat_toggles[key].button_pressed
	settings_changed.emit(settings.duplicate(true))
	ui_event.emit("menu_close")
	if settings_return_screen in ["profile", "profile_create"]: show_profile(settings_return_screen=="profile_create")
	else: show_title()

func handle_settings_back() -> bool:
	if current_screen != "settings": return false
	if support_panel.visible: support_panel.hide()
	elif cinematic_preferences.visible: cinematic_preferences.hide()
	elif combat_preferences.visible: combat_preferences.hide()
	else: save_settings()
	return true

func input_surface() -> Control:
	if identity_panel.is_visible_in_tree(): return identity_panel
	if current_screen == "settings":
		if support_panel.is_visible_in_tree(): return support_panel
		if cinematic_preferences.is_visible_in_tree(): return cinematic_preferences
		if combat_preferences.is_visible_in_tree(): return combat_preferences
	return self

func refresh_profile() -> void:
	if name_edit == null:
		return
	name_edit.text = str(profile.get("display_name", ""))
	nickname_edit.text = str(profile.get("lootling_nickname", ""))
	var uuid := str(profile.get("player_uuid", ""))
	profile_id_label.text = "ACCOUNT INFO  •  SUPPORT ID …%s" % uuid.right(8)
	profile_identity.text = "CURRENT AVATAR • %s" % Avatar.identity_line(profile).to_upper()
	profile_actor_name.text = Avatar.display_name(profile).to_upper()
	profile_actor_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

func refresh_settings() -> void:
	if setting_sliders.is_empty():
		return
	refreshing_settings=true
	for channel in SettingsStore.CHANNELS:
		setting_sliders[channel].value = float(settings.get(channel, 0.8))
		setting_mutes[channel].button_pressed = bool(settings.get(channel + "_muted", false))
	for key in cinematic_toggles: cinematic_toggles[key].button_pressed = bool(settings.get(key, SettingsStore.defaults()[key]))
	for key in combat_choices:
		var choice:OptionButton=combat_choices[key]
		for index in range(choice.item_count):
			if choice.get_item_text(index)==settings.get(key,SettingsStore.defaults()[key]):choice.select(index)
	for key in combat_toggles:combat_toggles[key].button_pressed=bool(settings.get(key,true))
	for index in range(audio_preset.item_count):
		if audio_preset.get_item_text(index)==settings.get("audio_preset","Custom"):audio_preset.select(index)
	refreshing_settings=false

func apply_audio_preset(index:int) -> void:
	audio_preset.select(index)
	var preset:String=audio_preset.get_item_text(index)
	if not SettingsStore.AUDIO_PRESETS.has(preset):return
	refreshing_settings=true
	for channel in SettingsStore.CHANNELS:setting_sliders[channel].value=SettingsStore.AUDIO_PRESETS[preset][channel]
	refreshing_settings=false

func set_screen(active: Control) -> void:
	var screens := [boot_content, title_content, profile_content, settings_content, lootling_content, wanderer_content]
	if presentation != null:
		presentation.switch_screen(screens, active, 0.24)
	else:
		for screen in screens:
			screen.visible = screen == active
	queue_redraw()

func _process(delta: float) -> void:
	scene_time += delta
	if current_screen=="title" and title_wordmark!=null:
		# Branding stays in the same safe frame as live menu controls.
		title_wordmark.position.y=42
		title_tagline.position.y=492
		layout_title_controls()

	if current_screen == "boot":
		boot_timer += delta
		var glyph := boot_content.get_node_or_null("CoreGlyph") as Control
		if glyph != null:
			glyph.modulate.a = 0.55 + sin(scene_time * 6.0) * 0.25
			glyph.scale = Vector2.ONE * (1.0 + sin(scene_time * 4.0) * 0.035)
		if boot_timer >= 1.35:
			skip_boot()
	queue_redraw()

func title_art_for_viewport() -> Texture2D:
	var aspect:float=get_viewport_rect().size.x/get_viewport_rect().size.y
	return TITLE_WIDE_ART if aspect>1.25 else TITLE_TALL_ART if aspect<.51 else TITLE_ART

func layout_title_controls() -> void:
	var wide:bool=get_viewport_rect().size.x/get_viewport_rect().size.y>1.25
	var positions:={"START":Rect2(92,622,296,72),"PROFILE":Rect2(68,712,160,60),"SETTINGS":Rect2(252,712,160,60),"EXIT":Rect2(184,786,112,60)}
	if wide:
		var total:=296.0+160+160+(112 if title_menu_buttons.has("EXIT") else 0)+24*(title_menu_buttons.size()-1)
		var x:float=240-total*.5
		for key in title_menu_buttons:
			var width:float=positions[key].size.x
			positions[key]=Rect2(x,786,width,60);x+=width+24
	for key in title_menu_buttons:
		title_menu_buttons[key].position=positions[key].position
		title_menu_buttons[key].size=positions[key].size

func _draw() -> void:
	var texture_size := BACKGROUND.get_size()
	var crop_height := texture_size.x * 854.0 / 480.0
	var source := Rect2(0, maxf(0.0, (texture_size.y - crop_height) * 0.5), texture_size.x, minf(texture_size.y, crop_height))
	if current_screen == "title":
		if get_parent().responsive_backdrop==null:
			draw_texture_rect(TITLE_ART,Rect2(0,0,480,854),false)
	else:
		if get_parent().responsive_backdrop == null: draw_texture_rect_region(BACKGROUND, Rect2(0, 0, 480, 854), source)
		draw_rect(Rect2(0, 0, 480, 854), Color("#0610298c"), true)
	if current_screen in ["lootling_select","wanderer_select"]:
		# Original stage lighting, not a replacement character illustration.
		for ring in range(4):
			draw_circle(Vector2(240,260),145-ring*26,Color(.27,.40,.60,.04+ring*.015))
		draw_set_transform(Vector2(240,387),0,Vector2(1,.20))
		draw_circle(Vector2.ZERO,136,Color("#050a17bb"))
		draw_arc(Vector2.ZERO,138,0,TAU,64,Color("#bc9c5870"),2,true)
		draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
		for mote in range(0 if settings.get("cinematic_reduced_motion",false) else 6):
			var point:=Vector2(102+mote*55,350-fmod(scene_time*12+mote*31,180))
			draw_circle(point,1.4,Color("#dfb65a66"))
	if current_screen != "title":draw_rect(Rect2(0, 0, 480, 5), Color("#d4a856"), true)

func make_panel(parent: Node, rect: Rect2, fill: Color, border: Color) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.add_theme_stylebox_override("panel", LootlingsUI.panel_style(fill, border, 22))
	parent.add_child(panel)
	return panel

func style_hero_stage(panel: Panel) -> void:
	var style:=StyleBoxFlat.new(); style.bg_color=Color("#07101e26"); style.border_color=Color("#c5a77766"); style.set_border_width_all(1); style.set_corner_radius_all(18)
	panel.add_theme_stylebox_override("panel",style)

func make_label(parent: Node, value: String, font_size: int, rect: Rect2, alignment: HorizontalAlignment, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = alignment
	label.add_theme_font_size_override("font_size", font_size)
	preload("res://lootlings_typography.gd").label(label,font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func make_button(parent: Node, value: String, rect: Rect2, fill: Color, border: Color, font_size: int) -> Button:
	var button := Button.new()
	button.set_meta("gesture_release_owned",true)
	button.text = value
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size", font_size)
	LootlingsUI.apply_button(button, fill, border)
	parent.add_child(button)
	return button

func refresh_roster_selection(buttons: Dictionary, selected_id: String) -> void:
	for id in buttons:
		var button: Button=buttons[id]
		button.set_meta("ui_selected",id==selected_id)
		button.set_meta("ui_intent","primary" if id==selected_id else "secondary")
		LootlingsUI.apply_button(button,Color("#17294b"),Color("#d1a85a"))
		var focus:=StyleBoxFlat.new();focus.bg_color=Color.TRANSPARENT;focus.border_color=Color("#d1dff6")
		focus.set_border_width_all(2);focus.set_corner_radius_all(10)
		button.add_theme_stylebox_override("focus",focus)

# Uses the accepted relic-metal button artwork; text and input remain native.
func style_title_button(button: Button, primary: bool) -> void:
	button.set_meta("ui_intent","primary" if primary else "utility")
	LootlingsUI.apply_button(button,Color("#102139"),Color("#d1a85a"))
	button.add_theme_font_size_override("font_size",20 if primary else (14 if button.text=="EXIT" else 17))
	button.add_theme_color_override("font_color",Color("#fff0c8") if primary else Color("#dfeafa"))
	button.add_theme_color_override("font_shadow_color",Color("#030a16"))
	button.add_theme_constant_override("shadow_offset_x",1)
	button.add_theme_constant_override("shadow_offset_y",2)
	if not primary:
		for state in ["normal","hover","pressed","disabled"]:
			var quiet:=StyleBoxFlat.new()
			quiet.bg_color=Color("#0714268c") if state in ["normal","disabled"] else Color("#061225d0")
			quiet.set_corner_radius_all(8)
			button.add_theme_stylebox_override(state,quiet)
	var focus:=StyleBoxFlat.new()
	focus.bg_color=Color.TRANSPARENT;focus.border_color=Color("#c3edff")
	focus.set_border_width_all(2);focus.set_corner_radius_all(8)
	button.add_theme_stylebox_override("focus",focus)
