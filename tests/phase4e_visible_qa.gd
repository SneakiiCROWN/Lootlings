extends SceneTree
const Progress=preload("res://endgame_progress.gd")
class Failing:
	extends "res://local_save_provider.gd"
	func save_snapshot(_p: String,_s: String,_d: Dictionary) -> Error:return ERR_CANT_CREATE
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	call_deferred("review")
func review() -> void:
	var g=load("res://main.tscn").instantiate();root.add_child(g);await process_frame
	g.set_process(false);g.app_lifecycle.platform_notifications_enabled=false;g.audio_settings.cinematic_first_time=false
	var p=g.retention.progress;p.begin("act_i")
	assert(p.earn_spin("boss") and not p.earn_spin("boss"))
	assert(p.earn_spin("elite") and p.earn_spin("milestone") and not p.earn_spin("extraction"))
	assert(p.data.free_spins==3 and p.data.free_run_grants==3)
	p.begin("act_i");assert(p.data.free_spins==3 and p.data.free_run_grants==0)
	var restored:=Progress.new();restored.load_progress();assert(restored.data.free_spins==3)
	p.data.spin_wallet=900;p.data.spins=2;p.save()
	var rng:=RandomNumberGenerator.new();rng.seed=313
	var rng_before: int=rng.state;var before: Dictionary=p.data.duplicate(true);var provider=p.provider;p.provider=Failing.new()
	assert(not p.earn_spin("secret") and p.data==before)
	p.free_spin(rng,"relic_beast","greatsword");assert(p.data==before and rng.state==rng_before)
	p.provider=provider;p.free_spin(rng,"relic_beast","greatsword")
	assert(p.data.free_spins==2 and p.data.spin_wallet==900 and p.data.spins==2 and p.data.spin_sparks==1 and p.data.pending.size()==1)
	var reward: Dictionary=p.data.pending[0].duplicate(true);p.recover(g)
	var inventory_count: int=g.inventory.stash.size();var progress_before: Dictionary=g.expedition_progress.data.duplicate(true)
	p.data.pending=[reward];p.save();p.recover(g)
	assert(g.inventory.stash.size()==inventory_count and g.expedition_progress.data==progress_before)
	for run in range(5):
		p.begin("act_i")
		for reason in ["boss","elite","milestone"]:p.earn_spin(reason)
	assert(p.data.free_spins==12 and not p.earn_spin("secret"))
	g.show_hideout();g.hideout_ui.show_campaign();g.hideout_ui.region_sheet.visible=true
	g.hideout_ui.show_shop();assert(not g.hideout_ui.region_sheet.visible and not g.hideout_ui.speech_panel.visible)
	g.retention.show_modes("dungeons");assert(not g.hideout_ui.visible and g.input_surface()==g.retention.panel)
	g.navigate_back();assert(g.state=="hideout" and g.hideout_ui.visible and not g.retention.panel.visible)
	g.retention.show_earned_spinner();assert(g.state=="relic_spinner" and not g.result_panel.visible and g.retention.buttons[0].text.begins_with("FREE"))
	g.navigate_back();assert(g.state=="hideout" and not g.retention.dimmer.visible and not g.retention.panel.visible)
	g.start_run();g.set_process(false);g.coins=0;g.show_merchant();g.inspect_merchant_item(0)
	assert(g.merchant_detail.text.contains("CURRENTLY EQUIPPED") and g.merchant_detail.text.contains("NEW ITEM") and g.merchant_buy_button.disabled)
	var equipped: Dictionary=g.inventory.equipped.duplicate(true);g.navigate_back();assert(g.state=="playing" and g.coins==0 and g.inventory.equipped==equipped)
	g.pending_items=[g.ItemCatalog.create_item("scrapfang_blade","RARE",814)];g.show_next_item();g.navigate_back()
	assert(g.state=="playing" and g.inventory.equipped==equipped)
	g.pending_levels=1;g.show_upgrade_choices();g.inspect_upgrade(0);assert(g.upgrade_compare.text.contains("COST: FREE"));g.navigate_back()
	assert(g.state=="playing" and g.pending_levels==0 and g.inventory.equipped==equipped)
	g.boss_reward_options=[g.ItemCatalog.create_item("scrapfang_blade","EPIC",851)];g.show_boss_reward();g.inspect_boss_reward(0)
	assert(is_instance_valid(g.touch_ux.dialog));g.navigate_back();assert(g.state=="boss_reward")
	g.pending_victory=true;g.navigate_back();assert(g.state=="result" and g.inventory.equipped==equipped)
	g.navigate_back();assert(g.state=="hideout" and not g.result_panel.visible)
	g.startup_ui.show_boot();assert(g.startup_ui.current_screen=="title")
	# Same pool, fresh seeds: distribution of one free spin and capped three-spin runs.
	var table: Dictionary={"material":[],"mastery":[],"blueprint":[]};var tiers: Dictionary={}
	for seed_value in range(10000):
		rng.seed=seed_value;var run: Dictionary={"material":0,"mastery":0,"blueprint":0}
		for i in range(3):
			var r: Dictionary=preload("res://relic_spin_catalog.gd").roll(rng);run[r.kind]+=r.amount;tiers[r.rarity]=int(tiers.get(r.rarity,0))+1
		for kind in run:table[kind].append(run[kind])
	var stats: Dictionary={}
	for kind in table:
		var values: Array=table[kind];values.sort();stats[kind]={"mean":values.reduce(func(a,b):return a+b,0)/10000.0,"p10":values[1000],"p50":values[5000],"p90":values[9000],"max":values.back(),"zero":values.count(0)}
	print("EARNED SPIN DISTRIBUTIONS "+JSON.stringify({"runs":10000,"max_free_per_run":3,"bank_cap":12,"cost":0,"unchanged_pool":tiers,"three_credit_runs":stats}))
	print("VISIBLE INTEGRATION: atomic earned bank/debit/reward/pity, reload, duplicate recovery, failure rollback/RNG, caps, modal visibility, Back/Skip and equipped comparison pass")
	g.free();quit()
