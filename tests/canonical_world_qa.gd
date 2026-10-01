extends SceneTree

const Roster = preload("res://lootling_catalog.gd")
const Story = preload("res://world_story.gd")
const Campaign = preload("res://campaign_system.gd")
const Items = preload("res://item_catalog.gd")
const Weapons = preload("res://weapon_catalog.gd")
var game
var native := false

func _initialize() -> void:
	native = "--visual" in OS.get_cmdline_user_args()
	call_deferred("run_qa")

func run_qa() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	for id in ["relic_beast", "emberhorn", "mosskin", "moonkip", "pebblewyrm", "glimmerfin"]:
		assert(not Roster.definition(id).temp_art)
		assert(Roster.runtime_texture(id).resource_path == Roster.definition(id).runtime_sprite)
		assert(Roster.presentation_tint(id) == Color.WHITE)
		game.profile.current_lootling_id = id
		game.startup_ui.profile = game.profile
		game.startup_ui.show_lootling_select()
		assert(not game.startup_ui.selector_confirm.disabled)
		if native: await capture("canonical_selector_" + id)
		game.campaign_id = "mossglass_wilds"
		game.start_run()
		game.wave_banner_timer = 0
		game.presentation_director.toast_panel.visible = false
		if native: await capture("canonical_combat_" + id)
		game.show_startup()
	game.startup_ui.selected_lootling_id = "gloomlet"
	game.startup_ui.refresh_selector()
	assert(not game.startup_ui.selector_confirm.disabled)
	assert(Roster.runtime_texture("gloomlet") == Roster.BASE_TEXTURE)
	assert(Roster.definition("gloomlet").temp_art)
	game.startup_ui.confirm_lootling()
	assert(game.profile.current_lootling_id == "gloomlet")
	if native: await capture("canonical_gloomlet_standin")
	game.profile.current_lootling_id = "relic_beast"
	for id in Campaign.ORDER:
		assert(Story.REGIONS.has(id))
		for index in range(5): assert(Story.region_line(id, index).length() < 64)
		for wave in [1, 6, 11]:
			var zone := Campaign.zone_for(id, wave)
			assert(zone.background != null)
	var region_paths: Dictionary = {}
	for id in Campaign.ORDER.slice(1):
		game.campaign_id = id
		game.start_run()
		assert(game.current_zone.background.resource_path.contains("/beta/"))
		assert(not region_paths.has(game.current_zone.background.resource_path), "Each expanded region needs a distinct composition")
		region_paths[game.current_zone.background.resource_path] = true
		assert(game.current_zone.presentation_tint == Color.WHITE)
		game.wave_banner_timer = 0
		game.presentation_director.toast_panel.visible = false
		if native: await capture("canonical_region_" + id)
		if id in ["mossglass_wilds", "cinder_crown"]:
			game.wave = 15
			game.wave_kills = 0
			game.spawn_enemy()
			game.wave_banner_timer = 0
			assert(game.enemy_is_boss)
			if native: await capture("canonical_boss_" + id)
	game.show_hideout()
	game.hideout_ui.show_campaign()
	if native: await capture("canonical_campaign")
	game.campaign.completed.clear()
	game.hideout_ui.show_lore()
	assert(game.hideout_ui.lore_entries.size() == 12)
	if native: await capture("canonical_lore_world")
	game.hideout_ui.cycle_lore(1)
	if native: await capture("canonical_lore_lootling")
	game.campaign.finish("act_i")
	game.hideout_ui.show_lore()
	assert(game.hideout_ui.lore_entries.size() == 13, "A campaign victory reveals the next trail's page")
	game.hideout_ui.lore_index = 8
	game.hideout_ui.cycle_lore(0)
	if native: await capture("canonical_lore_npc")
	for id in ["greatsword", "greataxe", "orb", "spear", "crossbow", "claws", "wand"]:
		var item: Dictionary = Items.create_item("scrapfang_blade", "COMMON", 981) if id == "greatsword" else Items.create_item(Weapons.starter(id).id, "COMMON", 982)
		game.inventory.equip(item)
		game.campaign_id = "cinder_crown"
		game.start_run()
		game.wave_banner_timer = 0
		assert(Weapons.runtime_texture(id, null).resource_path.ends_with("%s_held.png" % id))
		if native: await capture("canonical_weapon_" + id)
		if id in ["crossbow", "wand"]:
			game.attack_projectiles.clear()
			game.perform_player_attack(false)
			assert(not game.attack_projectiles.is_empty())
			var expected_socket := Vector2(game.player_x + 127.0, 447.0) if id == "crossbow" else Vector2(game.player_x + 91.0, 393.0)
			assert(game.attack_projectiles[0].start == expected_socket)
			if native:
				game.set_process(false)
				game.update_attack_projectiles(0.025)
				game.queue_redraw()
				await process_frame
				await RenderingServer.frame_post_draw
				assert(root.get_texture().get_image().save_png("res://.godot_test_data/canonical_release_%s_qa.png" % id) == OK)
				game.set_process(true)
	game.show_hideout()
	game.hideout_ui.show_home()
	game.hideout_ui.request_dialogue("tapped", "Salvager")
	assert(game.hideout_ui.speech_label.text.begins_with("PATCH BRASSWICK"))
	if native: await capture("canonical_dialogue")
	game.queue_free()
	await process_frame
	print("CANONICAL WORLD QA PASSED: six real identities, selectable documented Gloomlet fallback, ten story mappings, nine unique region compositions, named dialogue")
	quit(0)

func capture(label: String) -> void:
	await create_timer(0.4).timeout
	await process_frame
	await RenderingServer.frame_post_draw
	var shot := root.get_texture().get_image()
	assert(shot.get_size() == Vector2i(480, 854))
	assert(shot.save_png("res://.godot_test_data/%s_qa.png" % label) == OK)
