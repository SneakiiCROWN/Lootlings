extends SceneTree
const Wanderers = preload("res://wanderer_catalog.gd")
const Fit = preload("res://weapon_fit_catalog.gd")

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	var checks := 0
	for id in Wanderers.selectable_ids():
		for stance in Fit.STANCE_GROUPS:
			var contract := Wanderers.wardrobe_contract(id,stance)
			assert(contract.mode == "baked_preset" and not contract.tint_safe)
			assert(contract.body_profile == Wanderers.definition(id).body_frame)
			# Reusing the real body is a validation fixture, NOT a selectable new outfit.
			var fixture := {"slot":"upper_outfit","body_profiles":[contract.body_profile],"stances":[stance],
				"heads":[contract.head],"hair_styles":[contract.hair],"back_items":[contract.back],
				"hand_sets":[contract.hands],"weapon_occlusion":contract.weapon_occlusion,
				"tint_safe":false,"facing":"right_only","asset_path":Wanderers.definition(id).runtime_sprite}
			assert(Wanderers.layer_compatibility(fixture,contract).is_empty())
			fixture.facing = "left_only"
			assert(Wanderers.layer_compatibility(fixture,contract).is_empty())
			for field in ["body_profiles","stances","heads","hair_styles","back_items","hand_sets"]:
				var bad := fixture.duplicate(true)
				bad[field] = []
				assert(not Wanderers.layer_compatibility(bad,contract).is_empty())
			var missing := fixture.duplicate(true)
			missing.asset_path = "res://art/not_delivered.png"
			assert("missing_runtime_art" in Wanderers.layer_compatibility(missing,contract))
			var wrong := fixture.duplicate(true)
			wrong.asset_path = "res://art/ui/production/panel.png"
			assert("invalid_layer_canvas" in Wanderers.layer_compatibility(wrong,contract))
			# Pronouns/gender never appear in the compatibility contract.
			assert(not contract.has("gender") and not contract.has("pronouns"))
			checks += 1
	print("WARDROBE QA PASSED: %d body/stance contracts; head/hair/back/hand/occlusion/canvas gates; no gender/tint or nonexistent-art options" % checks)
	quit(0)
