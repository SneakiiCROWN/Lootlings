extends SceneTree

const BuildSystem = preload("res://build_system.gd")
const GameCatalog = preload("res://game_catalog.gd")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error("SMOKE TEST: " + message)

func run_tests() -> void:
	var packed := load("res://main.tscn") as PackedScene
	check(packed != null, "main scene loads")
	if packed == null:
		quit(1)
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	var identity_build = BuildSystem.new()
	identity_build.add_upgrade(upgrade_by_id("ignite"))
	identity_build.add_upgrade(upgrade_by_id("wildfire"))
	check(identity_build.dominant() == "Fire" and identity_build.tier() == 1, "build tags produce a Fire evolution threshold")
	check(BuildSystem.COLORS.Fire != BuildSystem.COLORS.Lightning and BuildSystem.COLORS.Poison != BuildSystem.COLORS.Physical, "implemented identities have distinct visual palettes")
	for mechanic_id in ["ignite", "storm", "venom", "heavy"]:
		game.start_run()
		game.apply_upgrade_effect(upgrade_by_id(mechanic_id))
		game.player_x = game.PLAYER_ATTACK_X
		game.enemy_max_hp = 99999.0
		game.enemy_hp = game.enemy_max_hp
		game.enemy_hit_multiplier = 1.0
		if mechanic_id == "storm":
			game.attack_sequence = 3
		elif mechanic_id == "heavy":
			game.attack_sequence = 4
		var hp_before: float = game.enemy_hp
		game.perform_player_attack(false)
		match mechanic_id:
			"ignite": check(game.enemy_burn_dps > 0.0, "Fire upgrades ignite enemies")
			"storm": check(hp_before - game.enemy_hp > game.base_damage * 1.2, "Lightning upgrades trigger chain damage")
			"venom": check(game.enemy_poison_stacks > 0, "Poison upgrades stack damage over time")
			"heavy": check(hp_before - game.enemy_hp > game.base_damage * 1.7, "Physical upgrades trigger heavy rhythm hits")
	game.start_run()
	check(game.state == "playing", "a run starts in gameplay")
	check(game.enemy_alive and game.enemy_hp > 0.0, "first enemy spawns with health")
	game.player_x = game.PLAYER_ATTACK_X
	game.perform_player_attack(true)
	check(game.enemy_hp < game.enemy_max_hp, "tap attack damages the enemy")
	check(game.attack_anim > 0.0 and game.enemy_recoil > 0.0, "attacks trigger readable impact animation")
	game.damage_enemy(game.enemy_max_hp * 10.0, false, false)
	check(game.enemy_death_anim > 0.0 and not game.reward_pickups.is_empty(), "enemy death launches reward feedback")
	var guard := 0
	while game.state != "result" and guard < 100:
		guard += 1
		while game.state == "upgrade":
			check(game.selected_upgrades.size() == 3, "level-up offers three upgrades")
			game.choose_upgrade(0)
		if game.state == "result":
			break
		if not game.enemy_alive:
			game.spawn_enemy()
		game.damage_enemy(game.enemy_hp + 1.0, false, false)
	check(guard < 100, "complete run does not softlock")
	check(game.state == "result" and game.wave == game.RUN_LAST_WAVE, "boss victory reaches results")
	check(game.total_kills >= 40, "waves and miniboss produced the expected enemy sequence")
	check(game.meta_shards > 0, "run rewards permanent-progression currency")
	game.start_run()
	check(game.state == "playing" and game.wave == 1 and game.enemy_alive, "another run restarts cleanly")
	game.player_hp = 1.0
	game.enemy_damage = 999.0
	game.perform_enemy_attack()
	check(game.state == "result" and game.player_hp == 0.0, "defeat reaches results without a softlock")
	seed(424242)
	var victories := 0
	for run_index in range(5):
		game.start_run()
		game.rng.seed = 1000 + run_index
		var elapsed := 0.0
		var tap_clock := 0.0
		while game.state != "result" and elapsed < 300.0:
			if game.state == "upgrade":
				game.choose_upgrade((run_index + game.level) % 3)
			else:
				game._process(0.05)
				tap_clock += 0.05
				if tap_clock >= 0.22:
					tap_clock = 0.0
					game.perform_player_attack(true)
			elapsed += 0.05
		if game.state == "result" and game.player_hp > 0.0 and game.wave == game.RUN_LAST_WAVE:
			victories += 1
		print("BALANCE RUN %d: wave=%d level=%d hp=%.0f time=%.1fs" % [run_index + 1, game.wave, game.level, game.player_hp, elapsed])
	check(victories >= 1, "a modest tapping strategy can complete a balanced run")
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("SMOKE TEST PASSED: full loop plus %d/5 simulated tapping victories" % victories)
		quit(0)
	else:
		print("SMOKE TEST FAILED: %d issue(s)" % failures.size())
		quit(1)

func upgrade_by_id(id: String) -> Dictionary:
	for upgrade in GameCatalog.UPGRADES:
		if upgrade.id == id:
			return upgrade
	return {}
