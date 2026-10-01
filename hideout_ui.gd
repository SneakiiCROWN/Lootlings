extends Control

signal play_requested
signal stash_equip_requested(index: int)
signal stash_scrap_requested(index: int)
signal upgrade_requested
signal shop_offer_requested(index: int)
signal shop_cache_requested
signal shop_gold_cache_requested
signal shop_expansion_requested
signal shop_reroll_requested
signal gold_upgrade_requested(upgrade_id: String)
signal profile_requested
signal title_requested
signal ui_event(event_name: String)
signal destination_visited(destination_id: String)

const ItemCatalog = preload("res://item_catalog.gd")
const ItemIcon = preload("res://item_icon.gd")
const PresentationDirector = preload("res://presentation_director.gd")
const DialogueDirector = preload("res://dialogue_director.gd")
const LootlingsUI = preload("res://lootlings_ui.gd")
const LootlingCatalog = preload("res://lootling_catalog.gd")

func actor_texture() -> Texture2D:
	return LootlingCatalog.runtime_texture(str(profile.get("current_lootling_id", "relic_beast")))

func actor_tint() -> Color:
	return LootlingCatalog.presentation_tint(str(profile.get("current_lootling_id", "relic_beast")))
const AchievementManager = preload("res://achievement_manager.gd")
const MASCOT_TEXTURE = preload("res://art/sprites/relic_beast_base.png")
const HIDEOUT_BACKGROUND = preload("res://art/backgrounds/lootlings_hideout.png")
const SHOP_BACKGROUND = preload("res://art/backgrounds/salvager_shop.png")
const STASH_BACKGROUND = preload("res://art/backgrounds/stash_vault.png")
const SHRINE_BACKGROUND = preload("res://art/backgrounds/relic_shrine.png")
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

var home_content: Control
var stash_content: Control
var upgrade_content: Control
var coming_content: Control
var shop_content: Control
var achievement_content: Control
var achievement_grid: GridContainer
var achievement_detail: RichTextLabel
var achievement_summary: Label
var achievement_filter_buttons: Array[Button] = []
var achievement_filter := "ALL"
var selected_achievement_id := ""
var achievement_manager
var visited_destinations := {}
var resource_label: RichTextLabel
var loadout_label: RichTextLabel
var loadout_panel: Panel
var stash_title: Label
var stash_list: VBoxContainer
var stash_detail: RichTextLabel
var stash_detail_panel: Panel
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
	build_stash()
	build_upgrades()
	build_shop()
	build_achievements()
	build_coming_soon()
	build_dialogue_overlay()
	build_transition_overlay()
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
	current_screen = "home"
	set_screen(home_content)
	refresh_home()
	if not queued_dialogue_context.is_empty():
		request_dialogue(queued_dialogue_context)
		queued_dialogue_context = ""
		queued_dialogue_priority = -1
	elif hideout_visits == 0:
		request_dialogue("first_visit")
	hideout_visits += 1
	visit_destination("home")
	queue_redraw()

func show_stash() -> void:
	dismiss_dialogue()
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
		_: refresh_home()

func set_screen(active: Control) -> void:
	var screens := [home_content, stash_content, upgrade_content, shop_content, achievement_content, coming_content]
	presentation.switch_screen(screens, active, 0.24)
	ui_event.emit("menu_transition")

func build_home() -> void:
	home_content = Control.new()
	home_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(home_content)
	make_label(home_content, "LOOTLINGS HIDEOUT", 26, Rect2(90, 20, 300, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	var profile_button := make_button(home_content, "PROFILE", Rect2(10, 16, 78, 38), Color("#172442c8"), Color("#72c8ff"), 10)
	profile_button.pressed.connect(func(): profile_requested.emit())
	var title_button := make_button(home_content, "TITLE", Rect2(392, 16, 78, 38), Color("#172442c8"), Color("#d1a85a"), 10)
	title_button.pressed.connect(func(): title_requested.emit())
	resource_label = LootlingsUI.rich_label(home_content, Rect2(30, 60, 420, 40), 13, Color("#d9e5ff"))
	var play_button := make_hotspot_button(home_content, "EXPEDITION GATE\nBEGIN RUN", Rect2(140, 118, 200, 92), Color("#ffd468"), 17)
	play_button.pressed.connect(func(): play_requested.emit())
	var upgrades_button := make_hotspot_button(home_content, "RELIC SHRINE\nUPGRADES", Rect2(14, 244, 138, 112), Color("#c99cff"), 15)
	upgrades_button.pressed.connect(show_upgrades)
	var shop_button := make_hotspot_button(home_content, "SALVAGER STALL\nSHOP", Rect2(328, 244, 138, 112), Color("#ffbd69"), 15)
	shop_button.pressed.connect(show_shop)
	var stash_button := make_hotspot_button(home_content, "GEAR CHEST\nSTASH", Rect2(14, 476, 150, 110), Color("#72c8ff"), 15)
	stash_button.pressed.connect(show_stash)
	var lootbook_button := make_hotspot_button(home_content, "ARCHIVE\nLOOTBOOK", Rect2(316, 476, 150, 110), Color("#91a6ce"), 15)
	lootbook_button.text = "ARCHIVE\nTROPHIES"
	lootbook_button.pressed.connect(show_achievements)
	loadout_panel = make_panel(home_content, Rect2(34, 704, 412, 88), Color("#0c1430c9"), Color("#c99a4e"))
	LootlingsUI.apply_material(loadout_panel, "leather", 16)
	make_label(loadout_panel, "EXPEDITION LOADOUT", 13, Rect2(12, 6, 388, 20), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe39a"))
	loadout_label = LootlingsUI.rich_label(loadout_panel, Rect2(14, 27, 384, 54), 11, Color("#e6edff"))
	make_npc_hotspot(home_content, Rect2(354, 382, 72, 82), "Salvager")
	make_npc_hotspot(home_content, Rect2(50, 378, 72, 92), "Relic Keeper")
	make_npc_hotspot(home_content, Rect2(350, 586, 78, 72), "Archivist")
	make_npc_hotspot(home_content, Rect2(204, 382, 76, 102), "Mascot")

func build_stash() -> void:
	stash_content = Control.new()
	stash_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stash_content.visible = false
	add_child(stash_content)
	var back := make_button(stash_content, "‹ HIDEOUT", Rect2(20, 20, 122, 48), Color("#202d4d"), Color("#7f94bc"), 16)
	back.pressed.connect(show_home)
	stash_title = make_label(stash_content, "STASH", 28, Rect2(150, 23, 310, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	var filters := ["ALL", "WEAPON", "ARMOUR", "CHARM", "RUNE"]
	for index in range(filters.size()):
		var filter_name: String = filters[index]
		var filter_button := make_button(stash_content, filter_name, Rect2(20 + index * 89, 78, 84, 40), Color("#1c2948"), Color("#6f89b5"), 11)
		filter_button.pressed.connect(set_stash_filter.bind(filter_name))
		filter_buttons[filter_name] = filter_button
	var scroll_panel := make_panel(stash_content, Rect2(20, 282, 440, 190), Color("#0b1229d6"), Color("#7194c4"))
	LootlingsUI.apply_material(scroll_panel, "leather", 16)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(10, 12)
	scroll.size = Vector2(420, 166)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_panel.add_child(scroll)
	stash_list = VBoxContainer.new()
	stash_list.custom_minimum_size = Vector2(402, 0)
	stash_list.add_theme_constant_override("separation", 8)
	scroll.add_child(stash_list)
	stash_detail_panel = make_panel(stash_content, Rect2(20, 486, 440, 190), Color("#0d1530dc"), Color("#c99a4e"))
	LootlingsUI.apply_material(stash_detail_panel, "leather", 16)
	stash_detail = RichTextLabel.new()
	stash_detail.position = Vector2(18, 16)
	stash_detail.size = Vector2(404, 158)
	stash_detail.bbcode_enabled = true
	stash_detail.scroll_active = false
	stash_detail.add_theme_font_size_override("normal_font_size", 15)
	stash_detail.add_theme_color_override("default_color", Color("#e5edff"))
	stash_detail_panel.add_child(stash_detail)
	stash_equip_button = make_button(stash_content, "EQUIP", Rect2(20, 694, 210, 66), Color("#285c4c"), Color("#69e6b0"), 18)
	stash_equip_button.pressed.connect(request_stash_equip)
	stash_scrap_button = make_button(stash_content, "SCRAP", Rect2(250, 694, 210, 66), Color("#5a3828"), Color("#ffbd69"), 18)
	stash_scrap_button.pressed.connect(request_stash_scrap)

func build_upgrades() -> void:
	upgrade_content = Control.new()
	upgrade_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	upgrade_content.visible = false
	add_child(upgrade_content)
	var back := make_button(upgrade_content, "‹ HIDEOUT", Rect2(20, 20, 122, 48), Color("#202d4d"), Color("#7f94bc"), 16)
	back.pressed.connect(show_home)
	make_label(upgrade_content, "RELIC TRAINING", 29, Rect2(145, 23, 315, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	upgrade_panel = make_panel(upgrade_content, Rect2(48, 354, 384, 202), Color("#101634ce"), Color("#b78cff"))
	LootlingsUI.apply_material(upgrade_panel, "relic")
	LootlingsUI.add_divider(upgrade_panel, Rect2(30, 116, 324, 8), "relic")
	make_label(upgrade_panel, "PERMANENT POWER", 20, Rect2(20, 12, 344, 32), HORIZONTAL_ALIGNMENT_CENTER, Color("#d8b5ff"))
	upgrade_summary = LootlingsUI.rich_label(upgrade_panel, Rect2(28, 40, 328, 68), 14, Color("#e8efff"))
	upgrade_button = make_button(upgrade_panel, "UPGRADE", Rect2(42, 126, 300, 60), Color("#49346b"), Color("#d19cff"), 17)
	upgrade_button.pressed.connect(func(): upgrade_requested.emit())
	var utility_panel := make_panel(upgrade_content, Rect2(30, 576, 420, 216), Color("#0d1530e8"), Color("#d1a85a"))
	LootlingsUI.apply_material(utility_panel, "relic", 18)
	make_label(utility_panel, "HIDEOUT IMPROVEMENTS  •  GOLD", 15, Rect2(12, 8, 396, 24), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	for index in range(3):
		var upgrade_id: String = ["bedroll", "whetstone", "pouch"][index]
		var button := make_button(utility_panel, "", Rect2(14, 38 + index * 55, 392, 48), Color("#25304a"), Color("#d1a85a"), 12)
		button.pressed.connect(request_gold_upgrade.bind(upgrade_id))
		gold_upgrade_buttons[upgrade_id] = button

func request_gold_upgrade(upgrade_id: String) -> void:
	gold_upgrade_requested.emit(upgrade_id)

func build_shop() -> void:
	shop_content = Control.new()
	shop_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shop_content.visible = false
	add_child(shop_content)
	var back := make_button(shop_content, "‹ HIDEOUT", Rect2(20, 20, 122, 48), Color("#202d4d"), Color("#7f94bc"), 16)
	back.pressed.connect(show_home)
	make_label(shop_content, "SALVAGER'S STALL", 27, Rect2(145, 22, 315, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	shop_scrap_label = LootlingsUI.rich_label(shop_content, Rect2(145, 65, 315, 28), 13, Color("#d9e5ff"))
	for index in range(3):
		var offer_button := make_button(shop_content, "", Rect2(20 + index * 147, 196, 137, 120), Color("#172442e8"), Color("#b7c0ca"), 12)
		offer_button.pressed.connect(select_shop_offer.bind(index))
		shop_offer_buttons.append(offer_button)
	shop_detail_panel = make_panel(shop_content, Rect2(20, 344, 440, 158), Color("#0d1530e6"), Color("#c99a4e"))
	LootlingsUI.apply_material(shop_detail_panel, "salvage", 16)
	shop_detail = RichTextLabel.new()
	shop_detail.position = Vector2(16, 12)
	shop_detail.size = Vector2(274, 148)
	shop_detail.bbcode_enabled = true
	shop_detail.scroll_active = false
	shop_detail.add_theme_font_size_override("normal_font_size", 14)
	shop_detail_panel.add_child(shop_detail)
	shop_buy_button = make_button(shop_detail_panel, "SELECT AN OFFER", Rect2(302, 36, 122, 82), Color("#6b4a1e"), Color("#ffd468"), 13)
	shop_buy_button.set_meta("ui_intent", "primary")
	apply_button_style(shop_buy_button, Color("#6b4a1e"), Color("#ffd468"))
	shop_buy_button.pressed.connect(request_selected_shop_offer)
	shop_gold_cache_button = make_button(shop_content, "SCAVENGED CACHE", Rect2(20, 525, 137, 76), Color("#5a3f20"), Color("#ffd36a"), 12)
	shop_gold_cache_button.pressed.connect(func(): shop_gold_cache_requested.emit())
	shop_cache_button = make_button(shop_content, "MYSTERY CACHE", Rect2(171, 525, 137, 76), Color("#3f315f"), Color("#c99cff"), 12)
	shop_cache_button.pressed.connect(func(): shop_cache_requested.emit())
	shop_expansion_button = make_button(shop_content, "STASH EXPANSION", Rect2(322, 525, 138, 76), Color("#21455b"), Color("#72c8ff"), 12)
	shop_expansion_button.pressed.connect(func(): shop_expansion_requested.emit())
	shop_reroll_button = make_button(shop_content, "REROLL ONCE", Rect2(93, 615, 294, 50), Color("#34405b"), Color("#91a6ce"), 13)
	shop_reroll_button.pressed.connect(func(): shop_reroll_requested.emit())
	shop_status_panel = make_panel(shop_content, Rect2(20, 679, 440, 92), Color("#0d1530dc"), Color("#8ea2c8"))
	LootlingsUI.apply_material(shop_status_panel, "salvage", 16)
	LootlingsUI.add_divider(shop_status_panel, Rect2(28, 4, 384, 8), "salvage")
	shop_status = RichTextLabel.new()
	shop_status.position = Vector2(14, 10)
	shop_status.size = Vector2(412, 72)
	shop_status.bbcode_enabled = true
	shop_status.fit_content = false
	shop_status.scroll_active = false
	shop_status.add_theme_font_size_override("normal_font_size", 14)
	shop_status.add_theme_color_override("default_color", Color("#e5edff"))
	shop_status_panel.add_child(shop_status)

func build_coming_soon() -> void:
	coming_content = Control.new()
	coming_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	coming_content.visible = false
	add_child(coming_content)
	var back := make_button(coming_content, "‹ HIDEOUT", Rect2(20, 20, 122, 48), Color("#202d4d"), Color("#7f94bc"), 16)
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
	var back := make_button(achievement_content, "‹ HIDEOUT", Rect2(20, 20, 122, 48), Color("#202d4d"), Color("#7f94bc"), 16)
	back.pressed.connect(show_home)
	make_label(achievement_content, "TROPHY ARCHIVE", 28, Rect2(145, 23, 315, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	achievement_summary = make_label(achievement_content, "", 14, Rect2(46, 75, 388, 28), HORIZONTAL_ALIGNMENT_CENTER, Color("#d7c9ff"))
	var filters := ["ALL", "ADVENTURE", "COMBAT", "LOOT", "OTHER"]
	for index in range(filters.size()):
		var filter_button := make_button(achievement_content, filters[index], Rect2(20 + index * 89, 108, 84, 38), Color("#171733d9"), Color("#846cb0"), 10)
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
	achievement_grid.columns = 3
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

func refresh_achievements() -> void:
	if achievement_grid == null:
		return
	for child in achievement_grid.get_children():
		achievement_grid.remove_child(child)
		child.queue_free()
	var unlocked_count: int = int(achievement_manager.unlocked.size()) if achievement_manager != null else 0
	achievement_summary.text = "%d / %d RECOVERED  •  TAP A BADGE FOR DETAILS" % [unlocked_count, AchievementManager.DEFINITIONS.size()]
	for index in range(achievement_filter_buttons.size()):
		achievement_filter_buttons[index].disabled = achievement_filter_buttons[index].text == achievement_filter
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
		var card := make_button(achievement_grid, "\n\n%s\n%s" % [title, progress_text], Rect2(0, 0, 127, 112), Color("#392b34") if unlocked else Color("#131a32"), Color("#ffd36a") if unlocked else Color("#58698f"), 11)
		LootlingsUI.add_icon(card, Rect2(43, 8, 40, 40), trophy_texture_path(entry, unlocked, secret))
		card.custom_minimum_size = Vector2(127, 112)
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
	resource_label.text = "[center]%s  •  %s %d GOLD\n%s %d SCRAP   %s %d SHARDS   POWER +%d%%[/center]" % [display_name.replace("[", "[lb]"), LootlingsUI.inline_icon("currency_gold"), gold, LootlingsUI.inline_icon("currency_scrap"), current_inventory.scrap, LootlingsUI.inline_icon("currency_star_shard"), shards, power * 5]
	if scrap_changed and current_screen == "home":
		pulse_control(resource_label, Color("#9fddff"))
	var weapon: Dictionary = current_inventory.equipped_item("Weapon")
	var armour: Dictionary = current_inventory.equipped_item("Armour")
	var charm: Dictionary = current_inventory.equipped_item("Relic")
	loadout_label.text = "[center]%s • %s  %s %s\n%s %s  %s NEUTRAL CORE[/center]" % [item_name_or_empty(weapon), current_inventory.weapon_family(), LootlingsUI.inline_icon("gear_armour", 14), item_name_or_empty(armour), LootlingsUI.inline_icon("gear_charm", 14), item_name_or_empty(charm), LootlingsUI.inline_icon("core_neutral", 14)]

func refresh_stash() -> void:
	if current_inventory == null or stash_list == null:
		return
	stash_title.text = "STASH  •  %d / %d STORED" % [current_inventory.stash.size(), current_inventory.stash_capacity]
	for filter_name in filter_buttons:
		var filter_button: Button = filter_buttons[filter_name]
		filter_button.disabled = filter_name == stash_filter
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
		button.custom_minimum_size = Vector2(402, 68)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.clip_text = true
		apply_item_thumbnail(button, item)
		button.pressed.connect(select_entry.bind(entry_index))
	var bottom_padding := Control.new()
	bottom_padding.custom_minimum_size = Vector2(402, 16)
	stash_list.add_child(bottom_padding)
	if entries.is_empty():
		stash_detail.text = "[center][color=#8fa4ce]No %s equipment found.[/color][/center]" % stash_filter.to_lower()
		stash_equip_button.disabled = true
		stash_scrap_button.disabled = true
	else:
		select_entry(clampi(selected_entry, 0, entries.size() - 1))

func select_entry(entry_index: int) -> void:
	if entry_index < 0 or entry_index >= entries.size():
		return
	selected_entry = entry_index
	if entry_index < stash_list.get_child_count():
		pulse_control(stash_list.get_child(entry_index), Color("#72c8ff"))
	var entry: Dictionary = entries[entry_index]
	var item: Dictionary = entry.item
	var rarity: String = item.get("rarity", "COMMON")
	var color := ItemCatalog.rarity_color(rarity).to_html(false)
	var header := "[center][font_size=22][color=#%s]%s[/color][/font_size]\n%s[/center]\n\n" % [color, item.get("name", "Unknown"), ItemCatalog.display_identity(item)]
	if entry.equipped:
		stash_detail.text = header + "[center][color=#69e6b0]CURRENTLY EQUIPPED[/color]\n%s\n\n%s[/center]" % [item.get("desc", ""), ItemCatalog.describe_effects(item)]
		stash_equip_button.disabled = true
		stash_scrap_button.disabled = true
		stash_equip_button.text = "EQUIPPED"
		stash_scrap_button.text = "SCRAP"
	else:
		var equipped: Dictionary = current_inventory.equipped_item(item.get("slot", ""))
		stash_detail.text = header + comparison_callable.call(item, equipped)
		stash_equip_button.disabled = false
		stash_scrap_button.disabled = false
		stash_equip_button.text = "EQUIP"
		stash_scrap_button.text = "SCRAP  +%d" % ItemCatalog.scrap_value(item)

func refresh_upgrades() -> void:
	if upgrade_summary == null:
		return
	var cost := 10 + power * 5
	upgrade_summary.text = "[center]LEVEL %d  •  TOTAL +%d%%\nDamage + Max HP every run\n%s %d STAR SHARDS[/center]" % [power, power * 5, LootlingsUI.inline_icon("currency_star_shard"), shards]
	upgrade_button.text = "POWER +5%%\nCOST %d SHARDS" % cost
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
			button.text = "%s  •  RANK %d/5\n%s     %d GOLD" % [data[0], rank, data[1], price]
			button.icon = LootlingsUI.icon("currency_gold")
			button.expand_icon = true
			button.add_theme_constant_override("icon_max_width", 18)
			button.disabled = gold < price

func refresh_shop() -> void:
	if current_inventory == null or current_shop == null or shop_scrap_label == null:
		return
	shop_scrap_label.text = "[center]%s %d GOLD • %s %d SCRAP • %d/%d STASH[/center]" % [LootlingsUI.inline_icon("currency_gold"), gold, LootlingsUI.inline_icon("currency_scrap"), current_inventory.scrap, current_inventory.stash.size(), current_inventory.stash_capacity]
	var reveal_pending: bool = not current_shop.pending_cache_item.is_empty()
	shop_gold_cache_button.text = "SCAVENGED CACHE\n%d GOLD" % current_shop.GOLD_CACHE_COST
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
		button.text = "\n\n%s\n[%s]  %d SCRAP" % [item.get("name", "Unknown"), item.get("rarity", "COMMON"), item.get("price", 0)]
		button.add_theme_font_size_override("font_size", 10 if str(item.get("name", "")).length() > 18 else 11)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.disabled = reveal_pending
		apply_display_button_style(button, ItemCatalog.rarity_color(item.get("rarity", "COMMON")), selected_shop_offer == index)
		apply_item_thumbnail(button, item, true)
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
			shop_status.text = "[center][color=#ffe39a]Persistent gear • paid with Scrap[/color]\nStock refreshes after a completed run.[/center]"

func refresh_shop_detail(reveal_pending: bool) -> void:
	if selected_shop_offer < 0 or selected_shop_offer >= current_shop.stock.size() or current_shop.stock[selected_shop_offer].is_empty():
		shop_detail_panel.visible = false
		shop_detail.text = ""
		shop_buy_button.text = "SELECT\nAN OFFER"
		shop_buy_button.disabled = true
		return
	shop_detail_panel.visible = true
	var item: Dictionary = current_shop.stock[selected_shop_offer]
	var rarity: String = item.get("rarity", "COMMON")
	var color := ItemCatalog.rarity_color(rarity).to_html(false)
	shop_detail.text = "[center][font_size=19][color=#%s]%s[/color][/font_size]\n%s  •  %s[/center]\n%s\n[color=#aebde0]%s[/color]" % [color, item.get("name", "Unknown"), rarity, ItemCatalog.display_slot(item.get("slot", "Item")), item.get("desc", ""), ItemCatalog.describe_effects(item)]
	shop_buy_button.text = "BUY\n%d SCRAP" % int(item.get("price", 0))
	shop_buy_button.disabled = reveal_pending or current_inventory.scrap < int(item.get("price", 0)) or current_inventory.stash.size() >= current_inventory.stash_capacity

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
	if selected_entry < 0 or selected_entry >= entries.size():
		return
	var entry: Dictionary = entries[selected_entry]
	if not entry.equipped:
		stash_equip_requested.emit(int(entry.stash_index))

func request_stash_scrap() -> void:
	if selected_entry < 0 or selected_entry >= entries.size():
		return
	var entry: Dictionary = entries[selected_entry]
	if not entry.equipped:
		stash_scrap_requested.emit(int(entry.stash_index))

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
		shop_offer_requested.emit(selected_shop_offer)

func play_shop_purchase(index: int, rarity_color: Color) -> void:
	if index >= 0 and index < shop_offer_buttons.size():
		pulse_control(shop_offer_buttons[index], rarity_color)
		spawn_ui_burst(Vector2(88 + index * 147, 258), rarity_color, 12)
	pulse_control(shop_scrap_label, Color("#9fddff"))

func play_cache_reveal(rarity_color: Color, reveal_profile: Dictionary = {}) -> void:
	cache_pulse_duration = maxf(0.34, float(reveal_profile.get("anticipation", 0.52)) + 0.28)
	cache_pulse = cache_pulse_duration
	cache_pulse_color = rarity_color
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
	match item.get("family", "VANGUARD"):
		"RANGER": return RANGER_WEAPON_TEXTURE
		"MAGE": return MAGE_WEAPON_TEXTURE
		"ROGUE": return ROGUE_WEAPON_TEXTURE
	return VANGUARD_WEAPON_TEXTURE

func apply_item_thumbnail(button: Button, item: Dictionary, card_layout: bool = false) -> void:
	var old_badge := button.get_node_or_null("RarityBadge")
	if old_badge != null:
		button.remove_child(old_badge)
		old_badge.queue_free()
	var old_icon := button.get_node_or_null("CategoryIcon")
	if old_icon != null:
		old_icon.queue_free()
	button.icon = null if card_layout else weapon_texture_for_item(item)
	button.expand_icon = true
	if button.icon != null:
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_constant_override("icon_max_width", 46)
	else:
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER if card_layout else HORIZONTAL_ALIGNMENT_RIGHT
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
			category_icon.position = Vector2((button.size.x - 42.0) * 0.5, 5) if card_layout else Vector2(4, maxf(4.0, (button.size.y - 40.0) * 0.5))
			category_icon.size = Vector2(42, 42) if card_layout else Vector2(40, 40)
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

func build_transition_overlay() -> void:
	presentation = PresentationDirector.new()
	add_child(presentation)

func build_dialogue_overlay() -> void:
	speech_panel = make_panel(self, Rect2(128, 560, 224, 76), Color("#10182bf2"), Color("#d8bd7b"))
	speech_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	speech_panel.visible = false
	speech_panel.z_index = 80
	speech_label = make_label(speech_panel, "", 12, Rect2(12, 7, 200, 62), HORIZONTAL_ALIGNMENT_CENTER, Color("#f3edda"))
	speech_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	speech_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	speech_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func make_npc_hotspot(parent: Control, rect: Rect2, speaker: String) -> void:
	var hotspot := Button.new()
	hotspot.position = rect.position
	hotspot.size = rect.size
	hotspot.flat = true
	hotspot.focus_mode = Control.FOCUS_NONE
	hotspot.tooltip_text = "Talk to %s" % speaker
	hotspot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hotspot.pressed.connect(request_dialogue.bind("tapped", speaker))
	parent.add_child(hotspot)

func queue_dialogue_context(context: String) -> void:
	var priorities := {"returning":1, "early_defeat":2, "victory":3, "epic_find":4, "boss_defeated":5, "legendary_find":6, "large_hoard":5}
	var priority := int(priorities.get(context, 1))
	if priority < queued_dialogue_priority:
		return
	queued_dialogue_context = context
	queued_dialogue_priority = priority
	speech_visible_timer = 0.0
	if speech_panel != null:
		speech_panel.visible = false

func request_dialogue(context: String = "idle", requested_speaker: String = "") -> void:
	if dialogue == null or speech_panel == null or speech_visible_timer > 0.0:
		return
	var entry: Dictionary = dialogue.choose(context, requested_speaker)
	if entry.is_empty():
		return
	var speaker := str(entry.speaker)
	speech_label.text = "%s\n%s" % [speaker.to_upper(), str(entry.text)]
	speech_panel.position = dialogue_anchor(speaker)
	speech_panel.visible = true
	speech_panel.modulate = Color(1, 1, 1, 0)
	speech_panel.scale = Vector2(0.96, 0.96)
	speech_panel.pivot_offset = speech_panel.size * 0.5
	var tween := create_tween().set_parallel(true)
	tween.tween_property(speech_panel, "modulate", Color.WHITE, 0.16)
	tween.tween_property(speech_panel, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	speech_visible_timer = 3.4

func dialogue_anchor(speaker: String) -> Vector2:
	if current_screen == "shop":
		return Vector2(222, 116) if speaker == "Salvager" else Vector2(126, 166)
	if current_screen == "upgrades":
		return Vector2(226, 264) if speaker == "Relic Keeper" else Vector2(126, 270)
	if current_screen == "stash":
		return Vector2(126, 188)
	match speaker:
		"Salvager": return Vector2(238, 326)
		"Relic Keeper": return Vector2(18, 326)
		"Archivist": return Vector2(236, 520)
		_: return Vector2(128, 500)

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
	elif current_screen == "home":
		speech_timer -= delta
		if speech_timer <= 0.0 and speech_panel != null:
			request_dialogue("rare" if dialogue.rng.randf() < 0.08 else "idle")
			if speech_visible_timer <= 0.0:
				speech_timer = 2.0
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
	draw_rect(Rect2(0, 0, 480, 854), Color("#070c1d"))
	var background := background_for_screen()
	var texture_size := background.get_size()
	var crop_height := texture_size.x * 854.0 / 480.0
	var source := Rect2(0, maxf(0.0, (texture_size.y - crop_height) * 0.5), texture_size.x, minf(texture_size.y, crop_height))
	draw_texture_rect_region(background, Rect2(0, 0, 480, 854), source)
	var veil := Color("#07102724")
	if current_screen == "shop": veil = Color("#21100620")
	elif current_screen == "stash": veil = Color("#06132a30")
	elif current_screen == "upgrades": veil = Color("#160a2a26")
	elif current_screen == "coming": veil = Color("#10172b56")
	draw_rect(Rect2(0, 0, 480, 854), veil, true)
	draw_rect(Rect2(0, 0, 480, 102), Color("#080e24d8"), true)
	draw_rect(Rect2(0, 0, 480, 5), Color("#d4a856"), true)
	draw_rect(Rect2(0, 101, 480, 2), Color("#ad8040"), true)
	match current_screen:
		"home": draw_home_scene()
		"shop": draw_shop_scene()
		"stash": draw_stash_scene()
		"upgrades": draw_shrine_scene()
		"coming": draw_archive_scene()
		"achievements": draw_archive_scene()
	draw_ui_sparks()

func background_for_screen() -> Texture2D:
	match current_screen:
		"shop": return SHOP_BACKGROUND
		"stash": return STASH_BACKGROUND
		"upgrades": return SHRINE_BACKGROUND
	return HIDEOUT_BACKGROUND

func draw_home_scene() -> void:
	# Canonical resident mascot, gently breathing in the painted Hideout.
	var bob := sin(scene_time * 2.0) * 4.0
	var breathe := 1.0 + sin(scene_time * 1.65) * 0.010
	draw_hideout_light(Vector2(179, 244), 20.0, 0.040, 0.0)
	draw_hideout_light(Vector2(302, 244), 20.0, 0.040, 1.3)
	draw_hideout_light(Vector2(442, 169), 17.0, 0.030, 2.1)
	draw_set_transform(Vector2(240, 491 + bob), 0.0, Vector2(1.0, 0.26))
	draw_circle(Vector2.ZERO, 71, Color("#03061299"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_set_transform(Vector2(240, 422 + bob), sin(scene_time * 1.15) * 0.006, Vector2(breathe, 1.0 / breathe))
	draw_texture_rect(actor_texture(), Rect2(-89, -89, 178, 178), false, actor_tint())
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var core_pulse := 0.07 + maxf(0.0, sin(scene_time * 2.6)) * 0.07
	draw_circle(Vector2(256, 425 + bob), 10.0 + sin(scene_time * 2.6), Color(0.78, 0.55, 1.0, core_pulse))
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
				draw_rect(Rect2(38 + twitch, 612, 38, 27), Color("#704328"), true)
				draw_line(Vector2(38 + twitch, 622), Vector2(76 + twitch, 622), Color("#d5a85a"), 3.0)
			"motes":
				for mote_index in range(5):
					var mote_pos := Vector2(78 + mote_index * 9, 514 - fmod(scene_time * (10.0 + mote_index), 42.0))
					draw_circle(mote_pos, 2.0, Color(0.78, 0.55, 1.0, 0.48))
	var salvage_bob := sin(scene_time * 3.1) * 2.0
	draw_circle(Vector2(390, 414 + salvage_bob), 18, Color("#6d7b48"))
	draw_circle(Vector2(383, 408 + salvage_bob), 5, Color("#d9e7b0"))
	draw_circle(Vector2(397, 408 + salvage_bob), 5, Color("#d9e7b0"))
	draw_rect(Rect2(377, 430 + salvage_bob, 27, 25), Color("#8a4f2d"), true)
	draw_line(Vector2(405, 436 + salvage_bob), Vector2(416, 426 + salvage_bob + sin(scene_time * 8.0) * 5.0), Color("#d6b56b"), 4)
	var keeper_bob := sin(scene_time * 1.8 + 1.0) * 1.5
	draw_circle(Vector2(86, 409 + keeper_bob), 19, Color("#493f70"))
	draw_colored_polygon(PackedVector2Array([Vector2(67,426 + keeper_bob),Vector2(105,426 + keeper_bob),Vector2(111,465 + keeper_bob),Vector2(61,465 + keeper_bob)]), Color("#2c294b"))
	draw_circle(Vector2(86, 412 + keeper_bob), 3, Color("#c99cff"))
	var archivist_bob := sin(scene_time * 2.1) * 1.5
	draw_circle(Vector2(390, 610 + archivist_bob), 14, Color("#5a6685"))
	draw_rect(Rect2(370, 625 + archivist_bob, 38, 24), Color("#70422c"), true)
	draw_line(Vector2(389, 625 + archivist_bob), Vector2(389, 649 + archivist_bob), Color("#d8bd7b"), 2)
	if sin(scene_time * 2.6) > 0.92:
		draw_circle(Vector2(414, 620 + archivist_bob), 3, Color("#ffe178"))

func draw_shop_scene() -> void:
	# Exact canonical visitor layered separately from the illustrated NPC merchant.
	draw_hideout_light(Vector2(39, 160), 18.0, 0.035, 0.4)
	draw_hideout_light(Vector2(443, 145), 20.0, 0.035, 2.2)
	var visitor_bob := sin(scene_time * 2.0) * 2.0
	var visitor_breath := 1.0 + sin(scene_time * 1.7) * 0.009
	draw_set_transform(Vector2(73, 153 + visitor_bob), sin(scene_time * 1.2) * 0.005, Vector2(visitor_breath, 1.0 / visitor_breath))
	draw_texture_rect(actor_texture(), Rect2(-48, -48, 96, 96), false, actor_tint())
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
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
	var bob := sin(scene_time * 2.0) * 2.5
	draw_hideout_light(Vector2(74, 320), 16.0, 0.028, 0.0)
	draw_hideout_light(Vector2(406, 320), 16.0, 0.028, 1.7)
	var breathe := 1.0 + sin(scene_time * 1.7) * 0.009
	draw_set_transform(Vector2(109, 217 + bob), sin(scene_time * 1.1) * 0.005, Vector2(breathe, 1.0 / breathe))
	draw_texture_rect(actor_texture(), Rect2(-75, -75, 150, 150), false, actor_tint())
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
	button.text = value
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size", font_size)
	apply_button_style(button, fill, border)
	parent.add_child(button)
	wire_press_feedback(button)
	return button

func make_hotspot_button(parent: Node, value: String, rect: Rect2, accent: Color, font_size: int) -> Button:
	var button := Button.new()
	button.text = value
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color("#f2f6ff"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_outline_color", Color("#050914"))
	button.add_theme_constant_override("outline_size", 6)
	for state_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		var box := StyleBoxFlat.new()
		box.bg_color = Color(0.025, 0.055, 0.12, 0.025 if state_name == "normal" else 0.42)
		if state_name == "hover": box.bg_color = Color(accent.r, accent.g, accent.b, 0.30)
		if state_name == "pressed": box.bg_color = Color(accent.r, accent.g, accent.b, 0.40)
		box.border_color = Color(accent.r, accent.g, accent.b, 0.14 if state_name == "normal" else 0.9)
		box.set_border_width_all(0 if state_name == "normal" else 3)
		box.set_corner_radius_all(18)
		box.shadow_color = Color(accent.r, accent.g, accent.b, 0.10 if state_name == "normal" else 0.22)
		box.shadow_size = 4 if state_name == "normal" else 5
		button.add_theme_stylebox_override(state_name, box)
	parent.add_child(button)
	wire_press_feedback(button)
	return button

func apply_display_button_style(button: Button, border: Color, selected: bool = false) -> void:
	apply_button_style(button, Color("#172442"), border)
	if selected:
		button.add_theme_stylebox_override("normal", LootlingsUI.button_style(Color.WHITE, border, "focus"))

func apply_sold_display_style(button: Button) -> void:
	apply_button_style(button, Color("#172442"), Color("#716170"))

func wire_press_feedback(button: Button) -> void:
	button.set_meta("presentation_bound", true)
	button.pivot_offset = button.size * 0.5
	button.button_down.connect(animate_press.bind(button))
	button.button_up.connect(animate_release.bind(button))
	button.pressed.connect(func(): ui_event.emit("ui_press"))

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
