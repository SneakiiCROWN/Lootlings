extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through isolated native evidence helper.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	assert(DisplayServer.get_name()!="headless")
	call_deferred("review")
func review() -> void:
	for dimensions in [Vector2i(1080,2340),Vector2i(1600,2560)]:
		root.size=dimensions; game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
		game.app_lifecycle.platform_notifications_enabled=false; game.audio_settings.cinematic_first_time=false
		var helper=preload("res://tests/weapon_fit_qa.gd").new(); helper.game=game
		helper.prepare("gloomlet","staff"); game.campaign_id="mossglass_wilds"; game.wave=15; game.spawn_enemy()
		game.enemy_entry_anim=0; game.special_intro_timer=0; game.forced_facing_test=0; game.player_x=162
		game.presentation_director.toast_queue.clear(); game.presentation_director.active_toast.clear(); game.presentation_director.toast_panel.visible=false
		folder="res://.godot_test_data/phase4e/acceptance-final/%dx%d/" % [dimensions.x,dimensions.y]
		for index in range(4):
			game.player_hp=game.player_max_hp; game.enemy_hp=game.enemy_max_hp; game.boss_phase=1
			game.enemy_attack_count=index; game.enemy_attack_clock=.18; game.boss_recovery=0
			game.attack_clock=10; game.attack_anim=0; game.player_flash=0; game.floating_texts.clear()
			game.combat_presentation.boss_action_time=0
			var action: String=preload("res://boss_patterns.gd").next(game).text
			await capture("verdant_telegraph_%d" % index)
			game.perform_enemy_attack()
			assert(game.combat_presentation.boss_action==action)
			# The real combat loop resets this clock after execution. Keeping it
			# low in frozen fixtures falsely displays the next telegraph at impact.
			game.enemy_attack_clock=game.enemy_attack_interval
			for frame in range(4):
				if frame>0: game._process(.15)
				await capture("verdant_attack_%d_%02d" % [index,frame])
			print("VERDANT_REAL_PROCESS "+JSON.stringify({"action":action,"frames":[0,.15,.30,.45],"forced_facing":game.forced_facing_test,"viewport":str(dimensions)}))
		helper.free(); game.free(); await process_frame
	print("VERDANT NATIVE: predicted/executed action agreement and real effect-clock progression, phone/tablet"); quit()
