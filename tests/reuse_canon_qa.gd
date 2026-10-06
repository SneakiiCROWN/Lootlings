extends SceneTree
const Fit=preload("res://weapon_fit_catalog.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	call_deferred("review")
func review() -> void:
	var game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	game.set_process(false)
	var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
	var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/production/phase4e/reuse_manifest.json"))
	var count:=0
	for row in data.entries:
		for weapon in row.weapon_types:
			helper.prepare(row.actor,weapon);game.enemy_stage_x=355;game.forced_facing_test=0
			var rng: int=game.rng.state;var loot_rng: int=game.loot_system.rng.state
			var pose:=Fit.sample(game)
			assert(pose.extracted_idle and not pose.sprite_rig and pose.texture.resource_path==row.asset_path)
			assert(pose.root.get_scale().is_equal_approx(Vector2.ONE))
			assert(pose.primary_hand.distance_to(Vector2(row.body_rect[0],row.body_rect[1])+Vector2(row.primary_anchor[0],row.primary_anchor[1])*Vector2(row.body_rect[2],row.body_rect[3]))<.01)
			assert(game.rng.state==rng and game.loot_system.rng.state==loot_rng)
			game.enemy_stage_x=30;assert(Fit.sample(game).sprite_rig,"Never mirror asymmetric canonical source")
			game.enemy_stage_x=355;game.player_x+=20;assert(Fit.sample(game).sprite_rig)
			game.player_x-=20;assert(Fit.sample(game,true).sprite_rig)
			game.perform_player_attack(false);assert(not Fit.sample(game).extracted_idle,"Neutral source cannot fake attack")
			count+=1
	assert(count==25)
	game.free();helper.free();print("REUSE CANON:25 unchanged Wanderer neutral cells; target facing, real palm sockets, uniform scale, RNG unchanged, movement/hurt/attack/left remain TEMP");quit()
