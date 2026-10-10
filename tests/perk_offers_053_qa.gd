extends SceneTree
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 var catalog=preload("res://game_catalog.gd").UPGRADES;var service=preload("res://perk_offer_catalog.gd")
 var a:=RandomNumberGenerator.new();var b:=RandomNumberGenerator.new();a.seed=53053;b.seed=a.seed
 var counts={"COMMON":0,"RARE":0,"EPIC":0}
 for i in range(2000):
  var offers:Array=service.offers(a,catalog,{"crit":.72,"life_steal":.08,"execute":.35})
  assert(offers==service.offers(b,catalog,{"crit":.72,"life_steal":.08,"execute":.35}))
  assert(offers.size()==3)
  var seen:Array=[]
  for up in offers:assert(not up.id in seen and not up.id in ["crit","vamp","execute","greed"]);seen.append(up.id);counts[up.rarity]+=1
 assert(counts.COMMON>3500 and counts.COMMON<4300 and counts.RARE>1300 and counts.RARE<1950 and counts.EPIC>300 and counts.EPIC<650)
 for rarity in ["COMMON","RARE","EPIC"]:
  for up in service.offers(a,catalog,{},rarity):assert(up.rarity==rarity)
 print("PERK OFFER 053 PASS: 2000 seeded equal pairs, unique valid choices, capped effects excluded, rarity distribution ",counts,". Combat balance acceptance remains open.")
 quit()
