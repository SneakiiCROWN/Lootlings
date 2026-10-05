extends RefCounted
# Visual-only contract. Reused artwork remains explicitly provisional.
const DRAGON=preload("res://art/sprites/enemies/hoard_dragon.png")
const VAULT=preload("res://art/sprites/enemies/hoard_depths_enemies.png")
const HEXER=preload("res://art/sprites/enemies/lantern_hexer.png")
const KNIGHT=preload("res://art/sprites/enemies/grump_knight.png")
static var active_texture: Texture2D
static var active_path := ""
const PROFILES := {
	"mossglass_wilds":{"texture_path":"res://art/sprites/enemies/beta/verdant_mirror.png","display_size":Vector2(228,278),"flip_h":false,"offset":Vector2(-17,0),"shadow":62.0,"attack_distance":18.0,"entrance_scale":.88,"recoil_limit":.045,"status":"BETA: existing intro tree/root guardian reused; authored combat phases pending"},
	"cinder_crown":{"texture_path":"res://art/sprites/enemies/beta/furnace_regent.png","display_size":Vector2(258,258),"flip_h":false,"offset":Vector2(-15,0),"shadow":72.0,"attack_distance":12.0,"entrance_scale":.92,"recoil_limit":.04,"accent":Color("#ff985d"),"motif":"furnace","status":"Existing Furnace Regent intro identity; articulated combat phases pending"},
	"moonfen":{"texture_path":"res://art/sprites/enemies/beta/lantern_jackal.svg","anchor":Vector2(.5,.885),"display_size":Vector2(248,248),"accent":Color("#94dcf0"),"motif":"lantern","status":"TEMP: procedural lantern-jackal rig prototype, not canonical body art"},
	"frostbell_hollows":{"texture_path":"res://art/sprites/enemies/beta/belljaw.svg","anchor":Vector2(.5,.885),"display_size":Vector2(264,264),"accent":Color("#ade9ff"),"motif":"chime","status":"TEMP: procedural frost/chime rig prototype, not canonical body art"},
	"sunken_gearworks":{"texture":VAULT,"source":Rect2(724,0,724,724),"baseline":80.0,"display_size":Vector2(266,266),"accent":Color("#77d6c2"),"motif":"engine","status":"BETA: armoured golem proxy; authored Drowned Engine needed"},
	"starfall_archive":{"texture":HEXER,"display_size":Vector2(202,240),"accent":Color("#dfbcff"),"motif":"script","status":"BETA: caster proxy; authored Redactor needed"},
	"nullglass_expanse":{"texture":KNIGHT,"display_size":Vector2(258,215),"accent":Color("#c7a4ff"),"motif":"mirror","status":"BETA: armoured proxy; authored Unchosen needed"},
	"skyhook_bastion":{"texture":KNIGHT,"display_size":Vector2(250,208),"accent":Color("#a4dfff"),"motif":"chain","status":"BETA: armoured proxy; authored Chainwarden needed"},
	"first_hoard":{"display_size":Vector2(242,229),"accent":Color("#ffe59a"),"motif":"crown","status":"BETA: Hoard Dragon proxy; authored Hollow Crown needed"}
}
static func profile(region: String) -> Dictionary:
	var result: Dictionary={"texture":DRAGON,"source":Rect2(),"facing":"left","flip_h":false,"anchor":Vector2(.5,1),"baseline":66.0,"display_size":Vector2(226,214),"offset":Vector2(-16,0),"shadow":68.0,"entrance_scale":.92,"rotation":0.0,"attack_distance":14.0,"recoil_limit":.045,"status":"TEMP: Hoard Dragon source tail is malformed; canonical redraw required, transforms are not a repair"}
	result.merge(PROFILES.get(region,{}),true)
	if not result.has("accent"): result.accent=Color("#cba6ff") if region=="act_i" else Color("#84e8b4")
	if not result.has("motif"): result.motif="crown" if region=="act_i" else "mirror"
	# Do not add rectangle distortion to the existing TEMP dragon source.
	# This preserves its pixels' proportions; the defective tail still needs redraw.
	result.preserve_aspect=region in ["act_i","first_hoard"]
	return result

static func display_rect(data: Dictionary, texture: Texture2D) -> Rect2:
	var size: Vector2=data.display_size
	if data.get("preserve_aspect",false):
		var source: Vector2=Vector2(texture.get_size())
		if source.x>0 and source.y>0: size=source*minf(size.x/source.x,size.y/source.y)
	return Rect2(-size*Vector2(data.anchor)+Vector2(0,float(data.baseline)),size)
static func profile_for(g) -> Dictionary:
	var result:=profile(g.campaign_id)
	var state: Dictionary=preload("res://boss_art_manifest.gd").state_for(g)
	var facing: int=g.enemy_facing_at(g.enemy_stage_x)
	var frame: Dictionary=preload("res://boss_art_manifest.gd").select_frame(g.campaign_id,state.state,state.action,facing)
	if frame.is_empty(): return result
	# Existing renderer mirrors a left source. Cancel that mirror for explicit
	# right exports; keep left anatomy unmirrored and preserve the current clocks.
	result.texture_path=frame.asset_path
	result.source=Rect2()
	result.anchor=Vector2(frame.anchor[0],frame.anchor[1])
	result.flip_h=facing>0
	result.preserve_aspect=true
	result.authored_state=state.state
	result.status="Owner-approved canonical export; visual acceptance remains scoped"
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

static func motion(g, preparation: float, direction: int) -> Dictionary:
	var active: float=clampf(g.combat_presentation.boss_action_time/.55,0,1)
	var commit: float=sin((1-active)*PI) if active>0 else 0
	var action: String=g.combat_presentation.boss_action if active>0 else str(preload("res://boss_patterns.gd").next(g).text)
	var offset:=Vector2.ZERO
	var tilt:=0.0
	var scale:=Vector2.ONE
	if action in ["RECOVER","COOLING"] or g.boss_recovery>0:
		offset.y=5; tilt=direction*-.04; scale=Vector2(1.025,.975)
	elif action in ["POUNCE","BITE","LANTERN BITE","CLAWS","HOOK"]:
		offset=Vector2(direction*(-preparation*8+commit*16),-commit*11)
		tilt=direction*(-preparation*.055+commit*.11)
		scale=Vector2(1+commit*.04,1-preparation*.06)
	elif "SWEEP" in action or action in ["PAGE CUT","GLASS CUT","TAIL SWEEP"]:
		tilt=direction*(-preparation*.07+commit*.09)
		scale=Vector2(1+commit*.045,1-commit*.025)
	elif action in ["HAMMER","PISTON","BELL STRIKE","ANCHOR SLAM","CROWN STRIKE"]:
		offset.y=-preparation*9+commit*6
		tilt=direction*(-preparation*.055+commit*.08)
		scale=Vector2(1+commit*.025,1-commit*.035)
	elif "BREATH" in action or action in ["STEAM VENT","TRIBUTE FLARE","ERASE","SHATTER"]:
		offset.x=direction*(preparation*3-commit*7)
		tilt=direction*(preparation*.025-commit*.055)
		scale=Vector2(1+preparation*.02,1+preparation*.025)
	else:
		offset.y=-preparation*5
		tilt=direction*(-preparation*.025+commit*.04)
	return {"offset":offset,"tilt":tilt,"scale":scale}

static func draw_identity(g, pos: Vector2, factor: float) -> void:
	# Original bounded props give fitting older bodies a regional silhouette.
	# These are presentation attachments, not a claim of new painted body art.
	g.draw_set_transform(pos,0,Vector2(-g.enemy_facing_at(pos.x),1)*factor)
	match g.campaign_id:
		"skyhook_bastion":
			for link in range(8):
				var point:=Vector2(55-link*14,-68+link*12)
				point.x+=sin(g.run_time*3+link*.3)*2
				g.draw_arc(point,6,0,TAU,12,Color("#a2bec9"),3,true)
			g.draw_polyline(PackedVector2Array([Vector2(-44,24),Vector2(-53,39),Vector2(-72,39),Vector2(-77,22),Vector2(-63,13)]),Color("#bfd9e1"),7,true)
		"nullglass_expanse":
			var points:=PackedVector2Array([Vector2(39,-146),Vector2(94,-66),Vector2(58,31),Vector2(16,-61),Vector2(39,-146)])
			g.draw_colored_polygon(points,Color("#342f5766")); g.draw_polyline(points,Color("#b7a1e5"),4,true)
			g.draw_polyline(PackedVector2Array([Vector2(40,-133),Vector2(50,-77),Vector2(36,-47),Vector2(60,9)]),Color("#cfe3fa"),2,true)
		"sunken_gearworks":
			g.draw_polyline(PackedVector2Array([Vector2(48,-35),Vector2(63,-87),Vector2(50,-100),Vector2(51,-132)]),Color("#8c9f9a"),11,true)
			g.draw_line(Vector2(43,-132),Vector2(59,-132),Color("#c3cab1"),5,true)
			for steam in range(3):
				var t:=fmod(g.run_time*.65+steam*.31,1)
				g.draw_circle(Vector2(51+t*10,-138-t*25),3+t*4,Color("#b7e8e3",(1-t)*.28))
		"starfall_archive":
			for page in range(4):
				var point:=Vector2(39+page*10,-97+page*20+sin(g.run_time*2+page)*4)
				g.draw_colored_polygon(PackedVector2Array([point,point+Vector2(26,-6),point+Vector2(30,23),point+Vector2(4,29)]),Color("#d9c6a7"))
				for line in range(3): g.draw_line(point+Vector2(6,5+line*5),point+Vector2(22,1+line*5),Color("#695375"),1.5,true)
		"first_hoard":
			var point:=Vector2(-17,-117+sin(g.run_time*1.3)*3)
			g.draw_polyline(PackedVector2Array([point+Vector2(-32,18),point+Vector2(-38,-12),point+Vector2(-13,1),point+Vector2(0,-20),point+Vector2(14,1),point+Vector2(37,-12),point+Vector2(30,18)]),Color("#e7c975"),7,true)
			g.draw_line(point+Vector2(-27,25),point+Vector2(-3,25),Color("#b7955b"),4,true)
			g.draw_line(point+Vector2(7,25),point+Vector2(28,25),Color("#b7955b"),4,true)
	g.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
