extends SceneTree

const SOURCE := "res://art/reference/phase2_master/"

static func clear_backdrop(image: Image) -> void:
	image.convert(Image.FORMAT_RGBA8)
	var visited := PackedByteArray()
	visited.resize(image.get_width() * image.get_height())
	var queue: Array[Vector2i] = []
	for x in range(image.get_width()):
		queue.append(Vector2i(x, 0))
		queue.append(Vector2i(x, image.get_height() - 1))
	for y in range(image.get_height()):
		queue.append(Vector2i(0, y))
		queue.append(Vector2i(image.get_width() - 1, y))
	var cursor := 0
	while cursor < queue.size():
		var point := queue[cursor]
		cursor += 1
		if point.x < 0 or point.y < 0 or point.x >= image.get_width() or point.y >= image.get_height(): continue
		var index := point.y * image.get_width() + point.x
		if visited[index]: continue
		visited[index] = 1
		var pixel := image.get_pixelv(point)
		if pixel.a < 0.01 or maxf(pixel.r, maxf(pixel.g, pixel.b)) < 0.055:
			image.set_pixelv(point, Color.TRANSPARENT)
			for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]: queue.append(point + offset)

static func retain_largest_body(image: Image) -> Image:
	var visited := PackedByteArray()
	visited.resize(image.get_width() * image.get_height())
	var largest: Array[Vector2i] = []
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if visited[y * image.get_width() + x] or image.get_pixel(x, y).a < 0.05: continue
			var component: Array[Vector2i] = [Vector2i(x, y)]
			visited[y * image.get_width() + x] = 1
			var cursor := 0
			while cursor < component.size():
				var point := component[cursor]
				cursor += 1
				for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
					var next: Vector2i = point + offset
					if next.x < 0 or next.y < 0 or next.x >= image.get_width() or next.y >= image.get_height(): continue
					var index := next.y * image.get_width() + next.x
					if not visited[index] and image.get_pixelv(next).a >= 0.05:
						visited[index] = 1
						component.append(next)
			if component.size() > largest.size(): largest = component
	var result := Image.create(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8)
	result.fill(Color.TRANSPARENT)
	for point in largest: result.set_pixelv(point, image.get_pixelv(point))
	return result

func _initialize() -> void:
	var ui := Image.load_from_file(SOURCE + "lootlings_hud_menu_cards_material_reference.png")
	var ornament := ui.get_region(Rect2i(351, 1017, 214, 52))
	clear_backdrop(ornament)
	DirAccess.make_dir_recursive_absolute("res://art/ui/beta")
	assert(ornament.save_png("res://art/ui/beta/ornament_gold.png") == OK)
	var material := ui.get_region(Rect2i(1048, 351, 250, 182))
	for name in ["leather", "relic"]:
		var skin: Image = load("res://art/ui/skins/panel_%s_9slice.png" % name).get_image()
		skin.convert(Image.FORMAT_RGBA8)
		for y in range(32, skin.get_height() - 32):
			for x in range(32, skin.get_width() - 32):
				var old := skin.get_pixel(x, y)
				if maxf(old.r, maxf(old.g, old.b)) > 0.30 or old.a < 0.95: continue
				var paint := material.get_pixel(x % material.get_width(), y % material.get_height())
				var tint := Color("#abb9f0") if name == "relic" else Color("#c3c7e3")
				paint = old.lerp(paint * tint, 0.25)
				paint.a = old.a
				skin.set_pixel(x, y, paint)
		assert(skin.save_png("res://art/ui/beta/panel_%s_9slice.png" % name) == OK)
	# Deliberate bust portraits, not truncated bodies pretending to be full actors.
	var heroes := Image.load_from_file(SOURCE + "lootlings_heroes_creatures_demon_cutout_reference.png")
	var portraits := {"patch":Rect2i(748, 37, 230, 290), "sera":Rect2i(1124, 29, 268, 310), "ilex":Rect2i(55, 556, 230, 300)}
	DirAccess.make_dir_recursive_absolute("res://art/sprites/npcs/beta")
	for id in portraits:
		var portrait := heroes.get_region(portraits[id])
		clear_backdrop(portrait)
		portrait.resize(256, 320, Image.INTERPOLATE_LANCZOS)
		assert(portrait.save_png("res://art/sprites/npcs/beta/%s_portrait.png" % id) == OK)
	print("PRESENTATION EXPORT PASSED: original painted material/trim and three deliberate adult bust portraits")
	quit(0)
