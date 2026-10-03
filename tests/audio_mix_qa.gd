extends SceneTree

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("run_audio_qa")

func run_audio_qa() -> void:
	var packed := load("res://main.tscn") as PackedScene
	if packed == null:
		push_error("AUDIO QA: main scene unavailable")
		quit(1)
		return
	var game = packed.instantiate()
	root.add_child(game)
	for frame in range(8):
		await process_frame
	game.set_process(false)
	var pcm_bytes := 0
	for event in game.audio_manager.EVENT_SPECS:
		var bank: Array = game.audio_manager.production_event_streams(event)
		assert(bank.size() == game.audio_manager.variant_count(event))
		for clip in bank: pcm_bytes += clip.data.size()
	for weapon in preload("res://weapon_catalog.gd").live_ids():
		game.inventory.reset_to_starter()
		game.inventory.equip(game.ItemCatalog.create_item(preload("res://tests/evolution_qa.gd").base_id(weapon),"COMMON",80))
		game.start_run()
		game.set_process(false)
		game.player_x = game.target_player_x()
		for player in game.audio_manager.players["SFX"]: player.stop()
		game.perform_player_attack(false)
		assert(game.audio_manager.event_sequence.get("swing_"+weapon,0) > 0,"Live weapon sound hook: "+weapon)
	# Measure the shipped defaults, not whatever mute/volume state a previous
	# local QA session persisted in this isolated test profile.
	game.audio_manager.apply_settings({"master":0.90, "music":0.58, "sfx":0.92, "ui":0.84, "ambience":0.62, "master_muted":false, "music_muted":false, "sfx_muted":false, "ui_muted":false, "ambience_muted":false})
	var master_index := AudioServer.get_bus_index("Master")
	var capture := AudioEffectCapture.new()
	capture.buffer_length = 12.0
	AudioServer.add_bus_effect(master_index, capture, AudioServer.get_bus_effect_count(master_index))
	game.audio_manager.set_music("OUTER_RUINS")
	var sequence := ["swing_greatsword", "swing_greataxe", "swing_maul", "swing_spear", "swing_daggers", "swing_claws", "swing_bow", "swing_crossbow", "swing_sling", "swing_staff", "swing_wand", "swing_orb", "magic_fire", "magic_lightning", "magic_poison", "ward", "explosion", "voice_relic_attack", "normal_hit", "gold_pickup", "crit", "voice_relic_hurt", "voice_imp_death", "equipment_drop", "chest_land", "chest_windup", "chest_open", "legendary_reveal", "boss_hit", "voice_dragon_death"]
	for frame in range(420):
		if frame % 14 == 0:
			game.audio_manager.play_event(sequence[int(frame / 14) % sequence.size()])
		await process_frame
	var available := capture.get_frames_available()
	var samples: PackedVector2Array = capture.get_buffer(available)
	var peak := 0.0
	var energy := 0.0
	for sample in samples:
		peak = maxf(peak, maxf(absf(sample.x), absf(sample.y)))
		energy += sample.x * sample.x + sample.y * sample.y
	var rms := sqrt(energy / maxf(1.0, samples.size() * 2.0))
	print("LIVE AUDIO BANKS: PCM bytes=%d; twelve real weapon attack hooks; thirty combat/reward families" % pcm_bytes)
	var preview := AudioStreamWAV.new()
	preview.format = AudioStreamWAV.FORMAT_16_BITS
	preview.mix_rate = AudioServer.get_mix_rate()
	preview.stereo = true
	var pcm := PackedByteArray()
	pcm.resize(samples.size()*4)
	for index in range(samples.size()):
		pcm.encode_s16(index*4,int(clampf(samples[index].x,-1,1)*32767))
		pcm.encode_s16(index*4+2,int(clampf(samples[index].y,-1,1)*32767))
	preview.data = pcm
	assert(preview.save_to_wav("res://.godot_test_data/mobileux-native-audio-mix.wav") == OK)
	print("AUDIO MIX QA: frames=%d peak=%.2f dBFS rms=%.2f dBFS limiter=%s" % [samples.size(), linear_to_db(maxf(peak, 0.00001)), linear_to_db(maxf(rms, 0.00001)), has_master_limiter(master_index)])
	AudioServer.remove_bus_effect(master_index, AudioServer.get_bus_effect_count(master_index) - 1)
	var passed := samples.size() > 1000 and peak > 0.01 and peak <= 1.0 and rms > 0.004 and has_master_limiter(master_index)
	if not passed:
		push_error("AUDIO QA: player-facing mix capture was silent, clipped, or below the sanity floor")
		quit(1)
		return
	game.queue_free()
	await process_frame
	await process_frame
	quit(0)

func has_master_limiter(master_index: int) -> bool:
	for effect_index in range(AudioServer.get_bus_effect_count(master_index)):
		if AudioServer.get_bus_effect(master_index, effect_index) is AudioEffectLimiter:
			return true
	return false
