extends RefCounted

const AFFIXES := {
	"keen":{"name":"Keen", "slots":["Weapon", "Rune"], "effects":{"crit":0.035}, "text":"Sharper critical edge."},
	"relentless":{"name":"Relentless", "slots":["Weapon", "Rune"], "effects":{"attack_speed":0.055}, "text":"Attacks flow a little faster."},
	"ruinous":{"name":"Ruinous", "slots":["Weapon"], "effects":{"damage_mult":0.065}, "text":"Hits carry relic-breaking force."},
	"dragonbane":{"name":"Dragonbane", "slots":["Weapon", "Relic"], "effects":{"boss_damage":0.10}, "text":"Built to worry enormous things."},
	"stout":{"name":"Stout", "slots":["Armour", "Relic"], "effects":{"max_hp":12.0}, "text":"A little harder to flatten."},
	"warded":{"name":"Warded", "slots":["Armour", "Relic"], "effects":{"armor":0.025}, "text":"A quiet ward softens incoming blows."},
	"prospector":{"name":"Prospector's", "slots":["Relic", "Rune"], "effects":{"coin_mult":0.10}, "text":"Loose Run Scrip has nowhere to hide."},
	"executioner":{"name":"Mercifully Sharp", "slots":["Weapon", "Rune"], "effects":{"execute":0.025}, "text":"Ends a wavering foe cleanly."},
	"emberbound":{"name":"Emberbound", "slots":["Weapon", "Rune", "Relic"], "effects":{"fire_damage":0.09}, "text":"Burning relics answer more fiercely."},
	"venomous":{"name":"Venomous", "slots":["Rune", "Relic"], "effects":{"poison_duration":0.16}, "text":"Poison clings to its target."},
	"sparkcaller":{"name":"Sparkcaller", "slots":["Rune", "Relic"], "effects":{"crit_lightning":0.16}, "text":"Critical hits wake a small Relic spark."},
	"quickened":{"name":"Quickened", "slots":["Weapon"], "effects":{"attack_speed":0.045}, "text":"A lighter rhythm without losing its shape."},
	"boss_biting":{"name":"Boss-Biting", "slots":["Weapon"], "effects":{"boss_damage":0.075}, "text":"Leaves especially memorable marks on large targets."},
	"plated":{"name":"Plated", "slots":["Armour"], "effects":{"armor":0.03}, "text":"One more sensible layer between fur and consequences."},
	"scavengers":{"name":"Scavenger's", "slots":["Relic", "Rune"], "effects":{"coin_mult":0.085}, "text":"Finds value where polite people see rubble."},
	"kindled":{"name":"Kindled", "slots":["Weapon", "Rune"], "effects":{"fire_damage":0.08}, "text":"Relic heat gathers around every strike."},
	"grounded":{"name":"Grounded", "slots":["Weapon", "Rune"], "effects":{"heavy_bonus":0.09}, "text":"Heavy rhythm hits land with better manners and worse outcomes."},
	"of_sparks":{"name":"of Sparks", "slots":["Weapon", "Rune"], "effects":{"crit_lightning":0.12}, "text":"Critical edges leave a small amber-blue answer."},
	"of_spite":{"name":"of Spite", "slots":["Weapon", "Armour"], "effects":{"low_health_damage":0.12}, "text":"Gets increasingly personal as health falls."},
	"of_the_vault":{"name":"of the Vault", "slots":["Weapon", "Armour", "Relic", "Rune"], "effects":{"damage_mult":0.025, "max_hp":4.0}, "text":"Carries a restrained trace of old vault power."}
}

const SIGNATURES := {
	"crooked_constellation":{"name":"Crooked Constellation", "slots":["Weapon"], "families":["RANGER"], "hook":"crooked_volley", "live":true, "text":"Every fifth shot splits into two crooked spectral arrows."},
	"first_light":{"name":"First Light", "slots":["Rune", "Relic"], "hook":"first_crit_spark", "live":true, "text":"The first critical hit against each foe calls a Relic spark."},
	"grudgekeeper":{"name":"Grudgekeeper", "slots":["Weapon", "Relic"], "hook":"banked_impact", "live":true, "text":"A defeated foe stores force for the next encounter."},
	"last_laugh":{"name":"Last Laugh", "slots":["Armour", "Relic"], "hook":"desperate_rhythm", "live":true, "text":"Below 40% health, attacks gain a strange second wind."},
	"last_lantern":{"name":"Last Lantern", "slots":["Armour", "Relic"], "hook":"last_lantern", "live":true, "text":"Once per run, fatal damage leaves one HP and snuffs its lantern."},
	"frostbell_chime":{"name":"Frostbell Chime", "slots":["Weapon", "Rune"], "hook":"frostbell_chime", "live":true, "text":"The first hit on each foe delays its next action."},
	"aftershock_receipt":{"name":"Aftershock Receipt", "slots":["Weapon", "Rune"], "hook":"aftershock_receipt", "live":false, "text":"A heavy impact returns as a smaller delayed shock."},
	"moon_echo":{"name":"Moon Echo", "slots":["Weapon", "Relic"], "hook":"moon_echo", "live":false, "text":"A near miss primes a ghost copy of the next attack."},
	"storm_receipt":{"name":"Storm Receipt", "slots":["Weapon", "Rune"], "hook":"storm_receipt", "live":false, "text":"Three distinct targets in quick succession call chain lightning."},
	"rooted_revenge":{"name":"Rooted Revenge", "slots":["Armour", "Rune"], "hook":"rooted_revenge", "live":false, "text":"A heavy hit plants a delayed retaliating thorn."},
	"bubble_bargain":{"name":"Bubble Bargain", "slots":["Relic", "Rune"], "hook":"bubble_bargain", "live":false, "text":"The first status application creates a protective bubble mote."},
	"mimic_appetite":{"name":"Mimic Appetite", "slots":["Weapon", "Relic"], "hook":"mimic_appetite", "live":false, "text":"Opening a chest empowers the next encounter's first strike."},
	"gilded_greed":{"name":"Gilded Greed", "slots":["Relic"], "hook":"gilded_greed", "live":false, "text":"Gilded enemies may spill one extra treasure burst."},
	"shardstorm":{"name":"Shardstorm", "slots":["Weapon", "Rune"], "hook":"shardstorm", "live":false, "text":"High-tier loot primes the next hit with relic-shard energy."},
	"hoardquake":{"name":"Hoardquake", "slots":["Weapon", "Rune"], "hook":"hoardquake", "live":false, "text":"A Legendary pickup primes the next heavy gold shockwave."}
}

static func compatible_ids(item: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var slot := str(item.get("slot", ""))
	for id in AFFIXES:
		if slot in AFFIXES[id].slots:
			result.append(id)
	return result

static func compatible_signature_ids(item: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var slot := str(item.get("slot", ""))
	var family := str(item.get("family", ""))
	for id in SIGNATURES:
		var entry: Dictionary = SIGNATURES[id]
		if not bool(entry.get("live", false)):
			continue
		if not slot in entry.slots:
			continue
		if entry.has("families") and not family in entry.families:
			continue
		result.append(id)
	return result

static func roll_for_item(item: Dictionary, rng: RandomNumberGenerator) -> Array[String]:
	var rarity := str(item.get("rarity", "COMMON"))
	var count := 0 if rarity == "COMMON" else 1 if rarity == "RARE" else 2
	var pool := compatible_ids(item)
	var result: Array[String] = []
	for _index in range(mini(count, pool.size())):
		var pick_index := rng.randi_range(0, pool.size() - 1)
		result.append(pool[pick_index])
		pool.remove_at(pick_index)
	if rarity == "LEGENDARY":
		var signatures := compatible_signature_ids(item)
		if not signatures.is_empty():
			result.append(signatures[rng.randi_range(0, signatures.size() - 1)])
	return result

static func apply(item: Dictionary, ids: Array) -> Dictionary:
	var result := item.duplicate(true)
	result.affix_ids = []
	result.signature_hooks = []
	result.affix_names = []
	for raw_id in ids:
		var id := str(raw_id)
		if AFFIXES.has(id):
			var affix: Dictionary = AFFIXES[id]
			if not str(result.get("slot", "")) in affix.slots:
				continue
			result.affix_ids.append(id)
			result.affix_names.append(str(affix.name))
			for key in affix.effects:
				result.effects[key] = float(result.effects.get(key, 0.0)) + float(affix.effects[key])
		elif SIGNATURES.has(id):
			var signature: Dictionary = SIGNATURES[id]
			if id not in compatible_signature_ids(result):
				continue
			result.affix_ids.append(id)
			result.affix_names.append(str(signature.name))
			result.signature_hooks.append(str(signature.hook))
	return result

static func descriptions(item: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for raw_id in item.get("affix_ids", []):
		var id := str(raw_id)
		if AFFIXES.has(id):
			result.append("%s — %s" % [str(AFFIXES[id].name), str(AFFIXES[id].text)])
		elif SIGNATURES.has(id):
			result.append("%s — %s" % [str(SIGNATURES[id].name), str(SIGNATURES[id].text)])
	return result
