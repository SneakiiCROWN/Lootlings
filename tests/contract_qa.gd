extends SceneTree
const Contracts = preload("res://contract_system.gd")
var game

func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	call_deferred("run_qa")

func run_qa() -> void:
	var contracts := Contracts.new()
	assert(contracts.claim(-1) == 0 and contracts.claim(99) == 0 and contracts.claim(0) == 0)
	for count in range(12): contracts.record("kill")
	contracts.record("invalid")
	assert(contracts.offer(0).progress == 12 and contracts.claim(0) == 10)
	assert(contracts.claim(0) == 0 and contracts.offer(0).event == "boss")
	contracts.record("boss")
	assert(contracts.claim(0) == 15 and contracts.offer(0).event == "win")
	assert(contracts.save("user://contract_test.cfg") == OK)
	var restored := Contracts.new()
	restored.load_progress("user://contract_test.cfg")
	assert(restored.active == contracts.active and restored.counts == contracts.counts)
	restored.record("win")
	assert(restored.claim(0) == 20)
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.contracts = Contracts.new()
	game.hideout_ui.contracts = game.contracts
	game.start_run()
	game.damage_enemy(game.enemy_hp * 10.0, false, false)
	assert(game.contracts.counts.kill == 1)
	game.wave = 8
	game.spawn_enemy()
	game.damage_enemy(game.enemy_hp * 10.0, false, false)
	assert(game.contracts.counts.miniboss == 1)
	game.show_hideout()
	var gold: int = game.gold
	game.hideout_ui.show_contracts()
	game.hideout_ui.contract_buttons[1].pressed.emit()
	assert(game.gold == gold + 15)
	game.claim_contract(1)
	assert(game.gold == gold + 15)
	var saved := Contracts.new()
	saved.load_progress("user://contracts.cfg")
	assert(saved.active == game.contracts.active)
	game.record_contract_chest()
	assert(game.contracts.counts.chest == 1)
	if "--visual" in OS.get_cmdline_user_args():
		for frame in range(30): await process_frame
		assert(root.get_texture().get_image().save_png("res://.godot_test_data/contracts_qa.png") == OK)
	print("CONTRACTS PASSED: actual kill/miniboss/chest events, claim bounds, no double rewards, rotation, persistence, fresh profile and menu")
	game.queue_free()
	await process_frame
	quit(0)
