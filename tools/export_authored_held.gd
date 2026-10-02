extends SceneTree
# Mechanical production-canvas export only; source paintings preserved.
func _initialize() -> void:
	for id in ["greatsword","greataxe","maul"]:
		var image := Image.load_from_file(ProjectSettings.globalize_path("res://art/source/held_heavy_v1/%s_held.png" % id))
		assert(image != null and image.has_mipmaps() == false)
		assert(image.get_format() == Image.FORMAT_RGBA8)
		image.resize(512,512,Image.INTERPOLATE_LANCZOS)
		DirAccess.make_dir_recursive_absolute("res://art/sprites/weapons/stances")
		assert(image.save_png("res://art/sprites/weapons/stances/%s_held.png" % id) == OK)
	print("Exported three 512x512 RGBA held assets; original paintings preserved")
	quit(0)
