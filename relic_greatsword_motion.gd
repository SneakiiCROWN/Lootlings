extends RefCounted
# The slice's two real paw poses share a planted-foot pivot. Visual only:
# tap damage remains immediate; automatic anticipation reads the real clock.
static func applies(g) -> bool:
	return str(g.profile.get("avatar_mode","lootling")) != "wanderer" and str(g.profile.get("current_lootling_id","relic_beast")) == "relic_beast" and str(g.inventory.equipped_item("Weapon").get("weapon_type","")) == "greatsword" and float(g.player_facing) > 0

static func moving(g) -> bool:
	return g.state == "playing" and g.enemy_alive and float(g.player_x) < float(g.target_player_x()) - 4.0

static func sample(g, hurt: bool) -> Dictionary:
	var clock := float(g.attack_clock)
	var anim := float(g.attack_anim)
	var elapsed := .22 - anim
	var phase := "MOVE" if moving(g) else "IDLE"
	var rotation := sin(float(g.run_time)*1.8)*.012
	var offset := Vector2.ZERO
	var scale := Vector2(1,1+sin(float(g.run_time)*1.9)*.006)
	var anticipate := 0.0
	var release := clampf(anim/.22,0,1)
	var impact := 0.0
	if anim > 0:
		# Immediate broad strike, then decelerating follow-through and a short
		# grounded return. Never add a windup after a tap has already hit.
		if elapsed < .075:
			phase = "ATTACK" if elapsed < .025 else "IMPACT"
			var t := clampf(elapsed/.075,0,1)
			rotation = lerpf(.16,.25,sin(t*PI*.5))
			offset = Vector2(lerpf(10,12,t),0)
			impact = sin(t*PI)
		elif anim > .055:
			phase = "RECOVER"
			var t := clampf((elapsed-.075)/.09,0,1)
			rotation = lerpf(.25,.07,t*t)
			offset = Vector2(lerpf(12,3,t),0)
		else:
			phase = "SETTLE"
			var t := clampf(anim/.055,0,1)
			rotation = -.045*sin(t*PI)
			offset = Vector2(-2*sin(t*PI),0)
	elif not moving(g) and g.state == "playing" and g.enemy_alive and clock < minf(.20,float(g.current_attack_interval())*.25):
		phase = "ANTICIPATE"
		anticipate = clampf(1-clock/minf(.20,float(g.current_attack_interval())*.25),0,1)
		rotation = -.18*anticipate
		offset.x = -4*anticipate
		scale = Vector2(1+.025*anticipate,1-.025*anticipate)
	elif moving(g):
		rotation = sin(float(g.run_time)*12)*.025
		offset.y = -absf(sin(float(g.run_time)*12))*1.8
	if hurt:
		phase = "HURT"
		rotation -= .09
		offset.x -= 5
	var reward := sin(clampf(float(g.player_reward_flash)/.45,0,1)*PI)
	if reward > 0 and anim <= 0 and not hurt:
		phase = "REWARD"
		offset.y -= reward*4
		rotation -= reward*.025
	return {"phase":phase,"rotation":rotation,"offset":offset,"scale":scale,"anticipate":anticipate,"release":release,"impact":impact}
