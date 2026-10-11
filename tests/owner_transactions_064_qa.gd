extends SceneTree
const Scope = preload("res://save_scope.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("review")
func review() -> void:
	var g = load("res://main.tscn").instantiate(); root.add_child(g); await process_frame
	g.set_process(false); g.debug_enabled = true
	assert(g.app_lifecycle.persist() == OK)
	var normal: Dictionary = {}
	for name in preload("res://offline_backup.gd").STORES:
		normal[name] = FileAccess.get_file_as_bytes("user://" + name)
	Scope.active = true
	g.inventory.stash.clear(); g.inventory.scrap = 23; g.rift_progress.sigils = 7
	assert(g.app_lifecycle.persist() == OK)
	var random_before: int = g.rng.state
	Scope.transitioning = true
	assert(g.debug_action("item_id", "dawnweave").contains("Unchanged"))
	assert(g.inventory.stash.is_empty() and g.rng.state == random_before)
	assert(g.debug_action("scrap", 20).contains("Unchanged") and g.inventory.scrap == 23)
	assert(g.debug_action("sigils", 20).contains("Unchanged") and g.rift_progress.sigils == 7)
	assert(g.debug_action("save_test", null).contains("Could not save"))
	Scope.transitioning = false
	assert(g.debug_action("item_id", "dawnweave").contains("Granted"))
	assert(g.debug_action("scrap", 20).contains("43") and g.inventory.scrap == 43)
	assert(g.debug_action("sigils", 20).contains("27") and g.rift_progress.sigils == 27)
	assert(g.debug_action("save_test", null).contains("Saved"))
	var restored = preload("res://inventory_system.gd").new(); restored.load(g.INVENTORY_SAVE_PATH)
	assert(restored.stash.size() == 1 and restored.stash[0].id == "dawnweave" and restored.scrap == 43)
	for name in normal: assert(FileAccess.get_file_as_bytes("user://" + name) == normal[name])
	Scope.active = false; g.free(); await process_frame
	print("OWNER TRANSACTIONS 064 PASS: failed grants/Scrap/Sigils/save report failure and retain memory/RNG; saved grants reload; normal stores unchanged.")
	quit()
