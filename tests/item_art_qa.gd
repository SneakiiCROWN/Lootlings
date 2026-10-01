extends SceneTree
const UI = preload("res://lootlings_ui.gd")
const Items = preload("res://item_catalog.gd")
var native := false
var game

func _initialize() -> void:
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
	for id in ["cursed_ring", "vault_receipt", "stormspark"]:
		game.start_run()
		game.set_process(false)
		game.pending_items = [Items.create_item(id, "EPIC", 43)]
		game.show_next_item()
		assert(game.current_item.id == id)
		if native: await capture("item_" + id)
	assert(UI.item_texture(Items.create_item("ruinweave_coat", "COMMON")).resource_path.ends_with("gear_armour.png"))
	# Every live starter's physical drops must use its actual family art.
	for type in preload("res://weapon_catalog.gd").STARTERS:
		var weapon := preload("res://weapon_catalog.gd").starter(type)
		assert(game.merchant_weapon_texture(weapon) == UI.item_texture(weapon))
	game.queue_free()
	await process_frame
	print("ITEM ART QA PASSED: 11 existing bases, immutable equipment data, category fallback and all starter drop textures")
	quit(0)

func capture(label: String) -> void:
	await create_timer(0.35).timeout
	await RenderingServer.frame_post_draw
	var shot := root.get_texture().get_image()
	assert(shot.get_size() == Vector2i(480, 854))
	assert(shot.save_png("res://.godot_test_data/%s_qa.png" % label) == OK)
