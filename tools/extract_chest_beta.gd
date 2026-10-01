extends SceneTree
const Extract = preload("res://tools/extract_presentation_beta.gd")

func _initialize() -> void:
	var source := Image.load_from_file("res://art/reference/phase2_master/lootlings_chests_shrine_merchant_props_reference.png")
	var crops := {"scavenged":Rect2i(0, 142, 291, 206), "relic":Rect2i(293, 58, 339, 288)}
	for id in crops:
		var body := source.get_region(crops[id])
		Extract.clear_backdrop(body)
		body = Extract.retain_largest_body(body)
		body = body.get_region(body.get_used_rect())
		var scale := 432.0 / maxf(body.get_width(), body.get_height())
		body.resize(roundi(body.get_width() * scale), roundi(body.get_height() * scale), Image.INTERPOLATE_LANCZOS)
		var canvas := Image.create(512, 512, false, Image.FORMAT_RGBA8)
		canvas.fill(Color.TRANSPARENT)
		canvas.blit_rect(body, Rect2i(Vector2i.ZERO, body.get_size()), (Vector2i(512, 512) - body.get_size()) / 2)
		assert(canvas.save_png("res://art/sprites/rewards/%s_chest_beta.png" % id) == OK)
	print("CHEST EXPORT PASSED: two original painted cutouts; Hoard art unchanged")
	quit(0)
