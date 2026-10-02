extends SceneTree
# Mechanical runtime canvas export; preserve the full source painting.
func _initialize() -> void:
	# One shared mechanical export path; no repainting or duplicate tooling.
	var family := "spear" if "--spear" in OS.get_cmdline_user_args() else "staff"
	if "--sling" in OS.get_cmdline_user_args(): family = "sling"
	var image := Image.load_from_file(ProjectSettings.globalize_path("res://art/source/held_%s_v1/%s_held.png" % [family,family]))
	assert(image != null and image.get_format() == Image.FORMAT_RGBA8)
	image.resize(512,512,Image.INTERPOLATE_LANCZOS)
	var path := "res://art/sprites/weapons/%s_held.png" % family if family == "sling" else "res://art/sprites/weapons/stances/%s_held.png" % family
	assert(image.save_png(path) == OK)
	if family == "sling":
		image.resize(256,256,Image.INTERPOLATE_LANCZOS)
		assert(image.save_png("res://art/sprites/weapons/sling_inventory.png") == OK)
	print("Exported independent 512-square held %s; source/inventory preserved" % family)
	quit(0)
