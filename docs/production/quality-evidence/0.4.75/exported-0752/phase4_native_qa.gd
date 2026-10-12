extends SceneTree
var game
var folder := ""
func _initialize() -> void:
	if not preload("C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-fixtures-0752/test_safety.gd").require_isolated(self): return
	assert(DisplayServer.get_name() != "headless")
	OS.set_environment("LOOTLINGS_MOBILE_TEST","1")
	create_timer(100).timeout.connect(func(): push_error("Phase4 native timeout"); quit(1))
	call_deferred("review")
func capture(label: String) -> void:
	await create_timer(.25).timeout
	game.queue_redraw(); await process_frame; await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(folder+label+".png") == OK)
func tap(control: Control) -> void:
	var position: Vector2 = root.get_screen_transform()*control.get_global_rect().get_center()-Vector2(root.position)
	for pressed in [true,false]:
		var event := InputEventScreenTouch.new(); event.index=0; event.pressed=pressed; event.position=position
		Input.parse_input_event(event); Input.flush_buffered_events(); await process_frame
func review() -> void:
	for size in [Vector2i(1080,2316),Vector2i(1600,2560)]:
		root.size=size; game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
		game.set_process(false); game.app_lifecycle.platform_notifications_enabled=false
		folder="C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-0752/phase4a/%dx%d/" % [size.x,size.y]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game.show_hideout(); game.hideout_ui.show_home(); await capture("hub")
		var p=game.expedition_progress
		p.data.fragments.oath_slab=3; p.data.materials.act_i=30; p.data.boss_parts.act_i=2
		p.data.actors.vault_runner=120; p.data.weapons.daggers=120
		game.hideout_ui.show_phase4("blueprints"); await process_frame
		var scroll: ScrollContainer = game.hideout_ui.phase4_list.get_parent()
		await swipe(game.hideout_ui.phase4_list.get_child(0))
		assert(scroll.scroll_vertical > 30 and game.hideout_ui.phase4_selected.is_empty())
		assert(int(p.data.materials.act_i)==30)
		game.touch_ux.inertia=null; scroll.scroll_vertical=0; await process_frame
		await tap(game.hideout_ui.phase4_list.get_child(0)); await capture("blueprint_selected")
		var before: int=game.inventory.stash.size(); var attacks: int=game.attack_sequence
		await tap(game.hideout_ui.phase4_action); await tap(game.hideout_ui.phase4_action)
		assert(game.inventory.stash.size()==before+1 and int(p.data.materials.act_i)==18)
		assert(game.attack_sequence==attacks); await capture("blueprint_forged")
		var job: Dictionary=p.job("act_i")
		p.data.counts[str(job.kind)+":act_i"]=int(p.data.counts.get(str(job.kind)+":act_i",0))+int(job.target)
		game.hideout_ui.show_phase4("contracts"); await process_frame
		await tap(game.hideout_ui.phase4_list.get_child(0)); await capture("bounty")
		await tap(game.hideout_ui.phase4_action); await tap(game.hideout_ui.phase4_action)
		assert(int(p.data.materials.act_i)==24 and game.attack_sequence==attacks)
		game.hideout_ui.show_phase4("archive"); await process_frame
		await tap(game.hideout_ui.phase4_list.get_child(1)); await capture("human_collection")
		game.hideout_ui.show_campaign(); await capture("farming_tiers")
		await tap(game.hideout_ui.tier_buttons[1]); assert(game.expedition_tier==1)
		game.hideout_ui.visible=false; game.startup_ui.visible=false
		for actor in game.Phase4.HUMANS:
			game.profile.avatar_mode="wanderer"; game.profile.wanderer.preset_id=actor
			var family: String=game.Phase4.HUMANS[actor].affinity.split(" / ")[0]
			for item in game.Phase4.ITEMS:
				if item.get("weapon_type","")==family: game.inventory.equip(game.ItemCatalog.create_item(item.id,"RARE",1)); break
			seed(912); game.rng.seed=192; game.start_run(); game.set_process(false); game.wave_banner_timer=0
			game.player_x=game.target_player_x(); game.perform_player_attack(false)
			await capture("human_"+str(actor))
			game.presentation_director.toast_queue.clear(); game.presentation_director.active_toast.clear(); game.presentation_director.toast_panel.visible=false
			for facing in [1,-1]:
				game.player_facing=facing
				for phase in ["windup","release"]:
					game.attack_anim=.22 if phase=="release" else 0.0
					game.attack_clock=.02 if phase=="windup" else game.current_attack_interval()
					await capture("human_%s_%s_%s" % [actor,"right" if facing==1 else "left",phase])
		for id in ["secret_bell","wandering_smith","mimic_parley"]:
			game.event_seen.clear(); p.data.counts.discovery_misses=5
			for trial in range(100):
				var pick:=RandomNumberGenerator.new(); pick.seed=trial
				if ["secret_bell","wandering_smith","mimic_parley"][pick.randi_range(0,2)]==id: p.rng.seed=trial; break
			game.wave=12; game.coins=700; game.show_expedition_event(); assert(game.event_id==id)
			await capture("event_"+id); game.choose_expedition_event(1)
			assert(p.data.seen.has("event:"+id)); game.pending_items.clear()
		game.free(); await process_frame
	print("PHASE4 NATIVE PASS: phone/tablet workshop craft and bounty touch paths; no duplicate payment or combat leak; collection; replay tiers; five humans with affinity weapons; three rare events")
	quit()

func swipe(control: Control) -> void:
	var point: Vector2=control.get_global_rect().get_center()
	var event:=InputEventScreenTouch.new(); event.index=0; event.pressed=true
	event.position=root.get_screen_transform()*point-Vector2(root.position)
	Input.parse_input_event(event); Input.flush_buffered_events(); await process_frame
	for step in range(1,9):
		var drag:=InputEventScreenDrag.new(); drag.index=0
		drag.position=root.get_screen_transform()*(point-Vector2(0,120*step/8))-Vector2(root.position)
		drag.relative=Vector2(0,-15)
		Input.parse_input_event(drag); Input.flush_buffered_events(); await process_frame
	event=InputEventScreenTouch.new(); event.index=0; event.pressed=false
	event.position=root.get_screen_transform()*(point-Vector2(0,120))-Vector2(root.position)
	Input.parse_input_event(event); Input.flush_buffered_events(); await process_frame
