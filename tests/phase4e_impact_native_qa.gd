extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through isolated native helper. Element overrides are labelled QA previews.
var baseline_effects: Array=[]
func draw_baseline() -> void:
	# Frozen pre-change drawing routine, QA only. Never swap shipping source files.
	for effect in baseline_effects:
		var ratio:=clampf(float(effect.life)/.24,0,1)
		var color: Color=preload("res://projectile_presentation.gd").COLORS.get(effect.element,Color("#e9bd71")); color.a=ratio
		var radius:=5+(1-ratio)*21
		for i in range(6):
			var d:=Vector2.RIGHT.rotated(TAU*i/6.0+.25)
			game.draw_line(effect.pos+d*radius*.55,effect.pos+d*radius,color,2.0*ratio,true)
		if effect.element!="Physical": game.draw_arc(effect.pos,radius*.8,-.4,4.4,18,color,1.5,true)
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	assert(DisplayServer.get_name()!="headless")
	create_timer(100).timeout.connect(func(): push_error("Impact QA timeout"); quit(1))
	call_deferred("review")
func review() -> void:
	var stage:=OS.get_environment("LOOTLINGS_IMPACT_STAGE")
	assert(stage in ["before","after"])
	for dimensions in [Vector2i(1080,2340),Vector2i(1600,2560)]:
		root.size=dimensions
		game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
		if stage=="before": game.draw.connect(draw_baseline)
		game.app_lifecycle.platform_notifications_enabled=false
		folder="res://.godot_test_data/phase4e/visible-mass-impacts/%s/%dx%d/" % [stage,dimensions.x,dimensions.y]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		var helper=preload("res://tests/weapon_fit_qa.gd").new(); helper.game=game
		for weapon in ["bow","staff","orb","sling"]:
			for side in [-1,1]:
				for element in (["Physical","Fire","Frost","Lightning","Poison","Corruption","Arcane"] if weapon=="bow" else ["Physical" if weapon=="sling" else "Arcane"]):
					seed(40513)
					game.rng.seed=40510; game.loot_system.rng.seed=40511; game.visual_rng.seed=40512
					helper.prepare("ashtrail_hunter",weapon)
					game.enemy_encounter.active=false; game.enemy_entry_anim=0; game.enemy_hp=10000; game.enemy_max_hp=10000
					game.forced_facing_test=0; game.player_x=160 if side==1 else 365; game.enemy_stage_x=340 if side==1 else 140
					game.perform_player_attack(false)
					assert(game.attack_projectiles.size()==1)
					game.attack_projectiles[0].element=element
					game.update_attack_projectiles(game.attack_projectiles[0].max_life+.001)
					assert(game.projectile_impacts.size()==1)
					game.update_attack_projectiles(.075)
					if stage=="before":
						baseline_effects=game.projectile_impacts.duplicate(true); game.projectile_impacts.clear()
					game.presentation_director.toast_queue.clear(); game.presentation_director.active_toast.clear(); game.presentation_director.toast_panel.visible=false
					await capture("%s_%s_%s_QA_element_preview" % [weapon,element.to_lower(),"right" if side==1 else "left"])
					assert(game.combat_facing()==side)
		game.free(); helper.free(); await process_frame
	print("IMPACT NATIVE: 40 actual projectile landings, seven labelled element previews, four weapons, both real target facings, phone/tablet"); quit()
