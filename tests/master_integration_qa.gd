extends SceneTree
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	call_deferred("verify")
func verify() -> void:
	var ui=preload("res://lootlings_ui.gd")
	for id in ui.RUNE_GLYPHS:
		var item=preload("res://item_catalog.gd").create_item(id,"RARE",91)
		assert(not item.is_empty() and item.slot=="Rune",id)
		assert(ui.item_texture(item).resource_path==ui.icon(ui.RUNE_GLYPHS[id]).resource_path)
	for glyph in ["rune_fire","rune_frost","rune_poison","rune_lightning","rune_arcane","core_fire","core_lightning"]:
		assert(ui.inline_icon(glyph).contains(ui.icon(glyph).resource_path))
	var generic=preload("res://item_catalog.gd").create_item("echo_invoice","RARE",91)
	assert(ui.item_texture(generic).resource_path.ends_with("rune_arcane.png"))
	var old=preload("res://item_catalog.gd").create_item("cursed_ring","RARE",91)
	assert(ui.item_texture(old).resource_path.ends_with("cursed_ring.png"))
	print("MASTER INTEGRATION: ten semantic rune mappings, five canonical glyphs, inline/drawn resource parity, existing bespoke item art retained");quit()
