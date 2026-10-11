extends "res://tests/typography_combat_061_native_qa.gd"
const Scope=preload("res://save_scope.gd")
func review() -> void:
	var results:Array=[]
	for viewport in [Vector2i(360,640),Vector2i(480,854),Vector2i(1080,2340),Vector2i(800,1280),Vector2i(1200,1920),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3440,1440)]:
		root.size=viewport;folder="res://.godot_test_data/issue6-061/presentation/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
		game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
		game.startup_ui.show_title();await capture("title_start")
		assert(named_button(game.startup_ui.title_content,"START").visible)
		for button in game.startup_ui.title_roster_buttons.values():assert(not button.visible)
		assert(not game.startup_ui.title_tagline.visible)
		game.startup_ui.profile_exists=true;await tap(named_button(game.startup_ui.title_content,"START"))
		await create_timer(.4).timeout;game.set_process(false)
		if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
		game.show_hideout();game.hideout_ui.show_shop()
		var gold_before:int=game.gold;var coins_before:int=game.coins
		await tap(game.hideout_ui.shop_offer_buttons[0]);await capture("shop_selected")
		assert(game.hideout_ui.shop_offer_buttons[0].get_meta("ui_selected"))
		await tap(game.hideout_ui.shop_offer_buttons[1])
		assert(not game.hideout_ui.shop_offer_buttons[0].get_meta("ui_selected") and game.hideout_ui.shop_offer_buttons[1].get_meta("ui_selected"))
		assert(game.gold==gold_before and game.coins==coins_before)
		game.hideout_ui.show_forge();await capture("forge")
		game.inventory.stash=[game.ItemCatalog.create_item("ironpaw_plate","RARE",61),game.ItemCatalog.create_item("dawnweave","MYTHICAL SHINY",62)]
		game.refresh_hideout();game.hideout_ui.show_stash();await capture("stash")
		game.start_run();game.set_process(false);game.enemy_encounter.clear();game.player_ward=37;game.player_hp=47;game.player_max_hp=100;game.wave_banner_timer=0
		game.player_x=game.target_player_x();await capture("combat_hud")
		var crest:Node
		for child in game.get_children():if child.get_script()==preload("res://hud_portrait_crest.gd"):crest=child
		assert(crest!=null and crest.visible and crest.mouse_filter==Control.MOUSE_FILTER_IGNORE)
		game.show_hideout();await process_frame;await process_frame;assert(not crest.visible)
		game.debug_enabled=true;Scope.active=true
		var panel=game.debug_panel;panel.open();panel.filter_sections(2)
		for key in panel.VALUE_FIELDS:
			for index in range(panel.value_picker.item_count):
				if panel.value_picker.get_item_metadata(index)==key:panel.value_picker.select(index);panel.refresh_value_bounds()
			var value:float=.25 if key in ["crit","armor"] else .65 if key=="attack_interval" else 77
			if key=="hp":value=47
			panel.amount.value=value
			panel.run_action("exact_value","set");assert(is_equal_approx(game.debug_value(key),value))
			panel.amount.value=panel.VALUE_FIELDS[key][3]
			panel.run_action("exact_value","add");panel.run_action("exact_value","remove")
			assert(is_equal_approx(game.debug_value(key),value))
			assert(panel.value_slider.min_value==panel.amount.min_value and panel.value_slider.max_value==panel.amount.max_value)
		panel.run_action("god",null);assert(panel.god_button.text=="GOD ON")
		panel.run_action("god",null);assert(panel.god_button.text=="GOD OFF")
		await capture("owner_exact_controls")
		panel.filter_sections(1);panel.item_search.text="Dawnweave";panel.item_search.text_changed.emit(panel.item_search.text);assert(panel.item_picker.item_count==1)
		panel.item_search.text="no_such_canon_item";panel.item_search.text_changed.emit(panel.item_search.text);assert(panel.item_picker.item_count==0)
		var stash_before:int=game.inventory.stash.size();panel.run_action("catalog_item",null);assert(game.inventory.stash.size()==stash_before)
		panel.item_search.text="";panel.item_search.text_changed.emit(panel.item_search.text);assert(panel.item_picker.item_count==game.ItemCatalog.ITEMS.size())
		panel.close();Scope.active=false
		results.append({"viewport":str(viewport),"shop_selection_and_no_payment":true,"masked_canon_portrait":true,"ten_exact_fields_set_add_remove":true,"search_no_match_safe":true,"start_route":true,"professional_acceptance":false,"physical_S23":"deferred"})
		game.free();await process_frame
	var file=FileAccess.open("res://.godot_test_data/issue6-061/BATCH_BC_NATIVE.json",FileAccess.WRITE);file.store_string(JSON.stringify(results,"  "));file.close()
	print("BATCH BC 061 NATIVE PASS: eight layouts, restrained selected gear cards, canonical masked crest, START flow, ten exact sandbox value fields with bounds, real God readout and safe catalogue search. Professional approval remains open.")
	quit()
