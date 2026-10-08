extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree via isolated native helper; actual attacks and three layouts.
func review() -> void:
	for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
		root.size=viewport;folder="res://.godot_test_data/combat-family/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
		game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
		var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
		for weapon in preload("res://weapon_catalog.gd").live_ids():
			helper.prepare("relic_beast",weapon);game.enemy_entry_anim=0;game.enemy_hp=10000;game.enemy_max_hp=10000;game.enemy_hit_multiplier=1
			game.presentation_director.finish_travel()
			if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
			var hp:float=game.enemy_hp
			game.perform_player_attack(true)
			for tick in range(12):game.update_effects(.02)
			assert(game.enemy_hp<hp or not game.enemy_alive,"Actual weapon attack must resolve")
			game.damage_enemy(7,true,weapon in ["greatsword","maul"],false)
			await capture("weapon_"+weapon)
		helper.prepare("relic_beast","greatsword");game.enemy_entry_anim=0;game.enemy_encounter.begin(game,3)
		game.presentation_director.finish_travel();game.enemy_hp=10000;game.enemy_max_hp=10000
		game.enemy_encounter.select(game,0);game.damage_enemy(9,true,true);var impact:Dictionary=game.combat_presentation.contacts.back().duplicate(true)
		game.enemy_encounter.select(game,2);assert(impact.pos==game.combat_presentation.contacts.back().pos);await capture("pack_contact_target_changed")
		game.enemy_encounter.clear();game.campaign_id="act_i";game.wave=15;game.spawn_enemy();game.enemy_entry_anim=0;game.special_intro_timer=0;game.wave_banner_timer=0;game.presentation_director.finish_travel()
		if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
		game.player_hp=10000;game.player_max_hp=10000;game.enemy_hp=10000;game.enemy_max_hp=10000;game.player_ward=100
		for action in range(6):
			game.enemy_attack_count=action;game.enemy_attack_clock=.12;game.combat_presentation.boss_action_time=0;game.boss_recovery=0
			await capture("boss_windup_%d" % action)
			game.perform_enemy_attack();game.enemy_attack_clock=game.enemy_attack_interval
			await capture("boss_commit_%d" % action)
		game.audio_settings.cinematic_reduced_motion=true;game.damage_enemy(10,true,true,true);await capture("reduced_motion")
		helper.free();game.free();await process_frame
	print("COMBAT FAMILY NATIVE PASS: 12 real weapon attacks, pinned pack contact, six boss action windups/commits, Ward and reduced motion across phone/tablet/desktop");quit()
