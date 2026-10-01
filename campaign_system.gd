extends RefCounted

const World = preload("res://world_content_catalog.gd")
const Zones = preload("res://zone_catalog.gd")
const ORDER := ["act_i", "mossglass_wilds", "moonfen", "frostbell_hollows", "sunken_gearworks", "cinder_crown", "starfall_archive", "nullglass_expanse", "skyhook_bastion", "first_hoard"]
# HP / attack interval / preferred role. These affect NEW regions only.
const TRAITS := {
	"mossglass_wilds":[1.10, 1.12, "tank", "Sturdy guards • patient strikes", Color("#64c5a5")],
	"moonfen":[0.92, 0.93, "skirmisher", "Nimble hunters • lighter bodies", Color("#989ce4")],
	"frostbell_hollows":[1.04, 1.08, "hexer", "Slow casters • hardened shells", Color("#9ed9ed")],
	"sunken_gearworks":[1.06, 1.03, "tank", "Heavy machines • caster support", Color("#68ada7")],
	"cinder_crown":[0.96, 0.96, "skirmisher", "Fast furnace beasts • brisk pressure", Color("#df996b")],
	"starfall_archive":[0.96, 1.02, "hexer", "Spell-heavy patrols • brittle pages", Color("#aab4da")],
	"nullglass_expanse":[1.03, 0.99, "hexer", "Echo casters • mixed patrols", Color("#ac8bc9")],
	"skyhook_bastion":[0.94, 0.94, "skirmisher", "Fast aerial patrols • short recoveries", Color("#a3ced9")],
	"first_hoard":[1.12, 1.08, "tank", "Vault guardians • deliberate heavy hits", Color("#dab56f")]
}
var completed: Array = []
const LOOT_POOLS := {
	"mossglass_wilds":["mossguard_harness", "moss_staff", "mire_rune"],
	"moonfen":["moonbranch", "moonbite_daggers", "critical_script"],
	"frostbell_hollows":["patchplate_vest", "tiny_bell", "bonebow"],
	"sunken_gearworks":["scrap_shivs", "stormspark", "relic_magnet_charm"],
	"cinder_crown":["cinder_staff", "ember_pop", "ironpaw_plate"],
	"starfall_archive":["glimmerstaff", "critical_script", "echo_rune"],
	"nullglass_expanse":["cursed_ring", "echo_rune", "moonbite_daggers"],
	"skyhook_bastion":["crooked_longbow", "gilded_shortbow", "stormspark"],
	"first_hoard":["vault_receipt", "bossbane_sigil", "mimic_mallet"]
}

func available(id: String) -> bool:
	var index := ORDER.find(id)
	return index == 0 or (index > 0 and ORDER[index - 1] in completed)

func finish(id: String) -> void:
	if available(id) and not id in completed:
		completed.append(id)

func save(path: String) -> Error:
	var config := ConfigFile.new()
	config.set_value("campaign", "version", 1)
	config.set_value("campaign", "completed", completed)
	return config.save(path)

func load_progress(path: String) -> void:
	completed.clear()
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return
	var saved = config.get_value("campaign", "completed", [])
	if saved is Array:
		for id in ORDER:
			if id in saved and available(id):
				completed.append(id)

static func title(id: String) -> String:
	return "ACT I • TREASURE RUINS" if id == "act_i" else str(World.FUTURE_ZONES.get(id, {}).get("name", id))

static func zone_for(id: String, wave: int) -> Dictionary:
	if not TRAITS.has(id):
		return Zones.for_wave(wave)
	var data: Dictionary = World.FUTURE_ZONES[id]
	var tuning: Array = TRAITS[id]
	var phase := clampi((wave - 1) / 5, 0, 2)
	var result: Dictionary = Zones.ZONES[phase].duplicate(true)
	result.id = id
	result.short_name = {"mossglass_wilds":"MOSSGLASS", "moonfen":"MOONFEN", "frostbell_hollows":"FROSTBELL", "sunken_gearworks":"GEARWORKS", "cinder_crown":"CINDER CROWN", "starfall_archive":"STARFALL", "nullglass_expanse":"NULLGLASS", "skyhook_bastion":"SKYHOOK", "first_hoard":"FIRST HOARD"}[id]
	result.name = "%s • TEMP ART" % data.name
	result.entry = ["ENTERING", "INNER SANCTUM", "BOSS APPROACH"][phase] + " • " + data.name
	result.accent = tuning[4]
	result.presentation_tint = Color.WHITE.lerp(tuning[4], 0.20)
	result.hp_scale = float(tuning[0]) * (1.0 + ORDER.find(id) * 0.015)
	result.interval_scale = float(tuning[1])
	result.boss = str(data.boss).to_upper()
	result.miniboss = "%s WARDEN" % str(data.enemies[2]).to_upper()
	result.enemies = {}
	var roles := ["skirmisher", "tank", "hexer"]
	for index in range(roles.size()):
		var name: String = data.enemies[index if index < 2 else 3]
		result.enemies[roles[index]] = {"id":name.to_snake_case().replace(" ", "_"), "name":name.to_upper()}
	result.compositions = []
	for local_wave in range(5):
		result.compositions.append([str(tuning[2]), roles[(local_wave + phase) % 3], roles[(local_wave + phase + 1) % 3]])
	return result
