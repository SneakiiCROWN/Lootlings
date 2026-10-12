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
const HUD_Y := 157.0
var actors: Array[Dictionary] = []
var selected := 0
var active := false
var aoe_active := false
var compact_hud_skin: StyleBox
var hud_layout_cache := {}
var hud_group_key:=""
var hud_extra:=0.0

func clear() -> void:
	actors.clear()
	selected = 0
	active = false
	aoe_active = false
	hud_layout_cache.clear();hud_group_key="";hud_extra=0

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
		if hud_rect(index).has_point(point): return index
	return -1

func hud_rect(index: int) -> Rect2:
	return Rect2(12+index*(228 if actors.size()==2 else 156),HUD_Y,218 if actors.size()==2 else 144,108+hud_extra)

func hud_layout(font: Font, text: String, index: int) -> Dictionary:
	var group:String="|".join(actors.map(func(actor):return str(actor.enemy_name).to_upper()))
	if group!=hud_group_key:
		hud_group_key=group;hud_layout_cache.clear();hud_extra=0
		for actor in actors:
			var actor_width:float=206 if actors.size()==2 else 132
			var actor_size:=13
			var actor_lines:=preload("res://combat_presentation.gd").name_lines(font,str(actor.enemy_name).to_upper(),actor_width,actor_size)
			while actor_lines.size()>3 and actor_size>11:
				actor_size-=1;actor_lines=preload("res://combat_presentation.gd").name_lines(font,str(actor.enemy_name).to_upper(),actor_width,actor_size)
			hud_extra=maxf(hud_extra,maxi(0,actor_lines.size()-3)*14)
	var key:="%s:%d:%d:%d" % [text,actors.size(),index,font.get_instance_id()]
	if hud_layout_cache.has(key):return hud_layout_cache[key]
	var rect:=hud_rect(index)
	var width:=rect.size.x-12
	var font_size:=13
	var lines:=preload("res://combat_presentation.gd").name_lines(font,text,width,font_size)
	while lines.size()>3 and font_size>11:
		font_size-=1;lines=preload("res://combat_presentation.gd").name_lines(font,text,width,font_size)
	var result:={"rect":rect,"name_width":width,"font_size":font_size,"lines":lines,"bar":Rect2(rect.position+Vector2(6,59+hud_extra),Vector2(width,18)),"status_y":rect.position.y+82+hud_extra,"cue":Rect2(rect.position.x+6,HUD_Y+115+hud_extra,width,24)}
	if hud_layout_cache.size()>=24:hud_layout_cache.clear()
	hud_layout_cache[key]=result
	return result

func hud_skin() -> StyleBox:
	if compact_hud_skin==null:
		var source=UI.skin_style("hud_header_9slice")
		# These script fields are not exported Resource storage properties;
		# duplicate() does not retain their loaded textures. Copy explicitly.
		compact_hud_skin=preload("res://ui_surface_style.gd").new()
		compact_hud_skin.texture=source.texture
		compact_hud_skin.protected_margin=source.protected_margin
		compact_hud_skin.source_scale=.10
	return compact_hud_skin

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
		var layout:=hud_layout(g.body_font,str(g.enemy_name).to_upper(),index)
		var width: float=layout.name_width
		var x: float=layout.rect.position.x+6
		var accent := Color("#78e4ff") if index == original else Color("#8da3bd")
		# Full-size ornate caps crowd narrow three-enemy cards. Preserve the
		# accepted texture, reducing only its chrome scale and reserving content.
		g.draw_style_box(hud_skin(),layout.rect)
		if index==original:g.draw_line(layout.rect.position+Vector2(14,2),layout.rect.position+Vector2(layout.rect.size.x-14,2),accent,2,true)
		for line in range(layout.lines.size()):g.draw_string(g.body_font,Vector2(x,HUD_Y+23+line*14),layout.lines[line],HORIZONTAL_ALIGNMENT_CENTER,width,layout.font_size,accent)
		g.draw_bar(layout.bar, maxf(0, g.enemy_hp) / g.enemy_max_hp, Color("#4b263d"), Color("#ff6279"), "%s / %s" % [preload("res://display_numbers.gd").compact(int(maxf(0,g.enemy_hp))),preload("res://display_numbers.gd").compact(int(g.enemy_max_hp))], 12, g.combat_presentation.health_ratio(g.enemy_serial))
		g.combat_presentation.draw_cue(g, position(index) + Vector2(0, 35) + shake, scale_factor, layout.cue)
		if g.enemy_burn_dps > 0.0: UI.draw_icon(g.get_canvas_item(), UI.icon("status_burn"), Rect2(x + 2, layout.status_y, 18, 18))
		if g.enemy_poison_stacks > 0:
			UI.draw_icon(g.get_canvas_item(), UI.icon("status_poison"), Rect2(x + 26, layout.status_y, 18, 18))
			g.draw_string(g.body_font, Vector2(x + 46, layout.status_y+14), "×%d" % g.enemy_poison_stacks, HORIZONTAL_ALIGNMENT_LEFT, width-72, 13, Color("#92f068"))
		if not str(g.enemy_variant_id).is_empty(): UI.draw_icon(g.get_canvas_item(), UI.icon(preload("res://enemy_variant_catalog.gd").icon_id(g.enemy_variant_id)), Rect2(x + width - 20, layout.status_y, 18, 18))
		if index == original:
			g.draw_arc(position(index) + Vector2(0, 35), 33 * scale_factor, 0, TAU, 20, Color("#78e4ff"), 2)
	load_actor(g, original)
