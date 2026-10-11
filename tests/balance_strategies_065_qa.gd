extends "res://tests/phase3_balance.gd"
# Explicit policies, not a claim of human competence. Real encounter simulation.
var strategy := "offensive"
var gear_id := ""
var gear_rarity := "COMMON"
var progression := 0
var records: Array = []
func configure_game(g) -> void:
	g.gold_upgrades={"bedroll":progression,"whetstone":progression,"pouch":0,"heartprism":progression,"mending":progression}
	g.inventory.equip(Items.create_item(gear_id,gear_rarity,65001))
	if progression > 0:
		g.inventory.equip(Items.create_item("ruinweave_coat",gear_rarity,65002))
		g.inventory.equip(Items.create_item("lucky_bell",gear_rarity,65003))
		g.inventory.equip(Items.create_item("stormspark",gear_rarity,65004))
func choose_offer(g, core: String) -> int:
	var order: Array
	match strategy:
		"defensive": order=["regen","vamp","armor","damage","multi","tap","speed","crit","execute","heavy","venom","ignite","storm","splash","frenzy","plague","wildfire"]
		"synergy":
			order=["venom","plague","vamp","regen","multi","damage","speed"] if core=="Poison" else (["ignite","wildfire","regen","vamp","damage","speed","multi"] if core=="Fire" else (["storm","crit","multi","regen","vamp","speed","damage"] if core=="Lightning" else ["heavy","damage","multi","regen","vamp","tap","speed","crit"]))
		_: order=["damage","multi","tap","speed","crit","execute","heavy","regen","vamp","armor","venom","ignite","storm","splash","frenzy","plague","wildfire"]
	# A bounded emergency rule is explicit and common to all three policies.
	if g.player_hp/g.player_max_hp < .45:
		order=["regen","vamp","armor"]+order
	var best := 0
	var best_score := -INF
	for i in range(g.selected_upgrades.size()):
		var id: String=g.selected_upgrades[i].id
		var rank: int=order.find(id)
		var score: float=100-rank if rank>=0 else 0
		if id=="vamp" and g.life_steal>=.08: score=-1
		if id=="crit" and g.effective_crit_chance()>=.85: score=-1
		if score>best_score: best_score=score;best=i
	return best
func record(actor: String, campaign: String, sample: int, core: String) -> void:
	gear_id=preload("res://character_traits.gd").TRAITS[actor].starter
	var weapon: String=Items.definition(gear_id).weapon_type
	var row: Dictionary=simulate(weapon,core,sample,campaign,actor,"tap")
	row.strategy=strategy;row.starting_item=gear_id;row.rarity=gear_rarity;row.progression=progression
	for foe in row.foes:
		foe.clearance_hp_per_second=foe.effective_dps;foe.erase("effective_dps")
	for key in ["scrip_earned","scrip_spent","scrip_left"]: row.erase(key)
	records.append(row)
	print("STRATEGY065_RUN "+JSON.stringify({"actor":actor,"campaign":campaign,"sample":sample,"strategy":strategy,"won":row.won,"seconds":row.seconds}))
	write_results()
func write_results() -> void:
	var summary: Dictionary={}
	for policy in ["offensive","defensive","synergy"]:
		var subset: Array=records.filter(func(r):return r.strategy==policy)
		var wins := 0;var damage := 0.0;var seconds := 0.0
		for r in subset:
			if r.won: wins+=1
			damage+=r.damage_taken;seconds+=r.seconds
		summary[policy]={"runs":subset.size(),"wins":wins,"mean_damage_taken":damage/maxi(1,subset.size()),"mean_seconds":seconds/maxi(1,subset.size())}
	var file:=FileAccess.open("res://.godot_test_data/balance-strategies-065.json",FileAccess.WRITE);assert(file!=null)
	file.store_string(JSON.stringify({"results":records,"summary":summary,"balance_accepted":false,"limitations":"Fixed 4 taps/sec; scripted choices, no dodging; canonical named starter weapons retained. Clearance HP/s is not measured DPS. Campaign routes only: Dungeon/Rift/Siege balance remains separate and open."},"  "));file.close()
func measure() -> void:
	helper=Diagnostic.new();packed=load("res://main.tscn")
	var actors: Array=preload("res://lootling_catalog.gd").selectable_ids()
	actors.append_array(preload("res://wanderer_catalog.gd").selectable_ids())
	for actor in actors:
		for sample in range(2):
			gear_rarity="COMMON" if sample==0 else "RARE";progression=sample
			for policy in ["offensive","defensive","synergy"]:
				strategy=policy;record(actor,"act_i",sample,["Physical","Fire","Lightning","Poison"][actors.find(actor)%4])
	for campaign in Campaign.ORDER:
		gear_rarity="EPIC";progression=3
		var actor: String=actors[Campaign.ORDER.find(campaign)%actors.size()]
		for policy in ["offensive","defensive","synergy"]:
			strategy=policy;record(actor,campaign,2,"Physical")
	assert(records.size()==102)
	print("BALANCE STRATEGIES 065 COMPLETE: 102 matched-policy real combat runs, all 12 actors and 10 regions; not whole-game balance acceptance.")
	helper.free();quit()
