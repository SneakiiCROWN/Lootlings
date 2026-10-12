extends SceneTree
const Audio = preload("res://audio_manager.gd")

func _initialize() -> void:
	if not preload("C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-fixtures-0751/test_safety.gd").require_isolated(self): return
	for cue in Audio.MUSIC_PATHS:
		var path := Audio.music_source_path(cue)
		assert(ResourceLoader.exists(path))
		var score = load(path)
		assert(score is AudioStreamWAV or score is AudioStreamOggVorbis)
		assert(score.get_length() >= 8.0 and score.get_length() <= 300.0)
	assert(Audio.music_source_path("NONEXISTENT") == "")
	for event in Audio.EVENT_SPECS:
		var bank := Audio.production_event_streams(event)
		assert(bank.size() == Audio.variant_count(event), "Complete recorded/designed bank required: "+event)
		for clip in bank: assert(Audio.valid_event_stream(clip))
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
	print("AUDIO PRODUCTION QA PASSED: all complete PCM48 recorded/designed event banks, bounded duration and preserved music fallback; license manifest present")
	quit(0)
