extends Node

const BUS_NAMES := ["Master", "Music", "SFX", "UI", "Ambience"]
const EVENT_SPECS := {
	"ui_press":["UI", 720.0, 0.045, 0.20], "menu_open":["UI", 520.0, 0.10, 0.18],
	"menu_close":["UI", 360.0, 0.08, 0.16], "menu_transition":["UI", 610.0, 0.12, 0.16],
	"tap_attack":["SFX", 210.0, 0.08, 0.42], "normal_hit":["SFX", 125.0, 0.11, 0.56],
	"heavy_hit":["SFX", 76.0, 0.20, 0.68], "crit":["SFX", 980.0, 0.20, 0.66],
	"boss_hit":["SFX", 62.0, 0.22, 0.74],
	"enemy_hurt":["SFX", 145.0, 0.07, 0.26], "player_hurt":["SFX", 92.0, 0.14, 0.44],
	"enemy_death":["SFX", 82.0, 0.24, 0.56], "gold_pickup":["SFX", 1180.0, 0.11, 0.42],
	"scrip_pickup":["SFX", 940.0, 0.09, 0.34], "resource_pickup":["SFX", 940.0, 0.09, 0.34],
	"xp_pickup":["SFX", 720.0, 0.10, 0.32], "equipment_drop":["SFX", 230.0, 0.24, 0.58],
	"rarity_reveal":["SFX", 680.0, 0.25, 0.42], "rare_reveal":["SFX", 720.0, 0.28, 0.46],
	"epic_reveal":["SFX", 560.0, 0.40, 0.64], "legendary_reveal":["SFX", 440.0, 0.58, 0.76],
	"chest_land":["SFX", 82.0, 0.22, 0.68], "chest_open":["SFX", 310.0, 0.46, 0.72],
	"level_up":["SFX", 660.0, 0.34, 0.60],
	"upgrade_select":["UI", 840.0, 0.16, 0.24], "core_awaken":["SFX", 420.0, 0.42, 0.58],
	"equip":["UI", 510.0, 0.13, 0.23], "scrap":["SFX", 190.0, 0.12, 0.24],
	"shop_purchase":["UI", 940.0, 0.17, 0.30], "boss_warning":["SFX", 64.0, 0.34, 0.50],
	"boss_death":["SFX", 52.0, 0.74, 0.78], "zone_transition":["Ambience", 240.0, 0.58, 0.48],
	"victory":["Music", 520.0, 0.70, 0.52], "defeat":["Music", 145.0, 0.55, 0.38]
}

var players := {}
var streams := {}
var music_player: AudioStreamPlayer
var current_music := ""
var music_streams := {}
var output_enabled := true

func _ready() -> void:
	ensure_buses()
	output_enabled = DisplayServer.get_name() != "headless"
	if not output_enabled:
		return
	for bus_name in ["SFX", "UI", "Ambience", "Music"]:
		players[bus_name] = []
		for index in range(4 if bus_name == "SFX" else 2):
			var player := AudioStreamPlayer.new()
			player.bus = bus_name
			add_child(player)
			players[bus_name].append(player)
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	for event_name in EVENT_SPECS:
		var spec: Array = EVENT_SPECS[event_name]
		streams[event_name] = make_tone(float(spec[1]), float(spec[2]), float(spec[3]), event_name)

func ensure_buses() -> void:
	for bus_name in BUS_NAMES:
		if AudioServer.get_bus_index(bus_name) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)

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
	var spec: Array = EVENT_SPECS[event_name]
	var bus_name: String = spec[0]
	var pool: Array = players.get(bus_name, [])
	if pool.is_empty():
		return
	var player: AudioStreamPlayer = pool[0]
	for candidate in pool:
		if not candidate.playing:
			player = candidate
			break
	player.stream = streams[event_name]
	player.pitch_scale = 1.0 + randf_range(-0.025, 0.025)
	player.play()

func set_music(cue: String) -> void:
	if not output_enabled:
		current_music = cue
		return
	if cue == current_music:
		return
	current_music = cue
	if cue.is_empty():
		music_player.stop()
		return
	var base_frequency: float = float({
		"TITLE":196.0, "HIDEOUT":220.0, "OUTER_RUINS":246.0, "SALVAGE_WARRENS":164.0,
		"HOARD_DEPTHS":130.0, "BOSS":98.0, "VICTORY":330.0, "DEFEAT":146.0
	}.get(cue, 196.0))
	if not music_streams.has(cue):
		music_streams[cue] = make_ambient_loop(base_frequency)
	music_player.stream = music_streams[cue]
	music_player.play()

func make_tone(frequency: float, duration: float, gain: float, event_name: String) -> AudioStreamWAV:
	var sample_rate := 22050
	var sample_count := maxi(1, int(duration * sample_rate))
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for sample_index in range(sample_count):
		var time := float(sample_index) / sample_rate
		var progress := float(sample_index) / sample_count
		var envelope := pow(1.0 - progress, 2.2)
		var sweep := 1.18 - 0.48 * progress
		var noise := sin(float(sample_index) * 12.9898) * sin(float(sample_index) * 0.731)
		var wave := sin(TAU * frequency * sweep * time) * 0.58
		wave += sin(TAU * frequency * 2.01 * time) * 0.18 * (1.0 - progress)
		if event_name in ["normal_hit", "heavy_hit", "boss_hit", "enemy_hurt", "player_hurt", "enemy_death", "boss_death", "chest_land", "scrap"]:
			var transient := exp(-progress * (18.0 if event_name == "normal_hit" else 10.0))
			wave = wave * 0.36 + sin(TAU * frequency * 0.48 * time) * 0.42 + noise * transient * 0.72
			wave += sin(TAU * 92.0 * time) * transient * (0.28 if event_name in ["normal_hit", "enemy_hurt"] else 0.44)
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
		var shaped := wave * envelope * gain
		shaped /= 1.0 + absf(shaped) * 0.32
		data.encode_s16(sample_index * 2, int(clampf(shaped, -0.98, 0.98) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream

func make_ambient_loop(base_frequency: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 6.0
	var sample_count := int(duration * sample_rate)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for sample_index in range(sample_count):
		var time := float(sample_index) / sample_rate
		var phrase := fmod(time, 1.5) / 1.5
		var pulse := 0.5 + 0.5 * sin(TAU * time / duration)
		var note_step := int(floor(time / 1.5)) % 4
		var note_ratio: float = [1.0, 1.25, 1.5, 1.125][note_step]
		var wave := sin(TAU * base_frequency * 0.5 * time) * 0.078
		wave += sin(TAU * base_frequency * note_ratio * time) * 0.056 * pow(1.0 - phrase, 1.4)
		wave += sin(TAU * base_frequency * 1.5 * time) * 0.032 * pulse
		wave += sin(TAU * base_frequency * 0.25 * time) * 0.036
		wave += sin(TAU * base_frequency * 0.75 * time) * 0.018 * (0.35 + pulse * 0.65)
		if base_frequency < 150.0:
			wave += sin(TAU * base_frequency * 0.5 * time) * 0.045 * (0.35 + 0.65 * pow(1.0 - fmod(time, 0.75) / 0.75, 3.0))
		data.encode_s16(sample_index * 2, int(clampf(wave, -1.0, 1.0) * 32767.0))
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
	if music_player != null:
		music_player.stop()
		music_player.stream = null
	for bus_name in players:
		for player in players[bus_name]:
			player.stop()
			player.stream = null
	streams.clear()
	music_streams.clear()
