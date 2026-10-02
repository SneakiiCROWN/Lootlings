extends RefCounted

const Story = preload("res://world_story.gd")
const Lootlings = preload("res://lootling_catalog.gd")
const Wanderers = preload("res://wanderer_catalog.gd")
const Campaign = preload("res://campaign_system.gd")
const BASE_BACKGROUND := "res://art/backgrounds/treasure_ruins_arena.png"
const REGION_ART := {"mossglass_wilds":"crystal_grove", "moonfen":"moonfen_marsh", "frostbell_hollows":"frozen_citadel", "sunken_gearworks":"gearworks_foundry", "cinder_crown":"infernal_citadel", "starfall_archive":"starfall_sanctum", "nullglass_expanse":"nullglass_gate", "skyhook_bastion":"skyhook_city", "first_hoard":"first_hoard_throne"}
const RESIDENTS := {
	"patch":{"name":"Patch Brasswick", "role":"Salvager", "art":"patch", "lines":["The gate was scrap when Patch found it.", "He rebuilt it for people who had nowhere to return.", "'Repairs cost money. Coming home doesn't.'"]},
	"sera":{"name":"Sera Vey", "role":"Relic Keeper", "art":"sera", "lines":["The Crown's scholars put a price on living Cores.", "Sera left before they could call that wisdom.", "'Ancient power can wait. Sit down first.'"]},
	"ilex":{"name":"Ilex Quill", "role":"Archivist", "art":"ilex", "lines":["Ilex fled Starfall before her name could be erased.", "Here, witnesses matter more than perfectly written histories.", "'A blank page is not permission to forget.'"]}
}
const BOSS_ENTRIES := {
	"grump_knight":{"name":"Grump Knight", "region":"act_i", "art":"res://art/sprites/enemies/grump_knight.png", "epithet":"The Unpaid Gatekeeper", "line":"The armour creaks. The toll was due centuries ago."},
	"hoard_dragon":{"name":"The Hoard Dragon", "region":"act_i", "art":"res://art/sprites/enemies/hoard_dragon.png", "epithet":"Keeper of the Count", "line":"Every coin counted. Every intruder noticed."},
	"verdant_mirror":{"name":"The Verdant Mirror", "region":"mossglass_wilds", "art":"res://art/sprites/enemies/beta/verdant_mirror.png", "epithet":"Warden of the Stolen Spring", "line":"The water remembers a face that was never yours."},
	"furnace_regent":{"name":"The Furnace Regent", "region":"cinder_crown", "art":"res://art/sprites/enemies/beta/furnace_regent.png", "epithet":"Crowned by Tribute", "line":"Every debt feeds the furnace. It accepts no refunds."}
}

static func region_background(id: String) -> String:
	return "res://art/backgrounds/beta/%s.png" % REGION_ART[id] if REGION_ART.has(id) else BASE_BACKGROUND

static func ids() -> Array[String]:
	var result: Array[String] = ["story/hideout"]
	for id in Lootlings.selectable_ids(): result.append("character/" + id)
	for id in Wanderers.ORIGINS: result.append("origin/" + id)
	for id in RESIDENTS: result.append("resident/" + id)
	for id in Campaign.ORDER: result.append("region/" + id)
	for id in BOSS_ENTRIES: result.append("boss/" + id)
	return result

static func entry(id: String, profile: Dictionary = {}) -> Dictionary:
	var result := {"id":id, "name":"", "category":"Story", "background":BASE_BACKGROUND, "actor":"", "actor_tint":Color.WHITE, "actor_kind":"creature", "duration":6.6, "lines":[], "sound":"menu_transition", "status":"BETA LAYERED ART"}
	var key := id.get_slice("/", 1)
	match id.get_slice("/", 0):
		"character":
			if not Lootlings.ENTRIES.has(key): return {}
			var character := Lootlings.definition(key)
			result.name = character.display_name
			result.category = "Characters"
			result.actor = character.runtime_sprite if not character.temp_art else Lootlings.ENTRIES.relic_beast.runtime_sprite
			result.actor_tint = Lootlings.presentation_tint(key)
			result.lines = [str(Story.ORIGINS[key]).get_slice(". ", 0) + ".", str(character.lore), Story.mascot_line(key, 0)]
			if character.temp_art: result.status = "DOCUMENTED TEMP ART • GLOOMLET EXPORT PENDING"
		"origin":
			if not Wanderers.ORIGINS.has(key): return {}
			var appearance: Dictionary = profile.get("wanderer", Wanderers.create_default())
			result.name = Wanderers.ORIGINS[key].name
			result.category = "Characters"
			result.actor = Wanderers.definition(str(appearance.get("preset_id", "vault_runner"))).runtime_sprite
			result.actor_kind = "adult"
			result.lines = [Wanderers.ORIGINS[key].line, "Your past brought you here. It does not choose your weapon.", "The next promise is yours to make."]
			result.status = "PLAYER-CHOSEN ORIGIN • BETA PRESET"
		"resident":
			if not RESIDENTS.has(key): return {}
			var resident: Dictionary = RESIDENTS[key]
			result.name = resident.name
			result.category = "Characters"
			result.background = "res://art/backgrounds/lootlings_hideout.png"
			result.actor = "res://art/sprites/npcs/beta/%s_portrait.png" % resident.art
			result.actor_kind = "portrait"
			var body_path := "res://art/sprites/npcs/beta/%s_idle.png" % resident.art
			if ResourceLoader.exists(body_path):
				result.actor = body_path
				result.actor_kind = "adult"
				result.status = "BETA RESIDENT CUTOUT • EXISTING LORE"
			result.lines = resident.lines
			result.duration = 5.8
		"region":
			if not key in Campaign.ORDER: return {}
			result.name = Campaign.title(key)
			result.category = "Regions"
			result.background = region_background(key)
			result.lines = [Story.region_line(key, 0), Story.region_line(key, 1), "Follow the trail. Bring its story home."]
		"boss":
			if not BOSS_ENTRIES.has(key): return {}
			var boss: Dictionary = BOSS_ENTRIES[key]
			result.name = boss.name
			result.category = "Bosses"
			result.background = region_background(boss.region)
			if key == "hoard_dragon": result.background = "res://art/backgrounds/hoard_depths_arena.png"
			elif key == "grump_knight": result.background = "res://art/backgrounds/salvage_warrens_arena.png"
			result.actor = boss.art
			result.actor_kind = "boss"
			result.duration = 5.0
			result.lines = [boss.epithet, boss.line]
			result.sound = "boss_warning"
		"story":
			if key != "hideout": return {}
			result.name = "A Place to Return"
			result.background = "res://art/backgrounds/lootlings_hideout.png"
			result.lines = ["The Crownfall left its promises in pieces.", "Here, strangers built somewhere to bring them home.", "Warm lanterns. Stranger treasure. A door left unlocked."]
		_: return {}
	return result

static func available(id: String, profile: Dictionary) -> bool:
	if id.begins_with("character/"): return Lootlings.ENTRIES.has(id.get_slice("/",1))
	if id == "origin/" + str(profile.get("wanderer", {}).get("origin", "")) and profile.get("avatar_mode", "lootling") == "wanderer": return true
	return id in profile.get("memories", [])
