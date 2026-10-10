extends RefCounted

# Presentation only: read existing combat clocks, never change damage or RNG.
var health_trails := {}
var boss_action := ""
var boss_action_time := 0.0
var player_prepared:=false
var contacts: Array[Dictionary] = []
var incoming_contacts: Array[Dictionary] = []
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
	# Runtime authored names are short words; unusually long imported names
	# must still remain within the fixed two-line HUD rather than cover combat.
	if lines.size()>2:lines=[lines[0]," ".join(lines.slice(1))]
	for index in range(lines.size()):
		while font.get_string_size(lines[index],HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>width and lines[index].length()>1:
			lines[index]=lines[index].trim_suffix("…").left(lines[index].trim_suffix("…").length()-1)+"…"
	return lines

func reset() -> void:
	health_trails.clear()
	contacts.clear()
	incoming_contacts.clear()
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
	var ward: bool = not g.enemy_is_boss and not g.enemy_is_miniboss and g.enemy_archetype == "hexer" and (g.enemy_attack_count + 1) % 3 == 0
	var label := "HOARD STRIKE" if g.enemy_is_boss else "HEAVY STRIKE" if g.enemy_is_miniboss or g.enemy_archetype == "tank" else "WARD" if ward else "HEX BOLT" if g.enemy_archetype == "hexer" else "QUICK STRIKE"
	if g.enemy_is_boss or g.enemy_is_miniboss:
		label = str(preload("res://boss_patterns.gd").next(g).text)
	var accent := Color("#bca3ff") if ward else Color("#d197ff") if g.enemy_archetype == "hexer" and not g.enemy_is_boss and not g.enemy_is_miniboss else Color("#ffb86b")
	return {"visible":g.state == "playing" and g.enemy_alive and g.enemy_entry_anim <= 0.0 and g.enemy_attack_clock <= window, "progress":clampf(1.0 - g.enemy_attack_clock / window, 0.0, 1.0), "label":label, "accent":accent}

static func cue_label_rect(g) -> Rect2:
	if g.enemy_is_boss:return Rect2(120,312,240,28)
	var width:float=195.0
	var x:float=clampf(g.target_combat_visual_position().x-width*.5,16,480-width-16)
	var text:String=g.enemy_name.to_upper()
	var size:int=17
	while size>14 and g.body_font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x>width-2:size-=1
	var extra:float=18.0 if name_lines(g.body_font,text,width-2,size).size()>1 else 0.0
	return Rect2(x,370+extra,width,22)
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
	g.draw_string(g.body_font, label_rect.position + Vector2(4, 19), str(cue.label), HORIZONTAL_ALIGNMENT_CENTER, label_rect.size.x - 8, 13, accent)
