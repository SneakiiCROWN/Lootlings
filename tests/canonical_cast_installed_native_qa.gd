extends "res://tests/canonical_cast_stage_native_qa.gd"
# extends SceneTree via guarded helper; production selectors only, no candidate cache.
func review() -> void:
 verify_installed=true
 await super.review()
