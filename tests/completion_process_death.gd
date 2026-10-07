extends SceneTree
class FailSecond:
	extends "res://local_save_provider.gd"
	var calls := 0
	func save_snapshot(path: String, section: String, snapshot: Dictionary) -> Error:
		calls+=1
		if calls==2:return ERR_CANT_CREATE
		return super.save_snapshot(path,section,snapshot)
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	call_deferred("exercise")
func exercise() -> void:
	var args:=OS.get_cmdline_user_args();var writer: bool="--writer" in args;var after: bool="--after" in args
	var kind: String="economy" if "--economy" in args else "item" if "--item" in args else "mastery" if "--mastery" in args else "blueprint" if "--blueprint" in args else "material"
	var game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
	var p=game.retention.progress
	if writer and kind=="economy":
		game.gold=321;game.meta_shards=17;game.inventory.scrap=333;game.contracts.counts.kill=12;game.contracts.claim(0);game.inventory.keep(preload("res://item_catalog.gd").create_item("bonebow","EPIC",8888));game.hideout_shop.stock[0]={}
		if "--baseline" in args:
			assert(game.inventory.save(game.INVENTORY_SAVE_PATH)==OK) # Original sequential helper boundary; shop write not reached.
		else:assert(preload("res://economy_transaction.gd").commit(game,3 if "--last" in args else 2 if after else 1 if "--mid" in args else 0)==ERR_BUSY)
		print("PROCESS_DEATH_READY economy");await create_timer(600).timeout;quit(3);return
	if not writer and kind=="economy" and "--baseline" in args:
		assert(game.inventory.stash.filter(func(item):return item.get("serial",0)==8888).size()==1 and not game.hideout_shop.stock[0].is_empty())
		print("PROCESS_DEATH_RECOVERY_PASS baseline: purchased ownership persisted while same offer remained available");game.free();await process_frame;quit();return
	if not writer and kind=="economy":
		assert(game.gold==321 and game.meta_shards==17 and game.inventory.scrap==333 and game.inventory.stash.filter(func(item):return item.get("serial",0)==8888).size()==1 and game.hideout_shop.stock[0].is_empty())
		assert(game.contracts.offer(0).event=="boss" and game.contracts.claim(0)==0);assert(not FileAccess.file_exists(preload("res://economy_transaction.gd").PATH));print("PROCESS_DEATH_RECOVERY_PASS economy");game.free();await process_frame;quit();return
	if writer:
		p.data.spin_wallet=777;p.data.free_spins=2;p.data.pending=[{"receipt":"process-death:"+kind,"kind":kind,"region":"act_i","amount":3,"actor":"relic_beast","family":"greatsword"}]
		if kind=="item":p.data.pending[0].item=preload("res://item_catalog.gd").create_item("bonebow","EPIC",7733)
		assert(game.inventory.save(game.INVENTORY_SAVE_PATH)==OK and game.expedition_progress.save()==OK and p.save()==OK)
		if after:
			p.provider=FailSecond.new();p.recover(game);assert(p.data.pending.size()==1)
		print("PROCESS_DEATH_READY "+kind+" "+("after_destination" if after else "before_destination"))
		# Harness kills this exact disposable process after the ready marker.
		await create_timer(600).timeout;quit(3);return
	# Game startup already invokes production recovery. Repeating it must be inert.
	p.recover(game);assert(p.data.pending.is_empty() and p.data.spin_wallet==777 and p.data.free_spins==2)
	if kind=="item":assert(game.inventory.stash.filter(func(item):return item.get("serial",0)==7733).size()==1)
	elif kind=="material":assert(game.expedition_progress.data.materials.act_i==3)
	elif kind=="mastery":assert(game.expedition_progress.data.actors.relic_beast==3 and game.expedition_progress.data.weapons.greatsword==3)
	else:assert(game.expedition_progress.data.fragments.values().reduce(func(sum,value):return sum+int(value),0)==3)
	var inventory: Array=game.inventory.stash.duplicate(true);var progress: Dictionary=game.expedition_progress.data.duplicate(true);p.recover(game);assert(game.inventory.stash==inventory and game.expedition_progress.data==progress)
	print("PROCESS_DEATH_RECOVERY_PASS "+kind);game.free();await process_frame;quit()
