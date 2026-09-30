extends RefCounted

const PROFILES := {
	"VANGUARD":{"idle_speed":1.8, "idle_amount":0.009, "anticipate_lean":-0.10, "release_lean":0.13, "recoil":-0.045, "stretch":0.055, "settle":0.035},
	"ROGUE":{"idle_speed":4.0, "idle_amount":0.018, "anticipate_lean":-0.075, "release_lean":0.16, "recoil":-0.025, "stretch":0.075, "settle":0.020},
	"RANGER":{"idle_speed":2.8, "idle_amount":0.014, "anticipate_lean":-0.055, "release_lean":-0.035, "recoil":-0.075, "stretch":0.035, "settle":0.030},
	"MAGE":{"idle_speed":2.1, "idle_amount":0.012, "anticipate_lean":-0.045, "release_lean":-0.055, "recoil":-0.065, "stretch":0.040, "settle":0.038}
}

static func profile(family: String) -> Dictionary:
	return PROFILES.get(family, PROFILES.VANGUARD)

static func sample(family: String, run_time: float, attack_clock: float, attack_interval: float, attack_anim: float, hurt: bool, reward_reaction: float = 0.0) -> Dictionary:
	var p: Dictionary = profile(family)
	var idle := sin(run_time * float(p.idle_speed)) * float(p.idle_amount)
	var breath := sin(run_time * 1.9) * 0.010
	var anticipation_window := minf(0.18, attack_interval * 0.22)
	var anticipate := 0.0
	if attack_anim <= 0.0 and attack_clock <= anticipation_window:
		anticipate = clampf(1.0 - attack_clock / maxf(0.01, anticipation_window), 0.0, 1.0)
	var release := clampf(attack_anim / 0.22, 0.0, 1.0)
	var impact := sin((1.0 - release) * PI) if release > 0.0 else 0.0
	var recovery := clampf((0.10 - attack_anim) / 0.10, 0.0, 1.0) if attack_anim > 0.0 else 0.0
	var rotation := idle + anticipate * float(p.anticipate_lean) + release * float(p.release_lean)
	rotation += impact * float(p.recoil) + recovery * float(p.settle)
	var root_shift := Vector2(-anticipate * 5.0 + release * 7.0, -impact * 2.0)
	if family in ["RANGER", "MAGE"]:
		root_shift.x = -anticipate * 3.0 - impact * 4.0
	if hurt:
		rotation -= 0.065
		root_shift.x -= 5.0
	var reward := sin(clampf(reward_reaction / 0.45, 0.0, 1.0) * PI)
	root_shift.y -= reward * 5.0
	rotation -= reward * 0.025
	return {
		"phase":"HURT" if hurt else "IMPACT" if impact > 0.72 else "ATTACK" if release > 0.0 else "ANTICIPATE" if anticipate > 0.0 else "IDLE",
		"rotation":rotation,
		"offset":root_shift,
		"scale":Vector2(1.0 + breath + impact * float(p.stretch), 1.0 - breath * 0.72 - impact * float(p.stretch) * 0.55),
		"anticipate":anticipate,
		"release":release,
		"impact":impact
	}
