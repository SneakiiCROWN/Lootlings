extends RefCounted

# Authored adult presets, not a claim that modular body/hair art is finished.
# All identity choices are flavour-only. Equipment belongs to InventoryStore.
const PRESETS := {
	"vault_runner":{"display_name":"Vault Runner", "body_frame":"athletic", "skin_tone":"umber", "face_id":"runner", "hair_id":"short_curls", "hair_colour":"dark", "outfit_cosmetic_id":"scavenger_coat", "runtime_sprite":"res://art/sprites/wanderers/beta/vault_runner_idle.png", "accent":Color("#62cbd9"), "grip":Vector2(0.719, 0.461), "core":Vector2(0.49, 0.31)},
	"ruin_warden":{"display_name":"Ruin Warden", "body_frame":"broad", "skin_tone":"bronze", "face_id":"warden", "hair_id":"braided_short", "hair_colour":"dark", "outfit_cosmetic_id":"warden_coat", "runtime_sprite":"res://art/sprites/wanderers/beta/ruin_warden_idle.png", "accent":Color("#d9b465"), "grip":Vector2(0.753, 0.438), "core":Vector2(0.473, 0.186), "body_rect":Rect2(-70,-145,140,210)}
}
const BODY_FRAMES := ["light", "athletic", "curvy", "broad", "heavy", "muscular"]
const LINEAGES := {"reachborn":"Reachborn", "ashmarked":"Ashmarked", "veilborn":"Veilborn", "starbound":"Starbound", "greenwoken":"Greenwoken"}
const ORIGINS := {
	"vault_hunter":{"name":"Vault Hunter", "line":"Some doors are locked. Others are merely expensive."},
	"moonfen_rogue":{"name":"Moonfen Rogue", "line":"The fen taught you which promises float."},
	"cinder_exile":{"name":"Cinder Exile", "line":"You left the ashes. They did not leave you."},
	"starfall_witch":{"name":"Starfall Witch", "line":"You learned to listen when the sky cracked."},
	"lantern_warden":{"name":"Lantern Warden", "line":"Keep the light. Count everyone home."},
	"wilds_ranger":{"name":"Wilds Ranger", "line":"Tracks tell the truth. Treasure maps rarely do."},
	"gearworks_tinker":{"name":"Gearworks Tinker", "line":"Nothing is broken until you run out of pockets."},
	"relic_priest":{"name":"Relic Priest", "line":"Old things remember. You try to ask politely."}
}
const VOICES := ["warm", "dry", "bold", "soft", "playful", "ominous"]
const PRONOUNS := ["they/them", "she/her", "he/him"]
static var textures := {}

static func create_default() -> Dictionary:
	return {"preset_id":"vault_runner", "avatar_id":"wanderer", "body_frame":"athletic", "lineage":"reachborn", "origin":"vault_hunter", "pronouns":"they/them", "voice":"dry", "skin_tone":"umber", "face_id":"runner", "hair_id":"short_curls", "hair_colour":"dark", "markings":[], "outfit_cosmetic_id":"scavenger_coat", "head_cosmetic_id":"", "cape_cosmetic_id":"", "jewellery_cosmetic_id":"", "idle_pose_id":"ready", "victory_pose_id":"proud"}

static func sanitize(value: Variant) -> Dictionary:
	var result := create_default()
	if value is Dictionary:
		for key in result:
			result[key] = value.get(key, result[key])
	if not PRESETS.has(str(result.preset_id)):
		result.preset_id = "vault_runner"
	# These are authored presets; unsupported modular values must not imply art
	# that the player cannot actually see. Keep identity independent of physique.
	var preset: Dictionary = PRESETS[result.preset_id]
	for key in ["body_frame", "skin_tone", "face_id", "hair_id", "hair_colour", "outfit_cosmetic_id"]:
		result[key] = preset[key]
	result.avatar_id = "wanderer"
	for pair in [["lineage", LINEAGES, "reachborn"], ["origin", ORIGINS, "vault_hunter"]]:
		if not pair[1].has(str(result[pair[0]])):
			result[pair[0]] = pair[2]
	if not VOICES.has(str(result.voice)):
		result.voice = "dry"
	result.pronouns = str(result.pronouns).strip_edges().replace("\n", " ").replace("\r", " ").left(24)
	if result.pronouns.is_empty():
		result.pronouns = "they/them"
	result.markings = []
	for key in ["head_cosmetic_id", "cape_cosmetic_id", "jewellery_cosmetic_id"]:
		result[key] = ""
	result.idle_pose_id = "ready"
	result.victory_pose_id = "proud"
	return result

static func definition(id: String) -> Dictionary:
	return PRESETS.get(id, PRESETS.vault_runner)

static func runtime_texture(id: String) -> Texture2D:
	if not textures.has(id):
		var path: String = definition(id).runtime_sprite
		textures[id] = load(path) if ResourceLoader.exists(path) else null
	return textures[id]

static func selectable_ids() -> Array[String]:
	var ids: Array[String] = []
	for id in PRESETS:
		if ResourceLoader.exists(str(PRESETS[id].runtime_sprite)):
			ids.append(id)
	return ids

static func bark(appearance: Dictionary, context: String) -> String:
	if context not in ["victory", "boss_defeated", "early_defeat", "legendary_find", "signature_find"]:
		return str(ORIGINS.get(str(appearance.get("origin", "vault_hunter")), ORIGINS.vault_hunter).line)
	var voice := str(appearance.get("voice", "dry"))
	var lines := {
		"victory":{"warm":"Everyone home. Treasure too.", "dry":"A profitable misunderstanding.", "bold":"That vault knows my name now.", "soft":"We made it. Let the light settle.", "playful":"Good news: the pockets survived.", "ominous":"Something in the ruins followed us home."},
		"early_defeat":{"warm":"A little rest. Then we try again.", "dry":"I have identified several tactical regrets.", "bold":"Next time, the ruins blink first.", "soft":"Not every door opens today.", "playful":"Apparently that was the biting end.", "ominous":"The dark remembers. So will I."},
		"legendary_find":{"warm":"Someone kept this safe for us.", "dry":"Finally. A useful family heirloom.", "bold":"Now that is worth a little danger.", "soft":"Listen. It still remembers its maker.", "playful":"I need a dramatically larger pocket.", "ominous":"It was waiting. I am not sure for whom."}
	}
	var key := "legendary_find" if context == "signature_find" else "victory" if context == "boss_defeated" else context
	return str(lines[key].get(voice, lines[key].dry))
