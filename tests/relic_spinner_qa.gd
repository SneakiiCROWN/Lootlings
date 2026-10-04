extends SceneTree
const Catalog=preload("res://relic_spin_catalog.gd")
const Progress=preload("res://endgame_progress.gd")
class FailingProvider:
	extends "res://local_save_provider.gd"
	func save_snapshot(_path: String, _section: String, _snapshot: Dictionary) -> Error: return ERR_CANT_CREATE
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	create_timer(90).timeout.connect(func(): push_error("Spinner QA timeout"); quit(1))
	call_deferred("review")
func distribution(old: bool) -> Dictionary:
	var totals: Dictionary={"material":[],"mastery":[],"blueprint":[]}
	var tiers: Dictionary={}
	for seed_value in range(10000):
		var rng:=RandomNumberGenerator.new(); rng.seed=seed_value
		var run: Dictionary={"material":0,"mastery":0,"blueprint":0}
		for spin in range(3):
			var reward: Dictionary
			if old:
				var value:=rng.randf()
				reward={"kind":"material","amount":2} if value<.5 else {"kind":"mastery","amount":6} if value<.85 else {"kind":"blueprint","amount":1}
			else:
				reward=Catalog.roll(rng); tiers[reward.rarity]=int(tiers.get(reward.rarity,0))+1
			run[reward.kind]+=reward.amount
		for kind in run: totals[kind].append(run[kind])
	var result: Dictionary={"runs":10000,"tiers":tiers}
	for kind in totals:
		var values: Array=totals[kind]; values.sort()
		result[kind]={"mean":values.reduce(func(a,b): return a+b,0)/10000.0,"p10":values[1000],"p50":values[5000],"p90":values[9000],"zero_runs":values.count(0),"max":values.back()}
	return result
func review() -> void:
	print("SPINNER DISTRIBUTIONS "+JSON.stringify({"baseline":distribution(true),"after":distribution(false),"costs":[140,230,360],"guaranteed_fragment_every_paid_spins":12}))
	var game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.app_lifecycle.platform_notifications_enabled=false; game.audio_settings.cinematic_first_time=false; game.start_run(); game.set_process(false)
	var progress=game.retention.progress; var rng:=RandomNumberGenerator.new(); rng.seed=1
	# Old v1 snapshots with no spark field retain all existing progress.
	progress.data.red_fragments=7; progress.data.erase("spin_sparks"); progress.save()
	var migrated:=Progress.new(); migrated.load_progress(); assert(migrated.data.red_fragments==7 and migrated.data.spin_sparks==0)
	progress.data.spin_sparks=0; progress.data.red_fragments=0
	for run in range(4):
		progress.begin("act_i"); progress.settle(1000,20)
		for spin in range(3):
			assert(progress.spin(rng,"relic_beast","greatsword").contains("Found")); progress.recover(game)
		assert(progress.data.spin_wallet==270 and progress.data.spins==3)
	assert(progress.data.spin_sparks==0 and progress.data.red_fragments==1)
	var reload:=Progress.new(); reload.load_progress(); assert(reload.data.red_fragments==1 and reload.data.spin_sparks==0)
	var failing:=Progress.new(); failing.provider=FailingProvider.new(); failing.data.spin_wallet=1000; failing.data.spin_sparks=11
	var original:=failing.data.duplicate(true)
	assert(failing.spin(rng,"relic_beast","greatsword").contains("no currency spent") and failing.data==original)
	# All tiers deliver once, including blueprint conversion after all recipes known.
	var before: int=game.expedition_progress.data.materials.get("act_i",0)
	for id in preload("res://phase4_catalog.gd").FARMS.act_i.items: game.expedition_progress.data.fragments[id]=3
	game.expedition_progress.save()
	var expected:=before
	for reward in Catalog.POOL:
		var reserved: Dictionary=reward.duplicate(true); reserved.receipt="tiers:"+reward.rarity; reserved.region="act_i"; reserved.actor="relic_beast"; reserved.family="greatsword"
		progress.data.pending=[reserved]; progress.save(); progress.recover(game)
		if reward.kind=="material": expected+=reward.amount
		elif reward.kind=="blueprint": expected+=2
		progress.data.pending=[reserved]; progress.save(); progress.recover(game)
	assert(game.expedition_progress.data.materials.act_i==expected)
	game.coins=1000; game.total_kills=20; game.end_run(false); game.retention.show_spinner(); game.retention.selected_at=0
	# Force a low result by searching a real RNG seed; no production outcome override.
	for seed_value in range(1000):
		rng.seed=seed_value
		if Catalog.roll(rng).rarity=="COMMON": game.retention.rng.seed=seed_value; break
	game.retention.choose(0); game.retention.selected_at=0; game.retention.choose(0)
	assert(progress.data.spin_wallet==860 and progress.data.spins==1 and progress.data.spin_sparks==1)
	game.retention.choose(2); assert(not game.retention.spin_busy and game.retention.machine.stage=="settled")
	progress.data.red_fragments=24; progress.save(); game.retention.show_spinner(); game.retention.selected_at=0
	assert(game.retention.buttons[4].visible)
	game.retention.choose(0); game.retention.selected_at=0
	game.retention.machine._process(4); game.retention.machine._process(.01); game.retention.machine._process(2)
	assert(not game.retention.buttons[4].visible and game.retention.detail.size.y==130)
	game.retention.close_spinner(); game.retention.show_spinner(); assert(game.retention.dimmer.visible)
	# Actual RED forge pays existing fragments once and cannot be skipped/Back'd mid-reveal.
	progress.data.red_fragments=24; progress.save(); game.retention.show_spinner(); game.retention.selected_at=0; game.retention.choose(4)
	assert(progress.data.red_fragments==0 and game.retention.machine.rarity=="RED" and game.retention.spin_busy)
	var count: int=game.inventory.stash.size(); game.retention.selected_at=0; game.retention.choose(2); game.navigate_back()
	assert(game.retention.spin_busy and game.state=="relic_spinner" and game.inventory.stash.size()==count)
	game.retention.machine._process(4); game.retention.machine._process(.01); game.retention.machine._process(2)
	assert(not game.retention.spin_busy and game.retention.machine.stage=="settled")
	game.retention.close_spinner(); assert(not game.retention.dimmer.visible and game.state=="result")
	# Direct mode forge returns to modes, not to a stale result screen.
	game.show_hideout(); progress.data.red_fragments=24; progress.save(); game.retention.show_modes(); game.retention.selected_at=0; game.retention.choose(3)
	assert(game.retention.spinner_from_modes and game.state=="relic_spinner")
	game.retention.machine._process(4); game.retention.machine._process(.01); game.retention.machine._process(2); game.retention.close_spinner()
	assert(game.state=="mode_menu" and not game.retention.dimmer.visible)
	# A real 1% secured drop routes to the premium reveal without a paid spin.
	game.show_hideout(); game.start_run(); game.set_process(false)
	for candidate in range(2000):
		rng.seed=candidate
		if rng.randf()<.01: rng.seed=candidate; break
	progress.secure_red(1,rng); assert(not progress.data.pending.is_empty())
	game.total_kills=20; game.end_run(false); await process_frame; await process_frame
	assert(game.state=="relic_spinner" and game.retention.machine.rarity=="RED" and progress.data.spins==0)
	game.free(); print("RELIC SPINNER QA PASS: distributions, old save, 12-spin chase, debit rollback, all tiers, conversion/replay, duplicate tap, skip, RED full reveal and return origin"); quit()
