extends Control

const ItemCatalog = preload("res://item_catalog.gd")
const VANGUARD_TEXTURE = preload("res://art/sprites/weapons/vanguard_hammer.png")
const RANGER_TEXTURE = preload("res://art/sprites/weapons/ranger_bow.png")
const MAGE_TEXTURE = preload("res://art/sprites/weapons/mage_staff.png")
const ROGUE_TEXTURE = preload("res://art/sprites/weapons/rogue_daggers.png")

var slot := "Relic"
var family := "VANGUARD"
var rarity_color := Color("#8de0a5")

func configure(item: Dictionary) -> void:
	slot = str(item.get("slot", "Relic"))
	family = str(item.get("family", "VANGUARD"))
	rarity_color = ItemCatalog.rarity_color(str(item.get("rarity", "COMMON")))
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.34
	draw_circle(center, radius * 1.20, Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.13))
	draw_circle(center, radius, Color("#10182cea"))
	draw_arc(center, radius, 0, TAU, 28, rarity_color, maxf(2.0, radius * 0.08))
	var ink := Color("#f8f1d0")
	if slot == "Weapon":
		var texture: Texture2D = {"RANGER":RANGER_TEXTURE, "MAGE":MAGE_TEXTURE, "ROGUE":ROGUE_TEXTURE}.get(family, VANGUARD_TEXTURE)
		var extent := radius * 1.55
		draw_texture_rect(texture, Rect2(center - Vector2.ONE * extent, Vector2.ONE * extent * 2.0), false, Color.WHITE)
		return
	match slot:
		"Armour":
			var shield := PackedVector2Array([center + Vector2(0,-radius*0.58),center + Vector2(radius*0.52,-radius*0.25),center + Vector2(radius*0.38,radius*0.36),center + Vector2(0,radius*0.65),center + Vector2(-radius*0.38,radius*0.36),center + Vector2(-radius*0.52,-radius*0.25)])
			draw_colored_polygon(shield, rarity_color.darkened(0.25))
			draw_polyline(PackedVector2Array(Array(shield) + [shield[0]]), ink, radius * 0.09)
		"Rune":
			var rune := PackedVector2Array([center + Vector2(0,-radius*0.62),center + Vector2(radius*0.48,0),center + Vector2(0,radius*0.62),center + Vector2(-radius*0.48,0)])
			draw_colored_polygon(rune, rarity_color.darkened(0.22))
			draw_polyline(PackedVector2Array(Array(rune) + [rune[0]]), ink, radius * 0.08)
			draw_line(center + Vector2(-radius*0.18,0), center + Vector2(radius*0.18,0), ink, radius * 0.08)
		_:
			draw_arc(center + Vector2(0, radius*0.08), radius*0.42, 0, TAU, 24, ink, radius * 0.16)
			draw_colored_polygon(PackedVector2Array([center + Vector2(0,-radius*0.65),center + Vector2(radius*0.24,-radius*0.28),center + Vector2(0,-radius*0.05),center + Vector2(-radius*0.24,-radius*0.28)]), rarity_color)
