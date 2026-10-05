extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through the isolated native helper.
# Real resolver, actual attack execution; no forced-facing poses here.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	assert(DisplayServer.get_name()!="headless")
	call_deferred("review")

func clear_toast() -> void:
	game.presentation_director.toast_queue.clear(); game.presentation_director.active_toast.clear(); game.presentation_director.toast_panel.visible=false

func review() -> void:
	for dimensions in [Vector2i(1080,2340),Vector2i(1600,2560)]:
		root.size=dimensions
		game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
		game.app_lifecycle.platform_notifications_enabled=false; game.audio_settings.cinematic_first_time=false
		folder="res://.godot_test_data/phase4e/polish-bosses/%dx%d/" % [dimensions.x,dimensions.y]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game.show_hideout(); game.hideout_ui.scene_time=3; await capture("home_final")
		var helper=preload("res://tests/weapon_fit_qa.gd").new(); helper.game=game
		var regions: Array=["act_i","mossglass_wilds","moonfen","frostbell_hollows","sunken_gearworks","cinder_crown","starfall_archive","nullglass_expanse","skyhook_bastion","first_hoard"]
		if OS.get_environment("LOOTLINGS_4E_FINAL_TOUCHUP")=="1": regions=["moonfen","frostbell_hollows"]
		for region in regions:
			helper.prepare("moonkip","daggers")
			game.campaign_id=region; game.wave=15; game.spawn_enemy()
			game.enemy_entry_anim=0; game.special_intro_timer=0; game.forced_facing_test=0; game.player_x=162
			game.attack_clock=10; game.attack_anim=0; game.enemy_attack_clock=game.enemy_attack_interval
			clear_toast(); await capture(region+"_idle")
			game.enemy_attack_clock=.08; await capture(region+"_windup")
			game.perform_enemy_attack(); game.enemy_attack_clock=game.enemy_attack_interval
			await capture(region+"_commit")
			game._process(.15); await capture(region+"_impact")
			game._process(.20); await capture(region+"_recovery")
			game.enemy_hp=1; game.damage_enemy(2,false,true); await capture(region+"_defeat")
			print("BOSS_POLISH_REAL "+JSON.stringify({"region":region,"name":game.enemy_name,"forced_facing":game.forced_facing_test,"body":preload("res://boss_presentation.gd").profile(region).status,"viewport":str(dimensions)}))
		game.state="result"; game.coins=1000; game.retention.show_spinner()
		for rarity in preload("res://relic_spin_catalog.gd").TIERS:
			var machine=game.retention.machine
			machine.wind_up("item",rarity,false); machine.set_process(false)
			machine.progress=1; machine.stage="anticipation"
			machine.elapsed=machine.reel_seconds+preload("res://relic_spin_catalog.gd").anticipation(rarity)*.75
			machine.queue_redraw(); await capture("final_spinner_"+rarity.to_lower()+"_anticipation")
			game.retention.spin_reward={"kind":"item","rarity":rarity,"amount":1,"display_name":"Gravebloom Staff"}
			game.retention.spin_kind="item"; game.retention.spin_message="FORCED RARITY PREVIEW — no reward granted"
			game.retention.lock_spin(); machine.stage="reveal"; machine.burst=1; machine.queue_redraw()
			await capture("final_spinner_"+rarity.to_lower()+"_reveal")
		machine_stop()
		helper.free(); game.free(); await process_frame
	print("POLISH BOSS NATIVE: selected regions, 6 actual attack/defeat states, phone/tablet"); quit()

func machine_stop() -> void:
	game.retention.machine.stop()
