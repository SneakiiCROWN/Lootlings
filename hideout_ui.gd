extends Control

signal play_requested
signal forge_requested(stash_index: int)
signal forge_craft_requested(weapon_type: String)
signal campaign_requested(region_id: String)
signal tracked_requested(id: String)
signal tier_requested(tier: int)
signal blueprint_requested(id: String)
signal farm_contract_requested(region: String)
var expedition_progress
var endgame_progress
var phase4_content: Control
var phase4_list: VBoxContainer
var phase4_detail: RichTextLabel
var phase4_detail_panel: Panel
var phase4_action: Button
var track_button: Button
var phase4_selected := ""
var phase4_mode := "blueprints"
var phase4_message := ""
var phase4_selected_msec := 0
var tier_buttons: Array[Button] = []
var selected_tier := 0
var selected_region_id := ""
var phase4_selections := {}
const Phase4 = preload("res://phase4_catalog.gd")
signal group_patrols_changed(enabled: bool)
signal dungeon_requested
signal engine_requested
var engine_button: Button
var group_patrols_enabled := false
var dungeon_start_button: Button
signal contract_claim_requested(slot: int)
signal stash_equip_requested(index: int)
signal stash_scrap_requested(index: int)
signal upgrade_requested
signal shop_offer_requested(index: int)
signal shop_cache_requested
signal shop_gold_cache_requested
signal shop_expansion_requested
signal shop_reroll_requested
signal gold_upgrade_requested(upgrade_id: String)
signal home_preferences_requested(home: Dictionary, companion: Dictionary)
signal profile_requested
signal title_requested
signal ui_event(event_name: String)
signal resident_meeting_requested(speaker: String)
signal memory_replay_requested(id: String)
signal destination_visited(destination_id: String)

const ItemCatalog = preload("res://item_catalog.gd")
const ItemIcon = preload("res://item_icon.gd")
const PresentationDirector = preload("res://presentation_director.gd")
const DialogueDirector = preload("res://dialogue_director.gd")
const WorldStory = preload("res://world_story.gd")
const BetaArt = preload("res://beta_art_catalog.gd")
const RESIDENT_PORTRAITS := {
	"Salvager":preload("res://art/production/phase4e/npcs/patch_canonical_station_panel.png"),
	"Relic Keeper":preload("res://art/sprites/npcs/beta/sera_portrait.png"),
	"Archivist":preload("res://art/production/phase4e/npcs/ilex_canonical_station_panel.png")
}
const HOME_SLOTS := {"pet_bed":Rect2(38,700,60,48),"trophy":Rect2(338,176,56,56),"weapon_display":Rect2(202,519,48,48),"banner":Rect2(92,124,48,100),"hearth":Rect2(32,268,64,64),"shelf":Rect2(350,614,64,48)}
const RESIDENT_RECTS := {"Salvager":Rect2(346,336,88,132), "Relic Keeper":Rect2(42,334,88,132), "Archivist":Rect2(352,562,80,120)}
const LootlingsUI = preload("res://lootlings_ui.gd")
const LootlingCatalog = preload("res://lootling_catalog.gd")
const Avatar = preload("res://avatar_presentation.gd")
const WandererCatalog = preload("res://wanderer_catalog.gd")
const Vignettes = preload("res://vignette_catalog.gd")
const ForgeSystem = preload("res://forge_system.gd")
const CampaignSystem = preload("res://campaign_system.gd")

var actor_ground_bounds := {}
func service_body_rect(texture: Texture2D) -> Rect2:
	var key := texture.resource_path
	if not actor_ground_bounds.has(key):
		var image := texture.get_image()
		actor_ground_bounds[key] = float(image.get_used_rect().end.y)/image.get_height() if image != null else 1.0
	return Avatar.fit_rect(profile,Rect2(-75,-150*float(actor_ground_bounds[key]),150,150))

func actor_texture() -> Texture2D:
	if not Avatar.is_wanderer(profile):
		var neutral := preload("res://phase4e_extracted_art.gd").neutral_body(str(profile.get("current_lootling_id","relic_beast")))
		if neutral!=null: return neutral
	return Avatar.texture(profile)

func actor_tint() -> Color:
	if not Avatar.is_wanderer(profile) and preload("res://phase4e_extracted_art.gd").neutral_body(str(profile.get("current_lootling_id","relic_beast")))!=null: return Color.WHITE
	return Avatar.tint(profile)
const AchievementManager = preload("res://achievement_manager.gd")
const MASCOT_TEXTURE = preload("res://art/sprites/relic_beast_base.png")
const HIDEOUT_BACKGROUND = preload("res://art/backgrounds/lootlings_hideout.png")
const SHOP_BACKGROUND = preload("res://art/backgrounds/salvager_shop.png")
const STASH_BACKGROUND = preload("res://art/backgrounds/stash_vault.png")
const SHRINE_BACKGROUND = preload("res://art/backgrounds/relic_shrine.png")
const HOME_GATE_ART = preload("res://art/production/phase4e/props/home_gate.png")
const HOME_SHRINE_ART = preload("res://art/production/phase4e/props/home_shrine.png")
const VANGUARD_WEAPON_TEXTURE = preload("res://art/sprites/weapons/vanguard_hammer.png")
const RANGER_WEAPON_TEXTURE = preload("res://art/sprites/weapons/ranger_bow.png")
const MAGE_WEAPON_TEXTURE = preload("res://art/sprites/weapons/mage_staff.png")
const ROGUE_WEAPON_TEXTURE = preload("res://art/sprites/weapons/rogue_daggers.png")

var current_screen := "home"
var current_inventory
var current_shop
var comparison_callable: Callable
var shards := 0
var power := 0
var gold := 0
var gold_upgrades := {"bedroll":0, "whetstone":0, "pouch":0}
var profile := {}
var entries: Array = []
var stash_filter := "ALL"
var filter_buttons := {}

var home_settings_content: Control
var private_return := false
var companion_collection_content: Control
var home_settings_summary: Label
var home_display_buttons: Dictionary = {}
var companion_buttons: Dictionary = {}
var companion_follow_button: Button
var companion_presenter := preload("res://companion_presentation.gd").new()
var hub_navigation := preload("res://hub_navigation.gd").new()
var home_content: Control
var stash_content: Control
var forge_content: Control
var forge_list: VBoxContainer
var forge_detail: RichTextLabel
var forge_confirm: Button
var forge_index := -1
var forge_armed := false
var forge_recipe := ""
var campaign_content: Control
var campaign_list: VBoxContainer
var campaign
var contracts
var contracts_content: Control
var contract_buttons: Array[Button] = []
var upgrade_content: Control
var coming_content: Control
var shop_content: Control
var achievement_content: Control
var lore_content: Control
var lore_detail: RichTextLabel
var lore_entries: Array = []
var lore_index := 0
var lore_filter := "ALL"
var lore_art: TextureRect
var lore_landscape_backing: ColorRect
var lore_heading: Label
var lore_filter_buttons: Array[Button] = []
const FieldNotes = preload("res://field_notes_catalog.gd")
var memory_content: Control
var memory_filter_buttons := {}
var memory_list: VBoxContainer
var memory_filter := "ALL"
var achievement_grid: GridContainer
var achievement_detail: RichTextLabel
var achievement_summary: Label
var achievement_filter_buttons: Array[Button] = []
var achievement_filter := "ALL"
var selected_achievement_id := ""
var achievement_manager
var visited_destinations := {}
var resident_facing: String = "left"
var resource_label: RichTextLabel
var loadout_label: RichTextLabel
var loadout_panel: Panel
var stash_title: Label
var stash_list: VBoxContainer
var stash_detail: RichTextLabel
var stash_detail_panel: Panel
var stash_detail_icon: Control
var stash_detail_name: Label
var stash_detail_identity: Label
var equipped_slot_buttons: Dictionary = {}
var stash_equip_button: Button
var stash_scrap_button: Button
var upgrade_summary: RichTextLabel
var upgrade_button: Button
var upgrade_panel: Panel
var gold_upgrade_buttons := {}
var coming_title: Label
var shop_scrap_label: RichTextLabel
var shop_offer_buttons: Array[Button] = []
var shop_cache_button: Button
var shop_gold_cache_button: Button
var shop_expansion_button: Button
var shop_reroll_button: Button
var shop_status: RichTextLabel
var shop_detail: RichTextLabel
var shop_buy_button: Button
var shop_detail_panel: Panel
var shop_status_panel: Panel
var selected_entry := -1
var selected_shop_offer := -1
var scene_time := 0.0
var transition_overlay: ColorRect
var presentation
var last_scrap := -1
var shrine_pulse := 0.0
var cache_pulse := 0.0
var cache_pulse_duration := 0.72
var cache_pulse_color := Color("#c99cff")
var ui_sparks: Array = []
var home_weapon: Control
var home_weapon_name: Label
var speech_portrait: TextureRect
var speech_role: Button
var speech_speaker := ""
var last_home_facts: Dictionary={}
var home_dialogue = preload("res://contextual_dialogue.gd").new()
var station_cycle := -1
var region_sheet: Panel
var region_detail: RichTextLabel
var region_art: TextureRect
var region_depart: Button
var phase4_heading: Label
var phase4_nav: Array[Button]=[]
var stash_scroll: ScrollContainer
var stash_opened_at := 0
var speech_panel: Panel
var speech_label: Label
var speech_timer := 4.5
var speech_visible_timer := 0.0
var dialogue
var queued_dialogue_context := ""
var queued_dialogue_priority := -1
var hideout_visits := 0
var life_rng := RandomNumberGenerator.new()
var life_event := ""
var life_event_clock := 6.0
var life_event_time := 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	dialogue = DialogueDirector.new()
	life_rng.randomize()
	build_home()
	build_home_settings()
	build_stash()
	build_forge()
	build_phase4()
	build_campaign()
	build_contracts()
	build_upgrades()
	build_shop()
	build_achievements()
	build_lore()
	build_memories()
	build_coming_soon()
	build_dialogue_overlay()
	build_transition_overlay()
	hub_navigation.finish_details()
	presentation.bind_buttons(self)
	set_process(true)

func configure(inventory, shop, shard_count: int, power_level: int, compare: Callable, gold_count: int = 0, profile_data: Dictionary = {}, gold_upgrade_data: Dictionary = {}, achievements = null) -> void:
	current_inventory = inventory
	current_shop = shop
	shards = shard_count
	power = power_level
	gold = gold_count
	profile = profile_data.duplicate(true)
	gold_upgrades = gold_upgrade_data.duplicate(true)
	comparison_callable = compare
	achievement_manager = achievements
	refresh_current_screen()

func show_home() -> void:
	if private_return:
		private_return=false;get_parent().show_personal_home();return
	if get_parent().audio_manager != null: get_parent().audio_manager.set_music("HIDEOUT")
	current_screen = "home"
	set_screen(home_content)
	refresh_home()
	loadout_panel.visible = false
	companion_presenter.react("return")
	hideout_visits += 1
	visit_destination("home")
	queue_redraw()

func show_stash() -> void:
	dismiss_dialogue()
	for child in stash_content.get_children():
		if child is Button and child.text.begins_with("‹"):child.text="‹ HOME" if private_return else "‹ HUB"
	current_screen = "stash"
	set_screen(stash_content)
	refresh_stash()
	visit_destination("stash")
	queue_redraw()

func show_upgrades() -> void:
	dismiss_dialogue()
	current_screen = "upgrades"
	set_screen(upgrade_content)
	refresh_upgrades()
	visit_destination("shrine")
	queue_redraw()

func show_shop() -> void:
	dismiss_dialogue()
	current_screen = "shop"
	set_screen(shop_content)
	refresh_shop()
	visit_destination("shop")
	queue_redraw()

func show_achievements() -> void:
	dismiss_dialogue()
	current_screen = "achievements"
	set_screen(achievement_content)
	refresh_achievements()
	visit_destination("archive")
	queue_redraw()

func visit_destination(id: String) -> void:
	if visited_destinations.has(id):
		return
	visited_destinations[id] = true
	destination_visited.emit(id)

func show_coming_soon(section_name: String) -> void:
	dismiss_dialogue()
	current_screen = "coming"
	coming_title.text = "%s\n\nCOMING SOON\n\nThis wing of the Hideout is still under construction." % section_name
	set_screen(coming_content)
	queue_redraw()

func refresh_current_screen() -> void:
	match current_screen:
		"stash": refresh_stash()
		"upgrades": refresh_upgrades()
		"shop": refresh_shop()
		"achievements": refresh_achievements()
		"contracts": refresh_contracts()
		"home_settings": refresh_home_settings()
		"workshop": refresh_phase4()
		_: refresh_home()

func set_screen(active: Control) -> void:
	# A screen transition must never leave a resident bubble over unrelated UI.
	dismiss_dialogue()
	if region_sheet!=null:region_sheet.visible=false
	if stash_detail_panel!=null:stash_detail_panel.visible=false
	if presentation != null: presentation.cancel_chest_showcase()
	var screens := [companion_collection_content,home_settings_content,phase4_content,home_content, stash_content, forge_content, campaign_content, contracts_content, upgrade_content, shop_content, achievement_content, lore_content, memory_content, coming_content]
	presentation.switch_screen(screens, active, 0.24)
	ui_event.emit("menu_transition")

func build_home() -> void:
	home_content=Control.new();home_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(home_content)
	hub_navigation.build(self)

func build_stash() -> void:
	stash_content = Control.new()
	stash_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stash_content.visible = false
	add_child(stash_content)
	var back := make_button(stash_content, "‹ HUB", Rect2(20, 20, 122, 48), Color("#202d4d"), Color("#7f94bc"), 16)
	back.pressed.connect(show_home)
	stash_title = make_label(stash_content, "STASH", 28, Rect2(150, 23, 310, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	var filters := ["ALL", "WEAPON", "ARMOUR", "CHARM", "RUNE"]
	for index in range(filters.size()):
		var filter_name: String = filters[index]
		var filter_button := make_button(stash_content, filter_name, Rect2(20 + index * 89, 146, 84, 48), Color("#1c2948"), Color("#6f89b5"), 12)
		filter_button.pressed.connect(set_stash_filter.bind(filter_name))
		filter_buttons[filter_name] = filter_button
	for index in range(4):
		var slot: String = ["Weapon", "Armour", "Relic", "Rune"][index]
		var slot_button := make_button(stash_content, "", Rect2(20 + index * 112, 76, 104, 60), Color("#172442"), Color("#7194c4"), 13)
		slot_button.disabled=true
		slot_button.flat=true
		slot_button.mouse_filter=Control.MOUSE_FILTER_IGNORE
		slot_button.tooltip_text="Currently equipped "+ItemCatalog.display_slot(slot)
		var slot_art := ItemIcon.new()
		slot_art.name = "SlotArt"
		slot_art.position = Vector2(34, 2)
		slot_art.size = Vector2(36, 36)
		slot_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot_button.add_child(slot_art)
		make_label(slot_button, ItemCatalog.display_slot(slot), 13, Rect2(4, 39, 96, 20), HORIZONTAL_ALIGNMENT_CENTER, Color("#dbe7ff"))
		equipped_slot_buttons[slot] = slot_button
	var scroll_panel := make_panel(stash_content, Rect2(20, 208, 440, 593), Color("#0b1229d6"), Color("#7194c4"))
	LootlingsUI.apply_material(scroll_panel, "leather", 16)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(10, 12)
	scroll.size = Vector2(420, 569)
	stash_scroll=scroll
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_panel.add_child(scroll)
	stash_list = VBoxContainer.new()
	stash_list.custom_minimum_size = Vector2(402, 0)
	stash_list.add_theme_constant_override("separation", 8)
	scroll.add_child(stash_list)
	stash_detail_panel = make_panel(stash_content, Rect2(20, 477, 440, 186), Color("#0d1530dc"), Color("#c99a4e"))
	LootlingsUI.apply_material(stash_detail_panel, "leather", 16)
	stash_detail_icon = ItemIcon.new()
	stash_detail_icon.position = Vector2(18, 12)
	stash_detail_icon.size = Vector2(54, 54)
	stash_detail_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stash_detail_panel.add_child(stash_detail_icon)
	stash_detail_name = make_label(stash_detail_panel, "", 20, Rect2(110, 12, 312, 50), HORIZONTAL_ALIGNMENT_LEFT, Color("#e5edff"))
	stash_detail_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stash_detail_identity = make_label(stash_detail_panel, "", 13, Rect2(110, 66, 312, 22), HORIZONTAL_ALIGNMENT_LEFT, Color("#dbe7ff"))
	stash_detail = RichTextLabel.new()
	stash_detail.position = Vector2(18, 96)
	stash_detail.size = Vector2(404, 78)
	stash_detail.bbcode_enabled = true
	stash_detail.scroll_active = true
	stash_detail.add_theme_font_size_override("normal_font_size", 14)
	stash_detail.add_theme_color_override("default_color", Color("#e5edff"))
	stash_detail_panel.add_child(stash_detail)
	stash_equip_button = make_button(stash_content, "EQUIP", Rect2(20, 666, 210, 54), Color("#285c4c"), Color("#69e6b0"), 18)
	stash_equip_button.pressed.connect(request_stash_equip)
	stash_scrap_button = make_button(stash_content, "SALVAGE", Rect2(250, 666, 210, 54), Color("#5a3828"), Color("#ffbd69"), 18)
	stash_scrap_button.pressed.connect(request_stash_scrap)
	make_button(stash_detail_panel,"×",Rect2(386,2,48,48),Color("#172442"),Color("#7087ae"),20).pressed.connect(close_stash_detail)
	close_stash_detail()

func close_stash_detail() -> void:
	stash_detail_panel.visible=false; stash_equip_button.visible=false; stash_scrap_button.visible=false
	if stash_scroll!=null: stash_scroll.size.y=569
	selected_entry = -1
	if stash_list != null:
		for child in stash_list.get_children():
			if child is Button: LootlingsUI.apply_selection(child,false)

func build_forge() -> void:
	forge_content = Control.new()
	forge_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	forge_content.visible = false
	add_child(forge_content)
	make_button(forge_content, "‹ HUB", Rect2(20, 20, 122, 48), Color("#202d4d"), Color("#7f94bc"), 16).pressed.connect(show_home)
	make_label(forge_content, "WEAPON FORGE", 25, Rect2(150, 23, 310, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	make_button(forge_content,"BLUEPRINT FORGE",Rect2(24,70,432,48),Color("#172442"),Color("#7087ae"),14).pressed.connect(func(): show_phase4("blueprints"))
	make_label(forge_content, "Two evolutions • new weapon behaviour\n+4% damage each • retains rarity and affixes", 14, Rect2(28, 126, 424, 48), HORIZONTAL_ALIGNMENT_CENTER, Color("#dbe7ff"))
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(28, 180)
	scroll.size = Vector2(424, 318)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	forge_content.add_child(scroll)
	forge_list = VBoxContainer.new()
	forge_list.custom_minimum_size.x = 398
	forge_list.add_theme_constant_override("separation", 10)
	scroll.add_child(forge_list)
	var forge_plate:=make_panel(forge_content, Rect2(28, 516, 424, 126), Color("#0b1229ec"), Color("#b39466"))
	forge_plate.add_theme_stylebox_override("panel",preload("res://station_presentation.gd").metal())
	forge_detail = LootlingsUI.rich_label(forge_content, Rect2(48, 524, 384, 112), 14, Color("#ffe6ad"))
	forge_detail.scroll_active=true
	forge_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	forge_confirm = make_button(forge_content, "EVOLVE", Rect2(55, 654, 370, 64), Color("#493052"), Color("#e2b563"), 19)
	forge_confirm.pressed.connect(func():
		var recipe:=forge_recipe;var index:=forge_index
		var owned_item:Dictionary=current_inventory.equipped_item("Weapon") if index<0 else current_inventory.stash[index]
		var heading:String="Make %s?" % str(ForgeSystem.WeaponCatalog.starter(recipe).name) if not recipe.is_empty() else "Evolve %s?" % str(owned_item.get("name","weapon"))
		get_parent().touch_ux.request(heading,forge_detail.text+"\nThe displayed materials are spent permanently.",func():
			if recipe.is_empty():forge_requested.emit(index)
			else:forge_craft_requested.emit(recipe)
			refresh_forge())
	)

func build_phase4() -> void:
	phase4_content = Control.new()
	phase4_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	phase4_content.visible = false; add_child(phase4_content)
	make_button(phase4_content,"‹ HUB",Rect2(20,20,126,48),Color("#172442"),Color("#7087ae"),14).pressed.connect(show_home)
	phase4_heading=make_label(phase4_content,"BLUEPRINT FORGE",25,Rect2(150,23,310,42),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe178"))
	for index in range(2):
		var nav:=make_button(phase4_content,"",Rect2(20+index*224,86,216,48),Color("#172442"),Color("#7087ae"),14); phase4_nav.append(nav)
		nav.pressed.connect(func():
			if phase4_mode=="blueprints": show_forge() if index==0 else show_phase4("blueprints")
			elif phase4_mode=="contracts": show_contracts() if index==0 else show_phase4("contracts")
			else: show_achievements() if index==0 else show_lore()
		)
	var scroll := ScrollContainer.new(); scroll.position = Vector2(24,150); scroll.size = Vector2(432,346)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	phase4_content.add_child(scroll)
	phase4_list = VBoxContainer.new(); phase4_list.custom_minimum_size.x = 410; phase4_list.add_theme_constant_override("separation",10); scroll.add_child(phase4_list)
	var detail_panel := make_panel(phase4_content,Rect2(24,510,432,222),Color("#0b1229ec"),Color("#7087ae"))
	phase4_detail_panel=detail_panel
	phase4_detail = LootlingsUI.rich_label(detail_panel,Rect2(16,12,400,198),15,Color("#e7edff"))
	phase4_detail.scroll_active = true
	phase4_action = make_button(phase4_content,"SELECT A FIND",Rect2(24,754,432,56),Color("#493052"),Color("#e2b563"),16)
	phase4_action.position.x=156; phase4_action.size.x=300
	track_button=make_button(phase4_content,"TRACK",Rect2(24,754,120,56),Color("#172442"),Color("#78e4ff"),14)
	track_button.pressed.connect(func():
		if not phase4_selected.is_empty(): tracked_requested.emit(phase4_selected)
	)
	phase4_action.set_meta("ui_intent","primary"); apply_button_style(phase4_action,Color("#493052"),Color("#e2b563"))
	phase4_action.pressed.connect(func():
		if phase4_selected.is_empty() or Time.get_ticks_msec()-phase4_selected_msec < 180: return
		var selected := phase4_selected; phase4_selected = ""; phase4_action.disabled = true
		if phase4_mode == "blueprints": blueprint_requested.emit(selected)
		elif phase4_mode == "contracts": farm_contract_requested.emit(selected)
	)

func show_phase4(mode: String) -> void:
	dismiss_dialogue(); current_screen = "workshop"; phase4_mode = mode
	set_screen(phase4_content)
	hub_navigation.archive_talk.visible=mode=="archive"
	phase4_heading.text={"blueprints":"BLUEPRINT FORGE","contracts":"CONTRACT BOARD","archive":"ILEX’S ARCHIVE"}.get(mode,"ARCHIVE")
	phase4_nav[0].text={"blueprints":"WEAPON EVOLUTION","contracts":"LOCAL CONTRACTS","archive":"TROPHIES"}.get(mode,"")
	phase4_nav[1].text={"blueprints":"BLUEPRINTS","contracts":"REGIONAL BOUNTIES","archive":"FIELD NOTES"}.get(mode,"")
	refresh_phase4()

func refresh_phase4() -> void:
	if expedition_progress == null: return
	var delivery_notice: String=phase4_message
	phase4_action.visible=true; track_button.visible=true
	phase4_selected = str(phase4_selections.get(phase4_mode,"")); track_button.disabled=true; phase4_action.disabled = true; phase4_action.text = "SELECT A FIND"
	phase4_detail_panel.add_theme_stylebox_override("panel",preload("res://station_presentation.gd").paper() if phase4_mode=="archive" else preload("res://station_presentation.gd").metal())
	phase4_detail.add_theme_color_override("default_color",Color("#382e32") if phase4_mode=="archive" else Color("#e7edff"))
	for child in phase4_list.get_children(): phase4_list.remove_child(child); child.queue_free()
	phase4_detail.text = phase4_message if not phase4_message.is_empty() else "Relic Rank %d\nRegional materials shape named gear. Boss seals bind a Rare blueprint craft.\nMastery comes from use; no daily clock." % expedition_progress.rank()
	phase4_message = ""
	if phase4_mode == "archive":
		phase4_detail.text = "Select a record to inspect. Unknown finds keep their names until you discover them."
		for category in ["Mastery","Characters","Named gear","Field discoveries","Blueprints","Relic Siege"]:
			var button := make_button(phase4_list,"",Rect2(0,0,410,56),Color("#172442"),Color("#7087ae"),16)
			button.set_meta("paper_selection",true)
			button.set_meta("ui_sound","archive_page")
			preload("res://station_presentation.gd").paper_button(button)
			var icon_name: String={"Mastery":"core","Characters":"res://art/sprites/relic_beast_base.png","Named gear":"res://art/production/phase4e/items/armour_inventory_v1/mossguard_harness.png","Field discoveries":"res://art/sprites/items/beta/vault_scroll.png","Blueprints":"gear_weapon","Relic Siege":"gear_rune"}[category]
			# Use verified canonical icons, with all decorative children ignoring touch.
			if icon_name=="core": icon_name="currency_star_shard"
			if icon_name=="gear_weapon": icon_name="res://art/sprites/weapons/vanguard_hammer.png"
			LootlingsUI.add_icon(button,Rect2(12,6,44,44),icon_name)
			make_label(button,category,17,Rect2(70,6,320,44),HORIZONTAL_ALIGNMENT_LEFT,Color("#382e32")).mouse_filter=Control.MOUSE_FILTER_IGNORE
			button.custom_minimum_size = Vector2(410,56)
			button.set_meta("selection_id",category)
			button.pressed.connect(func():
				phase4_selections[phase4_mode]=category
				refresh_selection_styles(phase4_list,category)
				if category=="Field discoveries": last_home_facts.event="archive_discovery"
				phase4_detail.text = expedition_progress.collection_text(category)
				if category == "Relic Siege" and endgame_progress != null:
					phase4_detail.text="Highest round %d • best score %d\nRootglass Vault clears %d\n%s\nRound 10: extraction. Round 20+: Crownroot chase.\nOwned gear, mastery and discoveries survive defeat." % [endgame_progress.data.highest,endgame_progress.data.best_score,endgame_progress.data.dungeon_clears,endgame_progress.target_text()]
					var owned_red: bool=current_inventory!=null and (current_inventory.equipped_item("Weapon").get("id","")=="gravebloom_staff" or current_inventory.stash.any(func(item): return item.id=="gravebloom_staff"))
					phase4_detail.text+="\nGravebloom Staff: "+("OWNED" if owned_red else "TARGET AVAILABLE")
				if category == "Characters":
					phase4_detail.text = "LOOTLINGS\n\n"
					for id in LootlingCatalog.ENTRIES:
						var actor: Dictionary=LootlingCatalog.ENTRIES[id]
						phase4_detail.text += "%s\n%s\n%s\n\n" % [actor.display_name,actor.personality,actor.lore]
					phase4_detail.text += "WANDERERS\n\n"
					for id in Phase4.HUMANS:
						var actor: Dictionary = Phase4.HUMANS[id]
						phase4_detail.text += "%s • %s\n%s\nAffinity: %s. Every weapon is welcome.\nMastery: %s\n\n" % [str(id).capitalize().replace("_"," "),actor.role,actor.bio,actor.affinity,actor.mastery]
				elif category in ["Named gear","Blueprints"]:
					phase4_detail.text = ""
					for source in Phase4.ITEMS:
						var found: bool = expedition_progress.data.seen.has("item:"+str(source.id))
						var pieces: int = int(expedition_progress.data.fragments.get(source.id,0))
						phase4_detail.text += "%s • %s\n" % [str(source.name) if found or pieces > 0 else "Undiscovered gear", "collected" if found else "blueprint %d/3" % pieces]
			)
		phase4_action.visible=false; track_button.visible=false; restore_phase4_selection(); return
	var entries: Array = Phase4.ITEMS if phase4_mode == "blueprints" else CampaignSystem.ORDER
	for entry in entries:
		var id: String = str(entry.id) if entry is Dictionary else str(entry)
		var region: String = Phase4.home_for(id) if phase4_mode == "blueprints" else id
		if phase4_mode == "contracts" and (campaign == null or not campaign.available(region)): continue
		var pieces: int = int(expedition_progress.data.fragments.get(id,0))
		var text: String = "%s  •  blueprint %d/3\n%s • %s" % [entry.name,pieces,CampaignSystem.title(region),Phase4.FARMS[region].material] if phase4_mode == "blueprints" else "%s\n%s" % [CampaignSystem.title(region),expedition_progress.job(region).name]
		var button := make_button(phase4_list,"",Rect2(0,0,410,88),Color("#172442"),Color("#7087ae"),14)
		button.custom_minimum_size = Vector2(410,88); button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; button.clip_text = true
		if phase4_mode=="blueprints":
			var item: Dictionary=entry.duplicate(true); item.rarity="RARE"
			var image:=ItemIcon.new(); image.position=Vector2(10,10); image.size=Vector2(68,68); image.mouse_filter=Control.MOUSE_FILTER_IGNORE
			image.name="BlueprintArt"; image.configure(item); button.add_child(image)
		else:
			var image:=LootlingsUI.add_icon(button,Rect2(10,10,68,68),CampaignSystem.zone_for(region,1).background.resource_path)
			image.name="RegionArt"; image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED; image.clip_contents=true
		var caption:=make_label(button,text,14,Rect2(90,8,306,72),HORIZONTAL_ALIGNMENT_LEFT,Color("#e7edff"))
		caption.name="RecordCaption"; caption.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; caption.mouse_filter=Control.MOUSE_FILTER_IGNORE
		button.set_meta("selection_id",id)
		button.set_meta("gesture_release_owned",true)
		button.pressed.connect(func():
			phase4_selections[phase4_mode]=id
			refresh_selection_styles(phase4_list,id)
			phase4_selected = id; track_button.disabled=phase4_mode!="blueprints"; phase4_selected_msec = Time.get_ticks_msec()
			if phase4_mode == "blueprints":
				phase4_detail.text = "%s\n%s\n\nSource: %s bosses/minibosses; regional loot also drops directly.\nForge: 12 %s + one boss seal.\nOwned: %d material / %d seals. Recipe fragments %d/3.\nRare gear • keeps its named behaviour." % [entry.name,entry.desc,CampaignSystem.title(region),Phase4.FARMS[region].material,int(expedition_progress.data.materials.get(region,0)),int(expedition_progress.data.boss_parts.get(region,0)),pieces]
				phase4_action.text = "CRAFT RARE GEAR"
				if pieces < 3: phase4_action.text="NEED %d FRAGMENTS" % (3-pieces)
				elif int(expedition_progress.data.materials.get(region,0)) < 12: phase4_action.text="NEED %d MATERIAL" % (12-int(expedition_progress.data.materials.get(region,0)))
				elif int(expedition_progress.data.boss_parts.get(region,0)) < 1: phase4_action.text="NEED A BOSS SEAL"
				elif current_inventory.stash.size() >= current_inventory.stash_capacity: phase4_action.text="STASH FULL"
				phase4_action.disabled = pieces < 3 or int(expedition_progress.data.materials.get(region,0)) < 12 or int(expedition_progress.data.boss_parts.get(region,0)) < 1 or current_inventory.stash.size() >= current_inventory.stash_capacity
			else:
				var current: Dictionary = expedition_progress.job(region)
				phase4_detail.text = "%s\n%s • %d / %d\nReturn anytime. No expiry.\nReward: 6 %s + one local blueprint fragment." % [CampaignSystem.title(region),current.name,current.progress,current.target,Phase4.FARMS[region].material]
				phase4_action.text = "CLAIM BOUNTY" if current.progress >= current.target else "%d MORE TO CLAIM" % (current.target-current.progress); phase4_action.disabled = current.progress < current.target
		)

	restore_phase4_selection()
	if not delivery_notice.is_empty():phase4_detail.text=delivery_notice+"\n\n"+phase4_detail.text

func build_campaign() -> void:
	campaign_content=Control.new(); campaign_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); campaign_content.visible=false; add_child(campaign_content)
	make_button(campaign_content,"‹ HUB",Rect2(20,20,122,48),Color("#172442"),Color("#7087ae"),14).pressed.connect(show_home)
	make_label(campaign_content,"EXPEDITIONS",24,Rect2(150,23,310,42),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe178"))
	make_button(campaign_content,"REGIONS",Rect2(20,85,140,48),Color("#293a46"),Color("#e2b563"),14).pressed.connect(show_campaign)
	dungeon_start_button=make_button(campaign_content,"RELIC SIEGE",Rect2(170,85,140,48),Color("#172442"),Color("#7087ae"),13); dungeon_start_button.pressed.connect(func(): dungeon_requested.emit())
	make_button(campaign_content,"DUNGEONS",Rect2(320,85,140,48),Color("#172442"),Color("#7087ae"),13).pressed.connect(func(): get_parent().retention.show_modes("dungeons"))
	for index in range(3):
		var button:=make_button(campaign_content,Phase4.TIERS[index].name,Rect2(24+index*146,146,140,48),Color("#172442"),Color("#d4ad65"),14); tier_buttons.append(button)
		button.pressed.connect(func(): selected_tier=index; tier_requested.emit(index); show_campaign())
	var scroll:=ScrollContainer.new(); scroll.position=Vector2(24,212); scroll.size=Vector2(432,522); scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED; campaign_content.add_child(scroll)
	campaign_list=VBoxContainer.new(); campaign_list.custom_minimum_size.x=408; campaign_list.add_theme_constant_override("separation",10); scroll.add_child(campaign_list)
	var patrol:=make_button(campaign_content,"PATROLS: SOLO",Rect2(24,761,432,48),Color("#172442"),Color("#7087ae"),13)
	patrol.pressed.connect(func(): group_patrols_enabled=not group_patrols_enabled; patrol.text="PATROLS: GROUPS" if group_patrols_enabled else "PATROLS: SOLO"; group_patrols_changed.emit(group_patrols_enabled))
	var region_veil:=ColorRect.new(); region_veil.name="RegionVeil"; region_veil.color=Color("#070c1cba"); region_veil.size=Vector2(480,854); region_veil.mouse_filter=Control.MOUSE_FILTER_STOP; region_veil.z_index=19; region_veil.visible=false; campaign_content.add_child(region_veil)
	region_sheet=make_panel(campaign_content,Rect2(20,432,440,393),Color("#10182bfa"),Color("#d8bd7b")); region_sheet.z_index=20; region_sheet.visible=false
	region_sheet.visibility_changed.connect(func():region_veil.visible=region_sheet.visible)
	region_art=LootlingsUI.add_icon(region_sheet,Rect2(22,62,396,104),"res://art/backgrounds/treasure_ruins_arena.png")
	region_art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED; region_art.clip_contents=true
	region_detail=LootlingsUI.rich_label(region_sheet,Rect2(22,179,396,122),17,Color("#e7edff")); region_detail.scroll_active=true
	region_detail.mouse_filter=Control.MOUSE_FILTER_STOP
	make_button(region_sheet,"×",Rect2(382,6,48,48),Color("#172442"),Color("#7087ae"),20).pressed.connect(func(): region_sheet.visible=false)
	region_depart=make_button(region_sheet,"DEPART",Rect2(22,316,396,56),Color("#285c4c"),Color("#69e6b0"),18)

func build_contracts() -> void:
	contracts_content = Control.new()
	contracts_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	contracts_content.visible = false
	add_child(contracts_content)
	make_button(contracts_content, "‹ EXPEDITIONS", Rect2(20, 20, 158, 48), Color("#202d4d"), Color("#7f94bc"), 13).pressed.connect(show_campaign)
	make_label(contracts_content, "CONTRACTS", 26, Rect2(220, 23, 240, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	LootlingsUI.add_icon(contracts_content,Rect2(180,26,30,38),"res://art/production/phase4e/props/contract_banner.png")
	make_button(contracts_content,"REGIONAL BOUNTIES",Rect2(24,70,432,48),Color("#172442"),Color("#7087ae"),14).pressed.connect(func(): show_phase4("contracts"))
	make_label(contracts_content, "Three local jobs • progress through play\nClaim a reward to receive a fresh job", 14, Rect2(24, 126, 432, 52), HORIZONTAL_ALIGNMENT_CENTER, Color("#dbe7ff"))
	for slot in range(3):
		var button := make_button(contracts_content, "", Rect2(30, 190 + slot * 148, 420, 126), Color("#172442"), Color("#d4ad65"), 16)
		LootlingsUI.apply_rarity_card(button,Color("#d4ad65"))
		LootlingsUI.add_icon(button,Rect2(18,48,44,44),"currency_gold")
		make_label(button,"",18,Rect2(80,12,320,28),HORIZONTAL_ALIGNMENT_LEFT,Color("#ffe6ad")).name="JobName"
		make_label(button,"",14,Rect2(80,43,320,26),HORIZONTAL_ALIGNMENT_LEFT,Color("#dbe7ff")).name="Requirement"
		make_label(button,"",15,Rect2(80,78,320,32),HORIZONTAL_ALIGNMENT_LEFT,Color("#b8d3df")).name="Reward"
		button.pressed.connect(func(): contract_claim_requested.emit(slot))
		contract_buttons.append(button)

func show_contracts() -> void:
	dismiss_dialogue()
	current_screen = "contracts"
	set_screen(contracts_content)
	refresh_contracts()

func refresh_contracts() -> void:
	if contracts == null: return
	for slot in range(3):
		var item: Dictionary = contracts.offer(slot)
		var ready := int(item.progress) >= int(item.target)
		var button:Button=contract_buttons[slot]
		var goals:Dictionary={"kill":"Defeat enemies", "miniboss":"Defeat a miniboss", "chest":"Open chests", "boss":"Defeat a boss", "win":"Return victorious"}
		button.text=""
		button.get_node("JobName").text=str(item.name)
		button.get_node("Requirement").text="%s • %d / %d" % [goals.get(str(item.event),"Explore"),item.progress,item.target]
		button.get_node("Reward").text="CLAIM %d LOOTCOINS  ›" % item.gold if ready else "%d Lootcoins reward • keep adventuring" % item.gold
		button.get_node("Reward").modulate=Color("#fff0a7") if ready else Color.WHITE
		button.disabled=not ready
		button.tooltip_text="Claim your reward" if ready else "%s to finish this job" % goals.get(str(item.event),"Explore")
		LootlingsUI.apply_rarity_card(button,Color("#ffe178") if ready else Color("#738ba1"))

func show_campaign() -> void:
	selected_tier=clampi(int(get_parent().expedition_tier),0,Phase4.TIERS.size()-1)
	if selected_region_id.is_empty():selected_region_id=get_parent().campaign_id
	for index in range(tier_buttons.size()):
		var rank_value: int = expedition_progress.rank() if expedition_progress != null else 1
		tier_buttons[index].disabled = rank_value < int(Phase4.TIERS[index].rank)
		tier_buttons[index].text = str(Phase4.TIERS[index].name)+( "\nRank %d" % int(Phase4.TIERS[index].rank) if tier_buttons[index].disabled else "")
		tier_buttons[index].tooltip_text = str(Phase4.TIERS[index].text)+" • Relic Rank %d" % int(Phase4.TIERS[index].rank)
		apply_display_button_style(tier_buttons[index],Color("#d4ad65"),selected_tier == index)
	if dungeon_start_button != null:
		dungeon_start_button.disabled = campaign == null
		dungeon_start_button.text = "RELIC SIEGE"
	dismiss_dialogue()
	current_screen = "campaign"
	set_screen(campaign_content)
	region_sheet.visible=false
	for child in campaign_list.get_children():
		campaign_list.remove_child(child)
		child.queue_free()
	for id in CampaignSystem.ORDER:
		var available: bool = campaign != null and campaign.available(id)
		var tuning: Array = CampaignSystem.TRAITS.get(id, [])
		var farm: Dictionary = Phase4.FARMS[id]
		var target_name: String = ItemCatalog.definition(str(farm.items[0])).name
		var tracked_here := false
		if endgame_progress != null and not str(endgame_progress.data.tracked).is_empty():
			var tracked: String=endgame_progress.data.tracked
			tracked_here=Phase4.home_for(tracked)==id or (tracked=="gravebloom_staff" and id=="mossglass_wilds")
			if tracked_here: target_name=ItemCatalog.definition(tracked).name
		var detail := "Farm %s • hunt %s\n%s" % [farm.material,target_name,Phase4.TIERS[selected_tier].text]
		var status := "RETURN TO FARM" if campaign != null and id in campaign.completed else "EXPEDITION" if available else "LOCKED"
		if not available:
			var previous_index:int=CampaignSystem.ORDER.find(id)-1
			status="Clear %s to unlock" % CampaignSystem.title(CampaignSystem.ORDER[maxi(0,previous_index)])
		if tracked_here: status="★ TRACKED SOURCE • "+status
		var button := make_button(campaign_list, "", Rect2(0, 0, 408, 104), Color("#172442"), Color("#d4ad65") if available else Color("#697085"), 14)
		button.custom_minimum_size = Vector2(408, 104)
		var preview:=TextureRect.new(); preview.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; preview.texture=CampaignSystem.zone_for(id,1).background; preview.position=Vector2(10,10); preview.size=Vector2(66,68); preview.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED; preview.mouse_filter=Control.MOUSE_FILTER_IGNORE; preview.clip_contents=true; button.add_child(preview)
		make_label(button,CampaignSystem.title(id),14,Rect2(88,13,302,25),HORIZONTAL_ALIGNMENT_LEFT,Color("#ffe6a0") if available else Color("#91a3c2")).mouse_filter=Control.MOUSE_FILTER_IGNORE
		make_label(button,"%s • %s" % [farm.material,"★ TRACKED" if tracked_here else status],12,Rect2(88,39,302,36),HORIZONTAL_ALIGNMENT_LEFT,Color("#bacbe0")).mouse_filter=Control.MOUSE_FILTER_IGNORE
		var loot_hint: String=str(preload("res://world_content_catalog.gd").FUTURE_ZONES.get(id,{}).get("loot","steel / relics / regional blueprints"))
		make_label(button,loot_hint,12,Rect2(88,74,302,23),HORIZONTAL_ALIGNMENT_LEFT,Color("#a6d2c3")).mouse_filter=Control.MOUSE_FILTER_IGNORE
		button.set_meta("gesture_release_owned",true)
		button.set_meta("selection_id",id)
		apply_display_button_style(button,Color("#d4ad65") if available else Color("#697085"),id==selected_region_id)
		button.add_theme_stylebox_override("disabled", button.get_theme_stylebox("normal"))
		button.add_theme_color_override("font_disabled_color", Color("#91a3c2"))
		button.disabled = false
		button.pressed.connect(func():
			selected_region_id=id
			refresh_selection_styles(campaign_list,id)
			region_depart.disabled=not available
			region_depart.text="DEPART" if available else "CLEAR THE PREVIOUS REGION"
			region_sheet.visible=true; region_art.texture=CampaignSystem.zone_for(id,1).background; region_detail.text="[font_size=23]%s[/font_size]\n\n%s\n\n%s\n%s" % [CampaignSystem.title(id),WorldStory.region_line(id,0),detail,status]
			for callback in region_depart.pressed.get_connections(): region_depart.pressed.disconnect(callback.callable)
			region_depart.pressed.connect(func(): region_sheet.visible=false; campaign_requested.emit(id))
		)

func show_forge() -> void:
	dismiss_dialogue()
	current_screen = "forge"
	set_screen(forge_content)
	refresh_forge()

func refresh_forge() -> void:
	for child in forge_list.get_children():
		forge_list.remove_child(child)
		child.queue_free()
	if current_inventory == null:
		return
	add_forge_entry(current_inventory.equipped_item("Weapon"), -1)
	for index in range(current_inventory.stash.size()):
		var item: Dictionary = current_inventory.stash[index]
		if item.get("slot", "") == "Weapon":
			add_forge_entry(item, index)
	for weapon_type in ForgeSystem.WeaponCatalog.STARTERS:
		var data := ForgeSystem.WeaponCatalog.definition(weapon_type)
		var button := make_forge_card(ForgeSystem.WeaponCatalog.starter(weapon_type), "MAKE %s\n150 Lootcoins + 6 Scrap" % str(data.name).to_upper(), Color("#8bbedb"))
		button.set_meta("selection_id","recipe:"+str(weapon_type))
		button.pressed.connect(select_forge_recipe.bind(weapon_type))
	select_forge_weapon(-1)

func select_forge_recipe(weapon_type: String) -> void:
	forge_recipe = weapon_type
	refresh_selection_styles(forge_list,"recipe:"+weapon_type)
	forge_armed = false
	var item := ForgeSystem.WeaponCatalog.starter(weapon_type)
	var description: String = str(item.desc).replace(" TEMP ART: shared class weapon.", "")
	forge_detail.text = "[center]" + ("%s\n150 Lootcoins + 6 Scrap\n%s\nYou have %d Lootcoins / %d Scrap" % [item.name, description, gold, current_inventory.scrap]) + "[/center]"
	forge_detail.add_theme_font_size_override("normal_font_size", 14)
	forge_confirm.text = "MAKE • STORE IN STASH"
	forge_confirm.disabled = gold < 150 or current_inventory.scrap < 6 or current_inventory.stash.size() >= current_inventory.stash_capacity
	if current_inventory.stash.size() >= current_inventory.stash_capacity:forge_confirm.text="STASH FULL • MAKE ROOM"
	elif gold<150:forge_confirm.text="NEED %d MORE LOOTCOINS" % (150-gold)
	elif current_inventory.scrap<6:forge_confirm.text="NEED %d MORE SCRAP" % (6-current_inventory.scrap)

func add_forge_entry(item: Dictionary, index: int) -> void:
	var label := "%s • %s\n%s / 3  •  %s" % ["EQUIPPED" if index == -1 else "STASH", item.get("name", "Weapon"), ForgeSystem.stage(item) + 1, item.get("rarity", "COMMON")]
	var button := make_forge_card(item, label, ItemCatalog.rarity_color(item.get("rarity", "COMMON")))
	button.set_meta("selection_id","owned:"+str(index))
	button.pressed.connect(select_forge_weapon.bind(index))

func make_forge_card(item: Dictionary, text: String, accent: Color) -> Button:
	var button := make_button(forge_list, "", Rect2(0, 0, 398, 84), Color("#172442"), accent, 15)
	button.custom_minimum_size = Vector2(398, 84)
	button.set_meta("gesture_release_owned",true)
	for state in ["normal","hover","pressed","focus"]:
		var plate:=preload("res://station_presentation.gd").metal(); plate.border_color=accent.darkened(.25)
		if state in ["hover","focus"]: plate.bg_color=Color("#2e3e40")
		button.add_theme_stylebox_override(state,plate)
	button.tooltip_text = text
	var visual := ItemIcon.new()
	visual.position = Vector2(14, 16)
	visual.size = Vector2(52, 52)
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(visual)
	visual.configure(item)
	var caption := make_label(button, text, 15, Rect2(80, 10, 276, 64), HORIZONTAL_ALIGNMENT_LEFT, Color("#e5ecff"))
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return button

func select_forge_weapon(index: int) -> void:
	forge_recipe = ""
	forge_detail.add_theme_font_size_override("normal_font_size", 14)
	forge_index = index
	refresh_selection_styles(forge_list,"owned:"+str(index))
	forge_armed = false
	var item: Dictionary = current_inventory.equipped_item("Weapon") if index == -1 else current_inventory.stash[index]
	var next := ForgeSystem.offer(item)
	forge_confirm.text = "EVOLVE"
	forge_confirm.disabled = next.is_empty() or gold < int(next.get("gold", 0)) or current_inventory.scrap < int(next.get("scrap", 0))
	if next.is_empty():
		forge_confirm.text="FULLY EVOLVED" if ForgeSystem.stage(item)==2 else "NO EVOLUTION AVAILABLE"
		forge_detail.text = "[center]" + ("%s\n%s\n%s" % [item.get("name", "Weapon"), "Fully evolved" if ForgeSystem.stage(item) == 2 else "No evolution line for this weapon yet", ForgeSystem.WeaponCatalog.evolution_text(str(item.get("weapon_type", "")), ForgeSystem.stage(item))]) + "[/center]"
	else:
		if gold<int(next.gold):forge_confirm.text="NEED %d MORE LOOTCOINS" % (int(next.gold)-gold)
		elif current_inventory.scrap<int(next.scrap):forge_confirm.text="NEED %d MORE SCRAP" % (int(next.scrap)-current_inventory.scrap)
		forge_detail.text = "[center]" + ("%s\n%d Lootcoins + %d Scrap\n+4%% damage • permanent\n%s\nYou have %d Lootcoins / %d Scrap" % [next.name, next.gold, next.scrap, next.behaviour, gold, current_inventory.scrap]) + "[/center]"

func build_upgrades() -> void:
	upgrade_content = Control.new()
	upgrade_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	upgrade_content.visible = false
	add_child(upgrade_content)
	var back := make_button(upgrade_content, "‹ HUB", Rect2(20, 20, 122, 48), Color("#202d4d"), Color("#7f94bc"), 16)
	back.pressed.connect(show_home)
	make_label(upgrade_content, "RELIC TRAINING", 29, Rect2(145, 23, 315, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	upgrade_panel = make_panel(upgrade_content, Rect2(48, 354, 384, 202), Color("#101634ce"), Color("#b78cff"))
	LootlingsUI.apply_material(upgrade_panel, "relic")
	LootlingsUI.add_divider(upgrade_panel, Rect2(30, 116, 324, 8), "relic")
	make_label(upgrade_panel, "PERMANENT POWER", 20, Rect2(20, 12, 344, 32), HORIZONTAL_ALIGNMENT_CENTER, Color("#d8b5ff"))
	upgrade_summary = LootlingsUI.rich_label(upgrade_panel, Rect2(28, 40, 328, 68), 14, Color("#e8efff"))
	upgrade_button = make_button(upgrade_panel, "UPGRADE", Rect2(42, 126, 300, 60), Color("#49346b"), Color("#d19cff"), 17)
	upgrade_button.pressed.connect(func(): safe_action(upgrade_button,"Permanent +5% power. Spends Loot Diamonds.",func(): upgrade_requested.emit()))
	var utility_panel := make_panel(upgrade_content, Rect2(30, 576, 420, 216), Color("#0d1530e8"), Color("#d1a85a"))
	LootlingsUI.apply_material(utility_panel, "relic", 18)
	make_label(utility_panel, "HIDEOUT IMPROVEMENTS  •  LOOTCOINS", 15, Rect2(12, 8, 396, 24), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	for index in range(3):
		var upgrade_id: String = ["bedroll", "whetstone", "pouch"][index]
		var button := make_button(utility_panel, "", Rect2(14, 38 + index * 55, 392, 48), Color("#25304a"), Color("#d1a85a"), 12)
		button.pressed.connect(request_gold_upgrade.bind(upgrade_id))
		gold_upgrade_buttons[upgrade_id] = button

func request_gold_upgrade(upgrade_id: String) -> void:
	safe_action(gold_upgrade_buttons[upgrade_id],"Permanent Hideout improvement. Spends Lootcoins.",func(): gold_upgrade_requested.emit(upgrade_id))

func build_shop() -> void:
	shop_content = Control.new()
	shop_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shop_content.visible = false
	add_child(shop_content)
	var back := make_button(shop_content, "‹ HUB", Rect2(20, 20, 122, 48), Color("#202d4d"), Color("#7f94bc"), 16)
	back.pressed.connect(show_home)
	make_label(shop_content, "PATCH’S SHOP", 27, Rect2(145, 22, 315, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	shop_scrap_label = LootlingsUI.rich_label(shop_content, Rect2(145, 65, 315, 28), 11, Color("#d9e5ff"))
	# The merchant cart is a world station in Hub; keep the selected shop view clear.
	for index in range(3):
		var offer_button := make_button(shop_content, "", Rect2(20, 196 + index * 84, 440, 76), Color("#172442e8"), Color("#b7c0ca"), 12)
		offer_button.pressed.connect(select_shop_offer.bind(index))
		shop_offer_buttons.append(offer_button)
	shop_detail_panel = make_panel(shop_content, Rect2(20, 454, 440, 142), Color("#0d1530e6"), Color("#c99a4e"))
	LootlingsUI.apply_material(shop_detail_panel, "salvage", 16)
	shop_detail = RichTextLabel.new()
	shop_detail.position = Vector2(22, 16)
	shop_detail.size = Vector2(268, 110)
	shop_detail.bbcode_enabled = true
	shop_detail.scroll_active = true
	shop_detail.mouse_filter=Control.MOUSE_FILTER_STOP
	shop_detail.add_theme_font_size_override("normal_font_size", 14)
	shop_detail.add_theme_font_size_override("bold_font_size", 16)
	shop_detail.add_theme_font_size_override("italics_font_size", 14)
	shop_detail.add_theme_font_size_override("bold_italics_font_size", 16)
	shop_detail_panel.add_child(shop_detail)
	shop_buy_button = make_button(shop_detail_panel, "SELECT AN OFFER", Rect2(302, 30, 122, 82), Color("#6b4a1e"), Color("#ffd468"), 13)
	shop_buy_button.set_meta("ui_intent", "primary")
	apply_button_style(shop_buy_button, Color("#6b4a1e"), Color("#ffd468"))
	shop_buy_button.pressed.connect(request_selected_shop_offer)
	shop_gold_cache_button = make_button(shop_content, "SCAVENGED CACHE", Rect2(20, 610, 137, 76), Color("#5a3f20"), Color("#ffd36a"), 12)
	shop_gold_cache_button.pressed.connect(func(): safe_action(shop_gold_cache_button,"Spend Lootcoins for one random item. Contents are not known before purchase.",func(): shop_gold_cache_requested.emit()))
	shop_cache_button = make_button(shop_content, "MYSTERY CACHE", Rect2(171, 610, 137, 76), Color("#3f315f"), Color("#c99cff"), 12)
	shop_cache_button.pressed.connect(func(): safe_action(shop_cache_button,"Spend Scrap for one random item. Contents are not known before purchase.",func(): shop_cache_requested.emit()))
	shop_expansion_button = make_button(shop_content, "STASH EXPANSION", Rect2(322, 610, 138, 76), Color("#21455b"), Color("#72c8ff"), 12)
	shop_expansion_button.pressed.connect(func(): safe_action(shop_expansion_button,"Spend Scrap to permanently add stash space.",func(): shop_expansion_requested.emit()))
	for utility in [shop_gold_cache_button,shop_cache_button,shop_expansion_button]:
		utility.clip_text = true
		utility.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		utility.add_theme_font_size_override("font_size",11)
		# Control keeps its previously expanded size when minimum size shrinks.
		utility.size.x = 138 if utility == shop_expansion_button else 137
		utility.set_meta("ui_intent","utility")
		LootlingsUI.apply_button(utility,Color("#192944"),Color("#7087ae"))
	shop_reroll_button = make_button(shop_content, "REROLL ONCE", Rect2(93, 696, 294, 50), Color("#34405b"), Color("#91a6ce"), 13)
	shop_reroll_button.pressed.connect(func(): safe_action(shop_reroll_button,"Spend Scrap to replace all current offers. Once per cycle.",func(): shop_reroll_requested.emit()))
	# Static accepted luggage art illustrates capacity; it is not a new loot roll.
	shop_expansion_button.icon=LootlingsUI.icon("res://art/production/phase4e/props/courier_cache.png")
	shop_expansion_button.expand_icon=true;shop_expansion_button.add_theme_constant_override("icon_max_width",28)
	shop_status_panel = make_panel(shop_content, Rect2(20, 758, 440, 76), Color("#0d1530dc"), Color("#8ea2c8"))
	LootlingsUI.apply_material(shop_status_panel, "salvage", 16)
	LootlingsUI.add_divider(shop_status_panel, Rect2(28, 4, 384, 8), "salvage")
	shop_status = RichTextLabel.new()
	shop_status.position = Vector2(14, 10)
	shop_status.size = Vector2(412, 56)
	shop_status.bbcode_enabled = true
	shop_status.fit_content = false
	shop_status.scroll_active = true
	shop_status.add_theme_font_size_override("normal_font_size", 14)
	shop_status.add_theme_color_override("default_color", Color("#e5edff"))
	shop_status_panel.add_child(shop_status)

func build_coming_soon() -> void:
	coming_content = Control.new()
	coming_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	coming_content.visible = false
	add_child(coming_content)
	var back := make_button(coming_content, "‹ HUB", Rect2(20, 20, 122, 48), Color("#202d4d"), Color("#7f94bc"), 16)
	back.pressed.connect(show_home)
	var panel := make_panel(coming_content, Rect2(38, 190, 404, 330), Color("#10162ff2"), Color("#8ea2c8"))
	coming_title = make_label(panel, "", 23, Rect2(28, 58, 348, 210), HORIZONTAL_ALIGNMENT_CENTER, Color("#dce6ff"))
	coming_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	coming_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func build_achievements() -> void:
	achievement_content = Control.new()
	achievement_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	achievement_content.visible = false
	add_child(achievement_content)
	var back := make_button(achievement_content, "‹ HUB", Rect2(20, 20, 122, 48), Color("#202d4d"), Color("#7f94bc"), 16)
	back.pressed.connect(show_home)
	make_label(achievement_content, "TROPHY ARCHIVE", 28, Rect2(145, 23, 315, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	LootlingsUI.add_icon(achievement_content,Rect2(155,26,32,38),"res://art/production/phase4e/props/trophy_dais.png")
	make_button(achievement_content,"COLLECTION & MASTERY",Rect2(20,797,216,48),Color("#172442"),Color("#7087ae"),12).pressed.connect(func(): show_phase4("archive"))
	achievement_summary = make_label(achievement_content, "", 14, Rect2(46, 75, 388, 28), HORIZONTAL_ALIGNMENT_CENTER, Color("#d7c9ff"))
	var filters := ["ALL", "ADVENTURE", "COMBAT", "LOOT", "OTHER"]
	for index in range(filters.size()):
		var filter_button := make_button(achievement_content, "TRAVEL" if filters[index] == "ADVENTURE" else filters[index], Rect2(20 + index * 89, 108, 84, 48), Color("#171733d9"), Color("#846cb0"), 14)
		filter_button.pressed.connect(set_achievement_filter.bind(filters[index]))
		achievement_filter_buttons.append(filter_button)
	var panel := make_panel(achievement_content, Rect2(20, 156, 440, 404), Color("#090f25d9"), Color("#9f7cce"))
	LootlingsUI.apply_material(panel, "relic", 14)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(13, 14)
	scroll.size = Vector2(414, 376)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	achievement_grid = GridContainer.new()
	achievement_grid.columns = 2
	achievement_grid.custom_minimum_size = Vector2(398, 0)
	achievement_grid.add_theme_constant_override("h_separation", 8)
	achievement_grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(achievement_grid)
	var detail_panel := make_panel(achievement_content, Rect2(20, 576, 440, 208), Color("#0b1229f0"), Color("#c99a4e"))
	LootlingsUI.apply_material(detail_panel, "hoard", 16)
	achievement_detail = RichTextLabel.new()
	achievement_detail.position = Vector2(20, 17)
	achievement_detail.size = Vector2(400, 174)
	achievement_detail.bbcode_enabled = true
	achievement_detail.scroll_active = false
	achievement_detail.fit_content = false
	achievement_detail.add_theme_font_size_override("normal_font_size", 15)
	achievement_detail.add_theme_color_override("default_color", Color("#e7edff"))
	detail_panel.add_child(achievement_detail)
	var lore_button := make_button(achievement_content, "FIELD NOTES & STORIES", Rect2(248, 797, 212, 48), Color("#252343"), Color("#b5a0de"), 12)
	lore_button.pressed.connect(show_lore)

func build_lore() -> void:
	lore_content = Control.new()
	lore_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lore_content.visible = false
	add_child(lore_content)
	make_button(lore_content, "‹ TROPHIES", Rect2(20, 20, 124, 48), Color("#202d4d"), Color("#7f94bc"), 15).pressed.connect(show_achievements)
	make_label(lore_content, "FIELD NOTES", 27, Rect2(148, 23, 312, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	LootlingsUI.add_icon(lore_content,Rect2(159,29,34,34),"res://art/production/phase4e/items/trail_map.png")
	for index in range(FieldNotes.CATEGORIES.size()):
		var category: String = FieldNotes.CATEGORIES[index]
		var button := make_button(lore_content, category, Rect2(20+index*89,90,85,48), Color("#202d4d"), Color("#b5a0de"), 13)
		button.pressed.connect(func(): lore_filter=category; lore_index=0; refresh_lore())
		lore_filter_buttons.append(button)
	var art_panel := make_panel(lore_content,Rect2(24,153,432,128),Color("#10162f"),Color("#b5a0de"))
	LootlingsUI.apply_material(art_panel,"relic")
	lore_art = TextureRect.new()
	lore_art.position=Vector2(12,8); lore_art.size=Vector2(116,112)
	lore_art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	lore_art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	lore_art.mouse_filter=Control.MOUSE_FILTER_IGNORE
	art_panel.add_child(lore_art)
	lore_landscape_backing=ColorRect.new();lore_landscape_backing.position=Vector2(12,85);lore_landscape_backing.size=Vector2(408,35)
	lore_landscape_backing.color=Color("#071027e8");lore_landscape_backing.mouse_filter=Control.MOUSE_FILTER_IGNORE;lore_landscape_backing.visible=false;art_panel.add_child(lore_landscape_backing)
	lore_heading=make_label(art_panel,"",22,Rect2(142,14,270,100),HORIZONTAL_ALIGNMENT_LEFT,Color("#ffe178"))
	lore_heading.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	var panel := make_panel(lore_content, Rect2(24,292,432,421), Color("#10162ff2"), Color("#b5a0de"))
	LootlingsUI.apply_material(panel, "relic")
	lore_detail = LootlingsUI.rich_label(panel, Rect2(24,22,384,377), 18, Color("#e7edff"))
	lore_detail.scroll_active = true
	lore_detail.mouse_filter=Control.MOUSE_FILTER_STOP
	make_button(lore_content, "‹ PREVIOUS", Rect2(28, 739, 204, 64), Color("#202d4d"), Color("#7f94bc"), 16).pressed.connect(cycle_lore.bind(-1))
	make_button(lore_content, "NEXT ›", Rect2(248, 739, 204, 64), Color("#202d4d"), Color("#7f94bc"), 16).pressed.connect(cycle_lore.bind(1))
	make_button(lore_content, "▷ MEMORIES / STORY REPLAY", Rect2(40, 805, 400, 44), Color("#202d4d"), Color("#c99cff"), 14).pressed.connect(show_memories)

func build_memories() -> void:
	memory_content = Control.new()
	memory_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	memory_content.visible = false
	add_child(memory_content)
	make_button(memory_content, "‹ NOTES", Rect2(20,20,124,48), Color("#202d4d"), Color("#7f94bc"),15).pressed.connect(show_lore)
	make_label(memory_content, "MEMORY ARCHIVE",25,Rect2(148,23,312,42),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe178"))
	make_label(memory_content, "Echoes of your travels • memories grant no rewards",13,Rect2(24,74,432,30),HORIZONTAL_ALIGNMENT_CENTER,Color("#c9d8f0"))
	LootlingsUI.add_icon(memory_content,Rect2(194,107,92,70),"res://art/production/phase4e/items/memory_hourglass.png")
	for index in range(4):
		var filter_name: String = ["ALL","Characters","Regions","Bosses"][index]
		var button:=make_button(memory_content, filter_name.to_upper(), Rect2(20+index*111,186,107,48), Color("#202d4d"),Color("#bba0de"),12)
		memory_filter_buttons[filter_name]=button
		button.pressed.connect(func(): memory_filter = filter_name; refresh_memories())
	var panel := make_panel(memory_content, Rect2(20,245,440,550),Color("#090f25d9"),Color("#bba0de"))
	LootlingsUI.apply_material(panel,"relic")
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(14,14)
	scroll.size = Vector2(412,522)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	memory_list = VBoxContainer.new()
	memory_list.custom_minimum_size = Vector2(396,0)
	memory_list.add_theme_constant_override("separation",10)
	scroll.add_child(memory_list)
	make_label(memory_content,"Meet residents. Follow trails. Remember.",13,Rect2(24,806,432,30),HORIZONTAL_ALIGNMENT_CENTER,Color("#bca6dc"))

func show_memories() -> void:
	dismiss_dialogue()
	current_screen = "memories"
	set_screen(memory_content)
	refresh_memories()

func refresh_memories() -> void:
	for id in memory_filter_buttons:apply_display_button_style(memory_filter_buttons[id],Color("#bba0de"),id==memory_filter)
	for child in memory_list.get_children():
		memory_list.remove_child(child)
		child.queue_free()
	for id in Vignettes.ids():
		var entry := Vignettes.entry(id,profile)
		if memory_filter != "ALL" and entry.category != memory_filter: continue
		var unlocked := Vignettes.available(id,profile,campaign.completed if campaign!=null else [])
		var button := Button.new()
		var illustrated: bool=unlocked and entry.category in ["Regions","Bosses"]
		button.custom_minimum_size = Vector2(396,112 if illustrated else 80)
		button.add_theme_font_size_override("font_size",16)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text=""
		LootlingsUI.apply_button(button,Color("#17294b"),Color("#c99cff"))
		var text_x:=144 if illustrated else 86 if unlocked else 16
		var caption:=make_label(button,"%s\n%s" % [str(entry.name), "Revisit this echo"] if unlocked else "UNDISCOVERED MEMORY\nFind this story on your travels",15,Rect2(text_x,12,396-text_x-16,88 if illustrated else 56),HORIZONTAL_ALIGNMENT_LEFT,Color("#e7edff") if unlocked else Color("#91a2c0"))
		caption.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		caption.mouse_filter=Control.MOUSE_FILTER_IGNORE
		if unlocked:
			var art_path: String = str(entry.actor) if not str(entry.actor).is_empty() else str(entry.background)
			if str(id).begins_with("character/"): art_path=FieldNotes.portrait(str(id).get_slice("/",1))
			if str(id).begins_with("resident/"): art_path=preload("res://resident_art_catalog.gd").portrait_path(str(id).get_slice("/",1))
			var thumbnail:=LootlingsUI.add_icon(button,Rect2(10,8,124,96) if illustrated else Rect2(10,8,64,64),art_path)
			if illustrated and str(art_path).contains("/backgrounds/"):
				thumbnail.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;thumbnail.clip_contents=true
			if str(id).begins_with("origin/"): thumbnail.texture=Avatar.portrait(profile)
		button.clip_text=true
		button.disabled = not unlocked
		button.pressed.connect(func(): memory_replay_requested.emit(id))
		memory_list.add_child(button)

func show_lore() -> void:
	dismiss_dialogue()
	current_screen = "lore"
	set_screen(lore_content)
	refresh_lore()

func refresh_lore() -> void:
	lore_entries=[]
	for page in FieldNotes.pages(profile,campaign,current_inventory):
		if lore_filter=="ALL" or page.category==lore_filter: lore_entries.append(page)
	for button in lore_filter_buttons:
		button.disabled=false
		apply_display_button_style(button,Color("#bba0de"),button.text==lore_filter)
	lore_index=clampi(lore_index,0,maxi(0,lore_entries.size()-1))
	cycle_lore(0)

func cycle_lore(direction: int) -> void:
	if direction!=0:ui_event.emit("archive_page")
	if lore_entries.is_empty():
		lore_art.texture=null; lore_heading.text="No recovered pages"
		lore_detail.text="Bring this story home from your travels."
		return
	lore_index = posmod(lore_index + direction, lore_entries.size())
	var entry: Dictionary = lore_entries[lore_index]
	lore_art.texture=entry.get("texture",LootlingsUI.icon(entry.art))
	var landscape: bool=entry.category=="TRAILS" or str(entry.art).contains("/backgrounds/")
	lore_landscape_backing.visible=landscape
	lore_art.get_parent().size.y=240 if landscape else 128
	lore_art.position=Vector2(12,8);lore_art.size=Vector2(408,224) if landscape else Vector2(116,112)
	lore_landscape_backing.position.y=197 if landscape else 85
	lore_detail.get_parent().position.y=404 if landscape else 292
	lore_detail.get_parent().size.y=309 if landscape else 421
	lore_detail.size.y=265 if landscape else 377
	lore_art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED if landscape else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	lore_art.clip_contents=landscape
	lore_heading.position=Vector2(20,199) if landscape else Vector2(142,14)
	lore_heading.size=Vector2(392,32) if landscape else Vector2(270,100)
	lore_heading.add_theme_font_size_override("font_size",19 if landscape else 22)
	lore_heading.text=str(entry.name)
	lore_detail.text="[color=#b99de6]%s • PAGE %d / %d[/color]\n\n%s" % [entry.category,lore_index+1,lore_entries.size(),entry.body]
	lore_detail.scroll_to_line(0)

func refresh_achievements() -> void:
	if achievement_grid == null:
		return
	for child in achievement_grid.get_children():
		achievement_grid.remove_child(child)
		child.queue_free()
	var unlocked_count: int = int(achievement_manager.unlocked.size()) if achievement_manager != null else 0
	achievement_summary.text = "%d / %d RECOVERED  •  TAP A BADGE FOR DETAILS" % [unlocked_count, AchievementManager.DEFINITIONS.size()]
	for index in range(achievement_filter_buttons.size()):
		achievement_filter_buttons[index].disabled=false
		apply_display_button_style(achievement_filter_buttons[index],Color("#bba0de"),achievement_filter_buttons[index].text==achievement_filter)
	var visible_entries: Array = []
	for entry in AchievementManager.DEFINITIONS:
		if not achievement_matches_filter(entry):
			continue
		visible_entries.append(entry)
		var unlocked: bool = achievement_manager != null and bool(achievement_manager.is_unlocked(str(entry.id)))
		var current := int(achievement_manager.progress.get(entry.id, 0)) if achievement_manager != null else 0
		var target := int(entry.get("target", 1))
		var secret: bool = bool(entry.get("secret", false)) and not unlocked
		var title := "???" if secret else str(entry.name)
		var progress_text := "COMPLETE" if unlocked else "%d / %d" % [mini(current, target), target]
		var card := make_button(achievement_grid, "\n\n%s\n%s" % [title, progress_text], Rect2(0, 0, 195, 142), Color("#392b34") if unlocked else Color("#131a32"), Color("#ffd36a") if unlocked else Color("#58698f"), 14)
		LootlingsUI.add_icon(card, Rect2(73, 8, 48, 48), trophy_texture_path(entry, unlocked, secret))
		card.custom_minimum_size = Vector2(195, 142)
		if unlocked:
			card.set_meta("ui_intent", "primary")
			apply_button_style(card, Color("#392b34"), Color("#ffd36a"))
		card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.clip_text = true
		card.tooltip_text = title
		card.pressed.connect(select_achievement.bind(str(entry.id)))
	if visible_entries.is_empty():
		achievement_detail.text = "[center][color=#9fb3d8]No trophies in this collection yet.[/color][/center]"
		return
	var selected_visible := false
	for entry in visible_entries:
		if str(entry.id) == selected_achievement_id:
			selected_visible = true
			break
	if not selected_visible:
		selected_achievement_id = str(visible_entries[0].id)
	refresh_achievement_detail()

func set_achievement_filter(filter_name: String) -> void:
	achievement_filter = filter_name
	selected_achievement_id = ""
	refresh_achievements()

func achievement_matches_filter(entry: Dictionary) -> bool:
	var category := str(entry.get("category", "Other")).to_upper()
	match achievement_filter:
		"ALL": return true
		"ADVENTURE": return category in ["ADVENTURE", "HIDEOUT"]
		"COMBAT": return category in ["COMBAT", "MASTERY"]
		"LOOT": return category in ["LOOT", "COLLECTION"]
		_: return category in ["BOSSES", "SECRET"]

func trophy_texture_path(entry: Dictionary, unlocked: bool, secret: bool) -> String:
	if secret:
		return "res://art/ui/trophies/category_secret.png"
	return "res://art/ui/trophies/category_%s.png" % str(entry.get("category", "Collection")).to_lower() if unlocked else "res://art/ui/trophies/trophy_locked.png"

func select_achievement(id: String) -> void:
	selected_achievement_id = id
	refresh_achievement_detail()

func refresh_achievement_detail() -> void:
	if achievement_detail == null or selected_achievement_id.is_empty():
		return
	var entry := AchievementManager.definition_for(selected_achievement_id)
	if entry.is_empty():
		return
	var unlocked: bool = achievement_manager != null and achievement_manager.is_unlocked(selected_achievement_id)
	var secret: bool = bool(entry.get("secret", false)) and not unlocked
	var title := "UNKNOWN TROPHY" if secret else str(entry.name).to_upper()
	var description := "A secret waits somewhere in the ruins." if secret else str(entry.get("revealed_desc", entry.desc))
	var current := int(achievement_manager.progress.get(entry.id, 0)) if achievement_manager != null else 0
	var target := int(entry.get("target", 1))
	var state_line := "[color=#ffe178]RECOVERED[/color]" if unlocked else "[color=#9fddff]PROGRESS  %d / %d[/color]" % [mini(current, target), target]
	achievement_detail.text = "[center][font_size=22][color=%s][img=28x28]%s[/img]  %s[/color][/font_size]\n[color=#b99de6]%s COLLECTION[/color]\n\n%s\n\n%s[/center]" % ["#ffe178" if unlocked else "#d9e5ff", trophy_texture_path(entry, unlocked, secret), title, str(entry.category).to_upper(), description, state_line]

func refresh_home() -> void:
	if current_inventory == null or resource_label == null:
		return
	var scrap_changed: bool = last_scrap >= 0 and last_scrap != int(current_inventory.scrap)
	last_scrap = current_inventory.scrap
	var display_name := str(profile.get("display_name", "TREASURE SEEKER")).to_upper()
	if display_name.is_empty():
		display_name = "TREASURE SEEKER"
	hub_navigation.refresh()
	resource_label.text="[center]%s %s Lootcoins   %s %s Scrap   %s %s Diamonds[/center]" % [LootlingsUI.inline_icon("currency_gold"),preload("res://display_numbers.gd").compact(gold),LootlingsUI.inline_icon("currency_scrap"),preload("res://display_numbers.gd").compact(current_inventory.scrap),LootlingsUI.inline_icon("currency_star_shard"),preload("res://display_numbers.gd").compact(shards)]
	# Public Hub equipment marker remains independent of private Home decor.
	home_weapon.visible=false
	home_weapon_name.visible=false
	home_weapon.configure(current_inventory.equipped_item("Weapon")); home_weapon_name.text=str(current_inventory.equipped_item("Weapon").get("name","No weapon"))
	if scrap_changed and current_screen == "home":
		pulse_control(resource_label, Color("#9fddff"))
	var weapon: Dictionary = current_inventory.equipped_item("Weapon")
	var armour: Dictionary = current_inventory.equipped_item("Armour")
	var charm: Dictionary = current_inventory.equipped_item("Relic")
	loadout_label.text = "[center]%s\n%s • open GEAR for your full loadout[/center]" % [item_name_or_empty(weapon), current_inventory.weapon_family()]

func refresh_stash() -> void:
	if current_inventory == null or stash_list == null:
		return
	for slot in equipped_slot_buttons:
		var slot_button: Button = equipped_slot_buttons[slot]
		var worn: Dictionary = current_inventory.equipped_item(slot)
		var slot_art: Control = slot_button.get_node("SlotArt")
		slot_art.visible = not worn.is_empty()
		if not worn.is_empty(): slot_art.configure(worn)
		slot_button.tooltip_text = "Empty %s slot" % ItemCatalog.display_slot(slot) if worn.is_empty() else "%s • %s" % [worn.name, worn.rarity]
		for state in ["normal","hover","pressed","disabled"]:
			slot_button.add_theme_stylebox_override(state,StyleBoxEmpty.new())
	stash_title.text = "STASH  •  %d / %d STORED" % [current_inventory.stash.size(), current_inventory.stash_capacity]
	for filter_name in filter_buttons:
		var filter_button: Button = filter_buttons[filter_name]
		filter_button.disabled=false
		apply_display_button_style(filter_button,Color("#7194c4"),filter_name==stash_filter)
	for child in stash_list.get_children():
		stash_list.remove_child(child)
		child.queue_free()
	entries.clear()
	for slot in current_inventory.SLOTS:
		var equipped: Dictionary = current_inventory.equipped_item(slot)
		if not equipped.is_empty() and item_matches_filter(equipped):
			entries.append({"item":equipped, "equipped":true, "stash_index":-1})
	for index in range(current_inventory.stash.size()):
		var stored_item: Dictionary = current_inventory.stash[index]
		if item_matches_filter(stored_item):
			entries.append({"item":stored_item, "equipped":false, "stash_index":index})
	for entry_index in range(entries.size()):
		var entry: Dictionary = entries[entry_index]
		var item: Dictionary = entry.item
		var marker := "EQUIPPED" if entry.equipped else "STORED"
		var family := "  •  %s" % item.get("family", "") if item.has("family") else ""
		var button := make_button(stash_list, "%s  •  %s%s\n%s  [%s]" % [marker, slot_icon(item.get("slot", "")), family, item.get("name", "Unknown"), item.get("rarity", "COMMON")], Rect2(0, 0, 402, 68), Color("#172442"), ItemCatalog.rarity_color(item.get("rarity", "COMMON")), 13)
		LootlingsUI.apply_rarity_card(button,ItemCatalog.rarity_color(item.get("rarity","COMMON")))
		button.custom_minimum_size = Vector2(402, 68)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.clip_text = true
		apply_item_thumbnail(button, item)
		button.pressed.connect(select_entry.bind(entry_index))
	if entries.is_empty():
		var empty := VBoxContainer.new()
		empty.name="EmptyStashGuide"
		empty.custom_minimum_size=Vector2(402,220)
		empty.add_theme_constant_override("separation",14)
		stash_list.add_child(empty)
		var heading:=Label.new()
		heading.text="YOUR NEXT TREASURE AWAITS" if stash_filter=="ALL" else "NO "+stash_filter.to_upper()+" GEAR YET"
		heading.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		heading.add_theme_font_size_override("font_size",19)
		heading.add_theme_color_override("font_color",Color("#ffe178"))
		heading.custom_minimum_size=Vector2(402,48)
		empty.add_child(heading)
		var help:=Label.new()
		help.text="Find equipment beyond the Gate, then return here to compare, equip or salvage it.\nYour equipped gear appears above." if stash_filter=="ALL" else "Try another category, or find more equipment on an expedition."
		help.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		help.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		help.add_theme_font_size_override("font_size",17)
		help.add_theme_color_override("font_color",Color("#b9cce9"))
		help.custom_minimum_size=Vector2(402,92)
		empty.add_child(help)
		if stash_filter!="ALL":
			var all_gear:=make_button(empty,"SHOW ALL GEAR",Rect2(0,0,402,56),Color("#1c2948"),Color("#72c8ff"),17)
			all_gear.custom_minimum_size=Vector2(402,56)
			all_gear.set_meta("ui_intent","primary")
			LootlingsUI.apply_button(all_gear,Color("#1c2948"),Color("#72c8ff"))
			all_gear.pressed.connect(func():stash_filter="ALL";refresh_stash())
	var bottom_padding := Control.new()
	bottom_padding.custom_minimum_size = Vector2(402, 16)
	stash_list.add_child(bottom_padding)
	if entries.is_empty():
		stash_detail_icon.visible = false
		stash_detail_name.text = "EMPTY CATEGORY"
		stash_detail_identity.text = "Find gear during an expedition"
		stash_detail.text = "[center][color=#8fa4ce]No %s equipment found.[/color][/center]" % stash_filter.to_lower()
		stash_equip_button.disabled = true
		stash_scrap_button.disabled = true
	close_stash_detail()

func select_entry(entry_index: int) -> void:
	if entry_index < 0 or entry_index >= entries.size():
		return
	selected_entry = entry_index
	for index in range(entries.size()):
		var row := stash_list.get_child(index) as Button
		if row != null: LootlingsUI.apply_selection(row,index==entry_index)
	stash_opened_at=Time.get_ticks_msec()
	stash_detail_panel.visible=true; stash_equip_button.visible=true; stash_scrap_button.visible=true
	stash_scroll.size.y=211
	if entry_index < stash_list.get_child_count():
		pulse_control(stash_list.get_child(entry_index), Color("#72c8ff"))
	var entry: Dictionary = entries[entry_index]
	var item: Dictionary = entry.item
	var rarity: String = item.get("rarity", "COMMON")
	var color := ItemCatalog.rarity_color(rarity).to_html(false)
	stash_detail_icon.visible = true
	stash_detail_icon.configure(item)
	stash_detail_name.text = str(item.get("name", "Unknown"))
	stash_detail_name.size.x=250
	stash_detail_name.add_theme_font_size_override("font_size",LootlingsUI.fitted_font_size(get_parent().body_font,stash_detail_name.text,250,20,14))
	stash_detail_name.add_theme_color_override("font_color", Color("#" + color))
	stash_detail_identity.text = "%s • %s" % [rarity, ItemCatalog.display_identity(item)]
	stash_detail.scroll_to_line(0)
	if entry.equipped:
		stash_detail.text = "[color=#69e6b0]CURRENTLY EQUIPPED[/color]\n%s" % ItemCatalog.describe_headline_effects(item, 2)
		stash_detail.tooltip_text = "%s\n%s" % [item.get("desc", ""), ItemCatalog.describe_effects(item)]
		stash_equip_button.disabled = true
		stash_scrap_button.disabled = true
		stash_equip_button.text = "EQUIPPED"
		stash_scrap_button.text = "SALVAGE"
	else:
		var equipped: Dictionary = current_inventory.equipped_item(item.get("slot", ""))
		stash_detail.text = "[b]Owned gear · free to equip[/b]\n" + comparison_callable.call(item, equipped)
		stash_detail.tooltip_text = "%s\n%s" % [item.get("desc", ""), ItemCatalog.describe_effects(item)]
		stash_equip_button.disabled = false
		stash_scrap_button.disabled = false
		stash_equip_button.text = "EQUIP"
		stash_scrap_button.text = "SALVAGE  +%d" % ItemCatalog.scrap_value(item)

func refresh_upgrades() -> void:
	if upgrade_summary == null:
		return
	var cost := 10 + power * 5
	upgrade_summary.text = "[center]LEVEL %d  •  TOTAL +%d%%\nDamage + Max HP every run\n%s %d LOOT DIAMONDS[/center]" % [power, power * 5, LootlingsUI.inline_icon("currency_star_shard"), shards]
	upgrade_button.text = "POWER +5%%\nCOST %d DIAMONDS" % cost
	if power >= 100: upgrade_button.text = "POWER MAXED\nRANK 100 / 100"
	elif shards < cost: upgrade_button.text = "POWER +5%%\nNEED %d MORE DIAMONDS" % (cost-shards)
	upgrade_button.icon = LootlingsUI.icon("currency_star_shard")
	upgrade_button.expand_icon = true
	upgrade_button.add_theme_constant_override("icon_max_width", 20)
	upgrade_button.disabled = shards < cost or power >= 100
	var definitions := {
		"bedroll":["STURDY BEDROLL", "+4 starting HP", [250,450,700,1000,1400]],
		"whetstone":["RELIC WHETSTONE", "+0.6 starting damage", [300,525,800,1150,1600]],
		"pouch":["FIELD POUCH", "+8 starting Run Scrip", [225,400,650,950,1300]]
	}
	for upgrade_id in gold_upgrade_buttons:
		var rank := int(gold_upgrades.get(upgrade_id, 0))
		var data: Array = definitions[upgrade_id]
		var button: Button = gold_upgrade_buttons[upgrade_id]
		if rank >= 5:
			button.text = "%s  •  RANK 5/5  •  MAXED" % data[0]
			button.disabled = true
		else:
			var price: int = data[2][rank]
			button.text = "%s  •  RANK %d/5\n%s     %d LOOTCOINS" % [data[0], rank, data[1], price]
			button.icon = LootlingsUI.icon("currency_gold")
			button.expand_icon = true
			button.add_theme_constant_override("icon_max_width", 18)
			button.disabled = gold < price
			if button.disabled:button.text += " · need %d more" % (price-gold)

func refresh_shop() -> void:
	if current_inventory == null or current_shop == null or shop_scrap_label == null:
		return
	shop_scrap_label.text = "[center]%s %s LOOTCOINS • %s %s SCRAP • %d/%d STASH[/center]" % [LootlingsUI.inline_icon("currency_gold"), preload("res://display_numbers.gd").compact(gold), LootlingsUI.inline_icon("currency_scrap"), preload("res://display_numbers.gd").compact(current_inventory.scrap), current_inventory.stash.size(), current_inventory.stash_capacity]
	var reveal_pending: bool = not current_shop.pending_cache_item.is_empty()
	shop_gold_cache_button.text = "SCAVENGED CACHE\n%d LOOTCOINS" % current_shop.GOLD_CACHE_COST
	shop_gold_cache_button.disabled = reveal_pending or current_shop.gold_cache_bought_this_cycle or gold < current_shop.GOLD_CACHE_COST or current_inventory.stash.size() >= current_inventory.stash_capacity
	for index in range(shop_offer_buttons.size()):
		var button: Button = shop_offer_buttons[index]
		if index >= current_shop.stock.size() or current_shop.stock[index].is_empty():
			button.text = "SOLD OUT\nREFRESHES AFTER RUN"
			button.disabled = true
			button.icon = null
			button.alignment = HORIZONTAL_ALIGNMENT_CENTER
			apply_sold_display_style(button)
			if selected_shop_offer == index:
				selected_shop_offer = -1
			continue
		var item: Dictionary = current_shop.stock[index]
		button.text = "%s\n%s · %d Scrap" % [item.get("name", "Unknown"), item.get("rarity", "COMMON").capitalize(), item.get("price", 0)]
		button.add_theme_font_size_override("font_size", 15)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.disabled = reveal_pending
		apply_display_button_style(button, ItemCatalog.rarity_color(item.get("rarity", "COMMON")), selected_shop_offer == index)
		apply_item_thumbnail(button, item)
	refresh_shop_detail(reveal_pending)
	var expansion_cost: int = current_shop.expansion_cost(current_inventory.stash_capacity)
	shop_expansion_button.text = "STASH EXPANSION\n%d → %d SLOTS\n%d SCRAP" % [current_inventory.stash_capacity, current_inventory.next_stash_capacity(), expansion_cost] if expansion_cost > 0 else "STASH EXPANSION\nMAXIMUM 24 SLOTS"
	shop_expansion_button.disabled = expansion_cost <= 0 or current_inventory.scrap < expansion_cost or reveal_pending
	shop_reroll_button.text = "REROLL ONCE  •  %d SCRAP" % current_shop.REROLL_COST if not current_shop.rerolled_this_cycle else "REROLL USED THIS RUN"
	shop_reroll_button.disabled = current_shop.rerolled_this_cycle or current_inventory.scrap < current_shop.REROLL_COST or reveal_pending
	if reveal_pending:
		var item: Dictionary = current_shop.pending_cache_item
		var color := ItemCatalog.rarity_color(item.get("rarity", "COMMON")).to_html(false)
		var is_gold_cache: bool = current_shop.pending_cache_currency == "gold"
		shop_cache_button.text = "CLAIM REVEALED ITEM" if not is_gold_cache else "MYSTERY CACHE"
		shop_cache_button.disabled = is_gold_cache or current_inventory.stash.size() >= current_inventory.stash_capacity
		shop_gold_cache_button.text = "CLAIM REVEALED ITEM" if is_gold_cache else "SCAVENGED CACHE"
		shop_gold_cache_button.disabled = not is_gold_cache or current_inventory.stash.size() >= current_inventory.stash_capacity
		shop_status.text = "[center][color=#ffe178]%s REVEAL[/color]\n[font_size=20][color=#%s]%s[/color][/font_size]\n%s  •  %s\n%s[/center]" % ["SCAVENGED CACHE" if is_gold_cache else "MYSTERY CACHE", color, item.get("name", "Unknown"), item.get("rarity", "COMMON"), ItemCatalog.display_slot(item.get("slot", "Item")), ItemCatalog.describe_effects(item)]
	else:
		if current_shop.cache_bought_this_cycle:
			shop_cache_button.text = "CACHE OPENED\nREFRESHES AFTER RUN"
			shop_cache_button.disabled = true
		else:
			shop_cache_button.text = "MYSTERY CACHE\nREVEAL 1 ITEM\n%d SCRAP" % current_shop.CACHE_COST
			shop_cache_button.disabled = current_inventory.scrap < current_shop.CACHE_COST or current_inventory.stash.size() >= current_inventory.stash_capacity
		if current_shop.gold_cache_bought_this_cycle:
			shop_gold_cache_button.text = "GOLD CACHE OPENED\nREFRESHES AFTER RUN"
			shop_gold_cache_button.disabled = true
		if current_inventory.stash.size() >= current_inventory.stash_capacity:
			shop_status.text = "[center][color=#ff9b8f]STASH FULL[/color]\nScrap or equip stored gear to make room.\nNothing will be overwritten.[/center]"
		elif shop_status.text.is_empty() or shop_status.text.contains("MYSTERY CACHE REVEAL") or shop_status.text.contains("SCAVENGED CACHE REVEAL") or shop_status.text.contains("STASH FULL"):
			shop_status.text = "[center][color=#ffe39a]Choose gear • pay with Scrap[/color]\nStock refreshes after a completed run.[/center]"
	if current_shop.requires_review():
		for button in shop_offer_buttons+[shop_cache_button,shop_gold_cache_button,shop_expansion_button,shop_reroll_button]:button.disabled=true
		show_shop_message("Your reserved cache needs review. Its record is retained; no new charge was made.")

func refresh_shop_detail(reveal_pending: bool) -> void:
	if selected_shop_offer < 0 or selected_shop_offer >= current_shop.stock.size() or current_shop.stock[selected_shop_offer].is_empty():
		shop_detail_panel.visible = true
		shop_detail.text = "[b]Choose an item above[/b]\nCompare it with your equipped gear, then buy with Scrap. Purchases go to your stash."
		shop_buy_button.text = "CHOOSE\nAN ITEM"
		shop_buy_button.disabled = true
		return
	shop_detail_panel.visible = true
	var item: Dictionary = current_shop.stock[selected_shop_offer]
	var rarity: String = item.get("rarity", "COMMON")
	var color := ItemCatalog.rarity_color(rarity).to_html(false)
	shop_detail.text = "[b][color=#%s]%s[/color][/b]\n%s · %s\n%s" % [color,item.get("name","Unknown"),rarity.capitalize(),ItemCatalog.display_slot(item.get("slot","Item")),ItemCatalog.describe_headline_effects(item,2)]
	shop_detail.tooltip_text = str(item.get("desc",""))
	shop_buy_button.text = "BUY\n%d SCRAP" % int(item.get("price", 0))
	shop_detail.text+="\n\n%s\nBought gear goes to your stash; equip it when ready.\n\n%s" % [comparison_callable.call(item,current_inventory.equipped_item(str(item.get("slot","Weapon")))),item.get("desc","")]
	shop_buy_button.disabled = reveal_pending or current_inventory.scrap < int(item.get("price", 0)) or current_inventory.stash.size() >= current_inventory.stash_capacity
	if reveal_pending:shop_buy_button.text="CLAIM\nYOUR CACHE"
	elif current_inventory.stash.size() >= current_inventory.stash_capacity:shop_buy_button.text="STASH\nIS FULL"
	elif current_inventory.scrap < int(item.get("price",0)):shop_buy_button.text="NEED %d\nMORE SCRAP" % (int(item.get("price",0))-current_inventory.scrap)

func show_shop_message(message: String, color: String = "#e5edff") -> void:
	shop_status.text = "[center][color=%s]%s[/color][/center]" % [color, message]
	refresh_shop()

func set_stash_filter(filter_name: String) -> void:
	stash_filter = filter_name
	selected_entry = -1
	refresh_stash()

func item_matches_filter(item: Dictionary) -> bool:
	if stash_filter == "ALL":
		return true
	var internal_filter := "Relic" if stash_filter == "CHARM" else stash_filter.capitalize()
	return item.get("slot", "") == internal_filter

func request_stash_equip() -> void:
	if selected_entry < 0 or selected_entry >= entries.size() or Time.get_ticks_msec()-stash_opened_at<180:
		return
	var entry: Dictionary = entries[selected_entry]
	if not entry.equipped:
		stash_equip_requested.emit(int(entry.stash_index))

func request_stash_scrap() -> void:
	if selected_entry<0 or selected_entry>=entries.size() or Time.get_ticks_msec()-stash_opened_at<250: return
	var entry: Dictionary=entries[selected_entry]
	if entry.equipped: return
	var item: Dictionary=entry.item; var index:=int(entry.stash_index)
	get_parent().touch_ux.request("Salvage %s?" % item.name,"Receive %d Scrap. This item is destroyed permanently." % ItemCatalog.scrap_value(item),func(): stash_scrap_requested.emit(index))

func select_shop_offer(index: int) -> void:
	if current_shop == null or index < 0 or index >= current_shop.stock.size() or current_shop.stock[index].is_empty():
		return
	selected_shop_offer = index
	refresh_shop_detail(not current_shop.pending_cache_item.is_empty())
	refresh_shop()
	pulse_control(shop_offer_buttons[index], ItemCatalog.rarity_color(current_shop.stock[index].get("rarity", "COMMON")))
	queue_redraw()

func request_selected_shop_offer() -> void:
	if selected_shop_offer >= 0:
		var index:=selected_shop_offer
		var item:Dictionary=current_shop.stock[index]
		get_parent().touch_ux.request("Buy %s?" % item.name,"Pay %d Scrap. This item goes into your stash." % int(item.price),func():shop_offer_requested.emit(index))

func play_shop_purchase(index: int, rarity_color: Color) -> void:
	if index >= 0 and index < shop_offer_buttons.size():
		pulse_control(shop_offer_buttons[index], rarity_color)
		spawn_ui_burst(Vector2(88 + index * 147, 258), rarity_color, 12)
	pulse_control(shop_scrap_label, Color("#9fddff"))

func play_cache_reveal(rarity_color: Color, reveal_profile: Dictionary = {}, item: Dictionary = {}) -> void:
	cache_pulse_duration = maxf(0.34, float(reveal_profile.get("anticipation", 0.52)) + 0.28)
	cache_pulse = cache_pulse_duration
	cache_pulse_color = rarity_color
	var revealed: Dictionary = item if not item.is_empty() else current_shop.pending_cache_item if current_shop != null else {}
	var texture := LootlingsUI.item_texture(revealed)
	presentation.play_chest_showcase("scavenged", Vector2(240, 428), rarity_color, texture)
	shake_control(shop_cache_button)
	pulse_control(shop_status_panel, rarity_color)
	spawn_ui_burst(Vector2(125, 562), rarity_color, int(reveal_profile.get("particles", 18)))

func play_stash_feedback(kind: String) -> void:
	var target := stash_equip_button if kind == "equip" else stash_scrap_button
	var color := Color("#69e6b0") if kind == "equip" else Color("#ffbd69")
	pulse_control(target, color)
	pulse_control(stash_detail_panel, color)
	spawn_ui_burst(target.position + target.size * 0.5, color, 12)

func play_shrine_upgrade() -> void:
	shrine_pulse = 0.72
	pulse_control(upgrade_panel, Color("#d19cff"))
	pulse_control(upgrade_button, Color("#f0d5ff"))
	spawn_ui_burst(Vector2(315, 252), Color("#c99cff"), 20)

func slot_icon(slot: String) -> String:
	match slot:
		"Weapon": return "WEAPON"
		"Armour": return "ARMOUR"
		"Relic": return "CHARM"
		"Rune": return "RUNE"
	return "GEAR"

func weapon_texture_for_item(item: Dictionary) -> Texture2D:
	if item.get("slot", "") != "Weapon":
		return null
	return LootlingsUI.item_texture(item)

func apply_item_thumbnail(button: Button, item: Dictionary, card_layout: bool = false) -> void:
	var old_badge := button.get_node_or_null("RarityBadge")
	if old_badge != null:
		button.remove_child(old_badge)
		old_badge.queue_free()
	var old_icon := button.get_node_or_null("CategoryIcon")
	if old_icon != null:
		button.remove_child(old_icon)
		old_icon.queue_free()
	button.icon = null if card_layout else weapon_texture_for_item(item)
	button.expand_icon = true
	if button.icon != null:
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_constant_override("icon_max_width", 52)
	else:
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER if card_layout else HORIZONTAL_ALIGNMENT_LEFT
		if not card_layout:
			# Every equipment category shares the weapon's icon-safe text lane.
			button.set_meta("card_text_inset",68.0)
			for state_name in ["normal","hover","pressed","disabled"]:
				var style := LootlingsUI.inset_style(button.get_theme_stylebox(state_name),68)
				button.add_theme_stylebox_override(state_name,style)
		var weapon_texture := weapon_texture_for_item(item)
		if card_layout and weapon_texture != null:
			var weapon_icon := TextureRect.new()
			weapon_icon.name = "CategoryIcon"
			weapon_icon.position = Vector2((button.size.x - 46.0) * 0.5, 4)
			weapon_icon.size = Vector2(46, 46)
			weapon_icon.texture = weapon_texture
			weapon_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			weapon_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			weapon_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.add_child(weapon_icon)
		else:
			var category_icon := ItemIcon.new()
			category_icon.name = "CategoryIcon"
			category_icon.position = Vector2((button.size.x - 42.0) * 0.5, 5) if card_layout else Vector2(8, maxf(4.0, (button.size.y - 52.0) * 0.5))
			category_icon.size = Vector2(42, 42) if card_layout else Vector2(52, 52)
			category_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			category_icon.configure(item)
			button.add_child(category_icon)
	if item.get("slot", "") == "Weapon":
		var badge := LootlingsUI.add_icon(button, Rect2(Vector2((button.size.x - 46) * 0.5 + 32, 36) if card_layout else Vector2(40, 42), Vector2(16, 16)), "rarity_%s" % str(item.get("rarity", "COMMON")).to_lower())
		badge.name = "RarityBadge"

func dismiss_dialogue() -> void:
	if speech_panel != null:
		speech_panel.visible = false
	speech_visible_timer = 0.0
	speech_timer = 6.0
	speech_speaker = ""

func build_transition_overlay() -> void:
	presentation = PresentationDirector.new()
	add_child(presentation)

func build_dialogue_overlay() -> void:
	var speech_veil:=ColorRect.new(); speech_veil.name="DialogueVeil"; speech_veil.color=Color("#050b171c"); speech_veil.size=Vector2(480,854); speech_veil.z_index=79; speech_veil.mouse_filter=Control.MOUSE_FILTER_STOP; speech_veil.visible=false; add_child(speech_veil)
	speech_panel=make_panel(self,Rect2(20,599,440,224),Color("#10182bf5"),Color("#d8bd7b")); speech_panel.visible=false; speech_panel.z_index=80
	speech_panel.visibility_changed.connect(func():speech_veil.visible=speech_panel.visible)
	speech_portrait=TextureRect.new(); speech_portrait.position=Vector2(14,14); speech_portrait.size=Vector2(54,64); speech_portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; speech_portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; speech_portrait.mouse_filter=Control.MOUSE_FILTER_IGNORE; speech_panel.add_child(speech_portrait)
	speech_label=make_label(speech_panel,"",15,Rect2(82,15,304,146),HORIZONTAL_ALIGNMENT_LEFT,Color("#f3edda")); speech_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; speech_label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	make_button(speech_panel,"×",Rect2(386,6,48,48),Color("#172442"),Color("#7087ae"),22).pressed.connect(dismiss_dialogue)
	speech_role=make_button(speech_panel,"",Rect2(82,168,304,48),Color("#293a46"),Color("#d8bd7b"),14)
	speech_role.pressed.connect(func():
		match speech_speaker:
			"Salvager": show_forge() if current_screen=="forge" else show_shop()
			"Relic Keeper": show_upgrades()
			"Archivist": show_phase4("archive")
			_: profile_requested.emit(); dismiss_dialogue()
	)

func make_npc_hotspot(parent: Control, rect: Rect2, speaker: String) -> void:
	var hotspot := Button.new()
	hotspot.position = rect.position
	hotspot.size = rect.size
	hotspot.flat = true
	hotspot.set_meta("gesture_release_owned",true)
	hotspot.focus_mode = Control.FOCUS_ALL
	var focus:=StyleBoxFlat.new();focus.bg_color=Color.TRANSPARENT;focus.border_color=Color("#d1dff6");focus.set_border_width_all(2);focus.set_corner_radius_all(8)
	hotspot.add_theme_stylebox_override("focus",focus)
	hotspot.tooltip_text = "Talk to %s" % WorldStory.SPEAKERS.get(speaker, speaker)
	hotspot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hotspot.pressed.connect(func():
		if speaker == "Mascot": request_dialogue("tapped", speaker)
		else: resident_meeting_requested.emit(speaker)
	)
	parent.add_child(hotspot)

func make_object_hotspot(parent: Control, node_name: String, rect: Rect2, action: Callable, hint: String) -> void:
	var hotspot:=Button.new(); hotspot.name=node_name; hotspot.position=rect.position; hotspot.size=rect.size; hotspot.flat=true; hotspot.focus_mode=Control.FOCUS_NONE; hotspot.tooltip_text=hint; hotspot.set_meta("gesture_release_owned",true)
	for state in ["normal","hover","pressed","focus"]: hotspot.add_theme_stylebox_override(state,StyleBoxEmpty.new())
	hotspot.pressed.connect(action); parent.add_child(hotspot)

func queue_dialogue_context(context: String) -> void:
	var priorities := {"returning":1, "early_defeat":2, "victory":3, "epic_find":4, "boss_defeated":5, "legendary_find":6, "red_find":8, "secret_discovered":8, "signature_find":7, "large_hoard":5, "forge_evolved":4, "contract_complete":3, "cache_opened":3, "trophy_earned":2}
	var priority := int(priorities.get(context, 1))
	if priority < queued_dialogue_priority:
		return
	queued_dialogue_context = context
	queued_dialogue_priority = priority
	speech_visible_timer = 0.0
	if speech_panel != null:
		speech_panel.visible = false

func request_dialogue(context: String = "idle", requested_speaker: String = "") -> void:
	if context not in ["idle","tapped"]:
		last_home_facts.event=context
	if context!="tapped" or speech_panel==null: return
	if speech_panel.visible and speech_speaker==requested_speaker: dismiss_dialogue(); return
	speech_speaker=requested_speaker
	var game=get_parent()
	var facts: Dictionary={"event":queued_dialogue_context,"weapon":str(current_inventory.equipped_item("Weapon").get("weapon_type","")) if current_inventory!=null else "","mode":"siege" if game.retention.siege else "dungeon" if game.retention.targeted else "region"}
	facts.merge(last_home_facts,true)
	if not queued_dialogue_context.is_empty(): facts.event=queued_dialogue_context
	facts.character=Avatar.preset_id(profile) if Avatar.is_wanderer(profile) else str(profile.get("current_lootling_id","relic_beast"))
	facts.activity=resident_activity(requested_speaker)
	var line: String=home_dialogue.choose(requested_speaker,facts)
	var voice_name: String=WorldStory.SPEAKERS.get(requested_speaker,requested_speaker)
	if requested_speaker=="Mascot":
		voice_name=Avatar.display_name(profile)
		line=home_dialogue.choose(facts.character,facts)
	queued_dialogue_context=""; queued_dialogue_priority=-1
	speech_label.text=voice_name+"
"+line
	speech_portrait.texture=RESIDENT_PORTRAITS.get(requested_speaker,Avatar.portrait(profile,"curious"))
	speech_role.text={"Salvager":"OPEN FORGE  ›" if current_screen=="forge" else "OPEN SHOP  ›","Relic Keeper":"OPEN SHRINE  ›","Archivist":"OPEN ARCHIVE  ›","Mascot":"CHARACTER  ›"}.get(requested_speaker,"CONTINUE")
	speech_panel.visible=true; speech_panel.modulate=Color.WHITE; speech_panel.scale=Vector2.ONE
	speech_visible_timer=0.0

func dialogue_anchor(speaker: String) -> Vector2:
	if current_screen == "shop":
		return Vector2(152, 116) if speaker == "Salvager" else Vector2(86, 166)
	if current_screen == "upgrades":
		return Vector2(152, 264) if speaker == "Relic Keeper" else Vector2(86, 270)
	if current_screen == "stash":
		return Vector2(86, 188)
	return Vector2(24, 590)

func play_transition() -> void:
	if presentation == null:
		return
	presentation.flash(Color("#7d93bd"), 0.18)

func _process(delta: float) -> void:
	scene_time += delta
	if dialogue != null:
		dialogue.update(delta)
	if not visible:
		return
	if current_screen == "home":
		companion_presenter.update(delta,Vector2(240,491),Vector2(-96,10))
		var cycle:=int(scene_time/28.0)
		if cycle!=station_cycle:
			station_cycle=cycle
			if cycle>0 and cycle%3==0: ui_event.emit("home_bench")
			elif cycle%3==2: ui_event.emit("home_page")
		life_event_clock -= delta
		life_event_time = maxf(0.0, life_event_time - delta)
		if life_event_clock <= 0.0:
			life_event = ["critter", "coin", "chest", "motes"][life_rng.randi_range(0, 3)]
			life_event_time = life_rng.randf_range(1.4, 3.2)
			life_event_clock = life_rng.randf_range(8.0, 15.0)
	shrine_pulse = maxf(0.0, shrine_pulse - delta)
	cache_pulse = maxf(0.0, cache_pulse - delta)
	if speech_visible_timer > 0.0:
		speech_visible_timer -= delta
		if speech_visible_timer <= 0.0 and speech_panel != null:
			speech_panel.visible = false
			speech_timer = 8.0 + fmod(scene_time, 5.0)
	for spark in ui_sparks:
		spark.life -= delta
		spark.pos += spark.vel * delta
		spark.vel *= 0.94
	for index in range(ui_sparks.size() - 1, -1, -1):
		if ui_sparks[index].life <= 0.0:
			ui_sparks.remove_at(index)
	if visible:
		queue_redraw()

func _draw() -> void:
	var background := background_for_screen()
	var texture_size := background.get_size()
	var crop_height := texture_size.x * 854.0 / 480.0
	var source := Rect2(0, maxf(0.0, (texture_size.y - crop_height) * 0.5), texture_size.x, minf(texture_size.y, crop_height))
	if get_parent().responsive_backdrop == null: draw_texture_rect_region(background, Rect2(0, 0, 480, 854), source)
	var veil := Color("#07102724")
	if current_screen == "shop": veil = Color("#21100620")
	elif current_screen == "stash": veil = Color("#06132a30")
	elif current_screen == "upgrades": veil = Color("#160a2a26")
	elif current_screen == "coming": veil = Color("#10172b56")
	draw_rect(Rect2(0, 0, 480, 854), veil, true)
	draw_rect(Rect2(0, 0, 480, 56 if current_screen=="home" else 74), Color("#080e24b0"), true)
	draw_rect(Rect2(0, 0, 480, 5), Color("#d4a856"), true)

	match current_screen:
		"home": draw_home_scene()
		"shop": draw_shop_scene()
		"stash": draw_stash_scene()
		"upgrades": draw_shrine_scene()
		"coming": draw_archive_scene()
		"achievements", "lore": draw_archive_scene()
	draw_ui_sparks()

func background_for_screen() -> Texture2D:
	if current_screen=="lore" and lore_art!=null and lore_landscape_backing.visible and lore_art.texture!=null:return lore_art.texture
	match current_screen:
		"campaign", "contracts": return BetaArt.MARKET
		"forge": return BetaArt.GEARWORKS
		"workshop": return BetaArt.ARCHIVE if phase4_mode=="archive" else BetaArt.GEARWORKS if phase4_mode=="blueprints" else BetaArt.MARKET
		"lore", "memories", "achievements": return BetaArt.ARCHIVE
		# The old stall painting bakes the superseded goblin Patch identity.
		# Reuse the current public Hub setting and the approved Patch station panel.
		"shop": return HIDEOUT_BACKGROUND
		"stash": return STASH_BACKGROUND
		"upgrades": return SHRINE_BACKGROUND
	return HIDEOUT_BACKGROUND

func draw_home_scene() -> void:
	# Canonical resident mascot, gently breathing in the painted Hideout.
	var bob := 0.0 # Feet stay planted; only the torso breathes.
	var breathe := 1.0 if get_parent().audio_settings.get("cinematic_reduced_motion",false) else 1.0 + sin(scene_time * 1.65) * 0.003
	draw_hideout_light(Vector2(179, 244), 20.0, 0.040, 0.0)
	draw_hideout_light(Vector2(302, 244), 20.0, 0.040, 1.3)
	draw_hideout_light(Vector2(442, 169), 17.0, 0.030, 2.1)
	# Accents live on the painted locations, rather than covering them with a menu.
	# Original approved prop pixels occupy existing destination hotspots. No new
	# identity, touch node, station system or generated replacement silhouette.
	LootlingsUI.draw_icon(get_canvas_item(),HOME_GATE_ART,Rect2(153,106,174,158))
	LootlingsUI.draw_icon(get_canvas_item(),HOME_SHRINE_ART,Rect2(8,210,80,112))
	# Contact shadows sit on the station floor, not around the image rectangle.
	for station in [[Vector2(405,444),46.0],[Vector2(71,707),52.0],[Vector2(403,721),29.0]]:
		draw_set_transform(station[0],0,Vector2(1,.18));draw_circle(Vector2.ZERO,station[1],Color("#03061280"));draw_set_transform(Vector2.ZERO)
	LootlingsUI.draw_icon(get_canvas_item(),preload("res://bible_runtime_art.gd").texture("merchant_cart","props"),Rect2(350,338,110,116))
	LootlingsUI.draw_icon(get_canvas_item(),preload("res://bible_runtime_art.gd").texture("forge_station","props"),Rect2(10,642,126,76))
	var gate_light:=Color("#87cbff"); gate_light.a=.10+sin(scene_time*1.7)*.025
	draw_arc(Vector2(240,179),63,-PI,0,32,gate_light,4,true)
	for rune in range(5):
		var point:=Vector2(240,182)+Vector2.RIGHT.rotated(PI+rune*PI/4)*63
		draw_circle(point,3,Color(.55,.8,1,.26+maxf(0,sin(scene_time*2-rune))*.16))
	draw_home_board()
	draw_set_transform(Vector2(240, 491 + bob), 0.0, Vector2(1.0, 0.18))
	draw_circle(Vector2.ZERO, 52, Color("#03061280"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_set_transform(Vector2(240, 491), sin(scene_time * 1.15) * 0.006, Vector2(1.0, breathe))
	var grounded_actor: Texture2D = Avatar.grounded_texture(actor_texture())
	var actor_extent: Vector2 = grounded_actor.get_size() * minf(144.0 / grounded_actor.get_width(), 144.0 / grounded_actor.get_height())
	draw_texture_rect(grounded_actor, Rect2(Vector2(-actor_extent.x*.5,-actor_extent.y),actor_extent), false, actor_tint())
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var core_pulse := 0.07 + maxf(0.0, sin(scene_time * 2.6)) * 0.07
	draw_circle(Vector2(253, 435), 10.0 + sin(scene_time * 2.6), Color(0.78, 0.55, 1.0, core_pulse))
	for index in range(6):
		var drift := fmod(scene_time * (8.0 + index) + index * 29.0, 150.0)
		draw_circle(Vector2(178 + index * 26, 640 - drift), 1.5 + (index % 2), Color(1.0, 0.78, 0.36, 0.25))
	# Rare bounded micro-events prevent the Hideout from reading as a static
	# painting without creating autonomous nodes or permanent particle systems.
	if life_event_time > 0.0:
		var event_phase := life_event_time
		match life_event:
			"critter":
				var critter_x := 44.0 + fmod((3.2 - event_phase) * 86.0, 126.0)
				draw_circle(Vector2(critter_x, 665), 8.0, Color("#17233cc9"))
				draw_colored_polygon(PackedVector2Array([Vector2(critter_x - 7, 660), Vector2(critter_x - 3, 650), Vector2(critter_x + 1, 660)]), Color("#17233cc9"))
				draw_circle(Vector2(critter_x + 3, 663), 1.5, Color("#ffe178"))
			"coin":
				var coin_x := 310.0 + minf(1.0, 3.2 - event_phase) * 52.0
				draw_circle(Vector2(coin_x, 668 + absf(sin(scene_time * 9.0)) * -7.0), 5.0, Color("#ffd468"), false, 2.0)
			"chest":
				var twitch := sin(scene_time * 18.0) * 2.5
				LootlingsUI.draw_icon(get_canvas_item(),preload("res://art/sprites/rewards/scavenged_chest_beta.png"),Rect2(35+twitch,603,46,40))
			"motes":
				for mote_index in range(5):
					var mote_pos := Vector2(78 + mote_index * 9, 514 - fmod(scene_time * (10.0 + mote_index), 42.0))
					draw_circle(mote_pos, 2.0, Color(0.78, 0.55, 1.0, 0.48))
	draw_resident("Relic Keeper", RESIDENT_RECTS["Relic Keeper"], "SERA", 1.0)
	# Exact authored bodies stand beside their established service stations.
	# Portraits remain the approved dialogue/memory illustrations.
	if preload("res://resident_art_catalog.gd").has_body("Salvager"):
		draw_resident("Salvager",Rect2(337,338,74,128),"PATCH",.4)
	if preload("res://resident_art_catalog.gd").has_body("Archivist"):
		draw_resident("Archivist",Rect2(340,537,74,112),"ILEX",1.8)
	var engine_art:=preload("res://art/production/phase4e/props/trophy_dais.png")
	LootlingsUI.draw_icon(get_canvas_item(),engine_art,Rect2(372,665,62,65))
	draw_hideout_light(Vector2(403,689),15,.055,1.7)
	draw_home_workstations()
	companion_presenter.draw_world(self,preload("res://companion_catalog.gd").sanitize(profile.get("companion",{})),get_parent().audio_settings.get("cinematic_reduced_motion",false))

func draw_home_board() -> void:
	# Accepted painted contract banner replaces the flat board/paper prototype.
	LootlingsUI.draw_icon(get_canvas_item(),preload("res://art/production/phase4e/props/contract_banner.png"),Rect2(374,174,50,96))

func draw_home_workstations() -> void:
	# Foreground furniture grounds the residents. The canonical painting remains
	# the room; these bounded accents add work, not a new homestead subsystem.
	# Existing painted counters/books remain the furniture. Detached prototype
	# tools/page blocks cannot be attached to a different full-body idle export.
	# Work/contact animation awaits the exact canonical activity layers.
	draw_hideout_light(Vector2(404,631),13,.04,1.1)
	# Bounded forge embers and merchant lantern flicker belong to their stations.
	if not get_parent().audio_settings.get("cinematic_reduced_motion",false):
		for spark in range(4):
			var rise:=fmod(scene_time*(8+spark)+spark*11,32.0)
			draw_circle(Vector2(65+sin(scene_time+spark)*9,671-rise),.8,Color(1,.55,.15,(1-rise/32.0)*.4))
	draw_hideout_light(Vector2(384,376),12,.025,2.4)
	var shrine_pulse:=.08+maxf(0,sin(scene_time*1.6))*.06
	draw_circle(Vector2(66,372),16,Color(.64,.51,1,shrine_pulse))

func resident_activity(speaker: String) -> String:
	if speech_panel!=null and speech_panel.visible and speech_speaker==speaker: return "talk"
	var index: int=["Salvager","Relic Keeper","Archivist"].find(speaker)
	if index<0: return "stand"
	var state: int=int((scene_time+index*11)/28.0)%5
	return {"Salvager":["repair","inspect","walk","sit","stand"],"Relic Keeper":["tend","sit","walk","stand","inspect"],"Archivist":["read","inspect","walk","sit","read"]}[speaker][state]

func draw_resident(speaker: String, rect: Rect2, name: String, phase: float) -> void:
	var activity:=resident_activity(speaker)
	# Route frames remain missing: keep actors grounded at their real interaction zones.
	# Until authored seated/work layers arrive, show the established idle body.
	# Activity routes and dialogue remain live; no fake body deformation.

	if speaker not in ["Salvager","Archivist"] or preload("res://resident_art_catalog.gd").has_body(speaker):
		draw_set_transform(Vector2(rect.get_center().x,rect.end.y-3),0,Vector2(1,.22))
		draw_circle(Vector2.ZERO,rect.size.x*.28,Color("#03061270"))
	preload("res://resident_art_catalog.gd").draw(self,speaker,rect,activity,resident_facing)

func draw_shop_scene() -> void:
	# Exact canonical visitor layered separately from the illustrated NPC merchant.
	draw_hideout_light(Vector2(39, 160), 18.0, 0.035, 0.4)
	draw_hideout_light(Vector2(443, 145), 20.0, 0.035, 2.2)
	# Approved identity art is deliberately framed, never passed off as a body.
	var plaque := Rect2(330,90,112,102)
	draw_style_box(LootlingsUI.material_style("leather"),plaque)
	LootlingsUI.draw_icon(get_canvas_item(),RESIDENT_PORTRAITS.Salvager,Rect2(340,96,92,72))
	draw_string(ThemeDB.fallback_font,Vector2(338,182),"PATCH · SHOP",HORIZONTAL_ALIGNMENT_CENTER,96,11,Color("#ffe3ac"))
	if current_shop != null:
		for index in range(mini(3, current_shop.stock.size())):
			if current_shop.stock[index].is_empty():
				var center := Vector2(88 + index * 147, 256)
				draw_line(center + Vector2(-34, -22), center + Vector2(34, 22), Color("#714a50aa"), 5)
				draw_line(center + Vector2(-34, 22), center + Vector2(34, -22), Color("#714a50aa"), 5)
	if cache_pulse > 0.0:
		var ratio := cache_pulse / cache_pulse_duration
		var pulse_color := cache_pulse_color
		pulse_color.a = ratio * 0.75
		draw_arc(Vector2(125, 562), 34.0 + (1.0 - ratio) * 34.0, 0.0, TAU, 28, pulse_color, 4.0)

func draw_stash_scene() -> void:
	draw_hideout_light(Vector2(58, 177), 18.0, 0.030, 0.2)
	draw_hideout_light(Vector2(424, 190), 18.0, 0.030, 1.8)
	var glint_alpha := maxf(0.0, sin(scene_time * 1.8)) * 0.34
	draw_line(Vector2(238, 181), Vector2(250, 181), Color(0.55, 0.84, 1.0, glint_alpha), 1.5)
	draw_line(Vector2(244, 175), Vector2(244, 187), Color(0.55, 0.84, 1.0, glint_alpha), 1.5)

func draw_shrine_scene() -> void:
	draw_hideout_light(Vector2(74, 320), 16.0, 0.028, 0.0)
	draw_hideout_light(Vector2(406, 320), 16.0, 0.028, 1.7)
	var breathe := 1.0 if get_parent().audio_settings.get("cinematic_reduced_motion",false) else 1.0 + sin(scene_time * 1.7) * 0.003
	draw_set_transform(Vector2(109,337),0,Vector2(1,.18))
	draw_circle(Vector2.ZERO,40,Color("#03061288"))
	# Pin the feet to the existing stone terrace; breathing grows upward.
	draw_set_transform(Vector2(109,337),0,Vector2(breathe,breathe))
	draw_texture_rect(actor_texture(), service_body_rect(actor_texture()), false, actor_tint())
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_circle(Vector2(240, 234), 12 + sin(scene_time * 2.4) * 2.0, Color(0.68, 0.42, 1.0, 0.12))
	if shrine_pulse > 0.0:
		var ratio := shrine_pulse / 0.72
		draw_arc(Vector2(315, 252), 28.0 + (1.0 - ratio) * 72.0, 0.0, TAU, 36, Color(0.76, 0.53, 1.0, ratio * 0.82), 5.0)

func draw_hideout_light(position: Vector2, radius: float, base_alpha: float, phase: float) -> void:
	var flicker := base_alpha + maxf(0.0, sin(scene_time * 3.1 + phase)) * base_alpha * 0.55
	draw_circle(position, radius + sin(scene_time * 2.3 + phase) * 1.5, Color(1.0, 0.64, 0.24, flicker))

func draw_archive_scene() -> void:
	# The physical Archive nook remains visible behind the deferred Lootbook notice.
	draw_rect(Rect2(0, 103, 480, 751), Color("#07102738"), true)

func item_name_or_empty(item: Dictionary) -> String:
	return item.get("name", "— Empty —") if not item.is_empty() else "— Empty —"

func make_panel(parent: Node, rect: Rect2, fill: Color, border: Color) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.add_theme_stylebox_override("panel", LootlingsUI.panel_style(fill, border, 18))
	parent.add_child(panel)
	return panel

func make_label(parent: Node, value: String, font_size: int, rect: Rect2, alignment: HorizontalAlignment, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = alignment
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func make_button(parent: Node, value: String, rect: Rect2, fill: Color, border: Color, font_size: int) -> Button:
	var button := Button.new()
	button.set_meta("gesture_release_owned",true)
	button.text = value
	button.position = rect.position
	button.size = Vector2(rect.size.x,maxf(48,rect.size.y))
	button.add_theme_font_size_override("font_size", maxi(13,font_size))
	apply_button_style(button, fill, border)
	parent.add_child(button)
	wire_press_feedback(button)
	return button

func make_hotspot_button(parent: Node, value: String, rect: Rect2, accent: Color, font_size: int) -> Button:
	var button := Button.new()
	button.text = value
	button.position = rect.position
	button.size = Vector2(rect.size.x,maxf(48,rect.size.y))
	button.add_theme_font_size_override("font_size", maxi(13,font_size))
	button.add_theme_color_override("font_color", Color("#f2f6ff"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_outline_color", Color("#050914"))
	button.add_theme_constant_override("outline_size", 2)
	for state_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		var box := StyleBoxFlat.new()
		box.bg_color = Color(0.025, 0.055, 0.12, 0.18 if state_name == "normal" else 0.42)
		if state_name == "hover": box.bg_color = Color(accent.r, accent.g, accent.b, 0.30)
		if state_name == "pressed": box.bg_color = Color(accent.r, accent.g, accent.b, 0.40)
		box.border_color = Color(accent.r, accent.g, accent.b, 0.14 if state_name == "normal" else 0.9)
		box.set_border_width_all(1 if state_name == "normal" else 3)
		box.set_corner_radius_all(18)
		box.shadow_color = Color(accent.r, accent.g, accent.b, 0.10 if state_name == "normal" else 0.22)
		box.shadow_size = 0 if state_name == "normal" else 3
		button.add_theme_stylebox_override(state_name, box)
	parent.add_child(button)
	wire_press_feedback(button)
	return button

func apply_display_button_style(button: Button, border: Color, selected: bool = false) -> void:
	button.set_meta("rarity_accent",border)
	button.set_meta("ui_selected",selected)
	button.set_meta("ui_intent","primary" if selected else "secondary")
	apply_button_style(button, Color("#172442"), border)
	LootlingsUI.apply_rarity_card(button,border)
	if selected:
		button.add_theme_stylebox_override("normal", LootlingsUI.button_style(Color.WHITE, border, "normal","primary"))
	# Focus is an outline only; it must not impersonate a persistent selection.
	var focus:=StyleBoxFlat.new();focus.bg_color=Color.TRANSPARENT;focus.border_color=Color("#d1dff6")
	focus.set_border_width_all(2);focus.set_corner_radius_all(10)
	button.add_theme_stylebox_override("focus",focus)

func apply_sold_display_style(button: Button) -> void:
	apply_button_style(button, Color("#172442"), Color("#716170"))

func wire_press_feedback(button: Button) -> void:
	button.set_meta("presentation_bound", true)
	button.pivot_offset = button.size * 0.5
	button.button_down.connect(animate_press.bind(button))
	button.button_up.connect(animate_release.bind(button))
	button.pressed.connect(func(): ui_event.emit(str(button.get_meta("ui_sound","ui_press"))))

func animate_press(button: Button) -> void:
	button.pivot_offset = button.size * 0.5
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(0.965, 0.965), 0.06).set_trans(Tween.TRANS_QUAD)

func animate_release(button: Button) -> void:
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(1.025, 1.025), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2.ONE, 0.10).set_trans(Tween.TRANS_QUAD)

func pulse_control(control: Control, color: Color) -> void:
	if control == null:
		return
	control.pivot_offset = control.size * 0.5
	control.scale = Vector2(0.96, 0.96)
	control.modulate = color.lightened(0.35)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(control, "scale", Vector2(1.035, 1.035), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(control, "modulate", Color.WHITE, 0.22).set_trans(Tween.TRANS_QUAD)
	tween.chain().tween_property(control, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_QUAD)

func shake_control(control: Control) -> void:
	if control == null:
		return
	control.pivot_offset = control.size * 0.5
	var tween := create_tween()
	for angle in [-0.035, 0.04, -0.025, 0.018, 0.0]:
		tween.tween_property(control, "rotation", angle, 0.045)
	tween.tween_property(control, "scale", Vector2(1.06, 1.06), 0.10).set_trans(Tween.TRANS_BACK)
	tween.tween_property(control, "scale", Vector2.ONE, 0.14)

func spawn_ui_burst(pos: Vector2, color: Color, count: int) -> void:
	for index in range(count):
		var angle := TAU * float(index) / float(count)
		ui_sparks.append({"pos":pos, "vel":Vector2.RIGHT.rotated(angle) * (38.0 + float(index % 4) * 12.0), "color":color, "life":0.42, "max_life":0.42})

func draw_ui_sparks() -> void:
	for spark in ui_sparks:
		var alpha: float = clampf(spark.life / spark.max_life, 0.0, 1.0)
		var color: Color = spark.color
		color.a = alpha * 0.9
		draw_circle(spark.pos, 2.0 + alpha * 2.5, color)

func apply_button_style(button: Button, fill: Color, border: Color) -> void:
	LootlingsUI.apply_button(button, fill, border)

func safe_action(button: Button, consequence: String, action: Callable) -> void:
	get_parent().touch_ux.request(button.text.get_slice("\n",0),button.text+"\n\n"+consequence,action)

func build_home_settings() -> void:
	home_settings_content=Control.new();home_settings_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);home_settings_content.visible=false;add_child(home_settings_content)
	make_button(home_settings_content,"‹ HOME",Rect2(20,20,122,48),Color("#202d4d"),Color("#7f94bc"),16).pressed.connect(func():get_parent().show_personal_home())
	make_label(home_settings_content,"YOUR HOME",24,Rect2(30,92,420,40),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe3ac"))
	var panel:=make_panel(home_settings_content,Rect2(20,148,440,630),Color("#10162ff2"),Color("#8ea2c8"))
	make_label(panel,"Shelf display • free to change",18,Rect2(18,18,404,40),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe3ac"))
	for index in range(4):
		var id: String=["weapon","scroll","trophy","none"][index]
		var button:=make_button(panel,"",Rect2(20,66+index*60,400,52),Color("#202d4d"),Color("#7f94bc"),16)
		home_display_buttons[id]=button;button.pressed.connect(func():choose_home_display(id))
	make_label(panel,"Companion",20,Rect2(18,324,404,36),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe3ac"))
	home_settings_summary=make_label(panel,"",16,Rect2(24,370,392,94),HORIZONTAL_ALIGNMENT_CENTER,Color("#dce6ff"));home_settings_summary.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	var unequip:=make_button(panel,"NO COMPANION",Rect2(20,476,400,52),Color("#202d4d"),Color("#7f94bc"),16);unequip.name="NoCompanion";unequip.pressed.connect(func():choose_companion(""))
	var collection:=make_button(panel,"COMPANION COLLECTION",Rect2(20,548,400,52),Color("#202d4d"),Color("#d7b46d"),16)
	collection.name="CompanionCollection";collection.pressed.connect(show_companion_collection)
	companion_collection_content=Control.new();companion_collection_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);companion_collection_content.visible=false;add_child(companion_collection_content)
	make_button(companion_collection_content,"‹ YOUR HOME",Rect2(20,20,148,48),Color("#202d4d"),Color("#7f94bc"),16).pressed.connect(func():get_parent().personal_home.go_back())
	make_label(companion_collection_content,"COMPANION COLLECTION",23,Rect2(20,100,440,44),HORIZONTAL_ALIGNMENT_CENTER,Color("#ffe3ac"))
	var collection_status:= make_label(companion_collection_content,"Meet the collection • not available yet",15,Rect2(20,146,440,24),HORIZONTAL_ALIGNMENT_CENTER,Color("#dce6ff"));collection_status.name="CollectionStatus"
	companion_follow_button=make_button(companion_collection_content,"",Rect2(20,174,440,48),Color("#202d4d"),Color("#d7b46d"),14)
	companion_follow_button.name="CompanionFollow";companion_follow_button.pressed.connect(toggle_companion_follow)
	var collection_panel:=make_panel(companion_collection_content,Rect2(20,236,440,536),Color("#10162ff2"),Color("#8ea2c8"))
	var scroll:=ScrollContainer.new();scroll.position=Vector2(18,18);scroll.size=Vector2(404,500);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;collection_panel.add_child(scroll)
	var list:=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(list)
	list.add_theme_constant_override("separation",10)
	for id in preload("res://companion_catalog.gd").known_ids():
		var entry: Dictionary=preload("res://companion_catalog.gd").ENTRIES[id]
		var row:=Control.new();row.custom_minimum_size=Vector2(380,126);list.add_child(row)
		var face:=TextureRect.new();face.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;face.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;face.texture=preload("res://companion_catalog.gd").idle_preview(id);face.texture=face.texture if face.texture!=null else preload("res://companion_catalog.gd").preview(id);face.position=Vector2(0,4);face.size=Vector2(76,94);face.mouse_filter=Control.MOUSE_FILTER_IGNORE;row.add_child(face)
		make_label(row,entry.name,20,Rect2(82,2,232,32),HORIZONTAL_ALIGNMENT_LEFT,Color("#ffe3ac"))
		make_label(row,entry.unlock_name,14,Rect2(82,36,232,26),HORIZONTAL_ALIGNMENT_LEFT,Color("#dce6ff"))
		var token:=TextureRect.new();token.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;token.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;token.texture=preload("res://companion_catalog.gd").preview(id,true);token.position=Vector2(322,4);token.size=Vector2(50,58);token.mouse_filter=Control.MOUSE_FILTER_IGNORE;row.add_child(token)
		var b:=make_button(row,"NOT YET AVAILABLE",Rect2(82,72,290,48),Color("#202d4d"),Color("#7f94bc"),14);companion_buttons[id]=b;b.pressed.connect(func():choose_companion(id))

func show_companion_collection() -> void:
	get_parent().show_personal_home("companions")

func show_home_settings() -> void:
	get_parent().show_personal_home("preferences")

func refresh_home_settings() -> void:
	var display: String=profile.get("homestead",{}).get("display","weapon")
	for id in home_display_buttons:
		apply_display_button_style(home_display_buttons[id],Color("#d7b46d"),id==display)
		home_display_buttons[id].text=("CURRENT • " if id==display else "USE • ")+{"weapon":"Equipped weapon","scroll":"Recovered plans","trophy":"Trophy stand","none":"Clear shelf"}[id]
	var companion:=preload("res://companion_catalog.gd").sanitize(profile.get("companion",{}))
	var no_companion: Button=home_settings_content.find_child("NoCompanion",true,false)
	apply_display_button_style(no_companion,Color("#d7b46d"),companion.equipped_id.is_empty())
	home_settings_summary.text="No companion equipped. Companions are cosmetic; they give no combat advantage."
	if preload("res://companion_catalog.gd").available_ids().is_empty():home_settings_summary.text="No companions are available yet. Your slot is ready. Companions never change combat stats."
	elif not companion.equipped_id.is_empty():home_settings_summary.text="Equipped: "+str(preload("res://companion_catalog.gd").ENTRIES[companion.equipped_id].get("name",companion.equipped_id))+" • cosmetic only"
	companion_follow_button.disabled=companion.equipped_id.is_empty()
	companion_follow_button.text="CHOOSE A COMPANION FIRST" if companion.equipped_id.is_empty() else "FOLLOWING YOU · STAY HOME" if companion.accompany else "STAYING HOME · FOLLOW ME"
	companion_follow_button.set_meta("ui_selected",companion.accompany)
	var ready_ids:=preload("res://companion_catalog.gd").available_ids()
	var collection_status: Label=companion_collection_content.get_node("CollectionStatus")
	collection_status.text="Meet the collection • not available yet" if ready_ids.is_empty() else "%d companions ready • unlock with relics" % ready_ids.size()
	for id in companion_buttons:
		apply_display_button_style(companion_buttons[id],Color("#d7b46d"),companion.equipped_id==id)
		var ready: bool=id in ready_ids
		companion_buttons[id].disabled=not ready or id not in companion.owned_ids
		companion_buttons[id].text="EQUIPPED" if companion.equipped_id==id else "EQUIP" if ready and id in companion.owned_ids else "LOCKED" if ready else "NOT YET AVAILABLE"

func choose_home_display(id: String) -> void:
	if current_screen!="home_settings" or id not in ["weapon","scroll","trophy","none"]:return
	var home: Dictionary=profile.get("homestead",{}).duplicate(true)
	home.display=id
	home=preload("res://home_catalog.gd").sanitize(home,str(profile.get("companion",{}).get("equipped_id","")))
	home.home_layout.placements["home.wall_display"]=null
	home_preferences_requested.emit(home,preload("res://companion_catalog.gd").sanitize(profile.get("companion",{})))

func choose_companion(id: String) -> void:
	if current_screen not in ["home_settings","companion_collection"]:return
	var companion:=preload("res://companion_catalog.gd").sanitize(profile.get("companion",{}))
	if not id.is_empty() and (id not in companion.owned_ids or id not in preload("res://companion_catalog.gd").available_ids()):return
	companion.equipped_id=id;home_preferences_requested.emit(profile.get("homestead",{"display":"weapon"}),companion)

func refresh_selection_styles(list: Control, selected_id: String) -> void:
	for child in list.get_children():
		if child is Button:
			var selected: bool=str(child.get_meta("selection_id",""))==selected_id
			if child.get_meta("paper_selection",false):
				child.set_meta("ui_selected",selected)
				apply_display_button_style(child,Color("#d4ad65"),selected)
			else:apply_display_button_style(child,Color("#d4ad65"),selected)

func restore_phase4_selection() -> void:
	var selected_id: String=str(phase4_selections.get(phase4_mode,""))
	for child in phase4_list.get_children():
		if child is Button and str(child.get_meta("selection_id",""))==selected_id:
			child.pressed.emit()
			return

func toggle_companion_follow() -> void:
	if current_screen!="companion_collection":return
	var next:=preload("res://companion_catalog.gd").sanitize(profile.get("companion",{}))
	if next.equipped_id.is_empty():return
	next.accompany=not next.accompany
	home_preferences_requested.emit(preload("res://home_catalog.gd").sanitize(profile.get("homestead",{}),next.equipped_id),next)
