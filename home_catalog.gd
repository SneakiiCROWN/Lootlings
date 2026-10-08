extends RefCounted
# Exact launch catalogue/anchors from the owner-approved master Home contracts.
# Four accepted furnishings reused unchanged. Missing perch exports stay gated.
const ITEMS := {
  "home_trophy": {
    "display_name": "Trophy stand",
    "classification": "REUSE_EXISTING",
    "asset_path": "art/production/phase4e/props/trophy_dais.png",
    "canvas": [
      287,
      366
    ],
    "pivot_pixel": [
      143.5,
      362
    ],
    "target_size_design": [
      70,
      70
    ],
    "allowed_slots": [
      "home.wall_display"
    ]
  },
  "home_plans": {
    "display_name": "Recovered plans",
    "classification": "REUSE_EXISTING",
    "asset_path": "art/production/phase4e/items/recipe_scroll.png",
    "canvas": [
      243,
      257
    ],
    "pivot_pixel": [
      121.5,
      253
    ],
    "target_size_design": [
      70,
      70
    ],
    "allowed_slots": [
      "home.wall_display"
    ]
  },
  "home_banner": {
    "display_name": "Contract banner",
    "classification": "REUSE_EXISTING",
    "asset_path": "art/production/phase4e/props/contract_banner.png",
    "canvas": [
      188,
      378
    ],
    "pivot_pixel": [
      94.0,
      4
    ],
    "target_size_design": [
      48,
      96
    ],
    "allowed_slots": [
      "home.wall_banner"
    ]
  },
  "home_lantern": {
    "display_name": "Brass lantern",
    "classification": "REUSE_EXISTING",
    "asset_path": "art/production/phase4e/props/brass_torch.png",
    "canvas": [
      175,
      370
    ],
    "pivot_pixel": [
      95.0,
      4
    ],
    "target_size_design": [
      42,
      90
    ],
    "allowed_slots": [
      "home.wall_light"
    ]
  },
  "home_companion_cushion": {
    "display_name": "Companion cushion",
    "classification": "NEEDS_NEW_AUTHORED_ART",
    "asset_path": "art/production/phase4e/props/home_companion_cushion.png",
    "canvas": [
      512,
      256
    ],
    "pivot_pixel": [
      256,
      192
    ],
    "target_size_design": [
      96,
      48
    ],
    "allowed_slots": [
      "home.floor_perch"
    ]
  },
  "home_companion_ledge": {
    "display_name": "Companion ledge",
    "classification": "NEEDS_NEW_AUTHORED_ART",
    "asset_path": "art/production/phase4e/props/home_companion_ledge.png",
    "canvas": [
      512,
      256
    ],
    "pivot_pixel": [
      256,
      128
    ],
    "target_size_design": [
      96,
      48
    ],
    "allowed_slots": [
      "home.wall_perch"
    ]
  }
}
const SLOTS := {
  "home.floor_perch": {
    "mount": "floor",
    "anchor_design": [
      92,
      746
    ],
    "allowed_decor": [
      "home_companion_cushion"
    ],
    "allowed_companions": [
      "auricub",
      "stonekith",
      "pixrask",
      "lunarwisp",
      "puffnest",
      "breezewyn"
    ],
    "sprite_size_design": [
      96,
      48
    ],
    "companion_pivot_design": [
      92,
      746
    ],
    "hit_rect_design": [
      40,
      682,
      100,
      80
    ],
    "facing_default": "right"
  },
  "home.wall_perch": {
    "mount": "wall",
    "anchor_design": [
      374,
      412
    ],
    "allowed_decor": [
      "home_companion_ledge"
    ],
    "allowed_companions": [
      "lunarwisp",
      "breezewyn"
    ],
    "sprite_size_design": [
      96,
      48
    ],
    "companion_pivot_design": [
      374,
      412
    ],
    "hit_rect_design": [
      334,
      356,
      100,
      80
    ],
    "facing_default": "left"
  },
  "home.wall_display": {
    "mount": "display",
    "anchor_design": [
      386,
      337
    ],
    "allowed_decor": [
      "home_trophy",
      "home_plans"
    ],
    "sprite_size_design": [
      70,
      70
    ],
    "hit_rect_design": [
      343,
      255,
      86,
      90
    ]
  },
  "home.wall_banner": {
    "mount": "wall",
    "anchor_design": [
      103,
      181
    ],
    "allowed_decor": [
      "home_banner"
    ],
    "sprite_size_design": [
      48,
      96
    ],
    "hit_rect_design": [
      72,
      181,
      62,
      108
    ]
  },
  "home.wall_light": {
    "mount": "wall",
    "anchor_design": [
      388,
      165
    ],
    "allowed_decor": [
      "home_lantern"
    ],
    "sprite_size_design": [
      42,
      90
    ],
    "hit_rect_design": [
      353,
      154,
      70,
      92
    ]
  }
}
const SLOT_NAMES := {"home.wall_display":"Display shelf","home.wall_banner":"Wall banner","home.wall_light":"Lantern","home.floor_perch":"Floor perch","home.wall_perch":"Wall perch"}
const TEXTURES := {
 "home_trophy":preload("res://art/production/phase4e/props/trophy_dais.png"),
 "home_plans":preload("res://art/production/phase4e/items/recipe_scroll.png"),
 "home_banner":preload("res://art/production/phase4e/props/contract_banner.png"),
 "home_lantern":preload("res://art/production/phase4e/props/brass_torch.png")}
static func defaults(display: String="weapon") -> Dictionary:
	return {"schema_version":1,"placements":{"home.floor_perch":"home_companion_cushion","home.wall_perch":"home_companion_ledge","home.wall_display":"home_plans" if display=="scroll" else "home_trophy" if display=="trophy" else null,"home.wall_banner":"home_banner","home.wall_light":"home_lantern"},"companion_mode":"follow","companion_perch_slot":"home.floor_perch"}
static func available(id: String) -> bool:
	return ITEMS.has(id) and (ITEMS[id].classification=="REUSE_EXISTING" and ResourceLoader.exists("res://"+str(ITEMS[id].asset_path)) or preload("res://home_runtime_art.gd").texture("home_decor:"+id)!=null)
static func sanitize(home: Dictionary, companion_id: String="") -> Dictionary:
	var display: String=str(home.get("display","weapon"))
	if display not in ["weapon","scroll","trophy","none"]:display="weapon"
	var layout: Dictionary=defaults(display)
	var incoming=home.get("home_layout",{})
	if incoming is Dictionary:
		var positions=incoming.get("placements",{})
		if positions is Dictionary:
			for slot in SLOTS:
				if not positions.has(slot):continue
				var id=positions[slot]
				if slot=="home.wall_display" and id==null:layout.placements[slot]=null
				elif id is String and (id.is_empty() or id in SLOTS[slot].allowed_decor):layout.placements[slot]=id
				else:layout.placements[slot]=""
		var perch=incoming.get("companion_perch_slot","home.floor_perch")
		if perch in ["home.floor_perch","home.wall_perch"]:layout.companion_perch_slot=perch
	# Preserve docking only for a complete, owned/equipped canonical companion.
	layout.companion_mode="follow"
	if incoming is Dictionary and incoming.get("companion_mode","")=="perch" and preload("res://companion_catalog.gd").can_perch(companion_id):
		var slot: String=layout.companion_perch_slot
		if companion_id not in SLOTS[slot].allowed_companions:slot="home.floor_perch"
		layout.companion_perch_slot=slot
		var furnishing: String=str(layout.placements.get(slot,""))
		if companion_id in SLOTS[slot].allowed_companions and available(furnishing):layout.companion_mode="perch"
	return {"display":display,"home_layout":layout}
static func texture(id: String) -> Texture2D:
	return TEXTURES.get(id,preload("res://home_runtime_art.gd").texture("home_decor:"+id))
static func draw(canvas: Control, layout: Dictionary) -> void:
	for slot in SLOTS:
		var id=layout.placements.get(slot,"")
		if not id is String or not available(id):continue
		var item: Dictionary=ITEMS[id];var art:=texture(id)
		var extent:=Vector2(item.target_size_design[0],item.target_size_design[1])
		var factor:=minf(extent.x/art.get_width(),extent.y/art.get_height())
		var anchor: Array=SLOTS[slot].anchor_design
		var pivot: Array=item.pivot_pixel
		canvas.draw_texture_rect(art,Rect2(Vector2(anchor[0],anchor[1])-Vector2(pivot[0],pivot[1])*factor,art.get_size()*factor),false)

static func draw_display_shelf(canvas: Control) -> void:
	# The fixed display support reuses the accepted ledge; movable perch is separate.
	var art:=texture("home_companion_ledge")
	if art==null:return
	var factor:=96.0/512.0
	canvas.draw_texture_rect(art,Rect2(Vector2(386,337)-Vector2(256,128)*factor,art.get_size()*factor),false)
static func draw_foreground(canvas: Control,layout: Dictionary) -> void:
	if layout.get("companion_mode","follow")!="perch":return
	for slot in ["home.floor_perch","home.wall_perch"]:
		var id: String=str(layout.placements.get(slot,""))
		if not available(id):continue
		var body:=texture(id)
		var path: String="res://"+str(ITEMS[id].asset_path).replace(".png","_front.png")
		# Retain the registered layer texture across canvas redraws.
		if not ResourceLoader.exists(path):continue
		if not preload("res://home_runtime_art.gd").textures.has(path):preload("res://home_runtime_art.gd").textures[path]=load(path)
		var art: Texture2D=preload("res://home_runtime_art.gd").textures[path]
		var anchor: Array=SLOTS[slot].anchor_design;var pivot: Array=ITEMS[id].pivot_pixel
		var factor:=96.0/512.0
		canvas.draw_texture_rect(art,Rect2(Vector2(anchor[0],anchor[1])-Vector2(pivot[0],pivot[1])*factor,body.get_size()*factor),false)
