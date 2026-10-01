extends Control

const ItemCatalog = preload("res://item_catalog.gd")
const LootlingsUI = preload("res://lootlings_ui.gd")
const VANGUARD_TEXTURE = preload("res://art/sprites/weapons/vanguard_hammer.png")
const RANGER_TEXTURE = preload("res://art/sprites/weapons/ranger_bow.png")
const MAGE_TEXTURE = preload("res://art/sprites/weapons/mage_staff.png")
const ROGUE_TEXTURE = preload("res://art/sprites/weapons/rogue_daggers.png")

var slot := "Relic"
var family := "VANGUARD"
var rarity := "COMMON"
var rarity_color := Color("#8de0a5")

func configure(item: Dictionary) -> void:
	slot = str(item.get("slot", "Relic"))
	family = str(item.get("family", "VANGUARD"))
	rarity = str(item.get("rarity", "COMMON"))
	rarity_color = ItemCatalog.rarity_color(rarity)
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.34
	if slot == "Weapon":
		draw_circle(center, radius * 1.20, Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.13))
		draw_arc(center, radius, 0, TAU, 28, rarity_color, maxf(2.0, radius * 0.08))
		var texture: Texture2D = {"RANGER":RANGER_TEXTURE, "MAGE":MAGE_TEXTURE, "ROGUE":ROGUE_TEXTURE}.get(family, VANGUARD_TEXTURE)
		LootlingsUI.draw_icon(get_canvas_item(), texture, Rect2(Vector2.ZERO, size))
	else:
		var category := "armour" if slot == "Armour" else "rune" if slot == "Rune" else "charm"
		LootlingsUI.draw_icon(get_canvas_item(), LootlingsUI.icon("gear_%s" % category), Rect2(Vector2.ZERO, size))
	var badge_size := minf(28, minf(size.x, size.y) * 0.28)
	LootlingsUI.draw_icon(get_canvas_item(), LootlingsUI.icon("rarity_%s" % rarity.to_lower()), Rect2(size - Vector2.ONE * badge_size, Vector2.ONE * badge_size))
