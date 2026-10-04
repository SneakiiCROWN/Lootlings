extends RefCounted
const Catalog=preload("res://phase4b_catalog.gd")
const Items=preload("res://item_catalog.gd")
const Safe=preload("res://safe_config.gd")
var provider=preload("res://local_save_provider.gd").new()
var data: Dictionary={"version":1,"highest":0,"best_score":0,"delivery_serial":0,"tracked":"","red_fragments":0,"spin_sparks":0,"dungeon_clears":0,"pending":[],"spin_wallet":0,"spins":0,"session":"","region":"act_i"}
const PATH="user://endgame.cfg"
func load_progress() -> void:
	var loaded: Dictionary=provider.load_snapshot(PATH,"endgame")
	for key in data:
		if loaded.has(key) and typeof(loaded[key])==typeof(data[key]): data[key]=loaded[key]
	for key in ["highest","best_score","delivery_serial","red_fragments","dungeon_clears","spin_wallet","spins"]: data[key]=clampi(Safe.int_value(data[key]),0,999999)
	data.spins=mini(3,data.spins)
	data.spin_sparks=clampi(Safe.int_value(data.spin_sparks),0,preload("res://relic_spin_catalog.gd").SPARK_TARGET-1)
	if not data.region in preload("res://phase4_catalog.gd").FARMS: data.region="act_i"
	data.pending=data.pending.filter(valid_reward)
static func valid_reward(value) -> bool:
	if not value is Dictionary or not value.get("receipt",null) is String or value.receipt.is_empty(): return false
	var kind: String=str(value.get("kind",""))
	if kind=="item": return value.get("item",null) is Dictionary and not preload("res://inventory_system.gd").sanitize_saved_item(value.item).is_empty()
	if kind not in ["material","mastery","blueprint"] or not value.get("region","") in preload("res://phase4_catalog.gd").FARMS: return false
	if not value.get("amount",null) is int or value.amount<1 or value.amount>12: return false
	return kind!="mastery" or (value.get("actor",null) is String and value.get("family",null) is String)
func save() -> Error: return provider.save_snapshot(PATH,"endgame",data)
func begin(region: String) -> void:
	data.session="run:%d:%d" % [Time.get_unix_time_from_system(),Time.get_ticks_usec()]
	data.spins=0; data.spin_wallet=0; data.region=region; save()
func track(id: String) -> bool:
	if Items.definition(id).is_empty(): return false
	var old: String=data.tracked; data.tracked=id
	if save()!=OK: data.tracked=old; return false
	return true
func target_text() -> String:
	if data.tracked.is_empty(): return "Choose a blueprint in Collection to track its home region."
	if data.tracked=="gravebloom_staff": return "TRACKED: Gravebloom Staff\nMossglass • Rootglass Vault boss / extract at Siege 20+\nCrownroot fragments %d / %d • guaranteed progress, 1%% complete drop" % [data.red_fragments,Catalog.RED_TARGET]
	var home: String=preload("res://phase4_catalog.gd").home_for(data.tracked)
	return "TRACKED: %s\nPrimary farm: %s • bosses/minibosses + regional loot" % [Items.definition(data.tracked).name,preload("res://campaign_system.gd").title(home)]
func queue_item(id: String, rarity: String) -> void:
	data.delivery_serial+=1
	var receipt: String="endgame:%s:%d" % [data.session,data.delivery_serial]
	var item:=Items.create_item(id,rarity,int(hash(receipt))&0x7fffffff); item.forge_receipt=receipt
	data.pending.append({"kind":"item","receipt":receipt,"item":item})
func secure_red(units: int, rng: RandomNumberGenerator) -> void:
	data.red_fragments=mini(999999,int(data.red_fragments)+units)
	if rng.randf()<.01: queue_item("gravebloom_staff","RED")
func forge_red() -> bool:
	if data.red_fragments<Catalog.RED_TARGET or not data.pending.is_empty(): return false
	var before:=data.duplicate(true); data.red_fragments-=Catalog.RED_TARGET; queue_item("gravebloom_staff","RED")
	if save()!=OK: data=before; return false
	return true
func settle(wallet: int, kills: int) -> void:
	data.spin_wallet=wallet if kills>=10 else 0; data.spins=0; save()
func spin(rng: RandomNumberGenerator, actor: String, family: String) -> String:
	if not data.pending.is_empty(): return "Recover the reserved reward first."
	if data.spins>=3: return "Three spins complete."
	var cost: int=Catalog.SPIN_COSTS[data.spins]
	if data.spin_wallet<cost: return "Needs %d leftover currency." % cost
	var before:=data.duplicate(true); var reward:=Catalog.spin_reward(rng)
	reward.receipt="spin:%s:%d" % [data.session,data.spins]; reward.region=data.region; reward.actor=actor; reward.family=family
	data.spin_wallet-=cost; data.spins+=1; data.pending.append(reward)
	# Debit, reserved reward and guaranteed chase progress share one atomic snapshot.
	data.spin_sparks+=1
	if data.spin_sparks>=preload("res://relic_spin_catalog.gd").SPARK_TARGET:
		data.spin_sparks=0; data.red_fragments=mini(999999,int(data.red_fragments)+1)
	if save()!=OK: data=before; return "Could not save; no currency spent."
	return "Found %d %s. Remaining %d." % [reward.amount,reward.kind,data.spin_wallet]
func recover(game) -> String:
	if not data.pending.is_empty() and save()!=OK: return "Reward reserved until saving returns."
	while not data.pending.is_empty():
		var reward: Dictionary=data.pending[0]
		if not valid_reward(reward): return "Reserved reward needs support review."
		var receipt: String=str(reward.get("receipt",""))
		if receipt.is_empty(): return "Reserved reward needs support review."
		if reward.kind=="item":
			if not receipt in game.inventory.craft_receipts:
				var item:=preload("res://inventory_system.gd").sanitize_saved_item(reward.item)
				if item.is_empty() or not game.inventory.keep(item): return "Reward reserved. Make room in Gear."
				game.inventory.craft_receipts.append(receipt)
				if game.inventory.save(game.INVENTORY_SAVE_PATH)!=OK:
					game.inventory.stash.erase(item); game.inventory.craft_receipts.erase(receipt); return "Reward reserved until saving returns."
		else:
			var p=game.expedition_progress; var before: Dictionary=p.data.duplicate(true)
			if not p.data.reward_receipts.has(receipt):
				var region: String=str(reward.region); var amount: int=int(reward.amount)
				match reward.kind:
					"material": p.data.materials[region]=int(p.data.materials.get(region,0))+amount
					"mastery":
						p.data.actors[reward.actor]=int(p.data.actors.get(reward.actor,0))+amount
						p.data.weapons[reward.family]=int(p.data.weapons.get(reward.family,0))+amount
					"blueprint":
						var options: Array=preload("res://phase4_catalog.gd").FARMS[region].items
						var id: String=""
						for candidate in options:
							if int(p.data.fragments.get(candidate,0))<3: id=candidate; break
						if id.is_empty(): p.data.materials[region]=int(p.data.materials.get(region,0))+amount*2
						else: p.data.fragments[id]=mini(3,int(p.data.fragments.get(id,0))+amount)
				p.data.reward_receipts[receipt]=true
				if p.save()!=OK: p.data=before; return "Reward reserved until saving returns."
		var removed: Dictionary=data.pending.pop_front()
		if save()!=OK: data.pending.push_front(removed); return "Reward delivered; receipt retained for recovery."
	return "Rewards secured."
