extends "res://tests/phase3_balance.gd"
# extends SceneTree through the existing isolated balance harness.
var shopping := "cheap"
var stops := []
var events := []

func measure() -> void:
	helper = Diagnostic.new(); packed = load("res://main.tscn")
	for strategy in ["cheap", "save", "search"]:
		shopping = strategy
		for sample in range(12):
			stops = []; events = []
			var row := simulate("greatsword", "sustain", sample, "act_i", "relic_beast", "tap")
			row.shopping = shopping; row.stops = stops.duplicate(true); row.events = events.duplicate(true)
			print("HUMAN_SCRIP " + JSON.stringify(row))
	helper.free(); print("HUMAN SCRIP COMPLETE: %d matched fresh runs" % completed); quit()

func measure_merchant(game) -> void:
	var prices := []; var ratios := []
	for item in game.shop.stock:
		prices.append(int(item.price)); ratios.append(float(item.price)/maxf(1,game.coins))
	var record := {"wave":game.wave,"wallet":game.coins,"prices":prices,"price_wallet":ratios,"rerolls":game.shop.rerolls}
	if shopping == "save" and game.wave < 11:
		record.action = "save"; game.leave_merchant()
	elif shopping == "search" and game.shop.rerolls < 2 and game.coins >= game.shop.reroll_cost(game.wave)+185+game.wave*6:
		record.action = "reroll"; game.reroll_merchant()
	else:
		var selected := -1
		for index in range(game.shop.stock.size()):
			var item: Dictionary = game.shop.stock[index]
			if game.coins < int(item.price): continue
			if selected < 0 or (int(item.price) < int(game.shop.stock[selected].price) if shopping == "cheap" else int(item.price) > int(game.shop.stock[selected].price)):
				selected = index
		record.action = "skip" if selected < 0 else "buy"
		if selected < 0: game.leave_merchant()
		else: record.selected = game.shop.stock[selected].duplicate(true); game.buy_merchant_item(selected)
	stops.append(record)

func event_choice(game) -> int:
	var selected := 2
	if shopping == "search":
		for index in range(2):
			var choice: Dictionary = game.ExpeditionEvents.choices_for(game.event_id,game.wave)[index]
			if int(choice.get("scrip",0)) < 0 and game.coins+int(choice.scrip) >= 0 and game.player_hp+float(choice.get("hp",0)) > 0:
				selected = index; break
	events.append({"wave":game.wave,"id":game.event_id,"wallet":game.coins,"choice":selected})
	return selected
