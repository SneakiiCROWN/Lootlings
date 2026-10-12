extends RefCounted
# Every standalone fixture must fail closed before instantiating the game.
static func require_isolated(tree: SceneTree) -> bool:
	var boundary := ProjectSettings.globalize_path("C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-076fresh/isolated/").replace("\\", "/").simplify_path().to_lower() + "/"
	var actual := OS.get_user_data_dir().replace("\\", "/").simplify_path().to_lower() + "/"
	if OS.get_environment("LOOTLINGS_QA") != "1" or not actual.begins_with(boundary):
		printerr("QA REFUSED: use tools/run_qa.py; player saves must never receive test fixtures.")
		tree.call_deferred("quit", 2)
		return false
	return true
