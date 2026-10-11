extends RefCounted

const AffixCatalog = preload("res://affix_catalog.gd")
const WeaponCatalog = preload("res://weapon_catalog.gd")
const Phase3 = preload("res://phase3_item_catalog.gd")

const RARITIES := ["COMMON", "RARE", "EPIC", "LEGENDARY", "RED", "MYTHICAL SHINY"]
const RARITY_COLORS := {
	"COMMON": Color("#b7c0ca"),
	"RARE": Color("#62bfff"),
	"EPIC": Color("#c879ff"),
	"LEGENDARY": Color("#ffb43f"), "RED":Color("#ff4e69"),"MYTHICAL SHINY":Color("#d4fff4")
}
const RARITY_POWER := {"COMMON":1.0, "RARE":1.25, "EPIC":1.6, "LEGENDARY":2.15,"RED":2.15,"MYTHICAL SHINY":2.15}

const ITEMS := [
	{"id":"scrapfang_blade", "name":"Scrapfang Blade", "slot":"Weapon", "family":"VANGUARD", "weapon_type":"greatsword", "icon":"BLADE", "evolution_path":["Vaultcleaver", "Crowncleaver"], "desc":"Heavy steel, a steady grip, and no intention of asking the lock nicely.", "effects":{"damage_mult":0.14, "armor":0.03}},
	{"id":"mimic_mallet", "name":"Mimic Mallet", "slot":"Weapon", "family":"VANGUARD", "weapon_type":"maul", "icon":"MALLET", "evolution_path":["Vault Mallet", "Hoardhammer"], "desc":"A hammer with a hungry grin. Its kill blast carries trouble forward.", "effects":{"damage_mult":0.20, "kill_explosion":0.45}},
	{"id":"bonebow", "name":"Bonebow", "slot":"Weapon", "family":"RANGER", "weapon_type":"bow", "projectile":"arrow", "icon":"BOW", "evolution_path":["Ruin Longbow", "Starstring"], "desc":"Light limbs, quick shots. The previous owner was less quick.", "effects":{"attack_speed":0.12, "crit":0.06}},
	{"id":"glimmerstaff", "name":"Glimmerstaff", "slot":"Weapon", "family":"MAGE", "weapon_type":"staff", "projectile":"magic_orb", "icon":"STAFF", "evolution_path":["Starstaff", "Observatory Spine"], "desc":"Every fifth spell echoes. Even the staff enjoys a second opinion.", "effects":{"fire_damage":0.12, "repeat_every":5}},
	{"id":"moonbite_daggers", "name":"Moonbite Daggers", "slot":"Weapon", "family":"ROGUE", "weapon_type":"daggers", "icon":"DAGGERS", "evolution_path":["Moonfangs", "Night's Receipt"], "desc":"Quick blades for critical hits and finishing wounded foes. Subtlety optional.", "effects":{"crit":0.09, "execute":0.05}},
	{"id":"mossguard_harness", "name":"Mossguard Harness", "slot":"Armour", "icon":"GUARD", "desc":"Living bark cushions hits and grows vitality.", "effects":{"max_hp":32.0, "armor":0.07}},
	{"id":"ironpaw_plate", "name":"Ironpaw Plate", "slot":"Armour", "icon":"PLATE", "desc":"Heavy plating trades speed for force.", "effects":{"max_hp":48.0, "damage_mult":0.12, "attack_slow":0.10}},
	{"id":"hoarders_locket", "name":"Hoarder's Locket", "slot":"Relic", "icon":"LOCKET", "desc":"Learn from every find. Its old treasure bonus now grants expedition XP.", "effects":{"coin_mult":0.35}},
	{"id":"cursed_ring", "name":"Definitely Not Cursed Ring", "slot":"Relic", "icon":"RING", "desc":"Strength at low health costs maximum HP. The inscription says probably.", "effects":{"low_health_damage":0.48, "max_hp":-12.0}},
	{"id":"ember_pop", "name":"Ember Pop Rune", "slot":"Rune", "icon":"FIRE", "desc":"An ember sealed in old kiln-glass. Strengthens burns and blasts on kills.", "effects":{"fire_damage":0.28, "kill_explosion":0.30}},
	{"id":"stormspark", "name":"Stormspark Rune", "slot":"Rune", "icon":"SPARK", "desc":"Critical hits call a lightning spark.", "effects":{"crit_lightning":0.55}},
	{"id":"toxic_burst", "name":"Toxic Burst Rune", "slot":"Rune", "icon":"TOXIN", "desc":"Poison stacks faster and lingers longer.", "effects":{"poison_bonus":1, "poison_duration":0.45}},
	{"id":"ground_slam", "name":"Ground Slam Rune", "slot":"Rune", "icon":"SLAM", "desc":"A deep-earth seal that lends weight to heavy strikes against guardians.", "effects":{"boss_damage":0.30, "heavy_bonus":0.35}},
	{"id":"sunken_cleaver", "name":"Sunken Cleaver", "slot":"Weapon", "family":"VANGUARD", "weapon_type":"greatsword", "icon":"BLADE", "desc":"A salt-dark blade that lands like an anchor.", "effects":{"damage_mult":0.17, "boss_damage":0.08}},
	{"id":"crooked_longbow", "name":"Crooked Longbow", "slot":"Weapon", "family":"RANGER", "weapon_type":"bow", "projectile":"arrow", "icon":"BOW", "evolution_path":["Ruin Longbow", "Starstring"], "desc":"Ugly, eager and remarkably accurate.", "effects":{"attack_speed":0.09, "crit":0.05}},
	{"id":"ruinweave_coat", "name":"Ruinweave Coat", "slot":"Armour", "icon":"GUARD", "desc":"Vault-thread reinforcement protects the wearer and keeps useful discoveries close.", "effects":{"max_hp":25.0, "armor":0.045, "coin_mult":0.08}},
	{"id":"dragon_scale_patch", "name":"Dragon-Scale Patch", "slot":"Armour", "icon":"PLATE", "desc":"A salvaged guardian scale, bound over the heart for the next hunt.", "effects":{"max_hp":38.0, "boss_damage":0.08}},
	{"id":"lucky_bell", "name":"Suspicious Lucky Bell", "slot":"Relic", "icon":"LOCKET", "desc":"Rings when treasure is pretending not to exist.", "effects":{"coin_mult":0.20, "crit":0.025}},
	{"id":"relic_magnet_charm", "name":"Relic Magnet Charm", "slot":"Relic", "icon":"RING", "desc":"Tugs loose relic energy into useful patterns.", "effects":{"attack_speed":0.04, "crit_lightning":0.18}},
	{"id":"echo_rune", "name":"Echo Rune", "slot":"Rune", "icon":"SPARK", "desc":"The ruins remember a good hit.", "effects":{"kill_explosion":0.22, "heavy_bonus":0.14}},
	{"id":"mire_rune", "name":"Mire Rune", "slot":"Rune", "icon":"TOXIN", "desc":"A patient little curse in polished stone.", "effects":{"poison_bonus":1, "poison_duration":0.25}},
	{"id":"moonsteel_slab", "name":"Moonsteel Slab", "slot":"Weapon", "family":"VANGUARD", "weapon_type":"greatsword", "icon":"BLADE", "evolution_path":["Starbreaker", "Sky-Sunder"], "desc":"A moon-bright slab forged to break the armour of fallen Crown sentries.", "effects":{"damage_mult":0.16, "crit":0.025}},
	{"id":"pebble_pounder", "name":"Pebble Pounder", "slot":"Weapon", "family":"VANGUARD", "weapon_type":"maul", "icon":"MALLET", "evolution_path":["Faultmaker", "Worldknocker"], "desc":"Small handle. Unreasonably geological conclusion.", "effects":{"damage_mult":0.18, "heavy_bonus":0.16}},
	{"id":"moonbranch", "name":"Moonbranch", "slot":"Weapon", "family":"RANGER", "weapon_type":"bow", "projectile":"arrow", "icon":"BOW", "evolution_path":["Crescent Bow", "Fullmoon Arc"], "desc":"A silver-limbed bow that rewards patient aim.", "effects":{"attack_speed":0.08, "crit":0.065}},
	{"id":"gilded_shortbow", "name":"Gilded Shortbow", "slot":"Weapon", "family":"RANGER", "weapon_type":"bow", "projectile":"arrow", "icon":"BOW", "evolution_path":["Hoardbow", "King's Dividend"], "desc":"Fast, flashy, and suspiciously interested in profit.", "effects":{"attack_speed":0.11, "coin_mult":0.10}},
	{"id":"cinder_staff", "name":"Cinder Staff", "slot":"Weapon", "family":"MAGE", "weapon_type":"staff", "projectile":"magic_orb", "icon":"STAFF", "evolution_path":["Furnace Rod", "Crownfire Branch"], "desc":"Its warm Core has never heard of indoor casting rules.", "effects":{"fire_damage":0.20, "damage_mult":0.07}},
	{"id":"moss_staff", "name":"Moss Staff", "slot":"Weapon", "family":"MAGE", "weapon_type":"staff", "projectile":"magic_orb", "icon":"STAFF", "evolution_path":["Verdant Rod", "Root of the Vault"], "desc":"Patient magic with roots in inconvenient places.", "effects":{"poison_duration":0.22, "max_hp":10.0}},
	{"id":"scrap_shivs", "name":"Scrap Shivs", "slot":"Weapon", "family":"ROGUE", "weapon_type":"daggers", "icon":"DAGGERS", "evolution_path":["Rivet Fangs", "Geargrin"], "desc":"Two sharp arguments assembled from one bad machine.", "effects":{"attack_speed":0.10, "execute":0.035}},
	{"id":"gilded_knives", "name":"Gilded Knives", "slot":"Weapon", "family":"ROGUE", "weapon_type":"daggers", "icon":"DAGGERS", "evolution_path":["King's Change", "Crown Tax"], "desc":"Treasure that cuts out the middle merchant.", "effects":{"crit":0.075, "coin_mult":0.08}},
	{"id":"patchplate_vest", "name":"Patchplate Vest", "slot":"Armour", "icon":"PLATE", "desc":"Every patch remembers a different near miss.", "effects":{"max_hp":28.0, "armor":0.05}},
	{"id":"coin_stitch_coat", "name":"Coinstitch Coat", "slot":"Armour", "icon":"GUARD", "desc":"Armour with pockets deep enough to affect posture.", "effects":{"max_hp":22.0, "coin_mult":0.12}},
	{"id":"tiny_bell", "name":"Tiny Bell of Warning", "slot":"Relic", "icon":"LOCKET", "desc":"Rings shortly before something educational happens.", "effects":{"crit":0.035, "armor":0.02}},
	{"id":"vault_receipt", "name":"Vault Receipt", "slot":"Relic", "icon":"RING", "desc":"Proof that the vault definitely owes you treasure.", "effects":{"coin_mult":0.22, "boss_damage":0.045}},
	{"id":"critical_script", "name":"Critical Script", "slot":"Rune", "icon":"SPARK", "desc":"A very short instruction ending in an exclamation mark.", "effects":{"crit":0.055, "crit_lightning":0.13}},
	{"id":"bossbane_sigil", "name":"Bossbane Sigil", "slot":"Rune", "icon":"SLAM", "desc":"Tiny engraving. Extremely large grudge.", "effects":{"boss_damage":0.16, "heavy_bonus":0.10}}
] + Phase3.ITEMS + preload("res://phase4_catalog.gd").ITEMS + preload("res://phase4b_catalog.gd").ITEMS + preload("res://mythical_collection.gd").ITEMS

static func definition(id: String) -> Dictionary:
	for item in ITEMS:
		if item.id == id:
			return item
	for weapon_type in WeaponCatalog.STARTERS:
		var item := WeaponCatalog.starter(weapon_type)
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
	item.evolution_stage = 0
	var scale: float = RARITY_POWER[item.rarity]
	for key in ["damage_mult", "attack_speed", "crit", "max_hp", "armor", "coin_mult", "low_health_damage", "fire_damage", "crit_lightning", "poison_duration", "boss_damage", "heavy_bonus", "kill_explosion", "execute"]:
		if item.effects.has(key):
			item.effects[key] = float(item.effects[key]) * scale
	item.affix_ids = []
	item.affix_names = []
	item.signature_hooks = []
	if source.has("fixed_signature"):
		item = AffixCatalog.apply(item,[source.fixed_signature])
	return item

static func live_weapon_types() -> Array[String]:
	return WeaponCatalog.live_ids()

static func create_affixed_item(id: String, rarity: String, serial: int, affix_ids: Array) -> Dictionary:
	return AffixCatalog.apply(create_item(id, rarity, serial), affix_ids)

static func rarity_rank(rarity: String) -> int:
	return maxi(0, RARITIES.find(rarity))

static func rarity_color(rarity: String) -> Color:
	return RARITY_COLORS.get(rarity, RARITY_COLORS.COMMON)

static func display_slot(slot: String) -> String:
	return "CHARM" if slot == "Relic" else slot.to_upper()

static func display_identity(item: Dictionary) -> String:
	if str(item.get("slot", "")) == "Weapon":
		var weapon_type := str(item.get("weapon_type", ""))
		var weapon_data := WeaponCatalog.definition(weapon_type)
		if not weapon_data.is_empty():
			return "%s  •  %s" % [str(weapon_data.name).to_upper(), str(item.get("family", "VANGUARD"))]
	return display_slot(str(item.get("slot", "Item")))

static func evolution_hint(item: Dictionary) -> String:
	var path: Array = item.get("evolution_path", [])
	if path.is_empty():
		return ""
	return "FORGE PATH  •  %s" % "  >  ".join(path)

static func scrap_value(item: Dictionary) -> int:
	return [3, 8, 18, 45, 70, 90][rarity_rank(item.get("rarity", "COMMON"))]

static func describe_effects(item: Dictionary) -> String:
	var effects: Dictionary = item.get("effects", {})
	var parts: Array[String] = []
	var evolved := WeaponCatalog.evolution_text(str(item.get("weapon_type", "")), int(item.get("evolution_stage", 0)))
	if not evolved.is_empty(): parts.append(evolved)
	if effects.has("damage_mult"): parts.append("%+.0f%% damage" % (effects.damage_mult * 100.0))
	if effects.has("attack_speed"): parts.append("%+.0f%% attack speed" % (effects.attack_speed * 100.0))
	if effects.has("attack_slow"): parts.append("%.0f%% slower attacks" % (effects.attack_slow * 100.0))
	if effects.has("incoming_mult"): parts.append("%+.0f%% incoming damage" % (effects.incoming_mult * 100.0))
	if effects.has("crit"): parts.append("%+.0f%% crit" % (effects.crit * 100.0))
	if effects.has("max_hp"): parts.append("%+.0f max HP" % effects.max_hp)
	if effects.has("armor"): parts.append("%+.0f%% armour" % (effects.armor * 100.0))
	if effects.has("coin_mult"): parts.append("%+.1f%% expedition XP / %+.0f%% Siege Embers" % [effects.coin_mult * 25.0,effects.coin_mult * 100.0])
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

static func describe_headline_effects(item: Dictionary, limit: int = 2) -> String:
	var full_parts := describe_effects(item).split("  /  ", false)
	var headlines: Array[String] = []
	for signature_name in item.get("affix_names", []):
		var value := str(signature_name)
		if not item.get("signature_hooks",[]).is_empty():
			headlines.append("SIGNATURE  •  %s" % value)
			break
	for part in full_parts:
		if headlines.size() >= limit + 1:
			break
		headlines.append(str(part))
	return "\n".join(headlines)
