extends SceneTree
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("review")
func review() -> void:
	var game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.set_process(false); game.audio_settings.cinematic_first_time=false
	game.show_hideout(); var home=game.hideout_ui
	home.request_dialogue("tapped","Salvager"); assert(home.speech_panel.visible)
	home.request_dialogue("tapped","Salvager"); assert(not home.speech_panel.visible)
	home.request_dialogue("tapped","Salvager"); home.request_dialogue("tapped","Archivist"); assert(home.speech_speaker=="Archivist" and home.speech_panel.visible)
	game.navigate_back(); assert(not home.speech_panel.visible and game.state=="hideout")
	home.request_dialogue("tapped","Relic Keeper"); home.show_stash(); assert(not home.speech_panel.visible and not home.stash_detail_panel.visible)
	home.select_entry(0); assert(home.stash_detail_panel.visible); home.close_stash_detail(); assert(not home.stash_detail_panel.visible)
	var history=preload("res://contextual_dialogue.gd").new()
	history.rng.seed=405
	for example in [["Salvager",{"mode":"siege","outcome":"victory"},"mode","siege"],["Salvager",{"weapon":"bow"},"weapon","bow"],["Relic Keeper",{"event":"early_defeat"},"event","early_defeat"]]:
		var found:=false
		for attempt in range(40):
			history.choose(example[0],example[1])
			if history.last_selection.get(example[2],"")==example[3]: found=true; break
		assert(found,"Weighted dialogue must actually expose its matching context")
	var saved: int=game.rng.state; home.request_dialogue("tapped","Archivist"); assert(game.rng.state==saved)
	game.show_hideout(); game.retention.siege=true; game.start_run(); game.set_process(false)
	for round_number in [10,15,20]:
		game.wave=round_number; game.retention.round_rule=game.retention.Catalog.round_rule(round_number,game.retention.rng); game.spawn_enemy()
		assert((game.audio_manager.current_music=="BOSS")==game.enemy_is_boss)
	game.total_kills=20; game.coins=1000; game.end_run(false); game.retention.show_spinner(); game.retention.selected_at=0
	# This checks skippable low-tier delivery; premium outcomes now deliberately
	# retain their full reveal and are covered by relic_spinner_qa.
	var spin_rng:=RandomNumberGenerator.new()
	for seed_value in range(1000):
		spin_rng.seed=seed_value
		if preload("res://relic_spin_catalog.gd").roll(spin_rng).rarity=="COMMON": game.retention.rng.seed=seed_value; break
	game.retention.choose(0); game.retention.selected_at=0; game.retention.choose(0)
	assert(game.retention.progress.data.spins==1 and game.retention.progress.data.spin_wallet==860)
	game.retention.choose(2); assert(not game.retention.spin_busy)
	var reloaded=preload("res://endgame_progress.gd").new(); reloaded.load_progress(); assert(reloaded.data.spins==1 and reloaded.data.pending.is_empty())
	game.free(); print("PHASE4C QA PASS: dialogue toggle/replace/Back/menu, contextual facts/RNG isolation, optional Stash sheet, actual Siege music routing, reveal skip/no double debit/save"); quit()
