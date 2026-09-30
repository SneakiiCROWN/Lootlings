extends SceneTree

const ItemCatalog = preload("res://item_catalog.gd")
const AffixCatalog = preload("res://affix_catalog.gd")

func _initialize() -> void:
	call_deferred("capture_screens")

func capture_screens() -> void:
	var packed := load("res://main.tscn") as PackedScene
	if packed == null:
		quit(1)
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	game.start_run()
	game.wave = 12
	game.wave_kills = 0
	game.last_spawned_wave = 0
	game.spawn_enemy()
	game.debug_force_variant("rootbound")
	for frame in range(8):
		await process_frame
	if not save_viewport("combat_variant_qa.png"):
		quit(1)
		return
	var preview := ItemCatalog.create_item("moonbranch", "LEGENDARY", 99002)
	preview = AffixCatalog.apply(preview, ["keen", "frostbell_chime"])
	game.pending_items = [preview]
	game.show_next_item()
	for frame in range(8):
		await process_frame
	if not save_viewport("signature_loot_qa.png"):
		quit(1)
		return
	print("VISUAL QA CAPTURED: combat variant + Signature Loot at %s" % root.content_scale_size)
	quit(0)

func save_viewport(file_name: String) -> bool:
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("VISUAL QA: viewport image unavailable")
		return false
	var path := ProjectSettings.globalize_path("res://.godot_test_data/%s" % file_name)
	var error := image.save_png(path)
	if error != OK:
		push_error("VISUAL QA: failed to save %s (%d)" % [path, error])
		return false
	return true
