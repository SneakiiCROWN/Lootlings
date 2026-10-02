extends SceneTree
# Mechanical runtime canvas export; preserve the full source painting.
func _initialize() -> void:
	var image := Image.load_from_file(ProjectSettings.globalize_path("res://art/source/held_staff_v1/staff_held.png"))
	assert(image != null and image.get_format() == Image.FORMAT_RGBA8)
	image.resize(512,512,Image.INTERPOLATE_LANCZOS)
	assert(image.save_png("res://art/sprites/weapons/stances/staff_held.png") == OK)
	print("Exported independent 512-square held staff; source/inventory preserved")
	quit(0)
