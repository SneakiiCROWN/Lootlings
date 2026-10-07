extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree via guarded native helper. Preview frames do not grant rewards.
const UI=preload("res://lootlings_ui.gd")
const Items=preload("res://item_catalog.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	assert(DisplayServer.get_name()!="headless");call_deferred("review_utilities")
func review_utilities() -> void:
	game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
	var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
	game.campaign.completed=preload("res://campaign_system.gd").ORDER.duplicate()
	for id in UI.CANON_RUNE_ART:
		var item=Items.create_item(id,"EPIC",221);assert(not item.is_empty())
		var unchanged=item.duplicate(true);assert(UI.item_texture(item).resource_path.ends_with("fault_seal.png"));assert(item==unchanged)
	for layout in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=layout;folder="res://.godot_test_data/canon-utilities/native/%dx%d/" % [layout.x,layout.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		game.show_hideout();game.hideout_ui.show_shop();await capture("merchant_capacity")
		game.hideout_ui.show_achievements();await capture("trophy_archive")
		game.hideout_ui.show_memories();await capture("memory_archive")
		game.hideout_ui.show_contracts();await capture("contracts")
		game.hideout_ui.hide()
		for id in UI.CANON_RUNE_ART:
			game.inventory.keep(Items.create_item(id,"EPIC",222));game.pending_items=[Items.create_item(id,"EPIC",223)]
			game.state="playing";game.show_next_item();await capture("rune_"+id)
		game.show_hideout();game.hideout_ui.show_lore();game.hideout_ui.lore_filter="GEAR";game.hideout_ui.refresh_lore()
		for i in range(game.hideout_ui.lore_entries.size()):
			if game.hideout_ui.lore_entries[i].name=="Fault Script":game.hideout_ui.lore_index=i;game.hideout_ui.cycle_lore(0)
		await capture("notes_fault_script")
		game.coins=1000;game.player_hp=game.player_max_hp*.5
		game.wave=9;game.wave_kills=1;game.retention.round_rule={"count":1,"boss":false,"event":true}
		game.retention.killed();assert(game.state=="siege_service")
		var wallet: int=game.coins;var hp: float=game.player_hp
		await capture("siege_service")
		assert(game.retention.buttons[2].icon.resource_path.ends_with("healing_wreath.png"))
		await swipe(game.retention.buttons[2]);game.touch_ux.inertia=null
		assert(game.coins==wallet and game.player_hp==hp,"Drag must never purchase a healing service")
		await tap(game.retention.buttons[3]);assert(game.state=="playing" and game.coins==wallet and game.player_hp==hp)
		game.retention.open("mode_menu","PREVIEW","",["LEAVE"]);assert(game.retention.buttons.all(func(button):return button.icon==null))
		game.retention.panel.hide()
		for element in ["Fire","Arcane"]:
			for side in [1,-1]:
				helper.prepare("glimmerfin","orb");game.forced_facing_test=0;game.enemy_entry_anim=0
				game.presentation_director.set_process(false);game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.hide()
				var start:=Vector2(150,game.target_combat_visual_position().y-29)
				var target: Vector2=game.target_combat_visual_position()
				if side<0:
					var swap:=start;start=target;target=swap
				game.attack_projectiles=[{"pos":start.lerp(target,.5),"start":start,"target":target,"family":"MAGE","weapon_type":"orb","element":element}]
				game.attack_anim=.18;await capture("spell_"+element.to_lower()+"_"+("right" if side>0 else "left"))
				# Forced missile-direction example only; actors retain real target facing.
				assert(game.forced_facing_test==0)
		game.attack_projectiles.clear()
	helper.free();game.free();await process_frame;await process_frame
	print("CANON UTILITIES PASS: immutable rune IDs, Archive/merchant/contracts, service drag/leave safety, cleared utility icons, Fire/Arcane missile directions, phone/tablet");quit()
