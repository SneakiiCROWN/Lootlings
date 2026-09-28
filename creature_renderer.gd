extends RefCounted

func draw_lootling(g, pos: Vector2, hurt: bool) -> void:
	var body_color := Color("#fff2d6") if hurt else Color("#f0d5aa")
	var fur_shadow := Color("#b77d59")
	var dark_fur := Color("#4c312f")
	var leather := Color("#684334")
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
	# Canonical neutral mascot: an enormous fluffy curled tail with brown tip.
	g.draw_arc(Vector2(-30, 29), 31, 0.55, 5.55, 30, dark_fur, 20)
	g.draw_arc(Vector2(-30, 29), 31, 0.62, 5.48, 30, body_color, 14)
	g.draw_arc(Vector2(-30, 29), 31, 3.45, 5.42, 16, fur_shadow, 13)
	g.draw_circle(Vector2(-53, 9), 12, fur_shadow)
	g.draw_circle(Vector2(-56, 29), 11, body_color)
	g.draw_circle(Vector2(-44, 48), 10, body_color)
	g.draw_circle(Vector2(-54, 8), 10, fur_shadow)
	g.draw_colored_polygon(PackedVector2Array([Vector2(-24,18),Vector2(-42,52),Vector2(-6,45)]), Color("#e75270"))
	# Satchel, patched tunic and partial scavenger armour remain asymmetric.
	g.draw_circle(Vector2(-29, 34), 19, Color("#382926"))
	g.draw_circle(Vector2(-29, 32), 16, leather)
	g.draw_rect(Rect2(-40, 26, 22, 6), Color("#9b6b3f"), true)
	g.draw_circle(Vector2(-29, 33), 4, Color("#e4b858"))
	g.draw_circle(Vector2(0, 30), 26, body_color)
	g.draw_colored_polygon(PackedVector2Array([Vector2(12,16),Vector2(33,24),Vector2(26,42),Vector2(9,35)]), Color("#805e4a"))
	g.draw_line(Vector2(14, 19), Vector2(28, 37), Color("#d5a34f"), 3)
	g.draw_rect(Rect2(-22, 25, 44, 12), leather, true)
	g.draw_rect(Rect2(-3, 24, 8, 14), Color("#d8a84d"), false, 2)
	g.draw_circle(Vector2(-17, 52), 10, dark_fur)
	g.draw_circle(Vector2(17, 52), 10, dark_fur)
	# Huge pointed ears are the neutral mascot's strongest phone-scale silhouette.
	g.draw_colored_polygon(PackedVector2Array([Vector2(-38,-8),Vector2(-44,-61),Vector2(-5,-31)]), dark_fur)
	g.draw_colored_polygon(PackedVector2Array([Vector2(38,-8),Vector2(44,-61),Vector2(5,-31)]), dark_fur)
	g.draw_colored_polygon(PackedVector2Array([Vector2(-34,-13),Vector2(-39,-52),Vector2(-10,-29)]), body_color)
	g.draw_colored_polygon(PackedVector2Array([Vector2(34,-13),Vector2(39,-52),Vector2(10,-29)]), body_color)
	g.draw_colored_polygon(PackedVector2Array([Vector2(-31,-18),Vector2(-35,-44),Vector2(-15,-28)]), Color("#c98670"))
	g.draw_colored_polygon(PackedVector2Array([Vector2(31,-18),Vector2(35,-44),Vector2(15,-28)]), Color("#c98670"))
	# Small rock horns with subtle relic-gold seams; not Emberhorn's flame horns.
	g.draw_colored_polygon(PackedVector2Array([Vector2(-21,-34),Vector2(-16,-55),Vector2(-6,-35)]), dark_fur)
	g.draw_colored_polygon(PackedVector2Array([Vector2(21,-34),Vector2(16,-55),Vector2(6,-35)]), dark_fur)
	g.draw_line(Vector2(-17,-48), Vector2(-11,-38), Color("#d9a346"), 2)
	g.draw_line(Vector2(17,-48), Vector2(11,-38), Color("#d9a346"), 2)
	g.draw_circle(Vector2(0, 2), 43, dark_fur)
	g.draw_circle(Vector2(0, -2), 41, body_color)
	# Neutral brown forehead tufts/markings distinguish the base from Emberhorn.
	g.draw_colored_polygon(PackedVector2Array([Vector2(-9,-31),Vector2(0,-38),Vector2(9,-31),Vector2(3,-22),Vector2(-4,-23)]), fur_shadow)
	g.draw_circle(Vector2(-15, -8), 11, Color.WHITE)
	g.draw_circle(Vector2(15, -8), 11, Color.WHITE)
	g.draw_circle(Vector2(-14, -7), 7, Color("#d89027"))
	g.draw_circle(Vector2(14, -7), 7, Color("#d89027"))
	g.draw_circle(Vector2(-14, -7), 4, Color("#2c211f"))
	g.draw_circle(Vector2(14, -7), 4, Color("#2c211f"))
	g.draw_circle(Vector2(-12, -10), 2, Color.WHITE)
	g.draw_circle(Vector2(16, -10), 2, Color.WHITE)
	g.draw_circle(Vector2(-28, 8), 6, Color("#ff91ac80"))
	g.draw_circle(Vector2(28, 8), 6, Color("#ff91ac80"))
	g.draw_arc(Vector2(0, 5), 13, 0.25, PI - 0.25, 16, dark_fur, 3)
	g.draw_colored_polygon(PackedVector2Array([Vector2(9,11),Vector2(18,11),Vector2(13,25)]), Color.WHITE)
	g.draw_line(Vector2(-31, -28), Vector2(31, -28), leather, 5)
	g.draw_circle(Vector2(0, -29), 5, Color("#d5a64e"))
	var glow_color := core_color
	glow_color.a = 0.20
	g.draw_circle(Vector2(0, 35), 13 + evolution_tier * 3, glow_color)
	var core_radius := 8 + evolution_tier * 2
	g.draw_colored_polygon(PackedVector2Array([Vector2(0,35-core_radius),Vector2(core_radius,35),Vector2(0,35+core_radius),Vector2(-core_radius,35)]), core_color)
	g.draw_colored_polygon(PackedVector2Array([Vector2(0,31-core_radius*0.35),Vector2(core_radius*0.48,35),Vector2(0,35+core_radius*0.45),Vector2(-core_radius*0.48,35)]), core_color.lightened(0.48))
	if evolution_tier > 0:
		g.draw_arc(Vector2(0, 35), 11 + evolution_tier * 3, g.run_time * 2.0, g.run_time * 2.0 + 4.8, 18, core_color.lightened(0.25), 2 + evolution_tier)
	var windup := clampf(1.0 - g.attack_clock / 0.16, 0.0, 1.0) if g.attack_anim <= 0.0 else 0.0
	var weapon_angle := lerpf(-0.28, -0.72, windup)
	if g.attack_anim > 0.0:
		weapon_angle = lerpf(-0.28, 0.42, g.attack_anim / 0.22)
	var weapon_color := core_color if identity != "Neutral" else Color("#9b6943")
	var family: String = g.inventory.weapon_family()
	match family:
		"RANGER": draw_bow(g, pos, weapon_angle, weapon_growth, weapon_color)
		"MAGE": draw_staff(g, pos, weapon_angle, weapon_growth, weapon_color, core_color)
		"ROGUE": draw_daggers(g, pos, weapon_angle, weapon_growth, weapon_color)
		_: draw_vanguard(g, pos, weapon_angle, weapon_growth, weapon_color, core_color, identity)
	g.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_vanguard(g, pos: Vector2, angle: float, growth: float, color: Color, core_color: Color, identity: String) -> void:
	g.draw_set_transform(pos, -0.03, Vector2.ONE)
	g.draw_line(Vector2(27, 22), Vector2(83, -45), Color("#a76939"), 11)
	g.draw_set_transform(pos + Vector2(81, -49), angle, Vector2.ONE * growth)
	var shape := PackedVector2Array([Vector2(-31,-15),Vector2(-23,-22),Vector2(24,-20),Vector2(32,-11),Vector2(28,17),Vector2(17,22),Vector2(-27,18)])
	g.draw_colored_polygon(shape, color.darkened(0.16))
	g.draw_polyline(PackedVector2Array([Vector2(-31,-15),Vector2(-23,-22),Vector2(24,-20),Vector2(32,-11),Vector2(28,17),Vector2(17,22),Vector2(-27,18),Vector2(-31,-15)]), color.lightened(0.32), 4)
	g.draw_circle(Vector2(-19, -8), 4, Color("#e9bd62"))
	g.draw_circle(Vector2(19, 9), 4, Color("#e9bd62"))
	if identity != "Neutral":
		g.draw_line(Vector2(-24, 10), Vector2(23, -10), core_color.lightened(0.38), 5)

func draw_bow(g, pos: Vector2, angle: float, growth: float, color: Color) -> void:
	g.draw_set_transform(pos + Vector2(61, -14), angle * 0.35, Vector2.ONE * growth)
	g.draw_arc(Vector2.ZERO, 38, -1.35, 1.35, 24, color.lightened(0.18), 7)
	g.draw_line(Vector2(8, -37), Vector2(8, 37), Color("#f1dfba"), 2)
	g.draw_line(Vector2(-20, 0), Vector2(52, 0), Color("#cfad74"), 4)
	g.draw_colored_polygon(PackedVector2Array([Vector2(55,0),Vector2(42,-7),Vector2(42,7)]), color.lightened(0.45))

func draw_staff(g, pos: Vector2, angle: float, growth: float, color: Color, core_color: Color) -> void:
	g.draw_set_transform(pos + Vector2(59, -10), angle * 0.45, Vector2.ONE * growth)
	g.draw_line(Vector2(-22, 39), Vector2(22, -38), Color("#795236"), 8)
	g.draw_circle(Vector2(25, -43), 18, color.darkened(0.18))
	g.draw_circle(Vector2(25, -43), 11, core_color.lightened(0.30))
	g.draw_arc(Vector2(25, -43), 24, g.run_time * 2.0, g.run_time * 2.0 + 4.8, 20, core_color, 3)

func draw_daggers(g, pos: Vector2, angle: float, growth: float, color: Color) -> void:
	g.draw_set_transform(pos + Vector2(48, -3), angle * 0.6, Vector2.ONE * growth)
	for offset in [Vector2(0, -17), Vector2(7, 18)]:
		g.draw_line(offset + Vector2(-17, 20), offset + Vector2(17, -19), Color("#6c4534"), 7)
		g.draw_colored_polygon(PackedVector2Array([offset + Vector2(14,-17),offset + Vector2(43,-28),offset + Vector2(24,1)]), color.lightened(0.28))
		g.draw_line(offset + Vector2(8, -8), offset + Vector2(27, 8), Color("#e6bd63"), 4)

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
				g.draw_arc(Vector2(0, -27), 9, -1.25, 1.2, 12, Color("#7e70d8"), 3)
			"tank":
				g.draw_arc(Vector2(0, -4), radius - 5, PI, TAU, 20, Color("#567064"), 10)
				g.draw_circle(Vector2(-43, 26), 22, Color("#4e3726"))
				g.draw_circle(Vector2(-43, 26), 18, Color("#7f6840"))
				g.draw_line(Vector2(-58, 26), Vector2(-28, 26), Color("#b59655"), 4)
				g.draw_line(Vector2(-43, 11), Vector2(-43, 41), Color("#b59655"), 4)
				g.draw_colored_polygon(PackedVector2Array([Vector2(-52,7),Vector2(-41,-4),Vector2(-38,10)]), Color("#8ebc62"))
			"hexer":
				g.draw_colored_polygon(PackedVector2Array([Vector2(-34,-24),Vector2(-26,-55),Vector2(-8,-31)]), Color("#342440"))
				g.draw_colored_polygon(PackedVector2Array([Vector2(34,-24),Vector2(26,-55),Vector2(8,-31)]), Color("#342440"))
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
