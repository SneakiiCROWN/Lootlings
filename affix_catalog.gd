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
	"sparkcaller":{"name":"Sparkcaller", "slots":["Rune", "Relic"], "effects":{"crit_lightning":0.16}, "text":"Critical hits wake a small Relic spark."}
}

const SIGNATURES := {
	"crooked_constellation":{"name":"Crooked Constellation", "slots":["Weapon"], "families":["RANGER"], "hook":"crooked_volley", "text":"Every fifth shot splits into two crooked spectral arrows."},
	"first_light":{"name":"First Light", "slots":["Rune", "Relic"], "hook":"first_crit_spark", "text":"The first critical hit against each foe calls a Relic spark."},
	"grudgekeeper":{"name":"Grudgekeeper", "slots":["Weapon", "Relic"], "hook":"banked_impact", "text":"A defeated foe stores force for the next encounter."},
	"last_laugh":{"name":"Last Laugh", "slots":["Armour", "Relic"], "hook":"desperate_rhythm", "text":"Below 40% health, attacks gain a strange second wind."}
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
