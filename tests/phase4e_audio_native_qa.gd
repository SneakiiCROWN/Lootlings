extends SceneTree
var game
var folder:="res://.godot_test_data/phase4e/audio/"
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("review")
func review() -> void:
	assert(DisplayServer.get_name()!="headless")
	game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.set_process(false); game.audio_manager.apply_settings(preload("res://settings_store.gd").defaults())
	game.audio_manager.set_music("OUTER_RUINS")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	for weapon in ["bow","crossbow","daggers","claws","greatsword","greataxe","maul","spear","sling","staff","wand","orb"]:
		await record("weapon_"+weapon,1.6,func(): game.audio_manager.play_event("swing_"+weapon); game.audio_manager.play_contact(weapon,"armour",false,weapon in ["greatsword","maul","greataxe"]))
	for material in ["flesh","armour","stone","wood","glass","molten","ethereal"]:
		await record("material_"+material,1.2,func(): game.audio_manager.play_contact("bow",material,false,false))
	for action in ["thorn","root","mirror","recover"]:
		await record("verdant_"+action,1.4,func(): game.play_audio_event("verdant_"+action))
	for rarity in ["COMMON","UNCOMMON","RARE","EPIC","LEGENDARY","RED"]:
		game.state="relic_spinner"
		await record("spinner_"+rarity.to_lower(),5.5,func(): game.retention.machine.wind_up("item",rarity,false))
		game.retention.machine.stop()
	game.free(); print("PHASE4E AUDIO NATIVE PASS: complete Master weapon/material/guardian/reel captures; listening and S23 mastering approval remain separate"); quit()

func record(label: String,seconds: float,trigger: Callable) -> void:
	var capture:=AudioEffectCapture.new(); capture.buffer_length=2
	AudioServer.add_bus_effect(0,capture)
	var samples:=PackedVector2Array(); trigger.call()
	var start: int=Time.get_ticks_msec()
	while Time.get_ticks_msec()-start<int(seconds*1000):
		await process_frame
		samples.append_array(capture.get_buffer(capture.get_frames_available()))
	samples.append_array(capture.get_buffer(capture.get_frames_available()))
	assert(capture.get_discarded_frames()==0)
	var pcm:=PackedByteArray(); pcm.resize(samples.size()*4)
	var peak:=0.0; var energy:=0.0
	for index in range(samples.size()):
		var frame: Vector2=samples[index]; peak=maxf(peak,maxf(absf(frame.x),absf(frame.y))); energy+=frame.length_squared()
		pcm.encode_s16(index*4,int(clampf(frame.x,-1,1)*32767)); pcm.encode_s16(index*4+2,int(clampf(frame.y,-1,1)*32767))
	var wav:=AudioStreamWAV.new(); wav.format=AudioStreamWAV.FORMAT_16_BITS; wav.stereo=true; wav.mix_rate=AudioServer.get_mix_rate(); wav.data=pcm
	assert(wav.save_to_wav(folder+label+".wav")==OK)
	assert(samples.size()>1000 and peak>.001 and peak<1.0)
	print("PHASE4E_AUDIO "+JSON.stringify({"label":label,"frames":samples.size(),"peak_dbfs":linear_to_db(peak),"rms_dbfs":linear_to_db(sqrt(energy/(samples.size()*2))),"discarded":capture.get_discarded_frames()}))
	AudioServer.remove_bus_effect(0,AudioServer.get_bus_effect_count(0)-1)
