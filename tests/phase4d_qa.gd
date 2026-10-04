extends SceneTree
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("review")
func review() -> void:
	var game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.set_process(false); game.audio_settings.cinematic_first_time=false; game.show_hideout()
	var run_rng: int=game.rng.state; var loot_rng: int=game.loot_system.rng.state
	for speaker in ["vault_runner","ruin_warden","nightstage_drifter","velvet_astrologer","ashtrail_hunter"]:
		var dialogue=preload("res://contextual_dialogue.gd").new()
		var first: String=dialogue.choose(speaker,{})
		assert(first!=dialogue.choose(speaker,{}))
	for region in game.campaign.ORDER:
		game.campaign_id=region; game.enemy_is_boss=true
		var voice: String=preload("res://voice_identity.gd").enemy(game)
		assert(voice in preload("res://voice_identity.gd").PROFILES)
		for role in ["attack","hurt","death"]: assert(not preload("res://audio_manager.gd").production_event_streams("voice_"+voice+"_"+role).is_empty())
	game.campaign_id="act_i"; game.enemy_is_boss=false
	game.hideout_ui.show_phase4("archive")
	for button in game.hideout_ui.phase4_list.get_children():
		for child in button.get_children():
			if child is Control: assert(child.mouse_filter==Control.MOUSE_FILTER_IGNORE)
	assert(game.rng.state==run_rng and game.loot_system.rng.state==loot_rng)
	var audio=preload("res://audio_manager.gd")
	for cue in ["home_bench","home_page"]: assert(audio.production_event_streams(cue).size()==1)
	var bar=preload("res://relic_chase_meter.gd").new(); root.add_child(bar); bar.size=Vector2(376,8); await process_frame; assert(bar.size.y==8); bar.free()
	game.free(); print("PHASE4D QA PASS: presentation RNG isolation, distinct rotating human voices, boss body/voice banks, decorative touch transparency, thin chase meter and licensed Home source aliases"); quit()
