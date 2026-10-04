extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through isolated native helpers.
func review() -> void:
	for size in [Vector2i(1080,2316),Vector2i(1600,2560)]:
		root.size=size; game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
		game.app_lifecycle.platform_notifications_enabled=false; game.audio_settings.cinematic_first_time=false
		game.start_run(); game.set_process(false); game.coins=1000; game.total_kills=20; game.end_run(false); game.retention.show_spinner(); game.retention.selected_at=0
		folder="res://.godot_test_data/phase4c/after/%dx%d/" % [size.x,size.y]
		await tap(game.retention.buttons[0]); assert(game.retention.progress.data.spin_wallet==860)
		assert(game.retention.panel.get_node("Wallet").text.contains("860") and game.retention.panel.get_node("Wallet").text.contains("2 spins"))
		await capture("spinner_windup"); await create_timer(.9).timeout; await capture("spinner_reveal")
		game.free(); await process_frame
	print("PHASE4C SPINNER NATIVE PASS: wallet and remaining spins update immediately before reveal, both viewport sizes"); quit()
