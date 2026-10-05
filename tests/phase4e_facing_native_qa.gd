extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through isolated native evidence helper.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	assert(DisplayServer.get_name()!="headless")
	call_deferred("review")

func review() -> void:
	var dimensions:=OS.get_environment("LOOTLINGS_CAPTURE_SIZE").split("x")
	root.size=Vector2i(int(dimensions[0]),int(dimensions[1]))
	game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.app_lifecycle.platform_notifications_enabled=false
	game.audio_settings.cinematic_first_time=false
	folder="res://.godot_test_data/phase4e/target_facing/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var helper=preload("res://tests/weapon_fit_qa.gd").new(); helper.game=game
	var rows: Array=[]
	for weapon in ["greatsword","bow"]:
		helper.prepare("relic_beast",weapon)
		game.enemy_encounter.active=false; game.enemy_entry_anim=0; game.special_intro_timer=0
		game.enemy_is_boss=false; game.enemy_is_miniboss=false; game.enemy_name="RAZOR IMP"; game.enemy_archetype="skirmisher"
		game.forced_facing_test=0; game.enemy_alive=true; game.state="playing"
		for sample in [["player_left",150,365],["player_right",350,105],["player_cross_before",210,250],["player_cross_after",290,250],["enemy_cross_before",240,330],["enemy_cross_after",240,150],["windup",350,105],["attack",350,105],["hit",350,105],["recovery",350,105]]:
			game.player_x=sample[1]; game.enemy_stage_x=sample[2]
			# Deliberately stale legacy flags must not override active targets.
			game.player_facing=-1 if game.enemy_stage_x>game.player_x else 1
			game.attack_clock=.01 if sample[0]=="windup" else game.current_attack_interval()
			game.attack_anim=.22 if sample[0]=="attack" else .06 if sample[0]=="recovery" else 0
			game.player_flash=.15 if sample[0]=="hit" else 0; game.enemy_recoil=8 if sample[0]=="hit" else 0
			game.enemy_attack_anim=.14 if sample[0]=="attack" else 0
			game.presentation_director.toast_queue.clear(); game.presentation_director.active_toast.clear(); game.presentation_director.toast_panel.visible=false
			# Advance the normal game loop, including recovery and position updates.
			# Staging chooses positions, never a facing override.
			game._process(.016)
			var expected: int=1 if game.enemy_stage_x>game.player_x else -1
			assert(game.combat_facing()==expected and game.enemy_facing_at(game.enemy_stage_x)==-expected)
			var pose: Dictionary=preload("res://weapon_fit_catalog.gd").sample(game,game.player_flash>0)
			assert(signf(pose.root.determinant())==expected or pose.authored_facing=="left_only")
			if sample[0]=="attack" and weapon=="bow":
				game.perform_player_attack(false)
				assert(not game.attack_projectiles.is_empty())
				assert(signf(game.attack_projectiles.back().target.x-game.attack_projectiles.back().start.x)==expected)
			await capture(weapon+"_"+sample[0])
			rows.append({"weapon":weapon,"case":sample[0],"player_x":game.player_x,"enemy_x":game.enemy_stage_x,"player_facing":game.combat_facing(),"enemy_facing":game.enemy_facing_at(game.enemy_stage_x),"forced_facing_test":game.forced_facing_test,"body_art":pose.authored_facing,"support_status":pose.support_status})
			game.attack_projectiles.clear()
	var report=FileAccess.open(folder+"report.json",FileAccess.WRITE)
	report.store_string(JSON.stringify({"samples":rows,"note":"Real combat renderer and target resolver, QA-staged positions, no forced-facing override. Crossing is staged because the current game does not expose free lateral movement. Front-facing fallback bodies remain a visual blocker."},"\t"))
	helper.free(); game.free(); print("TARGET FACING: 20 native target-driven combat captures; no forced-facing overrides"); quit()
