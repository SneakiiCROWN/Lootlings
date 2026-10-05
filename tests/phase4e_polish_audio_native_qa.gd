extends "res://tests/phase4e_audio_native_qa.gd"
# extends SceneTree; actual executed boss actions, not direct isolated cue hooks.
func review() -> void:
	assert(DisplayServer.get_name()!="headless")
	folder="res://.godot_test_data/phase4e/polish-audio-actions/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.audio_manager.apply_settings(preload("res://settings_store.gd").defaults())
	game.audio_manager.set_music("OUTER_RUINS")
	for region in preload("res://boss_patterns.gd").PATTERNS:
		for index in range(3):
			game.start_run(); game.set_process(false); game.campaign_id=region; game.wave=15; game.spawn_enemy()
			game.player_hp=game.player_max_hp; game.enemy_entry_anim=0; game.special_intro_timer=0
			game.enemy_attack_count=index; game.boss_phase=1
			var action: String=preload("res://boss_patterns.gd").next(game).text
			print("EXECUTED_AUDIO "+JSON.stringify({"region":region,"action":action,"event":preload("res://boss_audio_identity.gd").event(region,action)}))
			await record("%s_%02d_%s" % [region,index,action.to_snake_case().replace(" ","_")],1.4,func(): game.perform_enemy_attack())
	game.free(); print("BOSS ACTION AUDIO: 30 actual first/second/third actions captured through Master; listening approval remains separate"); quit()
