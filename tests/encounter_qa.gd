extends SceneTree
const Items = preload("res://item_catalog.gd")
var game
var native := false

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	native = "--visual" in OS.get_cmdline_user_args()
	call_deferred("run_qa")

func prepare(wave: int = 2, weapon: String = "scrapfang_blade") -> void:
	game.inventory.reset_to_starter()
	game.inventory.equip(Items.create_item(weapon, "COMMON", 7))
	game.campaign_id = "act_i"
	game.grouped_patrols = true
	game.start_run()
	game.set_process(false)
	game.rng.seed = 8181
	game.loot_system.rng.seed = 9191
	game.wave = wave
	game.wave_kills = 0
	game.spawn_enemy()
	game.player_x = game.target_player_x()
	game.wave_banner_timer = 0

func run_qa() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	prepare()
	assert(game.enemy_encounter.active and game.enemy_encounter.actors.size() == 2)
	var first: Array = game.enemy_encounter.actors.duplicate(true)
	game.visual_rng.seed = 987654
	prepare()
	for index in range(2):
		assert(game.enemy_encounter.actors[index].enemy_name == first[index].enemy_name)
		assert(game.enemy_encounter.actors[index].enemy_max_hp == first[index].enemy_max_hp)
		assert(game.enemy_encounter.actors[index].enemy_variant_id == first[index].enemy_variant_id)
	game.enemy_poison_stacks = 3
	game.enemy_poison_time = 5.0
	game.enemy_hp -= 7
	var hp: float = game.enemy_hp
	assert(game.enemy_encounter.select(game, 1))
	assert(game.enemy_poison_stacks == 0 and game.enemy_hp != hp)
	assert(game.enemy_encounter.select(game, 0))
	assert(game.enemy_poison_stacks == 3 and game.enemy_hp == hp)
	if native: await capture("duo_status")
	# A ranged shot remains bound to its launched target when selection changes.
	prepare(2, "bonebow")
	game.perform_player_attack(false)
	assert(game.attack_projectiles.size() == 1)
	game.enemy_encounter.select(game, 1)
	var other_hp: float = game.enemy_hp
	game.update_attack_projectiles(0.5)
	assert(game.enemy_encounter.selected == 1 and game.enemy_hp == other_hp)
	assert(game.enemy_encounter.actors[0].enemy_hp < game.enemy_encounter.actors[0].enemy_max_hp)
	if native: await capture("duo_ranged")
	prepare(2, "glimmerstaff")
	other_hp = game.enemy_encounter.actors[1].enemy_hp
	game.resolve_player_attack(false)
	assert(game.enemy_encounter.actors[1].enemy_hp < other_hp)
	# Independent attacks, DOT and god-mode guard run through the original methods.
	game.debug_god_mode = true
	for step in range(30): game._process(0.05)
	assert(game.player_hp > 0)
	game.debug_god_mode = false
	prepare(10)
	assert(game.enemy_encounter.actors.size() == 3)
	if native: await capture("pack_three")
	var kills: int = game.total_kills
	var coins: int = game.coins
	var expected := 0
	for actor in game.enemy_encounter.actors:
		# Run Scrip was retired: ordinary packs do not mint the Siege Embers
		# counter. Preserve the current economy rather than the obsolete test.
		if game.retention.siege:expected += int(round((5 + mini(15,game.wave) * 1.8) * game.coin_reward_mult * (1 + game.inventory.effect_total("coin_mult")) * float(actor.enemy_reward_multiplier)))
	for index in range(3):
		game.state = "playing"
		game.damage_enemy(game.enemy_hp * 10 + 1, false, false)
		assert(game.total_kills == kills + index + 1)
		if index < 2:
			assert(game.enemy_encounter.active and game.wave == 10)
	assert(not game.enemy_encounter.active and not game.enemy_alive and game.wave == 11)
	assert(game.coins == coins + expected)
	# Specials remain their validated solo/chest encounters.
	for wave in [8, 15]:
		prepare(wave)
		assert(not game.enemy_encounter.active)
	if native:
		prepare(10, "glimmerstaff")
		for index in range(3):
			game.enemy_encounter.select(game, index)
			game.enemy_hp = 100000.0
			game.enemy_max_hp = 100000.0
			game.enemy_damage = 0.1
			game.enemy_burn_dps = 1.0
			game.enemy_burn_time = 20.0
			game.enemy_poison_stacks = 3
			game.enemy_poison_time = 20.0
		game.enemy_encounter.capture(game)
		var elapsed_us := 0
		var worst_us := 0
		for frame in range(180):
			var start_us := Time.get_ticks_usec()
			game._process(1.0 / 60.0)
			var process_us := Time.get_ticks_usec() - start_us
			elapsed_us += process_us
			worst_us = maxi(worst_us, process_us)
			if frame % 45 == 0: game.add_reward_burst(20, 20)
			if frame % 30 == 0: game.add_particles(Vector2(345, 450), Color("#95eaff"), 12)
			assert(game.enemy_encounter.actors.size() == 3 and game.attack_projectiles.size() <= 4)
			await process_frame
		print("NATIVE GROUP STRESS: 180 rendered frames, step average=%d us worst=%d us; desktop only, not Android certification" % [elapsed_us / 180, worst_us])
		await capture("group_stress")
	game.show_hideout()
	game.hideout_ui.show_campaign()
	if native: await capture("patrol_selector")
	game.queue_free()
	await process_frame
	print("ENCOUNTER QA PASSED: bounded duo/pack, deterministic visual-RNG separation, independent HP/status, bound projectiles, AoE, exact rewards and special exclusion")
	quit(0)

func capture(label: String) -> void:
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	var shot := root.get_texture().get_image()
	assert(shot.get_size() == Vector2i(480, 854))
	assert(shot.save_png("res://.godot_test_data/%s_qa.png" % label) == OK)
