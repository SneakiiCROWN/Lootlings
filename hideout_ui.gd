extends Control

signal play_requested
signal stash_equip_requested(index: int)
signal stash_scrap_requested(index: int)
signal upgrade_requested
signal shop_offer_requested(index: int)
signal shop_cache_requested
signal shop_expansion_requested
signal shop_reroll_requested

const ItemCatalog = preload("res://item_catalog.gd")
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
var entries: Array = []
var stash_filter := "ALL"
var filter_buttons := {}

var home_content: Control
var stash_content: Control
var upgrade_content: Control
var coming_content: Control
var shop_content: Control
var resource_label: Label
var loadout_label: Label
var stash_title: Label
var stash_list: VBoxContainer
var stash_detail: RichTextLabel
var stash_equip_button: Button
var stash_scrap_button: Button
var upgrade_summary: Label
var upgrade_button: Button
var coming_title: Label
var shop_scrap_label: Label
var shop_offer_buttons: Array[Button] = []
var shop_cache_button: Button
var shop_expansion_button: Button
var shop_reroll_button: Button
var shop_status: RichTextLabel
var shop_detail: RichTextLabel
var shop_buy_button: Button
var selected_entry := -1
var selected_shop_offer := -1
var scene_time := 0.0
var transition_overlay: ColorRect

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	build_home()
	build_stash()
	build_upgrades()
	build_shop()
	build_coming_soon()
	build_transition_overlay()
	set_process(true)

func configure(inventory, shop, shard_count: int, power_level: int, compare: Callable) -> void:
	current_inventory = inventory
	current_shop = shop
	shards = shard_count
	power = power_level
	comparison_callable = compare
	refresh_current_screen()

func show_home() -> void:
	current_screen = "home"
	set_screen(home_content)
	refresh_home()
	queue_redraw()

func show_stash() -> void:
	current_screen = "stash"
	set_screen(stash_content)
	refresh_stash()
	queue_redraw()

func show_upgrades() -> void:
	current_screen = "upgrades"
	set_screen(upgrade_content)
	refresh_upgrades()
	queue_redraw()

func show_shop() -> void:
	current_screen = "shop"
	set_screen(shop_content)
	refresh_shop()
	queue_redraw()

func show_coming_soon(section_name: String) -> void:
	current_screen = "coming"
	coming_title.text = "%s\n\nCOMING SOON\n\nThis wing of the Hideout is still under construction." % section_name
	set_screen(coming_content)
	queue_redraw()

func refresh_current_screen() -> void:
	match current_screen:
		"stash": refresh_stash()
		"upgrades": refresh_upgrades()
		"shop": refresh_shop()
		_: refresh_home()

func set_screen(active: Control) -> void:
	for screen in [home_content, stash_content, upgrade_content, shop_content, coming_content]:
		if screen != null:
			screen.visible = screen == active
	play_transition()

func build_home() -> void:
	home_content = Control.new()
	home_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(home_content)
	make_label(home_content, "LOOTLINGS HIDEOUT", 30, Rect2(20, 20, 440, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	resource_label = make_label(home_content, "", 15, Rect2(38, 66, 404, 32), HORIZONTAL_ALIGNMENT_CENTER, Color("#d9e5ff"))
	var play_button := make_hotspot_button(home_content, "EXPEDITION GATE\nBEGIN RUN", Rect2(140, 118, 200, 92), Color("#ffd468"), 17)
	play_button.pressed.connect(func(): play_requested.emit())
	var upgrades_button := make_hotspot_button(home_content, "RELIC SHRINE\nUPGRADES", Rect2(14, 244, 138, 112), Color("#c99cff"), 15)
	upgrades_button.pressed.connect(show_upgrades)
	var shop_button := make_hotspot_button(home_content, "SALVAGER STALL\nSHOP", Rect2(328, 244, 138, 112), Color("#ffbd69"), 15)
	shop_button.pressed.connect(show_shop)
	var stash_button := make_hotspot_button(home_content, "GEAR CHEST\nSTASH", Rect2(14, 476, 150, 110), Color("#72c8ff"), 15)
	stash_button.pressed.connect(show_stash)
	var lootbook_button := make_hotspot_button(home_content, "ARCHIVE\nLOOTBOOK", Rect2(316, 476, 150, 110), Color("#91a6ce"), 15)
	lootbook_button.pressed.connect(show_coming_soon.bind("LOOTBOOK"))
	var loadout_panel := make_panel(home_content, Rect2(24, 678, 432, 116), Color("#0c1430df"), Color("#c99a4e"))
	make_label(loadout_panel, "EXPEDITION LOADOUT", 15, Rect2(12, 8, 408, 24), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe39a"))
	loadout_label = make_label(loadout_panel, "", 12, Rect2(16, 34, 400, 72), HORIZONTAL_ALIGNMENT_CENTER, Color("#e6edff"))
	loadout_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

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
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(10, 12)
	scroll.size = Vector2(420, 166)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_panel.add_child(scroll)
	stash_list = VBoxContainer.new()
	stash_list.custom_minimum_size = Vector2(402, 0)
	stash_list.add_theme_constant_override("separation", 8)
	scroll.add_child(stash_list)
	var detail_panel := make_panel(stash_content, Rect2(20, 486, 440, 190), Color("#0d1530e8"), Color("#c99a4e"))
	stash_detail = RichTextLabel.new()
	stash_detail.position = Vector2(18, 16)
	stash_detail.size = Vector2(404, 158)
	stash_detail.bbcode_enabled = true
	stash_detail.scroll_active = false
	stash_detail.add_theme_font_size_override("normal_font_size", 15)
	stash_detail.add_theme_color_override("default_color", Color("#e5edff"))
	detail_panel.add_child(stash_detail)
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
	var panel := make_panel(upgrade_content, Rect2(34, 350, 412, 284), Color("#101634e8"), Color("#b78cff"))
	make_label(panel, "PERMANENT POWER", 22, Rect2(20, 18, 372, 36), HORIZONTAL_ALIGNMENT_CENTER, Color("#d8b5ff"))
	upgrade_summary = make_label(panel, "", 17, Rect2(32, 55, 348, 128), HORIZONTAL_ALIGNMENT_CENTER, Color("#e8efff"))
	upgrade_summary.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	upgrade_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	upgrade_button = make_button(panel, "UPGRADE", Rect2(48, 194, 316, 70), Color("#49346b"), Color("#d19cff"), 18)
	upgrade_button.pressed.connect(func(): upgrade_requested.emit())
	make_label(upgrade_content, "Star Shards are persistent. Run Coins reset every run.", 14, Rect2(48, 650, 384, 48), HORIZONTAL_ALIGNMENT_CENTER, Color("#aebde0")).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func build_shop() -> void:
	shop_content = Control.new()
	shop_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shop_content.visible = false
	add_child(shop_content)
	var back := make_button(shop_content, "‹ HIDEOUT", Rect2(20, 20, 122, 48), Color("#202d4d"), Color("#7f94bc"), 16)
	back.pressed.connect(show_home)
	make_label(shop_content, "SALVAGER'S STALL", 27, Rect2(145, 22, 315, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	shop_scrap_label = make_label(shop_content, "", 15, Rect2(150, 65, 310, 28), HORIZONTAL_ALIGNMENT_CENTER, Color("#d9e5ff"))
	for index in range(3):
		var offer_button := make_button(shop_content, "", Rect2(20 + index * 147, 196, 137, 120), Color("#172442e8"), Color("#b7c0ca"), 12)
		offer_button.pressed.connect(select_shop_offer.bind(index))
		shop_offer_buttons.append(offer_button)
	var detail_panel := make_panel(shop_content, Rect2(20, 334, 440, 172), Color("#0d1530f2"), Color("#c99a4e"))
	shop_detail = RichTextLabel.new()
	shop_detail.position = Vector2(16, 12)
	shop_detail.size = Vector2(274, 148)
	shop_detail.bbcode_enabled = true
	shop_detail.scroll_active = false
	shop_detail.add_theme_font_size_override("normal_font_size", 14)
	detail_panel.add_child(shop_detail)
	shop_buy_button = make_button(detail_panel, "SELECT AN OFFER", Rect2(302, 42, 122, 86), Color("#6b4a1e"), Color("#ffd468"), 13)
	shop_buy_button.pressed.connect(request_selected_shop_offer)
	shop_cache_button = make_button(shop_content, "MYSTERY CACHE", Rect2(20, 525, 210, 76), Color("#3f315f"), Color("#c99cff"), 14)
	shop_cache_button.pressed.connect(func(): shop_cache_requested.emit())
	shop_expansion_button = make_button(shop_content, "STASH EXPANSION", Rect2(250, 525, 210, 76), Color("#21455b"), Color("#72c8ff"), 14)
	shop_expansion_button.pressed.connect(func(): shop_expansion_requested.emit())
	shop_reroll_button = make_button(shop_content, "REROLL ONCE", Rect2(93, 615, 294, 50), Color("#34405b"), Color("#91a6ce"), 13)
	shop_reroll_button.pressed.connect(func(): shop_reroll_requested.emit())
	var status_panel := make_panel(shop_content, Rect2(20, 679, 440, 92), Color("#0d1530f2"), Color("#8ea2c8"))
	shop_status = RichTextLabel.new()
	shop_status.position = Vector2(14, 10)
	shop_status.size = Vector2(412, 72)
	shop_status.bbcode_enabled = true
	shop_status.fit_content = false
	shop_status.scroll_active = false
	shop_status.add_theme_font_size_override("normal_font_size", 14)
	shop_status.add_theme_color_override("default_color", Color("#e5edff"))
	status_panel.add_child(shop_status)

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

func refresh_home() -> void:
	if current_inventory == null or resource_label == null:
		return
	resource_label.text = "◆ %d SCRAP       ✦ %d STAR SHARDS       POWER +%d%%" % [current_inventory.scrap, shards, power * 5]
	var weapon: Dictionary = current_inventory.equipped_item("Weapon")
	var armour: Dictionary = current_inventory.equipped_item("Armour")
	var charm: Dictionary = current_inventory.equipped_item("Relic")
	loadout_label.text = "⚔ %s  •  %s FAMILY\n◆ %s  •  ✦ %s\nRELIC CORE  •  NEUTRAL" % [item_name_or_empty(weapon), current_inventory.weapon_family(), item_name_or_empty(armour), item_name_or_empty(charm)]

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
		var button := make_button(stash_list, "%s  •  %s%s\n%s  [%s]" % [marker, slot_icon(item.get("slot", "")), family, item.get("name", "Unknown"), item.get("rarity", "COMMON")], Rect2(0, 0, 402, 64), Color("#172442"), ItemCatalog.rarity_color(item.get("rarity", "COMMON")), 14)
		button.custom_minimum_size = Vector2(402, 64)
		apply_item_thumbnail(button, item)
		button.pressed.connect(select_entry.bind(entry_index))
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
	var entry: Dictionary = entries[entry_index]
	var item: Dictionary = entry.item
	var rarity: String = item.get("rarity", "COMMON")
	var color := ItemCatalog.rarity_color(rarity).to_html(false)
	var header := "[center][font_size=22][color=#%s]%s[/color][/font_size]\n%s  •  %s[/center]\n\n" % [color, item.get("name", "Unknown"), ItemCatalog.display_slot(item.get("slot", "Item")), item.get("family", "GEAR")]
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
	upgrade_summary.text = "CURRENT LEVEL  %d\n\n+%d%% base Damage and Max HP\nfor every future run\n\nSTAR SHARDS  ✦ %d" % [power, power * 5, shards]
	upgrade_button.text = "POWER +5%%\nCOST  ✦ %d" % cost
	upgrade_button.disabled = shards < cost or power >= 100

func refresh_shop() -> void:
	if current_inventory == null or current_shop == null or shop_scrap_label == null:
		return
	shop_scrap_label.text = "◆ %d SCRAP  •  %d / %d STASH" % [current_inventory.scrap, current_inventory.stash.size(), current_inventory.stash_capacity]
	var reveal_pending: bool = not current_shop.pending_cache_item.is_empty()
	for index in range(shop_offer_buttons.size()):
		var button: Button = shop_offer_buttons[index]
		if index >= current_shop.stock.size() or current_shop.stock[index].is_empty():
			button.text = "SOLD OUT\n\nReturns after\nthe next run"
			button.disabled = true
			button.icon = null
			button.alignment = HORIZONTAL_ALIGNMENT_CENTER
			apply_button_style(button, Color("#202432"), Color("#596070"))
			if selected_shop_offer == index:
				selected_shop_offer = -1
			continue
		var item: Dictionary = current_shop.stock[index]
		button.text = "%s\n%s\n[%s]\n◆ %d" % [slot_icon(item.get("slot", "")), item.get("name", "Unknown"), item.get("rarity", "COMMON"), item.get("price", 0)]
		button.disabled = reveal_pending
		apply_display_button_style(button, ItemCatalog.rarity_color(item.get("rarity", "COMMON")))
		apply_item_thumbnail(button, item)
	refresh_shop_detail(reveal_pending)
	var expansion_cost: int = current_shop.expansion_cost(current_inventory.stash_capacity)
	shop_expansion_button.text = "STASH EXPANSION\n%d → %d SLOTS\n◆ %d" % [current_inventory.stash_capacity, current_inventory.next_stash_capacity(), expansion_cost] if expansion_cost > 0 else "STASH EXPANSION\nMAXIMUM 24 SLOTS"
	shop_expansion_button.disabled = expansion_cost <= 0 or current_inventory.scrap < expansion_cost or reveal_pending
	shop_reroll_button.text = "REROLL ONCE  •  ◆ %d" % current_shop.REROLL_COST if not current_shop.rerolled_this_cycle else "REROLL USED THIS RUN"
	shop_reroll_button.disabled = current_shop.rerolled_this_cycle or current_inventory.scrap < current_shop.REROLL_COST or reveal_pending
	if reveal_pending:
		var item: Dictionary = current_shop.pending_cache_item
		var color := ItemCatalog.rarity_color(item.get("rarity", "COMMON")).to_html(false)
		shop_cache_button.text = "CLAIM REVEALED ITEM"
		shop_cache_button.disabled = current_inventory.stash.size() >= current_inventory.stash_capacity
		shop_status.text = "[center][color=#ffe178]MYSTERY CACHE REVEAL[/color]\n[font_size=20][color=#%s]%s[/color][/font_size]\n%s  •  %s\n%s[/center]" % [color, item.get("name", "Unknown"), item.get("rarity", "COMMON"), ItemCatalog.display_slot(item.get("slot", "Item")), ItemCatalog.describe_effects(item)]
	else:
		if current_shop.cache_bought_this_cycle:
			shop_cache_button.text = "CACHE OPENED\nREFRESHES AFTER RUN"
			shop_cache_button.disabled = true
		else:
			shop_cache_button.text = "MYSTERY CACHE\nREVEAL 1 ITEM\n◆ %d" % current_shop.CACHE_COST
			shop_cache_button.disabled = current_inventory.scrap < current_shop.CACHE_COST or current_inventory.stash.size() >= current_inventory.stash_capacity
		if current_inventory.stash.size() >= current_inventory.stash_capacity:
			shop_status.text = "[center][color=#ff9b8f]STASH FULL[/color]\nScrap or equip stored gear to make room.\nNothing will be overwritten.[/center]"
		elif shop_status.text.is_empty() or shop_status.text.contains("MYSTERY CACHE REVEAL") or shop_status.text.contains("STASH FULL"):
			shop_status.text = "[center][color=#ffe39a]Persistent gear • paid with Scrap[/color]\nStock refreshes after a completed run.[/center]"

func refresh_shop_detail(reveal_pending: bool) -> void:
	if selected_shop_offer < 0 or selected_shop_offer >= current_shop.stock.size() or current_shop.stock[selected_shop_offer].is_empty():
		shop_detail.text = "[center][color=#aebde0]Tap a displayed item to inspect it.[/color]\n\nThree pieces recovered for this visit.[/center]"
		shop_buy_button.text = "SELECT\nAN OFFER"
		shop_buy_button.disabled = true
		return
	var item: Dictionary = current_shop.stock[selected_shop_offer]
	var rarity: String = item.get("rarity", "COMMON")
	var color := ItemCatalog.rarity_color(rarity).to_html(false)
	shop_detail.text = "[center][font_size=19][color=#%s]%s[/color][/font_size]\n%s  •  %s[/center]\n%s\n[color=#aebde0]%s[/color]" % [color, item.get("name", "Unknown"), rarity, ItemCatalog.display_slot(item.get("slot", "Item")), item.get("desc", ""), ItemCatalog.describe_effects(item)]
	shop_buy_button.text = "BUY\n◆ %d" % int(item.get("price", 0))
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
	queue_redraw()

func request_selected_shop_offer() -> void:
	if selected_shop_offer >= 0:
		shop_offer_requested.emit(selected_shop_offer)

func slot_icon(slot: String) -> String:
	match slot:
		"Weapon": return "⚔  WEAPON"
		"Armour": return "◆  ARMOUR"
		"Relic": return "✦  CHARM"
		"Rune": return "◈  RUNE"
	return "◇  GEAR"

func weapon_texture_for_item(item: Dictionary) -> Texture2D:
	if item.get("slot", "") != "Weapon":
		return null
	match item.get("family", "VANGUARD"):
		"RANGER": return RANGER_WEAPON_TEXTURE
		"MAGE": return MAGE_WEAPON_TEXTURE
		"ROGUE": return ROGUE_WEAPON_TEXTURE
	return VANGUARD_WEAPON_TEXTURE

func apply_item_thumbnail(button: Button, item: Dictionary) -> void:
	button.icon = weapon_texture_for_item(item)
	button.expand_icon = true
	if button.icon != null:
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_constant_override("icon_max_width", 46)
	else:
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER

func build_transition_overlay() -> void:
	transition_overlay = ColorRect.new()
	transition_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition_overlay.color = Color(0.02, 0.04, 0.10, 0.0)
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(transition_overlay)

func play_transition() -> void:
	if transition_overlay == null:
		return
	transition_overlay.move_to_front()
	transition_overlay.color.a = 0.34
	var tween := create_tween()
	tween.tween_property(transition_overlay, "color:a", 0.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	scene_time += delta
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

func background_for_screen() -> Texture2D:
	match current_screen:
		"shop": return SHOP_BACKGROUND
		"stash": return STASH_BACKGROUND
		"upgrades": return SHRINE_BACKGROUND
	return HIDEOUT_BACKGROUND

func draw_home_scene() -> void:
	# Canonical resident mascot, gently breathing in the painted Hideout.
	var bob := sin(scene_time * 2.0) * 4.0
	draw_set_transform(Vector2(240, 491 + bob), 0.0, Vector2(1.0, 0.26))
	draw_circle(Vector2.ZERO, 71, Color("#03061299"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_texture_rect(MASCOT_TEXTURE, Rect2(151, 333 + bob, 178, 178), false, Color.WHITE)
	for index in range(6):
		var drift := fmod(scene_time * (8.0 + index) + index * 29.0, 150.0)
		draw_circle(Vector2(178 + index * 26, 640 - drift), 1.5 + (index % 2), Color(1.0, 0.78, 0.36, 0.25))

func draw_shop_scene() -> void:
	# Exact canonical visitor layered separately from the illustrated NPC merchant.
	draw_texture_rect(MASCOT_TEXTURE, Rect2(25, 105 + sin(scene_time * 2.0) * 2.0, 96, 96), false, Color.WHITE)

func draw_stash_scene() -> void:
	pass

func draw_shrine_scene() -> void:
	var bob := sin(scene_time * 2.0) * 2.5
	draw_texture_rect(MASCOT_TEXTURE, Rect2(34, 142 + bob, 150, 150), false, Color.WHITE)
	draw_circle(Vector2(240, 234), 12 + sin(scene_time * 2.4) * 2.0, Color(0.68, 0.42, 1.0, 0.12))

func draw_archive_scene() -> void:
	# The physical Archive nook remains visible behind the deferred Lootbook notice.
	draw_rect(Rect2(0, 103, 480, 751), Color("#07102738"), true)

func item_name_or_empty(item: Dictionary) -> String:
	return item.get("name", "— Empty —") if not item.is_empty() else "— Empty —"

func make_panel(parent: Node, rect: Rect2, fill: Color, border: Color) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(2)
	box.set_corner_radius_all(18)
	box.shadow_color = Color(0.01, 0.02, 0.06, 0.55)
	box.shadow_size = 10
	panel.add_theme_stylebox_override("panel", box)
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
		box.bg_color = Color(0.025, 0.055, 0.12, 0.12 if state_name == "normal" else 0.42)
		if state_name == "hover": box.bg_color = Color(accent.r, accent.g, accent.b, 0.30)
		if state_name == "pressed": box.bg_color = Color(accent.r, accent.g, accent.b, 0.40)
		box.border_color = Color(accent.r, accent.g, accent.b, 0.34 if state_name == "normal" else 0.9)
		box.set_border_width_all(1 if state_name == "normal" else 3)
		box.set_corner_radius_all(18)
		box.shadow_color = Color(accent.r, accent.g, accent.b, 0.22)
		box.shadow_size = 10 if state_name == "normal" else 5
		button.add_theme_stylebox_override(state_name, box)
	parent.add_child(button)
	return button

func apply_display_button_style(button: Button, border: Color) -> void:
	for state_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		var box := StyleBoxFlat.new()
		var alpha := 0.50
		if state_name == "hover": alpha = 0.72
		elif state_name == "pressed": alpha = 0.82
		elif state_name == "disabled": alpha = 0.32
		box.bg_color = Color(0.025, 0.055, 0.12, alpha)
		box.border_color = border.darkened(0.45) if state_name == "disabled" else border
		box.set_border_width_all(2 if state_name == "normal" else 3)
		box.set_corner_radius_all(14)
		box.shadow_color = Color(border.r, border.g, border.b, 0.20)
		box.shadow_size = 5
		button.add_theme_stylebox_override(state_name, box)
	button.add_theme_color_override("font_disabled_color", Color("#76819a"))

func apply_button_style(button: Button, fill: Color, border: Color) -> void:
	for state_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		var box := StyleBoxFlat.new()
		box.bg_color = fill.darkened(0.30) if state_name == "disabled" else fill.lightened(0.10) if state_name == "hover" else fill.darkened(0.12) if state_name == "pressed" else fill
		box.border_color = border.darkened(0.45) if state_name == "disabled" else border
		box.set_border_width_all(2)
		box.set_corner_radius_all(14)
		box.shadow_color = Color(0.01, 0.02, 0.06, 0.5)
		box.shadow_size = 7 if state_name == "normal" else 3
		button.add_theme_stylebox_override(state_name, box)
	button.add_theme_color_override("font_disabled_color", Color("#76819a"))
