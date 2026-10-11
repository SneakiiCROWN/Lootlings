extends "res://tests/balance_strategies_065_qa.gd"
# Exact-export replay of the Common/zero-progression subset of the source cohort.
func measure() -> void:
	helper=Diagnostic.new();packed=load("res://main.tscn")
	var actors: Array=preload("res://lootling_catalog.gd").selectable_ids()
	actors.append_array(preload("res://wanderer_catalog.gd").selectable_ids())
	gear_rarity="COMMON";progression=0
	for actor in actors:
		for policy in ["offensive","defensive","synergy"]:
			strategy=policy;record(actor,"act_i",0,["Physical","Fire","Lightning","Poison"][actors.find(actor)%4])
	assert(records.size()==36)
	print("COMPILED STRATEGY 065 COMPLETE: 36 real routes for strict source/export comparison, all 12 actors and three policies.")
	helper.free();quit()
