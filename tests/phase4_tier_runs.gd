extends "res://tests/phase3_balance.gd"
# extends SceneTree through the isolated fresh-scene harness.
var tier := 0
var named := ""
func configure_game(game) -> void:
	game.expedition_progress.data.actors.relic_beast=120
	game.expedition_progress.data.weapons.greatsword=120
	game.expedition_tier=tier
	if not named.is_empty(): game.inventory.equip(Items.create_item(named,"RARE",1))
func measure() -> void:
	helper=Diagnostic.new(); packed=load("res://main.tscn")
	for index in range(3):
		tier=index
		for sample in range(4):
			var row:=simulate("greatsword","sustain",sample,"act_i","relic_beast","tap"); row.tier=tier
			print("PHASE4_TIER "+JSON.stringify(row))
	tier=0
	for item in preload("res://phase4_catalog.gd").ITEMS:
		if item.slot!="Weapon": continue
		named=item.id
		for sample in range(2):
			var row:=simulate(item.weapon_type,"sustain",sample,"act_i","relic_beast","tap"); row.named=named
			print("PHASE4_NAMED "+JSON.stringify(row))
	helper.free(); print("PHASE4 TIER/NAMED COMPLETE: %d fresh runs" % completed); quit()
