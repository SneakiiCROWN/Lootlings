extends "res://tests/perk_combat_054_qa.gd"
func configure_game(g) -> void:
 # Explicit mid-progression diagnostic loadout; not a target win-rate claim.
 g.gold_upgrades={"bedroll":3,"whetstone":3,"pouch":0,"heartprism":3,"mending":2}
 g.inventory.equip(g.ItemCatalog.create_item(g.inventory.equipped_item("Weapon").id,"EPIC",600))
func measure() -> void:
 helper=Diagnostic.new();packed=load("res://main.tscn");rows.clear();selection_policy="expert"
 for campaign in ["mossglass_wilds","cinder_crown","first_hoard"]:
  for entry in [["relic_beast","greatsword","Physical"],["moonkip","staff","Fire"],["gloomlet","daggers","Poison"],["vault_runner","daggers","Lightning"]]:
   for sample in range(2):
    var row:Dictionary=simulate(entry[1],entry[2],sample,campaign,entry[0],"tap")
    assert(row.state=="result" and row.seconds<900 and row.scrip_earned==0 and row.scrip_spent==0)
    for key in ["scrip_earned","scrip_spent","scrip_left"]:row.erase(key)
    rows.append(row)
 var summary:Dictionary={}
 for campaign in ["mossglass_wilds","cinder_crown","first_hoard"]:
  var subset:Array=rows.filter(func(row):return row.campaign==campaign);var wins:=0;var waves:=0.0
  for row in subset:
   if row.won:wins+=1
   waves+=row.wave
  summary[campaign]={"runs":subset.size(),"wins":wins,"mean_wave":waves/subset.size()}
 var file:=FileAccess.open("res://.godot_test_data/region-routes-056.json",FileAccess.WRITE);assert(file!=null)
 file.store_string(JSON.stringify({"cohort":"24 real runs: three later regions, four canonical actor/weapon/core pairs, two seeds; fixed mid-progression upgrades and Epic starter weapon; core-aware perk policy; no god mode","results":rows,"summary":summary,"balance_accepted":false,"limitation":"Small diagnostic cohort; frame-timed input, no expert superiority or complete endgame balance claim."},"  "));file.close()
 print("REGION ROUTES 056 PASS: "+JSON.stringify(summary));helper.free();quit()
