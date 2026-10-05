extends SceneTree
# Invoked only by the process-boundary runner, never the general QA sweep.
class AckFailure:
	extends "res://local_save_provider.gd"
	var writes:=0
	func save_snapshot(path: String, section: String, snapshot: Dictionary) -> Error:
		writes+=1
		return ERR_CANT_CREATE if writes==2 else super.save_snapshot(path,section,snapshot)
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self): return
	if OS.get_environment("LOOTLINGS_RESTART_STAGE").is_empty(): quit(); return
	create_timer(40).timeout.connect(func(): push_error("Restart fixture timeout"); quit(1))
	call_deferred("review")
func review() -> void:
	var game=load("res://main.tscn").instantiate(); root.add_child(game); await process_frame
	game.set_process(false); game.app_lifecycle.platform_notifications_enabled=false
	var kind:=OS.get_environment("LOOTLINGS_RESTART_KIND")
	var stage:=OS.get_environment("LOOTLINGS_RESTART_STAGE")
	var receipt:="process-boundary:"+kind
	var progress=game.retention.progress
	var reward:={"kind":kind,"receipt":receipt,"region":"act_i","actor":"gloomlet","family":"bow","amount":2}
	if kind=="item": reward={"kind":"item","receipt":receipt,"item":preload("res://item_catalog.gd").create_item("gravebloom_staff","RED",99405)}
	if stage in ["reserve","recipient"]:
		game.expedition_progress.data.materials["act_i"]=0
		game.expedition_progress.data.actors["gloomlet"]=0
		game.expedition_progress.data.weapons["bow"]=0
		game.expedition_progress.data.fragments["oath_slab"]=0
		assert(game.expedition_progress.save()==OK)
		game.inventory.stash.clear(); game.inventory.craft_receipts.clear(); assert(game.inventory.save(game.INVENTORY_SAVE_PATH)==OK)
		progress.data.spin_wallet=860; progress.data.spins=1; progress.data.spin_sparks=1
		progress.data.pending=[reward]; assert(progress.save()==OK)
		if stage=="recipient":
			progress.provider=AckFailure.new()
			assert(progress.recover(game)=="Reward delivered; receipt retained for recovery.")
			assert(progress.data.pending.size()==1)
		var marker:=FileAccess.open("user://restart_cut_ready.txt",FileAccess.WRITE)
		marker.store_string(stage); marker.close()
		# Runner terminates this exact process handle after the durable cut marker.
		await create_timer(35).timeout; push_error("Runner did not terminate cut process"); quit(1); return
	assert(stage=="verify")
	assert(progress.data.pending.is_empty())
	assert(progress.data.spin_wallet==860 and progress.data.spins==1 and progress.data.spin_sparks==1)
	var p=game.expedition_progress.data
	match kind:
		"material": assert(p.materials.act_i==2)
		"mastery": assert(p.actors.gloomlet==2 and p.weapons.bow==2)
		"blueprint": assert(p.fragments.oath_slab==2)
		"item": assert(game.inventory.stash.filter(func(item): return item.serial==99405 and item.rarity=="RED").size()==1)
	# Replay the same durable reserved receipt and ensure recipient store wins.
	progress.data.pending=[reward]; assert(progress.save()==OK)
	assert(progress.recover(game)=="Rewards secured.")
	match kind:
		"material": assert(p.materials.act_i==2)
		"mastery": assert(p.actors.gloomlet==2 and p.weapons.bow==2)
		"blueprint": assert(p.fragments.oath_slab==2)
		"item": assert(game.inventory.stash.size()==1)
	print("RESTART VERIFIED "+kind+": exact once across fresh process and receipt replay")
	game.free(); quit()
