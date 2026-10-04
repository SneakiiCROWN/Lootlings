extends "res://tests/relic_spinner_native_qa.gd"
# extends SceneTree via isolated native helpers; RED-ready card regression.
func review() -> void:
	var dimensions: PackedStringArray=OS.get_environment("LOOTLINGS_CAPTURE_SIZE").split("x")
	var viewport_size:=Vector2i(int(dimensions[0]),int(dimensions[1])); root.size=viewport_size
	game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.app_lifecycle.platform_notifications_enabled=false; game.audio_settings.cinematic_first_time=false
	folder="res://.godot_test_data/spinner/%dx%d/" % [viewport_size.x,viewport_size.y]; DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	game.start_run(); game.set_process(false); game.coins=1000; game.total_kills=20; game.end_run(false)
	game.retention.progress.data.red_fragments=24; game.retention.progress.save(); game.retention.show_spinner(); await create_timer(.22).timeout
	var rng:=RandomNumberGenerator.new()
	for candidate in range(2000):
		rng.seed=candidate
		if Spin.roll(rng).rarity=="COMMON": game.retention.rng.seed=candidate; break
	await tap(game.retention.buttons[0])
	while game.retention.spin_busy: await process_frame
	assert(not game.retention.buttons[4].visible and game.retention.detail.size.y==130 and game.retention.progress.data.spin_wallet==860)
	await capture("red_ready_paid_result"); await tap(game.retention.buttons[1]); game.retention.show_spinner(); await create_timer(.22).timeout
	assert(game.retention.buttons[4].visible); await tap(game.retention.buttons[4])
	while game.retention.machine.stage=="rolling" or game.retention.machine.stage=="anticipation": await process_frame
	await capture("red_burst")
	while game.retention.spin_busy: await process_frame
	assert(game.retention.detail.size.y==130 and game.retention.progress.data.red_fragments==0 and game.retention.progress.data.spin_wallet==860)
	await capture("red_result"); game.free()
	print("RELIC SPINNER CARD NATIVE PASS: RED-ready paid card unobstructed; reopen forge, single fragment debit, premium full-height card"); quit()
