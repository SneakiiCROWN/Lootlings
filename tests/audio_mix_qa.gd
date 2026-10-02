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
	# Measure the shipped defaults, not whatever mute/volume state a previous
	# local QA session persisted in this isolated test profile.
	game.audio_manager.apply_settings({"master":0.90, "music":0.58, "sfx":0.92, "ui":0.84, "ambience":0.62, "master_muted":false, "music_muted":false, "sfx_muted":false, "ui_muted":false, "ambience_muted":false})
	var master_index := AudioServer.get_bus_index("Master")
	var capture := AudioEffectCapture.new()
	capture.buffer_length = 5.0
	AudioServer.add_bus_effect(master_index, capture, AudioServer.get_bus_effect_count(master_index))
	game.audio_manager.set_music("OUTER_RUINS")
	var sequence := ["ranger_release", "normal_hit", "gold_pickup", "normal_hit", "crit", "player_hurt", "enemy_death", "equipment_drop", "chest_land", "chest_windup", "chest_open", "legendary_reveal", "boss_hit", "boss_death"]
	for frame in range(210):
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
