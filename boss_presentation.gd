extends RefCounted
# Visual-only contract. Reused artwork remains explicitly provisional.
const DRAGON=preload("res://art/sprites/enemies/hoard_dragon.png")
const GROVE=preload("res://art/sprites/lootlings/mosskin_idle.png")
const FURNACE=preload("res://art/sprites/enemies/emberworks_enemies.png")
const VAULT=preload("res://art/sprites/enemies/hoard_depths_enemies.png")
const BRUTE=preload("res://art/sprites/enemies/mossback_brute.png")
const HEXER=preload("res://art/sprites/enemies/lantern_hexer.png")
const KNIGHT=preload("res://art/sprites/enemies/grump_knight.png")
static var active_texture: Texture2D
static var active_path := ""
const PROFILES := {
	"mossglass_wilds":{"texture_path":"res://art/sprites/enemies/beta/verdant_mirror.png","display_size":Vector2(228,278),"flip_h":false,"offset":Vector2(-17,0),"shadow":62.0,"attack_distance":18.0,"entrance_scale":.88,"recoil_limit":.045,"status":"BETA: existing intro tree/root guardian reused; authored combat phases pending"},
	"cinder_crown":{"texture":FURNACE,"source":Rect2(724,0,724,724),"baseline":80.0,"display_size":Vector2(260,260),"flip_h":false,"offset":Vector2(-15,0),"shadow":72.0,"attack_distance":12.0,"entrance_scale":.92,"recoil_limit":.04,"accent":Color("#ff985d"),"motif":"furnace","status":"BETA: approved forge golem proxy; authored Furnace Regent needed"},
	"moonfen":{"texture":VAULT,"source":Rect2(0,0,724,724),"baseline":80.0,"display_size":Vector2(246,246),"flip_h":false,"accent":Color("#94dcf0"),"motif":"lantern","status":"BETA: four-legged vault beast proxy; authored Lantern Jackal needed"},
	"frostbell_hollows":{"texture":BRUTE,"display_size":Vector2(254,170),"accent":Color("#ade9ff"),"motif":"chime","status":"BETA: jawed brute proxy; authored Belljaw needed"},
	"sunken_gearworks":{"texture":VAULT,"source":Rect2(724,0,724,724),"baseline":80.0,"display_size":Vector2(266,266),"accent":Color("#77d6c2"),"motif":"engine","status":"BETA: armoured golem proxy; authored Drowned Engine needed"},
	"starfall_archive":{"texture":HEXER,"display_size":Vector2(202,240),"accent":Color("#dfbcff"),"motif":"script","status":"BETA: caster proxy; authored Redactor needed"},
	"nullglass_expanse":{"texture":KNIGHT,"display_size":Vector2(258,215),"accent":Color("#c7a4ff"),"motif":"mirror","status":"BETA: armoured proxy; authored Unchosen needed"},
	"skyhook_bastion":{"texture":KNIGHT,"display_size":Vector2(250,208),"accent":Color("#a4dfff"),"motif":"chain","status":"BETA: armoured proxy; authored Chainwarden needed"},
	"first_hoard":{"display_size":Vector2(242,229),"accent":Color("#ffe59a"),"motif":"crown","status":"BETA: Hoard Dragon proxy; authored Hollow Crown needed"}
}
static func profile(region: String) -> Dictionary:
	var result: Dictionary={"texture":DRAGON,"source":Rect2(),"facing":"left","flip_h":false,"anchor":Vector2(.5,1),"baseline":66.0,"display_size":Vector2(226,214),"offset":Vector2(-16,0),"shadow":68.0,"entrance_scale":.92,"rotation":0.0,"attack_distance":14.0,"recoil_limit":.045,"status":"BETA: existing left-facing Hoard Dragon fallback; regional body pending"}
	result.merge(PROFILES.get(region,{}),true)
	if not result.has("accent"): result.accent=Color("#cba6ff") if region=="act_i" else Color("#84e8b4")
	if not result.has("motif"): result.motif="crown" if region=="act_i" else "mirror"
	return result
static func texture_for(data: Dictionary) -> Texture2D:
	var texture: Texture2D=data.texture
	if data.has("texture_path"):
		if active_path!=data.texture_path:
			active_path=data.texture_path; active_texture=load(active_path)
		texture=active_texture
	if data.source.size.x>0:
		var crop:=AtlasTexture.new(); crop.atlas=texture; crop.region=data.source; return crop
	return texture
