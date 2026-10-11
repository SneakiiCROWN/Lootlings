extends RefCounted

# Presentation only: read existing combat clocks, never change damage or RNG.
var health_trails := {}
var boss_action := ""
var boss_action_time := 0.0
var player_prepared:=false
var contacts: Array[Dictionary] = []
var incoming_contacts: Array[Dictionary] = []
var previous_ward: float = -1.0
var ward_gain: float = 0.0
var ward_gain_life: float = 0.0
const CONTACT_LIMIT := 12

static func name_lines(font: Font, text: String, width: float, font_size: int) -> Array[String]:
	var lines: Array[String]=[]
	var line:=""
	for word in text.split(" ",false):
		var candidate:=word if line.is_empty() else line+" "+word
		if not line.is_empty() and font.get_string_size(candidate,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>width:
			lines.append(line);line=word
		else:line=candidate
	if not line.is_empty():lines.append(line)
	# Preserve names, including long words; grow the HUD by actual line count.
	var fitted: Array[String] = []
	for entry in lines:
		var chunk := ""
		for character in entry:
			if not chunk.is_empty() and font.get_string_size(chunk + character, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > width:
				fitted.append(chunk); chunk = ""
			chunk += character
		if not chunk.is_empty(): fitted.append(chunk)
	lines = fitted
	return lines

func reset() -> void:
	health_trails.clear()
	contacts.clear()
	incoming_contacts.clear()
	previous_ward=-1;ward_gain=0;ward_gain_life=0
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

func record_contact(g, critical: bool, heavy: bool) -> void:
	# Capture this actor before a kill/projectile/pack callback changes selection.
	var pos: Vector2=g.target_combat_visual_position()+Vector2(0,-29)
	var weapon: String=g.inventory.equipped_item("Weapon").get("weapon_type","")
	var event := {"serial":g.enemy_serial,"pos":pos,"origin":preload("res://weapon_fit_catalog.gd").projectile_origin(g),"material":preload("res://regional_enemy_presentation.gd").material(g),"facing":g.enemy_facing_at(pos.x),"critical":critical,"heavy":heavy or weapon in ["greatsword","greataxe","maul"],"weapon":weapon,"life":.18,"duration":.18}
	contacts.append(event)
	while contacts.size()>CONTACT_LIMIT: contacts.pop_front()

func record_incoming(g, absorbed: float, damage: float) -> void:
	var pos: Vector2=preload("res://weapon_fit_catalog.gd").world_position(g)+Vector2(0,-24)
	incoming_contacts.append({"pos":pos,"origin":g.target_combat_visual_position()+Vector2(25*g.enemy_facing_at(g.target_combat_visual_position().x),-24),"ward":absorbed>0,"damage":damage>0,"life":.18})
	while incoming_contacts.size()>6:incoming_contacts.pop_front()

func step(g, delta: float) -> void:
	ward_gain_life=maxf(0,ward_gain_life-delta)
	if g.state=="playing" and previous_ward>=0 and float(g.player_ward)>previous_ward+.01:
		ward_gain=float(g.player_ward)-previous_ward;ward_gain_life=.42
		g.play_audio_event("ward")
	previous_ward=float(g.player_ward)
	for event in incoming_contacts:event.life=maxf(0,float(event.life)-delta)
	incoming_contacts=incoming_contacts.filter(func(event):return event.life>0)
	for event in contacts: event.life=maxf(0,float(event.life)-delta)
	contacts=contacts.filter(func(event):return event.life>0)
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
	var special: bool = (g.enemy_attack_count + 1) % 3 == 0
	var mend: bool = not g.enemy_is_boss and not g.enemy_is_miniboss and g.enemy_archetype == "hexer" and special
	var label := "HEAVY STRIKE" if g.enemy_is_miniboss or g.enemy_archetype == "tank" else "MEND" if mend else "HEX BOLT" if g.enemy_archetype == "hexer" else "QUICK STRIKE"
	var intent := "heal" if mend else "attack"
	var accent := Color("#91e7ba") if mend else Color("#d197ff") if g.enemy_archetype == "hexer" else Color("#ffb86b")
	var progress := clampf(1.0 - g.enemy_attack_clock / window, 0.0, 1.0)
	var visible: bool = g.state == "playing" and g.enemy_alive and g.enemy_entry_anim <= 0.0 and g.enemy_attack_clock <= window
	if g.enemy_is_boss or g.enemy_is_miniboss:
		var action: Dictionary = preload("res://boss_patterns.gd").next(g)
		label = str(action.text)
		if g.boss_recovery > 0:
			label = "TAP OPENING"
			intent = "opening"
			visible = g.state == "playing" and g.enemy_alive and g.enemy_entry_anim <= 0.0
			progress = clampf(g.boss_recovery / maxf(.001, minf(1.0, g.enemy_attack_interval * .65)), 0.0, 1.0)
		elif bool(action.recovery):
			intent = "recovery"
		if intent in ["recovery", "opening"]: accent = Color("#91e7ba")
	elif not mend:
		match str(g.enemy_variant_id):
			"overcharged":
				if special: label = "SPARK SURGE"; accent = Color("#6ee8ff")
			"frostbitten":
				if special: label = "FROST STRIKE"; accent = Color("#9fe7ff")
			"enraged":
				if g.enemy_hp / maxf(1, g.enemy_max_hp) < .35: label = "RAGE STRIKE"; accent = Color("#ff8d70")
			"leeching": label = "DRAIN STRIKE"; accent = Color("#d18abd")
	return {"visible":visible, "progress":progress, "label":label, "accent":accent, "intent":intent}

static func enemy_name_layout(g) -> Dictionary:
	var width:float=400.0 if g.enemy_is_boss else 195.0
	var font_size:int=17
	var lines:=name_lines(g.body_font,g.enemy_name.to_upper(),width-2,font_size)
	# Wrap at the preferred size first. Shrink only exceptionally tall names.
	while lines.size()>3 and font_size>14:
		font_size-=1
		lines=name_lines(g.body_font,g.enemy_name.to_upper(),width-2,font_size)
	return {"lines":lines,"font_size":font_size,"extra":18.0*maxi(0,lines.size()-1)}
static func cue_label_rect(g) -> Rect2:
	var layout:=enemy_name_layout(g)
	if g.enemy_is_boss:return Rect2(120,338+layout.extra if not g.enemy_variant_id.is_empty() else 312+layout.extra,240,28)
	var width:float=195.0
	var x:float=clampf(g.target_combat_visual_position().x-width*.5,16,480-width-16)
	return Rect2(x,(397 if not g.enemy_variant_id.is_empty() else 370)+layout.extra,width,22)
static func draw_cue(g, center: Vector2, scale_factor: float = 1.0, label_rect: Rect2 = Rect2()) -> void:
	if label_rect.size==Vector2.ZERO:label_rect=cue_label_rect(g)
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
	# Pack cards are narrower than solo HUDs. Fit full special-action names.
	var font_size: int = preload("res://lootlings_ui.gd").fitted_font_size(g.body_font, str(cue.label), label_rect.size.x - 8, 13, 10)
	g.draw_string(g.body_font, label_rect.position + Vector2(4, 18), str(cue.label), HORIZONTAL_ALIGNMENT_CENTER, label_rect.size.x - 8, font_size, accent)
