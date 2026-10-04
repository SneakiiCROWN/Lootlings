extends SceneTree
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("measure")
func measure() -> void:
	assert(DisplayServer.get_name() != "headless")
	var game = load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.set_process(false); game.audio_manager.apply_settings(preload("res://settings_store.gd").defaults())
	if OS.get_environment("LOOTLINGS_AUDIO_LABEL") == "baseline-complete":
		# Reconstruct only the frozen gain/ceiling settings, using unchanged banks.
		game.audio_manager.music_gain_db = 1.0; game.audio_manager.event_mix_trim = false
		for index in range(AudioServer.get_bus_effect_count(0)):
			var effect := AudioServer.get_bus_effect(0,index)
			if effect is AudioEffectLimiter: effect.ceiling_db = -.8
	var folder := "res://.godot_test_data/humanqa/audio/"+OS.get_environment("LOOTLINGS_AUDIO_LABEL")+"/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	for cue in ["TITLE","HIDEOUT","OUTER_RUINS"]:
		for pool in game.audio_manager.players.values():
			for player in pool: player.stop()
		game.audio_manager.current_music = ""
		game.audio_manager.set_music(cue)
		if cue == "OUTER_RUINS":
			seed(27182); game.rng.seed = 27182; game.start_run(); game.set_process(false)
		await create_timer(.5).timeout
		var capture := AudioEffectCapture.new(); capture.buffer_length = 2
		AudioServer.add_bus_effect(0,capture)
		var samples := PackedVector2Array()
		var start := Time.get_ticks_msec(); var last := start
		var next_tap := start
		while Time.get_ticks_msec()-start < 8000:
			await process_frame
			samples.append_array(capture.get_buffer(capture.get_frames_available()))
			var now := Time.get_ticks_msec()
			if cue == "OUTER_RUINS":
				game._process(minf(.05,(now-last)/1000.0))
				if now >= next_tap: game.request_tap_attack(); next_tap = now+250
			last = now
		samples.append_array(capture.get_buffer(capture.get_frames_available()))
		assert(capture.get_discarded_frames() == 0,"The comparison must retain the complete capture")
		var peak := 0.0; var energy := 0.0
		var pcm := PackedByteArray(); pcm.resize(samples.size()*4)
		for index in range(samples.size()):
			var s := samples[index]; peak = maxf(peak,maxf(absf(s.x),absf(s.y))); energy += s.x*s.x+s.y*s.y
			pcm.encode_s16(index*4,int(clampf(s.x,-1,1)*32767)); pcm.encode_s16(index*4+2,int(clampf(s.y,-1,1)*32767))
		var wav := AudioStreamWAV.new(); wav.format = AudioStreamWAV.FORMAT_16_BITS; wav.mix_rate = AudioServer.get_mix_rate(); wav.stereo = true; wav.data = pcm
		assert(wav.save_to_wav(folder+cue.to_lower()+".wav") == OK)
		assert(samples.size() > 1000 and peak > .001 and peak <= 1)
		print("HUMAN_AUDIO "+JSON.stringify({"cue":cue,"frames":samples.size(),"mix_rate":AudioServer.get_mix_rate(),"discarded":capture.get_discarded_frames(),"peak_dbfs":linear_to_db(peak),"rms_dbfs":linear_to_db(sqrt(energy/(samples.size()*2.0))),"settings":preload("res://settings_store.gd").defaults(),"qualification":"Complete equal-default native Master capture; RMS is not LUFS; source levels cannot prove phone recording volume."}))
		AudioServer.remove_bus_effect(0,AudioServer.get_bus_effect_count(0)-1)
	game.free(); quit()
