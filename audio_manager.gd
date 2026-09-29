extends Node

const BUS_NAMES := ["Master", "Music", "SFX", "UI", "Ambience"]
const EVENT_SPECS := {
	"ui_press":["UI", 720.0, 0.045, 0.20], "menu_open":["UI", 520.0, 0.10, 0.18],
	"menu_close":["UI", 360.0, 0.08, 0.16], "menu_transition":["UI", 610.0, 0.12, 0.16],
	"tap_attack":["SFX", 185.0, 0.055, 0.24], "normal_hit":["SFX", 115.0, 0.075, 0.30],
	"heavy_hit":["SFX", 72.0, 0.13, 0.38], "crit":["SFX", 920.0, 0.12, 0.30],
	"enemy_hurt":["SFX", 145.0, 0.06, 0.22], "player_hurt":["SFX", 92.0, 0.12, 0.30],
	"enemy_death":["SFX", 78.0, 0.18, 0.32], "resource_pickup":["SFX", 1040.0, 0.08, 0.20],
	"xp_pickup":["SFX", 780.0, 0.07, 0.16], "equipment_drop":["SFX", 240.0, 0.16, 0.28],
	"rarity_reveal":["SFX", 680.0, 0.24, 0.26], "chest_land":["SFX", 88.0, 0.15, 0.34],
	"chest_open":["SFX", 330.0, 0.28, 0.28], "level_up":["SFX", 660.0, 0.24, 0.27],
	"upgrade_select":["UI", 840.0, 0.16, 0.24], "core_awaken":["SFX", 420.0, 0.34, 0.30],
	"equip":["UI", 510.0, 0.13, 0.23], "scrap":["SFX", 190.0, 0.12, 0.24],
	"shop_purchase":["UI", 940.0, 0.16, 0.25], "boss_warning":["SFX", 64.0, 0.30, 0.35],
	"boss_death":["SFX", 55.0, 0.42, 0.40], "zone_transition":["Ambience", 260.0, 0.38, 0.18],
	"victory":["Music", 520.0, 0.55, 0.28], "defeat":["Music", 145.0, 0.50, 0.24]
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
		var envelope := pow(1.0 - float(sample_index) / sample_count, 2.0)
		var sweep := 1.0 - 0.22 * float(sample_index) / sample_count
		var wave := sin(TAU * frequency * sweep * time)
		if event_name in ["normal_hit", "heavy_hit", "enemy_death", "boss_death", "chest_land"]:
			wave = wave * 0.55 + sin(TAU * frequency * 0.51 * time) * 0.25 + randf_range(-0.16, 0.16)
		data.encode_s16(sample_index * 2, int(clampf(wave * envelope * gain, -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream

func make_ambient_loop(base_frequency: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 4.0
	var sample_count := int(duration * sample_rate)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for sample_index in range(sample_count):
		var time := float(sample_index) / sample_rate
		var pulse := 0.5 + 0.5 * sin(TAU * time / duration)
		var wave := sin(TAU * base_frequency * time) * 0.035
		wave += sin(TAU * base_frequency * 1.5 * time) * 0.018 * pulse
		wave += sin(TAU * base_frequency * 0.5 * time) * 0.022
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
