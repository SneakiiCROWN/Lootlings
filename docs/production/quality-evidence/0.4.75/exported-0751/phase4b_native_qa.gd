extends "C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-fixtures-0751/phase4_native_qa.gd"
# extends SceneTree through the isolated native capture helper.
func review() -> void:
	for size in [Vector2i(1080,2316),Vector2i(1600,2560)]:
		root.size=size; game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
		game.set_process(false); game.app_lifecycle.platform_notifications_enabled=false; game.audio_settings.cinematic_first_time=false
		folder="C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-0751/phase4b/%dx%d/" % [size.x,size.y]; DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game.show_hideout(); game.hideout_ui.show_campaign(); await capture("mode_entry")
		await tap(game.hideout_ui.dungeon_start_button); assert(game.state=="mode_menu"); await capture("modes")
		var previous: String=game.retention.progress.data.tracked
		await swipe(game.retention.buttons[3]); assert(game.retention.progress.data.tracked==previous); game.touch_ux.inertia=null
		await tap(game.retention.buttons[3]); assert(game.retention.progress.data.tracked=="gravebloom_staff"); await capture("tracked")
		await tap(game.retention.buttons[0]); await create_timer(1).timeout; assert(game.state=="playing" and game.retention.siege)
		game.set_process(false); game.wave_banner_timer=0; game.player_x=game.target_player_x(); game.perform_player_attack(false); await capture("siege_combat"); await sample_performance("siege_open")
		var attacks: int=game.attack_sequence
		game.wave=10; game.wave_kills=0; game.retention.round_rule=game.retention.Catalog.round_rule(10,game.retention.rng); game.spawn_enemy(); await capture("boss_checkpoint_combat"); await sample_performance("boss_checkpoint"); attacks=game.attack_sequence
		game.kill_enemy(); game.loot_drops.clear(); game.pending_items.clear(); await capture("extract_or_continue")
		await tap(game.retention.buttons[1]); assert(game.wave==11 and game.state=="playing" and game.attack_sequence==attacks)
		game.wave=20; game.wave_kills=0; game.retention.round_rule=game.retention.Catalog.round_rule(20,game.retention.rng); game.spawn_enemy(); game.kill_enemy(); game.loot_drops.clear(); game.pending_items.clear()
		game.total_kills=65; game.coins=1000; await capture("deep_extraction")
		await tap(game.retention.buttons[0]); assert(game.state=="result")
		await capture("siege_result"); await tap(game.retention.spinner_button); await capture("spinner")
		var wallet: int=game.retention.progress.data.spin_wallet
		await tap(game.retention.buttons[0]); await tap(game.retention.buttons[0]); assert(game.retention.progress.data.spin_wallet==wallet)
		while game.retention.spin_busy: await create_timer(.1).timeout
		await capture("spinner_reward"); await tap(game.retention.buttons[1]); assert(game.state=="result" and game.attack_sequence==attacks)
		game.show_hideout(); game.campaign.finish("act_i"); game.retention.show_modes("dungeons"); await capture("dungeon_offer"); await tap(game.retention.buttons[1]); await create_timer(1).timeout
		assert(game.state=="route" and game.retention.targeted and game.campaign_id=="mossglass_wilds"); await capture("target_dungeon_route")
		game.show_hideout(); game.hideout_ui.show_phase4("archive"); await process_frame
		await swipe(game.hideout_ui.phase4_list.get_child(0)); game.touch_ux.inertia=null; await process_frame
		await tap(game.hideout_ui.phase4_list.get_child(5)); assert(game.hideout_ui.phase4_detail.text.contains("Highest round")); await capture("siege_archive"); await sample_performance("archive_scroll",false)
		game.retention.progress.data.red_fragments=24; game.retention.progress.save(); game.hideout_ui.show_home(); game.retention.show_modes(); await capture("red_forge")
		await tap(game.retention.buttons[3]); assert(game.inventory.stash.any(func(item): return item.id=="gravebloom_staff" and item.rarity=="RED"))
		game.show_hideout(); assert(not game.retention.siege and not game.retention.targeted)
		game.hideout_ui.show_home(); await capture("ordinary_return")
		await tap(game.hideout_ui.hub_navigation.buttons.gate); await process_frame
		assert(game.state=="hideout" and game.hideout_ui.current_screen=="campaign"); await capture("ordinary_destinations")
		var region: Button=game.hideout_ui.campaign_list.get_child(0)
		await tap(region); await process_frame
		assert(game.hideout_ui.region_sheet.visible)
		await tap(game.hideout_ui.region_depart); await create_timer(1).timeout
		assert(game.state=="playing" and not game.retention.siege and not game.dungeon.active and game.coins==0)
		game.set_process(false); print("PHASE4B DESKTOP MONITORS "+JSON.stringify({"viewport":str(size),"fps":Performance.get_monitor(Performance.TIME_FPS),"texture_bytes":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED),"static_bytes":Performance.get_monitor(Performance.MEMORY_STATIC),"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)})); game.pause_run(); await capture("ordinary_pause"); game.resume_run(); assert(game.state=="playing")
		game.end_run(false); var paid: int=game.gold; game.state="relic_spinner"; game.end_run(false); assert(game.gold==paid)
		game.free(); await process_frame
	print("PHASE4B NATIVE PASS: phone/tablet modes, Siege boss/extraction, retired paid-spinner wallet unchanged/tap isolation, target dungeon, tracked source, Archive, RED forge")
	quit()

# Use a human-duration finger contact in the existing window-to-viewport coordinate contract.
func tap(control: Control) -> void:
	root.grab_focus(); await process_frame
	var point: Vector2=root.get_screen_transform()*control.get_global_rect().get_center()-Vector2(root.position)
	var motion:=InputEventMouseMotion.new(); motion.position=point; Input.parse_input_event(motion); Input.flush_buffered_events(); await process_frame
	var event:=InputEventScreenTouch.new(); event.index=0; event.pressed=true; event.position=point
	Input.parse_input_event(event); Input.flush_buffered_events(); await create_timer(.07).timeout
	event=InputEventScreenTouch.new(); event.index=0; event.pressed=false; event.position=point
	Input.parse_input_event(event); Input.flush_buffered_events(); await process_frame; await process_frame

func sample_performance(label: String, combat: bool=true) -> void:
	var samples:=[]; var last: int=Time.get_ticks_usec()
	game.set_process(combat)
	for frame in range(90):
		await process_frame
		var now: int=Time.get_ticks_usec(); samples.append((now-last)/1000.0); last=now
	game.set_process(false); samples.sort()
	print("PHASE4B FRAME SAMPLE "+JSON.stringify({"label":label,"viewport":str(root.size),"frames":samples.size(),"median_ms":samples[45],"p95_ms":samples[85],"max_ms":samples.back(),"texture_bytes":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED),"static_bytes":Performance.get_monitor(Performance.MEMORY_STATIC),"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)}))
