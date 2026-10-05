extends SceneTree
const Fit=preload("res://weapon_fit_catalog.gd")
const Stage=preload("res://combat_stage.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("review")
func review() -> void:
	var helper=preload("res://tests/weapon_fit_qa.gd").new()
	helper.game=load("res://main.tscn").instantiate();root.add_child(helper.game);await process_frame
	var g=helper.game
	var actors: Array=preload("res://lootling_catalog.gd").selectable_ids()
	actors.append_array(preload("res://wanderer_catalog.gd").selectable_ids())
	var samples:=0
	var renderer=preload("res://creature_renderer.gd").new()
	for actor in actors:
		for weapon in preload("res://weapon_catalog.gd").live_ids():
			helper.prepare(actor,weapon)
			g.enemy_encounter.active=false;g.enemy_is_boss=false;g.enemy_is_miniboss=false
			g.enemy_name="RAZOR IMP";g.enemy_archetype="skirmisher";g.current_zone_id="outer_ruins"
			for facing in [-1,1]:
				g.forced_facing_test=0;g.player_x=g.target_player_x() if facing>0 else 480-g.target_player_x();g.enemy_stage_x=372 if facing>0 else 108
				for anim in [0.0,.22,.14,.04]:
					g.attack_anim=anim
					var snapshot: Array=[g.player_x,g.enemy_stage_x,g.player_hp,g.enemy_hp,g.attack_clock,g.enemy_attack_clock,g.rng.state,g.loot_system.rng.state,JSON.stringify(g.profile)]
					var pose:=Fit.sample(g)
					var origin:=Fit.world_position(g)
					var bounds:=Stage.transformed_bounds(pose.root,pose.body_rect)
					bounds.position+=origin
					assert(bounds.position.x>=Stage.EDGE-.01 and bounds.end.x<=480-Stage.EDGE+.01,"Full body must remain inside safe horizontal bounds")
					assert(bounds.end.y<600,"Full silhouette/feet need an arena-bottom margin")
					var world_root: Transform2D=pose.root;world_root.origin+=origin
					var held: Array[Transform2D]=[]
					if weapon in ["daggers","claws"]:
						for hand in range(2): held.append(renderer.paired_weapon_transform(g,world_root,pose,hand))
					else: held.append(world_root*Transform2D(pose.weapon_rotation,pose.weapon_scale,0,pose.primary_hand))
					for transform in held:
						var weapon_bounds:=Stage.transformed_bounds(transform,pose.weapon_rect)
						assert(weapon_bounds.position.x>=0 and weapon_bounds.end.x<=480,"Held weapon must fit horizontally: "+actor+"/"+weapon)
						assert(weapon_bounds.position.y>=112 and weapon_bounds.end.y<=620,"Held weapon needs arena margins: "+actor+"/"+weapon)
					assert(absf((origin+pose.root*Vector2(0,pose.feet_baseline)).y-Stage.GROUND_Y)<.01)
					if anim==0:
						var gap: float=absf(origin.x-Stage.enemy_position(g,g.enemy_stage_x).x)-maxf(absf(pose.body_rect.position.x),absf(pose.body_rect.end.x))-Stage.enemy_radius(g)
						assert(gap>=19,"Neutral actor bodies must be separated")
					assert(Fit.projectile_origin(g).distance_to(origin+pose.projectile)<.01,"Projectile must share the real rendered hand/weapon transform")
					assert(g.combat_facing()==facing and g.enemy_facing_at(g.enemy_stage_x)==-facing)
					assert(snapshot==[g.player_x,g.enemy_stage_x,g.player_hp,g.enemy_hp,g.attack_clock,g.enemy_attack_clock,g.rng.state,g.loot_system.rng.state,JSON.stringify(g.profile)],"Staging cannot change simulation/save state")
					samples+=1
	for count in [2,3]:
		helper.prepare("relic_beast","bow");g.enemy_encounter.begin(g,count)
		for index in range(count):
			var point:=Stage.enemy_position(g,g.enemy_encounter.position(index).x)
			assert(g.enemy_encounter.select_at(g,point),"Visible pack actors must remain selectable")
			assert(g.enemy_encounter.selected==index)
		g.enemy_encounter.select(g,0);g.attack_projectiles.clear();g.attack_anim=0
		var sequence: int=g.attack_sequence
		var card:=Vector2(12+(228 if count==2 else 156)+40,g.enemy_encounter.HUD_Y+35)
		var touch:=InputEventScreenTouch.new();touch.index=0;touch.position=g.get_global_transform_with_canvas()*card;touch.pressed=true
		g.touch_ux._input(touch);touch.pressed=false;g.touch_ux._input(touch)
		assert(g.enemy_encounter.selected==1)
		assert(g.attack_sequence==sequence and g.attack_projectiles.is_empty(),"Target HUD tap must never attack")
		g.enemy_encounter.select(g,0)
		var mouse:=InputEventMouseButton.new();mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=true;mouse.position=touch.position
		g._unhandled_input(mouse)
		assert(g.enemy_encounter.selected==1 and g.attack_sequence==sequence and g.attack_projectiles.is_empty(),"Target HUD mouse click must only select")
		g.enemy_encounter.select(g,0);touch.pressed=true;g.touch_ux._input(touch)
		var drag:=InputEventScreenDrag.new();drag.index=0;drag.position=touch.position+Vector2(30,0);g.touch_ux._input(drag)
		touch.pressed=false;touch.position=drag.position;g.touch_ux._input(touch)
		assert(g.enemy_encounter.selected==0 and g.attack_sequence==sequence,"Dragging a target card must not select or attack")
	g.free();helper.free();print("COMBAT STAGING: %d samples across 12 actors/12 weapons/both real facings; neutral clearance, common ground, body margins, rendered launch contact, unchanged state/clocks/RNG; 2/3 pack touch targets" % samples);quit()
