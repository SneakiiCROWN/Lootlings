extends RefCounted
# Explicit BETA body identities. Gameplay roles and stats remain authoritative.
const IMP=preload("res://art/sprites/enemies/razor_imp.png")
const HEXER=preload("res://art/sprites/enemies/lantern_hexer.png")
const BRUTE=preload("res://art/sprites/enemies/mossback_brute.png")
const KNIGHT=preload("res://art/sprites/enemies/grump_knight.png")
const BODIES={
	"hound":preload("res://art/sprites/enemies/beta/regional_hound.svg"),
	"bat":preload("res://art/sprites/enemies/beta/regional_bat.svg"),
	"toad":preload("res://art/sprites/enemies/beta/regional_toad.svg"),
	"crab":preload("res://art/sprites/enemies/beta/regional_crab.svg"),
	"beetle":preload("res://art/sprites/enemies/beta/regional_beetle.svg"),
	"wyrm":preload("res://art/sprites/enemies/beta/regional_wyrm.svg"),
	"shard":preload("res://art/sprites/enemies/beta/regional_shard.svg"),
	"imp":IMP,"hexer":HEXER,"brute":BRUTE,"knight":KNIGHT
}
const ENTRIES={
	"MOSSMAW":["hound","wood","moss",Color("#b4d592")],
	"GLASSWING":["bat","glass","glimmer",Color("#a0f2ec")],
	"DEW HEXER":["hexer","ethereal","hexer",Color("#b1e8ca")],
	"FEN SNEAK":["imp","flesh","imp",Color("#d1c098")],
	"LANTERN TOAD":["toad","flesh","brute",Color("#ddd29e")],
	"MUDCLOAK":["hexer","flesh","hexer",Color("#c9c2a2")],
	"BELL BAT":["bat","glass","glimmer",Color("#c6e9ff")],
	"RIME PUP":["hound","flesh","moon",Color("#c4e7ff")],
	"ICICLE IMP":["imp","glass","imp",Color("#ace6ff")],
	"SLUICE CRAB":["crab","armour","forge",Color("#a4ddd7")],
	"PRESSURE SPRITE":["shard","ethereal","glimmer",Color("#a9e5e4")],
	"BRASSBACK":["beetle","armour","forge",Color("#ffe5a5")],
	"COAL PUP":["hound","molten","ember",Color("#ffd19c")],
	"SLAG KNIGHT":["knight","armour","human_heavy",Color("#ffd5ac")],
	"FORGE BEETLE":["beetle","molten","forge",Color("#ffac80")],
	"INKLING":["wyrm","ethereal","gloom",Color("#caaffe")],
	"MARGIN IMP":["imp","flesh","imp",Color("#e7c8ff")],
	"PAGEWYRM":["wyrm","ethereal","gloom",Color("#f9e7c5")],
	"NULL HOUND":["hound","ethereal","gloom",Color("#d5baf4")],
	"ECHO IMP":["imp","ethereal","imp",Color("#c5c0f4")],
	"MIRROR KNIGHT":["knight","glass","human_heavy",Color("#cee7fc")],
	"HOOKWING":["bat","flesh","moon",Color("#cce7ea")],
	"CHAIN GUARD":["knight","armour","human_heavy",Color("#d3e7fa")],
	"DECK HEXER":["hexer","ethereal","hexer",Color("#a8d5e5")],
	"FIRST GUARD":["knight","armour","human_heavy",Color("#ffe6b7")],
	"CROWN SHARD":["shard","glass","glimmer",Color("#ffdd90")],
	"HOARD ECHO":["hexer","ethereal","hexer",Color("#ffdab4")]
}
static func profile(name: String) -> Dictionary:
	var normalized:=name.to_upper().replace("_"," ")
	# Variant prefixes may precede the canonical name; choose longest exact suffix.
	for key in ENTRIES:
		if normalized.ends_with(key):
			var e: Array=ENTRIES[key]
			var size: Vector2={"hound":Vector2(154,127),"bat":Vector2(158,127),"toad":Vector2(148,119),"crab":Vector2(153,123),"beetle":Vector2(151,132),"wyrm":Vector2(143,132),"shard":Vector2(102,148),"imp":Vector2(118,105),"hexer":Vector2(111,132),"knight":Vector2(167,142),"brute":Vector2(148,99)}[e[0]]
			return {"texture":BODIES[e[0]],"size":size,"tint":e[3],"material":e[1],"voice":e[2],"hover":e[0] in ["bat","shard"],"body":e[0],"status":"BETA: original regional sprite" if e[0] not in ["imp","hexer","knight","brute"] else "BETA: existing fitting canonical archetype"}
	return {}

static func material(g) -> String:
	if g.enemy_is_boss:
		return {"mossglass_wilds":"wood","moonfen":"flesh","frostbell_hollows":"glass","sunken_gearworks":"armour","cinder_crown":"molten","starfall_archive":"ethereal","nullglass_expanse":"glass","skyhook_bastion":"armour"}.get(g.campaign_id,"armour")
	if g.enemy_is_miniboss: return "armour"
	var data:=profile(g.enemy_name)
	return str(data.get("material","wood" if g.enemy_archetype=="tank" else "ethereal" if g.enemy_archetype=="hexer" else "flesh"))
