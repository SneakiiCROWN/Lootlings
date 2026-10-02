extends RefCounted
# Visual-only body + stance + authored override. No RNG or gameplay mutation.
const Wanderers = preload("res://wanderer_catalog.gd")
const Lootlings = preload("res://lootling_catalog.gd")
const Avatar = preload("res://avatar_presentation.gd")
const Actions = preload("res://action_pose_catalog.gd")
const Authored = preload("res://authored_pose_manifest.gd")
const RelicMotion = preload("res://relic_greatsword_motion.gd")
const BODY_RECT := Rect2(-75,-146,150,225)
const HUMANOID_PROFILES := {
	"light":.92,"athletic":1.0,"curvy":.98,"broad":1.04,"heavy":1.06,"muscular":1.04
}
const SECONDARY_HANDS := {
	"vault_runner":Vector2(.305,.49),"ruin_warden":Vector2(.29,.47),
	"nightstage_drifter":Vector2(.275,.47),"velvet_astrologer":Vector2(.27,.49),
	"ashtrail_hunter":Vector2(.27,.49)
}
const CREATURE_PROFILES := {
	"relic_beast":{"category":"chunky_biped","primary":Vector2(.777,.731),"secondary":Vector2(.515,.69),"core":Vector2(.63,.594),"scale":.82},
	"emberhorn":{"category":"small_biped","primary":Vector2(.715,.75),"secondary":Vector2(.24,.765),"core":Vector2(.50,.63),"scale":.78},
	"mosskin":{"category":"shielded_biped","primary":Vector2(.295,.735),"secondary":Vector2(.76,.70),"core":Vector2(.50,.63),"scale":.76,"handling":"shield_side","baked":"shield"},
	"moonkip":{"category":"small_biped","primary":Vector2(.70,.755),"secondary":Vector2(.30,.745),"core":Vector2(.50,.66),"scale":.74,"baked":"daggers"},
	"pebblewyrm":{"category":"heavy_brute","primary":Vector2(.80,.77),"secondary":Vector2(.27,.77),"core":Vector2(.64,.735),"scale":.90},
	"glimmerfin":{"category":"floating","primary":Vector2(.72,.77),"secondary":Vector2(.30,.765),"core":Vector2(.50,.66),"scale":.76,"baked":"wand"},
	"gloomlet":{"category":"chunky_biped","primary":Vector2(.777,.731),"secondary":Vector2(.515,.69),"core":Vector2(.63,.594),"scale":.82,"stand_in":true}
}
const GEOMETRY := {
	"greatsword":{"size":Vector2(112, 142), "grip":Vector2(.377,.84), "socket":Vector2(.65,.05), "angle":0.36},
	"greataxe":{"size":Vector2(112, 142), "grip":Vector2(.37,.70), "socket":Vector2(.63,.20), "angle":0.44},
	"maul":{"size":Vector2(116, 110), "grip":Vector2(.30,.72), "socket":Vector2(.82,.15), "angle":-0.12},
	"spear":{"size":Vector2(104, 162), "grip":Vector2(0.37,0.76), "socket":Vector2(0.8,0.08), "angle":0.35},
	"daggers":{"size":Vector2(92, 94), "grip":Vector2(0.27,0.68), "socket":Vector2(0.82,0.1), "angle":-0.2},
	"claws":{"size":Vector2(87, 72), "grip":Vector2(.21,.44), "socket":Vector2(0.9,0.3), "angle":0.0},
	"bow":{"size":Vector2(86, 114), "grip":Vector2(0.48,0.55), "socket":Vector2(0.68,0.46), "angle":-0.62},
	"crossbow":{"size":Vector2(115, 80), "grip":Vector2(.43,.56), "socket":Vector2(.10,.36), "angle":0.05, "mirror":true},
	"sling":{"size":Vector2(96,104), "grip":Vector2(.24,.78), "socket":Vector2(.79,.20), "angle":.18},
	"staff":{"size":Vector2(80, 142), "grip":Vector2(.32,.76), "socket":Vector2(.80,.20), "angle":-0.12},
	"wand":{"size":Vector2(75, 93), "grip":Vector2(.42,.72), "socket":Vector2(.60,.10), "angle":0.16},
	"orb":{"size":Vector2(64, 64), "grip":Vector2(-0.22,0.78), "socket":Vector2(0.7,0.43), "angle":0.0}
}


const STANCES := {
	"greatsword":{"group":"heavy_two_hand","handling":"two_hand","secondary_grip":Vector2(.41,.77),"ready":-.20,"release":.42},
	"greataxe":{"group":"heavy_two_hand","handling":"two_hand","secondary_grip":Vector2(.41,.59),"ready":-.22,"release":.42},
	"maul":{"group":"heavy_two_hand","handling":"two_hand","secondary_grip":Vector2(.41,.61),"ready":-.24,"release":.42},
	"spear":{"group":"polearm","handling":"two_hand","secondary_grip":Vector2(.47,.59),"ready":-.12,"release":.18},
	"daggers":{"group":"dual_wield","handling":"paired","secondary_grip":Vector2(.70,.70),"ready":-.22,"release":.40},
	"claws":{"group":"dual_wield","handling":"paired","secondary_grip":Vector2(.72,.55),"ready":-.16,"release":.24},
	"bow":{"group":"bow","handling":"two_hand","secondary_grip":Vector2(.35,.57),"ready":-.12,"release":-.08},
	"crossbow":{"group":"crossbow","handling":"two_hand","secondary_grip":Vector2(.57,.58),"ready":-.08,"release":-.08},
	"sling":{"group":"one_hand","handling":"special","secondary_grip":Vector2.ZERO,"ready":-.28,"release":.42,"art_pending":false},
	"staff":{"group":"staff","handling":"two_hand","secondary_grip":Vector2(.36,.65),"ready":-.12,"release":-.08},
	"wand":{"group":"wand","handling":"one_hand","secondary_grip":Vector2.ZERO,"ready":-.16,"release":-.08},
	"orb":{"group":"orb","handling":"levitated","secondary_grip":Vector2.ZERO,"ready":0.0,"release":-.08}
}
# Authored body/hand exports register here, not in rendering code. No fake limbs.
static var stance_assets := {}
static var body_cache := {}
static var managed_stance := ""
static var absent_stances := {}
const MAX_HELD_SIZE := Vector2(149,179)
const STANCE_GROUPS := ["neutral","one_hand","heavy_two_hand","polearm","dual_wield","bow","crossbow","staff","wand","orb"]
const HANDLING_OVERRIDES := {
	"shield_side":{
		"maul":{"angle":-1.50,"release":-.10},
		"greatsword":{"angle":-.90,"release":-.10},
		"greataxe":{"angle":-.90,"release":-.10},
		"spear":{"angle":-.90},"staff":{"angle":-.90},"wand":{"angle":-.90},
		"daggers":{"angle":-.35},"claws":{"angle":-.35},"bow":{"angle":-.35},
		"crossbow":{"angle":-.35},"sling":{"angle":-1.35,"release":-.10},"orb":{"angle":-.35}
	},
	"paw":{"staff":{"angle_offset":.30},"spear":{"angle_offset":.30},"bow":{"angle_offset":.30}}
}

static func register_stance(actor_id: String, group: String, data: Dictionary) -> bool:
	if group not in STANCE_GROUPS or (not Wanderers.PRESETS.has(actor_id) and not CREATURE_PROFILES.has(actor_id)):
		return false
	if not data.get("texture") is Texture2D or not data.get("body_rect") is Rect2:
		return false
	if not data.get("primary_hand") is Vector2 or not data.get("secondary_hand") is Vector2:
		return false
	if str(data.get("depth","front")) not in ["front","back"]:
		return false
	var registered := data.duplicate()
	var facings := {}
	for facing in data.get("facing_variants",{}):
		var variant: Dictionary = data.facing_variants[facing]
		if not variant.get("texture") is Texture2D: return false
		facings[facing] = resolve_phases(variant)
		if facings[facing].is_empty(): return false
	registered.resolved_facings = facings
	registered = resolve_phases(registered)
	if registered.is_empty(): return false
	stance_assets[actor_id+":"+group] = registered
	return true

static func resolve_phases(data: Dictionary) -> Dictionary:
	var registered := data.duplicate()
	var phases := {}
	for phase in data.get("phase_variants",{}):
		var variant: Dictionary = data.phase_variants[phase]
		if not variant.get("texture") is Texture2D: return {}
		var resolved := registered.duplicate()
		resolved.merge(variant,true)
		phases[phase] = resolved
	registered.resolved_phases = phases
	return registered

static func body(profile: Dictionary) -> Dictionary:
	var human := Avatar.is_wanderer(profile)
	var id := Avatar.preset_id(profile) if human else str(profile.get("current_lootling_id","relic_beast"))
	var key := ("human:" if human else "creature:")+id
	if body_cache.has(key): return body_cache[key]
	var result: Dictionary
	if human:
		var preset := Wanderers.definition(id)
		var rect: Rect2 = preset.get("body_rect",BODY_RECT)
		var category: String = str(preset.body_frame)
		result = {"id":id,"category":category,"body_rect":rect,
			"primary_hand":rect.position+Vector2(preset.grip)*rect.size,
			"secondary_hand":rect.position+Vector2(SECONDARY_HANDS.get(id,Vector2(.30,.49)))*rect.size,"core":rect.position+Vector2(preset.core)*rect.size,
			"weapon_scale":float(HUMANOID_PROFILES.get(category,1.0)),"pose_profile":category,
			"handling":"hand","baked":""}
	else:
		var pose_id: String = str(Lootlings.definition(id).pose_profile)
		var data: Dictionary = CREATURE_PROFILES.get(pose_id,CREATURE_PROFILES.relic_beast)
		var rect := Rect2(-96,-128,192,192)
		result = {"id":id,"category":data.category,"body_rect":rect,
			"primary_hand":rect.position+Vector2(data.primary)*rect.size,
			"secondary_hand":rect.position+Vector2(data.secondary)*rect.size,
			"core":rect.position+Vector2(data.core)*rect.size,"weapon_scale":float(data.scale),
			"pose_profile":pose_id,"handling":data.get("handling","paw"),"baked":data.get("baked","")}
	result.texture = Avatar.texture(profile)
	result.tint = Avatar.tint(profile)
	result.head_bounds = Rect2(result.body_rect.position,Vector2(result.body_rect.size.x,result.body_rect.size.y*(.30 if human else .55)))
	result.wardrobe = {"mode":"baked","reserved":["head","torso","back","shield"] if result.baked == "shield" else ["head","torso","back"]}
	result.wardrobe_by_stance = {}
	if human:
		for group in STANCE_GROUPS:
			result.wardrobe_by_stance[group] = Wanderers.wardrobe_contract(id,group)
	body_cache[key] = result
	return result

static func sample(g, hurt: bool = false) -> Dictionary:
	var actor := body(g.profile)
	var item: Dictionary = g.inventory.equipped_item("Weapon")
	var subtype: String = str(item.get("weapon_type",""))
	if not GEOMETRY.has(subtype):
		subtype = {"VANGUARD":"maul","ROGUE":"daggers","RANGER":"bow","MAGE":"staff"}.get(g.current_weapon_family(),"maul")
	var weapon: Dictionary = GEOMETRY[subtype]
	var stance: Dictionary = STANCES[subtype]
	var key := str(actor.id)+":"+str(stance.group)
	if managed_stance != key and not managed_stance.is_empty():
		stance_assets.erase(managed_stance)
		managed_stance = ""
	if not stance_assets.has(key) and not absent_stances.has(key):
		var pack := Authored.pack(str(actor.id),str(stance.group))
		if not pack.is_empty() and register_stance(str(actor.id),str(stance.group),pack):
			managed_stance = key
		else:
			absent_stances[key] = true
	var authored: Dictionary = stance_assets.get(str(actor.id)+":"+str(stance.group),{})
	if not authored.get("weapon_types",[]).is_empty() and subtype not in authored.weapon_types:
		authored = {}
	var action := Actions.sample(g.current_weapon_family(),float(g.run_time),float(g.attack_clock),float(g.current_attack_interval()),float(g.attack_anim),hurt,float(g.player_reward_flash))
	var relic_motion := RelicMotion.applies(g) and not authored.is_empty()
	if relic_motion: action = RelicMotion.sample(g,hurt)
	# Optional keyed poses and baked wardrobe compatibility stay visual-only.
	if float(g.player_facing) < 0:
		authored = authored.get("resolved_facings",{}).get("left",authored)
	authored = authored.get("resolved_phases",{}).get(str(action.phase),authored)
	var opposite_art_required: bool = float(g.player_facing) < 0 and authored.get("facing_support","") == "right_only"
	if opposite_art_required: authored = {}
	var appearance: Dictionary = g.profile.get("wanderer",{}).get("appearance",{}).get("components",{})
	for slot in authored.get("wardrobe_requires",{}):
		if appearance.get(slot) != authored.wardrobe_requires[slot]:
			authored = {}
			break
	var facing := float(g.player_facing)
	var creature := not Avatar.is_wanderer(g.profile)
	var scale: Vector2 = Vector2(action.scale)
	if creature:
		scale *= Vector2(1.08,.92) if g.squash > 0 else Vector2.ONE
		if hurt: scale *= Vector2(1.06,.94)
	var idle := sin(clampf(float(g.player_idle_reaction)/.34,0,1)*PI)*.022*float(g.player_idle_reaction_direction) if creature else 0.0
	# A left export is already posed left. Mirror only the neutral/right fallback.
	var mirror := 1.0 if authored.get("facing_support","") == "left_only" else facing
	var offset := Vector2(action.offset)+Vector2(authored.get("body_offset",Vector2.ZERO))
	offset.x *= facing
	var root := Transform2D((float(action.rotation)+idle+float(authored.get("body_lean",0.0)))*facing,scale*Vector2(mirror,1),0,offset)
	if relic_motion:
		var feet := Vector2(0,float(authored.get("feet_baseline",53)))
		root.origin += feet-root.basis_xform(feet)
	var geometry: Dictionary = authored.get("weapon_overrides",{}).get(subtype,weapon)
	var size: Vector2 = Vector2(geometry.size)*float(actor.weapon_scale)*(1.0+clampi(int(item.get("evolution_stage",0)),0,2)*.06)
	if creature: size *= 1.0+float(g.build.weapon_tier())*.14
	size *= minf(1.0,minf(MAX_HELD_SIZE.x/size.x,MAX_HELD_SIZE.y/size.y))
	var primary: Vector2 = authored.get("primary_hand",actor.primary_hand)
	var secondary: Variant = authored.get("secondary_hand",actor.secondary_hand)
	var handling: Dictionary = HANDLING_OVERRIDES.get(str(actor.handling),{}).get(subtype,{})
	var angle := float(handling.get("angle",geometry.angle))+float(handling.get("angle_offset",0.0))
	var release_angle := float(handling.get("release",stance.release))
	var base_angle := angle
	angle += float(action.anticipate)*float(stance.ready)+float(action.release)*release_angle
	var rect := Rect2(-Vector2(geometry.grip)*size,size)
	var weapon_scale := Vector2(-1 if bool(geometry.get("mirror",false)) else 1,1)
	var support_status := "not_required"
	var secondary_grip: Vector2 = geometry.get("secondary_grip",stance.secondary_grip)
	if stance.handling in ["two_hand","paired"]:
		support_status = "authored_pose_required"
		if bool(authored.get("supports_two_hand",false)) and secondary is Vector2:
			var span: Vector2 = (secondary_grip-Vector2(geometry.grip))*size*weapon_scale
			var target: Vector2 = secondary-primary
			if span.length() > 1.0:
				var factor := target.length()/span.length()
				if factor >= .75 and factor <= 1.25 and size.x*factor <= MAX_HELD_SIZE.x and size.y*factor <= MAX_HELD_SIZE.y:
					size *= factor
					angle = target.angle()-span.angle()
					rect = Rect2(-Vector2(geometry.grip)*size,size)
					support_status = "authored_two_hand"
	var support := primary+((secondary_grip-Vector2(geometry.grip))*size*weapon_scale).rotated(angle)
	var socket := (rect.position+Vector2(geometry.socket)*size)*weapon_scale
	return {"action":action,"root":root,"body_rect":authored.get("body_rect",actor.body_rect),
		"texture":authored.get("texture",actor.texture),"tint":actor.tint,"hand":primary,"primary_hand":primary,
		"secondary_hand":secondary,"secondary_grip":support,"grip_span":primary.distance_to(support),
		"weapon_rect":rect,"weapon_rotation":angle,"weapon_scale":weapon_scale,"weapon_type":subtype,"stance":stance.group,"geometry":geometry,
		"handling":stance.handling,"support_status":support_status,
		"depth":authored.get("depth","front"),"foreground":authored.get("foreground",null),
		"weapon_origin":root*primary,
		"ready_transform":root*Transform2D(base_angle+float(stance.ready),weapon_scale,0,primary),
		"release_transform":root*Transform2D(base_angle+release_angle,weapon_scale,0,primary),
		"projectile":root*(primary+socket.rotated(angle)),"core":authored.get("core",actor.core),
		"opposite_art_required":opposite_art_required,
		"authored_facing":str(authored.get("facing_support","neutral_mirrored")),
		"body_profile":actor.category,"actor_id":actor.id,"head_bounds":actor.head_bounds,
		"baked_conflict":not str(actor.baked).is_empty(),"wardrobe":actor.wardrobe_by_stance.get(str(stance.group),actor.wardrobe)}

static func world_position(g) -> Vector2:
	if RelicMotion.applies(g): return Vector2(float(g.player_x),472)
	var family: String = g.current_weapon_family()
	var distance := 20.0 if family == "ROGUE" else 17.0 if family == "VANGUARD" else 3.0
	if g.attack_was_tap: distance += 3.0 if family in ["VANGUARD","ROGUE"] else 1.0
	return Vector2(float(g.player_x)+clampf(float(g.attack_anim)/.22,0,1)*distance*float(g.player_facing),472.0+sin(float(g.run_time)*4.3)*3.0)

static func projectile_origin(g) -> Vector2:
	return world_position(g)+Vector2(sample(g,g.player_flash>0).projectile)
