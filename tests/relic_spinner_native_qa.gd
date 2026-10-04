extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree via isolated native touch/capture helpers.
const Spin=preload("res://relic_spin_catalog.gd")
func review() -> void:
	# One fresh process/save namespace per viewport avoids Windows moving an
	# oversized native window between finger press and release after a resize.
	var dimensions: PackedStringArray=OS.get_environment("LOOTLINGS_CAPTURE_SIZE").split("x")
	for viewport_size in [Vector2i(int(dimensions[0]),int(dimensions[1]))]:
		root.size=viewport_size; game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
		game.app_lifecycle.platform_notifications_enabled=false; game.audio_settings.cinematic_first_time=false
		folder="res://.godot_test_data/spinner/%dx%d/" % [viewport_size.x,viewport_size.y]; DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		for rarity in Spin.TIERS:
			game.start_run(); game.set_process(false); game.coins=1000; game.total_kills=20
			var natural_red: bool=rarity=="RED" and viewport_size.x==1600
			if natural_red:
				var red_rng:=RandomNumberGenerator.new()
				for candidate in range(2000):
					red_rng.seed=candidate
					if red_rng.randf()<.01: red_rng.seed=candidate; break
				game.retention.progress.secure_red(1,red_rng)
			game.end_run(false); await process_frame; game.retention.show_spinner()
			await create_timer(.22).timeout
			var attacks: int=game.attack_sequence
			if rarity=="RED" and not natural_red:
				game.retention.progress.data.red_fragments=24; game.retention.progress.save(); game.retention.show_spinner()
				await create_timer(.22).timeout
				await tap(game.retention.buttons[4])
			elif rarity!="RED":
				var rng:=RandomNumberGenerator.new(); var found:=false
				for candidate in range(2000):
					rng.seed=candidate
					if Spin.roll(rng).rarity==rarity: game.retention.rng.seed=candidate; found=true; break
				assert(found)
				await tap(game.retention.buttons[0])
			if not game.retention.spin_busy or game.retention.machine.rarity!=rarity:
				print("SPINNER TAP DIAGNOSTIC "+JSON.stringify({"viewport":str(viewport_size),"expected":rarity,"actual":game.retention.machine.rarity,"state":game.state,"wallet":game.retention.progress.data.spin_wallet,"pending":game.retention.progress.data.pending,"button_disabled":game.retention.buttons[0].disabled}))
				await capture("failed_tap"); push_error("Native spinner tap failed"); quit(1); return
			await tap(game.retention.buttons[0]); assert(game.retention.progress.data.spins==0 if rarity=="RED" else game.retention.progress.data.spins==1)
			if rarity=="COMMON": await capture("rolling")
			if rarity=="RED":
				game.app_lifecycle.suspend(); var paused_elapsed: float=game.retention.machine.elapsed
				await create_timer(.15).timeout; assert(game.retention.machine.elapsed==paused_elapsed)
				game.app_lifecycle.restore_focus(); assert(game.retention.spin_busy)
			var samples:=[]; var last: int=Time.get_ticks_usec()
			while game.retention.machine.stage=="rolling":
				await process_frame
				var now: int=Time.get_ticks_usec(); samples.append((now-last)/1000.0); last=now
			samples.sort()
			if samples.size()>10: print("SPINNER ROLL FRAMES "+JSON.stringify({"viewport":str(viewport_size),"rarity":rarity,"frames":samples.size(),"median_ms":samples[samples.size()/2],"p95_ms":samples[int(samples.size()*.95)]}))
			if rarity=="RED": await capture("red_anticipation")
			while game.retention.machine.stage=="anticipation": await process_frame
			await capture(rarity.to_lower()+"_burst")
			while game.retention.spin_busy: await process_frame
			assert(game.audio_manager.last_event_msec.has(Spin.sound(rarity)))
			if rarity=="RED": assert(game.audio_manager.last_event_msec.has("legendary_reveal"))
			assert(game.attack_sequence==attacks and not game.retention.buttons[1].disabled)
			await capture(rarity.to_lower()+"_result")
			if rarity=="COMMON":
				await tap(game.retention.buttons[3]); assert(game.retention.pool_panel.visible); await capture("pool")
				game.navigate_back(); assert(not game.retention.pool_panel.visible)
				await create_timer(.22).timeout
				# The next low spin is fast and Skip does not debit twice.
				game.retention.rng.seed=0
				while true:
					var saved: int=game.retention.rng.state
					var reward: Dictionary=Spin.roll(game.retention.rng)
					if Spin.tier(reward.rarity)<3: game.retention.rng.state=saved; break
				await tap(game.retention.buttons[0]); assert(game.retention.machine.fast)
				await create_timer(.20).timeout
				await tap(game.retention.buttons[2]); assert(not game.retention.spin_busy)
				assert(game.retention.progress.data.spin_wallet==630 and game.retention.progress.data.spins==2)
				await capture("fast_skip")
			await tap(game.retention.buttons[1]); assert(game.state=="result" and not game.retention.dimmer.visible)
		# Native reduced-motion premium still retains its timing/card with no shake/punch.
		game.audio_settings.cinematic_reduced_motion=true; game.coins=1000; game.total_kills=20; game.retention.progress.data.red_fragments=24; game.retention.progress.save()
		game.retention.show_spinner(); await create_timer(.22).timeout; await tap(game.retention.buttons[4]); assert(game.retention.machine.reduced_motion)
		while game.retention.spin_busy: await process_frame
		await capture("reduced_red"); await sample_performance("spinner_settled",false)
		game.free(); await process_frame
	print("RELIC SPINNER NATIVE PASS: six real reward tiers, phone/tablet, passing reels/anticipation/bursts/cards, pool, paid wallet, fast/skip, duplicate touches, no attacks, RED forge and reduced motion"); quit()
