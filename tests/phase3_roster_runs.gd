extends SceneTree
const Balance = preload("res://tests/phase3_balance.gd")
const Traits = preload("res://character_traits.gd")
const Items = preload("res://item_catalog.gd")

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("measure")

func measure() -> void:
	var helper := Balance.new()
	helper.harness_root = root
	helper.helper = preload("res://tests/combat_seed_diagnostics.gd").new()
	helper.packed = load("res://main.tscn")
	for actor in Traits.TRAITS:
		var weapon := str(Items.definition(Traits.TRAITS[actor].starter).weapon_type)
		for kit in ["shared","identity"]:
			for sample in range(8):
				var row := helper.simulate("greatsword" if kit == "shared" else weapon,"sustain",sample,"act_i",actor,"tap")
				row.kit = kit
				print("PHASE3_ROSTER " + JSON.stringify(row))
	helper.helper.free(); helper.free()
	print("PHASE3_ROSTER COMPLETE: 192 independent shared/identity-kit runs; no victory quota")
	quit()
