extends RefCounted

const ENTRIES := {
	"relic_beast":{"display_name":"Relic Beast", "personality":"Curious, loyal, treasure-distracted", "playstyle":"Adaptable scavenger • any weapon", "lore":"A curious scavenger with a brave little Core.", "runtime_sprite":"res://art/sprites/relic_beast_base.png", "reference":"res://art/reference/canonical/characters/Lootlings_Main_Mascot_RelicBeast_Canonical.png", "pose_profile":"relic_beast", "accent":Color("#d8b15a"), "available":true, "unlock_source":"starter", "future_passive":"", "cosmetic_slots":["skin", "head", "core", "weapon", "trail", "victory", "emote"]},
	"emberhorn":{"display_name":"Emberhorn", "personality":"Fearless, warm, impatient", "playstyle":"Fire-forward bruiser flavour", "lore":"A warm-hearted bruiser with a spark to prove.", "runtime_sprite":"", "reference":"res://art/reference/canonical/characters/Emberhorn_CharacterSheet_Canonical.png", "pose_profile":"emberhorn", "accent":Color("#f07846"), "available":false, "unlock_source":"runtime_art_required"},
	"mosskin":{"display_name":"Mosskin", "personality":"Patient, protective, unmovable", "playstyle":"Guardian and sustain flavour", "lore":"A steadfast guardian grown around ancient stone.", "runtime_sprite":"", "reference":"res://art/reference/canonical/characters/Mosskin_CharacterSheet_Canonical.png", "pose_profile":"mosskin", "accent":Color("#7eb66c"), "available":false, "unlock_source":"runtime_art_required"},
	"moonkip":{"display_name":"Moonkip", "personality":"Clever, nimble, proudly sneaky", "playstyle":"Speed and crit flavour", "lore":"A nimble moonlit rogue who pockets trouble.", "runtime_sprite":"", "reference":"res://art/reference/canonical/characters/Moonkip_CharacterSheet_Canonical.png", "pose_profile":"moonkip", "accent":Color("#9e8cff"), "available":false, "unlock_source":"runtime_art_required"},
	"pebblewyrm":{"display_name":"Pebblewyrm", "personality":"Stubborn, cheerful, extremely dense", "playstyle":"Heavy physical flavour", "lore":"A tiny rocky powerhouse with enormous confidence.", "runtime_sprite":"", "reference":"res://art/reference/canonical/characters/Pebblewyrm_CharacterSheet_Canonical.png", "pose_profile":"pebblewyrm", "accent":Color("#c08f62"), "available":false, "unlock_source":"runtime_art_required"},
	"glimmerfin":{"display_name":"Glimmerfin", "personality":"Dreamy, theatrical, tide-wise", "playstyle":"Ranged magical flavour", "lore":"A tide-touched mage with impossible pockets.", "runtime_sprite":"", "reference":"res://art/reference/canonical/characters/Glimmerfin_CharacterSheet_Canonical.png", "pose_profile":"glimmerfin", "accent":Color("#55cddd"), "available":false, "unlock_source":"runtime_art_required"},
	"gloomlet":{"display_name":"Gloomlet", "personality":"Dry, agile, suspiciously innocent", "playstyle":"Shadow assassin flavour", "lore":"A shadowy little menace who insists it was an accident.", "runtime_sprite":"", "reference":"res://art/reference/canonical/characters/Gloomlet_CharacterSheet_Canonical.png", "pose_profile":"gloomlet", "accent":Color("#9f6bc9"), "available":false, "unlock_source":"runtime_art_required"}
}

const DEFAULT_FIELDS := {
	"personality":"Curious",
	"playstyle":"Any weapon family",
	"runtime_sprite":"",
	"reference":"",
	"pose_profile":"relic_beast",
	"accent":Color("#d8b15a"),
	"available":false,
	"development_available":false,
	"unlock_source":"runtime_art_required",
	"future_passive":"",
	"cosmetic_slots":["skin", "head", "core", "weapon", "trail", "victory", "emote"],
	"victory_pose":"default_proud",
	"profile_icon":""
}

static func definition(id: String) -> Dictionary:
	var result := DEFAULT_FIELDS.duplicate(true)
	result.merge(ENTRIES.get(id, ENTRIES.relic_beast), true)
	if result.profile_icon.is_empty() and not result.runtime_sprite.is_empty():
		result.profile_icon = result.runtime_sprite
	result.development_available = bool(result.available)
	return result

static func selectable_ids() -> Array[String]:
	var result: Array[String] = []
	for id in ENTRIES:
		if bool(ENTRIES[id].get("available", false)) and not str(ENTRIES[id].get("runtime_sprite", "")).is_empty():
			result.append(id)
	return result

static func is_runtime_ready(id: String) -> bool:
	var entry := definition(id)
	return bool(entry.get("available", false)) and not str(entry.get("runtime_sprite", "")).is_empty()
