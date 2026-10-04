extends RefCounted

const ActionPoseCatalog = preload("res://action_pose_catalog.gd")
const LootlingCatalog = preload("res://lootling_catalog.gd")
const WeaponCatalog = preload("res://weapon_catalog.gd")
const BetaArt = preload("res://beta_art_catalog.gd")
const Avatar = preload("res://avatar_presentation.gd")
const WandererPose = preload("res://wanderer_pose_catalog.gd")
const RelicMotion = preload("res://relic_greatsword_motion.gd")

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
	if pose.weapon_type == "bow": draw_bow_string(g,pose)
	g.draw_texture_rect(texture,Rect2(pose.weapon_rect),false,Color.WHITE)

func draw_bow_string(g, pose: Dictionary) -> void:
	var rect: Rect2 = pose.weapon_rect
	var upper := rect.position+rect.size*Vector2(.888,.258)
	var lower := rect.position+rect.size*Vector2(.411,.887)
	var midpoint := (upper+lower)*.5
	var forward := Vector2.RIGHT.rotated(-float(pose.weapon_rotation))*Vector2(pose.weapon_scale)
	var draw_amount := float(pose.action.anticipate)
	var nock := midpoint-forward*(draw_amount*14.0)
	if g.attack_anim > .16: nock += forward*sin((.22-g.attack_anim)*80)*2.0
	g.draw_polyline(PackedVector2Array([upper,nock,lower]),Color("#141a2c"),3.0,true)
	g.draw_polyline(PackedVector2Array([upper,nock,lower]),Color("#e8d9a8"),1.2,true)
	if g.attack_anim <= 0:
		preload("res://projectile_presentation.gd").draw_arrow(g,nock+forward*48.0,forward,"Physical",1.3,false)

func draw_striking_blade(g, pos: Vector2) -> void:
	# Large foes used to hide the entire contact stroke. Only the blade crosses
	# their foreground; the handle stays beneath the real closed paws.
	if g.attack_anim <= .055: return
	var pose := WandererPose.sample(g,g.player_flash > 0)
	var blade_fraction: float = {"greatsword":.61,"greataxe":.50,"maul":.47,"spear":.48,"daggers":.50,"claws":.30}.get(str(pose.weapon_type),0.0)
	if blade_fraction == 0: return
	var root: Transform2D = pose.root
	root.origin += pos
	var item: Dictionary = g.inventory.equipped_item("Weapon")
	var texture := WeaponCatalog.presentation_texture(str(pose.weapon_type),"held",VANGUARD_WEAPON_TEXTURE,int(item.get("evolution_stage",0)))
	if pose.geometry.has("held_path"):
		texture = WeaponCatalog.authored_held_texture(str(pose.geometry.held_path),texture)
	if texture == null: return
	g.draw_set_transform_matrix(root*Transform2D(float(pose.weapon_rotation),Vector2(pose.weapon_scale),0,Vector2(pose.hand)))
	var rect: Rect2 = pose.weapon_rect
	var source := Rect2(Vector2.ZERO,Vector2(texture.get_size())*Vector2(1,blade_fraction))
	g.draw_texture_rect_region(texture,Rect2(rect.position,rect.size*Vector2(1,blade_fraction)),source)
	g.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)

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
