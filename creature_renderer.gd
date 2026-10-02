extends RefCounted

const ActionPoseCatalog = preload("res://action_pose_catalog.gd")
const LootlingCatalog = preload("res://lootling_catalog.gd")
const WeaponCatalog = preload("res://weapon_catalog.gd")
const BetaArt = preload("res://beta_art_catalog.gd")
const Avatar = preload("res://avatar_presentation.gd")
const WandererPose = preload("res://wanderer_pose_catalog.gd")

const MASCOT_TEXTURE = preload("res://art/sprites/relic_beast_base.png")
const RAZOR_IMP_TEXTURE = preload("res://art/sprites/enemies/razor_imp.png")
const MOSSBACK_BRUTE_TEXTURE = preload("res://art/sprites/enemies/mossback_brute.png")
const LANTERN_HEXER_TEXTURE = preload("res://art/sprites/enemies/lantern_hexer.png")
const GRUMP_KNIGHT_TEXTURE = preload("res://art/sprites/enemies/grump_knight.png")
const HOARD_DRAGON_TEXTURE = preload("res://art/sprites/enemies/hoard_dragon.png")
const EMBERWORKS_ENEMIES_TEXTURE = preload("res://art/sprites/enemies/emberworks_enemies.png")
const HOARD_DEPTHS_ENEMIES_TEXTURE = preload("res://art/sprites/enemies/hoard_depths_enemies.png")
const VANGUARD_WEAPON_TEXTURE = preload("res://art/sprites/weapons/vanguard_hammer.png")
const RANGER_WEAPON_TEXTURE = preload("res://art/sprites/weapons/ranger_bow.png")
const MAGE_WEAPON_TEXTURE = preload("res://art/sprites/weapons/mage_staff.png")
const ROGUE_WEAPON_TEXTURE = preload("res://art/sprites/weapons/rogue_daggers.png")

func draw_lootling(g, pos: Vector2, hurt: bool) -> void:
	var pose := WandererPose.sample(g, hurt)
	var texture: Texture2D = pose.texture
	if texture == null: return
	var root: Transform2D = pose.root
	root.origin += pos
	var creature := not Avatar.is_wanderer(g.profile)
	var identity: String = g.build.dominant()
	var accent: Color = g.build.color(identity)
	var tier: int = g.build.tier(identity)
	if creature:
		for index in range(2+tier*2):
			var angle: float = float(g.run_time)*(1.1+index*.08)+TAU*index/float(2+tier*2)
			var aura := accent
			aura.a = .18 if identity == "Neutral" else .34
			g.draw_circle(pos+Vector2(cos(angle)*(58+tier*6),sin(angle)*(43+tier*4)),2.5+tier,aura)
	g.draw_set_transform(pos+Vector2(-4 if creature else 0,46 if creature else 52),0,Vector2(1,.30 if creature else .28))
	g.draw_circle(Vector2.ZERO,55 if creature else 39,Color("#07101f88"))
	if pose.depth == "back": draw_fitted_weapon(g, root, pose)
	g.draw_set_transform_matrix(root)
	var rect: Rect2 = pose.body_rect
	var edge_size := 2.0 if creature else 1.5
	for edge in [Vector2(-edge_size,0),Vector2(edge_size,0),Vector2(0,-edge_size),Vector2(0,edge_size)]:
		g.draw_texture_rect(texture,Rect2(rect.position+edge,rect.size),false,Color("#101426d9"))
	g.draw_texture_rect(texture,rect,false,Color("#ffb9b9") if hurt else Color(pose.tint))
	if identity != "Neutral":
		var glow := accent
		glow.a = .20+tier*.05
		g.draw_circle(Vector2(pose.core),12+tier*3,glow)
		g.draw_arc(Vector2(pose.core),14+tier*3,g.run_time*2,g.run_time*2+4.9,18,accent.lightened(.25),2+tier)
	if pose.depth == "front": draw_fitted_weapon(g, root, pose)
	# Only a real authored foreground layer may cover the weapon with a hand.
	if pose.foreground is Texture2D:
		g.draw_set_transform_matrix(root)
		g.draw_texture_rect(pose.foreground,rect,false,Color.WHITE)
	g.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)

func draw_fitted_weapon(g, root: Transform2D, pose: Dictionary) -> void:
	g.draw_set_transform_matrix(root*Transform2D(float(pose.weapon_rotation),Vector2(pose.weapon_scale),0,Vector2(pose.hand)))
	var item: Dictionary = g.inventory.equipped_item("Weapon")
	var fallback: Texture2D = {"RANGER":RANGER_WEAPON_TEXTURE,"MAGE":MAGE_WEAPON_TEXTURE,"ROGUE":ROGUE_WEAPON_TEXTURE}.get(g.current_weapon_family(),VANGUARD_WEAPON_TEXTURE)
	var texture := WeaponCatalog.presentation_texture(str(pose.weapon_type),"held",fallback,int(item.get("evolution_stage",0)))
	if pose.geometry.has("held_path"):
		texture = WeaponCatalog.authored_held_texture(str(pose.geometry.held_path),texture)
	g.draw_texture_rect(texture,Rect2(pose.weapon_rect),false,Color.WHITE)

func draw_wanderer(g, pos: Vector2, hurt: bool) -> void:
	draw_lootling(g,pos,hurt)

func draw_lootling_procedural(g, pos: Vector2, hurt: bool) -> void:
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
	var weapon_color := core_color if identity != "Neutral" else Color("#9b6943")
	var family: String = g.current_weapon_family()
	var weapon_angle := weapon_pose_angle(family, windup, clampf(g.attack_anim / 0.22, 0.0, 1.0))
	match family:
		"RANGER": draw_bow(g, pos, weapon_angle, weapon_growth, weapon_color)
		"MAGE": draw_staff(g, pos, weapon_angle, weapon_growth, weapon_color, core_color)
		"ROGUE": draw_daggers(g, pos, weapon_angle, weapon_growth, weapon_color)
		_: draw_vanguard(g, pos, weapon_angle, weapon_growth, weapon_color, core_color, identity)
	g.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func weapon_pose_angle(family: String, windup: float, attack_pose: float) -> float:
	match family:
		"RANGER":
			# Raise and draw the bow, then give it a small release snap instead of a melee swing.
			return lerpf(-0.12, 0.04, attack_pose) if attack_pose > 0.0 else lerpf(-0.12, -0.30, windup)
		"MAGE":
			# The staff lifts toward the target while the projectile charges/releases.
			return lerpf(-0.20, -0.42, attack_pose) if attack_pose > 0.0 else lerpf(-0.20, -0.36, windup)
		"ROGUE":
			return lerpf(-0.20, 0.62, attack_pose) if attack_pose > 0.0 else lerpf(-0.20, -0.52, windup)
		_:
			return lerpf(-0.28, 0.48, attack_pose) if attack_pose > 0.0 else lerpf(-0.28, -0.72, windup)

func draw_vanguard(g, pos: Vector2, angle: float, growth: float, color: Color, core_color: Color, identity: String) -> void:
	var accent := core_color if identity != "Neutral" else Color("#ffbd55")
	draw_weapon_sprite(g, VANGUARD_WEAPON_TEXTURE, pos + Vector2(28, 15), Rect2(-8, -105, 126, 114), angle * 0.68, growth, accent, Vector2(82, -62))

func draw_bow(g, pos: Vector2, angle: float, growth: float, color: Color) -> void:
	draw_weapon_sprite(g, RANGER_WEAPON_TEXTURE, pos + Vector2(27, 14), Rect2(-7, -100, 119, 110), angle * 0.42, growth, color, Vector2(76, -55))

func draw_staff(g, pos: Vector2, angle: float, growth: float, color: Color, core_color: Color) -> void:
	draw_weapon_sprite(g, MAGE_WEAPON_TEXTURE, pos + Vector2(25, 16), Rect2(-5, -117, 98, 118), angle * 0.48, growth, core_color, Vector2(65, -78))

func draw_daggers(g, pos: Vector2, angle: float, growth: float, color: Color) -> void:
	draw_weapon_sprite(g, ROGUE_WEAPON_TEXTURE, pos + Vector2(24, 15), Rect2(-4, -98, 112, 102), angle * 0.62, growth, color, Vector2(75, -55))

func draw_weapon_sprite(g, texture: Texture2D, pivot: Vector2, rect: Rect2, rotation: float, growth: float, accent: Color, glow_offset: Vector2) -> void:
	var item: Dictionary = g.inventory.equipped_item("Weapon")
	var subtype := str(item.get("weapon_type", ""))
	growth *= 1.0 + clampi(int(item.get("evolution_stage", 0)), 0, 2) * 0.06
	texture = WeaponCatalog.runtime_texture(subtype, texture, int(item.get("evolution_stage", 0)))
	rect = WeaponCatalog.held_rect(subtype, rect)
	if subtype in ["greatsword", "greataxe"]:
		rotation += 0.58
	if subtype == "orb":
		glow_offset = Vector2(16, -4)
	elif subtype == "crossbow":
		rotation -= 0.30
		glow_offset = Vector2(108, -22)
	elif subtype == "spear":
		rotation += 0.43
	elif subtype == "wand":
		rotation += 0.30
		glow_offset = Vector2(60, -91)
	elif subtype == "claws":
		glow_offset = Vector2(76, 2)
	var glow := accent
	glow.a = 0.16
	g.draw_set_transform(pivot, rotation, Vector2.ONE * growth)
	g.draw_circle(glow_offset, 24.0, glow)
	g.draw_circle(glow_offset, 12.0, Color(accent.r, accent.g, accent.b, 0.10))
	g.draw_texture_rect(texture, rect, false, Color.WHITE)
	g.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_enemy(g, pos: Vector2, color: Color, extra_scale: float = 1.0) -> void:
	draw_enemy_sprite(g, pos, color, extra_scale)

func draw_enemy_sprite(g, pos: Vector2, color: Color, extra_scale: float = 1.0) -> void:
	var texture: Texture2D = RAZOR_IMP_TEXTURE
	var sprite_rect := Rect2(-64, -56, 128, 107)
	var atlas_region := Rect2()
	var shadow_radius := 39.0
	var threat_color := Color.TRANSPARENT
	if g.enemy_is_boss:
		texture = HOARD_DRAGON_TEXTURE
		sprite_rect = Rect2(-104, -108, 208, 174)
		var regional_texture := BetaArt.boss_texture(g.campaign_id)
		if regional_texture != null:
			texture = regional_texture
			sprite_rect = Rect2(-120, -142, 240, 208)
			pos.x -= 26.0
		shadow_radius = 78.0
		threat_color = Color("#a94dff2e")
	elif g.enemy_is_miniboss:
		texture = GRUMP_KNIGHT_TEXTURE
		sprite_rect = Rect2(-87, -86, 174, 145)
		shadow_radius = 62.0
		threat_color = Color("#ffb33e2b")
	else:
		if g.current_zone_id == "emberworks" or g.current_zone_id == "hoard_depths":
			texture = EMBERWORKS_ENEMIES_TEXTURE if g.current_zone_id == "emberworks" else HOARD_DEPTHS_ENEMIES_TEXTURE
			var atlas_index := 1 if g.enemy_archetype == "tank" else 2 if g.enemy_archetype == "hexer" else 0
			atlas_region = Rect2(atlas_index * 724, 0, 724, 724)
			match g.enemy_archetype:
				"tank":
					sprite_rect = Rect2(-78, -61, 156, 116)
					shadow_radius = 50.0
				"hexer": sprite_rect = Rect2(-58, -79, 116, 137)
				_: sprite_rect = Rect2(-67, -64, 134, 115)
		else:
			match g.enemy_archetype:
				"tank":
					texture = MOSSBACK_BRUTE_TEXTURE
					sprite_rect = Rect2(-74, -46, 148, 99)
					shadow_radius = 48.0
				"hexer":
					texture = LANTERN_HEXER_TEXTURE
					sprite_rect = Rect2(-55, -76, 110, 131)
	# A restrained local value break keeps painted creatures readable against the rich ruin art.
	g.draw_set_transform(pos + Vector2(0, -5), 0.0, Vector2(1.0, 0.76) * extra_scale)
	g.draw_circle(Vector2.ZERO, shadow_radius + 16.0, Color(0.015, 0.025, 0.065, 0.18 * color.a))
	g.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if threat_color.a > 0.0:
		threat_color.a *= color.a
		g.draw_set_transform(pos + Vector2(0, -4), 0.0, Vector2(1.0, 0.72) * extra_scale)
		g.draw_circle(Vector2.ZERO, shadow_radius + 14.0, threat_color)
		g.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if g.enemy_is_boss:
		# Hoard Guardian motif: one slow relic halo with two controlled violet seals.
		var halo_angle := float(g.run_time) * 0.22
		g.draw_set_transform(pos, 0.0, Vector2.ONE * extra_scale)
		g.draw_arc(Vector2.ZERO, 97.0, halo_angle, halo_angle + 4.55, 38, Color("#d7aa5066"), 3.0)
		for seal_index in range(2):
			var seal_angle := halo_angle + 0.35 + seal_index * 2.85
			var seal_pos := Vector2.RIGHT.rotated(seal_angle) * 97.0
			g.draw_circle(seal_pos, 5.0, Color("#b968ff99"))
			g.draw_circle(seal_pos, 2.2, Color("#f0d5ff"))
		g.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var tint := Color.WHITE
	if color.r > 0.95 and color.g > 0.95 and color.b > 0.95:
		tint = Color("#fff2ca")
	tint.a = color.a
	var hit_scale := Vector2(1.13, 0.82) if g.enemy_squash > 0.0 and g.enemy_alive else Vector2.ONE
	var recoil_tilt := clampf(float(g.enemy_recoil) / 24.0, -1.0, 1.0) * 0.08
	var personality_scale := Vector2.ONE
	var personality_tilt := 0.0
	if g.enemy_is_boss:
		personality_scale = Vector2(1.0 + sin(g.run_time * 1.35) * 0.012, 1.0 - sin(g.run_time * 1.35) * 0.014)
	elif g.enemy_is_miniboss:
		personality_scale = Vector2(1.0 + sin(g.run_time * 1.8) * 0.010, 1.0 - sin(g.run_time * 1.8) * 0.012)
	else:
		match g.enemy_archetype:
			"skirmisher":
				personality_tilt = sin(g.run_time * 7.5) * 0.025
				personality_scale = Vector2(1.0, 1.0 + sin(g.run_time * 7.5) * 0.025)
			"tank": personality_scale = Vector2(1.0 + sin(g.run_time * 2.0) * 0.012, 1.0 - sin(g.run_time * 2.0) * 0.018)
			"hexer": personality_tilt = sin(g.run_time * 2.6) * 0.018
	g.draw_set_transform(pos + Vector2(0, 49), 0.0, Vector2(1.0, 0.28) * extra_scale)
	g.draw_circle(Vector2.ZERO, shadow_radius, Color(0.015, 0.025, 0.06, 0.52 * color.a))
	var cast_charge := clampf(1.0 - float(g.enemy_attack_clock) / 0.30, 0.0, 1.0) if g.enemy_archetype == "hexer" and not g.enemy_is_boss and not g.enemy_is_miniboss else 0.0
	if cast_charge > 0.0:
		g.draw_circle(Vector2(pos.x - 25, pos.y - 24), 8.0 + cast_charge * 9.0, Color(0.72, 0.38, 1.0, cast_charge * 0.24))
	g.draw_set_transform(pos, recoil_tilt + personality_tilt, hit_scale * personality_scale * extra_scale)
	var edge_strength := 3.0 if g.enemy_is_boss else 2.5 if g.enemy_is_miniboss else 1.75
	var outline_color := Color("#0c1024df")
	if not str(g.enemy_variant_id).is_empty():
		var variant_color: Color = g.enemy_variant_color
		outline_color = Color(variant_color.r * 0.30, variant_color.g * 0.30, variant_color.b * 0.30, 0.94 * color.a)
	for edge in [Vector2(-edge_strength, 0), Vector2(edge_strength, 0), Vector2(0, -edge_strength), Vector2(0, edge_strength)]:
		var edge_rect := Rect2(sprite_rect.position + edge, sprite_rect.size)
		if atlas_region.size.x > 0.0:
			g.draw_texture_rect_region(texture, edge_rect, atlas_region, outline_color)
		else:
			g.draw_texture_rect(texture, edge_rect, false, outline_color)
	if atlas_region.size.x > 0.0:
		g.draw_texture_rect_region(texture, sprite_rect, atlas_region, tint)
	else:
		g.draw_texture_rect(texture, sprite_rect, false, tint)
	g.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_enemy_procedural(g, pos: Vector2, color: Color, extra_scale: float = 1.0) -> void:
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
