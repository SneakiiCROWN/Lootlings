extends SceneTree
const Fit=preload("res://weapon_fit_catalog.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	call_deferred("review")
func review() -> void:
	var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/production/phase4e/runtime_manifest.json"))
	var game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
	var cells:=0
	for row in data.entries:
		var image:=Image.load_from_file(row.asset_path)
		assert(image.get_size()==Vector2i(512,512))
		assert(image.get_pixel(0,0).a==0 and image.get_pixel(511,511).a==0)
		for anchor in [row.primary_anchor,row.secondary_anchor]:
			var pixel:=Vector2i(Vector2(anchor[0],anchor[1])*512)
			assert(image.get_pixelv(pixel).a>.5,"socket not on canonical source silhouette: "+row.actor+"/"+row.phase+"/"+row.facing)
		for weapon in row.weapon_types:
			helper.prepare(row.actor,weapon);game.player_x=game.target_player_x();game.enemy_stage_x=30 if row.facing=="left_only" else 355;game.forced_facing_test=0
			game.attack_clock=.01 if row.phase=="ANTICIPATE" else game.current_attack_interval()
			var rng: int=game.rng.state;var loot_rng: int=game.loot_system.rng.state
			var pose:=Fit.sample(game)
			assert(pose.extracted_pose and not pose.sprite_rig)
			assert(pose.texture.resource_path==row.asset_path and pose.authored_facing==row.facing)
			assert(pose.root.get_scale().is_equal_approx(Vector2.ONE))
			var stage: Vector2=preload("res://combat_stage.gd").player_position(game,pose)
			assert(absf((stage+pose.root*Vector2(0,pose.feet_baseline)).y-preload("res://combat_stage.gd").GROUND_Y)<.01)
			assert(game.rng.state==rng and game.loot_system.rng.state==loot_rng)
			var source_texture: WeakRef = weakref(pose.texture)
			pose = {}
			await process_frame
			assert(source_texture.get_ref()!=null,"extracted texture must outlive canvas RID commands")
			game.player_flash=.1;assert(not Fit.sample(game,true).extracted_pose);game.player_flash=0
			game.player_x+=20;assert(not Fit.sample(game).extracted_pose);game.player_x-=20
			game.perform_player_attack(false);assert(not Fit.sample(game).extracted_pose)
			cells+=1
	assert(cells==35)
	for actor in ["emberhorn","mosskin","moonkip","pebblewyrm","glimmerfin","gloomlet"]:
		for expression in ["happy","cheeky","angry","excited","sad","curious","surprised","determined"]:
			assert(preload("res://phase4e_extracted_art.gd").portrait(actor,expression).get_size()==Vector2(88,86))
	for weapon in preload("res://weapon_catalog.gd").live_ids():
		var held:=preload("res://weapon_catalog.gd").presentation_texture(weapon,"held",load("res://art/sprites/weapons/vanguard_hammer.png"))
		var icon:=preload("res://weapon_catalog.gd").presentation_texture(weapon,"inventory",held)
		assert(icon.resource_path.begins_with("res://art/production/phase4e/weapons/"))
		assert(not held.resource_path.begins_with("res://art/production/phase4e/"))
	game.free();helper.free();print("EXTRACTED ART:35 exact source actor/weapon/state/view cells; alpha sockets, baselines, uniform scale, RNG isolation, movement/hurt/attack restrictions,48 portraits,12 inventory icons; held art preserved");quit()
