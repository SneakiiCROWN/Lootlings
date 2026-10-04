extends SceneTree
const UI = preload("res://lootlings_ui.gd")
const Items = preload("res://item_catalog.gd")
var native := false
var game

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	native = "--visual" in OS.get_cmdline_user_args()
	call_deferred("run_qa")

func run_qa() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	for id in UI.ITEM_ART:
		var item := Items.create_item(id, "EPIC", 41)
		assert(not item.is_empty())
		var texture := UI.item_texture(item)
		assert(texture.resource_path == "res://art/sprites/items/beta/%s.png" % UI.ITEM_ART[id])
		assert(texture.get_size() == Vector2(256, 256))
		var before := item.duplicate(true)
		game.item_icon.configure(item)
		assert(game.item_icon.painted_texture == texture and item == before)
	for id in ["cursed_ring", "vault_receipt", "stormspark", "pebble_sling"]:
		game.start_run()
		game.set_process(false)
		game.pending_items = [Items.create_item(id, "EPIC", 43)]
		game.show_next_item()
		assert(game.current_item.id == id)
		if id == "pebble_sling":
			assert(UI.item_texture(game.current_item).resource_path == "res://art/sprites/weapons/sling_inventory.png")
			assert(game.item_icon.painted_texture.get_size() == Vector2(256,256))
			assert(game.hideout_ui.weapon_texture_for_item(game.current_item).resource_path.ends_with("sling_inventory.png"))
		if native: await capture("item_" + id)
	assert(UI.item_texture(Items.create_item("ruinweave_coat", "COMMON")).resource_path.ends_with("gear_armour.png"))
	# Every live starter's physical drops must use its actual family art.
	for type in preload("res://weapon_catalog.gd").STARTERS:
		var weapon := preload("res://weapon_catalog.gd").starter(type)
		game.apply_merchant_thumbnail(game.merchant_buttons[0],game.merchant_icons[0],weapon)
		assert(game.merchant_icons[0].painted_texture == UI.item_texture(weapon))
	game.show_hideout()
	# Other isolated suite tests may have persisted an equipped charm. This UI
	# fixture must select the item it just creates, not a previous test's gear.
	game.inventory.reset_to_starter()
	game.inventory.keep(Items.create_item("cursed_ring", "LEGENDARY", 71))
	game.hideout_ui.show_stash()
	assert(game.hideout_ui.equipped_slot_buttons.size() == 4)
	game.hideout_ui.equipped_slot_buttons.Relic.pressed.emit()
	assert(game.hideout_ui.stash_filter == "CHARM")
	assert(game.hideout_ui.stash_detail_icon.visible)
	assert(game.hideout_ui.stash_detail_name.text == "Definitely Not Cursed Ring")
	assert(game.hideout_ui.stash_detail.scroll_active)
	assert(game.hideout_ui.stash_detail_identity.text.contains("LEGENDARY"))
	if native: await capture("stash_charm_detail")
	game.queue_free()
	await process_frame
	print("ITEM ART QA PASSED: 11 existing bases, immutable equipment data, category fallback and all starter drop textures")
	quit(0)

func capture(label: String) -> void:
	await create_timer(0.35).timeout
	await RenderingServer.frame_post_draw
	var shot := root.get_texture().get_image()
	assert(shot.get_size() == root.size)
	assert(shot.save_png("res://.godot_test_data/%s_qa.png" % label) == OK)
