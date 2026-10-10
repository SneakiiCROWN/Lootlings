extends RefCounted
# Shared prices, rank limits and descriptions. Legacy ranks retain exact effects.
const DEFINITIONS={
 "bedroll":["STURDY BEDROLL","+4 starting HP",[250,450,700,1000,1400]],
 "whetstone":["RELIC WHETSTONE","+0.6 starting damage",[300,525,800,1150,1600]],
 "pouch":["FIELD POUCH","+8 starting Run Scrip",[225,400,650,950,1300]],
 "wardweave":["WARDWEAVE LINING","Diminishing armour - up to 3%",[600,950,1400,2000,2800]],
 "hearthward":["HEARTHWARD CHARM","+1 starting Ward - up to 5",[450,750,1150,1600,2200]],
 "mending":["MENDING THREAD","Diminishing regen - up to 0.15 HP/s",[900,1400,2100,3000,4200]],
 "heartprism":["HEART PRISM","Diminishing starting HP - up to +12",[60,110,180]],
 "keenprism":["KEEN PRISM","Diminishing critical chance - up to +2.25%",[80,140,220]],
 "aegisprism":["AEGIS PRISM","Diminishing starting Ward - up to +4",[50,90,150]]
}
static func defaults() -> Dictionary:
 var ranks:Dictionary={}
 for id in DEFINITIONS:ranks[id]=0
 return ranks
static func sanitize(value: Dictionary) -> Dictionary:
 var ranks:=defaults()
 for id in ranks:ranks[id]=clampi(preload("res://safe_config.gd").int_value(value.get(id,0)),0,DEFINITIONS[id][2].size())
 return ranks
static func armour(rank: int) -> float:return [0.0,.010,.018,.024,.028,.030][clampi(rank,0,5)]
static func regeneration(rank: int) -> float:return [0.0,.050,.090,.120,.140,.150][clampi(rank,0,5)]

static func diamonds(id: String) -> bool:return id in ["heartprism","keenprism","aegisprism"]
static func currency(id: String) -> String:return "Loot Diamonds" if diamonds(id) else "Lootcoins"
static func heart(rank: int) -> float:return [0.0,6.0,10.0,12.0][clampi(rank,0,3)]
static func keen(rank: int) -> float:return [0.0,.010,.0175,.0225][clampi(rank,0,3)]
static func aegis(rank: int) -> float:return [0.0,2.0,3.0,4.0][clampi(rank,0,3)]
