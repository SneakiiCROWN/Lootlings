extends RefCounted

const UPGRADES := [
	{"id":"damage", "name":"HUGE HAMMER", "desc":"+35% damage", "icon":"HAMMER", "rarity":"COMMON"},
	{"id":"speed", "name":"QUICK GRIP", "desc":"Attack 18% faster", "icon":"ZAP", "rarity":"COMMON"},
	{"id":"crit", "name":"KEEN EDGE", "desc":"+12% crit chance", "icon":"CRIT", "rarity":"RARE"},
	{"id":"multi", "name":"TWIN BONK", "desc":"+1 hit each attack", "icon":"x2", "rarity":"EPIC"},
	{"id":"splash", "name":"SHOCKWAVE", "desc":"Damage echoes to next foe", "icon":"WAVE", "rarity":"RARE"},
	{"id":"vamp", "name":"SNACKY FANG", "desc":"Heal 4% of damage dealt", "icon":"HEAL", "rarity":"RARE"},
	{"id":"armor", "name":"TIN LID", "desc":"+30 max HP, 8% less damage", "icon":"HP", "rarity":"COMMON"},
	{"id":"frenzy", "name":"PANIC POWER", "desc":"Faster when hurt", "icon":"RAGE", "rarity":"EPIC"},
	{"id":"tap", "name":"TAP TEMPEST", "desc":"Taps deal +80% damage", "icon":"TAP", "rarity":"COMMON"},
	{"id":"execute", "name":"YEET", "desc":"Execute foes below 12% HP", "icon":"YEET", "rarity":"EPIC"},
	{"id":"regen", "name":"BANDAGE", "desc":"Regenerate 1.5 HP/sec", "icon":"REGEN", "rarity":"COMMON"},
	{"id":"greed", "name":"SHINY BRAIN", "desc":"+50% coins and XP", "icon":"LOOT", "rarity":"RARE"}
]

static func rarity_color(rarity: String) -> Color:
	match rarity:
		"EPIC": return Color("#d497ff")
		"RARE": return Color("#63d9ff")
		_: return Color("#8de0a5")

static func display_name(id: String) -> String:
	for upgrade in UPGRADES:
		if upgrade.id == id:
			return upgrade.name.to_pascal_case()
	return id.to_pascal_case()
