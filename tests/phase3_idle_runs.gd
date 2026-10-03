extends SceneTree
const Balance = preload("res://tests/phase3_balance.gd")
const Traits = preload("res://character_traits.gd")

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("measure")

func measure() -> void:
	var helper := Balance.new(); helper.harness_root = root
	helper.helper = preload("res://tests/combat_seed_diagnostics.gd").new(); helper.packed = load("res://main.tscn")
	for actor in Traits.TRAITS:
		var weapon := str(preload("res://item_catalog.gd").definition(Traits.TRAITS[actor].starter).weapon_type)
		for sample in range(8):
			print("PHASE3_IDLE " + JSON.stringify(helper.simulate(weapon,"sustain",sample,"act_i",actor,"idle")))
	helper.helper.free(); helper.free()
	print("PHASE3_IDLE COMPLETE: 96 fresh no-tap identity-kit runs; no difficulty adjustment")
	quit()
