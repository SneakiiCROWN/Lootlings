extends RefCounted

const VARIANTS := {
	"hasty":{"name":"HASTY", "hp":0.92, "damage":0.96, "interval":0.84, "hit":1.0, "coin":1.05, "xp":1.03, "accent":Color("#ff9a70"), "icon":"»"},
	"armoured":{"name":"ARMOURED", "hp":1.16, "damage":0.96, "interval":1.10, "hit":0.94, "coin":1.10, "xp":1.08, "accent":Color("#9eb7d0"), "icon":"◆"},
	"volatile":{"name":"VOLATILE", "hp":0.94, "damage":1.04, "interval":1.0, "hit":1.0, "coin":1.12, "xp":1.08, "accent":Color("#ff7d62"), "icon":"✦"},
	"cursed":{"name":"CURSED", "hp":1.0, "damage":1.10, "interval":0.96, "hit":1.0, "coin":1.12, "xp":1.10, "accent":Color("#ba7cff"), "icon":"◇"},
	"gilded":{"name":"GILDED", "hp":1.12, "damage":1.02, "interval":1.04, "hit":1.0, "coin":1.38, "xp":1.18, "accent":Color("#ffd45f"), "icon":"¤"},
	"frostbitten":{"name":"FROSTBITTEN", "hp":0.98, "damage":0.96, "interval":1.04, "hit":1.0, "coin":1.12, "xp":1.10, "accent":Color("#9fe7ff"), "icon":"❄", "special":"slow_pulse"},
	"overcharged":{"name":"OVERCHARGED", "hp":0.96, "damage":1.02, "interval":0.98, "hit":1.0, "coin":1.14, "xp":1.10, "accent":Color("#6ee8ff"), "icon":"ϟ", "special":"third_spark"},
	"rootbound":{"name":"ROOTBOUND", "hp":1.08, "damage":0.96, "interval":1.08, "hit":0.94, "coin":1.12, "xp":1.12, "accent":Color("#7fd58b"), "icon":"♧", "special":"opening_guard"}
	,"regenerating":{"name":"REKNITTING","hp":.96,"damage":.92,"interval":1.08,"hit":1.0,"coin":1.22,"xp":1.16,"accent":Color("#87d6ac"),"icon":"♧","special":"renewal"}
	,"enraged":{"name":"ENRAGED","hp":1.0,"damage":.96,"interval":1.0,"hit":1.0,"coin":1.20,"xp":1.15,"accent":Color("#f78d70"),"icon":"»","special":"last_stand"}
	,"leeching":{"name":"LEECHING","hp":.96,"damage":.94,"interval":1.06,"hit":1.0,"coin":1.22,"xp":1.16,"accent":Color("#d18abd"),"icon":"◇","special":"drain"}
}

const ZONE_POOLS := {
	"outer_ruins":["hasty", "armoured", "volatile", "gilded"],
	"emberworks":["hasty", "armoured", "volatile", "overcharged", "gilded","enraged"],
	"hoard_depths":["armoured", "cursed", "frostbitten", "rootbound", "gilded","regenerating","leeching"]
}

static func roll(rng: RandomNumberGenerator, wave: int, is_special: bool, zone_id: String = "") -> String:
	if is_special or wave <= 1:
		return ""
	var chance := 0.10 if wave <= 5 else 0.14 if wave <= 10 else 0.17
	if rng.randf() >= chance:
		return ""
	var ids: Array = ZONE_POOLS.get(zone_id, VARIANTS.keys())
	# One modifier per actor is the exclusion rule: no haste+drain+rage pileups.
	# Treasure carriers are uncommon; sustain specials are also lower weight.
	var total := 0.0
	for id in ids: total += weight(str(id))
	var roll_value := rng.randf()*total
	for id in ids:
		roll_value -= weight(str(id))
		if roll_value <= 0: return str(id)
	return str(ids.back())

static func weight(id: String) -> float:
	return .55 if id == "gilded" else .70 if id in ["regenerating","leeching"] else 1.0

static func definition(id: String) -> Dictionary:
	return VARIANTS.get(id, {})

static func apply(id: String, stats: Dictionary) -> Dictionary:
	var result := stats.duplicate(true)
	var data := definition(id)
	if data.is_empty():
		return result
	result.hp = float(result.hp) * float(data.hp)
	result.damage = float(result.damage) * float(data.damage)
	result.interval = float(result.interval) * float(data.interval)
	result.hit = float(result.hit) * float(data.hit)
	result.coin = float(data.coin)
	result.xp = float(data.xp)
	return result

static func special(id: String) -> String:
	return str(definition(id).get("special", ""))

static func icon_id(id: String) -> String:
	return "variant_rootbound" if id == "regenerating" else "variant_hasty" if id == "enraged" else "variant_cursed" if id == "leeching" else "variant_"+id

static func live_ids() -> Array[String]:
	var result: Array[String] = []
	for id in VARIANTS:
		result.append(id)
	return result
