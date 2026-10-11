extends SceneTree
const Scope = preload("res://save_scope.gd")
const Inventory = preload("res://inventory_system.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("review")
func review() -> void:
	var g = load("res://main.tscn").instantiate()
	root.add_child(g); await process_frame; g.set_process(false)
	g.show_hideout(); g.contextual_guide.enabled = true
	g.contextual_guide.read_ids = ["equipment"]; g.contextual_guide.practised_ids.clear()
	var checked := 0
	for slot in Inventory.SLOTS:
		var id := ""
		for entry in g.ItemCatalog.ITEMS:
			if entry.slot == slot: id = entry.id; break
		assert(not id.is_empty())
		g.inventory.stash = [g.ItemCatalog.create_item(id, "RARE", 640 + checked)]
		g.inventory.scrap = 37
		assert(g.inventory.save(g.INVENTORY_SAVE_PATH) == OK)
		g.hideout_ui.show_stash()
		var before: Dictionary = g.inventory.equipped.duplicate(true)
		var stash: Array = g.inventory.stash.duplicate(true)
		var disk := FileAccess.get_sha256(g.INVENTORY_SAVE_PATH)
		Scope.transitioning = true; g.equip_stash_item(0); Scope.transitioning = false
		assert(g.inventory.equipped == before and g.inventory.stash == stash)
		assert(FileAccess.get_sha256(g.INVENTORY_SAVE_PATH) == disk)
		assert(not "equipment" in g.contextual_guide.practised_ids)
		Scope.transitioning = true; g.scrap_stash_item(0); Scope.transitioning = false
		assert(g.inventory.stash == stash and g.inventory.scrap == 37)
		assert(FileAccess.get_sha256(g.INVENTORY_SAVE_PATH) == disk)
		g.equip_stash_item(0)
		assert(g.inventory.equipped_item(slot).serial == 640 + checked)
		var restored = Inventory.new(); restored.load(g.INVENTORY_SAVE_PATH)
		assert(restored.equipped == g.inventory.equipped and restored.stash == g.inventory.stash)
		assert("equipment" in g.contextual_guide.practised_ids)
		g.contextual_guide.practised_ids.clear()
		g.inventory.stash = stash.duplicate(true); assert(g.inventory.save(g.INVENTORY_SAVE_PATH) == OK)
		g.scrap_stash_item(0)
		assert(g.inventory.stash.is_empty() and g.inventory.scrap > 37)
		restored.load(g.INVENTORY_SAVE_PATH)
		assert(restored.stash.is_empty() and restored.scrap == g.inventory.scrap)
		var unchanged := FileAccess.get_sha256(g.INVENTORY_SAVE_PATH)
		g.equip_stash_item(-1); g.scrap_stash_item(99)
		assert(FileAccess.get_sha256(g.INVENTORY_SAVE_PATH) == unchanged)
		checked += 1
	g.free(); await process_frame
	print("STASH TRANSACTION 064 PASS: all four slots reject save failures without changing memory/disk/practice; successful equip and salvage persist across reload; invalid indexes unchanged.")
	quit()
