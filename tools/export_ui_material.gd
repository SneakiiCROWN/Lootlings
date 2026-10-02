extends SceneTree
# Mechanical alpha-bounds/canvas export. Original generated paintings retained.
func _initialize() -> void:
	for id in ["panel","relic","hud","button_primary","button_secondary","button_destructive"]:
		var image := Image.load_from_file(ProjectSettings.globalize_path("res://art/source/ui_material_v1/%s.png" % id))
		assert(image != null and image.get_format() == Image.FORMAT_RGBA8)
		if id == "hud" or id.begins_with("button_"):
			# Ignore near-transparent generation padding, preserve the solid trim.
			var low := image.get_size()
			var high := Vector2i.ZERO
			for y in image.get_height():
				for x in image.get_width():
					if image.get_pixel(x,y).a > .5:
						low = low.min(Vector2i(x,y))
						high = high.max(Vector2i(x,y))
			var bounds := Rect2i(low,high-low+Vector2i.ONE).grow(2).intersection(Rect2i(Vector2i.ZERO,image.get_size()))
			image = image.get_region(bounds)
			image.resize(512 if id.begins_with("button_") else 960,144 if id.begins_with("button_") else 240,Image.INTERPOLATE_LANCZOS)
		else: image.resize(512,512,Image.INTERPOLATE_LANCZOS)
		assert(image.save_png("res://art/ui/production/%s.png" % id) == OK)
	print("Exported six painted UI materials; original paintings retained")
	quit(0)
