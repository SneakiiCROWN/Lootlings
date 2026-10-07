extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree via native helper; disposable profile, forced visual previews.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	assert(DisplayServer.get_name()!="headless");call_deferred("review_bible")
func review_bible() -> void:
	game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
	game.campaign.completed=preload("res://campaign_system.gd").ORDER.duplicate()
	game.profile.memories=["region/act_i","resident/patch","resident/sera","resident/ilex"]
	var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
	for layout in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=layout;folder="res://.godot_test_data/phase4e/bible-runtime/native/%dx%d/" % [layout.x,layout.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game.show_hideout();await capture("home_props")
		game.hideout_ui.request_dialogue("tapped","Archivist");await capture("ilex_dialogue");game.hideout_ui.dismiss_dialogue()
		game.hideout_ui.show_shop();await capture("merchant_cart")
		game.hideout_ui.show_lore();game.hideout_ui.lore_filter="ALL";game.hideout_ui.refresh_lore()
		for id in ["region/mossglass_wilds","route/hoard_depths","boss/belljaw"]:
			for index in range(game.hideout_ui.lore_entries.size()):
				if game.hideout_ui.lore_entries[index].id==id:
					game.hideout_ui.lore_index=index;game.hideout_ui.cycle_lore(0);await capture("notes_"+id.replace("/","_"))
		game.hideout_ui.show_memories();game.hideout_ui.memory_filter="Regions";game.hideout_ui.refresh_memories();await capture("regional_memories")
		game.hideout_ui.memory_filter="Bosses";game.hideout_ui.refresh_memories();await capture("boss_memories")
		game.hideout_ui.hide();game.dungeon.setup(4917,"moonfen");game.campaign_id="moonfen";game.start_run();game.set_process(false);game.dungeon.depth=2;game.show_route_choices();await capture("dungeon_destinations")
		for button in game.route_buttons:
			assert(button.position.x+button.size.x<=game.route_panel.size.x,"Dungeon destination exceeds panel")
		# Each following visual fixture is a fresh combat staging, not a route overlay.
		game.dungeon.active=false;game.route_panel.visible=false
		game.presentation_director.set_process(false);game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.visible=false
		for identity in ["Fire","Frost","Arcane","Corruption"]:
			helper.prepare("relic_beast","orb");game.forced_facing_test=0;game.enemy_entry_anim=0;game.wave_banner_timer=0;game.projectile_impacts=[{"pos":Vector2(game.target_combat_visual_position()),"life":.21,"element":identity,"weapon_type":"orb","direction":Vector2.RIGHT}]
			game.attack_projectiles.clear();game.attack_projectiles.append({"pos":Vector2(240,game.target_combat_visual_position().y-29),"start":Vector2(150,game.target_combat_visual_position().y-29),"target":game.target_combat_visual_position(),"family":"MAGE","weapon_type":"orb","element":identity})
			await capture("spell_"+identity.to_lower())
		game.attack_projectiles.clear();game.projectile_impacts.clear()
		game.state="result";game.retention.show_spinner()
		for tier in preload("res://relic_spin_catalog.gd").TIERS:
			var machine=game.retention.machine;machine.wind_up("blueprint",tier,false);machine.set_process(false);machine.stage="reveal";machine.burst=.85;machine.queue_redraw()
			game.retention.detail.text="[center]FORCED RARITY PREVIEW — no reward granted[/center]";await capture("spinner_"+tier.to_lower())
		game.retention.machine.stop()
	helper.free();game.free();await process_frame;await process_frame
	print("BIBLE NATIVE PASS: source props, real dungeon presentation, HUD portrait, four spell motifs, all six spinner reveals; no fabricated body states");quit()
