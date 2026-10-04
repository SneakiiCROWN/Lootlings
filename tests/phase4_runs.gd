extends "res://tests/phase3_balance.gd"
# extends SceneTree through the isolated fresh-scene harness.
func measure() -> void:
	helper=Diagnostic.new(); packed=load("res://main.tscn")
	for actor in preload("res://phase4_catalog.gd").HUMANS:
		var weapon: String=preload("res://phase4_catalog.gd").HUMANS[actor].affinity.split(" / ")[0]
		for sample in range(4): print("PHASE4_RUN "+JSON.stringify(simulate(weapon,"sustain",sample,"act_i",actor,"tap")))
	for sample in range(12): print("PHASE4_RUN "+JSON.stringify(simulate("greatsword","sustain",sample,"act_i","relic_beast","tap")))
	helper.free(); print("PHASE4 RUNS COMPLETE: %d fresh runs" % completed); quit()
