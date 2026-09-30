extends RefCounted

const AffixCatalog = preload("res://affix_catalog.gd")

const RARITIES := ["COMMON", "RARE", "EPIC", "LEGENDARY"]
const RARITY_COLORS := {
	"COMMON": Color("#b7c0ca"),
	"RARE": Color("#62bfff"),
	"EPIC": Color("#c879ff"),
	"LEGENDARY": Color("#ffb43f")
}
const RARITY_POWER := {"COMMON":1.0, "RARE":1.25, "EPIC":1.6, "LEGENDARY":2.15}

const ITEMS := [
	{"id":"scrapfang_blade", "name":"Scrapfang Blade", "slot":"Weapon", "family":"VANGUARD", "icon":"BLADE", "evolution_path":["Emberfang", "Inferno Maw"], "desc":"Heavy scavenged blade. Strong, deliberate hits.", "effects":{"damage_mult":0.14, "armor":0.03}},
	{"id":"mimic_mallet", "name":"Mimic Mallet", "slot":"Weapon", "family":"VANGUARD", "icon":"MALLET", "desc":"Kills echo into the next foe.", "effects":{"damage_mult":0.20, "kill_explosion":0.45}},
	{"id":"bonebow", "name":"Bonebow", "slot":"Weapon", "family":"RANGER", "icon":"BOW", "evolution_path":["Wyrmspine Ballista"], "desc":"Ranged, rapid shots with keen aim.", "effects":{"attack_speed":0.12, "crit":0.06}},
	{"id":"glimmerstaff", "name":"Glimmerstaff", "slot":"Weapon", "family":"MAGE", "icon":"STAFF", "evolution_path":["Tidal Scepter", "Leviathan's Eye"], "desc":"Every fifth spell repeats at reduced power.", "effects":{"fire_damage":0.12, "repeat_every":5}},
	{"id":"moonbite_daggers", "name":"Moonbite Daggers", "slot":"Weapon", "family":"ROGUE", "icon":"DAGGERS", "evolution_path":["Crescent Twins", "Eclipse Fangs"], "desc":"Fast blades sharpen crits and executions.", "effects":{"crit":0.09, "execute":0.05}},
	{"id":"mossguard_harness", "name":"Mossguard Harness", "slot":"Armour", "icon":"GUARD", "desc":"Living bark cushions hits and grows vitality.", "effects":{"max_hp":32.0, "armor":0.07}},
	{"id":"ironpaw_plate", "name":"Ironpaw Plate", "slot":"Armour", "icon":"PLATE", "desc":"Heavy plating trades speed for force.", "effects":{"max_hp":48.0, "damage_mult":0.12, "attack_slow":0.10}},
	{"id":"hoarders_locket", "name":"Hoarder's Locket", "slot":"Relic", "icon":"LOCKET", "desc":"Enemies spill more Run Scrip.", "effects":{"coin_mult":0.35}},
	{"id":"cursed_ring", "name":"Definitely Not Cursed Ring", "slot":"Relic", "icon":"RING", "desc":"Huge power while hurt. Probably safe.", "effects":{"low_health_damage":0.48, "max_hp":-12.0}},
	{"id":"ember_pop", "name":"Ember Pop Rune", "slot":"Rune", "icon":"FIRE", "desc":"Burns hit harder and kills may erupt.", "effects":{"fire_damage":0.28, "kill_explosion":0.30}},
	{"id":"stormspark", "name":"Stormspark Rune", "slot":"Rune", "icon":"SPARK", "desc":"Critical hits call a lightning spark.", "effects":{"crit_lightning":0.55}},
	{"id":"toxic_burst", "name":"Toxic Burst Rune", "slot":"Rune", "icon":"TOXIN", "desc":"Poison stacks faster and lingers longer.", "effects":{"poison_bonus":1, "poison_duration":0.45}},
	{"id":"ground_slam", "name":"Ground Slam Rune", "slot":"Rune", "icon":"SLAM", "desc":"Heavy hits punish bosses.", "effects":{"boss_damage":0.30, "heavy_bonus":0.35}},
	{"id":"sunken_cleaver", "name":"Sunken Cleaver", "slot":"Weapon", "family":"VANGUARD", "icon":"BLADE", "desc":"A salt-dark blade that lands like an anchor.", "effects":{"damage_mult":0.17, "boss_damage":0.08}},
	{"id":"crooked_longbow", "name":"Crooked Longbow", "slot":"Weapon", "family":"RANGER", "icon":"BOW", "desc":"Ugly, eager and remarkably accurate.", "effects":{"attack_speed":0.09, "crit":0.05}},
	{"id":"ruinweave_coat", "name":"Ruinweave Coat", "slot":"Armour", "icon":"GUARD", "desc":"Many pockets. Some are structural.", "effects":{"max_hp":25.0, "armor":0.045, "coin_mult":0.08}},
	{"id":"dragon_scale_patch", "name":"Dragon-Scale Patch", "slot":"Armour", "icon":"PLATE", "desc":"One scale is still technically armour.", "effects":{"max_hp":38.0, "boss_damage":0.08}},
	{"id":"lucky_bell", "name":"Suspicious Lucky Bell", "slot":"Relic", "icon":"LOCKET", "desc":"Rings when treasure is pretending not to exist.", "effects":{"coin_mult":0.20, "crit":0.025}},
	{"id":"relic_magnet_charm", "name":"Relic Magnet Charm", "slot":"Relic", "icon":"RING", "desc":"Tugs loose relic energy into useful patterns.", "effects":{"attack_speed":0.04, "crit_lightning":0.18}},
	{"id":"echo_rune", "name":"Echo Rune", "slot":"Rune", "icon":"SPARK", "desc":"The ruins remember a good hit.", "effects":{"kill_explosion":0.22, "heavy_bonus":0.14}},
	{"id":"mire_rune", "name":"Mire Rune", "slot":"Rune", "icon":"TOXIN", "desc":"A patient little curse in polished stone.", "effects":{"poison_bonus":1, "poison_duration":0.25}}
]

static func definition(id: String) -> Dictionary:
	for item in ITEMS:
		if item.id == id:
			return item
	return {}

static func create_item(id: String, rarity: String, serial: int = 0) -> Dictionary:
	var source := definition(id)
	if source.is_empty():
		return {}
	var item := source.duplicate(true)
	item.rarity = rarity if rarity in RARITIES else "COMMON"
	item.serial = serial
	var scale: float = RARITY_POWER[item.rarity]
	for key in ["damage_mult", "attack_speed", "crit", "max_hp", "armor", "coin_mult", "low_health_damage", "fire_damage", "crit_lightning", "poison_duration", "boss_damage", "heavy_bonus", "kill_explosion", "execute"]:
		if item.effects.has(key):
			item.effects[key] = float(item.effects[key]) * scale
	item.affix_ids = []
	item.affix_names = []
	item.signature_hooks = []
	return item

static func create_affixed_item(id: String, rarity: String, serial: int, affix_ids: Array) -> Dictionary:
	return AffixCatalog.apply(create_item(id, rarity, serial), affix_ids)

static func rarity_rank(rarity: String) -> int:
	return maxi(0, RARITIES.find(rarity))

static func rarity_color(rarity: String) -> Color:
	return RARITY_COLORS.get(rarity, RARITY_COLORS.COMMON)

static func display_slot(slot: String) -> String:
	return "CHARM" if slot == "Relic" else slot.to_upper()

static func scrap_value(item: Dictionary) -> int:
	return [3, 8, 18, 45][rarity_rank(item.get("rarity", "COMMON"))]

static func describe_effects(item: Dictionary) -> String:
	var effects: Dictionary = item.get("effects", {})
	var parts: Array[String] = []
	if effects.has("damage_mult"): parts.append("%+.0f%% damage" % (effects.damage_mult * 100.0))
	if effects.has("attack_speed"): parts.append("%+.0f%% attack speed" % (effects.attack_speed * 100.0))
	if effects.has("attack_slow"): parts.append("%.0f%% slower attacks" % (effects.attack_slow * 100.0))
	if effects.has("crit"): parts.append("%+.0f%% crit" % (effects.crit * 100.0))
	if effects.has("max_hp"): parts.append("%+.0f max HP" % effects.max_hp)
	if effects.has("armor"): parts.append("%+.0f%% armour" % (effects.armor * 100.0))
	if effects.has("coin_mult"): parts.append("%+.0f%% Run Scrip" % (effects.coin_mult * 100.0))
	if effects.has("execute"): parts.append("%+.0f%% execute threshold" % (effects.execute * 100.0))
	if effects.has("repeat_every"): parts.append("repeat every %d attacks" % effects.repeat_every)
	if effects.has("crit_lightning"): parts.append("crits spark lightning")
	if effects.has("poison_bonus"): parts.append("+%d poison stacks" % effects.poison_bonus)
	if effects.has("fire_damage"): parts.append("%+.0f%% burn power" % (effects.fire_damage * 100.0))
	if effects.has("kill_explosion"): parts.append("kills store explosion damage")
	if effects.has("low_health_damage"): parts.append("power surges at low HP")
	if effects.has("boss_damage"): parts.append("%+.0f%% boss damage" % (effects.boss_damage * 100.0))
	if effects.has("heavy_bonus"): parts.append("stronger heavy rhythm hits")
	for line in AffixCatalog.descriptions(item):
		parts.append(line)
	return "  /  ".join(parts)
