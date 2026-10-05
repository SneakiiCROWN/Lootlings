extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through native, isolated evidence helper.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	assert(DisplayServer.get_name()!="headless")
	call_deferred("review")
func review() -> void:
	for dimensions in [Vector2i(1080,2340),Vector2i(1600,2560)]:
		root.size=dimensions; game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
		game.app_lifecycle.platform_notifications_enabled=false
		game.audio_settings.cinematic_first_time=false
		var helper=preload("res://tests/weapon_fit_qa.gd").new(); helper.game=game
		helper.prepare("gloomlet","bow")
		game.enemy_entry_anim=0; game.special_intro_timer=0; game.enemy_encounter.active=false
		game.presentation_director.toast_queue.clear(); game.presentation_director.active_toast.clear(); game.presentation_director.toast_panel.visible=false
		folder="res://.godot_test_data/phase4e/acceptance-final/%dx%d/" % [dimensions.x,dimensions.y]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		for name in preload("res://regional_enemy_presentation.gd").ENTRIES:
			game.enemy_name=name; game.enemy_is_boss=false; game.enemy_is_miniboss=false
			game.enemy_flash=0; game.enemy_recoil=0; game.enemy_squash=0; game.enemy_attack_anim=0
			game.enemy_hp=game.enemy_max_hp; game.attack_anim=0; game.crit_flash=0; game.element_flash=0
			await capture("regional_"+name.to_snake_case().replace(" ","_"))
		for archetype in ["skirmisher","tank","hexer"]:
			game.enemy_archetype=archetype; game.enemy_name={"skirmisher":"MOSSMAW","tank":"LANTERN TOAD","hexer":"DEW HEXER"}[archetype]
			for phase in ["prepare","commit","recover"]:
				game.enemy_attack_clock=.04 if phase=="prepare" else 1
				game.enemy_attack_anim=.16 if phase=="commit" else .04 if phase=="recover" else 0
				await capture("regional_motion_%s_%s" % [archetype,phase])
		game.show_hideout(); game.hideout_ui.show_stash(); await capture("gear")
		game.hideout_ui.visible=false; game.state="result"; game.retention.show_spinner()
		assert(game.retention.panel.visible); await capture("spinner_disabled_state")
		helper.free(); game.free(); await process_frame
	print("REGIONAL NATIVE: 27 refined species plus three attack-role sequences, phone and tablet"); quit()
