extends RefCounted

func draw_lootling(g, pos: Vector2, hurt: bool) -> void:
	var body_color := Color("#f6f8ff") if hurt else Color("#7ad9ff")
	var identity: String = g.build.dominant()
	var core_color: Color = g.build.color(identity)
	var evolution_tier: int = g.build.tier(identity)
	var weapon_growth: float = 1.0 + float(g.build.weapon_tier()) * 0.14
	var scale_y := 0.82 if g.squash > 0.0 else 1.0
	var scale_x := 1.13 if g.squash > 0.0 else 1.0
	if identity != "Neutral":
		for aura_index in range(3 + evolution_tier * 2):
			var angle: float = float(g.run_time) * (1.2 + aura_index * 0.08) + TAU * aura_index / float(3 + evolution_tier * 2)
			var aura_pos := pos + Vector2(cos(angle) * (45 + evolution_tier * 8), sin(angle) * (34 + evolution_tier * 5))
			var aura_color := core_color
			aura_color.a = 0.38
			g.draw_circle(aura_pos, 2.5 + evolution_tier, aura_color)
	g.draw_set_transform(pos, -0.03, Vector2(scale_x, scale_y))
	g.draw_set_transform(pos + Vector2(0, 46), 0.0, Vector2(1.0, 0.34))
	g.draw_circle(Vector2.ZERO, 43, Color("#0a1123a0"))
	g.draw_set_transform(pos, -0.03, Vector2(scale_x, scale_y))
	g.draw_arc(Vector2(-26, 30), 28, 0.7, 5.4, 28, Color("#274a75"), 13)
	g.draw_arc(Vector2(-26, 30), 17, 0.8, 5.2, 24, body_color.darkened(0.08), 9)
	g.draw_colored_polygon(PackedVector2Array([Vector2(-24,18),Vector2(-42,52),Vector2(-6,45)]), Color("#e75270"))
	g.draw_circle(Vector2(0, 30), 26, Color("#395fa4"))
	g.draw_rect(Rect2(-22, 24, 44, 15), Color("#f0c862"), true)
	g.draw_circle(Vector2(-17, 52), 10, Color("#24324f"))
	g.draw_circle(Vector2(17, 52), 10, Color("#24324f"))
	g.draw_circle(Vector2(-27, -27), 17, body_color)
	g.draw_circle(Vector2(27, -27), 17, body_color)
	g.draw_colored_polygon(PackedVector2Array([Vector2(-23,-36),Vector2(-17,-55),Vector2(-8,-35)]), Color("#f2d7a0"))
	g.draw_colored_polygon(PackedVector2Array([Vector2(23,-36),Vector2(17,-55),Vector2(8,-35)]), Color("#f2d7a0"))
	g.draw_circle(Vector2(0, 2), 43, Color("#20304e"))
	g.draw_circle(Vector2(0, -2), 41, body_color)
	g.draw_circle(Vector2(-15, -8), 9, Color.WHITE)
	g.draw_circle(Vector2(15, -8), 9, Color.WHITE)
	g.draw_circle(Vector2(-14, -7), 5, Color("#14203b"))
	g.draw_circle(Vector2(14, -7), 5, Color("#14203b"))
	g.draw_circle(Vector2(-12, -10), 2, Color.WHITE)
	g.draw_circle(Vector2(16, -10), 2, Color.WHITE)
	g.draw_circle(Vector2(-28, 8), 6, Color("#ff91ac80"))
	g.draw_circle(Vector2(28, 8), 6, Color("#ff91ac80"))
	g.draw_arc(Vector2(0, 5), 13, 0.25, PI - 0.25, 16, Color("#315175"), 3)
	g.draw_colored_polygon(PackedVector2Array([Vector2(10,12),Vector2(17,12),Vector2(13,22)]), Color.WHITE)
	g.draw_line(Vector2(-31, -28), Vector2(31, -28), Color("#f6c955"), 5)
	g.draw_colored_polygon(PackedVector2Array([Vector2(-8,-29),Vector2(0,-43),Vector2(8,-29)]), Color("#ffe783"))
	var glow_color := core_color
	glow_color.a = 0.20
	g.draw_circle(Vector2(0, 35), 13 + evolution_tier * 3, glow_color)
	g.draw_circle(Vector2(0, 35), 7 + evolution_tier * 2, core_color)
	g.draw_circle(Vector2(-2, 32), 2 + evolution_tier, core_color.lightened(0.55))
	if evolution_tier > 0:
		g.draw_arc(Vector2(0, 35), 11 + evolution_tier * 3, g.run_time * 2.0, g.run_time * 2.0 + 4.8, 18, core_color.lightened(0.25), 2 + evolution_tier)
	g.draw_line(Vector2(27, 22), Vector2(83, -45), Color("#a76939"), 11)
	var windup := clampf(1.0 - g.attack_clock / 0.16, 0.0, 1.0) if g.attack_anim <= 0.0 else 0.0
	var weapon_angle := lerpf(-0.28, -0.72, windup)
	if g.attack_anim > 0.0:
		weapon_angle = lerpf(-0.28, 0.42, g.attack_anim / 0.22)
	g.draw_set_transform(pos + Vector2(81, -49), weapon_angle, Vector2.ONE * weapon_growth)
	var weapon_color := core_color if identity != "Neutral" else Color("#ffcf58")
	g.draw_rect(Rect2(-31, -20, 62, 40), weapon_color.darkened(0.16), true)
	g.draw_rect(Rect2(-31, -20, 62, 40), weapon_color.lightened(0.28), false, 4)
	g.draw_circle(Vector2(-20, -8), 4, Color("#fff7c4"))
	match identity:
		"Fire":
			g.draw_colored_polygon(PackedVector2Array([Vector2(-10,18),Vector2(-2,-4),Vector2(5,9),Vector2(13,-17),Vector2(20,18)]), core_color.lightened(0.35))
		"Lightning":
			g.draw_polyline(PackedVector2Array([Vector2(-23,-12),Vector2(-7,-3),Vector2(-15,8),Vector2(5,1),Vector2(0,14),Vector2(24,5)]), core_color.lightened(0.45), 4)
		"Poison":
			g.draw_circle(Vector2(-11, 2), 7, core_color.lightened(0.2))
			g.draw_circle(Vector2(6, -7), 5, core_color.lightened(0.35))
			g.draw_circle(Vector2(17, 10), 4, core_color.darkened(0.2))
		"Physical":
			g.draw_colored_polygon(PackedVector2Array([Vector2(-28,-20),Vector2(-18,-32),Vector2(-7,-20)]), core_color.lightened(0.25))
			g.draw_colored_polygon(PackedVector2Array([Vector2(8,-20),Vector2(19,-33),Vector2(27,-20)]), core_color.lightened(0.25))
	g.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_enemy(g, pos: Vector2, color: Color, extra_scale: float = 1.0) -> void:
	var hit_scale := Vector2(1.16, 0.78) if g.enemy_squash > 0.0 and g.enemy_alive else Vector2.ONE
	g.draw_set_transform(pos, 0.0, hit_scale * extra_scale)
	var radius := 58.0 if g.enemy_is_boss else 48.0 if g.enemy_is_miniboss else 39.0
	var outline := Color("#311f3b")
	outline.a = color.a
	g.draw_circle(Vector2(0, 10), radius + 4, outline)
	g.draw_circle(Vector2(0, 38), radius * 0.56, color.darkened(0.22))
	g.draw_circle(Vector2(0, 4), radius, color)
	if g.enemy_is_boss:
		g.draw_colored_polygon(PackedVector2Array([Vector2(-42,-20),Vector2(-29,-67),Vector2(-9,-35),Vector2(10,-72),Vector2(29,-34),Vector2(47,-61),Vector2(39,-15)]), Color("#ffb33e"))
	elif g.enemy_is_miniboss:
		g.draw_rect(Rect2(-43, -43, 86, 26), Color("#8e97ae"), true)
	else:
		g.draw_circle(Vector2(-23, -25), 14, color)
		g.draw_circle(Vector2(23, -25), 14, color)
		match g.enemy_archetype:
			"skirmisher":
				g.draw_colored_polygon(PackedVector2Array([Vector2(-29,-31),Vector2(-21,-52),Vector2(-11,-33)]), Color("#e8c4a0"))
				g.draw_colored_polygon(PackedVector2Array([Vector2(29,-31),Vector2(21,-52),Vector2(11,-33)]), Color("#e8c4a0"))
			"tank":
				g.draw_arc(Vector2(0, -4), radius - 5, PI, TAU, 20, Color("#567064"), 10)
				g.draw_rect(Rect2(-51, 4, 22, 48), Color("#769184"), true)
				g.draw_circle(Vector2(-40, 28), 5, Color("#b7c7a6"))
			"hexer":
				g.draw_colored_polygon(PackedVector2Array([Vector2(-31,-26),Vector2(0,-66),Vector2(34,-25)]), Color("#6d4b90"))
				g.draw_line(Vector2(30, 15), Vector2(53, 52), Color("#9a6b3d"), 6)
				g.draw_circle(Vector2(55, 56), 10, Color("#cf73ff"))
	g.draw_circle(Vector2(-15, -6), 9, Color.WHITE)
	g.draw_circle(Vector2(15, -6), 9, Color.WHITE)
	g.draw_circle(Vector2(-13, -5), 5, Color("#271c35"))
	g.draw_circle(Vector2(13, -5), 5, Color("#271c35"))
	g.draw_circle(Vector2(-11, -8), 2, Color.WHITE)
	g.draw_circle(Vector2(15, -8), 2, Color.WHITE)
	g.draw_line(Vector2(-23, -18), Vector2(-7, -13), Color("#51243f"), 4)
	g.draw_line(Vector2(23, -18), Vector2(7, -13), Color("#51243f"), 4)
	g.draw_line(Vector2(-12, 20), Vector2(12, 18), Color("#51243f"), 3)
	if g.enemy_is_boss:
		g.draw_colored_polygon(PackedVector2Array([Vector2(-10,19),Vector2(-4,30),Vector2(1,19),Vector2(7,30),Vector2(12,18)]), Color.WHITE)
	g.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
