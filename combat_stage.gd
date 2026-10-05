extends RefCounted
# Presentation only. Never writes logical positions, clocks, HP or RNG.
const GROUND_Y := 548.0
const ENEMY_FOOT := 66.0
const EDGE := 12.0
const BODY_GAP := 26.0

static func enemy_radius(g) -> float:
	if g.enemy_is_boss: return float(preload("res://boss_presentation.gd").profile(g.campaign_id).display_size.x)*.5
	if g.enemy_is_miniboss: return 87.0
	var regional: Dictionary=preload("res://regional_enemy_presentation.gd").profile(g.enemy_name)
	if not regional.is_empty(): return float(regional.size.x)*.5
	return 78.0 if g.enemy_archetype=="tank" else 64.0

static func enemy_position(g, logical_x: float) -> Vector2:
	var factor: float=.82 if g.enemy_encounter.active and g.enemy_encounter.actors.size()==2 else .64 if g.enemy_encounter.active else 1.0
	var radius:=enemy_radius(g)*factor
	return Vector2(clampf(logical_x,EDGE+radius,480-EDGE-radius),GROUND_Y-ENEMY_FOOT*factor)

static func player_position(g, pose: Dictionary) -> Vector2:
	var rect: Rect2=pose.body_rect
	var radius: float=maxf(absf(rect.position.x),absf(rect.end.x))*(1.0 if pose.sprite_rig else 1.1)
	var target_x: float=enemy_position(g,g.target_combat_position().x).x
	if g.enemy_is_boss: target_x+=float(preload("res://boss_presentation.gd").profile(g.campaign_id).offset.x)
	var factor: float=.82 if g.enemy_encounter.active and g.enemy_encounter.actors.size()==2 else .64 if g.enemy_encounter.active else 1.0
	var separation: float=radius+enemy_radius(g)*factor+BODY_GAP
	var x: float=g.player_x
	# Clamp approach on its existing side; orientation never swaps actor lanes.
	if g.state=="playing" or g.enemy_alive or g.enemy_death_anim>0:
		x=minf(x,target_x-separation) if g.player_x<g.target_combat_position().x else maxf(x,target_x+separation)
	x=clampf(x,EDGE+radius,480-EDGE-radius)
	var feet: Vector2=pose.root*Vector2(0,float(pose.feet_baseline))
	var family: String=g.current_weapon_family()
	var reach: float=17 if family=="VANGUARD" else 20 if family=="ROGUE" else 3
	# Only the existing short attack animation may enter the contact gap.
	var lunge: float=clampf(g.attack_anim/.22,0,1)*reach*g.combat_facing()
	if preload("res://relic_greatsword_motion.gd").applies(g): lunge=0
	var bounds:=transformed_bounds(pose.root,rect)
	return Vector2(clampf(x+lunge,EDGE-bounds.position.x,480-EDGE-bounds.end.x),GROUND_Y-feet.y)

static func transformed_bounds(transform: Transform2D, rect: Rect2) -> Rect2:
	var points: Array[Vector2]=[transform*rect.position,transform*Vector2(rect.end.x,rect.position.y),transform*rect.end,transform*Vector2(rect.position.x,rect.end.y)]
	var result:=Rect2(points[0],Vector2.ZERO)
	for point in points: result=result.expand(point)
	return result
