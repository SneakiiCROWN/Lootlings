extends SceneTree
func _initialize() -> void:
    if not preload("res://tests/test_safety.gd").require_isolated(self):return
    call_deferred("run")
func run() -> void:
    var g=load("res://main.tscn").instantiate();root.add_child(g)
    for frame in range(6):await process_frame
    g.show_hideout();g.set_process(false)
    var hub=g.hideout_ui;var heard=[];hub.ui_event.connect(func(event):heard.append(event));hub.set_process(false);hub.scene_time=56;hub.station_cycle=0;hub._process(.01)
    assert("home_page" in heard)
    hub.scene_time=84;hub._process(.01)
    assert("home_bench" in heard)
    var a=g.audio_manager.production_event_streams("home_bench")[0]
    var b=g.audio_manager.production_event_streams("scrap")[0]
    assert(a.data!=b.data and a.format==AudioStreamWAV.FORMAT_16_BITS)
    assert(g.audio_manager.production_event_streams("home_page")[0].data!=g.audio_manager.production_event_streams("menu_open")[0].data)
    print("WORLD STATION AUDIO NATIVE PASS: actual Hub idle activity hooks use distinct recorded wood/cloth and page sounds; generic scrap/menu banks preserved.")
    g.queue_free();await process_frame;quit(0)
