extends "res://tests/phase4b_native_qa.gd"
const Presentation=preload("res://perk_presentation.gd")
func review() -> void:
	for viewport in [Vector2i(360,640),Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
		root.size=viewport;folder="res://.godot_test_data/perk065/%dx%d/" % [viewport.x,viewport.y]
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
		game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
		game.start_run();game.set_process(false);game.pending_levels=1
		game.life_steal=.06;game.crit_chance=.68;game.execute_ratio=.30
		var rng_state: int=game.rng.state
		for id in ["vamp","crit","execute"]:
			var up: Dictionary=game.UPGRADES.filter(func(u):return u.id==id)[0]
			var text: String=Presentation.effect(game,up)
			assert(not text.is_empty() and game.rng.state==rng_state)
		assert(Presentation.effect(game,{"id":"vamp"}).contains("6.0% → 8.0%"))
		assert(Presentation.effect(game,{"id":"execute"}).contains("30% → 35%"))
		game.show_upgrade_choices();game._process(0);await create_timer(.3).timeout
		var attacks: int=game.attack_sequence
		for index in range(3):
			var id: String=["vamp","crit","execute"][index]
			var up: Dictionary=game.UPGRADES.filter(func(u):return u.id==id)[0].duplicate(true)
			game.selected_upgrades[index]=up
			game.refresh_upgrade_card(index,up)
			assert(game.upgrade_buttons[index].size.x<=game.upgrade_panel.size.x-40)
			assert(game.upgrade_visuals[index].effect.get_line_count()<=3)
		for up in game.UPGRADES:
			game.refresh_upgrade_card(0,up)
			await process_frame
			assert(game.upgrade_visuals[0].name.get_visible_line_count()==game.upgrade_visuals[0].name.get_line_count())
			assert(game.upgrade_visuals[0].effect.get_visible_line_count()==game.upgrade_visuals[0].effect.get_line_count())
		game.refresh_upgrade_card(0,game.selected_upgrades[0])
		await tap(game.upgrade_buttons[0]);assert(game.upgrade_selection==0 and game.upgrade_compare.text.contains("8.0%"))
		assert(game.upgrade_visuals[0].name.get_visible_line_count()==1)
		assert(game.upgrade_visuals[0].effect.get_visible_line_count()==2)
		await capture("capped_perks")
		await tap(game.upgrade_buttons[2]);assert(game.upgrade_selection==2 and game.upgrade_compare.text.contains("35%"))
		await create_timer(.2).timeout;await tap(game.upgrade_take_button)
		assert(is_equal_approx(game.execute_ratio,.35) and is_equal_approx(game.life_steal,.06))
		assert(game.attack_sequence==attacks)
		game.free();await process_frame
	print("PERK CLARITY 065 NATIVE PASS: capped effects, four layouts, real selection/confirmation and modal combat isolation.")
	quit()
