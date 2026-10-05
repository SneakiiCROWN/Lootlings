extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through the isolated native evidence helper.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	assert(DisplayServer.get_name()!="headless")
	OS.set_environment("LOOTLINGS_MOBILE_TEST","1")
	create_timer(300).timeout.connect(func(): push_error("Phase4E native timeout"); quit(1))
	call_deferred("review")

func review() -> void:
	var stage:=OS.get_environment("LOOTLINGS_4E_STAGE")
	if stage.is_empty(): stage="before"
	var dimensions:=OS.get_environment("LOOTLINGS_CAPTURE_SIZE").split("x")
	root.size=Vector2i(int(dimensions[0]),int(dimensions[1]))
	game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.set_process(false); game.audio_settings.cinematic_first_time=false; game.app_lifecycle.platform_notifications_enabled=false
	folder="res://.godot_test_data/phase4e/%s/%s/" % [stage,OS.get_environment("LOOTLINGS_CAPTURE_SIZE")]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	game.show_hideout(); await capture("home")
	for clock in [3.0,28.0,56.0,84.0]:
		game.hideout_ui.scene_time=clock; await capture("home_activity_%03d" % clock)
	for speaker in ["Salvager","Archivist","Relic Keeper"]:
		game.hideout_ui.request_dialogue("tapped",speaker); await capture(speaker.to_snake_case()); game.hideout_ui.dismiss_dialogue()
	for sample in [
		["returning","Salvager",{"event":"returning"}],
		["victory","Relic Keeper",{"outcome":"victory"}],
		["defeat","Salvager",{"event":"early_defeat","outcome":"defeat"}],
		["boss","Archivist",{"region":"mossglass_wilds","outcome":"victory"}],
		["weapon","Salvager",{"weapon":"bow"}],
		["loot","Relic Keeper",{"event":"red_find"}],
		["easter","Archivist",{}],
		["secret","Archivist",{"event":"archive_discovery"}]]:
		# Each category preview starts a fresh isolated presentation director;
		# earlier sampled rare lines must not consume later preview cooldowns.
		game.hideout_ui.home_dialogue=preload("res://contextual_dialogue.gd").new()
		game.hideout_ui.home_dialogue.rng.seed=40205
		var found:=false
		for attempt in range(100):
			game.hideout_ui.home_dialogue.recent.clear()
			var text: String=game.hideout_ui.home_dialogue.choose(sample[1],sample[2])
			var chosen: Dictionary=game.hideout_ui.home_dialogue.last_selection
			var target: String="gameplay" if sample[0]=="weapon" else "easter" if sample[0]=="easter" else "secret" if sample[0]=="secret" else "context"
			if chosen.category!=target: continue
			game.hideout_ui.request_dialogue("tapped",sample[1])
			game.hideout_ui.speech_label.text=preload("res://world_story.gd").SPEAKERS[sample[1]]+"\n"+text
			game.hideout_ui.speech_panel.visible=true; game.hideout_ui.speech_speaker=sample[1]
			await capture("dialogue_"+sample[0]); print("DIALOGUE_NATIVE "+JSON.stringify({"sample":sample[0],"selection":chosen,"facts":sample[2]})); found=true; break
		assert(found,"Native dialogue must find an eligible authored example: "+sample[0])
		game.hideout_ui.dismiss_dialogue()
	game.hideout_ui.show_stash(); await capture("gear")
	game.show_hideout(); game.retention.show_modes(); await capture("siege")
	game.show_hideout(); game.retention.show_modes("dungeons"); await capture("dungeon")
	game.retention.panel.visible=false; game.hideout_ui.visible=false; game.startup_ui.visible=false
	var helper=preload("res://tests/weapon_fit_qa.gd").new(); helper.game=game
	for weapon in ["staff","bow","daggers","claws","greatsword","sling","maul","spear","crossbow","greataxe","wand","orb"]:
		helper.prepare("gloomlet",weapon); game.attack_projectiles.clear()
		for facing in ([1,-1] if weapon in ["bow","daggers","claws"] else [1]):
			game.player_facing=facing; game.forced_facing_test=facing
			for frame in range(6):
				game.attack_anim=[0.0,0.0,.22,.14,.06,0.0][frame]
				game.attack_clock=[game.current_attack_interval(),.01,game.current_attack_interval(),game.current_attack_interval(),game.current_attack_interval(),game.current_attack_interval()][frame]
				await capture("%s_%s_%02d" % [weapon,"right" if facing==1 else "left",frame])
	game.player_facing=1; game.forced_facing_test=0; game.enemy_name="GLASSWING"; game.enemy_archetype="tank"; await capture("glasswing")
	game.damage_enemy(1,true,false); await capture("enemy_hit")
	for name in preload("res://regional_enemy_presentation.gd").ENTRIES:
		clear_effects()
		game.enemy_is_boss=false; game.enemy_is_miniboss=false; game.enemy_name=name; game.enemy_recoil=0; game.enemy_flash=0; game.enemy_squash=0; game.attack_anim=0; game.attack_clock=game.current_attack_interval()
		await capture("regional_"+name.to_snake_case().replace(" ","_"))
	for identity in ["Fire","Frost","Lightning","Poison","Arcane","Corruption"]:
		clear_effects()
		game.element_flash_identity=identity; game.element_flash=.21; await capture("impact_"+identity.to_lower())
	game.element_flash=0
	clear_effects()
	game.campaign_id="mossglass_wilds"; game.wave=15; game.spawn_enemy(); game.enemy_entry_anim=0; game.special_intro_timer=0; game.state="playing"; clear_toast()
	await capture("verdant_body")
	game.presentation_director.vignette.play(preload("res://vignette_catalog.gd").entry("boss/verdant_mirror"),game.audio_settings,"preview")
	await capture("verdant_intro"); game.presentation_director.vignette.finish()
	for index in [0,1,2,3]:
		game.enemy_attack_count=index; game.enemy_attack_clock=.18; game.boss_recovery=.6 if index==3 else 0; await capture("verdant_telegraph_%d" % index)
		game.perform_enemy_attack()
		game.enemy_attack_clock=game.enemy_attack_interval
		for frame in range(4):
			game.combat_presentation.boss_action_time=maxf(.01,.55-frame*.15); game.boss_recovery=maxf(0,game.boss_recovery-.15)
			await capture("verdant_attack_%d_%02d" % [index,frame])
	game.enemy_hp=1; game.damage_enemy(2,true,true); await capture("verdant_death")
	game.state="result"; game.coins=1000; game.retention.show_spinner(); await capture("spinner_start")
	game.retention.pool_panel.visible=true; await capture("spinner_pool"); game.retention.pool_panel.visible=false
	for rarity in ["COMMON","UNCOMMON","RARE","EPIC","LEGENDARY","RED"]:
		var machine=game.retention.machine; machine.wind_up("item" if rarity=="RED" else "material",rarity,false); machine.set_process(false)
		for frame in range(6):
			machine.elapsed=frame*.25; machine.progress=minf(1,machine.elapsed/machine.reel_seconds); machine.stage="rolling"; machine.queue_redraw()
			await capture("spinner_%s_motion_%02d" % [rarity.to_lower(),frame])
		machine.stage="anticipation"; machine.elapsed=machine.reel_seconds+preload("res://relic_spin_catalog.gd").anticipation(rarity)*.75; machine.progress=1; machine.queue_redraw(); await capture("spinner_%s_anticipation" % rarity.to_lower())
		game.retention.spin_reward={"kind":"item" if rarity=="RED" else "material","rarity":rarity,"amount":1 if rarity=="RED" else 2,"display_name":"Gravebloom Staff" if rarity=="RED" else "Local materials"}; game.retention.spin_kind="item" if rarity=="RED" else "material"; game.retention.spin_message="DEV VISUAL PREVIEW - no reward granted"; game.retention.lock_spin(); machine.stage="reveal"; machine.burst=1; machine.queue_redraw(); await capture("spinner_%s_reveal" % rarity.to_lower())
	game.retention.machine.stop(); game.retention.panel.visible=false; game.retention.dimmer.visible=false
	game.show_hideout(); await sample_performance("phase4e_home",false)
	helper.prepare("gloomlet","bow"); await sample_performance("phase4e_bow")
	game.free(); helper.free(); print("PHASE4E NATIVE PASS "+stage); quit()

func clear_toast() -> void:
	game.presentation_director.toast_queue.clear(); game.presentation_director.active_toast.clear(); game.presentation_director.toast_panel.visible=false

func clear_effects() -> void:
	game.crit_flash=0; game.element_flash=0; game.enemy_flash=0; game.floating_texts.clear(); game.particles.clear(); game.impact_flash=0; game.death_burst=0
