extends SceneTree
const Items = preload("res://item_catalog.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	var valid := Items.create_item("bonebow","EPIC",841)
	var broken := {"id":"scrapfang_blade","slot":"Weapon","effects":17,"serial":842}
	var config := ConfigFile.new()
	config.set_value("inventory","stash",[valid,"not an item",broken])
	config.set_value("inventory","equipped",{"Weapon":broken})
	assert(config.save("user://typed_inventory.cfg") == OK)
	var inventory := preload("res://inventory_system.gd").new(); inventory.load("user://typed_inventory.cfg")
	if "--baseline" in OS.get_cmdline_user_args():
		print("RC SAVE BASELINE: parseable mixed stash retains %d records, including invalid item/effects types" % inventory.stash.size())
		quit(); return
	assert(inventory.stash.size() == 1 and inventory.stash[0] == valid)
	assert(inventory.equipped_item("Weapon").serial == -1)
	assert(is_finite(inventory.effect_total("armor")))
	# The malformed source is untouched by loading and therefore recoverable.
	var original := ConfigFile.new(); assert(original.load("user://typed_inventory.cfg") == OK)
	assert(original.get_value("inventory","stash").size() == 3)
	config.clear(); config.set_value("progress","gold",{"wrong":"type"})
	config.set_value("progress","power","5"); config.set_value("progress","shards",INF)
	assert(config.save("user://typed_progress.cfg") == OK)
	var progress := preload("res://meta_store.gd").load_progress("user://typed_progress.cfg")
	assert(progress.gold == 0 and progress.power == 5 and progress.shards == 0)
	# Valid evolved/affixed ownership is preserved exactly.
	valid = preload("res://affix_catalog.gd").apply(valid,["of_the_vault"])
	valid.evolution_stage = 2; inventory.reset_to_starter(); inventory.equip(valid)
	assert(inventory.save("user://valid_owned.cfg") == OK)
	var restored := preload("res://inventory_system.gd").new(); restored.load("user://valid_owned.cfg")
	assert(restored.equipped_item("Weapon") == valid)
	print("RC SAVE QA PASSED: mixed-record/type/nonfinite recovery and exact valid ownership preservation")
	quit()
