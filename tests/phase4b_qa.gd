extends SceneTree
const Catalog=preload("res://phase4b_catalog.gd")
const Progress=preload("res://endgame_progress.gd")
var game
class FailingProvider:
	extends "res://local_save_provider.gd"
	func save_snapshot(_path: String, _section: String, _snapshot: Dictionary) -> Error: return ERR_CANT_CREATE
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	create_timer(120).timeout.connect(func(): push_error("Phase4B fixture timeout"); quit(1))
	call_deferred("review")
func review() -> void:
	var rng:=RandomNumberGenerator.new(); rng.seed=37123
	var elites:=0; var minibosses:=0
	for round_number in range(1,101):
		for sample in range(200):
			var rule:=Catalog.round_rule(round_number,rng)
			if round_number%10==0: assert(rule.boss and rule.count==1)
			if round_number%5==0: assert(rule.elite)
			if rule.elite: elites+=1
			if rule.miniboss: minibosses+=1
	print("PHASE4B ROUNDS "+JSON.stringify({"sampled_rounds":20000,"elite_rounds":elites,"invasions":minibosses,"hp_curve_caps_at_round":15,"max_sequential_foes":6}))
	var acquisition:=[]; var spinner={"material":0,"mastery":0,"blueprint":0}
	for sample in range(3000):
		var clears:=0
		while clears<Catalog.RED_TARGET:
			clears+=1
			if rng.randf()<.01: break
		acquisition.append(clears)
		for spin in range(3):
			var reward:=Catalog.spin_reward(rng); spinner[reward.kind]+=int(reward.amount)
	acquisition.sort()
	print("PHASE4B ECONOMY "+JSON.stringify({"red_paths":3000,"clears_min":acquisition[0],"clears_median":acquisition[1500],"clears_p90":acquisition[2700],"clears_max":acquisition.back(),"spinner_totals_9000_spins":spinner,"all_spin_cost":Catalog.SPIN_COSTS.reduce(func(a,b): return a+b,0)}))
	game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.set_process(false); game.app_lifecycle.platform_notifications_enabled=false
	game.gold_upgrades.pouch=2; game.retention.siege=true; game.dungeon.active=false; game.start_run(); game.set_process(false); assert(game.coins==0)
	var owned: Dictionary=game.inventory.equipped.duplicate(true)
	var milestones:=[]
	while game.wave<=20:
		if game.state=="siege_checkpoint":
			milestones.append(game.wave); game.retention.selected_at=0
			if game.wave==20: game.retention.choose(0); break
			game.retention.choose(1)
		elif game.state=="siege_service": game.retention.selected_at=0; game.retention.choose(3)
		else:
			game.spawn_enemy(); assert(game.enemy_is_boss==(game.wave%10==0))
			game.kill_enemy(); game.loot_drops.clear(); game.pending_items.clear(); game.pending_levels=0
	assert(milestones==[10,20] and game.state=="result" and not game.campaign.completed.has("act_i"))
	assert(game.retention.progress.data.red_fragments>=2 and game.inventory.equipped==owned)
	assert(game.inventory.stash.any(func(item): return item.id=="siege_receipt"))
	assert(game.result_summary.text.contains("The Last Receipt") and game.result_summary.text.contains("Crownroot fragments"))
	var secured: int=game.retention.progress.data.red_fragments
	game.end_run(true); assert(game.retention.progress.data.red_fragments==secured)
	var progress=game.retention.progress
	progress.data.spin_wallet=1000; progress.data.spins=0; progress.save()
	for count in range(3):
		progress.spin(rng,"relic_beast","greatsword"); progress.recover(game)
	assert(progress.data.spins==3 and progress.data.spin_wallet==270)
	assert(progress.spin(rng,"relic_beast","greatsword").contains("complete"))
	# Interrupted cross-store material delivery replays exactly once.
	progress.data.pending=[{"kind":"material","receipt":"test-recovery","region":"act_i","amount":2}]; progress.save()
	var before: int=game.expedition_progress.data.materials.get("act_i",0)
	progress.recover(game); progress.data.pending=[{"kind":"material","receipt":"test-recovery","region":"act_i","amount":2}]; progress.save(); progress.recover(game)
	assert(game.expedition_progress.data.materials.act_i==before+2)
	progress.data.red_fragments=24; progress.save(); assert(progress.forge_red()); progress.recover(game)
	assert(game.inventory.stash.any(func(item): return item.id=="gravebloom_staff" and item.rarity=="RED"))
	assert(not preload("res://forge_system.gd").offer(game.ItemCatalog.create_item("gravebloom_staff","RED",123)).is_empty())
	assert(progress.track("gravebloom_staff"))
	var fresh:=Progress.new(); fresh.load_progress(); assert(fresh.data.tracked=="gravebloom_staff" and fresh.data.highest==20)
	game.show_hideout(); game.retention.siege=true; game.start_run(); game.set_process(false)
	game.retention.escrow=5; game.wave=21; game.end_run(false)
	assert(progress.data.red_fragments==0 and game.inventory.equipped==owned)
	game.show_hideout(); game.start_run(); game.set_process(false); assert(game.multi_hits==1 and game.life_steal==0 and game.coins==16)
	assert(not game.loot_system.eligible_items(false).any(func(item): return item.id in Catalog.EXCLUSIVE))
	# Pending full-stash delivery survives reopening; the receipt prevents replay.
	game.inventory.stash.clear()
	for i in range(game.inventory.stash_capacity): game.inventory.keep(game.ItemCatalog.create_item("scrapfang_blade","COMMON",i))
	progress.data.red_fragments=24; progress.data.pending.clear(); progress.save(); assert(progress.forge_red())
	var reserved: Dictionary=progress.data.pending[0].duplicate(true)
	assert(progress.recover(game).contains("Make room"))
	fresh=Progress.new(); fresh.load_progress(); assert(fresh.data.pending.size()==1 and fresh.data.red_fragments==0)
	game.inventory.stash.pop_back(); assert(fresh.recover(game)=="Rewards secured.")
	var count: int=game.inventory.stash.size(); fresh.data.pending=[reserved]; fresh.save(); fresh.recover(game); assert(game.inventory.stash.size()==count)
	assert(not Progress.valid_reward({"kind":"material","receipt":"malformed","region":"invalid","amount":2}))
	assert(not Progress.valid_reward({"kind":"item","receipt":"malformed"}))
	var failing:=Progress.new(); failing.provider=FailingProvider.new(); failing.data.spin_wallet=1000; failing.data.red_fragments=24
	assert(failing.spin(rng,"relic_beast","greatsword").contains("no currency spent") and failing.data.spin_wallet==1000 and failing.data.spins==0)
	assert(not failing.forge_red() and failing.data.red_fragments==24 and failing.data.pending.is_empty())
	# Ending again from the spinner cannot pay the same run twice.
	game.end_run(false); var gold: int=game.gold; game.state="relic_spinner"; game.end_run(true); assert(game.gold==gold)
	game.free()
	print("PHASE4B QA PASS: round20 extraction; no campaign unlock; permanent gear; spinner cap/debit; cross-store receipt; RED forge/persistence; death escrow; run reset; exclusive loot")
	quit()
