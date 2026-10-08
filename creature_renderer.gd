extends RefCounted

# Retained for the legacy smoke contract; active sprites use WeaponFitCatalog.
func weapon_pose_angle(family: String, windup: float, attack_pose: float) -> float:
	match family:
		"RANGER":
			return lerpf(-0.12, 0.04, attack_pose) if attack_pose > 0.0 else lerpf(-0.12, -0.30, windup)
		"MAGE":
			return lerpf(-0.20, -0.42, attack_pose) if attack_pose > 0.0 else lerpf(-0.20, -0.36, windup)
		"ROGUE":
			return lerpf(-0.20, 0.62, attack_pose) if attack_pose > 0.0 else lerpf(-0.20, -0.52, windup)
		_:
			return lerpf(-0.28, 0.48, attack_pose) if attack_pose > 0.0 else lerpf(-0.28, -0.72, windup)

const ActionPoseCatalog = preload("res://action_pose_catalog.gd")
const LootlingCatalog = preload("res://lootling_catalog.gd")
const WeaponCatalog = preload("res://weapon_catalog.gd")
const BossPresentation=preload("res://boss_presentation.gd")
const BetaArt = preload("res://beta_art_catalog.gd")
const Avatar = preload("res://avatar_presentation.gd")
const WandererPose = preload("res://wanderer_pose_catalog.gd")
const RelicMotion = preload("res://relic_greatsword_motion.gd")

const RAZOR_IMP_TEXTURE = preload("res://art/sprites/enemies/razor_imp.png")
const MOSSBACK_BRUTE_TEXTURE = preload("res://art/sprites/enemies/mossback_brute.png")
const LANTERN_HEXER_TEXTURE = preload("res://art/sprites/enemies/lantern_hexer.png")
const GRUMP_KNIGHT_TEXTURE = preload("res://art/sprites/enemies/grump_knight.png")
const EMBERWORKS_ENEMIES_TEXTURE = preload("res://art/sprites/enemies/emberworks_enemies.png")
const HOARD_DEPTHS_ENEMIES_TEXTURE = preload("res://art/sprites/enemies/hoard_depths_enemies.png")
const VANGUARD_WEAPON_TEXTURE = preload("res://art/sprites/weapons/vanguard_hammer.png")
const RANGER_WEAPON_TEXTURE = preload("res://art/sprites/weapons/ranger_bow.png")
const MAGE_WEAPON_TEXTURE = preload("res://art/sprites/weapons/mage_staff.png")
const ROGUE_WEAPON_TEXTURE = preload("res://art/sprites/weapons/rogue_daggers.png")

func draw_lootling(g, pos: Vector2, hurt: bool) -> void:
	var pose := WandererPose.sample(g, hurt)
	if pose.get("sprite_rig",false) and not prototype_preview_enabled():
		draw_missing_actor_reference(g,pos,pose)
		return
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
	g.draw_set_transform(Vector2(pos.x-4 if creature else pos.x,preload("res://combat_stage.gd").GROUND_Y),0,Vector2(1,.30 if creature else .28))
	g.draw_circle(Vector2.ZERO,55 if creature else 39,Color("#07101f88"))
	if pose.depth == "back": draw_fitted_weapon(g, root, pose)
	g.draw_set_transform_matrix(root)
	if pose.get("sprite_rig",false): preload("res://combat_sprite_rig.gd").draw_limbs(g,pose,false)
	var rect: Rect2 = pose.body_rect
	var edge_size := 2.0 if creature else 1.5
	for edge in [Vector2(-edge_size,0),Vector2(edge_size,0),Vector2(0,-edge_size),Vector2(0,edge_size)]:
		g.draw_texture_rect(texture,Rect2(rect.position+edge,rect.size),false,Color("#101426d9"))
	g.draw_texture_rect(texture,rect,false,Color("#ffb9b9") if hurt else Color(pose.tint))
	if identity != "Neutral":
		var glow := accent
		glow.a = .20+tier*.05
		g.draw_circle(Vector2(pose.core),5+tier,Color(glow,.14))
		g.draw_arc(Vector2(pose.core),8+tier,g.run_time*2,g.run_time*2+2.3,12,Color(accent,.45),1)
	if pose.get("sprite_rig",false): preload("res://combat_sprite_rig.gd").draw_limbs(g,pose,true)
	if pose.depth == "front": draw_fitted_weapon(g, root, pose)
	if pose.get("sprite_rig",false):
		g.draw_set_transform_matrix(root)
		preload("res://combat_sprite_rig.gd").draw_hands(g,pose)
	# Only a real authored foreground layer may cover the weapon with a hand.
	if pose.foreground is Texture2D:
		g.draw_set_transform_matrix(root)
		g.draw_texture_rect(pose.foreground,rect,false,Color.WHITE)
	g.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
	if pose.get("sprite_rig",false):g.draw_string(g.body_font,pos+Vector2(-78,-148),"RIG PROTOTYPE / QA ONLY",HORIZONTAL_ALIGNMENT_CENTER,156,10,Color("#ffe3ac"))

static func prototype_preview_enabled() -> bool:
	return OS.get_environment("LOOTLINGS_QA")=="1" and OS.get_environment("LOOTLINGS_QA_RIG_PREVIEW")=="1"

func draw_missing_actor_reference(g, pos: Vector2, pose: Dictionary) -> void:
	# Explicit reference UI, not a substitute body or fake authored pose. Keep
	# the technical rig/sockets for QA and projectile logic; never render its
	# alternate identity or unattached weapons as accepted gameplay artwork.
	var rect:=Rect2(pos+Vector2(-54,-81),Vector2(108,131))
	g.draw_set_transform(Vector2.ZERO)
	g.draw_rect(rect,Color("#0c182eea"))
	g.draw_rect(rect,Color("#b5a17a"),false,1.5)
	preload("res://lootlings_ui.gd").draw_icon(g.get_canvas_item(),Avatar.portrait(g.profile),Rect2(rect.position+Vector2(20,6),Vector2(68,68)))
	var name_size:=preload("res://lootlings_ui.gd").fitted_font_size(g.body_font,Avatar.display_name(g.profile),100,12,8)
	g.draw_string(g.body_font,rect.position+Vector2(4,91),Avatar.display_name(g.profile),HORIZONTAL_ALIGNMENT_CENTER,100,name_size,Color("#ffe3ac"))
	g.draw_string(g.body_font,rect.position+Vector2(4,108),"POSE ART PENDING",HORIZONTAL_ALIGNMENT_CENTER,100,10,Color("#ddd6c4"))
	g.draw_string(g.body_font,rect.position+Vector2(4,122),"REFERENCE ONLY",HORIZONTAL_ALIGNMENT_CENTER,100,9,Color("#a9b8d2"))

func draw_fitted_weapon(g, root: Transform2D, pose: Dictionary) -> void:
	if pose.get("baked_weapon","") == pose.weapon_type: return
	if pose.weapon_type in ["daggers","claws"]:
		draw_paired_weapons(g,root,pose)
		return
	g.draw_set_transform_matrix(root*Transform2D(float(pose.weapon_rotation),Vector2(pose.weapon_scale),0,Vector2(pose.hand)))
	var item: Dictionary = g.inventory.equipped_item("Weapon")
	var fallback: Texture2D = {"RANGER":RANGER_WEAPON_TEXTURE,"MAGE":MAGE_WEAPON_TEXTURE,"ROGUE":ROGUE_WEAPON_TEXTURE}.get(g.current_weapon_family(),VANGUARD_WEAPON_TEXTURE)
	var texture := WeaponCatalog.presentation_texture(str(pose.weapon_type),"held",fallback,int(item.get("evolution_stage",0)))
	if pose.geometry.has("held_path"):
		texture = WeaponCatalog.authored_held_texture(str(pose.geometry.held_path),texture)
	if pose.weapon_type == "bow": draw_bow_string(g,pose)
	g.draw_texture_rect(texture,Rect2(pose.weapon_rect),false,Color.WHITE)
	if pose.weapon_type in ["staff","wand","orb"]: draw_cast_connection(g,pose)

func draw_cast_connection(g, pose: Dictionary) -> void:
	var charge: float=float(pose.action.anticipate)
	var impact: float=float(pose.action.impact)
	var energy: float=maxf(charge,impact)
	if energy<=.02: return
	if pose.weapon_type=="orb":
		var socket_pos: Vector2=Vector2(pose.weapon_rect.position)+Vector2(pose.geometry.socket)*Vector2(pose.weapon_rect.size)
		preload("res://bible_runtime_art.gd").draw(g,"shadow_orb" if preload("res://projectile_presentation.gd").identity(g)=="Corruption" else "crystal_ward",Rect2(socket_pos-Vector2(16,16),Vector2(32,32)),energy*.65)
	var rect: Rect2=pose.weapon_rect
	var socket: Vector2=rect.position+Vector2(pose.geometry.socket)*rect.size
	var color: Color=preload("res://projectile_presentation.gd").COLORS.get(preload("res://projectile_presentation.gd").identity(g),Color("#a8acff"))
	var forward:=Vector2.RIGHT.rotated(-float(pose.weapon_rotation))*Vector2(pose.weapon_scale)
	# Charge is attached to the actual gem/socket. Orb energy comes from the
	# casting palm rather than floating independently of the actor.
	if pose.weapon_type=="orb":
		var midpoint:=socket*.5+forward.orthogonal()*sin(g.run_time*13)*3*charge
		g.draw_polyline(PackedVector2Array([Vector2.ZERO,midpoint,socket]),Color(color,energy*.65),1.8,true)
	for shard in range(3):
		var direction:=forward.rotated(shard*TAU/3+g.run_time*2)
		var inner: float=5+charge*3
		g.draw_line(socket+direction*inner,socket+direction*(inner+3+energy*5),Color(color,energy*.8),1.5,true)
	if impact>.1:
		g.draw_line(socket,socket+forward*(9+impact*18),Color(color,impact*.85),2,true)

func draw_paired_weapons(g, root: Transform2D, pose: Dictionary) -> void:
	var dagger: bool=pose.weapon_type=="daggers"
	var texture: Texture2D=preload("res://art/sprites/weapons/paired_dagger_painted.png") if dagger else preload("res://art/sprites/weapons/claws_held.png")
	var held_size:=Vector2(42,107) if dagger else Vector2(48,42)
	var grip:=Vector2(.247659,.791269) if dagger else Vector2(.21,.44)
	for hand in range(2):
		g.draw_set_transform_matrix(paired_weapon_transform(g,root,pose,hand))
		g.draw_texture_rect(texture,Rect2(-grip*held_size,held_size),false,Color.WHITE)

func paired_weapon_transform(g, root: Transform2D, pose: Dictionary, hand: int) -> Transform2D:
	var dagger: bool=pose.weapon_type=="daggers"
	var leading: bool=hand==int(g.attack_sequence)%2
	var release: float=float(pose.action.release)*(1 if leading else .45)
	var angle: float
	if dagger: angle=(.40 if hand==0 else -.55)+release*(1.1 if hand==0 else 1.8)-float(pose.action.anticipate)*.28
	else: angle=(-.28 if hand==0 else .28)+release*(.65 if hand==0 else -.65)-float(pose.action.anticipate)*.18
	# Both claw axes face the target. Only a curved dagger is mirrored locally.
	return root*Transform2D(angle,Vector2(-1 if dagger and hand==1 else 1,1),0,pose.primary_hand if hand==0 else pose.secondary_hand)

func draw_bow_string(g, pose: Dictionary) -> void:
	var rect: Rect2 = pose.weapon_rect
	var upper := rect.position+rect.size*Vector2(.888,.258)
	var lower := rect.position+rect.size*Vector2(.411,.887)
	var midpoint := (upper+lower)*.5
	var forward := Vector2.RIGHT.rotated(-float(pose.weapon_rotation))*Vector2(pose.weapon_scale)
	if pose.get("bow_forward") is Vector2: forward=pose.bow_forward
	var draw_amount := float(pose.action.anticipate)
	var nock := midpoint-forward*(draw_amount*14.0)
	if pose.get("bow_nock") is Vector2: nock=pose.bow_nock
	if g.attack_anim > .16: nock += forward*sin((.22-g.attack_anim)*80)*2.0
	g.draw_polyline(PackedVector2Array([upper,nock,lower]),Color("#141a2c"),3.0,true)
	g.draw_polyline(PackedVector2Array([upper,nock,lower]),Color("#e8d9a8"),1.2,true)
	if g.attack_anim <= 0:
		if pose.get("bow_nock") is Vector2:
			# Full draw spans the delivered hand-to-grip distance. Extend only the
			# shaft; retain the existing readable head/feathers instead of scaling.
			var length:=nock.length()+18.0
			preload("res://projectile_presentation.gd").draw_arrow(g,nock+forward*length,forward,"Physical",1.3,false,false,length/1.3)
		else:
			preload("res://projectile_presentation.gd").draw_arrow(g,nock+forward*48.0,forward,"Physical",1.3,false)

func draw_striking_blade(g, pos: Vector2) -> void:
	# Large foes used to hide the entire contact stroke. Only the blade crosses
	# their foreground; the handle stays beneath the real closed paws.
	if g.attack_anim <= .055: return
	var pose := WandererPose.sample(g,g.player_flash > 0)
	if pose.get("sprite_rig",false) and not prototype_preview_enabled():return
	if pose.weapon_type in ["daggers","claws"]: return
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
	preload("res://enemy_motion.gd").verdant(g,pos)

func draw_enemy_sprite(g, pos: Vector2, color: Color, extra_scale: float = 1.0) -> void:
	var texture: Texture2D = RAZOR_IMP_TEXTURE
	var sprite_rect := Rect2(-64, -56, 128, 107)
	var atlas_region := Rect2()
	var shadow_radius := 39.0
	var threat_color := Color.TRANSPARENT
	var boss_data: Dictionary={}
	if g.enemy_is_boss:
		boss_data=BossPresentation.profile_for(g); texture=BossPresentation.texture_for(boss_data)
		sprite_rect=BossPresentation.display_rect(boss_data,texture)
		pos+=boss_data.offset; shadow_radius=boss_data.shadow; threat_color=Color("#a94dff2e")
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
	var glasswing: bool=preload("res://enemy_motion.gd").glasswing(g)
	var regional: Dictionary=preload("res://regional_enemy_presentation.gd").profile(g.enemy_name) if not g.enemy_is_boss and not g.enemy_is_miniboss else {}
	if not regional.is_empty():
		texture=regional.texture; sprite_rect=Rect2(Vector2(-regional.size.x*.5,66-regional.size.y*.89),regional.size); atlas_region=Rect2(); shadow_radius=regional.size.x*.28
	var exact_neutral: Dictionary=preload("res://approved_missing_runtime_art.gd").enemy_neutral(g,pos.x) if not regional.is_empty() else {}
	if not exact_neutral.is_empty():
		texture=exact_neutral.texture
		if exact_neutral.has("display_size"):sprite_rect=Rect2(-Vector2(exact_neutral.display_size)*Vector2(.5,1)+Vector2(0,66),exact_neutral.display_size)
	if not regional.is_empty() and regional.hover:
		pos.y-=17+sin(g.run_time*4)*5
	if glasswing and regional.get("body","") != "bat":
		preload("res://enemy_motion.gd").draw_wings(g,pos,extra_scale)
	# Fit the source uniformly inside its archetype bounds; align full frames to
	# one ground baseline instead of giving each size a different foot height.
	var source_size: Vector2=atlas_region.size if atlas_region.size.x>0 else Vector2(texture.get_size())
	if not g.enemy_is_boss:
		var fitted: Vector2=source_size*minf(sprite_rect.size.x/source_size.x,sprite_rect.size.y/source_size.y)
		sprite_rect=Rect2(Vector2(-fitted.x*.5,66-fitted.y),fitted)
	else:
		sprite_rect.position.y+=66-sprite_rect.end.y
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
		# Regional stage motifs are presentation only; they never alter telegraphs.
		var halo_angle := float(g.run_time) * 0.22
		var stage_color: Color=boss_data.accent
		stage_color.a=.38
		g.draw_set_transform(pos, 0.0, Vector2.ONE * extra_scale)
		g.draw_line(Vector2(-69,58),Vector2(69,58),Color(stage_color,.20),2,true)
		for seal_index in range(3):
			var seal_angle := halo_angle + .35 + seal_index * 2.09
			var seal_pos := Vector2(-56+seal_index*56,58)
			match str(boss_data.motif):
				"script", "mirror":
					g.draw_polyline(PackedVector2Array([seal_pos+Vector2(0,-7),seal_pos+Vector2(5,0),seal_pos+Vector2(0,7),seal_pos+Vector2(-5,0),seal_pos+Vector2(0,-7)]),stage_color.lightened(.3),1.5,true)
				"engine", "chain", "chime":
					g.draw_circle(seal_pos,6,stage_color,false,2,true)
					g.draw_line(seal_pos+Vector2(0,-8),seal_pos+Vector2(0,8),stage_color,1.5,true)
				_:
					g.draw_circle(seal_pos,4,stage_color.lightened(.3))
					g.draw_circle(seal_pos,9,Color(stage_color, .12))
		g.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if g.enemy_is_boss and not boss_data.has("authored_state"): BossPresentation.draw_identity(g,pos,extra_scale)
	var tint: Color=Color.WHITE if not exact_neutral.is_empty() else regional.get("tint",Color.WHITE)
	if color.r > 0.95 and color.g > 0.95 and color.b > 0.95:
		tint = Color("#fff2ca")
	tint.a = color.a
	var hit_scale := (Vector2(1.025,.98) if g.enemy_is_boss else Vector2(1.045,.965)) if g.enemy_squash>0.0 and g.enemy_alive else Vector2.ONE
	var recoil_tilt := clampf(float(g.enemy_recoil) / 24.0, -1.0, 1.0) * 0.08
	if g.enemy_is_boss: recoil_tilt=clampf(recoil_tilt,-boss_data.recoil_limit,boss_data.recoil_limit)
	var personality_scale := Vector2.ONE
	var personality_tilt := 0.0
	var boss_charge: float=clampf(1-g.enemy_attack_clock/.7,0,1) if g.enemy_is_boss else 0
	if g.enemy_is_boss and g.campaign_id=="mossglass_wilds":
		pos.x+=boss_charge*6
		if g.boss_recovery>0: pos.y+=7; recoil_tilt+=.045; tint=tint.darkened(.16)
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
	var cue: Dictionary=preload("res://combat_presentation.gd").attack_cue(g)
	var preparation: float=float(cue.progress) if cue.visible else 0
	var commit: float=clampf(g.enemy_attack_anim/.18,0,1)
	var direction: int=g.enemy_facing_at(pos.x)
	if g.enemy_is_boss:
		var motion: Dictionary=BossPresentation.motion(g,preparation,direction)
		pos+=Vector2(motion.offset); personality_tilt+=float(motion.tilt); personality_scale*=Vector2(motion.scale)
	elif g.enemy_archetype=="tank":
		personality_tilt+=direction*(-preparation*.11+commit*.16)
		personality_scale*=Vector2(1+preparation*.035,1-preparation*.04+commit*.035)
	elif g.enemy_archetype=="skirmisher":
		personality_tilt+=direction*(-preparation*.07+commit*.12)
		personality_scale.y*=1-preparation*.07+commit*.035
	else:
		personality_tilt+=direction*(-preparation*.04+commit*.08)
		pos.y-=preparation*4
	if not regional.is_empty() and regional.hover: pos.y+=commit*18
	g.draw_set_transform(Vector2(pos.x,preload("res://combat_stage.gd").GROUND_Y), 0.0, Vector2(1.0, 0.28) * extra_scale)
	g.draw_circle(Vector2.ZERO, shadow_radius, Color(0.015, 0.025, 0.06, 0.52 * color.a))
	var cast_charge := clampf(1.0 - float(g.enemy_attack_clock) / 0.30, 0.0, 1.0) if g.enemy_archetype == "hexer" and not g.enemy_is_boss and not g.enemy_is_miniboss else 0.0
	if cast_charge > 0.0:
		g.draw_circle(Vector2(pos.x + 25*g.enemy_facing_at(pos.x), pos.y - 24), 8.0 + cast_charge * 9.0, Color(0.72, 0.38, 1.0, cast_charge * 0.24))
	# Existing enemy sprites face left; flip only for a player on their right.
	var facing_scale:=Vector2(-g.enemy_facing_at(pos.x),1)
	if not exact_neutral.is_empty(): facing_scale.x=1 # This export already faces the actual target; never mirror it.
	if g.enemy_is_boss and boss_data.flip_h: facing_scale.x*=-1
	var entry_scale: float=lerpf(float(boss_data.entrance_scale),1.0,1.0-clampf(float(g.enemy_entry_anim)/.55,0,1)) if g.enemy_is_boss else 1.0
	if g.audio_settings.get("cinematic_reduced_motion",false):
		personality_tilt=0; recoil_tilt=0; personality_scale=Vector2.ONE; hit_scale=Vector2.ONE
	var feet: Vector2=preload("res://enemy_motion.gd").feet_anchor(texture,atlas_region,sprite_rect)
	g.draw_set_transform_matrix(preload("res://enemy_motion.gd").grounded_transform(pos,recoil_tilt+personality_tilt+(float(boss_data.rotation) if g.enemy_is_boss else 0.0),hit_scale*personality_scale*extra_scale*facing_scale*entry_scale,feet,66*extra_scale))
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
