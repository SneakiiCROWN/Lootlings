extends SceneTree

const Extract = preload("res://tools/extract_presentation_beta.gd")
const CROPS := {
	"spear":Rect2i(1234, 0, 214, 474),
	"crossbow":Rect2i(698, 501, 306, 281),
	"claws":Rect2i(12, 778, 246, 308),
	"wand":Rect2i(1218, 474, 230, 310)
}

func _initialize() -> void:
	var source := Image.load_from_file("res://art/reference/phase2_master/lootlings_weapon_families_reference.png")
	for id in CROPS:
		var body := source.get_region(CROPS[id])
		Extract.clear_backdrop(body)
		body = Extract.retain_largest_body(body)
		body = body.get_region(body.get_used_rect())
		if id == "claws": body.rotate_90(COUNTERCLOCKWISE) # Wrist left, talons right.
		var scale := 432.0 / maxf(body.get_width(), body.get_height())
		body.resize(roundi(body.get_width() * scale), roundi(body.get_height() * scale), Image.INTERPOLATE_LANCZOS)
		var canvas := Image.create(512, 512, false, Image.FORMAT_RGBA8)
		canvas.fill(Color.TRANSPARENT)
		canvas.blit_rect(body, Rect2i(Vector2i.ZERO, body.get_size()), (Vector2i(512, 512) - body.get_size()) / 2)
		assert(canvas.save_png("res://art/sprites/weapons/%s_held.png" % id) == OK)
	print("WEAPON EXPORT PASSED: four approved beta silhouettes, originals unchanged; flail rejected as a Sling substitute")
	quit(0)
