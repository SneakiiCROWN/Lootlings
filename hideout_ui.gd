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
const BACKGROUND_TEXTURE = preload("res://art/backgrounds/treasure_ruins_arena.png")

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
var selected_entry := -1

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	build_home()
	build_stash()
	build_upgrades()
	build_shop()
	build_coming_soon()

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

func build_home() -> void:
	home_content = Control.new()
	home_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(home_content)
	make_label(home_content, "LOOTLINGS HIDEOUT", 30, Rect2(20, 20, 440, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	resource_label = make_label(home_content, "", 15, Rect2(38, 66, 404, 32), HORIZONTAL_ALIGNMENT_CENTER, Color("#d9e5ff"))
	var loadout_panel := make_panel(home_content, Rect2(226, 113, 234, 218), Color("#0c1430eb"), Color("#c99a4e"))
	make_label(loadout_panel, "CURRENT LOADOUT", 17, Rect2(12, 10, 210, 28), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe39a"))
	loadout_label = make_label(loadout_panel, "", 13, Rect2(16, 48, 202, 152), HORIZONTAL_ALIGNMENT_LEFT, Color("#e6edff"))
	var play_button := make_button(home_content, "PLAY  •  BEGIN RUN", Rect2(24, 355, 432, 72), Color("#6b4a1e"), Color("#ffd468"), 23)
	play_button.pressed.connect(func(): play_requested.emit())
	var stash_button := make_button(home_content, "STASH", Rect2(24, 444, 207, 70), Color("#213b61"), Color("#72c8ff"), 20)
	stash_button.pressed.connect(show_stash)
	var upgrades_button := make_button(home_content, "UPGRADES", Rect2(249, 444, 207, 70), Color("#3f315f"), Color("#c99cff"), 20)
	upgrades_button.pressed.connect(show_upgrades)
	var lootbook_button := make_button(home_content, "LOOTBOOK", Rect2(24, 532, 207, 70), Color("#26344e"), Color("#7185aa"), 18)
	lootbook_button.pressed.connect(show_coming_soon.bind("LOOTBOOK"))
	var shop_button := make_button(home_content, "SHOP", Rect2(249, 532, 207, 70), Color("#26344e"), Color("#7185aa"), 18)
	shop_button.pressed.connect(show_shop)
	make_label(home_content, "Prepare your gear, then brave the 15-wave treasure ruins.", 14, Rect2(35, 622, 410, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#aebde0")).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

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
	var scroll_panel := make_panel(stash_content, Rect2(20, 130, 440, 228), Color("#0b1229ef"), Color("#7194c4"))
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(10, 12)
	scroll.size = Vector2(420, 204)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_panel.add_child(scroll)
	stash_list = VBoxContainer.new()
	stash_list.custom_minimum_size = Vector2(402, 0)
	stash_list.add_theme_constant_override("separation", 8)
	scroll.add_child(stash_list)
	var detail_panel := make_panel(stash_content, Rect2(20, 374, 440, 286), Color("#0d1530f2"), Color("#c99a4e"))
	stash_detail = RichTextLabel.new()
	stash_detail.position = Vector2(18, 16)
	stash_detail.size = Vector2(404, 252)
	stash_detail.bbcode_enabled = true
	stash_detail.scroll_active = false
	stash_detail.add_theme_font_size_override("normal_font_size", 15)
	stash_detail.add_theme_color_override("default_color", Color("#e5edff"))
	detail_panel.add_child(stash_detail)
	stash_equip_button = make_button(stash_content, "EQUIP", Rect2(20, 682, 210, 66), Color("#285c4c"), Color("#69e6b0"), 18)
	stash_equip_button.pressed.connect(request_stash_equip)
	stash_scrap_button = make_button(stash_content, "SCRAP", Rect2(250, 682, 210, 66), Color("#5a3828"), Color("#ffbd69"), 18)
	stash_scrap_button.pressed.connect(request_stash_scrap)

func build_upgrades() -> void:
	upgrade_content = Control.new()
	upgrade_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	upgrade_content.visible = false
	add_child(upgrade_content)
	var back := make_button(upgrade_content, "‹ HIDEOUT", Rect2(20, 20, 122, 48), Color("#202d4d"), Color("#7f94bc"), 16)
	back.pressed.connect(show_home)
	make_label(upgrade_content, "RELIC TRAINING", 29, Rect2(145, 23, 315, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	var panel := make_panel(upgrade_content, Rect2(34, 142, 412, 430), Color("#101634f2"), Color("#b78cff"))
	make_label(panel, "PERMANENT POWER", 23, Rect2(20, 28, 372, 40), HORIZONTAL_ALIGNMENT_CENTER, Color("#d8b5ff"))
	upgrade_summary = make_label(panel, "", 19, Rect2(32, 92, 348, 170), HORIZONTAL_ALIGNMENT_CENTER, Color("#e8efff"))
	upgrade_summary.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	upgrade_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	upgrade_button = make_button(panel, "UPGRADE", Rect2(48, 292, 316, 82), Color("#49346b"), Color("#d19cff"), 19)
	upgrade_button.pressed.connect(func(): upgrade_requested.emit())
	make_label(upgrade_content, "Star Shards are persistent. Run Coins reset every run.", 14, Rect2(48, 598, 384, 48), HORIZONTAL_ALIGNMENT_CENTER, Color("#aebde0")).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func build_shop() -> void:
	shop_content = Control.new()
	shop_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shop_content.visible = false
	add_child(shop_content)
	var back := make_button(shop_content, "‹ HIDEOUT", Rect2(20, 20, 122, 48), Color("#202d4d"), Color("#7f94bc"), 16)
	back.pressed.connect(show_home)
	make_label(shop_content, "SALVAGER'S SHOP", 27, Rect2(145, 22, 315, 42), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	shop_scrap_label = make_label(shop_content, "", 15, Rect2(150, 65, 310, 28), HORIZONTAL_ALIGNMENT_CENTER, Color("#d9e5ff"))
	var offers_panel := make_panel(shop_content, Rect2(20, 101, 440, 300), Color("#0b1229ef"), Color("#c99a4e"))
	for index in range(3):
		var offer_button := make_button(offers_panel, "", Rect2(12, 12 + index * 94, 416, 82), Color("#172442"), Color("#b7c0ca"), 14)
		offer_button.pressed.connect(request_shop_offer.bind(index))
		shop_offer_buttons.append(offer_button)
	shop_cache_button = make_button(shop_content, "MYSTERY CACHE", Rect2(20, 420, 210, 82), Color("#3f315f"), Color("#c99cff"), 15)
	shop_cache_button.pressed.connect(func(): shop_cache_requested.emit())
	shop_expansion_button = make_button(shop_content, "STASH EXPANSION", Rect2(250, 420, 210, 82), Color("#21455b"), Color("#72c8ff"), 15)
	shop_expansion_button.pressed.connect(func(): shop_expansion_requested.emit())
	shop_reroll_button = make_button(shop_content, "REROLL ONCE", Rect2(93, 516, 294, 54), Color("#34405b"), Color("#91a6ce"), 14)
	shop_reroll_button.pressed.connect(func(): shop_reroll_requested.emit())
	var status_panel := make_panel(shop_content, Rect2(20, 590, 440, 158), Color("#0d1530f2"), Color("#8ea2c8"))
	shop_status = RichTextLabel.new()
	shop_status.position = Vector2(16, 12)
	shop_status.size = Vector2(408, 134)
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
	loadout_label.text = "WEAPON  •  %s\n\nARMOUR  •  %s\n\nCHARM  •  %s\n\nFAMILY  •  %s\nCORE  •  NEUTRAL" % [item_name_or_empty(weapon), item_name_or_empty(armour), item_name_or_empty(charm), current_inventory.weapon_family()]

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
		var button := make_button(stash_list, "%s  •  %s%s\n%s  [%s]" % [marker, ItemCatalog.display_slot(item.get("slot", "Item")), family, item.get("name", "Unknown"), item.get("rarity", "COMMON")], Rect2(0, 0, 402, 64), Color("#172442"), ItemCatalog.rarity_color(item.get("rarity", "COMMON")), 14)
		button.custom_minimum_size = Vector2(402, 64)
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
		if index >= current_shop.stock.size():
			button.text = "SOLD  •  Refreshes after the next run"
			button.disabled = true
			continue
		var item: Dictionary = current_shop.stock[index]
		button.text = "%s  •  %s\n%s  [%s]\n◆ %d SCRAP" % [ItemCatalog.display_slot(item.get("slot", "Item")), item.get("family", "GEAR"), item.get("name", "Unknown"), item.get("rarity", "COMMON"), item.get("price", 0)]
		button.disabled = reveal_pending or current_inventory.scrap < int(item.get("price", 0)) or current_inventory.stash.size() >= current_inventory.stash_capacity
		apply_button_style(button, Color("#172442"), ItemCatalog.rarity_color(item.get("rarity", "COMMON")))
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
			shop_status.text = "[center][color=#ffe39a]Persistent equipment, paid with Scrap.[/color]\nOffers refresh after every completed run.\nPremium boss and world drops remain stronger.[/center]"

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

func request_shop_offer(index: int) -> void:
	shop_offer_requested.emit(index)

func _draw() -> void:
	draw_rect(Rect2(0, 0, 480, 854), Color("#070c1d"))
	var texture_size := BACKGROUND_TEXTURE.get_size()
	var crop_height := texture_size.x * 854.0 / 480.0
	var source := Rect2(0, maxf(0.0, (texture_size.y - crop_height) * 0.5), texture_size.x, minf(texture_size.y, crop_height))
	draw_texture_rect_region(BACKGROUND_TEXTURE, Rect2(0, 0, 480, 854), source)
	draw_rect(Rect2(0, 0, 480, 854), Color("#071027a8"), true)
	draw_rect(Rect2(0, 0, 480, 102), Color("#080e24e8"), true)
	draw_rect(Rect2(0, 0, 480, 5), Color("#d4a856"), true)
	draw_rect(Rect2(0, 101, 480, 2), Color("#ad8040"), true)
	if current_screen == "home":
		draw_set_transform(Vector2(124, 300), 0.0, Vector2(1.0, 0.28))
		draw_circle(Vector2.ZERO, 72, Color("#04081588"))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		draw_texture_rect(MASCOT_TEXTURE, Rect2(18, 110, 212, 212), false, Color.WHITE)

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
