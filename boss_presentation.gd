extends RefCounted
# Visual-only contract. Reused artwork remains explicitly provisional.
const DRAGON=preload("res://art/sprites/enemies/hoard_dragon.png")
const GROVE=preload("res://art/sprites/lootlings/mosskin_idle.png")
const FURNACE=preload("res://art/sprites/enemies/beta/furnace_regent.png")
const PROFILES := {
	"mossglass_wilds":{"texture":GROVE,"display_size":Vector2(210,230),"flip_h":true,"offset":Vector2(-17,0),"shadow":62.0,"attack_distance":18.0,"entrance_scale":.88,"recoil_limit":.045,"status":"BETA: clean Mosskin guardian reuse; unique Verdant Mirror body pending"},
	"cinder_crown":{"texture":FURNACE,"display_size":Vector2(222,236),"flip_h":false,"offset":Vector2(-15,0),"shadow":72.0,"attack_distance":12.0,"entrance_scale":.92,"recoil_limit":.04,"status":"BETA: frontal Furnace Regent; final silhouette pending"}
}
static func profile(region: String) -> Dictionary:
	var result: Dictionary={"texture":DRAGON,"source":Rect2(),"facing":"left","flip_h":false,"anchor":Vector2(.5,1),"baseline":66.0,"display_size":Vector2(226,214),"offset":Vector2(-16,0),"shadow":68.0,"entrance_scale":.92,"rotation":0.0,"attack_distance":14.0,"recoil_limit":.045,"status":"BETA: existing left-facing Hoard Dragon fallback; regional body pending"}
	result.merge(PROFILES.get(region,{}),true)
	return result
static func texture_for(data: Dictionary) -> Texture2D:
	var texture: Texture2D=data.texture
	if data.source.size.x>0:
		var crop:=AtlasTexture.new(); crop.atlas=texture; crop.region=data.source; return crop
	return texture
