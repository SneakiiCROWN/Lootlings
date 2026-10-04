extends RefCounted
const Catalog = preload("res://phase4_catalog.gd")
const Items = preload("res://item_catalog.gd")
const Safe = preload("res://safe_config.gd")
const PATH := "user://expedition_progress.cfg"
var data := {"version":1,"actors":{},"weapons":{},"materials":{},"boss_parts":{},"fragments":{},"seen":{},"counts":{},"jobs":{},"claims":{},"craft_pending":{},"reward_receipts":{}}
var rng := RandomNumberGenerator.new()
var run_region := "act_i"
var run_tier := 0
var run_kills := 0
var run_events := 0
var run_elites := 0
var run_finds := []
var run_materials := 0

func load_progress() -> void:
	var cfg := ConfigFile.new()
	if Safe.load_config(cfg,PATH,"expedition") != OK: return
	for key in data:
		if key == "version": continue
		var value = cfg.get_value("expedition",key,{})
		if value is Dictionary: data[key] = value.duplicate(true)
	for key in ["actors","weapons","materials","boss_parts","fragments","counts","claims"]:
		for id in data[key].keys():
			if not id is String: data[key].erase(id); continue
			data[key][id] = clampi(Safe.int_value(data[key][id]),0,99999)
	for region in Catalog.FARMS:
		if data.jobs.has(region) and not data.jobs[region] is Dictionary: data.jobs.erase(region)

func save() -> Error:
	var cfg := ConfigFile.new()
	for key in data: cfg.set_value("expedition",key,data[key])
	return Safe.save_config(cfg,PATH)

func rank() -> int:
	var levels := 0
	for collection in [data.actors,data.weapons]:
		for xp in collection.values(): levels += mini(4,int(xp)/30)
	return mini(8,1+levels/4)

func begin_run(region: String, tier: int, seed_value: int) -> void:
	run_region = region; run_tier = clampi(tier,0,2)
	run_kills = 0; run_elites = 0; run_events = 0; run_finds.clear()
	run_materials = 0
	rng.seed = seed_value
	data.seen["region:"+region] = true

func record_kill(actor: String, weapon: String, enemy: String, elite: String, miniboss: bool, boss: bool) -> void:
	run_kills += 1
	data.actors[actor] = mini(99999,int(data.actors.get(actor,0))+1)
	data.weapons[weapon] = mini(99999,int(data.weapons.get(weapon,0))+1)
	data.seen["actor:"+actor] = true; data.seen["weapon:"+weapon] = true
	data.seen[("boss:" if boss else "miniboss:" if miniboss else "enemy:")+enemy] = true
	if not elite.is_empty():
		run_elites += 1; data.seen["elite:"+elite] = true
		increment("elite:"+run_region)
	var yield_value := (4+run_tier if boss else 2 if miniboss else 1 if not elite.is_empty() or run_kills%3 == 0 else 0)
	data.materials[run_region] = mini(99999,int(data.materials.get(run_region,0))+yield_value)
	run_materials += yield_value
	if boss or miniboss:
		var options: Array = Catalog.FARMS[run_region].items
		# Lowest-progress recipe first: deterministic boss access prevents recipe droughts.
		var lowest: String = str(options[0])
		for id in options:
			if int(data.fragments.get(id,0)) < int(data.fragments.get(lowest,0)): lowest = id
		data.fragments[lowest] = mini(3,int(data.fragments.get(lowest,0))+(1+run_tier if boss else 1))
		run_finds.append("%s • blueprint %d/3" % [Items.definition(lowest).name,int(data.fragments[lowest])])
	if boss:
		data.boss_parts[run_region] = mini(99999,int(data.boss_parts.get(run_region,0))+1)
		increment("boss:"+run_region)
	if boss or miniboss or run_kills%5 == 0: save()

func increment(id: String) -> void:
	data.counts[id] = mini(99999,int(data.counts.get(id,0))+1)

func record_event(id: String, curse: bool) -> void:
	run_events += 1; increment("event:"+run_region)
	data.seen["event:"+id] = true
	if id.begins_with("secret_"): data.seen["secret:"+id] = true
	if curse: increment("curse:"+run_region)
	save()

func finish(victory: bool) -> void:
	if victory:
		increment("clear:"+run_region)
		if run_tier > 0: increment("hardened:"+run_region)
	save()

func job(region: String) -> Dictionary:
	if not data.jobs.has(region):
		var cycle := int(data.claims.get(region,0))%4
		var kind: String = ["boss","elite","event","hardened"][cycle]
		data.jobs[region] = {"kind":kind,"start":int(data.counts.get(kind+":"+region,0))}
	var entry: Dictionary = data.jobs[region]
	var kind := str(entry.get("kind","boss"))
	if kind not in ["boss","elite","event","hardened"]: kind = "boss"
	var goal := 3 if kind == "elite" else 1
	return {"kind":kind,"target":goal,"progress":clampi(int(data.counts.get(kind+":"+region,0))-Safe.int_value(entry.get("start",0)),0,goal),"name":{"boss":"Bring back a boss seal","elite":"Thin the marked patrols","event":"Follow a roadside lead","hardened":"Walk the harder road"}[kind]}

func claim_job(region: String) -> bool:
	var current := job(region)
	if current.progress < current.target: return false
	var before := data.duplicate(true)
	data.materials[region] = mini(99999,int(data.materials.get(region,0))+6)
	var options: Array = Catalog.FARMS[region].items
	var id: String = str(options[int(data.claims.get(region,0))%options.size()])
	data.fragments[id] = mini(3,int(data.fragments.get(id,0))+1)
	data.claims[region] = int(data.claims.get(region,0))+1
	data.jobs.erase(region); job(region)
	if save() != OK: data = before; return false
	return true

func craft(id: String, inventory, inventory_path: String) -> String:
	var region := Catalog.home_for(id)
	if region.is_empty() or int(data.fragments.get(id,0)) < 3: return "Find all three blueprint fragments first."
	if inventory.stash.size() >= inventory.stash_capacity: return "Make room in Gear before forging."
	if not data.craft_pending.is_empty(): return "Finish recovering the previous forge delivery first."
	if int(data.materials.get(region,0)) < 12 or int(data.boss_parts.get(region,0)) < 1: return "Needs 12 %s and one boss seal from that region." % Catalog.FARMS[region].material
	var before := data.duplicate(true)
	var receipt := "forge:%s:%d:%d" % [id,Time.get_unix_time_from_system(),Time.get_ticks_usec()]
	var item := Items.create_item(id,"RARE",int(hash(receipt))&0x7fffffff)
	item.forge_receipt = receipt
	data.materials[region] = int(data.materials[region])-12; data.boss_parts[region] = int(data.boss_parts[region])-1
	data.craft_pending = item
	if save() != OK: data = before; return "Forge could not save. No materials were spent."
	return recover_delivery(inventory,inventory_path)

func recover_delivery(inventory, inventory_path: String) -> String:
	if data.craft_pending.is_empty(): return ""
	var item: Dictionary = preload("res://inventory_system.gd").sanitize_saved_item(data.craft_pending)
	if item.is_empty() or not item.has("forge_receipt"): return "Forge delivery needs support review; resources remain recorded."
	var receipt := str(item.forge_receipt)
	var delivered: bool = receipt in inventory.craft_receipts
	for owned in inventory.stash+inventory.equipped.values():
		if owned is Dictionary and str(owned.get("forge_receipt","")) == receipt: delivered = true
	if not delivered:
		if not inventory.keep(item): return "Forge delivery is reserved. Make room in Gear."
		inventory.craft_receipts.append(receipt)
		if inventory.save(inventory_path) != OK:
			inventory.stash.erase(item)
			inventory.craft_receipts.erase(receipt)
			return "Forge delivery is reserved until saving is available."
	data.craft_pending = {}; data.seen["item:"+str(item.id)] = true
	if save() != OK: data.craft_pending = item
	return "%s forged into Gear." % item.name

func collection_text() -> String:
	var text := "RELIC RANK %d\nUse characters and weapon families; rank unlocks routes, never raw damage.\n\n" % rank()
	for actor in data.actors:
		var title: String = Catalog.HUMANS.get(actor,{}).get("mastery",actor.capitalize().replace("_"," "))
		text += "%s  •  mastery %d  (%d defeats)\n" % [title,mini(6,int(data.actors[actor])/30),int(data.actors[actor])]
	for family in data.weapons: text += "%s  •  mastery %d\n" % [str(family).capitalize(),mini(6,int(data.weapons[family])/30)]
	text += "\nFIELD DISCOVERIES\n"
	for key in data.seen: text += str(key).replace(":"," • ").replace("_"," ").capitalize()+"\n"
	return text
