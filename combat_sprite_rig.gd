extends RefCounted
# Original three-quarter combat bodies with articulated matching limbs.
# Painted menu portraits and already-authored combat exports remain separate.
const PALETTES := {
	"relic_beast":["#ba7035","#f4ce82","#e8b94d"], "emberhorn":["#963c39","#ef8a58","#ffd076"],
	"mosskin":["#52685a","#a0b585","#c9d879"], "moonkip":["#748cad","#d6eafa","#b6a1ef"],
	"pebblewyrm":["#76665c","#b8a38a","#e6bb68"], "glimmerfin":["#297b88","#8edfd7","#d7a4ef"],
	"gloomlet":["#42355e","#8275a5","#d79ced"], "vault_runner":["#3b6673","#9a674a","#76dae3"],
	"ruin_warden":["#514b40","#b58361","#e0bc65"], "nightstage_drifter":["#383b51","#b59d7c","#b495e5"],
	"velvet_astrologer":["#5d365e","#a9745b","#e4bd76"], "ashtrail_hunter":["#655344","#dfb8a0","#cba573"]}
static var textures: Dictionary = {}
static var boots: Dictionary = {}

static func texture(id: String) -> Texture2D:
	if not textures.has(id): textures[id] = load("res://art/sprites/combat_rigs/%s.svg" % id)
	return textures[id]

static func contacts(g, action: Dictionary, subtype: String) -> Array:
	var a: float=action.anticipate
	var r: float=action.release
	var primary:=Vector2(40-a*14+r*18,-17-a*13-r*14)
	var secondary:=Vector2(12-a*9,-8-a*9)
	if subtype in ["bow","crossbow"]: primary=Vector2(48,-29); secondary=Vector2(14,-25)
	elif subtype in ["staff","wand","orb"]: primary=Vector2(40+a*4,-16-a*20-r*18)
	elif subtype in ["daggers","claws"]:
		var lead: int=int(g.attack_sequence)%2
		primary=Vector2(34-a*12+r*(23 if lead==0 else 7),-19-a*8-r*10)
		secondary=Vector2(10-a*10+r*(23 if lead==1 else 7),-1-a*8-r*14)
	return [primary,secondary]

static func segment(g, a: Vector2, b: Vector2, width: float, color: Color) -> void:
	var normal: Vector2=(b-a).normalized().orthogonal()*width*.5
	g.draw_line(a,b,Color("#172334"),width+3,true)
	g.draw_polygon(PackedVector2Array([a-normal,a+normal,b+normal*.75,b-normal*.75]),PackedColorArray([color.darkened(.12),color.lightened(.15),color,color.darkened(.2)]))

static func arm(g, shoulder: Vector2, hand: Vector2, color: Color, rear: bool) -> void:
	# Two-bone IK; elbow bend stays anatomical while the hand follows the grip.
	var delta:=hand-shoulder
	var distance: float=maxf(1,delta.length())
	var length: float=maxf(28,distance*.54)
	var bend: float=sqrt(maxf(0,length*length-distance*distance*.25))
	var elbow:=shoulder+delta*.5+delta.normalized().orthogonal()*bend*(1 if rear else -1)
	segment(g,shoulder,elbow,13,color)
	segment(g,elbow,hand,10,color.lightened(.08))
	g.draw_circle(elbow,5,color.darkened(.1))
	var cuff:=elbow.lerp(hand,.83)
	g.draw_line(cuff-Vector2(0,5),cuff+Vector2(0,5),Color("#2b3344"),4,true)

static func draw_limbs(g, pose: Dictionary, front: bool) -> void:
	var colors: Array=PALETTES[pose.actor_id]
	var coat:=Color(colors[0])
	if not front:
		var moving: bool=absf(g.player_x-g.target_player_x())>4
		var stride: float=sin(g.run_time*9)*11 if moving else 0
		var a: float=pose.action.anticipate
		for index in range(2):
			var hip:=Vector2(-13+index*26,6)
			var foot:=Vector2(-24+index*49+(stride if index==0 else -stride),61)
			if pose.actor_id=="glimmerfin": foot.y-=10+sin(g.run_time*3)*3
			var knee:=hip.lerp(foot,.52)+Vector2(-7-a*5, -a*2)
			segment(g,hip,knee,16,coat.darkened(.15 if index==0 else 0))
			segment(g,knee,foot,13,coat)
			g.draw_style_box(boot_box(Color(colors[1]).darkened(.35)),Rect2(foot+Vector2(-8,-5),Vector2(23,9)))
		arm(g,Vector2(-18,-34),pose.secondary_hand,coat.darkened(.17),true)
	else:
		arm(g,Vector2(13,-36),pose.primary_hand,coat,false)

static func boot_box(color: Color) -> StyleBoxFlat:
	if boots.has(color): return boots[color]
	var box:=StyleBoxFlat.new()
	box.bg_color=color; box.border_color=Color("#172334")
	box.set_border_width_all(2); box.set_corner_radius_all(4)
	boots[color]=box
	return box

static func draw_hands(g, pose: Dictionary) -> void:
	var color:=Color(PALETTES[pose.actor_id][1])
	for hand in [pose.primary_hand,pose.secondary_hand]:
		g.draw_circle(hand,5.5,Color("#172334"))
		g.draw_circle(hand,4,color)
		g.draw_line(hand+Vector2(-2,-1),hand+Vector2(2,1),color.darkened(.3),1,true)
