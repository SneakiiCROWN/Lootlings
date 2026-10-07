extends RefCounted
# Original sheet pixels, bounded static motifs on existing visual clocks.
static var textures := {}
static func texture(id: String, category: String = "vfx") -> Texture2D:
	var key:=category+"/"+id
	if not textures.has(key): textures[key]=load("res://art/production/phase4e/%s/%s.png" % [category,id])
	return textures[key]
static func draw(canvas: CanvasItem, id: String, bounds: Rect2, alpha: float = 1.0, category: String = "vfx") -> void:
	var image:=texture(id,category)
	var extent:=image.get_size()*minf(bounds.size.x/image.get_width(),bounds.size.y/image.get_height())
	canvas.draw_texture_rect(image,Rect2(bounds.get_center()-extent*.5,extent),false,Color(1,1,1,clampf(alpha,0,1)))
static func impact(canvas: CanvasItem, pos: Vector2, element: String, life: float) -> bool:
	var id: String={"Fire":"fire_arc","Frost":"frost_burst","Ice":"frost_burst","Lightning":"lightning_contact","Poison":"poison_contact","Nature":"nature_vines","Corruption":"shadow_seal","Dark":"shadow_seal","Arcane":"crystal_ward","Relic":"crystal_ward"}.get(element,"")
	if id.is_empty():return false
	draw(canvas,id,Rect2(pos-Vector2(32,38),Vector2(64,64)),life*.85)
	return true
