extends SceneTree
const Audio = preload("res://audio_manager.gd")

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	for cue in Audio.MUSIC_PATHS:
		assert(Audio.music_source_path(cue) == Audio.MUSIC_PATHS[cue])
	assert(Audio.music_source_path("NONEXISTENT") == "")
	for event in Audio.EVENT_SPECS:
		assert(Audio.production_event_streams(event).is_empty(), "No production audio has been supplied yet")
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 48000
	stream.data = PackedByteArray()
	assert(not Audio.valid_event_stream(stream))
	var data := PackedByteArray()
	data.resize(48000 * 2)
	stream.data = data
	assert(Audio.valid_event_stream(stream))
	stream.mix_rate = 22050
	assert(not Audio.valid_event_stream(stream))
	stream.mix_rate = 48000
	data.resize(48000 * 6)
	stream.data = data
	assert(not Audio.valid_event_stream(stream))
	assert(not Audio.valid_event_stream(null))
	print("AUDIO PRODUCTION QA PASSED: all existing music/event fallbacks, bounded PCM validation; no final audio falsely enabled")
	quit(0)
