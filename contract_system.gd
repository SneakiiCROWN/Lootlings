extends RefCounted

# Rotation is local and claim-driven; no clock, service, or visual RNG dependency.
const TEMPLATES := [
	{"name":"Ruin Cleanup", "event":"kill", "target":12, "gold":10},
	{"name":"Warden Worries", "event":"miniboss", "target":1, "gold":15},
	{"name":"Chest Inspector", "event":"chest", "target":3, "gold":10},
	{"name":"Big Trouble", "event":"boss", "target":1, "gold":15},
	{"name":"Home With Treasure", "event":"win", "target":1, "gold":20},
	{"name":"Experienced Scavenger", "event":"kill", "target":30, "gold":15}
]
var counts := {"kill":0, "miniboss":0, "chest":0, "boss":0, "win":0}
var next_template := 3
var active: Array = []

func _init() -> void:
	for index in range(3): active.append({"template":index, "start":0})

func record(event: String) -> void:
	if counts.has(event): counts[event] = int(counts[event]) + 1

func offer(slot: int) -> Dictionary:
	if slot < 0 or slot >= active.size(): return {}
	var assigned: Dictionary = active[slot]
	var result: Dictionary = TEMPLATES[int(assigned.template)].duplicate()
	result.progress = clampi(int(counts[result.event]) - int(assigned.start), 0, int(result.target))
	return result

func claim(slot: int) -> int:
	var current := offer(slot)
	if current.is_empty() or int(current.progress) < int(current.target): return 0
	var index := next_template % TEMPLATES.size()
	next_template += 1
	var other_templates: Array = []
	for other_slot in range(active.size()):
		if other_slot != slot: other_templates.append(int(active[other_slot].template))
	while index in other_templates:
		index = next_template % TEMPLATES.size()
		next_template += 1
	active[slot] = {"template":index, "start":int(counts[TEMPLATES[index].event])}
	return int(current.gold)

func save(path: String) -> Error:
	var config := ConfigFile.new()
	config.set_value("contracts", "version", 1)
	config.set_value("contracts", "counts", counts)
	config.set_value("contracts", "active", active)
	config.set_value("contracts", "next", next_template)
	return preload("res://safe_config.gd").save_config(config, path)

func load_progress(path: String) -> void:
	var config := ConfigFile.new()
	if preload("res://safe_config.gd").load_config(config, path, "contracts") != OK: return
	var saved_counts = config.get_value("contracts", "counts", {})
	if saved_counts is Dictionary:
		for event in counts: counts[event] = clampi(int(saved_counts.get(event, 0)), 0, 999999999)
	next_template = clampi(int(config.get_value("contracts", "next", 3)), 3, 999999999)
	var saved_active = config.get_value("contracts", "active", [])
	if saved_active is Array and saved_active.size() == 3:
		for slot in range(3):
			var entry = saved_active[slot]
			if entry is Dictionary:
				var index := clampi(int(entry.get("template", slot)), 0, TEMPLATES.size() - 1)
				active[slot] = {"template":index, "start":clampi(int(entry.get("start", 0)), 0, int(counts[TEMPLATES[index].event]))}
