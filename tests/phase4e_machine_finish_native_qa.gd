extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through guarded isolated native helper.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	assert(DisplayServer.get_name()!="headless")
	call_deferred("review")
func review() -> void:
	for dimensions in [Vector2i(1080,2340),Vector2i(1600,2560)]:
		root.size=dimensions
		game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
		game.app_lifecycle.platform_notifications_enabled=false
		folder="res://.godot_test_data/phase4e/machine-finish/%dx%d/" % [dimensions.x,dimensions.y]
		if not OS.get_environment("LOOTLINGS_MACHINE_STAGE").is_empty(): folder="res://.godot_test_data/phase4e/%s/%dx%d/" % [OS.get_environment("LOOTLINGS_MACHINE_STAGE"),dimensions.x,dimensions.y]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game.state="result"; game.coins=1000; game.retention.show_spinner()
		for rarity in preload("res://relic_spin_catalog.gd").TIERS:
			var machine=game.retention.machine
			machine.wind_up("item",rarity,false); machine.set_process(false)
			machine.progress=.7; machine.elapsed=machine.reel_seconds*.7
			machine.queue_redraw(); await capture(rarity.to_lower()+"_rolling")
			game.retention.spin_reward={"kind":"item","rarity":rarity,"amount":1,"display_name":"Gravebloom Staff"}
			game.retention.spin_kind="item"; game.retention.spin_message="FORCED RARITY PREVIEW — no reward granted"
			machine._process(9); machine._process(.001); machine._process(.016)
			assert(machine.stage=="reveal" and machine.burst>.9)
			await capture(rarity.to_lower()+"_delayed_lock")
			machine.progress=1; machine.stage="anticipation"
			machine.elapsed=machine.reel_seconds+preload("res://relic_spin_catalog.gd").anticipation(rarity)*.75
			machine.queue_redraw(); await capture(rarity.to_lower()+"_anticipation")
			game.retention.spin_reward={"kind":"item","rarity":rarity,"amount":1,"display_name":"Gravebloom Staff"}
			game.retention.spin_kind="item"; game.retention.spin_message="FORCED RARITY PREVIEW — no reward granted"
			game.retention.lock_spin(); machine.stage="reveal"; machine.burst=1; machine.queue_redraw()
			await capture(rarity.to_lower()+"_reveal")
		game.retention.machine.stop(); game.free(); await process_frame
	print("MACHINE FINISH NATIVE: all six tiers rolling/anticipation/reveal, phone/tablet"); quit()
