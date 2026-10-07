extends RefCounted
# Source-sheet expression crops, not substitute combat states.
static var portraits := {}
static var icons := {}
static var neutral_bodies := {}
# Authored neutral source views for Home and memory staging only. Combat must
# still use its exact state/facing/weapon contract, never this convenience path.
static func neutral_body(id: String) -> Texture2D:
	if preload("res://actor_identity_corrections.gd").corrected_actor(id):return null
	if id not in preload("res://lootling_catalog.gd").ENTRIES: return null
	if not neutral_bodies.has(id):
		var path := "res://art/production/phase4e/lootlings/%s/%s_idle_right.png" % [id,id]
		neutral_bodies[id]=load(path) if ResourceLoader.exists(path) else null
	return neutral_bodies[id]
static func inventory_icon(id: String) -> Texture2D:
	if id not in ["greatsword","greataxe","maul","spear","daggers","claws","bow","crossbow","sling","staff","wand","orb"]: return null
	if not icons.has(id): icons[id]=load("res://art/production/phase4e/weapons/"+id+"_inventory.png")
	return icons[id]
static func portrait(id: String, expression: String = "determined") -> Texture2D:
	if preload("res://actor_identity_corrections.gd").corrected_actor(id):return null
	if id not in ["emberhorn","mosskin","moonkip","pebblewyrm","glimmerfin","gloomlet"]: return null
	if expression not in ["happy","cheeky","angry","excited","sad","curious","surprised","determined"]: expression="determined"
	var key := id+"_"+expression
	if not portraits.has(key): portraits[key]=load("res://art/production/phase4e/ui/expressions/"+key+".png")
	return portraits[key]
