extends SceneTree
const Regions=preload("res://region_audio.gd")
func _initialize() -> void:
    assert(OS.get_environment("LOOTLINGS_QA")=="1" and ".godot_test_data" in OS.get_user_data_dir())
    call_deferred("run")
func run() -> void:
    var g=load("res://main.tscn").instantiate();root.add_child(g)
    for frame in range(8):await process_frame
    g.set_process(false)
    var a=g.audio_manager
    a.apply_settings({"master":.90,"music":.58,"sfx":.92,"ui":.84,"ambience":.62,"master_muted":false,"music_muted":false,"sfx_muted":false,"ui_muted":false,"ambience_muted":false})
    var bus=AudioServer.get_bus_index("Master");var capture=AudioEffectCapture.new();capture.buffer_length=30
    AudioServer.add_bus_effect(bus,capture,AudioServer.get_bus_effect_count(bus))
    var checks=[]
    for region in Regions.CUES:
        g.campaign_id=region;g.wave=1;g.start_run();g.campaign_id=region;g.wave=1;g.spawn_enemy();g.set_process(false)
        assert(a.current_music==Regions.CUES[region],"Actual regional spawn must select its own score")
        assert(a.music_player.playing and a.ambience_player.playing)
        assert(a.music_player.stream.get_length()>60 and a.music_streams.size()==1)
        capture.clear_buffer()
        for frame in range(90):await process_frame
        var samples=capture.get_buffer(capture.get_frames_available());var peak=0.0;var energy=0.0
        for s in samples:peak=maxf(peak,maxf(absf(s.x),absf(s.y)));energy+=s.x*s.x+s.y*s.y
        assert(samples.size()>1000 and peak>.001 and peak<1.0)
        checks.append({"region":region,"cue":a.current_music,"frames":samples.size(),"peak_dbfs":linear_to_db(peak),"rms_dbfs":linear_to_db(sqrt(energy/maxf(1,samples.size()*2)))})
        assert(Regions.combat_cue(region,"outer_ruins",true)=="BOSS")
    assert(Regions.combat_cue("act_i","emberworks",false)=="SALVAGE_WARRENS")
    assert(Regions.combat_cue("moonfen","outer_ruins",false)=="OUTER_RUINS")
    a.set_music("HOME");assert(a.ambience_player.stream.resource_path.ends_with("home_hearth.wav"))
    a.set_music("TITLE");assert(a.ambience_player.stream==null)
    assert(a.music_player.stream.resource_path.ends_with("title.ogg"))
    a.set_music("BOSS");assert(a.ambience_player.stream==null)
    a.set_music("");assert(a.music_streams.is_empty() and not a.music_player.playing)
    AudioServer.remove_bus_effect(bus,AudioServer.get_bus_effect_count(bus)-1)
    var file=FileAccess.open("C:/Users/Snkii/Documents/lootlings/.godot_test_data/region-audio-compiled.json",FileAccess.WRITE);file.store_string(JSON.stringify({"checks":checks,"physical_device_review":false,"subjective_listening_review":false,"retained_title_route":true},"  "));file.close()
    print("REGIONAL AUDIO NATIVE PASS: four actual region spawn hooks, full stereo scores, distinct ambience, non-silent bounded output, boss/Act I/title/Home routes and bounded active-score cache")
    g.queue_free();await process_frame;await process_frame;quit(0)
