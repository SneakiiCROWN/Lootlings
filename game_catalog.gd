extends RefCounted

const UPGRADES := [
	{"id":"damage", "name":"COLOSSAL GRIP", "desc":"+35% damage", "icon":"FIST", "rarity":"COMMON", "tags":["Physical"]},
	{"id":"crit", "name":"RELIC EDGE", "desc":"+12% crit chance", "icon":"CRIT", "rarity":"RARE", "tags":["Physical"]},
	{"id":"execute", "name":"MERCY BREAKER", "desc":"Hits finish foes below 12% HP", "icon":"YEET", "rarity":"EPIC", "tags":["Physical", "Physical"]},
	{"id":"heavy", "name":"QUAKE GRIP", "desc":"Periodic heavy hits deal 2.2x damage", "icon":"BOOM", "rarity":"EPIC", "tags":["Physical"]},
	{"id":"speed", "name":"QUICK GRIP", "desc":"18% shorter attack interval", "icon":"ZAP", "rarity":"COMMON", "tags":["Lightning"]},
	{"id":"multi", "name":"TWIN VOLT", "desc":"+1 hit each auto attack", "icon":"x2", "rarity":"EPIC", "tags":["Lightning", "Lightning"]},
	{"id":"tap", "name":"STATIC FINGERS", "desc":"Taps gain 80% of base hit power", "icon":"TAP", "rarity":"COMMON", "tags":["Lightning"]},
	{"id":"storm", "name":"STORM RHYTHM", "desc":"Periodic strikes add lightning damage", "icon":"ARC", "rarity":"RARE", "tags":["Lightning"]},
	{"id":"splash", "name":"CINDER WAKE", "desc":"Carry damage into the next foe", "icon":"FIRE", "rarity":"RARE", "tags":["Fire"]},
	{"id":"ignite", "name":"EMBER TEETH", "desc":"Strengthen damage over time from burns", "icon":"BURN", "rarity":"COMMON", "tags":["Fire"]},
	{"id":"frenzy", "name":"FURNACE HEART", "desc":"Faster when hurt", "icon":"RAGE", "rarity":"EPIC", "tags":["Fire", "Fire"]},
	{"id":"wildfire", "name":"WILDFIRE", "desc":"Burning foes explode", "icon":"NOVA", "rarity":"EPIC", "tags":["Fire"]},
	{"id":"vamp", "name":"TOXIC FANG", "desc":"Heal 4% of damage dealt", "icon":"DRAIN", "rarity":"RARE", "tags":["Poison"]},
	{"id":"regen", "name":"MUTANT MOSS", "desc":"Regenerate 1.5 HP/sec", "icon":"REGEN", "rarity":"COMMON", "tags":["Poison"]},
	{"id":"venom", "name":"VENOM COAT", "desc":"Hits stack poison damage", "icon":"TOXIN", "rarity":"COMMON", "tags":["Poison"]},
	{"id":"plague", "name":"PLAGUE SIPHON", "desc":"Poison damage restores health", "icon":"SIPHON", "rarity":"EPIC", "tags":["Poison", "Poison"]},
	{"id":"armor", "name":"SCAVENGER PLATE", "desc":"+30 HP, 8% less damage", "icon":"HP", "rarity":"COMMON", "tags":["Physical"]},
	{"id":"greed", "name":"RELIC MAGNET", "desc":"+25% Run Scrip, +15% XP", "icon":"LOOT", "rarity":"RARE", "tags":[]}
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
