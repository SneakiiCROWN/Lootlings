extends "res://tests/phase3_balance.gd"
var selection_policy: String="expert"
var decisions_rng:=RandomNumberGenerator.new()
var rows: Array=[]
func measure() -> void:
 helper=Diagnostic.new();packed=load("res://main.tscn")
 for entry in [["relic_beast","greatsword","Physical"],["moonkip","staff","Fire"],["gloomlet","daggers","Poison"],["emberhorn","fists","Physical"],["vault_runner","daggers","Lightning"]]:
  for sample in range(4):
   for strategy in ["expert","random"]:
    selection_policy=strategy;decisions_rng.seed=hash("decisions:54:%d" % sample)
    var row: Dictionary=simulate(entry[1],entry[2],sample,"act_i",entry[0],"tap")
    row.selection_policy=strategy
    for key in ["scrip_earned","scrip_spent","scrip_left"]:row.erase(key)
    rows.append(row)
 var summary: Dictionary={}
 for strategy in ["expert","random"]:
  var subset: Array=rows.filter(func(row):return row.selection_policy==strategy)
  var wins: int=0;var waves: float=0;var damage: float=0;var levels: float=0
  for row in subset:
   if row.won:wins+=1
   waves+=row.wave;damage+=row.damage_taken;levels+=row.level
  summary[strategy]={"runs":subset.size(),"wins":wins,"mean_wave":waves/subset.size(),"mean_damage_taken":damage/subset.size(),"mean_level":levels/subset.size()}
 var path: String="res://.godot_test_data/perk-combat-054.json"
 var file:=FileAccess.open(path,FileAccess.WRITE);assert(file!=null);file.store_string(JSON.stringify({"cohort":"40 actual act-I runs / five actor-weapon pairs / four matched seeds / expert core-aware versus random perk choices / same tap policy","results":rows,"summary":summary,"balance_accepted":false},"  "));file.close()
 print("PERK COMBAT 054 RESULTS: "+JSON.stringify(summary));print("PERK COMBAT 054 COMPLETE: 40 actual seeded combat routes; no forced buffs or god mode. Limited Act-I cohort, not whole-game balance acceptance.")
 helper.free();quit()
func choose_offer(game,core: String) -> int:
 if selection_policy=="random":return decisions_rng.randi_range(0,game.selected_upgrades.size()-1)
 var best: int=helper.pick_upgrade(game)
 var score: float=-INF
 for index in range(game.selected_upgrades.size()):
  var perk: Dictionary=game.selected_upgrades[index]
  var value: float=2.0 if core in perk.tags else 0.0
  if "Physical" in perk.tags and core!="Physical":value+=.5
  if perk.id in ["damage","haste","multihit","crit"]:value+=1.0
  if perk.id in ["regen","vamp","maxhp","armor"] and game.player_hp/game.player_max_hp<.6:value+=2.5
  if perk.id in ["firestorm","plague","chain"] and core in perk.tags:value+=1.0
  if value>score:score=value;best=index
 return best
