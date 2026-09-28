extends Control

const DESIGN_SIZE := Vector2(480.0, 854.0)
const SAVE_PATH := "user://lootlings_save.cfg"
const RUN_LAST_WAVE := 15
const ENEMIES_PER_WAVE := 3
const PLAYER_HOME_X := 102.0
const PLAYER_ATTACK_X := 245.0
const ENEMY_X := 372.0

const UPGRADES := [
	{"id":"damage", "name":"HUGE HAMMER", "desc":"+35% damage", "icon":"HAMMER"},
	{"id":"speed", "name":"QUICK GRIP", "desc":"Attack 18% faster", "icon":"ZAP"},
	{"id":"crit", "name":"KEEN EDGE", "desc":"+12% crit chance", "icon":"CRIT"},
	{"id":"multi", "name":"TWIN BONK", "desc":"+1 hit each attack", "icon":"x2"},
	{"id":"splash", "name":"SHOCKWAVE", "desc":"Damage echoes to next foe", "icon":"WAVE"},
	{"id":"vamp", "name":"SNACKY FANG", "desc":"Heal 4% of damage dealt", "icon":"HEAL"},
	{"id":"armor", "name":"TIN LID", "desc":"+30 max HP, 8% less damage", "icon":"HP"},
	{"id":"frenzy", "name":"PANIC POWER", "desc":"Faster when hurt", "icon":"RAGE"},
	{"id":"tap", "name":"TAP TEMPEST", "desc":"Taps deal +80% damage", "icon":"TAP"},
	{"id":"execute", "name":"YEET", "desc":"Execute foes below 12% HP", "icon":"YEET"},
	{"id":"regen", "name":"BANDAGE", "desc":"Regenerate 1.5 HP/sec", "icon":"REGEN"},
	{"id":"greed", "name":"SHINY BRAIN", "desc":"+50% coins and XP", "icon":"LOOT"}
]

var rng := RandomNumberGenerator.new()
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
var enemy_alive := true
var spawn_clock := 0.0
var carried_shockwave := 0.0
var selected_upgrades: Array = []
var upgrade_counts := {}
var floating_texts: Array = []
var particles: Array = []
var screen_shake := 0.0
var enemy_flash := 0.0
var player_flash := 0.0
var squash := 0.0
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

func _ready() -> void:
	rng.randomize()
	title_font = ThemeDB.fallback_font
	body_font = ThemeDB.fallback_font
	build_overlay_ui()
	load_meta()
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
	meta_button.pressed.connect(buy_meta_power)
	result_panel.add_child(meta_button)
	restart_button = Button.new()
	restart_button.text = "START ANOTHER RUN"
	restart_button.position = Vector2(47, 415)
	restart_button.size = Vector2(330, 78)
	restart_button.add_theme_font_size_override("font_size", 20)
	restart_button.pressed.connect(start_run)
	result_panel.add_child(restart_button)
	help_label = make_label(self, "TAP / CLICK / SPACE = bonus attack", 14, Rect2(20, 815, 440, 26), HORIZONTAL_ALIGNMENT_CENTER, Color("#a9b7d7"))

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
	var meta_bonus := 1.0 + float(meta_power) * 0.05
	player_max_hp = 100.0 * meta_bonus
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
	floating_texts.clear()
	particles.clear()
	upgrade_panel.visible = false
	result_panel.visible = false
	help_label.visible = true
	run_shards_earned = 0
	status_message = "A new run begins!"
	status_clock = 2.5
	spawn_enemy()
	queue_redraw()

func spawn_enemy() -> void:
	enemy_is_miniboss = wave == 8
	enemy_is_boss = wave == RUN_LAST_WAVE
	var progress := pow(1.18, wave - 1)
	var type_bonus := 1.0
	if enemy_is_boss:
		type_bonus = 5.2
		enemy_name = "THE HOARD DRAGON"
	elif enemy_is_miniboss:
		type_bonus = 2.8
		enemy_name = "GRUMP KNIGHT"
	else:
		var names := ["Pocket Slime", "Mushroom Punk", "Dust Goblin", "Angry Turnip", "Sock Mimic"]
		enemy_name = names[(wave + wave_kills) % names.size()]
	enemy_max_hp = (24.0 + wave * 7.0) * progress * type_bonus
	enemy_hp = enemy_max_hp
	enemy_damage = (3.5 + wave * 0.92) * (1.3 if enemy_is_miniboss else 1.0) * (1.55 if enemy_is_boss else 1.0)
	enemy_attack_interval = maxf(0.85, 2.25 - wave * 0.045)
	enemy_attack_clock = enemy_attack_interval
	enemy_alive = true
	spawn_clock = 0.0
	player_x = minf(player_x, PLAYER_HOME_X + 30.0)
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
		spawn_clock -= delta
		if spawn_clock <= 0.0:
			spawn_enemy()
		queue_redraw()
		return
	if player_x < PLAYER_ATTACK_X:
		player_x = minf(PLAYER_ATTACK_X, player_x + 155.0 * delta)
	else:
		attack_clock -= delta
		if attack_clock <= 0.0:
			attack_clock += current_attack_interval()
			perform_player_attack(false)
		enemy_attack_clock -= delta
		if enemy_attack_clock <= 0.0:
			enemy_attack_clock += enemy_attack_interval
			perform_enemy_attack()
	queue_redraw()

func current_attack_interval() -> float:
	var result := attack_interval
	if frenzy > 0.0:
		result /= 1.0 + frenzy * (1.0 - player_hp / player_max_hp)
	return maxf(0.16, result)

func perform_player_attack(is_tap: bool) -> void:
	if state != "playing" or not enemy_alive or player_x < PLAYER_ATTACK_X - 4.0:
		return
	var hit_count := 1 if is_tap else multi_hits
	var damage_scale := tap_mult if is_tap else 1.0
	if is_tap:
		tap_combo += 1
		combo_clock = 0.7
		damage_scale *= 1.0 + minf(tap_combo, 10) * 0.025
	for hit_index in range(hit_count):
		if not enemy_alive:
			break
		var is_crit := rng.randf() < crit_chance
		var damage := base_damage * damage_scale * (crit_mult if is_crit else 1.0) * rng.randf_range(0.92, 1.08)
		damage_enemy(damage, is_crit, is_tap)
		if hit_count > 1 and hit_index < hit_count - 1:
			add_particles(Vector2(337, 475), Color("#d6a8ff"), 3)
	squash = 0.14

func damage_enemy(amount: float, is_crit: bool, is_tap: bool) -> void:
	enemy_hp -= amount
	enemy_flash = 0.11
	screen_shake = 0.09 if is_crit else 0.045
	var text := ("CRIT! %.0f" if is_crit else "%.0f") % amount
	if is_tap and not is_crit:
		text = "TAP %.0f" % amount
	add_float(text, Vector2(360 + rng.randf_range(-18, 18), 420), Color("#fff178") if is_crit else Color.WHITE, 23 if is_crit else 18)
	add_particles(Vector2(342, 475), Color("#ffda69") if is_crit else Color("#b8efff"), 8 if is_crit else 4)
	player_hp = minf(player_max_hp, player_hp + amount * life_steal)
	carried_shockwave += amount * splash_ratio
	if execute_ratio > 0.0 and enemy_hp > 0.0 and enemy_hp / enemy_max_hp <= execute_ratio:
		add_float("YEET!", Vector2(355, 385), Color("#ff8bd8"), 28)
		enemy_hp = 0.0
	if enemy_hp <= 0.0:
		kill_enemy()

func perform_enemy_attack() -> void:
	if not enemy_alive:
		return
	var damage := enemy_damage * (1.0 - minf(armor, 0.65))
	player_hp -= damage
	player_flash = 0.13
	screen_shake = 0.08
	add_float("-%.0f" % damage, Vector2(150, 432), Color("#ff7a84"), 19)
	add_particles(Vector2(170, 478), Color("#ff768c"), 5)
	if player_hp <= 0.0:
		player_hp = 0.0
		end_run(false)

func kill_enemy() -> void:
	enemy_alive = false
	spawn_clock = 0.55
	enemy_hp = 0.0
	total_kills += 1
	wave_kills += 1
	var reward := int(round((5.0 + wave * 1.8) * reward_mult * (4.0 if enemy_is_boss else 2.0 if enemy_is_miniboss else 1.0)))
	coins += reward
	var xp_reward := (13.0 + wave * 2.2) * reward_mult * (2.6 if enemy_is_boss else 1.8 if enemy_is_miniboss else 1.0)
	add_xp(xp_reward)
	add_float("+%d COINS" % reward, Vector2(346, 355), Color("#ffd65a"), 19)
	add_particles(Vector2(365, 480), Color("#ffd65a"), 16)
	status_message = "%s defeated!" % enemy_name
	status_clock = 1.2
	if enemy_is_boss:
		end_run(true)
		return
	if wave_kills >= ENEMIES_PER_WAVE or enemy_is_miniboss:
		wave += 1
		wave_kills = 0
		player_hp = minf(player_max_hp, player_hp + player_max_hp * 0.20)
		status_message = "WAVE %d - enemies grow stronger!" % wave
		status_clock = 2.0
	carried_shockwave = minf(carried_shockwave, base_damage * 12.0)

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
		upgrade_buttons[i].text = "%s   %s\n%s%s" % [up.icon, up.name, up.desc, "  (owned %d)" % stacks if stacks > 0 else ""]
	upgrade_title.text = "LEVEL %d - PICK ONE" % level
	upgrade_panel.visible = true

func choose_upgrade(index: int) -> void:
	if state != "upgrade" or index < 0 or index >= selected_upgrades.size():
		return
	var up: Dictionary = selected_upgrades[index]
	var id: String = up.id
	upgrade_counts[id] = int(upgrade_counts.get(id, 0)) + 1
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
	status_message = "%s acquired!" % up.name
	status_clock = 2.0
	pending_levels -= 1
	upgrade_panel.visible = false
	if pending_levels > 0:
		show_upgrade_choices()
	else:
		state = "playing"
	queue_redraw()

func end_run(victory: bool) -> void:
	state = "result"
	upgrade_panel.visible = false
	result_panel.visible = true
	help_label.visible = false
	run_shards_earned = (10 + level * 2 + wave) if victory else max(2, int(level + wave * 0.5))
	meta_shards += run_shards_earned
	save_meta()
	result_title.text = "HOARD CONQUERED!" if victory else "BONKED OUT!"
	result_title.add_theme_color_override("font_color", Color("#ffe178") if victory else Color("#ff8995"))
	result_summary.text = "Wave %d / %d\nLevel %d  -  %d enemies\n%d coins gathered\n\n+%d star shards\nPermanent power: +%d%%" % [wave, RUN_LAST_WAVE, level, total_kills, coins, run_shards_earned, meta_power * 5]
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
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	meta_shards = clampi(int(config.get_value("progress", "shards", 0)), 0, 999999)
	meta_power = clampi(int(config.get_value("progress", "power", 0)), 0, 100)

func save_meta() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "version", 1)
	config.set_value("progress", "shards", meta_shards)
	config.set_value("progress", "power", meta_power)
	config.save(SAVE_PATH)

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

func add_float(text_value: String, pos: Vector2, color: Color, size_value: int) -> void:
	floating_texts.append({"text":text_value, "pos":pos, "color":color, "size":size_value, "life":0.8, "max_life":0.8})

func add_particles(pos: Vector2, color: Color, count: int) -> void:
	for i in range(count):
		particles.append({"pos":pos, "vel":Vector2(rng.randf_range(-105, 105), rng.randf_range(-155, -25)), "color":color, "life":rng.randf_range(0.25, 0.55), "max_life":0.55})

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

func draw_background() -> void:
	draw_rect(Rect2(0, 0, 480, 854), Color("#101831"))
	for i in range(9):
		var color := Color("#18264a") if i % 2 == 0 else Color("#15213f")
		draw_circle(Vector2(25 + i * 63, 275 + (i % 3) * 28), 115, color)
	draw_rect(Rect2(0, 510, 480, 304), Color("#243652"))
	draw_colored_polygon(PackedVector2Array([Vector2(0,545),Vector2(110,500),Vector2(220,548),Vector2(340,495),Vector2(480,540),Vector2(480,650),Vector2(0,650)]), Color("#314b64"))
	for i in range(12):
		draw_circle(Vector2(18 + i * 43, 613 + (i % 4) * 29), 5, Color("#3f5c6d"))

func draw_hud() -> void:
	draw_string(title_font, Vector2(18, 40), "LOOTLINGS", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("#ffe178"))
	draw_string(body_font, Vector2(18, 67), "WAVE %d / %d" % [wave, RUN_LAST_WAVE], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#dce7ff"))
	draw_string(body_font, Vector2(282, 39), "COINS  %d" % coins, HORIZONTAL_ALIGNMENT_RIGHT, 180, 18, Color("#ffd75e"))
	draw_string(body_font, Vector2(282, 66), "LEVEL  %d" % level, HORIZONTAL_ALIGNMENT_RIGHT, 180, 17, Color("#baddff"))
	draw_bar(Rect2(18, 82, 444, 20), xp / xp_needed, Color("#263457"), Color("#64d9ff"), "XP %.0f / %.0f" % [xp, xp_needed], 13)
	draw_bar(Rect2(18, 112, 444, 24), player_hp / player_max_hp, Color("#472c46"), Color("#69df8d"), "HP %.0f / %.0f" % [player_hp, player_max_hp], 15)
	var wave_target := 1 if wave == 8 or wave == RUN_LAST_WAVE else ENEMIES_PER_WAVE
	draw_string(body_font, Vector2(60, 163), "%s  -  %d / %d" % ["BOSS" if enemy_is_boss else "MINIBOSS" if enemy_is_miniboss else "ENEMIES", mini(wave_kills + (0 if enemy_alive else 1), wave_target), wave_target], HORIZONTAL_ALIGNMENT_CENTER, 360, 16, Color("#aebee8"))

func draw_arena(shake: Vector2) -> void:
	var enemy_color := Color("#ff6f87") if enemy_is_boss else Color("#bf80ff") if enemy_is_miniboss else Color("#73d7a2")
	if enemy_flash > 0.0:
		enemy_color = Color.WHITE
	if enemy_alive:
		draw_string(body_font, Vector2(40, 215), enemy_name, HORIZONTAL_ALIGNMENT_CENTER, 400, 21, Color("#f4f7ff"))
		draw_bar(Rect2(75, 232, 330, 22), enemy_hp / enemy_max_hp, Color("#4b263d"), Color("#ffad45") if enemy_is_boss else Color("#ff6279"), "%.0f / %.0f" % [enemy_hp, enemy_max_hp], 13)
	elif state == "playing":
		draw_string(body_font, Vector2(90, 236), "Next foe incoming...", HORIZONTAL_ALIGNMENT_CENTER, 300, 17, Color("#aebee8"))
	var player_pos := Vector2(player_x, 472) + shake
	draw_lootling(player_pos, player_flash > 0.0)
	if enemy_alive:
		draw_enemy(Vector2(ENEMY_X, 467) + shake, enemy_color)
	if status_clock > 0.0:
		draw_string(body_font, Vector2(25, 690), status_message, HORIZONTAL_ALIGNMENT_CENTER, 430, 19, Color("#ffe797"))
	draw_stats_strip()

func draw_lootling(pos: Vector2, hurt: bool) -> void:
	var body_color := Color("#f6f8ff") if hurt else Color("#7ad9ff")
	var scale_y := 0.82 if squash > 0.0 else 1.0
	draw_set_transform(pos, -0.03, Vector2(1.0, scale_y))
	draw_circle(Vector2(0, 8), 43, Color("#20304e"))
	draw_circle(Vector2.ZERO, 40, body_color)
	draw_circle(Vector2(-24, -28), 16, body_color)
	draw_circle(Vector2(24, -28), 16, body_color)
	draw_circle(Vector2(-13, -5), 5, Color("#152037"))
	draw_circle(Vector2(13, -5), 5, Color("#152037"))
	draw_arc(Vector2(0, 4), 13, 0.3, PI - 0.3, 16, Color("#315175"), 3)
	draw_line(Vector2(27, 18), Vector2(83, -45), Color("#b77942"), 10)
	draw_set_transform(pos + Vector2(81, -49), -0.28, Vector2.ONE)
	draw_rect(Rect2(-27, -18, 55, 36), Color("#ffcf58"), true)
	draw_rect(Rect2(-27, -18, 55, 36), Color("#fff0a0"), false, 4)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_enemy(pos: Vector2, color: Color) -> void:
	draw_set_transform(pos, 0.0, Vector2.ONE)
	var radius := 58.0 if enemy_is_boss else 48.0 if enemy_is_miniboss else 39.0
	draw_circle(Vector2(0, 10), radius + 4, Color("#311f3b"))
	draw_circle(Vector2(0, 4), radius, color)
	if enemy_is_boss:
		draw_colored_polygon(PackedVector2Array([Vector2(-42,-20),Vector2(-29,-67),Vector2(-9,-35),Vector2(10,-72),Vector2(29,-34),Vector2(47,-61),Vector2(39,-15)]), Color("#ffb33e"))
	elif enemy_is_miniboss:
		draw_rect(Rect2(-43, -43, 86, 26), Color("#8e97ae"), true)
	else:
		draw_circle(Vector2(-23, -25), 14, color)
		draw_circle(Vector2(23, -25), 14, color)
	draw_circle(Vector2(-14, -5), 5, Color("#271c35"))
	draw_circle(Vector2(14, -5), 5, Color("#271c35"))
	draw_line(Vector2(-12, 19), Vector2(12, 17), Color("#51243f"), 3)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_stats_strip() -> void:
	draw_rect(Rect2(18, 718, 444, 78), Color("#111a33d9"), true)
	draw_rect(Rect2(18, 718, 444, 78), Color("#526b9b"), false, 2)
	var lines := ["DMG %.0f" % base_damage, "SPEED %.2fs" % current_attack_interval(), "CRIT %d%%" % int(crit_chance * 100.0), "HITS x%d" % multi_hits]
	for i in range(4):
		draw_string(body_font, Vector2(21 + i * 110, 750), lines[i], HORIZONTAL_ALIGNMENT_CENTER, 105, 14, Color("#dce7ff"))
	draw_string(body_font, Vector2(30, 779), "BUILD: %s" % build_summary(), HORIZONTAL_ALIGNMENT_CENTER, 420, 13, Color("#9fb4dd"))

func build_summary() -> String:
	if upgrade_counts.is_empty():
		return "No upgrades yet"
	var parts: Array[String] = []
	for key in upgrade_counts:
		parts.append("%s x%d" % [key, upgrade_counts[key]])
	return ", ".join(parts).left(55)

func draw_bar(rect: Rect2, ratio: float, back: Color, fill: Color, text_value: String, font_size: int) -> void:
	draw_rect(rect, back, true)
	draw_rect(Rect2(rect.position + Vector2(2, 2), Vector2(maxf(0.0, (rect.size.x - 4) * clampf(ratio, 0.0, 1.0)), rect.size.y - 4)), fill, true)
	draw_rect(rect, Color("#9db1d3"), false, 2)
	draw_string(body_font, Vector2(rect.position.x + 4, rect.position.y + rect.size.y - 5), text_value, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 8, font_size, Color.WHITE)

func draw_effects() -> void:
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
