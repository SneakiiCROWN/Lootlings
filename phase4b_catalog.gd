extends RefCounted
const ITEMS := [
	{"id":"gravebloom_staff","name":"Gravebloom Staff","slot":"Weapon","weapon_type":"staff","family":"MAGE","projectile":"magic_orb","icon":"STAFF","evolution_path":["Gravebloom Heartwood","Gravebloom Crownroot"],"desc":"Three targets close a storm circuit. Poison lingers; its living roots borrow your vitality.","effects":{"poison_bonus":1,"poison_duration":0.35,"crit_lightning":0.24,"max_hp":-12.0},"fixed_signature":"storm_receipt"},
	{"id":"siege_receipt","name":"The Last Receipt","slot":"Relic","icon":"RING","desc":"A deep-Siege keepsake. Kills bank force for the next foe; carrying it invites harder hits.","effects":{"incoming_mult":0.12},"fixed_signature":"grudgekeeper"}
]
const EXCLUSIVE := ["gravebloom_staff","siege_receipt"]
const RED_TARGET := 24
const SPIN_COSTS := [140,230,360]
static func round_rule(round_number: int, rng: RandomNumberGenerator) -> Dictionary:
	var boss:=round_number%10==0
	var disruption:=rng.randf()
	return {"boss":boss,"miniboss":not boss and round_number>5 and disruption<.07,"elite":round_number%5==0 or disruption<minf(.45,.10+round_number*.012),"event":not boss and round_number%3==0,"count":1 if boss or (round_number>5 and disruption<.07) else 3+mini(3,round_number/10)}
static func spin_reward(rng: RandomNumberGenerator) -> Dictionary:
	return preload("res://relic_spin_catalog.gd").roll(rng)
