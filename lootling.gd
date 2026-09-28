extends Control

const GameCatalog = preload("res://game_catalog.gd")
const BuildSystem = preload("res://build_system.gd")
const MetaStore = preload("res://meta_store.gd")
const CreatureRenderer = preload("res://creature_renderer.gd")
const ItemCatalog = preload("res://item_catalog.gd")
const LootSystem = preload("res://loot_system.gd")
const InventorySystem = preload("res://inventory_system.gd")
const ShopSystem = preload("res://shop_system.gd")
const DESIGN_SIZE := Vector2(480.0, 854.0)
const SAVE_PATH := "user://lootlings_save.cfg"
const INVENTORY_SAVE_PATH := "user://lootlings_inventory.cfg"
const RUN_LAST_WAVE := 15
const ENEMIES_PER_WAVE := 3
const PLAYER_HOME_X := 102.0
const PLAYER_ATTACK_X := 245.0
const ENEMY_X := 372.0

const UPGRADES := GameCatalog.UPGRADES

var rng := RandomNumberGenerator.new()
var build = BuildSystem.new()
var creature_renderer = CreatureRenderer.new()
var loot_system = LootSystem.new()
var inventory = InventorySystem.new()
var shop = ShopSystem.new()
var title_font: Font
var body_font: Font
var state := "playing"
var wave := 1
var wave_kills := 0
var total_kills := 0
var coins := 0
var level := 1
var xp := 0.0
var xp_needed := 32.0
var pending_levels := 0
var run_time := 0.0
var player_x := PLAYER_HOME_X
var player_facing := 1
var player_hp := 100.0
var player_max_hp := 100.0
var base_damage := 11.0
var attack_interval := 0.85
var attack_clock := 0.0
var crit_chance := 0.08
var crit_mult := 2.0
var multi_hits := 1
var splash_ratio := 0.0
var life_steal := 0.0
var armor := 0.0
var frenzy := 0.0
var tap_mult := 0.65
var execute_ratio := 0.0
var regen_per_second := 0.0
var reward_mult := 1.0
var enemy_name := ""
var enemy_hp := 1.0
var enemy_max_hp := 1.0
var enemy_damage := 1.0
var enemy_attack_interval := 2.0
var enemy_attack_clock := 1.5
var enemy_is_boss := false
var enemy_is_miniboss := false
var enemy_archetype := "skirmisher"
var enemy_hit_multiplier := 1.0
var enemy_attack_count := 0
var enemy_alive := true
var spawn_clock := 0.0
var carried_shockwave := 0.0
var attack_sequence := 0
var enemy_burn_dps := 0.0
var enemy_burn_time := 0.0
var enemy_poison_stacks := 0
var enemy_poison_time := 0.0
var dot_tick_clock := 0.4
var heavy_power := 0
var storm_power := 0
var ignite_power := 0
var wildfire_power := 0
var venom_power := 0
var plague_power := 0
var selected_upgrades: Array = []
var upgrade_counts := {}
var floating_texts: Array = []
var particles: Array = []
var reward_pickups: Array = []
var loot_drops: Array = []
var pending_items: Array = []
var current_item: Dictionary = {}
var pending_victory := false
var merchant_due := false
var item_review_due := false
var return_to_merchant := false
var equipment_hp_bonus := 0.0
var boss_reward_options: Array = []
var screen_shake := 0.0
var enemy_flash := 0.0
var player_flash := 0.0
var squash := 0.0
var attack_anim := 0.0
var enemy_recoil := 0.0
var enemy_squash := 0.0
var enemy_death_anim := 0.0
var enemy_entry_anim := 0.0
var impact_flash := 0.0
var tap_pulse := 0.0
var upgrade_flash := 0.0
var wave_banner_timer := 0.0
var wave_banner_text := ""
var wave_banner_color := Color("#8fdcff")
var status_message := "Tap anywhere to help!"
var status_clock := 4.0
var tap_combo := 0
var combo_clock := 0.0
var meta_shards := 0
var meta_power := 0
var run_shards_earned := 0
var upgrade_panel: Panel
var upgrade_title: Label
var upgrade_buttons: Array[Button] = []
var result_panel: Panel
var result_title: Label
var result_summary: Label
var meta_button: Button
var restart_button: Button
var help_label: Label
var item_panel: Panel
var item_title: Label
var item_description: Label
var item_compare: Label
var item_equip_button: Button
var item_keep_button: Button
var item_scrap_button: Button
var merchant_panel: Panel
var merchant_title: Label
var merchant_buttons: Array[Button] = []
var merchant_reroll_button: Button
var merchant_continue_button: Button
var boss_reward_panel: Panel
var boss_reward_buttons: Array[Button] = []

func _ready() -> void:
	rng.randomize()
	title_font = ThemeDB.fallback_font
	body_font = ThemeDB.fallback_font
	build_overlay_ui()
	load_meta()
	inventory.load(INVENTORY_SAVE_PATH)
	start_run()
	queue_redraw()

func build_overlay_ui() -> void:
	upgrade_panel = make_panel(Rect2(22, 205, 436, 470), Color("#172042f2"))
	upgrade_panel.visible = false
	upgrade_title = make_label(upgrade_panel, "LEVEL UP!", 30, Rect2(20, 18, 396, 48), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	for i in range(3):
		var button := Button.new()
		button.position = Vector2(25, 86 + i * 115)
		button.size = Vector2(386, 96)
		button.add_theme_font_size_override("font_size", 20)
		button.add_theme_color_override("font_color", Color("#f8fbff"))
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.pressed.connect(choose_upgrade.bind(i))
		upgrade_panel.add_child(button)
		upgrade_buttons.append(button)
	make_label(upgrade_panel, "Every pick stacks. Make something silly.", 15, Rect2(20, 438, 396, 24), HORIZONTAL_ALIGNMENT_CENTER, Color("#aebee8"))
	result_panel = make_panel(Rect2(28, 155, 424, 555), Color("#151b39f5"))
	result_panel.visible = false
	result_title = make_label(result_panel, "RUN COMPLETE!", 34, Rect2(20, 25, 384, 55), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	result_summary = make_label(result_panel, "", 20, Rect2(35, 100, 354, 190), HORIZONTAL_ALIGNMENT_CENTER, Color("#e9efff"))
	result_summary.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	meta_button = Button.new()
	meta_button.position = Vector2(47, 320)
	meta_button.size = Vector2(330, 72)
	meta_button.add_theme_font_size_override("font_size", 18)
	apply_button_style(meta_button, Color("#24365f"), Color("#72b8ff"))
	meta_button.pressed.connect(buy_meta_power)
	result_panel.add_child(meta_button)
	restart_button = Button.new()
	restart_button.text = "START ANOTHER RUN"
	restart_button.position = Vector2(47, 415)
	restart_button.size = Vector2(330, 78)
	restart_button.add_theme_font_size_override("font_size", 20)
	apply_button_style(restart_button, Color("#795523"), Color("#ffd468"))
	restart_button.pressed.connect(start_run)
	result_panel.add_child(restart_button)
	help_label = make_label(self, "TAP / CLICK / SPACE = bonus attack", 14, Rect2(20, 815, 440, 26), HORIZONTAL_ALIGNMENT_CENTER, Color("#a9b7d7"))
	build_item_ui()
	build_merchant_ui()
	build_boss_reward_ui()

func build_item_ui() -> void:
	item_panel = make_panel(Rect2(24, 174, 432, 520), Color("#111a36f7"))
	item_panel.visible = false
	item_title = make_label(item_panel, "LOOT FOUND!", 27, Rect2(20, 18, 392, 45), HORIZONTAL_ALIGNMENT_CENTER, Color.WHITE)
	item_description = make_label(item_panel, "", 18, Rect2(28, 82, 376, 146), HORIZONTAL_ALIGNMENT_CENTER, Color("#e8efff"))
	item_description.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	item_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item_compare = make_label(item_panel, "", 15, Rect2(28, 235, 376, 92), HORIZONTAL_ALIGNMENT_CENTER, Color("#aebee8"))
	item_compare.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	item_compare.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item_equip_button = make_action_button(item_panel, "EQUIP", Vector2(28, 345), Vector2(176, 62), Color("#295d50"), Color("#69e6b0"), accept_item_equip)
	item_keep_button = make_action_button(item_panel, "KEEP", Vector2(228, 345), Vector2(176, 62), Color("#29486b"), Color("#74caff"), accept_item_keep)
	item_scrap_button = make_action_button(item_panel, "SCRAP", Vector2(28, 426), Vector2(376, 58), Color("#5a3828"), Color("#ffbd69"), accept_item_scrap)

func build_merchant_ui() -> void:
	merchant_panel = make_panel(Rect2(20, 156, 440, 570), Color("#15142ff8"))
	merchant_panel.visible = false
	merchant_title = make_label(merchant_panel, "THE PACK PEDDLER", 27, Rect2(20, 17, 400, 50), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffe178"))
	make_label(merchant_panel, "Spend run coins. Purchases still use Equip / Keep / Scrap.", 14, Rect2(26, 62, 388, 38), HORIZONTAL_ALIGNMENT_CENTER, Color("#b8c6e6")).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for i in range(3):
		var button := Button.new()
		button.position = Vector2(25, 110 + i * 112)
		button.size = Vector2(390, 96)
		button.add_theme_font_size_override("font_size", 16)
		button.pressed.connect(buy_merchant_item.bind(i))
		merchant_panel.add_child(button)
		merchant_buttons.append(button)
	merchant_reroll_button = make_action_button(merchant_panel, "REROLL", Vector2(25, 462), Vector2(185, 64), Color("#3e315c"), Color("#c89bff"), reroll_merchant)
	merchant_continue_button = make_action_button(merchant_panel, "CONTINUE", Vector2(230, 462), Vector2(185, 64), Color("#295d50"), Color("#69e6b0"), leave_merchant)

func build_boss_reward_ui() -> void:
	boss_reward_panel = make_panel(Rect2(20, 155, 440, 570), Color("#17142ff8"))
	boss_reward_panel.visible = false
	make_label(boss_reward_panel, "BOSS HOARD", 30, Rect2(20, 18, 400, 48), HORIZONTAL_ALIGNMENT_CENTER, Color("#ffd36a"))
	make_label(boss_reward_panel, "Choose one relic-grade reward", 16, Rect2(20, 64, 400, 30), HORIZONTAL_ALIGNMENT_CENTER, Color("#d9c9ff"))
	for i in range(3):
		var button := Button.new()
		button.position = Vector2(25, 112 + i * 130)
		button.size = Vector2(390, 108)
		button.add_theme_font_size_override("font_size", 17)
		button.pressed.connect(choose_boss_reward.bind(i))
		boss_reward_panel.add_child(button)
		boss_reward_buttons.append(button)

func make_action_button(parent: Node, text_value: String, pos: Vector2, button_size: Vector2, fill: Color, border: Color, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text_value
	button.position = pos
	button.size = button_size
	button.add_theme_font_size_override("font_size", 18)
	apply_button_style(button, fill, border)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func apply_button_style(button: Button, fill: Color, border: Color) -> void:
	for state_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		var box := StyleBoxFlat.new()
		box.bg_color = fill.lightened(0.10) if state_name == "hover" else fill.darkened(0.12) if state_name == "pressed" else fill
		box.border_color = border
		box.set_border_width_all(2)
		box.set_corner_radius_all(14)
		box.content_margin_left = 16
		box.content_margin_right = 16
		box.shadow_color = Color(0, 0, 0, 0.28)
		box.shadow_size = 6 if state_name == "normal" else 2
		button.add_theme_stylebox_override(state_name, box)

func make_panel(rect: Rect2, color: Color) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = Color("#7289d6")
	box.set_border_width_all(2)
	box.set_corner_radius_all(20)
	box.shadow_color = Color(0, 0, 0, 0.4)
	box.shadow_size = 12
	panel.add_theme_stylebox_override("panel", box)
	add_child(panel)
	return panel

func make_label(parent: Node, text_value: String, size_value: int, rect: Rect2, alignment: HorizontalAlignment, color: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = alignment
	label.add_theme_font_size_override("font_size", size_value)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func start_run() -> void:
	state = "playing"
	wave = 1
	wave_kills = 0
	total_kills = 0
	coins = 0
	level = 1
	xp = 0.0
	xp_needed = 32.0
	pending_levels = 0
	run_time = 0.0
	player_x = PLAYER_HOME_X
	player_facing = 1
	var meta_bonus := 1.0 + float(meta_power) * 0.05
	equipment_hp_bonus = inventory.effect_total("max_hp")
	player_max_hp = maxf(40.0, 100.0 * meta_bonus + equipment_hp_bonus)
	player_hp = player_max_hp
	base_damage = 11.0 * meta_bonus
	attack_interval = 0.85
	attack_clock = 0.3
	crit_chance = 0.08
	crit_mult = 2.0
	multi_hits = 1
	splash_ratio = 0.0
	life_steal = 0.0
	armor = 0.0
	frenzy = 0.0
	tap_mult = 0.65
	execute_ratio = 0.0
	regen_per_second = 0.0
	reward_mult = 1.0
	carried_shockwave = 0.0
	selected_upgrades.clear()
	upgrade_counts.clear()
	build.reset()
	attack_sequence = 0
	heavy_power = 0
	storm_power = 0
	ignite_power = 0
	wildfire_power = 0
	venom_power = 0
	plague_power = 0
	floating_texts.clear()
	particles.clear()
	reward_pickups.clear()
	loot_drops.clear()
	pending_items.clear()
	current_item.clear()
	boss_reward_options.clear()
	pending_victory = false
	merchant_due = false
	item_review_due = false
	return_to_merchant = false
	shop.stock.clear()
	shop.rerolls = 0
	attack_anim = 0.0
	enemy_recoil = 0.0
	enemy_death_anim = 0.0
	wave_banner_text = "WAVE 1"
	wave_banner_color = Color("#8fdcff")
	wave_banner_timer = 1.8
	upgrade_panel.visible = false
	result_panel.visible = false
	item_panel.visible = false
	merchant_panel.visible = false
	boss_reward_panel.visible = false
	help_label.visible = true
	run_shards_earned = 0
	status_message = "A new run begins!"
	status_clock = 2.5
	spawn_enemy()
	queue_redraw()

func spawn_enemy() -> void:
	enemy_is_miniboss = wave == 8
	enemy_is_boss = wave == RUN_LAST_WAVE
	# Steady curve with explicit special-enemy spikes; regular archetypes stay closer together.
	var progress := pow(1.15, wave - 1)
	var type_bonus := 1.0
	if enemy_is_boss:
		type_bonus = 4.8
		enemy_name = "THE HOARD DRAGON"
	elif enemy_is_miniboss:
		type_bonus = 2.65
		enemy_name = "GRUMP KNIGHT"
	else:
		var archetypes := ["skirmisher", "tank", "hexer"]
		enemy_archetype = archetypes[(wave + wave_kills) % archetypes.size()]
		match enemy_archetype:
			"tank": enemy_name = "MOSSBACK BRUTE"
			"hexer": enemy_name = "LANTERN HEXER"
			_: enemy_name = "RAZOR IMP"
	enemy_max_hp = (24.0 + wave * 7.0) * progress * type_bonus
	enemy_damage = (3.5 + wave * 0.92) * (1.3 if enemy_is_miniboss else 1.0) * (1.55 if enemy_is_boss else 1.0)
	enemy_attack_interval = maxf(0.85, 2.25 - wave * 0.045)
	enemy_hit_multiplier = 1.0
	if not enemy_is_boss and not enemy_is_miniboss:
		match enemy_archetype:
			"skirmisher":
				enemy_max_hp *= 0.86
				enemy_attack_interval *= 0.62
				enemy_damage *= 0.72
			"tank":
				enemy_max_hp *= 1.48
				enemy_attack_interval *= 1.28
				enemy_damage *= 0.9
				enemy_hit_multiplier = 0.82
			"hexer":
				enemy_max_hp *= 0.9
				enemy_attack_interval *= 1.08
				enemy_damage *= 0.88
	enemy_hp = enemy_max_hp
	enemy_attack_clock = enemy_attack_interval
	enemy_attack_count = 0
	enemy_burn_dps = 0.0
	enemy_burn_time = 0.0
	enemy_poison_stacks = 0
	enemy_poison_time = 0.0
	dot_tick_clock = 0.35
	enemy_alive = true
	spawn_clock = 0.0
	enemy_entry_anim = 0.55 if enemy_is_boss or enemy_is_miniboss else 0.28
	enemy_death_anim = 0.0
	player_x = minf(player_x, PLAYER_HOME_X + 30.0)
	if enemy_is_boss:
		wave_banner_text = "BOSS  -  THE HOARD DRAGON"
		wave_banner_color = Color("#ffb154")
		wave_banner_timer = 2.3
	elif enemy_is_miniboss:
		wave_banner_text = "MINIBOSS  -  GRUMP KNIGHT"
		wave_banner_color = Color("#d49cff")
		wave_banner_timer = 2.0
	if carried_shockwave > 0.0:
		var opening_damage := minf(carried_shockwave, enemy_hp * 0.55)
		enemy_hp -= opening_damage
		add_float("SHOCKWAVE %.0f" % opening_damage, Vector2(350, 405), Color("#8fe7ff"), 18)
		carried_shockwave = 0.0

func _process(delta: float) -> void:
	update_effects(delta)
	if state != "playing":
		queue_redraw()
		return
	run_time += delta
	status_clock = maxf(0.0, status_clock - delta)
	combo_clock -= delta
	if combo_clock <= 0.0:
		tap_combo = 0
	player_hp = minf(player_max_hp, player_hp + regen_per_second * delta)
	if not enemy_alive:
		# Never replace a defeated foe while its visible loot reveal is still resolving.
		if not loot_drops.is_empty():
			queue_redraw()
			return
		if loot_drops.is_empty() and item_review_due:
			if not boss_reward_options.is_empty():
				show_boss_reward()
				queue_redraw()
				return
			if not pending_items.is_empty():
				show_next_item()
				queue_redraw()
				return
			item_review_due = false
		if loot_drops.is_empty() and pending_victory:
			end_run(true)
			queue_redraw()
			return
		if loot_drops.is_empty() and merchant_due:
			show_merchant()
			queue_redraw()
			return
		spawn_clock -= delta
		if spawn_clock <= 0.0:
			spawn_enemy()
		queue_redraw()
		return
	var attack_position := target_player_x()
	if player_x < attack_position:
		player_x = minf(attack_position, player_x + 155.0 * delta)
		if enemy_archetype == "hexer" and not enemy_is_boss and not enemy_is_miniboss:
			enemy_attack_clock -= delta
			if enemy_attack_clock <= 0.0:
				enemy_attack_clock += enemy_attack_interval
				perform_enemy_attack(0.62)
	else:
		attack_clock -= delta
		if attack_clock <= 0.0:
			attack_clock += current_attack_interval()
			perform_player_attack(false)
		enemy_attack_clock -= delta
		if enemy_attack_clock <= 0.0:
			enemy_attack_clock += enemy_attack_interval
			perform_enemy_attack()
	update_elemental_damage(delta)
	queue_redraw()

func current_attack_interval() -> float:
	var result := attack_interval
	match inventory.weapon_family():
		"RANGER": result *= 0.78
		"MAGE": result *= 0.95
		"ROGUE": result *= 0.68
		_: result *= 1.18
	result *= 1.0 + inventory.effect_total("attack_slow")
	result /= 1.0 + inventory.effect_total("attack_speed")
	if frenzy > 0.0:
		result /= 1.0 + frenzy * (1.0 - player_hp / player_max_hp)
	return maxf(0.16, result)

func target_player_x() -> float:
	return 162.0 if inventory.weapon_family() in ["RANGER", "MAGE"] else PLAYER_ATTACK_X

func effective_crit_chance() -> float:
	var family_bonus := 0.10 if inventory.weapon_family() == "ROGUE" else 0.06 if inventory.weapon_family() == "RANGER" else 0.0
	return minf(0.85, crit_chance + inventory.effect_total("crit") + family_bonus)

func equipment_damage_multiplier() -> float:
	var result := 1.0 + inventory.effect_total("damage_mult")
	if player_hp / player_max_hp < 0.4:
		result += inventory.effect_total("low_health_damage")
	if enemy_is_boss:
		result += inventory.effect_total("boss_damage")
	match inventory.weapon_family():
		"VANGUARD": result *= 1.18
		"RANGER": result *= 0.82
		"MAGE": result *= 0.95
		"ROGUE": result *= 0.72
	return result

func perform_player_attack(is_tap: bool) -> void:
	if state != "playing" or not enemy_alive or player_x < target_player_x() - 4.0:
		return
	var hit_count := 1 if is_tap else multi_hits + int(inventory.effect_total("extra_hits"))
	var damage_scale := tap_mult if is_tap else 1.0
	attack_sequence += 1
	var physical_count: int = build.count("Physical")
	var heavy_interval := maxi(3, 7 - mini(physical_count + heavy_power, 4))
	var is_heavy := physical_count > 0 and attack_sequence % heavy_interval == 0
	if is_heavy:
		damage_scale *= 2.2 + inventory.effect_total("heavy_bonus")
		wave_banner_text = "QUAKE BONK!"
		wave_banner_color = build.color("Physical")
		wave_banner_timer = 0.38
	if is_tap:
		tap_combo += 1
		combo_clock = 0.7
		tap_pulse = 0.18
		damage_scale *= 1.0 + minf(tap_combo, 10) * 0.025
	for hit_index in range(hit_count):
		if not enemy_alive:
			break
		var is_crit := rng.randf() < effective_crit_chance()
		var damage := base_damage * damage_scale * equipment_damage_multiplier() * (crit_mult if is_crit else 1.0) * rng.randf_range(0.92, 1.08)
		damage_enemy(damage, is_crit, is_tap)
		if enemy_alive and is_crit and inventory.effect_total("crit_lightning") > 0.0:
			deal_elemental_hit(base_damage * inventory.effect_total("crit_lightning"), "Lightning")
		if hit_count > 1 and hit_index < hit_count - 1:
			add_particles(Vector2(337, 475), Color("#d6a8ff"), 3)
	var lightning_count: int = build.count("Lightning")
	var chain_interval := maxi(3, 6 - mini(lightning_count + storm_power, 3))
	if enemy_alive and lightning_count > 0 and attack_sequence % chain_interval == 0:
		var chain_damage := base_damage * (0.35 + lightning_count * 0.14) * (1.0 + (multi_hits - 1) * 0.18)
		deal_elemental_hit(chain_damage, "Lightning")
	if enemy_alive and inventory.weapon_family() == "MAGE":
		var repeat_every := maxi(3, int(inventory.effect_total("repeat_every"))) if inventory.effect_total("repeat_every") > 0.0 else 4
		if attack_sequence % repeat_every == 0:
			var spell_identity := build.dominant()
			if spell_identity == "Neutral":
				spell_identity = "Lightning"
			deal_elemental_hit(base_damage * 0.62, spell_identity)
			add_float("RELIC SPELL!", Vector2(250, 365), build.color(spell_identity), 18)
	squash = 0.16
	attack_anim = 0.22

func damage_enemy(amount: float, is_crit: bool, is_tap: bool) -> void:
	amount *= enemy_hit_multiplier
	enemy_hp -= amount
	enemy_flash = 0.11
	enemy_squash = 0.16
	enemy_recoil = 28.0 if is_crit else 17.0 if is_tap else 12.0
	impact_flash = 0.10 if is_crit else 0.045
	screen_shake = 0.075 if is_crit else 0.035
	var text := ("CRIT! %.0f" if is_crit else "%.0f") % amount
	if is_tap and not is_crit:
		text = "TAP %.0f" % amount
	add_float(text, Vector2(330 + rng.randf_range(-12, 12), 408), Color("#fff178") if is_crit else Color.WHITE, 29 if is_crit else 20)
	add_particles(Vector2(342, 475), Color("#ffda69") if is_crit else Color("#b8efff"), 14 if is_crit else 7)
	player_hp = minf(player_max_hp, player_hp + amount * life_steal)
	carried_shockwave += amount * splash_ratio
	var fire_count: int = build.count("Fire")
	if fire_count > 0:
		var fire_bonus := 1.0 + inventory.effect_total("fire_damage")
		enemy_burn_dps = minf(base_damage * (1.5 + fire_count * 0.45) * fire_bonus, enemy_burn_dps + amount * (0.018 * fire_count + ignite_power * 0.025) * fire_bonus)
		enemy_burn_time = 3.2
	var poison_count: int = build.count("Poison")
	if poison_count > 0:
		enemy_poison_stacks = mini(4 + poison_count * 3, enemy_poison_stacks + 1 + venom_power + int(inventory.effect_total("poison_bonus")))
		enemy_poison_time = 5.0 * (1.0 + inventory.effect_total("poison_duration"))
	var effective_execute := execute_ratio + inventory.effect_total("execute")
	if effective_execute > 0.0 and enemy_hp > 0.0 and enemy_hp / enemy_max_hp <= effective_execute:
		add_float("YEET!", Vector2(355, 385), Color("#ff8bd8"), 28)
		enemy_hp = 0.0
	if enemy_hp <= 0.0:
		kill_enemy()

func perform_enemy_attack(damage_scale: float = 1.0) -> void:
	if not enemy_alive:
		return
	enemy_attack_count += 1
	if enemy_archetype == "hexer" and not enemy_is_boss and not enemy_is_miniboss and enemy_attack_count % 3 == 0:
		var ward := enemy_max_hp * 0.07
		enemy_hp = minf(enemy_max_hp, enemy_hp + ward)
		add_float("WARD +%.0f" % ward, Vector2(325, 410), Color("#d194ff"), 17)
		add_particles(Vector2(365, 465), Color("#b86cff"), 6)
		return
	var style_armor := 0.04 if inventory.weapon_family() == "VANGUARD" else 0.0
	var effective_armor := armor + inventory.effect_total("armor") + style_armor
	var damage := enemy_damage * damage_scale * (1.0 - minf(effective_armor, 0.72))
	player_hp -= damage
	player_flash = 0.13
	screen_shake = 0.08
	add_float("-%.0f" % damage, Vector2(150, 432), Color("#ff7a84"), 19)
	add_particles(Vector2(170, 478), Color("#ff768c"), 5)
	if player_hp <= 0.0:
		player_hp = 0.0
		end_run(false)

func deal_elemental_hit(amount: float, identity: String) -> void:
	if not enemy_alive:
		return
	amount *= enemy_hit_multiplier
	enemy_hp -= amount
	var color := build.color(identity)
	enemy_flash = 0.08
	enemy_recoil = 22.0
	impact_flash = 0.06
	add_float("ARC %.0f" % amount, Vector2(324, 390), color, 22)
	add_particles(Vector2(350, 455), color, 9)
	carried_shockwave += amount * 0.18 if build.count("Lightning") >= 5 else 0.0
	if enemy_hp <= 0.0:
		kill_enemy()

func update_elemental_damage(delta: float) -> void:
	if not enemy_alive:
		return
	enemy_burn_time = maxf(0.0, enemy_burn_time - delta)
	enemy_poison_time = maxf(0.0, enemy_poison_time - delta)
	if enemy_burn_time <= 0.0:
		enemy_burn_dps = move_toward(enemy_burn_dps, 0.0, base_damage * delta)
	if enemy_poison_time <= 0.0:
		enemy_poison_stacks = 0
	dot_tick_clock -= delta
	if dot_tick_clock > 0.0:
		return
	dot_tick_clock += 0.4
	var total_dot := 0.0
	if enemy_burn_dps > 0.0:
		var burn_damage := enemy_burn_dps * 0.4 * enemy_hit_multiplier
		total_dot += burn_damage
		add_float("BURN %.0f" % burn_damage, Vector2(322, 400), build.color("Fire"), 15)
		add_particles(Vector2(360, 446), build.color("Fire"), 2)
	if enemy_poison_stacks > 0:
		var poison_damage := base_damage * 0.012 * build.count("Poison") * enemy_poison_stacks * enemy_hit_multiplier
		total_dot += poison_damage
		add_float("TOXIN %.0f" % poison_damage, Vector2(350, 430), build.color("Poison"), 15)
		add_particles(Vector2(375, 480), build.color("Poison"), 2)
		if build.count("Poison") >= 3 or plague_power > 0:
			player_hp = minf(player_max_hp, player_hp + poison_damage * (0.12 + plague_power * 0.05))
	if total_dot > 0.0:
		enemy_hp -= total_dot
		if enemy_hp <= 0.0:
			kill_enemy()

func kill_enemy() -> void:
	enemy_alive = false
	spawn_clock = 0.72
	enemy_death_anim = 0.62
	impact_flash = 0.12
	enemy_hp = 0.0
	total_kills += 1
	wave_kills += 1
	var reward := int(round((5.0 + wave * 1.8) * reward_mult * (1.0 + inventory.effect_total("coin_mult")) * (4.0 if enemy_is_boss else 2.0 if enemy_is_miniboss else 1.0)))
	coins += reward
	var xp_reward := (13.0 + wave * 2.2) * reward_mult * (2.6 if enemy_is_boss else 1.8 if enemy_is_miniboss else 1.0)
	var fire_count: int = build.count("Fire")
	if fire_count >= 3 or wildfire_power > 0:
		var explosion := base_damage * (0.45 * fire_count + wildfire_power * 0.5)
		carried_shockwave += explosion
		add_float("WILDFIRE %.0f" % explosion, Vector2(300, 380), build.color("Fire"), 23)
		add_particles(Vector2(365, 455), build.color("Fire"), 12)
	var gear_explosion := base_damage * inventory.effect_total("kill_explosion")
	if gear_explosion > 0.0:
		carried_shockwave += gear_explosion
		add_float("GEAR BURST %.0f" % gear_explosion, Vector2(290, 405), Color("#ffd17a"), 18)
	spawn_item_drop()
	add_xp(xp_reward)
	add_float("+%d COINS" % reward, Vector2(346, 355), Color("#ffd65a"), 19)
	add_particles(Vector2(365, 470), Color("#ffd65a"), 26 if enemy_is_boss else 18)
	add_reward_burst(reward, xp_reward)
	status_message = "%s defeated!" % enemy_name
	status_clock = 1.2
	if enemy_is_boss:
		pending_victory = true
		item_review_due = true
		return
	if wave_kills >= ENEMIES_PER_WAVE or enemy_is_miniboss:
		wave += 1
		wave_kills = 0
		item_review_due = true
		if wave in [6, 11]:
			merchant_due = true
		player_hp = minf(player_max_hp, player_hp + player_max_hp * 0.20)
		status_message = "WAVE %d - enemies grow stronger!" % wave
		status_clock = 2.0
		wave_banner_text = "FINAL WAVE" if wave == RUN_LAST_WAVE else "MINIBOSS AHEAD" if wave == 8 else "WAVE %d" % wave
		wave_banner_color = Color("#ffb154") if wave == RUN_LAST_WAVE else Color("#d49cff") if wave == 8 else Color("#8fdcff")
		wave_banner_timer = 1.8
	carried_shockwave = minf(carried_shockwave, base_damage * 12.0)

func spawn_item_drop() -> void:
	var drop_count := 3 if enemy_is_boss else 1
	for drop_index in range(drop_count):
		var item: Dictionary = loot_system.roll_drop(enemy_is_miniboss, enemy_is_boss)
		if item.is_empty():
			continue
		if enemy_is_boss:
			boss_reward_options.append(item)
		var rarity_color := ItemCatalog.rarity_color(item.rarity)
		loot_drops.append({
			"item":item,
			"boss_choice":enemy_is_boss,
			"pos":Vector2(345 + drop_index * 20, 430),
			"vel":Vector2(-75.0 + drop_index * 52.0, rng.randf_range(-250.0, -205.0)),
			"pickup":1.15 + drop_index * 0.08,
			"bounces":0,
			"color":rarity_color
		})
	spawn_clock = maxf(spawn_clock, 1.2)
	if enemy_is_boss:
		add_float("BOSS HOARD!", Vector2(290, 335), Color("#ffd36a"), 25)
	elif not loot_drops.is_empty():
		add_float("%s LOOT!" % loot_drops.back().item.rarity, Vector2(290, 335), loot_drops.back().color, 21)

func show_boss_reward() -> void:
	state = "boss_reward"
	boss_reward_panel.visible = true
	help_label.visible = false
	for i in range(boss_reward_buttons.size()):
		var item: Dictionary = boss_reward_options[i]
		boss_reward_buttons[i].text = "%s  %s\n%s  -  %s\n%s" % [item.rarity, item.name, item.slot, item.get("family", "GEAR"), ItemCatalog.describe_effects(item)]
		apply_button_style(boss_reward_buttons[i], Color("#24264f"), ItemCatalog.rarity_color(item.rarity))

func choose_boss_reward(index: int) -> void:
	if state != "boss_reward" or index < 0 or index >= boss_reward_options.size():
		return
	var chosen: Dictionary = boss_reward_options[index]
	boss_reward_options.clear()
	boss_reward_panel.visible = false
	pending_items.push_front(chosen)
	state = "playing"
	show_next_item()

func show_next_item() -> void:
	if pending_items.is_empty():
		finish_item_decision()
		return
	state = "item"
	current_item = pending_items.pop_front()
	var rarity: String = current_item.get("rarity", "COMMON")
	var color := ItemCatalog.rarity_color(rarity)
	item_title.text = "%s  %s" % [rarity, current_item.get("name", "Unknown Loot")]
	item_title.add_theme_color_override("font_color", color)
	item_description.text = "%s  -  %s\n\n%s" % [current_item.get("slot", "Item"), current_item.get("family", "GEAR"), current_item.get("desc", "")]
	var equipped: Dictionary = inventory.equipped_item(current_item.get("slot", ""))
	var equipped_text := "Empty slot"
	if not equipped.is_empty():
		equipped_text = "Equipped: %s [%s]\n%s" % [equipped.get("name", "Item"), equipped.get("rarity", "COMMON"), ItemCatalog.describe_effects(equipped)]
	item_compare.text = "%s\n\nFound: %s" % [equipped_text, ItemCatalog.describe_effects(current_item)]
	item_keep_button.disabled = inventory.stash.size() >= InventorySystem.MAX_STASH
	item_keep_button.text = "KEEP (%d/%d)" % [inventory.stash.size(), InventorySystem.MAX_STASH]
	item_scrap_button.text = "SCRAP  +%d" % ItemCatalog.scrap_value(current_item)
	apply_button_style(item_equip_button, Color("#295d50"), color)
	item_panel.visible = true
	help_label.visible = false
	queue_redraw()

func accept_item_equip() -> void:
	if state != "item" or current_item.is_empty():
		return
	var item_name: String = current_item.get("name", "Loot")
	var result: Dictionary = inventory.equip(current_item)
	refresh_equipment_health()
	inventory.save(INVENTORY_SAVE_PATH)
	status_message = "%s equipped!" % item_name
	if int(result.get("scrapped", 0)) > 0:
		status_message += " Old gear auto-scrapped."
	finish_item_decision()

func accept_item_keep() -> void:
	if state != "item" or current_item.is_empty():
		return
	if not inventory.keep(current_item):
		return
	inventory.save(INVENTORY_SAVE_PATH)
	status_message = "%s sent to stash." % current_item.get("name", "Loot")
	finish_item_decision()

func accept_item_scrap() -> void:
	if state != "item" or current_item.is_empty():
		return
	var value := inventory.salvage(current_item)
	inventory.save(INVENTORY_SAVE_PATH)
	status_message = "Loot scrapped for %d scrap." % value
	finish_item_decision()

func finish_item_decision() -> void:
	item_panel.visible = false
	current_item.clear()
	status_clock = 2.0
	if not pending_items.is_empty():
		state = "playing"
		show_next_item()
	elif return_to_merchant:
		return_to_merchant = false
		show_merchant()
	elif pending_victory:
		end_run(true)
	else:
		item_review_due = false
		state = "playing"
		help_label.visible = true

func refresh_equipment_health() -> void:
	var new_bonus := inventory.effect_total("max_hp")
	var difference := new_bonus - equipment_hp_bonus
	equipment_hp_bonus = new_bonus
	player_max_hp = maxf(40.0, player_max_hp + difference)
	player_hp = clampf(player_hp + maxf(0.0, difference), 1.0, player_max_hp)

func show_merchant() -> void:
	state = "merchant"
	merchant_due = false
	if shop.stock.is_empty():
		shop.generate_stock(loot_system, wave)
	merchant_panel.visible = true
	help_label.visible = false
	refresh_merchant_ui()

func refresh_merchant_ui() -> void:
	merchant_title.text = "THE PACK PEDDLER  -  %d COINS" % coins
	for i in range(merchant_buttons.size()):
		var button := merchant_buttons[i]
		if i >= shop.stock.size():
			button.text = "SOLD"
			button.disabled = true
			continue
		var item: Dictionary = shop.stock[i]
		var price := int(item.get("price", 0))
		button.text = "%s  [%s]  -  %d COINS\n%s\n%s" % [item.name, item.rarity, price, item.slot, ItemCatalog.describe_effects(item)]
		button.disabled = coins < price
		apply_button_style(button, Color("#202d52"), ItemCatalog.rarity_color(item.rarity))
	var reroll_price := shop.reroll_cost(wave)
	merchant_reroll_button.text = "REROLL  %d" % reroll_price
	merchant_reroll_button.disabled = coins < reroll_price

func buy_merchant_item(index: int) -> void:
	if state != "merchant" or index < 0 or index >= shop.stock.size():
		return
	var price := int(shop.stock[index].get("price", 0))
	if coins < price:
		return
	coins -= price
	var bought: Dictionary = shop.take(index)
	merchant_panel.visible = false
	return_to_merchant = true
	pending_items.push_front(bought)
	state = "playing"
	show_next_item()

func reroll_merchant() -> void:
	if state != "merchant":
		return
	var price := shop.reroll_cost(wave)
	if coins < price:
		return
	coins -= price
	shop.reroll(loot_system, wave)
	refresh_merchant_ui()

func leave_merchant() -> void:
	if state != "merchant":
		return
	merchant_panel.visible = false
	shop.stock.clear()
	state = "playing"
	help_label.visible = true
	status_message = "Back to the hunt!"
	status_clock = 1.5

func add_xp(amount: float) -> void:
	xp += amount
	while xp >= xp_needed:
		xp -= xp_needed
		level += 1
		xp_needed = 32.0 + level * 15.0
		pending_levels += 1
	if pending_levels > 0 and state == "playing":
		show_upgrade_choices()

func show_upgrade_choices() -> void:
	state = "upgrade"
	selected_upgrades.clear()
	var pool := UPGRADES.duplicate(true)
	pool.shuffle()
	for i in range(3):
		selected_upgrades.append(pool[i])
		var up: Dictionary = pool[i]
		var stacks := int(upgrade_counts.get(up.id, 0))
		var tag: String = up.tags[0].to_upper()
		upgrade_buttons[i].text = "%s   %s   [%s]\n%s  -  %s%s" % [up.icon, up.name, up.rarity, tag, up.desc, "  (x%d)" % stacks if stacks > 0 else ""]
		apply_button_style(upgrade_buttons[i], Color("#202d52"), GameCatalog.rarity_color(up.rarity))
	upgrade_title.text = "LEVEL %d - PICK ONE" % level
	upgrade_panel.visible = true

func choose_upgrade(index: int) -> void:
	if state != "upgrade" or index < 0 or index >= selected_upgrades.size():
		return
	var up: Dictionary = selected_upgrades[index]
	var previous_dominant: String = build.dominant()
	var previous_tier: int = build.tier(previous_dominant)
	apply_upgrade_effect(up)
	var new_dominant: String = build.dominant()
	var transformed := new_dominant != "Neutral" and (new_dominant != previous_dominant or build.tier(new_dominant) > previous_tier)
	if transformed:
		wave_banner_text = "%s CORE  -  %s" % [new_dominant.to_upper(), build.tier_name(new_dominant)]
		wave_banner_timer = 1.8
		upgrade_flash = 1.1
		add_particles(Vector2(player_x, 470), build.color(), 34)
	else:
		wave_banner_text = "%s EQUIPPED" % up.name
		wave_banner_timer = 1.15
		add_particles(Vector2(player_x, 470), build.color(), 20)
	wave_banner_color = build.color()
	status_message = "%s acquired!" % up.name
	status_clock = 2.0
	pending_levels -= 1
	upgrade_panel.visible = false
	if pending_levels > 0:
		show_upgrade_choices()
	else:
		state = "playing"
	queue_redraw()

func apply_upgrade_effect(up: Dictionary) -> void:
	var id: String = up.id
	upgrade_counts[id] = int(upgrade_counts.get(id, 0)) + 1
	build.add_upgrade(up)
	match id:
		"damage": base_damage *= 1.35
		"speed": attack_interval *= 0.82
		"crit": crit_chance = minf(0.72, crit_chance + 0.12)
		"multi": multi_hits += 1
		"splash": splash_ratio += 0.25
		"vamp": life_steal += 0.04
		"armor":
			player_max_hp += 30.0
			player_hp += 30.0
			armor = 1.0 - (1.0 - armor) * 0.92
		"frenzy": frenzy += 1.0
		"tap": tap_mult += 0.8
		"execute": execute_ratio = minf(0.35, execute_ratio + 0.12)
		"regen": regen_per_second += 1.5
		"greed": reward_mult += 0.5
		"heavy": heavy_power += 1
		"storm": storm_power += 1
		"ignite": ignite_power += 1
		"wildfire": wildfire_power += 1
		"venom": venom_power += 1
		"plague": plague_power += 1

func end_run(victory: bool) -> void:
	state = "result"
	upgrade_panel.visible = false
	item_panel.visible = false
	merchant_panel.visible = false
	boss_reward_panel.visible = false
	result_panel.visible = true
	help_label.visible = false
	run_shards_earned = (10 + level * 2 + wave) if victory else max(2, int(level + wave * 0.5))
	meta_shards += run_shards_earned
	save_meta()
	result_title.text = "HOARD CONQUERED!" if victory else "BONKED OUT!"
	result_title.add_theme_color_override("font_color", Color("#ffe178") if victory else Color("#ff8995"))
	result_summary.text = "Wave %d / %d\nLevel %d  -  %d enemies\n%d coins  -  %d scrap\n%s equipped\n\n+%d star shards\nPermanent power: +%d%%" % [wave, RUN_LAST_WAVE, level, total_kills, coins, inventory.scrap, inventory.equipped_item("Weapon").get("name", "No weapon"), run_shards_earned, meta_power * 5]
	if victory:
		for burst in range(4):
			add_particles(Vector2(80 + burst * 105, 260 + (burst % 2) * 70), Color("#ffd766") if burst % 2 == 0 else Color("#81e6ff"), 18)
	refresh_meta_button()

func buy_meta_power() -> void:
	if state != "result":
		return
	var cost := 10 + meta_power * 5
	if meta_shards >= cost:
		meta_shards -= cost
		meta_power += 1
		save_meta()
		refresh_meta_button()
		result_summary.text += "\nPower upgraded!"

func refresh_meta_button() -> void:
	var cost := 10 + meta_power * 5
	meta_button.text = "PERMANENT POWER +5%%\nCost %d shards  -  You have %d" % [cost, meta_shards]
	meta_button.disabled = meta_shards < cost

func load_meta() -> void:
	var progress := MetaStore.load_progress(SAVE_PATH)
	meta_shards = progress.shards
	meta_power = progress.power

func save_meta() -> void:
	MetaStore.save_progress(SAVE_PATH, meta_shards, meta_power)

func _unhandled_input(event: InputEvent) -> void:
	if state != "playing":
		return
	var tapped := false
	if event is InputEventMouseButton:
		tapped = event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	elif event is InputEventScreenTouch:
		tapped = event.pressed
	elif event is InputEventKey:
		tapped = event.pressed and not event.echo and event.keycode == KEY_SPACE
	if tapped:
		perform_player_attack(true)
		get_viewport().set_input_as_handled()

func update_effects(delta: float) -> void:
	enemy_flash = maxf(0.0, enemy_flash - delta)
	player_flash = maxf(0.0, player_flash - delta)
	screen_shake = maxf(0.0, screen_shake - delta)
	squash = maxf(0.0, squash - delta)
	attack_anim = maxf(0.0, attack_anim - delta)
	enemy_squash = maxf(0.0, enemy_squash - delta)
	enemy_death_anim = maxf(0.0, enemy_death_anim - delta)
	enemy_entry_anim = maxf(0.0, enemy_entry_anim - delta)
	impact_flash = maxf(0.0, impact_flash - delta)
	tap_pulse = maxf(0.0, tap_pulse - delta)
	upgrade_flash = maxf(0.0, upgrade_flash - delta)
	wave_banner_timer = maxf(0.0, wave_banner_timer - delta)
	enemy_recoil = move_toward(enemy_recoil, 0.0, 115.0 * delta)
	for item in floating_texts:
		item.life -= delta
		item.pos.y -= 42.0 * delta
	for i in range(floating_texts.size() - 1, -1, -1):
		if floating_texts[i].life <= 0.0:
			floating_texts.remove_at(i)
	for particle in particles:
		particle.life -= delta
		particle.pos += particle.vel * delta
		particle.vel.y += 100.0 * delta
	for i in range(particles.size() - 1, -1, -1):
		if particles[i].life <= 0.0:
			particles.remove_at(i)
	for pickup in reward_pickups:
		if pickup.delay > 0.0:
			pickup.delay -= delta
			continue
		pickup.life -= delta
		var progress: float = 1.0 - clampf(pickup.life / pickup.max_life, 0.0, 1.0)
		pickup.pos = pickup.start.lerp(pickup.target, progress) + Vector2(0, -sin(progress * PI) * 72.0)
	for i in range(reward_pickups.size() - 1, -1, -1):
		if reward_pickups[i].life <= 0.0:
			reward_pickups.remove_at(i)
	for drop in loot_drops:
		drop.pickup -= delta
		drop.vel.y += 340.0 * delta
		drop.pos += drop.vel * delta
		if drop.pos.y >= 540.0 and drop.vel.y > 0.0:
			drop.pos.y = 540.0
			drop.vel.y = -drop.vel.y * (0.44 if int(drop.bounces) == 0 else 0.18)
			drop.vel.x *= 0.68
			drop.bounces += 1
	for i in range(loot_drops.size() - 1, -1, -1):
		if loot_drops[i].pickup <= 0.0:
			if not bool(loot_drops[i].get("boss_choice", false)):
				var found: Dictionary = loot_drops[i].item
				pending_items.append(found)
			add_particles(loot_drops[i].pos, loot_drops[i].color, 18)
			loot_drops.remove_at(i)

func add_float(text_value: String, pos: Vector2, color: Color, size_value: int) -> void:
	floating_texts.append({"text":text_value, "pos":pos, "color":color, "size":size_value, "life":0.8, "max_life":0.8})

func add_particles(pos: Vector2, color: Color, count: int) -> void:
	for i in range(count):
		particles.append({"pos":pos, "vel":Vector2(rng.randf_range(-105, 105), rng.randf_range(-155, -25)), "color":color, "life":rng.randf_range(0.25, 0.55), "max_life":0.55})

func add_reward_burst(coin_reward: int, xp_reward: float) -> void:
	var coin_count := mini(7, maxi(3, int(coin_reward / 8) + 3))
	for i in range(coin_count):
		var start := Vector2(360, 450) + Vector2(rng.randf_range(-24, 24), rng.randf_range(-18, 20))
		reward_pickups.append({"kind":"coin", "start":start, "pos":start, "target":Vector2(420, 35), "delay":i * 0.045, "life":0.72, "max_life":0.72})
	var xp_count := mini(5, maxi(2, int(xp_reward / 25.0) + 2))
	for i in range(xp_count):
		var start := Vector2(365, 450) + Vector2(rng.randf_range(-28, 28), rng.randf_range(-15, 22))
		reward_pickups.append({"kind":"xp", "start":start, "pos":start, "target":Vector2(250, 92), "delay":0.10 + i * 0.055, "life":0.78, "max_life":0.78})

func _draw() -> void:
	var sx := size.x / DESIGN_SIZE.x
	var sy := size.y / DESIGN_SIZE.y
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(sx, sy))
	var shake := Vector2.ZERO
	if screen_shake > 0.0:
		shake = Vector2(rng.randf_range(-4, 4), rng.randf_range(-3, 3))
	draw_background()
	draw_hud()
	draw_arena(shake)
	draw_effects()
	draw_moment_overlay()

func draw_background() -> void:
	draw_rect(Rect2(0, 0, 480, 854), Color("#101831"))
	draw_circle(Vector2(405, 310), 72, Color("#21335c"))
	draw_circle(Vector2(388, 293), 58, Color("#172447"))
	for i in range(9):
		var color := Color("#18264a") if i % 2 == 0 else Color("#15213f")
		draw_circle(Vector2(25 + i * 63, 275 + (i % 3) * 28), 115, color)
	draw_rect(Rect2(0, 510, 480, 304), Color("#243652"))
	draw_colored_polygon(PackedVector2Array([Vector2(0,545),Vector2(110,500),Vector2(220,548),Vector2(340,495),Vector2(480,540),Vector2(480,650),Vector2(0,650)]), Color("#314b64"))
	draw_line(Vector2(0, 511), Vector2(480, 511), Color("#49667c"), 3)
	for i in range(12):
		draw_circle(Vector2(18 + i * 43, 613 + (i % 4) * 29), 5, Color("#3f5c6d"))

func draw_hud() -> void:
	draw_rect(Rect2(0, 0, 480, 146), Color("#0b1229e8"), true)
	draw_rect(Rect2(0, 144, 480, 2), Color("#4e6394"), true)
	draw_string(title_font, Vector2(18, 35), "LOOTLINGS", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("#ffe178"))
	draw_string(body_font, Vector2(18, 62), "WAVE %02d / %02d" % [wave, RUN_LAST_WAVE], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#bac9eb"))
	draw_circle(Vector2(353, 29), 11, Color("#f7c94c"))
	draw_circle(Vector2(353, 29), 6, Color("#ffe990"))
	draw_string(body_font, Vector2(370, 36), "%d" % coins, HORIZONTAL_ALIGNMENT_LEFT, 90, 18, Color("#ffe078"))
	draw_string(body_font, Vector2(337, 63), "LV %d" % level, HORIZONTAL_ALIGNMENT_CENTER, 125, 15, Color("#9fddff"))
	draw_bar(Rect2(18, 77, 444, 18), xp / xp_needed, Color("#1d2948"), Color("#55caef"), "XP  %.0f / %.0f" % [xp, xp_needed], 12)
	draw_bar(Rect2(18, 106, 444, 25), player_hp / player_max_hp, Color("#38263d"), Color("#5ed78a"), "HP  %.0f / %.0f" % [player_hp, player_max_hp], 14)
	var wave_target := 1 if wave == 8 or wave == RUN_LAST_WAVE else ENEMIES_PER_WAVE
	draw_string(body_font, Vector2(60, 169), "%s     %d / %d" % ["BOSS" if enemy_is_boss else "MINIBOSS" if enemy_is_miniboss else "ENCOUNTER", mini(wave_kills + (0 if enemy_alive else 1), wave_target), wave_target], HORIZONTAL_ALIGNMENT_CENTER, 360, 14, Color("#9fb0d4"))

func draw_arena(shake: Vector2) -> void:
	var enemy_color := Color("#ff6f87") if enemy_is_boss else Color("#bf80ff") if enemy_is_miniboss else Color("#73d7a2")
	if enemy_flash > 0.0:
		enemy_color = Color.WHITE
	if enemy_alive:
		draw_string(body_font, Vector2(40, 210), enemy_name.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 400, 19, Color("#f4f7ff"))
		draw_bar(Rect2(75, 232, 330, 22), enemy_hp / enemy_max_hp, Color("#4b263d"), Color("#ffad45") if enemy_is_boss else Color("#ff6279"), "%.0f / %.0f" % [enemy_hp, enemy_max_hp], 13)
	elif state == "playing":
		draw_string(body_font, Vector2(90, 236), "Next foe incoming...", HORIZONTAL_ALIGNMENT_CENTER, 300, 17, Color("#aebee8"))
	var idle_bob := sin(run_time * 5.2) * 2.0
	var lunge := attack_anim / 0.22 * 10.0
	var player_pos := Vector2(player_x + lunge, 472 + idle_bob) + shake
	draw_lootling(player_pos, player_flash > 0.0)
	if enemy_alive:
		var entry_offset := ease(enemy_entry_anim / 0.55, 2.0) * 95.0
		var behavior_offset := Vector2.ZERO
		if not enemy_is_boss and not enemy_is_miniboss:
			match enemy_archetype:
				"skirmisher": behavior_offset = Vector2(-maxf(0.0, 1.0 - enemy_attack_clock / 0.18) * 18.0, sin(run_time * 8.0) * 3.0)
				"tank": behavior_offset = Vector2(0, sin(run_time * 2.2) * 1.0)
				"hexer": behavior_offset = Vector2(12.0 + sin(run_time * 2.5) * 6.0, sin(run_time * 3.2) * 5.0)
		var enemy_pos := Vector2(ENEMY_X + enemy_recoil + entry_offset, 467) + behavior_offset + shake
		draw_enemy(enemy_pos, enemy_color)
	elif enemy_death_anim > 0.0:
		var death_progress := 1.0 - enemy_death_anim / 0.62
		var death_color := enemy_color
		death_color.a = 1.0 - death_progress
		draw_enemy(Vector2(ENEMY_X + death_progress * 35.0, 467 - death_progress * 38.0) + shake, death_color, 1.0 + death_progress * 0.28)
	if status_clock > 0.0:
		draw_string(body_font, Vector2(25, 690), status_message, HORIZONTAL_ALIGNMENT_CENTER, 430, 19, Color("#ffe797"))
	draw_stats_strip()

func draw_lootling(pos: Vector2, hurt: bool) -> void:
	creature_renderer.draw_lootling(self, pos, hurt)

func draw_enemy(pos: Vector2, color: Color, extra_scale: float = 1.0) -> void:
	creature_renderer.draw_enemy(self, pos, color, extra_scale)

func draw_stats_strip() -> void:
	draw_rect(Rect2(18, 714, 444, 84), Color("#101831ee"), true)
	draw_rect(Rect2(18, 714, 444, 84), Color("#526b9b"), false, 2)
	var identity := build.dominant()
	var build_title := "RELIC CORE  -  DORMANT" if identity == "Neutral" else "%s CORE  -  %s" % [identity.to_upper(), build.tier_name(identity)]
	draw_string(body_font, Vector2(31, 735), build_title, HORIZONTAL_ALIGNMENT_LEFT, 300, 11, build.color())
	var lines := ["DMG  %.0f" % (base_damage * equipment_damage_multiplier()), "RATE  %.2fs" % current_attack_interval(), "CRIT  %d%%" % int(effective_crit_chance() * 100.0), "HITS  x%d" % multi_hits]
	for i in range(4):
		draw_rect(Rect2(27 + i * 108, 742, 102, 24), Color("#1d2a4a"), true)
		draw_string(body_font, Vector2(27 + i * 108, 760), lines[i], HORIZONTAL_ALIGNMENT_CENTER, 102, 13, Color("#e3edff"))
	draw_string(body_font, Vector2(30, 787), "%s  |  %s  |  %d SCRAP" % [inventory.weapon_family(), build_summary(), inventory.scrap], HORIZONTAL_ALIGNMENT_CENTER, 420, 12, Color("#9fb4dd"))

func build_summary() -> String:
	return build.short_summary()

func draw_bar(rect: Rect2, ratio: float, back: Color, fill: Color, text_value: String, font_size: int) -> void:
	draw_rect(Rect2(rect.position + Vector2(0, 2), rect.size + Vector2(0, 3)), Color("#05091675"), true)
	draw_rect(rect, back, true)
	draw_rect(Rect2(rect.position + Vector2(2, 2), Vector2(maxf(0.0, (rect.size.x - 4) * clampf(ratio, 0.0, 1.0)), rect.size.y - 4)), fill, true)
	draw_rect(Rect2(rect.position + Vector2(2, 2), Vector2(maxf(0.0, (rect.size.x - 4) * clampf(ratio, 0.0, 1.0)), 3)), fill.lightened(0.35), true)
	draw_rect(rect, Color("#7f94bc"), false, 2)
	draw_string(body_font, Vector2(rect.position.x + 4, rect.position.y + rect.size.y - 5), text_value, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 8, font_size, Color.WHITE)

func draw_effects() -> void:
	for drop in loot_drops:
		draw_loot_drop(drop)
	for pickup in reward_pickups:
		if pickup.delay > 0.0:
			continue
		var pop := clampf(pickup.life / pickup.max_life * 2.0, 0.0, 1.0)
		if pickup.kind == "coin":
			draw_circle(pickup.pos, 7.0 * pop, Color("#f4bd3e"))
			draw_circle(pickup.pos, 4.0 * pop, Color("#fff09a"))
		else:
			var radius := 7.0 * pop
			draw_colored_polygon(PackedVector2Array([pickup.pos + Vector2(0,-radius),pickup.pos + Vector2(radius,0),pickup.pos + Vector2(0,radius),pickup.pos + Vector2(-radius,0)]), Color("#70e5ff"))
	for particle in particles:
		var alpha: float = clampf(particle.life / particle.max_life, 0.0, 1.0)
		var color: Color = particle.color
		color.a = alpha
		draw_circle(particle.pos, 3.0 + 3.0 * alpha, color)
	for item in floating_texts:
		var alpha: float = clampf(item.life / item.max_life, 0.0, 1.0)
		var color: Color = item.color
		color.a = alpha
		draw_string(body_font, item.pos, item.text, HORIZONTAL_ALIGNMENT_CENTER, 150, item.size, color)

func draw_loot_drop(drop: Dictionary) -> void:
	var color: Color = drop.color
	var beam := color
	beam.a = 0.17 + sin(run_time * 9.0 + drop.pos.x) * 0.05
	draw_colored_polygon(PackedVector2Array([drop.pos + Vector2(-18, 8), drop.pos + Vector2(-6, -105), drop.pos + Vector2(6, -105), drop.pos + Vector2(18, 8)]), beam)
	var pulse := 1.0 + sin(run_time * 7.0 + drop.pos.x) * 0.08
	var halo := color
	halo.a = 0.22
	draw_circle(drop.pos, 22.0 * pulse, halo)
	draw_circle(drop.pos, 16.0 * pulse, Color("#10182cea"))
	draw_arc(drop.pos, 19.0 * pulse, run_time * 2.2, run_time * 2.2 + 4.7, 22, color.lightened(0.28), 3)
	var slot: String = drop.item.get("slot", "Relic")
	match slot:
		"Weapon":
			draw_line(drop.pos + Vector2(-8, 9), drop.pos + Vector2(8, -9), color.lightened(0.45), 5)
			draw_line(drop.pos + Vector2(-9, 1), drop.pos + Vector2(1, 11), Color("#f6d77b"), 3)
		"Armour":
			draw_colored_polygon(PackedVector2Array([drop.pos + Vector2(0,-10),drop.pos + Vector2(10,-5),drop.pos + Vector2(7,8),drop.pos + Vector2(0,12),drop.pos + Vector2(-7,8),drop.pos + Vector2(-10,-5)]), color)
		"Rune":
			for ray in range(4):
				var direction := Vector2.RIGHT.rotated(ray * PI * 0.5)
				draw_line(drop.pos - direction * 10.0, drop.pos + direction * 10.0, color.lightened(0.45), 3)
			draw_circle(drop.pos, 5, Color.WHITE)
		_:
			draw_arc(drop.pos, 9, 0, TAU, 20, color.lightened(0.42), 5)
			draw_circle(drop.pos, 3, Color("#fff2bd"))

func draw_moment_overlay() -> void:
	if impact_flash > 0.0:
		var flash_alpha := clampf(impact_flash * 1.8, 0.0, 0.16)
		draw_rect(Rect2(0, 146, 480, 555), Color(1.0, 0.94, 0.68, flash_alpha), true)
	if tap_pulse > 0.0 and tap_combo > 1:
		var pulse_alpha := clampf(tap_pulse / 0.18, 0.0, 1.0)
		draw_string(title_font, Vector2(285, 660), "TAP COMBO  x%d" % tap_combo, HORIZONTAL_ALIGNMENT_CENTER, 170, 17 + mini(tap_combo, 6), Color(0.55, 0.92, 1.0, pulse_alpha))
	if wave_banner_timer > 0.0:
		var fade := clampf(wave_banner_timer * 2.5, 0.0, 1.0)
		var banner_color := wave_banner_color
		banner_color.a = fade
		draw_rect(Rect2(0, 286, 480, 78), Color(0.03, 0.06, 0.16, 0.78 * fade), true)
		draw_rect(Rect2(0, 286, 480, 3), banner_color, true)
		draw_rect(Rect2(0, 361, 480, 3), banner_color, true)
		draw_string(title_font, Vector2(20, 339), wave_banner_text, HORIZONTAL_ALIGNMENT_CENTER, 440, 27, banner_color)
