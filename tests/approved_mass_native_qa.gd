extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through the isolated native helper. Forced tiers are previews.
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	assert(DisplayServer.get_name()!="headless"); call_deferred("review_approved")
func review_approved() -> void:
	game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
	var baseline: bool=OS.get_environment("LOOTLINGS_REUSE_BASELINE")=="1"
	if baseline:
		game.hideout_ui.hide();game.hideout_ui.set_process(false)
		var ui=load("res://.godot_test_data/phase4e/approved-mass/baseline_hideout_ui.gd").new();game.add_child(ui);game.hideout_ui=ui
		ui.campaign=game.campaign;ui.expedition_progress=game.expedition_progress;ui.endgame_progress=game.retention.progress
		ui.configure(game.inventory,game.hideout_shop,game.meta_shards,game.meta_power,Callable(game,"build_item_comparison"),game.gold,game.profile,game.gold_upgrades,game.achievements)
		game.combat_controls.hide();game.combat_controls.set_process(false)
		var controls=load("res://.godot_test_data/phase4e/approved-mass/baseline_combat_controls.gd").new();game.add_child(controls);controls.configure(game);game.combat_controls=controls
		game.retention.machine.hide();game.retention.machine.set_process(false)
		var machine=load("res://.godot_test_data/phase4e/approved-mass/baseline_relic_machine.gd").new();game.retention.panel.add_child(machine);game.retention.machine=machine
	game.campaign.completed=["act_i","mossglass_wilds","moonfen"]
	game.profile.memories=["resident/patch","resident/sera","resident/ilex","region/act_i"]
	game.profile.avatar_mode="wanderer";game.profile.wanderer=preload("res://wanderer_catalog.gd").create_default()
	# Existing bounty display lazily creates job cursors; initialise the same
	# fixtures before comparing read-only inspection, with no reward claims.
	for region in preload("res://campaign_system.gd").ORDER: game.expedition_progress.job(region)
	var progress_before: String=JSON.stringify(game.expedition_progress.data)
	var stash_before: String=JSON.stringify(game.inventory.stash)
	var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
	for layout in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		game.profile.avatar_mode="wanderer";game.profile.wanderer=preload("res://wanderer_catalog.gd").create_default()
		root.size=layout;folder="res://.godot_test_data/phase4e/approved-mass/%s/%dx%d/" % ["before" if baseline else "after",layout.x,layout.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game.show_hideout()
		# Home intentionally records equipped discoveries; measure inspection
		# after that pre-existing return behavior, not before entering Home.
		progress_before=JSON.stringify(game.expedition_progress.data);stash_before=JSON.stringify(game.inventory.stash)
		game.hideout_ui.show_phase4("blueprints");await capture("blueprints")
		await tap(game.hideout_ui.phase4_list.get_child(0));await capture("blueprint_detail")
		assert(game.inventory.stash.size()==JSON.parse_string(stash_before).size())
		game.hideout_ui.show_phase4("contracts");await capture("regional_bounties")
		await tap(game.hideout_ui.phase4_list.get_child(1));await capture("bounty_detail")
		game.hideout_ui.show_memories();game.hideout_ui.memory_filter="Characters";game.hideout_ui.refresh_memories();await capture("resident_origin_memories")
		game.hideout_ui.memory_list.get_parent().scroll_vertical=10000
		await capture("resident_origin_memories_lower")
		game.hideout_ui.show_lore();game.hideout_ui.lore_filter="TRAILS";game.hideout_ui.refresh_lore()
		for index in range(game.hideout_ui.lore_entries.size()):
			if str(game.hideout_ui.lore_entries[index].id).begins_with("route/"):
				game.hideout_ui.lore_index=index;game.hideout_ui.cycle_lore(0);await capture("notes_"+str(game.hideout_ui.lore_entries[index].id).replace("/","_"))
		if not baseline: assert(game.hideout_ui.lore_entries.filter(func(e):return str(e.id).begins_with("route/")).size()==3)
		assert(JSON.stringify(game.expedition_progress.data)==progress_before)
		for weapon in ["greatsword","daggers","bow","staff","orb","sling"]:
			helper.prepare("relic_beast",weapon);game.enemy_entry_anim=0;game.wave_banner_timer=0;game.forced_facing_test=0
			await capture("attack_"+weapon)
			if not baseline:
				assert(game.combat_controls.weapon_icon.mouse_filter==Control.MOUSE_FILTER_IGNORE)
				assert(game.combat_controls.weapon_icon.texture==preload("res://lootlings_ui.gd").item_texture(game.inventory.equipped_item("Weapon")))
		game.state="result";game.retention.show_spinner()
		for rarity in preload("res://relic_spin_catalog.gd").TIERS:
			var machine=game.retention.machine;machine.wind_up("material",rarity,false);machine.set_process(false)
			machine.stage="anticipation";machine.elapsed=machine.reel_seconds+preload("res://relic_spin_catalog.gd").anticipation(rarity)*.75;machine.progress=1;machine.queue_redraw()
			game.retention.detail.text="[center]FORCED RARITY PREVIEW — no reward granted[/center]";await capture("spinner_"+rarity.to_lower()+"_anticipation")
			machine.stage="reveal";machine.burst=1;machine.queue_redraw();await capture("spinner_"+rarity.to_lower()+"_reveal")
		game.retention.machine.stop()
	helper.free();game.free();await process_frame;await process_frame
	print("APPROVED MASS NATIVE PASS: illustrative source cards, three recovered Act I paintings, portraits, six attack glyphs and six-tier machine; read-only preview/progress");quit()
