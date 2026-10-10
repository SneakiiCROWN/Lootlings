extends RefCounted
# Existing effects stay unchanged. Seeded rarity roll, no duplicate/capped offers.
const RARITY_WEIGHTS={"COMMON":65.0,"RARE":27.0,"EPIC":8.0}
static func eligible(up:Dictionary, context:Dictionary) -> bool:
 match str(up.id):
  "crit":return float(context.get("crit",0.0))<.72
  "vamp":return float(context.get("life_steal",0.0))<.08
  "execute":return float(context.get("execute",0.0))<.35
  "greed":return false # Temporary-currency perk retired; other currency migration is separate.
 return true
static func offers(rng:RandomNumberGenerator, catalog:Array, context:Dictionary, forced:String="") -> Array:
 var pool:Array=catalog.filter(func(up):return eligible(up,context))
 var result:Array=[]
 while result.size()<3 and not pool.is_empty():
  var rarities:Array=[];var weights:=PackedFloat32Array()
  for rarity in RARITY_WEIGHTS:
   if pool.any(func(up):return str(up.rarity)==rarity):rarities.append(rarity);weights.append(RARITY_WEIGHTS[rarity])
  var rarity:String=forced if forced in rarities else str(rarities[rng.rand_weighted(weights)])
  var matching:Array=pool.filter(func(up):return str(up.rarity)==rarity)
  var selected:Dictionary=matching[rng.randi_range(0,matching.size()-1)]
  result.append(selected.duplicate(true));pool.erase(selected)
 return result
