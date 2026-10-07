extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree via disposable native capture helper; previews grant no rewards.
const UI=preload("res://lootlings_ui.gd")
const Items=preload("res://item_catalog.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	assert(DisplayServer.get_name()!="headless");call_deferred("review_content")
func review_content() -> void:
	game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
	var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
	game.campaign.completed=preload("res://campaign_system.gd").ORDER.duplicate()
	for id in UI.CANON_RELIC_ART:
		var item=Items.create_item(id,"EPIC",171);assert(not item.is_empty(),"Art must route an actual game ID")
		var unchanged=item.duplicate(true);assert(UI.item_texture(item).resource_path.ends_with(UI.CANON_RELIC_ART[id]+".png"));assert(item==unchanged)
	assert(UI.icon("currency_run_scrip").resource_path.ends_with("currency_run_scrip.png"),"Gold art cannot impersonate Run Scrip")
	for layout in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=layout;folder="res://.godot_test_data/canon-content/native-final/%dx%d/" % [layout.x,layout.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game.show_hideout();await capture("home_currencies")
		game.hideout_ui.show_shop();await capture("merchant_currencies")
		game.inventory.keep(Items.create_item("gilded_debt","EPIC",179))
		game.hideout_ui.show_lore();game.hideout_ui.lore_filter="GEAR";game.hideout_ui.refresh_lore()
		for i in range(game.hideout_ui.lore_entries.size()):
			if game.hideout_ui.lore_entries[i].name=="Gilded Debt":game.hideout_ui.lore_index=i;game.hideout_ui.cycle_lore(0)
		await capture("notes_owned_relic")
		game.hideout_ui.hide();game.dungeon.setup(4917,"moonfen");game.campaign_id="moonfen";game.start_run();game.set_process(false)
		for depth in [0,3,6]:
			var kind: String={0:"Rest",3:"Risk",6:"Boss"}[depth]
			game.dungeon.depth=depth;assert(game.dungeon.choices().any(func(room):return room.kind==kind))
			game.show_route_choices();await capture("dungeon_"+kind.to_lower())
		game.dungeon.active=false;game.route_panel.hide()
		for id in UI.CANON_RELIC_ART:
			game.pending_items=[Items.create_item(id,"EPIC",180)];game.state="playing";game.show_next_item();await capture("reward_"+id)
		for identity in ["Lightning","Poison","Frost"]:
			helper.prepare("glimmerfin","orb");game.forced_facing_test=0;game.enemy_entry_anim=0
			game.presentation_director.set_process(false);game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.hide()
			game.projectile_impacts=[{"pos":game.target_combat_visual_position(),"life":.21,"element":identity,"weapon_type":"orb","direction":Vector2.RIGHT}]
			game.attack_projectiles=[{"pos":Vector2(240,game.target_combat_visual_position().y-29),"start":Vector2(150,game.target_combat_visual_position().y-29),"target":game.target_combat_visual_position(),"family":"MAGE","weapon_type":"orb","element":identity}]
			game.attack_anim=.18;await capture("spell_"+identity.to_lower())
		game.attack_projectiles.clear();game.projectile_impacts.clear();game.state="result";game.retention.show_spinner()
		for tier in preload("res://relic_spin_catalog.gd").TIERS:
			assert(preload("res://relic_spin_catalog.gd").icon_for("mastery")=="currency_star_shard")
			game.retention.machine.wind_up("mastery",tier,false);game.retention.machine.set_process(false);game.retention.machine.stage="reveal";game.retention.machine.burst=.85;game.retention.machine.queue_redraw()
			game.retention.detail.text="[center]FORCED RARITY PREVIEW • no reward granted[/center]";await capture("spinner_"+tier.to_lower())
		game.retention.machine.stop()
	helper.free();game.free();await process_frame;await process_frame
	print("CANON CONTENT PASS: actual relic IDs, immutable item data, separate Gold/Scrip, phone/tablet source props/Notes/rewards/spells and six-tier previews");quit()
