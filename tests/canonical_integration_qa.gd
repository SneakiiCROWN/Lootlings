extends SceneTree
const Residents=preload("res://resident_art_catalog.gd")
const Boss=preload("res://boss_presentation.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	call_deferred("review")
func review() -> void:
	for speaker in Residents.IDS:
		var bounds: Rect2=preload("res://hideout_ui.gd").RESIDENT_RECTS[speaker]
		var entry:=Residents.presentation(speaker,bounds)
		assert(entry.texture.resource_path==preload("res://vignette_catalog.gd").entry("resident/"+entry.id).actor)
		if entry.id in ["patch","ilex"]:assert(entry.export_state=="canonical_station_panel" and entry.activity_states.begins_with("NEEDS_NEW_CANON_EXPORT"))
		else:assert(entry.export_state=="idle" and entry.activity_states.begins_with("TEMP"))
		assert(bounds.encloses(entry.rect))
		assert(is_equal_approx(entry.rect.size.x/entry.rect.size.y,float(entry.texture.get_width())/entry.texture.get_height()))
		var note=preload("res://field_notes_catalog.gd").pages({},null,null).filter(func(page):return page.id=="resident/"+entry.id)[0]
		if entry.id in ["patch","ilex"]:assert(note.art==entry.texture.resource_path)
	for region in preload("res://campaign_system.gd").ORDER:
		var profile:=Boss.profile(region);var texture:=Boss.texture_for(profile);var rect:=Boss.display_rect(profile,texture)
		assert(is_equal_approx(rect.size.x/rect.size.y,float(texture.get_width())/texture.get_height()))
		assert(rect.size.x<=profile.display_size.x+.001 and rect.size.y<=profile.display_size.y+.001)
		assert(not profile.status.contains("approved canonical"))
	var inner:=preload("res://lootlings_ui.gd").meter_inner(Rect2(18,80,444,4))
	assert(inner.size.y==2 and inner.size.x==440)
	assert(preload("res://boss_art_manifest.gd").rows().is_empty())
	var game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	for id in preload("res://wanderer_catalog.gd").PRESETS:
		var text: String=str(preload("res://wanderer_catalog.gd").PRESETS[id].display_name).to_upper()
		var size:=preload("res://lootlings_ui.gd").fitted_font_size(game.title_font,text,170,18,12)
		assert(game.title_font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x<=170)
	game.free()
	print("CANONICAL INTEGRATION: scoped Patch/Ilex station panels match memory identity, Sera preserved, source aspect/bounds; all ten boss source ratios; visible thin XP fill; no absent body state promoted")
	quit()
