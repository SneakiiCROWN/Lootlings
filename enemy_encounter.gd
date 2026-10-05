extends RefCounted
const UI = preload("res://lootlings_ui.gd")

# Bounded state adapter around the existing combat functions. Solo encounters
# never use this path; actor state is allocated only when an encounter spawns.
const FIELDS := [
	"enemy_name", "enemy_hp", "enemy_max_hp", "enemy_damage", "enemy_attack_interval",
	"enemy_attack_clock", "enemy_is_boss", "enemy_is_miniboss", "enemy_weapon_opening_used",
	"enemy_archetype", "enemy_hit_multiplier", "enemy_variant_id", "enemy_variant_name",
	"enemy_variant_color", "enemy_reward_multiplier", "enemy_xp_multiplier", "enemy_attack_count",
	"enemy_first_crit_used", "enemy_frostbell_used", "enemy_variant_guarded", "enemy_post_guard_hit_multiplier",
	"enemy_alive", "enemy_burn_dps", "enemy_burn_time", "enemy_poison_stacks", "enemy_poison_time",
	"dot_tick_clock", "enemy_flash", "enemy_attack_anim", "enemy_recoil", "enemy_squash",
	"enemy_death_anim", "enemy_entry_anim", "enemy_serial",
	"enemy_trait_opening_used","enemy_trait_crit_used","enemy_control_budget","enemy_status_ward_used","enemy_chime_primed",
]
const VISUAL_TIMERS := ["enemy_flash", "enemy_attack_anim", "enemy_squash", "enemy_death_anim", "enemy_entry_anim"]
const HUD_Y := 307.0
var actors: Array[Dictionary] = []
var selected := 0
var active := false
var aoe_active := false

func clear() -> void:
	actors.clear()
	selected = 0
	active = false
	aoe_active = false

func capture(g) -> void:
	if not active: return
	for field in FIELDS: actors[selected][field] = g.get(field)

func load_actor(g, index: int) -> void:
	selected = index
	for field in FIELDS: g.set(field, actors[index][field])

func add_actor(g) -> void:
	var actor: Dictionary = {}
	for field in FIELDS: actor[field] = g.get(field)
	actors.append(actor)

func begin(g, count: int) -> void:
	clear()
	var kills: int = g.wave_kills
	for index in range(clampi(count, 2, 3)):
		g.wave_kills = kills + index
		g.spawn_single_enemy()
		g.enemy_weapon_opening_used = false
		g.enemy_damage *= 0.58 if count == 2 else 0.42
		g.enemy_attack_clock += index * 0.42
		add_actor(g)
	g.wave_kills = kills
	active = true
	load_actor(g, 0)
	g.player_x = minf(g.player_x, 170.0)

func position(index: int) -> Vector2:
	return Vector2(310 + index * 106, 515) if actors.size() == 2 else Vector2(278 + index * 79, 518)

func target_position() -> Vector2:
	return position(selected)

func select(g, index: int) -> bool:
	if not active or index < 0 or index >= actors.size(): return false
	capture(g)
	if not actors[index].enemy_alive: return false
	load_actor(g, index)
	return true

func select_at(g, point: Vector2) -> bool:
	if not active: return false
	for index in range(actors.size()):
		if Rect2(preload("res://combat_stage.gd").enemy_position(g,position(index).x) - Vector2(45, 82), Vector2(90, 150)).has_point(point) or card_at(point)==index:
			return select(g, index)
	return false

func card_at(point: Vector2) -> int:
	if not active: return -1
	for index in range(actors.size()):
		if Rect2(12+index*(228 if actors.size()==2 else 156),HUD_Y,218 if actors.size()==2 else 144,72).has_point(point): return index
	return -1

func on_death(g) -> void:
	capture(g)
	for index in range(actors.size()):
		if actors[index].enemy_alive:
			load_actor(g, index)
			return
	# Keep the last death pose and highest serial; future projectiles cannot bind
	# to a reused actor ID. The existing group-complete/wave logic owns rewards.
	for actor in actors: g.enemy_serial = maxi(g.enemy_serial, int(actor.enemy_serial))
	active = false

func step(g, delta: float) -> void:
	capture(g)
	var target := selected
	for index in range(actors.size()):
		if index != target:
			for timer in VISUAL_TIMERS: actors[index][timer] = maxf(0.0, float(actors[index][timer]) - delta)
			actors[index].enemy_recoil = move_toward(float(actors[index].enemy_recoil), 0.0, 115.0 * delta)
		if not active or g.state != "playing": break
		if not actors[index].enemy_alive: continue
		load_actor(g, index)
		g.enemy_attack_clock -= delta
		g.enemy_control_budget = minf(.5,g.enemy_control_budget+delta*.25)
		if g.enemy_attack_clock <= 0.0:
			g.enemy_attack_clock += g.enemy_attack_interval
			g.perform_enemy_attack(0.62 if g.player_x < g.target_player_x() else 1.0)
		g.update_elemental_damage(delta)
		capture(g)
	if not active: return
	if actors[target].enemy_alive: load_actor(g, target)
	if g.state != "playing": return
	var stance: float = g.target_player_x()
	g.player_x = minf(stance, g.player_x + 155.0 * float(g.character_trait.get("move",1.0)) * delta)
	if g.player_x >= stance and g.tap_buffer_timer > 0.0:
		g.tap_buffer_timer = 0.0
		g.perform_player_attack(true)
	g.attack_clock -= delta
	if g.player_x >= stance and g.attack_clock <= 0.0:
		g.attack_clock += g.current_attack_interval()
		g.perform_player_attack(false)
	capture(g)

func resolve_projectile(g, serial: int, tapped: bool) -> void:
	capture(g)
	var original := selected
	for index in range(actors.size()):
		if actors[index].enemy_alive and int(actors[index].enemy_serial) == serial:
			load_actor(g, index)
			g.resolve_player_attack(tapped)
			capture(g)
			break
	if active and actors[original].enemy_alive: load_actor(g, original)

func resolve_echo(g, serial: int, power: float) -> void:
	capture(g)
	var original := selected
	for index in range(actors.size()):
		if int(actors[index].enemy_serial) == serial and actors[index].enemy_alive:
			load_actor(g,index); g.deal_elemental_hit(power,"Physical"); capture(g)
			break
	if active and actors[original].enemy_alive: load_actor(g,original)

func splash(g, damage: float, identity: String, origin_serial: int = -1) -> void:
	if not active or aoe_active: return
	capture(g)
	var original := selected
	aoe_active = true
	for index in range(actors.size()):
		if not active: break
		if int(actors[index].enemy_serial) == origin_serial or (origin_serial == -1 and index == original) or not actors[index].enemy_alive: continue
		load_actor(g, index)
		g.deal_elemental_hit(damage, identity)
		capture(g)
	aoe_active = false
	if active and actors[original].enemy_alive: load_actor(g, original)

func draw(g, shake: Vector2) -> void:
	capture(g)
	var original := selected
	for index in range(actors.size()):
		load_actor(g, index)
		var scale_factor := 0.82 if actors.size() == 2 else 0.64
		if g.enemy_alive or g.enemy_death_anim > 0.0:
			var alpha: float = 1.0 if g.enemy_alive else clampf(g.enemy_death_anim / 0.5, 0.0, 1.0)
			g.draw_enemy(preload("res://combat_stage.gd").enemy_position(g,position(index).x) + Vector2(g.enemy_recoil * 0.35, sin(g.run_time * 3.0 + index) * 1.5) + shake, Color(1, 1, 1, alpha) if g.enemy_flash > 0.0 else Color(0.45, 0.84, 0.64, alpha), scale_factor)
		if g.state != "playing": continue
		var width := 218.0 if actors.size() == 2 else 144.0
		var x := 12.0 + index * (228.0 if actors.size() == 2 else 156.0)
		var accent := Color("#78e4ff") if index == original else Color("#8da3bd")
		g.draw_string(g.body_font, Vector2(x, HUD_Y+13), ("▸ " if index == original else "") + str(g.enemy_name).left(22 if actors.size() == 2 else 15), HORIZONTAL_ALIGNMENT_CENTER, width, 13, accent)
		g.draw_bar(Rect2(x, HUD_Y+22, width, 20), maxf(0, g.enemy_hp) / g.enemy_max_hp, Color("#4b263d"), Color("#ff6279"), "%.0f / %.0f" % [maxf(0, g.enemy_hp), g.enemy_max_hp], 12, g.combat_presentation.health_ratio(g.enemy_serial))
		g.combat_presentation.draw_cue(g, position(index) + Vector2(0, 35) + shake, scale_factor, Rect2(x, HUD_Y+85, width, 28))
		if g.enemy_burn_dps > 0.0: UI.draw_icon(g.get_canvas_item(), UI.icon("status_burn"), Rect2(x + 8, HUD_Y+47, 18, 18))
		if g.enemy_poison_stacks > 0:
			UI.draw_icon(g.get_canvas_item(), UI.icon("status_poison"), Rect2(x + 32, HUD_Y+47, 18, 18))
			g.draw_string(g.body_font, Vector2(x + 52, HUD_Y+61), "×%d" % g.enemy_poison_stacks, HORIZONTAL_ALIGNMENT_LEFT, 38, 13, Color("#92f068"))
		if not str(g.enemy_variant_id).is_empty(): UI.draw_icon(g.get_canvas_item(), UI.icon(preload("res://enemy_variant_catalog.gd").icon_id(g.enemy_variant_id)), Rect2(x + width - 26, HUD_Y+47, 18, 18))
		if index == original:
			g.draw_arc(position(index) + Vector2(0, 35), 33 * scale_factor, 0, TAU, 20, Color("#78e4ff"), 2)
	load_actor(g, original)
