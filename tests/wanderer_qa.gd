extends SceneTree
const Profiles = preload("res://profile_store.gd")
const Wanderers = preload("res://wanderer_catalog.gd")
const Avatar = preload("res://avatar_presentation.gd")
const Poses = preload("res://wanderer_pose_catalog.gd")
const Weapons = preload("res://weapon_catalog.gd")
const Items = preload("res://item_catalog.gd")
const EvolutionQA = preload("res://tests/evolution_qa.gd")
var game
var native := false

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	native = "--visual" in OS.get_cmdline_user_args()
	call_deferred("run_qa")

func run_qa() -> void:
	var old := ConfigFile.new()
	old.set_value("profile", "schema_version", 2)
	old.set_value("profile", "player_uuid", "legacy-id-retained")
	old.set_value("profile", "display_name", "Old Seeker")
	old.set_value("profile", "current_lootling_id", "gloomlet")
	assert(old.save("user://old_profile.cfg") == OK)
	var profile := Profiles.load_profile("user://old_profile.cfg")
	assert(profile.schema_version == 3 and profile.avatar_mode == "lootling")
	assert(profile.player_uuid == "legacy-id-retained" and profile.current_lootling_id == "gloomlet")
	assert(preload("res://lootling_catalog.gd").selectable_ids().size() == 7)
	assert(Wanderers.selectable_ids().size() == 5)
	var invalid := Wanderers.sanitize({"preset_id":"fake", "origin":"fake", "lineage":"fake", "body_frame":"fake", "pronouns":"\n", "voice":"fake"})
	assert(invalid.preset_id == "vault_runner" and invalid.origin == "vault_hunter" and invalid.pronouns == "they/them")
	assert(invalid.appearance == Wanderers.appearance_manifest("vault_runner"))
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.audio_settings.cinematic_first_time = false
	game.profile = profile
	game.startup_ui.profile = profile.duplicate(true)
	game.startup_ui.show_profile(true)
	game.startup_ui.name_edit.text = "New Seeker"
	game.startup_ui.profile_exists = false
	game.startup_ui.save_profile()
	assert(game.startup_ui.current_screen == "lootling_select")
	game.startup_ui.show_wanderer_select()
	assert(game.startup_ui.current_screen == "wanderer_select")
	if native: await capture("wanderer_selector_runner")
	game.startup_ui.cycle_wanderer(1)
	if native: await capture("wanderer_selector_warden")
	game.startup_ui.select_identity(game.startup_ui.wanderer_origin, "starfall_witch")
	game.startup_ui.wanderer_pronouns.text = "she/they"
	game.startup_ui.confirm_wanderer()
	assert(game.profile.avatar_mode == "wanderer" and game.profile.wanderer.pronouns == "she/they")
	assert(game.profile.wanderer.origin == "starfall_witch" and game.profile.current_lootling_id == "gloomlet")
	assert(Profiles.save_profile("user://wanderer_profile.cfg", game.profile) == OK)
	assert(Profiles.load_profile("user://wanderer_profile.cfg") == game.profile)
	var equipped_before: Dictionary = game.inventory.equipped.duplicate(true)
	var gold_before: int = game.gold
	for preset in Wanderers.selectable_ids():
		game.profile.wanderer.preset_id = preset
		game.profile.wanderer = Wanderers.sanitize(game.profile.wanderer)
		assert(game.profile.wanderer.appearance.mode == "authored_preset")
		for slot in Wanderers.APPEARANCE_SLOTS:
			assert(game.profile.wanderer.appearance.components.has(slot))
		var forged: Dictionary = game.profile.wanderer.duplicate(true)
		forged.appearance.components.hair_style = "nonexistent_modular_hair"
		assert(Wanderers.sanitize(forged).appearance == game.profile.wanderer.appearance)
		assert(Profiles.save_profile("user://preset_profile.cfg", game.profile) == OK)
		assert(Profiles.load_profile("user://preset_profile.cfg") == game.profile)
		var texture := Wanderers.runtime_texture(preset)
		assert(texture != null and texture.get_size() == Vector2(1024,1536))
		var image := Image.load_from_file(ProjectSettings.globalize_path(str(Wanderers.definition(preset).runtime_sprite)))
		for point in [Vector2i(10,10),Vector2i(1010,10),Vector2i(1010,1500),Vector2i(10,1500)]:
			assert(image.get_pixelv(point).a == 0.0, "Backdrop must be transparent, not a pasted portrait")
		var grip: Vector2 = Wanderers.definition(preset).grip * Vector2(image.get_size())
		assert(image.get_pixelv(Vector2i(grip)).a > 0.8, "Grip must be on the visible hand, not empty air")
		assert(Avatar.portrait(game.profile) is AtlasTexture)
		assert(game.inventory.equipped == equipped_before and game.gold == gold_before)
		game.startup_ui.profile = game.profile
		game.startup_ui.show_wanderer_select()
		if native: await capture("wanderer_selector_" + preset)
		game.show_hideout()
		if native: await capture("wanderer_home_" + preset)
		game.show_startup()
		game.startup_ui.profile = game.profile
		game.startup_ui.show_title()
		if native: await capture("wanderer_title_" + preset)
		for subtype in Weapons.live_ids():
			game.inventory.reset_to_starter()
			game.inventory.equip(Items.create_item(EvolutionQA.base_id(subtype), "COMMON", 81))
			game.start_run()
			game.set_process(false)
			game.player_x = game.target_player_x()
			game.wave_banner_timer = 0
			game.presentation_director.toast_panel.visible = false
			var damage: float = game.base_damage
			var interval: float = game.current_attack_interval()
			var rng: int = game.rng.state
			var loot_rng: int = game.loot_system.rng.state
			for phase in [0.0,0.1,0.22]:
				game.attack_anim = phase
				var pose := Poses.sample(game)
				assert(Rect2(-150,-250,380,380).has_point(pose.projectile))
				assert(pose.weapon_rect.size.x <= 150 and pose.weapon_rect.size.y <= 180)
			assert(game.rng.state == rng and game.loot_system.rng.state == loot_rng)
			assert(game.base_damage == damage and game.current_attack_interval() == interval)
			game.attack_anim = 0
			var weapon_texture := preload("res://lootlings_ui.gd").item_texture(game.inventory.equipped_item("Weapon"))
			if subtype in ["daggers","bow","staff"]:
				assert(not weapon_texture.resource_path.ends_with("vanguard_hammer.png"))
			game.perform_player_attack(false)
			if game.current_weapon_family() in ["RANGER","MAGE"]:
				assert(not game.attack_projectiles.is_empty())
				assert(game.attack_projectiles[0].start.distance_to(Poses.projectile_origin(game)) < 0.1)
			if native:
				await capture("wanderer_" + preset + "_" + subtype)
			game.show_startup()
		game.inventory.equipped = equipped_before.duplicate(true)
		game.gold = gold_before
	# Switching branches preserves the adult settings and every Lootling identity.
	game.startup_ui.profile = game.profile
	game.startup_ui.selected_lootling_id = "gloomlet"
	game.startup_ui.confirm_lootling()
	assert(game.profile.avatar_mode == "lootling" and game.profile.current_lootling_id == "gloomlet")
	assert(game.profile.wanderer.origin == "starfall_witch")
	print("WANDERER QA PASSED: schema-2 migration/UUID, five adult presets, appearance manifest/persistence, seven Lootlings/Gloomlet retained, 60 avatar/weapon combinations, socket bounds, stat/RNG neutrality")
	game.queue_free()
	await process_frame
	quit(0)

func capture(label: String) -> void:
	game.queue_redraw()
	await create_timer(0.35).timeout
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	assert(image.get_size() == Vector2i(480,854))
	assert(image.save_png("res://.godot_test_data/" + label + "_qa.png") == OK)
