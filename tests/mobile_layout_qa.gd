extends SceneTree

const DESIGN := Vector2(480, 854)
var game
var failures: Array[String] = []
var observations: Array = []
var capture_sizes := {}

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("run_qa")

func check(ok: bool, detail: String) -> void:
	if not ok:
		failures.append(detail)
		push_error("MOBILE LAYOUT QA: " + detail)

func run_qa() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.app_lifecycle.platform_notifications_enabled = false
	game.audio_settings.cinematic_first_time = false
	var diagnostics_enabled := OS.get_environment("LOOTLINGS_MOBILE_TEST") == "1"
	check(is_instance_valid(game.mobile_test_monitor) == diagnostics_enabled,"test reporter follows explicit feature gate")
	if diagnostics_enabled:
		await validate_monitor_startup()
	for size in [Vector2i(480,854), Vector2i(480,1030), Vector2i(720,1544), Vector2i(360,640),Vector2i(800,1280),Vector2i(1200,1600),Vector2i(1200,1920)]:
		root.size = size
		await create_timer(0.2).timeout
		await process_frame
		for notch in [false, true]:
			var logical_safe := Rect2(0,24,480,800) if notch else Rect2(Vector2.ZERO, DESIGN)
			game.safe_area_layout.apply(logical_safe)
			game.start_run()
			await process_frame
			var label := "%dx%d_%s" % [size.x,size.y,"notch" if notch else "full"]
			var transform: Transform2D = game.get_global_transform_with_canvas()
			check(is_equal_approx(transform.x.length(), transform.y.length()), label + " uniform root scale")
			var frame := Rect2(transform * Vector2.ZERO, transform.basis_xform(DESIGN))
			check(logical_safe.encloses(frame.grow(-0.05)), label + " root frame inside safe bounds")
			check(root.get_visible_rect().size.is_equal_approx(DESIGN), label + " fixed canvas dimensions")
			check_control(game.pause_button, logical_safe, label + " Pause")
			check_rect(Rect2(18,106,444,25), logical_safe, label + " HUD HP")
			await tap_control(game.pause_button)
			check(game.state == "paused", label + " actual touch Pause")
			var resume := button_named(game.pause_panel,"RESUME")
			check(resume != null, label + " Resume button exists")
			if resume != null:
				check_control(resume,logical_safe,label + " Resume")
				await tap_control(resume)
				check(game.state == "playing",label + " actual touch Resume")
			# Actual touch-coordinate conversion selects the right pack actor.
			game.grouped_patrols = true
			game.wave = 2
			game.wave_kills = 0
			game.spawn_enemy()
			check(game.enemy_encounter.active,label + " grouped fixture active")
			game.tap_input_cooldown = 0.0
			await tap_local(game.enemy_encounter.position(1))
			check(game.enemy_encounter.selected == 1,label + " scaled touch selects second foe")
			# Two touches inside cooldown must cause only one real attack.
			game.grouped_patrols = false
			game.wave = 1
			game.spawn_enemy()
			game.player_x = game.target_player_x()
			game.enemy_hp = 100000.0
			game.enemy_max_hp = 100000.0
			game.tap_input_cooldown = 0.0
			var attacks: int = game.attack_sequence
			await tap_local(Vector2(240,620))
			await tap_local(Vector2(240,620))
			check(game.attack_sequence == attacks + 1,label + " rapid touch cooldown gives one attack")
			if notch:
				var before: int = game.attack_sequence
				game.tap_input_cooldown = 0.0
				await tap_canvas(Vector2(240,10))
				check(game.attack_sequence == before,label + " outside safe frame ignored")
			game.boss_reward_options.clear()
			for index in range(3):
				game.boss_reward_options.append(game.ItemCatalog.create_item(["scrapfang_blade","patchplate_vest","echo_rune"][index],"EPIC",9000 + index))
			game.show_boss_reward()
			await create_timer(0.4).timeout
			for button in game.boss_reward_buttons: check_control(button,logical_safe,label + " reward card")
			await capture(label + "_rewards")
			await tap_control(game.boss_reward_buttons[1])
			check(game.state == "boss_reward",label + " reward tap inspects without choosing")
			await create_timer(.2).timeout
			await tap_control(game.touch_ux.confirm_button)
			check(game.state == "item" and game.current_item.serial == 9001,label + " actual touch reward selection")
			game.accept_item_scrap()
			game.wave = 6
			game.coins = 1000
			game.show_merchant()
			await create_timer(0.4).timeout
			check_control(game.merchant_continue_button,logical_safe,label + " merchant Continue")
			for button in game.merchant_buttons:
				if button.visible: check_control(button,logical_safe,label + " merchant buy")
			var price: int = game.shop.stock[0].price
			var scrip: int = game.coins
			var buy_position: Vector2 = game.merchant_buttons[0].get_global_rect().get_center()
			await tap_canvas(buy_position)
			await tap_canvas(buy_position)
			check(game.coins == scrip,label + " offer taps inspect without spending")
			await create_timer(.2).timeout
			await tap_control(game.touch_ux.confirm_button)
			check(game.coins == scrip - price and game.state == "item",label + " two taps buy once")
			game.accept_item_scrap()
			game.show_hideout()
			await create_timer(0.1).timeout
			check_control(game.hideout_ui,logical_safe,label + " Hideout")
			await capture(label + "_hideout")
			if diagnostics_enabled:
				game.mobile_test_monitor.show_report()
				await process_frame
				var report_box: PanelContainer
				for child in game.mobile_test_monitor.report_panel.get_children():
					if child is PanelContainer: report_box = child
				check(report_box != null,label + " report panel exists")
				if report_box != null:
					check_control(report_box,logical_safe,label + " test report")
					for child in report_box.get_child(0).get_children():
						if child is Control: check_control(child,logical_safe,label + " test report child")
				if size == Vector2i(480,854) and notch: await capture("test_report")
				game.mobile_test_monitor.report_panel.queue_free()
				await process_frame
			var screen: Transform2D = root.get_screen_transform()
			# Pixel-rounded letterbox width can differ by < 0.25% at tiny sizes.
			check(absf(screen.x.length()/screen.y.length()-1.0) < 0.0025,label + " uniform physical stretch within pixel rounding")
			observations.append({"window":str(root.size),"canvas":str(root.get_visible_rect()),"screen_transform":str(screen),"root_transform":str(transform),"safe_frame":str(frame),"texture_size":str(root.get_texture().get_size()),"label":label})
	if diagnostics_enabled: await validate_monitor_lifecycle()
	game.free()
	print("MOBILE_LAYOUT_OBSERVATIONS " + JSON.stringify(observations))
	print("MOBILE_CAPTURE_SIZES " + JSON.stringify(capture_sizes))
	print("MOBILE LAYOUT QA %s: fourteen native size/safe-area scenarios, real ScreenTouch UI/target/cooldown/purchase routing; handset acceptance pending" % ("PASSED" if failures.is_empty() else "FAILED"))
	quit(0 if failures.is_empty() else 1)

func check_rect(local_rect: Rect2,safe: Rect2,label: String) -> void:
	var t: Transform2D = game.get_global_transform_with_canvas()
	var actual := Rect2(t * local_rect.position,t.basis_xform(local_rect.size))
	check(safe.encloses(actual.grow(-0.05)),label + " inside safe frame")

func validate_monitor_startup() -> void:
	var monitor = game.mobile_test_monitor
	await process_frame
	check(game.state == "boot","fresh disposable profile presents actual boot state")
	check(monitor.first_menu_ms >= 0.0,"first menu metric recognizes actual boot startup state")
	monitor.checkpoint("qa_startup")
	var stored: Variant = JSON.parse_string(FileAccess.get_file_as_string(monitor.REPORT_PATH))
	check(stored is Dictionary and stored.get("test_build",false),"gated reporter writes valid user JSON")
	if stored is Dictionary:
		check(stored.loading_node_to_first_menu_ms >= 0.0,"persisted loading metric is initialized")
		check(stored.state == game.state,"report state matches actual startup state")

func validate_monitor_lifecycle() -> void:
	var monitor = game.mobile_test_monitor
	game.safe_area_layout.apply(Rect2(Vector2.ZERO,DESIGN))
	game.start_run()
	await process_frame
	var before_out: int = monitor.lifecycle.focus_out
	var before_in: int = monitor.lifecycle.focus_in
	monitor._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	game.app_lifecycle.suspend()
	check(paused and game.state == "paused","synthetic focus loss safely suspends playing tree")
	check(monitor.previous_usec == 0,"focus loss excludes background time from frame samples")
	monitor._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	monitor._notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	monitor._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	game.app_lifecycle.restore_focus()
	check(not paused and game.state == "paused","focus return restores tree and retains player Pause decision")
	check(monitor.lifecycle.focus_out == before_out + 1 and monitor.lifecycle.focus_in == before_in + 1,"report records synthetic focus pair")
	check(monitor.lifecycle.paused > 0 and monitor.lifecycle.resumed > 0,"report records pause/resume notifications")
	game.resume_run()
	await process_frame
	check(game.state == "playing","Resume works after synthetic focus restoration")
	for index in range(24): monitor.checkpoint("qa_bounded_%d" % index)
	check(monitor.contexts.size() == 16,"recent report context list remains bounded")
	check(monitor.histogram.size() == 251 and monitor.combat_histogram.size() == 251,"frame histograms remain fixed-sized")
	var total := 0
	var combat_total := 0
	for bucket in monitor.histogram: total += bucket
	for bucket in monitor.combat_histogram: combat_total += bucket
	check(total == monitor.sample_count and combat_total == monitor.combat_samples,"histogram totals match sample counters")
	check(monitor.sample_count > 0 and monitor.combat_samples > 0 and monitor.combat_samples <= monitor.sample_count,"frame samples include bounded combat subset")
	var stored: Variant = JSON.parse_string(FileAccess.get_file_as_string(monitor.REPORT_PATH))
	check(stored is Dictionary,"final user report JSON parses")
	if stored is Dictionary:
		check(stored.recent_contexts.size() == 16 and stored.samples >= stored.combat_samples,"serialized report bounded counters/context")

func check_control(control: Control,safe: Rect2,label: String) -> void:
	var transform := control.get_global_transform_with_canvas()
	var actual := Rect2(transform * Vector2.ZERO,transform.basis_xform(control.size))
	check(safe.encloses(actual.grow(-0.05)),label + " actual Control including CanvasLayer inside safe frame")

func button_named(parent: Node,text: String) -> Button:
	for child in parent.get_children():
		if child is Button and child.text == text: return child
	return null

func tap_control(control: Control) -> void:
	await tap_canvas(control.get_global_rect().get_center())

func tap_local(point: Vector2) -> void:
	await tap_canvas(game.get_global_transform_with_canvas() * point)

func tap_canvas(point: Vector2) -> void:
	var press := InputEventScreenTouch.new()
	press.index = 0
	press.pressed = true
	# parse_input_event follows the native Window input path: coordinates are
	# physical window pixels, including letterbox offsets, then Godot applies
	# the stretch transform before dispatching GUI and unhandled touch input.
	var physical := root.get_screen_transform() * point - Vector2(root.position)
	press.position = physical
	Input.parse_input_event(press)
	await process_frame
	var release := InputEventScreenTouch.new()
	release.index = 0
	release.pressed = false
	release.position = physical
	Input.parse_input_event(release)
	await process_frame

func capture(label: String) -> void:
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	var shot := root.get_texture().get_image()
	capture_sizes[label] = str(shot.get_size())
	check(shot.save_png("res://.godot_test_data/mobile_%s.png" % label) == OK,label + " capture")
