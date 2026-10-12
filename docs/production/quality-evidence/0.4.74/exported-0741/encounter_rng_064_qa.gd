extends SceneTree
func _initialize() -> void:
	if not preload("C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-fixtures-0741/test_safety.gd").require_isolated(self): return
	call_deferred("review")
func review() -> void:
	var g = load("res://main.tscn").instantiate(); root.add_child(g); await process_frame; g.set_process(false)
	g.start_run(); g.enemy_encounter.clear(); g.grouped_patrols = false
	var count := 0
	for sample in range(64):
		var expected: Array = []
		var random_state: int = 0
		for repeat in range(2):
			g.rng.seed = 64000 + sample; g.wave = 2; g.wave_kills = 0; g.wave_composition_wave = -1
			seed(900 + repeat)
			# Equivalent to differing cosmetic pitch/UI random consumption.
			for i in range(repeat * 137): randf()
			g.spawn_enemy()
			if repeat == 0: expected = g.wave_composition.duplicate(); random_state = g.rng.state
			else: assert(g.wave_composition == expected and g.rng.state == random_state)
		assert(expected.size() == 3)
		assert(expected.count("hexer") <= 1 and expected.count("tank") <= 1)
		count += 1
	g.free(); await process_frame
	print("ENCOUNTER RNG 064 PASS: 64 seeds /128 spawns; global cosmetic RNG changes cannot alter combat role order or seeded stream; role budgets preserved.")
	quit()
