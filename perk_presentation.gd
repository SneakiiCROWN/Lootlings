extends RefCounted
# Read-only descriptions of existing effects. Never predicts conditional DPS.
static func effect(g, up: Dictionary) -> String:
	match str(up.id):
		"damage": return "Strike power +35%\nStacks multiplicatively"
		"speed": return "Auto delay %.2fs → %.2fs" % [g.current_attack_interval(), maxf(.16,g.current_attack_interval()*.82)]
		"crit":
			var before: float = g.effective_crit_chance()
			var gain: float = minf(.72,g.crit_chance+.12)-g.crit_chance
			return "Crit %.1f%% → %.1f%%\nGear included; 85%% total cap" % [before*100,minf(.85,before+gain)*100]
		"execute": return "Finish threshold %.0f%% → %.0f%% HP" % [g.execute_ratio*100,minf(.35,g.execute_ratio+.12)*100]
		"vamp": return "Hit leech %.1f%% → %.1f%%\nActual HP removed; 8%% cap" % [g.life_steal*100,minf(.08,g.life_steal+.04)*100]
		"regen": return "Healing %.2f → %.2f HP/s" % [g.regen_per_second,g.regen_per_second+1.5]
		"armor":
			var gear: float = g.inventory.effect_total("armor") + (.04 if g.current_weapon_family()=="VANGUARD" else 0)
			return "+30 current / maximum HP\nArmour %.1f%% → %.1f%%" % [minf(.72,g.armor+gear)*100,minf(.72,1-(1-g.armor)*.92+gear)*100]
		"multi": return "Base auto hits %d → %d\nTap hit count unchanged" % [g.multi_hits+int(g.inventory.effect_total("extra_hits")),g.multi_hits+1+int(g.inventory.effect_total("extra_hits"))]
		"tap": return "Tap power %.0f%% → %.0f%%\nBefore combo / weapon modifiers" % [g.tap_mult*100,(g.tap_mult+.8)*100]
		"heavy":
			var count: int = g.build.count("Physical")
			return "Heavy: every %d → %d attacks\nRelease: ×%.2f power" % [maxi(3,7-mini(count+g.heavy_power,4)),maxi(3,7-mini(count+1+g.heavy_power+1,4)),2.2+g.inventory.effect_total("heavy_bonus")]
		"splash": return "Carry %.0f%% → %.0f%% hit power\nInto the next foe" % [g.splash_ratio*100,(g.splash_ratio+.25)*100]
		_: return str(up.desc)
