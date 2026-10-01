extends SceneTree

# Explicitly approved mechanical BETA extraction. No generative repainting.
# Originals remain in art/reference (excluded from runtime imports).
const SOURCE := "res://art/reference/phase2_master/"
const ENV := "lootlings_environment_town_forest_infernal_frost_reference.png"
const GEAR := "lootlings_fantasy_gear_compendium.png"
const WEAPON_CROPS := {
	"greatsword":Rect2i(588, 69, 68, 168),
	"greataxe":Rect2i(663, 68, 87, 169),
	"orb":Rect2i(960, 571, 84, 100)
}
const EXPORTS := [
	[ENV, Rect2i(4, 4, 714, 528), "art/backgrounds/beta/moonmarket.png", false],
	[ENV, Rect2i(730, 4, 714, 528), "art/backgrounds/beta/crystal_grove.png", false],
	[ENV, Rect2i(4, 545, 714, 537), "art/backgrounds/beta/infernal_citadel.png", false],
	[ENV, Rect2i(730, 545, 714, 537), "art/backgrounds/beta/frozen_citadel.png", false]
]

func _initialize() -> void:
	for entry in EXPORTS:
		var source := Image.load_from_file(SOURCE + entry[0])
		assert(source != null and not source.is_empty())
		var crop := source.get_region(entry[1])
		crop.convert(Image.FORMAT_RGBA8)
		# Gameplay band is 480x568: portrait-safe focal crop, no board seams.
		var width := roundi(crop.get_height() * 480.0 / 568.0)
		crop = crop.get_region(Rect2i((crop.get_width() - width) / 2, 0, width, crop.get_height()))
		crop.resize(480, 568, Image.INTERPOLATE_LANCZOS)
		DirAccess.make_dir_recursive_absolute("res://" + str(entry[2]).get_base_dir())
		assert(crop.save_png("res://" + entry[2]) == OK)
		print("BETA EXPORT ", entry[2], " ", crop.get_size())
	for id in ["emberhorn", "mosskin", "moonkip", "pebblewyrm", "glimmerfin"]:
		var name: String = {"emberhorn":"Emberhorn", "mosskin":"Mosskin", "moonkip":"Moonkip", "pebblewyrm":"Pebblewyrm", "glimmerfin":"Glimmerfin", "gloomlet":"Gloomlet"}[id]
		var original := Image.load_from_file("res://art/reference/canonical/characters/%s_CharacterSheet_Canonical.png" % name)
		var body := original.get_region(Rect2i(0, 765, 166, 189))
		body.convert(Image.FORMAT_RGBA8)
		# Edge-connected near-neutral dark sheet backdrop only. Interior fur,
		# clothing, eyes and markings remain original pixels, including dark ones.
		var visited := PackedByteArray()
		visited.resize(body.get_width() * body.get_height())
		var queue: Array[Vector2i] = []
		for x in range(body.get_width()):
			queue.append(Vector2i(x, 0))
			queue.append(Vector2i(x, body.get_height() - 1))
		for y in range(body.get_height()):
			queue.append(Vector2i(0, y))
			queue.append(Vector2i(body.get_width() - 1, y))
		var cursor := 0
		while cursor < queue.size():
			var point := queue[cursor]
			cursor += 1
			if point.x < 0 or point.y < 0 or point.x >= body.get_width() or point.y >= body.get_height(): continue
			var index := point.y * body.get_width() + point.x
			if visited[index]: continue
			visited[index] = 1
			var pixel := body.get_pixelv(point)
			var maximum := maxf(pixel.r, maxf(pixel.g, pixel.b))
			var minimum := minf(pixel.r, minf(pixel.g, pixel.b))
			if maximum < 0.25 and maximum - minimum < 0.085:
				body.set_pixelv(point, Color.TRANSPARENT)
				for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]: queue.append(point + offset)
		var bounds := body.get_used_rect()
		body = body.get_region(bounds)
		var scale := 480.0 / maxf(body.get_width(), body.get_height())
		body.resize(roundi(body.get_width() * scale), roundi(body.get_height() * scale), Image.INTERPOLATE_LANCZOS)
		var canvas := Image.create(512, 512, false, Image.FORMAT_RGBA8)
		canvas.fill(Color.TRANSPARENT)
		canvas.blit_rect(body, Rect2i(Vector2i.ZERO, body.get_size()), (Vector2i(512, 512) - body.get_size()) / 2)
		DirAccess.make_dir_recursive_absolute("res://art/sprites/lootlings")
		assert(canvas.save_png("res://art/sprites/lootlings/%s_idle.png" % id) == OK)
		print("CANONICAL PIXEL EXPORT ", id)
	var gear := Image.load_from_file(SOURCE + GEAR)
	for family in WEAPON_CROPS:
		var weapon := gear.get_region(WEAPON_CROPS[family])
		weapon.convert(Image.FORMAT_RGBA8)
		var bg_seen := PackedByteArray()
		bg_seen.resize(weapon.get_width() * weapon.get_height())
		var bg_queue: Array[Vector2i] = []
		for x in range(weapon.get_width()):
			bg_queue.append(Vector2i(x, 0))
			bg_queue.append(Vector2i(x, weapon.get_height() - 1))
		for y in range(weapon.get_height()):
			bg_queue.append(Vector2i(0, y))
			bg_queue.append(Vector2i(weapon.get_width() - 1, y))
		var bg_cursor := 0
		while bg_cursor < bg_queue.size():
			var point := bg_queue[bg_cursor]
			bg_cursor += 1
			if point.x < 0 or point.y < 0 or point.x >= weapon.get_width() or point.y >= weapon.get_height(): continue
			var index := point.y * weapon.get_width() + point.x
			if bg_seen[index]: continue
			bg_seen[index] = 1
			var pixel := weapon.get_pixelv(point)
			if maxf(pixel.r, maxf(pixel.g, pixel.b)) < 0.28 and absf(pixel.r - pixel.b) < 0.14:
				weapon.set_pixelv(point, Color.TRANSPARENT)
				for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]: bg_queue.append(point + offset)
		# Reject detached frame labels/icons; retain the weapon's connected art.
		var seen := PackedByteArray()
		seen.resize(weapon.get_width() * weapon.get_height())
		var largest: Array[Vector2i] = []
		for y in range(weapon.get_height()):
			for x in range(weapon.get_width()):
				if seen[y * weapon.get_width() + x] or weapon.get_pixel(x, y).a < 0.05: continue
				var component: Array[Vector2i] = [Vector2i(x, y)]
				seen[y * weapon.get_width() + x] = 1
				var cursor := 0
				while cursor < component.size():
					var point := component[cursor]
					cursor += 1
					for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
						var next: Vector2i = point + offset
						if next.x < 0 or next.y < 0 or next.x >= weapon.get_width() or next.y >= weapon.get_height(): continue
						var index := next.y * weapon.get_width() + next.x
						if not seen[index] and weapon.get_pixelv(next).a >= 0.05:
							seen[index] = 1
							component.append(next)
				if component.size() > largest.size(): largest = component
		var isolated := Image.create(weapon.get_width(), weapon.get_height(), false, Image.FORMAT_RGBA8)
		isolated.fill(Color.TRANSPARENT)
		for point in largest: isolated.set_pixelv(point, weapon.get_pixelv(point))
		isolated = isolated.get_region(isolated.get_used_rect())
		var scale := 480.0 / maxf(isolated.get_width(), isolated.get_height())
		isolated.resize(roundi(isolated.get_width() * scale), roundi(isolated.get_height() * scale), Image.INTERPOLATE_LANCZOS)
		var canvas := Image.create(512, 512, false, Image.FORMAT_RGBA8)
		canvas.fill(Color.TRANSPARENT)
		canvas.blit_rect(isolated, Rect2i(Vector2i.ZERO, isolated.get_size()), (Vector2i(512, 512) - isolated.get_size()) / 2)
		assert(canvas.save_png("res://art/sprites/weapons/%s_held.png" % family) == OK)
	var ruins: Image = load("res://art/backgrounds/treasure_ruins_arena.png").get_image()
	var ground := ruins.get_region(Rect2i(0, roundi(ruins.get_height() * 0.571), ruins.get_width(), roundi(ruins.get_height() * 0.135)))
	ground.resize(480, 110, Image.INTERPOLATE_LANCZOS)
	ground.convert(Image.FORMAT_RGBA8)
	for y in range(ground.get_height()):
		for x in range(ground.get_width()):
			var pixel := ground.get_pixel(x, y)
			pixel.a = minf(clampf(y / 5.0, 0, 1), clampf((109 - y) / 34.0, 0, 1))
			ground.set_pixel(x, y, pixel)
	assert(ground.save_png("res://art/backgrounds/beta/ruin_platform.png") == OK)
	var boss_board := Image.load_from_file(SOURCE + "lootlings_boss_demon_mimic_reference.png")
	for id in ["furnace_regent", "verdant_mirror"]:
		var boss := boss_board.get_region(Rect2i(0, 0, 540, 569) if id == "furnace_regent" else Rect2i(991, 0, 457, 594))
		boss.convert(Image.FORMAT_RGBA8)
		# Remove only identifiable neighbouring blue/purple cutouts at board seams.
		for y in range(boss.get_height()):
			for x in range(boss.get_width()):
				var pixel := boss.get_pixel(x, y)
				if (id == "furnace_regent" and x > 520 and pixel.b > pixel.r) or (id == "verdant_mirror" and ((x < 25 and y > 300 and pixel.b > pixel.g * 0.95) or (y > 575 and pixel.b > pixel.g * 1.1))):
					boss.set_pixel(x, y, Color.TRANSPARENT)
		var seen := PackedByteArray()
		seen.resize(boss.get_width() * boss.get_height())
		var queue: Array[Vector2i] = []
		for x in range(boss.get_width()):
			queue.append(Vector2i(x, 0))
			queue.append(Vector2i(x, boss.get_height() - 1))
		for y in range(boss.get_height()):
			queue.append(Vector2i(0, y))
			queue.append(Vector2i(boss.get_width() - 1, y))
		var cursor := 0
		while cursor < queue.size():
			var point := queue[cursor]
			cursor += 1
			if point.x < 0 or point.y < 0 or point.x >= boss.get_width() or point.y >= boss.get_height(): continue
			var index := point.y * boss.get_width() + point.x
			if seen[index]: continue
			seen[index] = 1
			var pixel := boss.get_pixelv(point)
			if maxf(pixel.r, maxf(pixel.g, pixel.b)) < 0.06 or pixel.a < 0.01:
				boss.set_pixelv(point, Color.TRANSPARENT)
				for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]: queue.append(point + offset)
		var bounds := boss.get_used_rect()
		boss = boss.get_region(bounds)
		var scale := 480.0 / maxf(boss.get_width(), boss.get_height())
		boss.resize(roundi(boss.get_width() * scale), roundi(boss.get_height() * scale), Image.INTERPOLATE_LANCZOS)
		var canvas := Image.create(512, 512, false, Image.FORMAT_RGBA8)
		canvas.fill(Color.TRANSPARENT)
		canvas.blit_rect(boss, Rect2i(Vector2i.ZERO, boss.get_size()), (Vector2i(512, 512) - boss.get_size()) / 2)
		DirAccess.make_dir_recursive_absolute("res://art/sprites/enemies/beta")
		assert(canvas.save_png("res://art/sprites/enemies/beta/%s.png" % id) == OK)
	quit(0)
