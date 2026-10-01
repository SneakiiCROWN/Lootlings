extends SceneTree
const Extract = preload("res://tools/extract_presentation_beta.gd")

func _initialize() -> void:
	var source := Image.load_from_file("res://art/reference/phase2_master/lootlings_jewellery_relic_consumable_loot_reference.png")
	var crops := {
		"cursed_ring":Rect2i(249, 0, 244, 276),
		"nature_pendant":Rect2i(492, 0, 240, 280),
		"hoard_locket":Rect2i(733, 0, 237, 278),
		"relic_orbit":Rect2i(944, 280, 250, 260),
		"vault_scroll":Rect2i(938, 548, 270, 258),
		"storm_crystal":Rect2i(494, 803, 243, 282),
		"ember_stone":Rect2i(739, 804, 231, 281),
	}
	DirAccess.make_dir_recursive_absolute("res://art/sprites/items/beta")
	for id in crops:
		var body := source.get_region(crops[id])
		Extract.clear_backdrop(body)
		body = Extract.retain_largest_body(body)
		body = body.get_region(body.get_used_rect())
		var scale := 224.0 / maxf(body.get_width(), body.get_height())
		body.resize(roundi(body.get_width() * scale), roundi(body.get_height() * scale), Image.INTERPOLATE_LANCZOS)
		var canvas := Image.create(256, 256, false, Image.FORMAT_RGBA8)
		canvas.fill(Color.TRANSPARENT)
		canvas.blit_rect(body, Rect2i(Vector2i.ZERO, body.get_size()), (Vector2i(256, 256) - body.get_size()) / 2)
		assert(canvas.save_png("res://art/sprites/items/beta/%s.png" % id) == OK)
	print("LOOT ART EXPORT PASSED: seven approved jewellery/relic/rune silhouettes")
	quit(0)
