extends SceneTree
const Progress = preload("res://expedition_progress.gd")
const Catalog = preload("res://phase4_catalog.gd")
const Inventory = preload("res://inventory_system.gd")
const Items = preload("res://item_catalog.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	create_timer(90).timeout.connect(func(): push_error("Phase 4 fixture did not complete"); quit(1))
	call_deferred("review")
func review() -> void:
	var p := Progress.new(); p.load_progress(); assert(p.rank() == 1)
	var inv := Inventory.new(); inv.save("user://phase4_inventory.cfg")
	var ids := {}
	print("PHASE4 CATALOG total=%d new=%d families=%d humans=%d" % [Items.ITEMS.size(),Catalog.ITEMS.size(),preload("res://weapon_catalog.gd").live_ids().size(),Catalog.HUMANS.size()])
	for item in Catalog.ITEMS:
		assert(not ids.has(item.id)); ids[item.id] = true
		var gear := Items.create_item(item.id,"RARE",1)
		assert(not gear.is_empty() and not gear.signature_hooks.is_empty())
		assert(not Catalog.home_for(item.id).is_empty())
		if gear.slot == "Weapon": assert(gear.weapon_type in preload("res://weapon_catalog.gd").live_ids())
	for region in Catalog.FARMS:
		var q := Progress.new(); q.begin_run(region,0,18293)
		for run in range(6):
			for kill in range(40): q.record_kill("vault_runner","daggers","Razor Imp","",false,false)
			q.record_kill("vault_runner","daggers","Grump Knight","",true,false)
			q.record_kill("vault_runner","daggers","Keeper","",false,true)
		for id in Catalog.FARMS[region].items: assert(int(q.data.fragments.get(id,0)) == 3,"Bounded blueprint access: "+id)
		print("PHASE4 FARM "+JSON.stringify({"region":region,"six_clears_material":q.data.materials[region],"boss_seals":q.data.boss_parts[region],"fragments":q.data.fragments}))
	p = Progress.new(); p.begin_run("act_i",0,1923)
	for count in range(90): p.record_kill("vault_runner","daggers","Imp","armoured" if count%4 == 0 else "",false,false)
	assert(p.rank() >= 2 and int(p.data.actors.vault_runner) == 90)
	p.data.fragments.oath_slab = 3; p.data.materials.act_i = 24; p.data.boss_parts.act_i = 2
	p.save(); var reload := Progress.new(); reload.load_progress(); assert(reload.data.actors == p.data.actors and reload.rank() == p.rank())
	assert(p.craft("oath_slab",inv,"user://phase4_inventory.cfg").contains("forged"))
	assert(inv.stash.size() == 1 and int(p.data.materials.act_i) == 12)
	var receipt: String = inv.stash[0].forge_receipt
	# Interrupted finalize: inventory receipt survives even if the player scraps the item.
	p.data.craft_pending = inv.stash[0].duplicate(true); p.save()
	inv.stash.clear(); inv.save("user://phase4_inventory.cfg")
	var fresh := Inventory.new(); fresh.load("user://phase4_inventory.cfg")
	assert(receipt in fresh.craft_receipts); p.recover_delivery(fresh,"user://phase4_inventory.cfg")
	assert(fresh.stash.is_empty() and p.data.craft_pending.is_empty())
	# Full stash is fail-closed before payment.
	while fresh.stash.size() < fresh.stash_capacity: fresh.stash.append(Items.create_item("oath_slab","RARE",fresh.stash.size()))
	assert(p.craft("oath_slab",fresh,"user://phase4_inventory.cfg").contains("Make room")); assert(int(p.data.materials.act_i) == 12)
	fresh.stash.clear(); p.job("act_i"); p.increment("boss:act_i")
	var materials: int = int(p.data.materials.act_i)
	assert(p.claim_job("act_i")); assert(not p.claim_job("act_i")); assert(int(p.data.materials.act_i) == materials+6)
	# Seeded real target tables; inspect actual item choices, not only catalog weights.
	for region in Catalog.FARMS:
		var loot := preload("res://loot_system.gd").new(9123)
		loot.region_pool = preload("res://campaign_system.gd").LOOT_POOLS.get(region,[]).duplicate()
		loot.region_pool.append_array(Catalog.FARMS[region].items)
		var drops := 0; var targeted := 0; var named := 0; var drought := 0; var max_drought := 0
		for draw in range(3000):
			var item: Dictionary = loot.roll_drop(false,false)
			if item.is_empty(): continue
			drops += 1
			if item.id in Catalog.FARMS[region].items: named += 1
			if item.id in loot.region_pool: targeted += 1; drought = 0
			else: drought += 1; max_drought = maxi(max_drought,drought)
		print("PHASE4 TARGET "+JSON.stringify({"region":region,"draws":3000,"drops":drops,"targeted":targeted,"new_named":named,"max_non_target_drop_streak":max_drought}))
		assert(drops > 100 and targeted > drops*.25 and named > drops*.1 and max_drought <= 3)
	# Current game wiring, persistent human cohort, unaltered normal and explicit tier pressure.
	var game = load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.set_process(false); game.audio_settings.cinematic_first_time = false
	for actor in Catalog.HUMANS:
		game.profile.avatar_mode = "wanderer"; game.profile.wanderer.preset_id = actor
		game.start_run(); assert(game.character_trait == game.CharacterTraits.TRAITS[actor])
		for source in Catalog.ITEMS:
			if source.slot != "Weapon": continue
			game.inventory.equipped.Weapon = Items.create_item(source.id,"RARE",7)
			game.refresh_equipment_health(); game.player_x = game.target_player_x()
			game.perform_player_attack(false)
	game.expedition_progress.save(); game.free()
	print("PHASE4 QA PASSED: catalogs/use mastery/migration/persistence/forge receipt/full stash/contracts/target distributions/human weapons")
	quit()
