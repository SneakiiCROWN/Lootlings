extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through guarded native UI helper.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	assert(DisplayServer.get_name()!="headless")
	call_deferred("review")
func review() -> void:
	for dimensions in [Vector2i(1080,2340),Vector2i(1600,2560)]:
		root.size=dimensions; game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
		game.app_lifecycle.platform_notifications_enabled=false; game.set_process(false)
		game.startup_ui.visible=false; game.hideout_ui.visible=false; game.state="result"
		game.coins=0; game.retention.show_spinner()
		assert(game.retention.panel.visible)
		folder="res://.godot_test_data/phase4e/acceptance-final/%dx%d/" % [dimensions.x,dimensions.y]
		await capture("spinner_disabled_state")
		game.free(); await process_frame
	print("PHASE4E UI: actual spinner disabled state captured on phone and tablet"); quit()
