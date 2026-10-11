extends "res://tests/perk_combat_054_qa.gd"
# Existing real combat harness with COMMON compatible family starters.
# Actor starter IDs select the family; this is not exact named-gear coverage.
func measure() -> void:
	helper = Diagnostic.new(); packed = load("res://main.tscn")
	var results: Array = []
	for actor in preload("res://character_traits.gd").TRAITS:
		var starter: String = preload("res://character_traits.gd").TRAITS[actor].starter
		var weapon: String = str(Items.definition(starter).get("weapon_type", ""))
		assert(Weapons.live_ids().has(weapon))
		for strategy in ["expert", "random"]:
			selection_policy = strategy; decisions_rng.seed = hash("decisions:64:0")
			var row := simulate(weapon, "sustain", 0, "act_i", actor, "tap")
			row.selection_policy = strategy; row.cohort = "actor_starter"
			results.append(row); print("FOUNDATION64 " + JSON.stringify(row))
	for campaign in Campaign.ORDER:
		for sample in range(2):
			selection_policy = "expert"; decisions_rng.seed = hash("decisions:64:%d" % sample)
			var row := simulate("greatsword", "sustain", sample, campaign, "relic_beast", "tap")
			row.selection_policy = "expert"; row.cohort = "regional_starter"
			results.append(row); print("FOUNDATION64 " + JSON.stringify(row))
	var file := FileAccess.open("res://.godot_test_data/foundation-cohort-064.json", FileAccess.WRITE)
	assert(file != null)
	file.store_string(JSON.stringify({"results":results, "balance_accepted":false, "scope":"All 12 actors with compatible COMMON family starter weapons, two policies/one seed; 10 regional starter routes/two seeds. Fixed 0.05s simulation step; no exact named-gear, late-game equipment/mode or frame-time acceptance."}, "  ")); file.close()
	helper.free()
	print("FOUNDATION COHORT 064 COMPLETE: %d real routes, diagnostic evidence only." % results.size())
	quit()
