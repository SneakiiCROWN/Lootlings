extends Control

const ItemCatalog = preload("res://item_catalog.gd")
const LootlingsUI = preload("res://lootlings_ui.gd")
const WeaponCatalog = preload("res://weapon_catalog.gd")
const VANGUARD_TEXTURE = preload("res://art/sprites/weapons/vanguard_hammer.png")
const RANGER_TEXTURE = preload("res://art/sprites/weapons/ranger_bow.png")
const MAGE_TEXTURE = preload("res://art/sprites/weapons/mage_staff.png")
const ROGUE_TEXTURE = preload("res://art/sprites/weapons/rogue_daggers.png")

var slot := "Relic"
var family := "VANGUARD"
var weapon_type := ""
var evolution_stage := 0
var rarity := "COMMON"
var rarity_color := Color("#8de0a5")
var painted_texture: Texture2D

func configure(item: Dictionary) -> void:
	slot = str(item.get("slot", "Relic"))
	family = str(item.get("family", "VANGUARD"))
	weapon_type = str(item.get("weapon_type", ""))
	evolution_stage = int(item.get("evolution_stage", 0))
	rarity = str(item.get("rarity", "COMMON"))
	rarity_color = ItemCatalog.rarity_color(rarity)
	painted_texture = LootlingsUI.item_texture(item)
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.34
	if slot == "Weapon" and rarity!="MYTHICAL SHINY":
		draw_circle(center, radius * 1.20, Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.13))
		draw_arc(center, radius, 0, TAU, 28, rarity_color, maxf(2.0, radius * 0.08))
		var texture: Texture2D = {"RANGER":RANGER_TEXTURE, "MAGE":MAGE_TEXTURE, "ROGUE":ROGUE_TEXTURE}.get(family, VANGUARD_TEXTURE)
		texture = WeaponCatalog.runtime_texture(weapon_type, texture, evolution_stage)
		texture = WeaponCatalog.presentation_texture(weapon_type,"inventory",texture,evolution_stage)
		LootlingsUI.draw_icon(get_canvas_item(), LootlingsUI.framed_item_texture(texture), Rect2(Vector2.ZERO, size))
	else:
		draw_circle(center, radius * 1.20, Color(rarity_color, 0.12))
		LootlingsUI.draw_icon(get_canvas_item(), painted_texture, Rect2(Vector2.ZERO, size))
	var badge_size := minf(28, minf(size.x, size.y) * 0.28)
	var badge_rect := Rect2(size - Vector2.ONE * badge_size, Vector2.ONE * badge_size)
	if rarity in ["RED","MYTHICAL SHINY"]:
		# Existing relic seal with a distinct scarlet rim; never a gold tier badge.
		draw_circle(badge_rect.get_center(),badge_size*.52,Color("#280b22"))
		draw_arc(badge_rect.get_center(),badge_size*.5,0,TAU,24,rarity_color,2,true)
		LootlingsUI.draw_icon(get_canvas_item(),LootlingsUI.icon("gear_charm"),badge_rect.grow(-2))
	else:
		LootlingsUI.draw_icon(get_canvas_item(), LootlingsUI.icon("rarity_%s" % rarity.to_lower()),badge_rect)
