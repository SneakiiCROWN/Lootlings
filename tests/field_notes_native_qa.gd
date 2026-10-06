extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through isolated native fixture.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	assert(DisplayServer.get_name()!="headless"); call_deferred("review_notes")
func review_notes() -> void:
	game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.set_process(false); game.app_lifecycle.platform_notifications_enabled=false
	game.inventory.keep(preload("res://item_catalog.gd").create_item("bonebow","RED",7))
	game.profile.memories=["boss/hoard_dragon","resident/patch","region/act_i"]
	for layout in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=layout
		folder="res://.godot_test_data/phase4e/full-continuation/"+str(layout.x)+"x"+str(layout.y)+"/"; DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game.show_hideout(); game.hideout_ui.show_lore(); await capture("field_notes_crownfall")
		for category in ["CAST","TRAILS","BOSSES","GEAR"]:
			var button: Button=game.hideout_ui.lore_filter_buttons[preload("res://field_notes_catalog.gd").CATEGORIES.find(category)]
			await tap(button); assert(game.hideout_ui.lore_filter==category)
			await capture("field_notes_"+category.to_lower())
		game.hideout_ui.show_memories(); await capture("memory_cards")
		for actor in preload("res://lootling_catalog.gd").selectable_ids():
			game.profile.current_lootling_id=actor; game.show_hideout(); game.hideout_ui.show_home()
			assert(game.hideout_ui.actor_texture()==preload("res://phase4e_extracted_art.gd").neutral_body(actor))
			await capture("home_"+actor)
			game.replay_memory("character/"+actor); await capture("memory_"+actor)
			assert(game.presentation_director.vignette.actor==preload("res://phase4e_extracted_art.gd").neutral_body(actor))
			game.presentation_director.vignette.cancel()
		var completed: Array=game.campaign.completed.duplicate()
		# Forced discovery fixtures test existing replay UI; no campaign save writes.
		for region in preload("res://vignette_catalog.gd").REGIONAL_BOSS_IDS:
			game.campaign.completed=[region]
			var boss: String=preload("res://vignette_catalog.gd").REGIONAL_BOSS_IDS[region]
			game.replay_memory("boss/"+boss); assert(game.presentation_director.vignette.active)
			assert(game.presentation_director.vignette.actor==null)
			await capture("boss_account_"+boss)
			game.presentation_director.vignette.elapsed=game.presentation_director.vignette.duration*.55
			game.presentation_director.vignette.update_caption()
			await capture("boss_account_"+boss+"_story")
			game.presentation_director.vignette.cancel()
		game.campaign.completed=completed
		game.hideout_ui.show_campaign(); await tap(game.hideout_ui.campaign_list.get_child(0)); assert(game.hideout_ui.region_sheet.visible)
		await capture("region_preview")
		game.hideout_ui.show_shop(); game.hideout_ui.select_shop_offer(0); await capture("merchant_comparison_top")
		await process_frame
		assert(game.hideout_ui.shop_detail.get_v_scroll_bar().max_value>game.hideout_ui.shop_detail.size.y)
		var balance: int=game.inventory.scrap
		await swipe_text(game.hideout_ui.shop_detail)
		assert(game.hideout_ui.shop_detail.get_v_scroll_bar().value>0 and game.inventory.scrap==balance)
		game.hideout_ui.shop_detail.scroll_to_line(999); await capture("merchant_comparison_bottom")
		assert(game.inventory.scrap==balance)
		game.hideout_ui.show_home(); await capture("home_return")
		game.start_run(); game.set_process(false)
		game.loot_drops=[{"item":preload("res://item_catalog.gd").create_item("bonebow","RED",7),"rarity":"RED","color":preload("res://item_catalog.gd").rarity_color("RED"),"pos":Vector2(330,455),"pickup":.5,"bounces":1}]
		await capture("red_drop_combat")
		game.pending_items=[preload("res://item_catalog.gd").create_item("bonebow","RED",7)]
		game.show_next_item(); await capture("red_bow_reward")
	game.free(); print("FIELD NOTES NATIVE PASS: phone/tablet real category taps, notes, memories, Home return, RED reward"); quit()

func swipe_text(control: Control) -> void:
	var start: Vector2=control.get_global_rect().get_center()+Vector2(0,32)
	var transform:=root.get_screen_transform()
	var down:=InputEventScreenTouch.new(); down.index=0; down.pressed=true
	down.position=transform*start-Vector2(root.position); Input.parse_input_event(down); await process_frame
	for step in range(1,9):
		var drag:=InputEventScreenDrag.new(); drag.index=0
		drag.position=transform*(start-Vector2(0,step*8))-Vector2(root.position)
		drag.relative=Vector2(0,-8); Input.parse_input_event(drag); await process_frame
	var up:=InputEventScreenTouch.new(); up.index=0; up.pressed=false
	up.position=transform*(start-Vector2(0,64))-Vector2(root.position); Input.parse_input_event(up)
	await create_timer(.35).timeout
