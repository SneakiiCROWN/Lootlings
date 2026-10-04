extends Node

const BUS_NAMES := ["Master", "Music", "SFX", "UI", "Ambience"]
const PRODUCTION_ROOT := "res://art/audio/production/"
const MUSIC_PATHS := {
	"TITLE":"res://art/audio/music/title.wav", "HIDEOUT":"res://art/audio/music/hideout.wav",
	"OUTER_RUINS":"res://art/audio/music/outer_ruins.wav", "SALVAGE_WARRENS":"res://art/audio/music/salvage_warrens.wav",
	"HOARD_DEPTHS":"res://art/audio/music/hoard_depths.wav", "BOSS":"res://art/audio/music/boss.wav",
	"VICTORY":"res://art/audio/music/victory.wav", "DEFEAT":"res://art/audio/music/defeat.wav"
}
const BASE_EVENT_SPECS := {
	"swing_greatsword":["SFX",0,.28,.5], "swing_greataxe":["SFX",0,.30,.5], "swing_maul":["SFX",0,.32,.5],
	"swing_spear":["SFX",0,.18,.4], "swing_daggers":["SFX",0,.15,.4], "swing_claws":["SFX",0,.12,.4],
	"swing_bow":["SFX",0,.18,.4], "swing_crossbow":["SFX",0,.16,.4], "swing_sling":["SFX",0,.18,.4],
	"swing_staff":["SFX",0,.38,.4], "swing_wand":["SFX",0,.25,.4], "swing_orb":["SFX",0,.40,.4],
	"magic_fire":["SFX",0,.38,.4], "magic_lightning":["SFX",0,.22,.4], "magic_poison":["SFX",0,.38,.4],
	"ward":["SFX",0,.28,.4], "explosion":["SFX",0,.38,.5],
	"ui_press":["UI", 720.0, 0.045, 0.20], "menu_open":["UI", 520.0, 0.10, 0.18],
	"menu_close":["UI", 360.0, 0.08, 0.16], "menu_transition":["UI", 610.0, 0.12, 0.16],
	"tap_attack":["SFX", 210.0, 0.08, 0.42], "normal_hit":["SFX", 125.0, 0.11, 0.56],
	"ranger_release":["SFX", 760.0, 0.13, 0.34], "mage_cast":["SFX", 430.0, 0.22, 0.38],
	"vanguard_swing":["SFX", 92.0, 0.16, 0.48], "rogue_slash":["SFX", 1040.0, 0.10, 0.32],
	"enemy_skirmisher":["SFX", 180.0, 0.12, 0.28], "enemy_tank":["SFX", 68.0, 0.19, 0.38],
	"enemy_hexer":["SFX", 350.0, 0.22, 0.32],
	"heavy_hit":["SFX", 76.0, 0.20, 0.68], "crit":["SFX", 980.0, 0.20, 0.66],
	"boss_hit":["SFX", 62.0, 0.22, 0.74],

	"gold_pickup":["SFX", 1180.0, 0.11, 0.42],
	"scrip_pickup":["SFX", 940.0, 0.09, 0.34], "resource_pickup":["SFX", 940.0, 0.09, 0.34],
	"xp_pickup":["SFX", 720.0, 0.10, 0.32], "equipment_drop":["SFX", 230.0, 0.24, 0.58],
	"rarity_reveal":["SFX", 680.0, 0.25, 0.42], "rare_reveal":["SFX", 720.0, 0.28, 0.46],
	"epic_reveal":["SFX", 560.0, 0.40, 0.64], "legendary_reveal":["SFX", 440.0, 0.58, 0.76],
	"chest_land":["SFX", 82.0, 0.22, 0.68], "chest_windup":["SFX", 126.0, 0.58, 0.42], "chest_open":["SFX", 310.0, 0.46, 0.72],
	"level_up":["SFX", 660.0, 0.34, 0.60],
	"upgrade_select":["UI", 840.0, 0.16, 0.24], "core_awaken":["SFX", 420.0, 0.42, 0.58],
	"equip":["UI", 510.0, 0.13, 0.23], "scrap":["SFX", 190.0, 0.12, 0.24],
	"shop_purchase":["UI", 940.0, 0.17, 0.30], "boss_warning":["SFX", 64.0, 0.34, 0.50],
	"zone_transition":["Ambience", 240.0, 0.58, 0.48],
	"victory":["Music", 520.0, 0.70, 0.52], "defeat":["Music", 145.0, 0.55, 0.38]
}

static var EVENT_SPECS := event_specs()

static func event_specs() -> Dictionary:
	var result := BASE_EVENT_SPECS.duplicate(true)
	for profile in preload("res://voice_identity.gd").PROFILES:
		for role in ["attack","hurt","death"]:
			result["voice_"+profile+"_"+role] = ["SFX",0,.5,.4]
	return result

static func variant_count(event: String) -> int:
	return 4 if event in VARIANT_EVENTS or event.begins_with("voice_") else 1

var players := {}
var streams := {}
var music_player: AudioStreamPlayer
var ambience_player: AudioStreamPlayer
var current_music := ""
var music_streams := {}
var output_enabled := true
var last_variant := {}
var event_sequence := {}
var last_event_msec := {}
var duck_tween: Tween
var music_gain_db := 4.0
var event_mix_trim := true

const VARIANT_EVENTS := ["swing_greatsword", "swing_greataxe", "swing_maul", "swing_spear", "swing_daggers", "swing_claws", "swing_bow", "swing_crossbow", "swing_sling", "swing_staff", "swing_wand", "swing_orb", "magic_fire", "magic_lightning", "magic_poison", "ward", "explosion", "tap_attack", "normal_hit", "heavy_hit", "crit", "boss_hit", "gold_pickup", "scrip_pickup", "resource_pickup", "xp_pickup", "equipment_drop", "ranger_release", "mage_cast", "vanguard_swing", "rogue_slash", "enemy_skirmisher", "enemy_tank", "enemy_hexer"]
const PICKUP_EVENTS := ["gold_pickup", "scrip_pickup", "resource_pickup", "xp_pickup"]
const IMPORTANT_EVENTS := ["heavy_hit", "crit", "boss_hit", "equipment_drop", "rare_reveal", "epic_reveal", "legendary_reveal", "chest_land", "chest_windup", "chest_open", "level_up", "core_awaken", "boss_warning", "victory", "defeat"]

func _ready() -> void:
	ensure_buses()
	output_enabled = DisplayServer.get_name() != "headless"
	if not output_enabled:
		return
	for bus_name in ["SFX", "UI", "Ambience", "Music"]:
		players[bus_name] = []
		for index in range(6 if bus_name == "SFX" else 2):
			var player := AudioStreamPlayer.new()
			player.bus = bus_name
			add_child(player)
			players[bus_name].append(player)
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	ambience_player = AudioStreamPlayer.new()
	ambience_player.bus = "Ambience"
	add_child(ambience_player)
	for event_name in EVENT_SPECS:
		var spec: Array = EVENT_SPECS[event_name]
		var authored := production_event_streams(event_name)
		if not authored.is_empty():
			streams[event_name] = authored
			continue
		var count := variant_count(event_name)
		var variants: Array[AudioStreamWAV] = []
		for variant in range(count):
			variants.append(make_tone(float(spec[1]), float(spec[2]), float(spec[3]), event_name, variant))
		streams[event_name] = variants

static func valid_event_stream(stream: Variant) -> bool:
	# Short imported assets only: no unbounded ambient/music buffer in SFX pools.
	return stream is AudioStreamWAV and stream.format == AudioStreamWAV.FORMAT_16_BITS and stream.mix_rate in [44100,48000] and stream.get_length() >= 0.025 and stream.get_length() <= 2.0

static func production_event_streams(event_name: String) -> Array[AudioStreamWAV]:
	var result: Array[AudioStreamWAV] = []
	if not EVENT_SPECS.has(event_name): return result
	var count := variant_count(event_name)
	for index in range(count):
		var path := PRODUCTION_ROOT + "sfx/%s_%02d.wav" % [event_name,index+1]
		if not ResourceLoader.exists(path):
			# Require the complete four-variant pack for frequent cues; otherwise
			# retain the original anti-fatigue bank, never a partial repetitive pack.
			return []
		var stream = load(path)
		if not valid_event_stream(stream):
			push_warning("Production SFX rejected (PCM16, 44.1/48kHz, 0.025–2s required): " + path)
			return []
		result.append(stream)
	return result

static func music_source_path(cue: String) -> String:
	if not MUSIC_PATHS.has(cue): return ""
	var path := PRODUCTION_ROOT + "music/" + cue.to_lower() + ".wav"
	return path if ResourceLoader.exists(path) else str(MUSIC_PATHS[cue])

func ensure_buses() -> void:
	for bus_name in BUS_NAMES:
		if AudioServer.get_bus_index(bus_name) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
	# The rescue mix brings important gameplay cues forward, so keep the final
	# player-facing path protected instead of relying on every overlapping voice
	# to remain below full scale by accident.
	var master_index := AudioServer.get_bus_index("Master")
	var has_limiter := false
	for effect_index in range(AudioServer.get_bus_effect_count(master_index)):
		if AudioServer.get_bus_effect(master_index, effect_index) is AudioEffectLimiter:
			has_limiter = true
			break
	if not has_limiter:
		var limiter := AudioEffectLimiter.new()
		limiter.ceiling_db = -1.5
		limiter.threshold_db = -3.0
		limiter.soft_clip_db = 2.0
		AudioServer.add_bus_effect(master_index, limiter)

func apply_settings(settings: Dictionary) -> void:
	for channel in ["master", "music", "sfx", "ui", "ambience"]:
		var bus_name: String = {"master":"Master", "music":"Music", "sfx":"SFX", "ui":"UI", "ambience":"Ambience"}[channel]
		var index := AudioServer.get_bus_index(bus_name)
		if index < 0:
			continue
		var volume := clampf(float(settings.get(channel, 0.8)), 0.0, 1.0)
		AudioServer.set_bus_volume_db(index, linear_to_db(maxf(volume, 0.0001)))
		AudioServer.set_bus_mute(index, bool(settings.get(channel + "_muted", false)))

func play_event(event_name: String) -> void:
	if not output_enabled or not EVENT_SPECS.has(event_name):
		return
	var now := Time.get_ticks_msec()
	if event_name in PICKUP_EVENTS and now - int(last_event_msec.get(event_name, -1000)) < 65:
		return
	last_event_msec[event_name] = now
	var spec: Array = EVENT_SPECS[event_name]
	var bus_name: String = spec[0]
	var pool: Array = players.get(bus_name, [])
	if pool.is_empty():
		return
	var player: AudioStreamPlayer
	for candidate in pool:
		if not candidate.playing:
			player = candidate
			break
	if player == null:
		if event_name not in IMPORTANT_EVENTS and not (event_name.begins_with("voice_") and not event_name.ends_with("_attack")):
			return
		player = pool[0]
	var variants: Array = streams[event_name]
	var variant_index := choose_variant(event_name, variants.size())
	player.stream = variants[variant_index]
	var pitch_range := 0.018 if event_name in IMPORTANT_EVENTS else 0.032
	player.pitch_scale = 1.0 + randf_range(-pitch_range, pitch_range)
	# Reserve a little true-peak headroom for music + reward/boss transients while
	# keeping important cues perceptually forward through timbre and duration.
	if event_name in IMPORTANT_EVENTS:
		player.volume_db = randf_range(-3.0, -2.0)
	elif event_name in ["normal_hit", "ranger_release", "mage_cast", "vanguard_swing", "rogue_slash", "gold_pickup", "scrip_pickup", "xp_pickup"]:
		player.volume_db = randf_range(-3.0, -1.8)
	else:
		player.volume_db = randf_range(-5.0, -3.5)
	# Equal-default native captures showed combat ~12 dB above the hub.
	# Trim overlapping impact/weapon families; preserve species timbre and saved sliders.
	if event_mix_trim:
		player.volume_db -= 4.0 if event_name in ["normal_hit","heavy_hit","crit","boss_hit","explosion"] else 3.0 if event_name.begins_with("swing_") or event_name in ["tap_attack","ranger_release","mage_cast","vanguard_swing","rogue_slash"] else 2.0
	player.play()

func play_voice(profile: String, role: String) -> void:
	if profile not in preload("res://voice_identity.gd").PROFILES or role not in ["attack","hurt","death"]: return
	var event := "voice_"+profile+"_"+role
	var now := Time.get_ticks_msec()
	var interval := 1350 if role == "attack" else 700 if role == "hurt" else 0
	if now-int(last_event_msec.get(event,-2000)) < interval: return
	play_event(event)

func choose_variant(event_name: String, variant_count: int) -> int:
	if variant_count <= 1:
		last_variant[event_name] = 0
		return 0
	var sequence := int(event_sequence.get(event_name, 0)) + 1
	event_sequence[event_name] = sequence
	var candidate := sequence % variant_count
	if candidate == int(last_variant.get(event_name, -1)):
		candidate = (candidate + 1) % variant_count
	last_variant[event_name] = candidate
	return candidate

func set_music(cue: String) -> void:
	if not output_enabled:
		current_music = cue
		return
	if cue == current_music:
		return
	current_music = cue
	if ambience_player != null:
		ambience_player.stop()
		ambience_player.stream = null
		var ambient_key: String = {"OUTER_RUINS":"outer_ruins","SALVAGE_WARRENS":"salvage_warrens","HOARD_DEPTHS":"hoard_depths","HIDEOUT":"hideout"}.get(cue,"")
		if not ambient_key.is_empty():
			var ambient: AudioStreamWAV = load(PRODUCTION_ROOT+"ambience/"+ambient_key+".wav")
			ambient.loop_mode = AudioStreamWAV.LOOP_FORWARD
			ambient.loop_end = int(ambient.get_length()*ambient.mix_rate)
			ambience_player.stream = ambient
			ambience_player.volume_db = -9
			ambience_player.play()
	if cue.is_empty():
		music_player.stop()
		return
	if not MUSIC_PATHS.has(cue):
		return
	if not music_streams.has(cue):
		# Generated once during development and imported as an ordinary WAV. Keep
		# only the active long-form score resident so travel never stalls Android.
		music_streams.clear()
		var path := music_source_path(cue)
		var stream = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if path != MUSIC_PATHS[cue] and (not stream is AudioStreamWAV or stream.get_length() < 8.0 or stream.get_length() > 120.0):
			push_warning("Production score rejected (8–120s WAV required): " + path)
			stream = ResourceLoader.load(MUSIC_PATHS[cue], "", ResourceLoader.CACHE_MODE_IGNORE)
		if stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			stream.loop_begin = 0
			stream.loop_end = int(stream.get_length() * stream.mix_rate)
		music_streams[cue] = stream
	music_player.stream = music_streams[cue]
	# The prebaked score is intentionally low-amplitude to retain source
	# headroom; restore body here before the saved Music and Master controls.
	music_player.volume_db = music_gain_db
	music_player.play()

func duck_music(duration: float = 0.20, depth_db: float = -11.0) -> void:
	if not output_enabled or music_player == null:
		return
	if duck_tween != null and duck_tween.is_valid():
		duck_tween.kill()
	duck_tween = create_tween()
	duck_tween.tween_property(music_player, "volume_db", depth_db, 0.045)
	duck_tween.tween_interval(maxf(0.04, duration))
	duck_tween.tween_property(music_player, "volume_db", music_gain_db, 0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func make_tone(frequency: float, duration: float, gain: float, event_name: String, variant: int = 0) -> AudioStreamWAV:
	var sample_rate := 22050
	var sample_count := maxi(1, int(duration * sample_rate))
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for sample_index in range(sample_count):
		var time := float(sample_index) / sample_rate
		var progress := float(sample_index) / sample_count
		var envelope := pow(1.0 - progress, 2.2)
		var variant_tone := 1.0 + (float(variant) - 1.5) * 0.018
		var sweep := 1.18 - (0.45 + variant * 0.018) * progress
		var noise := sin(float(sample_index + variant * 17) * 12.9898) * sin(float(sample_index + variant * 31) * 0.731)
		var wave := sin(TAU * frequency * variant_tone * sweep * time + variant * 0.21) * 0.58
		wave += sin(TAU * frequency * 2.01 * time) * 0.18 * (1.0 - progress)
		if event_name in ["normal_hit", "heavy_hit", "boss_hit", "chest_land", "scrap"]:
			var transient := exp(-progress * (18.0 if event_name == "normal_hit" else 10.0))
			wave = wave * 0.36 + sin(TAU * frequency * 0.48 * time) * 0.42 + noise * transient * 0.72
			wave += sin(TAU * 92.0 * time) * transient * (0.28 if event_name in ["normal_hit"] else 0.44)
		if event_name in ["crit", "rare_reveal", "epic_reveal", "legendary_reveal", "level_up", "core_awaken", "victory"]:
			wave += sin(TAU * frequency * (1.0 + floor(progress * 3.0) * 0.25) * time) * 0.32
			wave += sin(TAU * frequency * 1.5 * time) * 0.18 * sin(PI * progress)
			wave += sin(TAU * 118.0 * time) * exp(-progress * 7.0) * (0.34 if event_name == "crit" else 0.20)
		if event_name in ["gold_pickup", "scrip_pickup", "resource_pickup", "xp_pickup", "shop_purchase"]:
			wave += sin(TAU * frequency * 1.5 * time) * 0.30 * sin(PI * progress)
		if event_name == "equipment_drop":
			wave += sin(TAU * 1380.0 * time) * exp(-progress * 12.0) * 0.34
		if event_name == "chest_open":
			wave = noise * exp(-progress * 7.0) * 0.48 + sin(TAU * frequency * (0.65 + progress) * time) * 0.52
		if event_name == "ranger_release":
			wave = noise * exp(-progress * 22.0) * 0.32 + sin(TAU * frequency * (1.2 - progress * 0.35) * time) * 0.46
		if event_name == "mage_cast" or event_name == "enemy_hexer":
			wave = sin(TAU * frequency * (0.58 + progress * 1.2) * time) * 0.42 + sin(TAU * frequency * 1.51 * time) * 0.22 * sin(PI * progress)
		if event_name == "vanguard_swing" or event_name == "enemy_tank":
			wave = sin(TAU * frequency * (1.5 - progress) * time) * 0.48 + noise * exp(-progress * 9.0) * 0.42
		if event_name == "rogue_slash" or event_name == "enemy_skirmisher":
			wave = noise * exp(-progress * 18.0) * 0.42 + sin(TAU * frequency * (1.35 - progress * 0.55) * time) * 0.40
		var shaped := wave * envelope * gain
		shaped /= 1.0 + absf(shaped) * 0.32
		data.encode_s16(sample_index * 2, int(clampf(shaped, -0.98, 0.98) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream

func make_ambient_loop(base_frequency: float, cue: String = "OUTER_RUINS") -> AudioStreamWAV:
	# A precomputed 48-second five-part phrase: A, variation, B, quiet bridge,
	# and return. It is long enough to avoid obvious cycling while remaining a
	# compact mono buffer suitable for mobile and creates no runtime synthesis.
	var sample_rate := 16000
	var duration := 48.0
	var sample_count := int(duration * sample_rate)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var notes: Array[float] = [1.0, 1.25, 1.5, 1.125, 1.0, 1.333, 1.5, 1.20,
		1.0, 1.5, 1.25, 1.333, 1.125, 1.5, 1.20, 1.0,
		0.75, 1.0, 1.25, 1.5, 1.333, 1.125, 1.0, 0.75,
		1.0, 1.125, 1.0, 0.75, 1.0, 1.25, 1.5, 1.0]
	var dark_cue := cue in ["HOARD_DEPTHS", "BOSS", "DEFEAT"]
	var mechanical_cue := cue == "SALVAGE_WARRENS"
	var safe_cue := cue in ["TITLE", "HIDEOUT"]
	for sample_index in range(sample_count):
		var time := float(sample_index) / sample_rate
		var phrase := fmod(time, 1.5) / 1.5
		var step := mini(int(floor(time / 1.5)), notes.size() - 1)
		var section := mini(4, int(floor(time / 9.6)))
		var note_ratio := notes[step]
		var beat := fmod(time, 0.75) / 0.75
		var pluck_env := pow(1.0 - phrase, 3.2)
		var drum_env := pow(1.0 - beat, 8.0)
		var slow_pulse := 0.5 + 0.5 * sin(TAU * time / 12.0)
		var quiet := 0.48 if section == 3 else 1.0
		var wave := sin(TAU * base_frequency * 0.25 * time) * (0.034 if dark_cue else 0.025)
		# Warm pad: detuned low harmonics rather than a single exposed sine.
		wave += sin(TAU * base_frequency * 0.5 * time) * 0.038 * quiet
		wave += sin(TAU * base_frequency * 0.503 * time + 0.7) * 0.025 * quiet
		wave += sin(TAU * base_frequency * 0.75 * time) * 0.016 * slow_pulse
		# Pluck and bell motif; sections vary register and density.
		var pluck_frequency := base_frequency * note_ratio * (0.5 if dark_cue else 1.0)
		wave += (sin(TAU * pluck_frequency * time) * 0.038 + sin(TAU * pluck_frequency * 2.01 * time) * 0.014) * pluck_env * quiet
		if section in [1, 2, 4] and step % 2 == 0:
			wave += sin(TAU * pluck_frequency * 2.5 * time) * 0.017 * pow(1.0 - phrase, 2.0)
		# Low adventure drum and deterministic filtered-noise percussion.
		var pseudo_noise := sin(float(sample_index + step * 97) * 12.9898) * sin(float(sample_index + 31) * 0.731)
		var drum_gain := 0.040 if dark_cue else 0.026
		wave += sin(TAU * (56.0 + base_frequency * 0.08) * time) * drum_env * drum_gain * quiet
		if mechanical_cue and step % 2 == 1:
			wave += pseudo_noise * pow(1.0 - phrase, 13.0) * 0.028
		elif not safe_cue and step % 4 == 3:
			wave += pseudo_noise * pow(1.0 - phrase, 16.0) * 0.012
		# Relic sparkle is sparse and intentionally absent through the bridge.
		if section != 3 and step % 4 == 2:
			wave += sin(TAU * base_frequency * 3.0 * time) * pow(1.0 - phrase, 5.0) * 0.010
		var loop_edge := clampf(minf(time, duration - time) / 0.055, 0.0, 1.0)
		wave *= loop_edge
		data.encode_s16(sample_index * 2, int(clampf(wave, -0.92, 0.92) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_count
	stream.data = data
	return stream

func _exit_tree() -> void:
	if ambience_player != null:
		ambience_player.stop()
		ambience_player.stream = null
	if music_player != null:
		music_player.stop()
		music_player.stream = null
	for bus_name in players:
		for player in players[bus_name]:
			player.stop()
			player.stream = null
	streams.clear()
	music_streams.clear()
