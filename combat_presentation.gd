extends RefCounted

# Presentation only: read existing combat clocks, never change damage or RNG.
var health_trails := {}
var boss_action := ""
var boss_action_time := 0.0
var player_prepared:=false

func reset() -> void:
	health_trails.clear()
	boss_action=""; boss_action_time=0
	player_prepared=false

func register_enemy(serial: int) -> void:
	health_trails[serial] = {"ratio":1.0, "last":1.0, "hold":0.0}
	# Solo turnover and packs have a fixed, tiny memory budget.
	var enemy_keys: Array = health_trails.keys().filter(func(key): return key != -1)
	while enemy_keys.size() > 3:
		health_trails.erase(enemy_keys.pop_front())

func update_health(key: int, hp: float, maximum: float, delta: float) -> void:
	var ratio := clampf(hp / maxf(1.0, maximum), 0.0, 1.0)
	if not health_trails.has(key):
		health_trails[key] = {"ratio":ratio, "last":ratio, "hold":0.0}
	var trail: Dictionary = health_trails[key]
	if ratio < float(trail.last): trail.hold = 0.18
	trail.last = ratio
	trail.hold = maxf(0.0, float(trail.hold) - delta)
	if ratio >= float(trail.ratio):
		trail.ratio = ratio
	elif float(trail.hold) <= 0.0:
		trail.ratio = move_toward(float(trail.ratio), ratio, delta * 0.8)

func step(g, delta: float) -> void:
	boss_action_time=maxf(0,boss_action_time-delta)
	if g.attack_clock>.22 or g.attack_anim>0: player_prepared=false
	if g.state=="playing" and g.enemy_alive and g.attack_clock<=.18 and g.attack_anim<=0 and not player_prepared:
		player_prepared=true
		var weapon: String=g.inventory.equipped_item("Weapon").get("weapon_type","")
		if weapon=="bow": g.play_audio_event("draw_bow")
		elif weapon in ["staff","wand","orb"]: g.play_audio_event("charge_staff")
	update_health(-1, g.player_hp, g.player_max_hp, delta)
	if g.enemy_encounter.active:
		g.enemy_encounter.capture(g)
		for actor in g.enemy_encounter.actors:
			update_health(int(actor.enemy_serial), actor.enemy_hp, actor.enemy_max_hp, delta)
	else:
		update_health(g.enemy_serial, g.enemy_hp, g.enemy_max_hp, delta)

func health_ratio(key: int) -> float:
	return float(health_trails.get(key, {}).get("ratio", -1.0))

static func attack_cue(g) -> Dictionary:
	var window := 0.70 if g.enemy_is_boss else 0.60 if g.enemy_is_miniboss or g.enemy_archetype == "tank" else 0.48 if g.enemy_archetype == "hexer" else 0.36
	var ward: bool = not g.enemy_is_boss and not g.enemy_is_miniboss and g.enemy_archetype == "hexer" and (g.enemy_attack_count + 1) % 3 == 0
	var label := "HOARD STRIKE" if g.enemy_is_boss else "HEAVY STRIKE" if g.enemy_is_miniboss or g.enemy_archetype == "tank" else "WARD" if ward else "HEX BOLT" if g.enemy_archetype == "hexer" else "QUICK STRIKE"
	if g.enemy_is_boss or g.enemy_is_miniboss:
		label = str(preload("res://boss_patterns.gd").next(g).text)
	var accent := Color("#bca3ff") if ward else Color("#d197ff") if g.enemy_archetype == "hexer" and not g.enemy_is_boss and not g.enemy_is_miniboss else Color("#ffb86b")
	return {"visible":g.state == "playing" and g.enemy_alive and g.enemy_entry_anim <= 0.0 and g.enemy_attack_clock <= window, "progress":clampf(1.0 - g.enemy_attack_clock / window, 0.0, 1.0), "label":label, "accent":accent}

static func draw_cue(g, center: Vector2, scale_factor: float = 1.0, label_rect: Rect2 = Rect2(120, 312, 240, 28)) -> void:
	var cue := attack_cue(g)
	if not cue.visible: return
	var accent: Color = cue.accent
	var radius := 24.0 * scale_factor
	# A steady silhouette plus a filling ring reads without relying on flashing.
	g.draw_arc(center, radius, 0, TAU, 32, Color(accent, 0.23), 3.0, true)
	if float(cue.progress) > 0.01:
		g.draw_arc(center, radius, -PI * 0.5, -PI * 0.5 + TAU * float(cue.progress), 32, accent, 3.0, true)
	g.draw_rect(label_rect, Color("#081022e8"), true)
	g.draw_line(label_rect.position, label_rect.position + Vector2(label_rect.size.x * float(cue.progress), 0), accent, 2.0)
	g.draw_string(g.body_font, label_rect.position + Vector2(4, 19), str(cue.label), HORIZONTAL_ALIGNMENT_CENTER, label_rect.size.x - 8, 13, accent)
