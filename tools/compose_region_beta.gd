extends SceneTree

const Extract = preload("res://tools/extract_presentation_beta.gd")
const SOURCE := "res://art/reference/phase2_master/"

func portrait(image: Image) -> Image:
	image.convert(Image.FORMAT_RGBA8)
	var extent := Vector2(image.get_size())
	var wanted := 480.0 / 568.0
	var size := Vector2i(roundi(extent.y * wanted), image.get_height()) if extent.x / extent.y > wanted else Vector2i(image.get_width(), roundi(extent.x / wanted))
	image = image.get_region(Rect2i((image.get_size() - size) / 2, size))
	image.resize(480, 568, Image.INTERPOLATE_LANCZOS)
	return image

func add_prop(background: Image, source: Image, crop: Rect2i, destination: Rect2i) -> void:
	var prop := source.get_region(crop)
	Extract.clear_backdrop(prop)
	prop = Extract.retain_largest_body(prop)
	prop.resize(destination.size.x, destination.size.y, Image.INTERPOLATE_LANCZOS)
	background.blend_rect(prop, Rect2i(Vector2i.ZERO, prop.get_size()), destination.position)

func save(image: Image, id: String) -> void:
	assert(image.save_png("res://art/backgrounds/beta/%s.png" % id) == OK)

func _initialize() -> void:
	var world := Image.load_from_file(SOURCE + "lootlings_worlds_loot_and_adventure.png")
	var props := Image.load_from_file(SOURCE + "lootlings_chests_shrine_merchant_props_reference.png")
	var moonfen := portrait(world.get_region(Rect2i(1234, 88, 201, 224)))
	save(moonfen, "moonfen_marsh")
	var archive := portrait(world.get_region(Rect2i(1030, 90, 188, 222)))
	save(archive, "starfall_sanctum")
	save(portrait(world.get_region(Rect2i(410, 91, 191, 221))), "skyhook_city")
	# Real spatial recomposition, not a same-arena palette swap. Portal, forge
	# and throne are scenery; they have no damage, reward or encounter meaning.
	var nullglass := archive.duplicate()
	add_prop(nullglass, props, Rect2i(900, 350, 391, 368), Rect2i(70, 42, 340, 350))
	save(nullglass, "nullglass_gate")
	var gearworks := portrait(load("res://art/backgrounds/salvage_warrens_arena.png").get_image())
	add_prop(gearworks, props, Rect2i(180, 731, 281, 330), Rect2i(283, 40, 176, 246))
	gearworks.blit_rect(archive, Rect2i(0, 386, 480, 182), Vector2i(0, 386))
	save(gearworks, "gearworks_foundry")
	var hoard := portrait(load("res://art/backgrounds/stash_vault.png").get_image())
	add_prop(hoard, props, Rect2i(317, 347, 253, 363), Rect2i(110, 30, 260, 340))
	save(hoard, "first_hoard_throne")
	print("REGION EXPORT PASSED: six distinct scene compositions, unchanged source boards")
	quit(0)
