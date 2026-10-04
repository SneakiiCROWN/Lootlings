extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through guarded native helpers.
func review() -> void:
	root.size=Vector2i(1080,2316); game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.app_lifecycle.platform_notifications_enabled=false; game.audio_settings.cinematic_first_time=false
	folder="res://.godot_test_data/phase4c/bosses/"; DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	game.start_run(); game.set_process(false); game.wave=15; game.player_x=game.target_player_x()
	for region in game.campaign.ORDER:
		game.campaign_id=region; game.spawn_enemy(); game.wave_banner_timer=0; game.enemy_entry_anim=0; game.special_intro_timer=0; game.state="playing"
		game.presentation_director.toast_panel.visible=false; game.enemy_attack_anim=0; await capture(region+"_idle")
		game.enemy_attack_anim=.28; game.enemy_flash=.08; await capture(region+"_attack")
		assert(game.enemy_is_boss and preload("res://boss_presentation.gd").profile(region).texture!=null)
	game.campaign_id="act_i"; game.wave=1; game.spawn_enemy(); game.enemy_entry_anim=0; game.special_intro_timer=0; game.enemy_attack_anim=0; game.enemy_flash=0; game.wave_banner_timer=0
	var helper=preload("res://tests/weapon_fit_qa.gd").new(); helper.game=game
	for facing in [1,-1]:
		helper.prepare("relic_beast","bow"); game.player_facing=facing; game.enemy_entry_anim=0; game.wave_banner_timer=0
		game.attack_anim=0; game.attack_clock=.02; await capture("bow_%s_draw" % facing)
		game.perform_player_attack(false); assert(not game.attack_projectiles.is_empty()); game.update_attack_projectiles(.035); game.attack_anim=.22; await capture("bow_%s_fire" % facing)
		game.attack_anim=.06; await capture("bow_%s_recovery" % facing)
	helper.free(); await sample_performance("combat"); game.wave=15; game.spawn_enemy(); game.enemy_entry_anim=0; await sample_performance("boss")
	game.free(); print("PHASE4C BOSS NATIVE PASS: ten regional contracts idle/attack and bow draw/fire/recovery both facings"); quit()
