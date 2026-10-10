extends SceneTree
func _initialize() -> void:
 if not preload("C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-fixtures-0522/test_safety.gd").require_isolated(self):return
 OS.unset_environment("LOOTLINGS_OWNER_TEST")
 assert(not preload("res://owner_test_access.gd").enabled())
 assert(not preload("res://debug_panel.gd").allowed(false))
 assert(not preload("res://save_scope.gd").active)
 print("NORMAL OWNER BOUNDARY PASS: no build feature, no runtime access, release panel denied")
 quit()
