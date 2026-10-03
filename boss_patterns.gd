extends RefCounted

# Each six-action loop has a recovery action. Pressure redistributes the old
# attack budget rather than adding unavoidable burst on top of it.
const PATTERNS := {
	"act_i":{"title":"Hoard Levy", "calls":["CLAWS","BRACE","COIN BREATH","RECOVER","TAIL SWEEP","CLAWS"],"power":[0.9,0.75,1.3,0.0,1.15,0.9]},
	"mossglass_wilds":{"title":"Stolen Spring", "calls":["ROOT SWEEP","MIRROR CHARGE","THORN CAST","RECOVER","ROOT SWEEP","THORN CAST"],"power":[1.1,0.7,1.2,0.0,1.1,0.9]},
	"moonfen":{"title":"False Lantern", "calls":["POUNCE","FEINT","LANTERN BITE","RECOVER","POUNCE","BITE"],"power":[1.2,0.6,1.3,0.0,1.1,0.8]},
	"frostbell_hollows":{"title":"Swallowed Chime", "calls":["BELL STRIKE","RIME BREATH","CHIME","RECOVER","BELL STRIKE","RIME BREATH"],"power":[1.1,1.1,0.9,0.0,1.1,0.9]},
	"sunken_gearworks":{"title":"Endless Shift", "calls":["PISTON","PRESSURE RISE","STEAM VENT","COOLING","PISTON","GEAR SWEEP"],"power":[1.1,0.6,1.35,0.0,1.1,0.95]},
	"cinder_crown":{"title":"Burning Tribute", "calls":["HAMMER","COAL BREATH","TRIBUTE FLARE","RECOVER","HAMMER","CINDER SWEEP"],"power":[1.15,0.85,1.3,0.0,1.1,0.9]},
	"starfall_archive":{"title":"Witness Erasure", "calls":["INK STRIKE","ANNOTATE","ERASE","RECOVER","PAGE CUT","INK STRIKE"],"power":[1.0,0.65,1.35,0.0,1.1,1.0]},
	"nullglass_expanse":{"title":"Unchosen Reflection", "calls":["ECHO","REFRACT","GLASS CUT","RECOVER","ECHO","SHATTER"],"power":[0.9,0.7,1.2,0.0,1.0,1.2]},
	"skyhook_bastion":{"title":"Closed Horizon", "calls":["CHAIN SWEEP","REEL IN","ANCHOR SLAM","RECOVER","CHAIN SWEEP","HOOK"],"power":[1.1,0.65,1.35,0.0,1.0,0.9]},
	"first_hoard":{"title":"Broken Promise", "calls":["CROWN STRIKE","CLAIM","VAULT SEAL","RECOVER","CROWN STRIKE","COLLECT"],"power":[1.0,0.7,1.3,0.0,1.1,1.0]},
}

static func next(game) -> Dictionary:
	var pattern: Dictionary = PATTERNS.get(game.campaign_id,PATTERNS.act_i)
	if game.enemy_is_miniboss:
		var titles := ["SHIELD BASH","GUARD","HEAVY SWING","RECOVER"]
		if game.campaign_id != "act_i": titles = [pattern.calls[0],pattern.calls[1],pattern.calls[2],"RECOVER"]
		var powers := [1.0,0.7,1.3,0.0]
		var index: int = game.enemy_attack_count % titles.size()
		return {"text":titles[index],"power":powers[index],"recovery":powers[index] == 0.0}
	var index: int = (game.enemy_attack_count + (2 if game.boss_phase == 2 else 0)) % pattern.calls.size()
	return {"text":pattern.calls[index],"power":pattern.power[index],"recovery":pattern.power[index] == 0.0}
