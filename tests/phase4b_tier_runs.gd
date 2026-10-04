extends "res://tests/phase3_balance.gd"
# extends SceneTree via isolated actual-combat harness.
var chosen_tier:=0
func configure_game(game) -> void:
	game.expedition_progress.data.actors.relic_beast=120; game.expedition_progress.data.weapons.greatsword=120; game.expedition_tier=chosen_tier
func measure() -> void:
	helper=Diagnostic.new(); packed=load("res://main.tscn")
	for tier in range(3):
		chosen_tier=tier
		for sample in range(4):
			var row:=simulate("greatsword","sustain",sample,"act_i","relic_beast","tap"); row.tier=tier
			print("PHASE4B_TIER "+JSON.stringify(row))
	helper.free(); quit()
