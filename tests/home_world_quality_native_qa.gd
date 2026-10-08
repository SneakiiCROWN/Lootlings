extends "res://tests/hub_navigation_native_qa.gd"
# extends SceneTree via guarded native helper. Candidate stays out of ordinary routes.
func review() -> void:
 preload("res://home_runtime_art.gd").review_assets["environment:personal_home:interior"]="res://art/production/phase4e/regions/personal_home_lived_in_v2.png"
 assert(ResourceLoader.exists("res://art/production/phase4e/regions/personal_home_lived_in_v2.png"))
 assert(preload("res://home_runtime_art.gd").texture("environment:personal_home:interior").resource_path.ends_with("personal_home_lived_in_v2.png"))
 await super.review()
