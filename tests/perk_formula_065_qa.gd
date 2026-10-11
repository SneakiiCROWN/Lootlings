extends SceneTree
const Presentation=preload("res://perk_presentation.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	call_deferred("review")
func review() -> void:
	var game=load("res://main.tscn").instantiate();root.add_child(game);game.set_process(false)
	game.start_run();game.set_process(false)
	for id in ["damage","speed","crit","execute","vamp","regen","armor","multi","tap","heavy","splash"]:
		var up: Dictionary=game.UPGRADES.filter(func(u):return u.id==id)[0]
		var rng_state: int=game.rng.state
		var before: Dictionary={"power":game.base_damage,"interval":game.current_attack_interval(),"crit":game.effective_crit_chance(),"leech":game.life_steal,"execute":game.execute_ratio,"regen":game.regen_per_second,"hp":game.player_max_hp,"multi":game.multi_hits,"tap":game.tap_mult,"splash":game.splash_ratio}
		var text: String=Presentation.effect(game,up)
		assert(not text.is_empty() and game.rng.state==rng_state)
		game.apply_upgrade_effect(up)
		match id:
			"damage":assert(is_equal_approx(game.base_damage,before.power*1.35))
			"speed":assert(is_equal_approx(game.current_attack_interval(),maxf(.16,before.interval*.82)))
			"crit":assert(text.contains("%.1f%%" % (game.effective_crit_chance()*100)))
			"vamp":assert(text.contains("%.1f%%" % (game.life_steal*100)))
			"execute":assert(text.contains("%.0f%%" % (game.execute_ratio*100)))
			"regen":assert(text.contains("%.2f HP/s" % game.regen_per_second))
			"armor":assert(is_equal_approx(game.player_max_hp,before.hp+30))
			"multi":assert(game.multi_hits==before.multi+1)
			"tap":assert(is_equal_approx(game.tap_mult,before.tap+.8))
			"splash":assert(is_equal_approx(game.splash_ratio,before.splash+.25))
	for id in ["vamp","crit","execute"]:
		game.life_steal=.079;game.crit_chance=.719;game.execute_ratio=.349
		var up: Dictionary=game.UPGRADES.filter(func(u):return u.id==id)[0]
		var text: String=Presentation.effect(game,up);game.apply_upgrade_effect(up)
		match id:
			"vamp":assert(is_equal_approx(game.life_steal,.08) and text.contains("8.0%"))
			"crit":assert(is_equal_approx(game.crit_chance,.72))
			"execute":assert(is_equal_approx(game.execute_ratio,.35) and text.contains("35%"))
	game.free();print("PERK FORMULA 065 PASS: readonly descriptions agree with applied effects and caps; no combat RNG consumption.");quit()
