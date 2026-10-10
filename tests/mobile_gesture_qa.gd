extends SceneTree

var game
var failures: Array[String] = []
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("run_qa")
func check(ok: bool, detail: String) -> void:
	if not ok:
		failures.append(detail)
		push_error("GESTURE QA: " + detail)
func event_at(point: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.pressed = pressed
	event.position = root.get_screen_transform()*point-Vector2(root.position)
	Input.parse_input_event(event)
	await process_frame
func tap(point: Vector2) -> void:
	await event_at(point,true)
	await event_at(point,false)
func swipe(point: Vector2, distance: float) -> void:
	await event_at(point,true)
	for step in range(1,9):
		var event := InputEventScreenDrag.new()
		event.index = 0
		event.position = root.get_screen_transform()*(point+Vector2(0,-distance*step/8))-Vector2(root.position)
		event.relative = Vector2(0,-distance/8)
		Input.parse_input_event(event)
		await process_frame
	await event_at(point+Vector2(0,-distance),false)
	await create_timer(.35).timeout
func local(point: Vector2) -> Vector2:
	return game.get_global_transform_with_canvas()*point
func run_qa() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.audio_settings.cinematic_first_time = false
	for size in [Vector2i(360,640),Vector2i(480,1030),Vector2i(1200,1600)]:
		root.size = size
		await create_timer(.15).timeout
		game.safe_area_layout.apply(Rect2(0,24,480,800))
		game.start_run()
		game.player_x = game.target_player_x()
		game.enemy_hp = 100000
		game.enemy_max_hp = 100000
		var count: int = game.attack_sequence
		for point in [Vector2(240,120),Vector2(240,270),Vector2(240,816)]:
			await tap(local(point))
		check(game.attack_sequence == count,"HUD and help touches never attack at " + str(size))
		await swipe(local(Vector2(240,600)),100)
		check(game.attack_sequence == count,"arena swipe never attacks")
		game.tap_input_cooldown = 0
		await tap(local(Vector2(240,620)))
		check(game.attack_sequence == count+1,"deliberate release still attacks promptly")
		game.tap_input_cooldown=0
		await tap(game.combat_controls.attack.get_global_rect().get_center())
		check(game.attack_sequence==count+2,"dedicated Attack release adds exactly one strike")
		game.inventory.stash.clear()
		for index in range(12): game.inventory.stash.append(game.ItemCatalog.create_item("scrapfang_blade","RARE",index+400))
		game.show_hideout()
		game.hideout_ui.show_stash()
		await process_frame
		await process_frame
		var scroll: ScrollContainer = game.hideout_ui.stash_list.get_parent()
		var first: Button = game.hideout_ui.stash_list.get_child(0)
		var selection: int = game.hideout_ui.selected_entry
		var scrap: int = game.inventory.scrap
		await swipe(first.get_global_rect().get_center(),100)
		check(scroll.scroll_vertical > 30,"finger drags content over a card at " + str(size))
		check(game.hideout_ui.selected_entry == selection,"drag release never selects a card")
		check(game.inventory.stash.size() == 12 and game.inventory.scrap == scrap,"swipe never salvages or replaces gear")
		# Release stays inside the same tall button: distance, not hover exit,
		# must distinguish a swipe from a consequential button press.
		var pad := Control.new()
		pad.position = Vector2(20,300)
		pad.size = Vector2(440,150)
		game.hideout_ui.stash_content.add_child(pad)
		var trap := Button.new()
		trap.text = "DRAG MUST NOT ACTIVATE"
		trap.size = pad.size
		pad.add_child(trap)
		trap.pressed.connect(func(): game.inventory.scrap += 100)
		await swipe(trap.get_global_rect().get_center()+Vector2(0,30),40)
		check(game.inventory.scrap == scrap,"drag release inside original button is canceled")
		await tap(trap.get_global_rect().get_center())
		check(game.inventory.scrap == scrap+100,"next deliberate tap is not swallowed or stuck")
		game.inventory.scrap = scrap
		pad.queue_free()
		await process_frame
		var slider := HSlider.new()
		slider.position = Vector2(20,300)
		slider.size = Vector2(440,48)
		slider.value = 20
		game.hideout_ui.stash_content.add_child(slider)
		var slider_start := slider.get_global_rect().position+Vector2(90,24)
		await event_at(slider_start,true)
		for step in range(1,7):
			var drag := InputEventScreenDrag.new()
			drag.index = 0
			drag.position = root.get_screen_transform()*(slider_start+Vector2(step*30,0))-Vector2(root.position)
			drag.relative = Vector2(30,0)
			Input.parse_input_event(drag)
			await process_frame
		await event_at(slider_start+Vector2(180,0),false)
		check(slider.value > 50,"settings-style slider retains native horizontal finger drag")
		slider.queue_free()
		await process_frame
		game.navigate_back()
		if game.hideout_ui.current_screen=="stash":game.navigate_back()
		check(game.hideout_ui.current_screen == "home","Back returns submenu to hub")
		await event_at(local(Vector2(240,740)),true)
		game.touch_ux.request("GUARD TEST","Only CONFIRM should run this action.",func(): game.inventory.scrap += 1)
		await event_at(game.touch_ux.confirm_button.get_global_rect().get_center(),false)
		check(game.inventory.scrap == scrap,"inherited release cannot confirm")
		game.navigate_back()
		check(not is_instance_valid(game.touch_ux.dialog) and game.inventory.scrap == scrap,"Back cancels without spending")
		game.touch_ux.request("LONG DETAILS", "Costs and consequences must remain readable. ".repeat(80),func(): game.inventory.scrap += 1)
		await process_frame
		var details: RichTextLabel = game.touch_ux.dialog.find_children("*","RichTextLabel",true,false)[0]
		await swipe(details.get_global_rect().get_center(),70)
		check(details.get_v_scroll_bar().value > 0,"long confirmation text scrolls from its content")
		game.navigate_back()
		game.inventory.equipped.Weapon = game.ItemCatalog.create_item("scrapfang_blade","RARE",999)
		game.current_item = game.ItemCatalog.create_item("scrapfang_blade","EPIC",1000)
		game.state = "item"
		game.inspect_item_equip()
		check(is_instance_valid(game.touch_ux.dialog) and game.inventory.equipped.Weapon.serial == 999,"full-stash equip explicitly protects old gear")
		game.navigate_back()
	game.free()
	print("MOBILE GESTURE QA %s: actual Window touch/drag, cards, inertia, HUD isolation, deliberate attacks, confirmation debounce, Back and full-stash destruction guard" % ("PASSED" if failures.is_empty() else "FAILED"))
	quit(0 if failures.is_empty() else 1)
