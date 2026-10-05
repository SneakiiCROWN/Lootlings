extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through isolated native helper. Existing source is TEMP.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	assert(DisplayServer.get_name()!="headless")
	call_deferred("review")

func review() -> void:
	root.size=Vector2i(1080,2340)
	game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.app_lifecycle.platform_notifications_enabled=false
	game.audio_settings.cinematic_first_time=false
	var helper=preload("res://tests/weapon_fit_qa.gd").new(); helper.game=game
	var stage: String=OS.get_environment("LOOTLINGS_4E_INTEGRITY_STAGE")
	assert(not stage.is_empty(),"Separate before/after evidence folders are required")
	folder="res://.godot_test_data/phase4e/dragon-integrity/"+stage+"/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var rows: Array=[]
	for facing in [-1,1]:
		helper.prepare("relic_beast","greatsword")
		game.campaign_id="act_i"; game.wave=15; game.spawn_enemy()
		game.enemy_encounter.active=false; game.enemy_entry_anim=0; game.special_intro_timer=0
		game.forced_facing_test=0; game.player_hp=game.player_max_hp
		game.player_x=160 if facing<0 else 355
		game.enemy_stage_x=365 if facing<0 else 140
		game.attack_clock=10; game.enemy_attack_clock=game.enemy_attack_interval
		game.presentation_director.toast_queue.clear(); game.presentation_director.active_toast.clear(); game.presentation_director.toast_panel.visible=false
		for phase in ["idle","windup","attack","tail_sweep","hurt","recovery","defeat"]:
			game.enemy_flash=0; game.enemy_recoil=0; game.enemy_squash=0; game.enemy_attack_anim=0; game.boss_recovery=0
			game.enemy_attack_clock=.05 if phase=="windup" else game.enemy_attack_interval
			game.combat_presentation.boss_action_time=0
			if phase in ["attack","tail_sweep"]:
				game.enemy_attack_count=4 if phase=="tail_sweep" else 0
				game.perform_enemy_attack()
			if phase=="hurt": game.damage_enemy(1,false,true)
			if phase=="recovery": game.boss_recovery=.5
			if phase=="defeat": game.enemy_hp=1; game.damage_enemy(2,false,true)
			assert(game.forced_facing_test==0)
			assert(game.enemy_facing_at(game.enemy_stage_x)==facing)
			await capture(("left_" if facing<0 else "right_")+phase)
			var profile: Dictionary=preload("res://boss_presentation.gd").profile("act_i")
			rows.append({"stage":stage,"phase":phase,"enemy_facing":facing,"player_facing":game.combat_facing(),"forced_facing_test":0,"display_bounds":str(profile.display_size),"preserve_source_aspect":profile.get("preserve_aspect",false),"source_tail_repaired":false})
	var report=FileAccess.open(folder+"report.json",FileAccess.WRITE)
	report.store_string(JSON.stringify({"samples":rows,"note":"Native real target resolver with QA-staged positions. Rendering proportions only; malformed source tail remains unresolved TEMP art."},"\t"))
	helper.free(); game.free(); print("DRAGON INTEGRITY: both real facings, idle/windup/attack/tail/hurt/recovery/defeat; source tail NOT repaired"); quit()
