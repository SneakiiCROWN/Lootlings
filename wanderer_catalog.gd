extends RefCounted

# Authored adult presets, not a claim that modular body/hair art is finished.
# All identity choices are flavour-only. Equipment belongs to InventoryStore.
const PRESETS := {
	"vault_runner":{"display_name":"Vault Runner", "body_frame":"athletic", "skin_tone":"umber", "face_id":"runner", "hair_id":"short_curls", "hair_colour":"dark", "outfit_cosmetic_id":"scavenger_coat", "runtime_sprite":"res://art/sprites/wanderers/beta/vault_runner_idle.png", "accent":Color("#62cbd9"), "grip":Vector2(0.719, 0.461), "core":Vector2(0.49, 0.31)},
	"ruin_warden":{"display_name":"Ruin Warden", "body_frame":"broad", "skin_tone":"bronze", "face_id":"warden", "hair_id":"braided_short", "hair_colour":"dark", "outfit_cosmetic_id":"warden_coat", "runtime_sprite":"res://art/sprites/wanderers/beta/ruin_warden_idle.png", "accent":Color("#d9b465"), "grip":Vector2(0.753, 0.438), "core":Vector2(0.473, 0.186), "body_rect":Rect2(-70,-145,140,210)},
	"nightstage_drifter":{"display_name":"Nightstage Drifter", "body_frame":"athletic", "skin_tone":"olive", "face_id":"drifter", "hair_id":"violet_shag", "hair_colour":"black_violet", "outfit_cosmetic_id":"nightstage_leathers", "runtime_sprite":"res://art/sprites/wanderers/beta/nightstage_drifter_idle.png", "accent":Color("#b694ed"), "grip":Vector2(0.787,0.446), "core":Vector2(0.463,0.181), "portrait_region":Rect2(0.35,0.015,0.34,0.23)},
	"velvet_astrologer":{"display_name":"Velvet Astrologer", "body_frame":"curvy", "skin_tone":"umber", "face_id":"astrologer", "hair_id":"silver_braids", "hair_colour":"silver", "outfit_cosmetic_id":"velvet_arcana", "runtime_sprite":"res://art/sprites/wanderers/beta/velvet_astrologer_idle.png", "accent":Color("#e2b86d"), "grip":Vector2(0.766,0.447), "core":Vector2(0.504,0.236), "portrait_region":Rect2(0.35,0.015,0.34,0.23)},
	"ashtrail_hunter":{"display_name":"Ashtrail Hunter", "body_frame":"muscular", "skin_tone":"weathered_pale", "face_id":"hunter", "hair_id":"auburn_tousled", "hair_colour":"auburn", "outfit_cosmetic_id":"ashtrail_leathers", "runtime_sprite":"res://art/sprites/wanderers/beta/ashtrail_hunter_idle.png", "accent":Color("#c6aa79"), "grip":Vector2(0.765,0.452), "core":Vector2(0.549,0.244), "portrait_region":Rect2(0.35,0.015,0.34,0.23)}
}
# Stable export slots. Baked preset components describe visible art; they are
# NOT independent equip slots until registered replacement layers are supplied.
const APPEARANCE_SLOTS := ["face", "skin_tone", "hair_style", "hair_colour", "facial_hair", "makeup", "markings", "jewellery", "headwear", "upper_outfit", "lower_outfit", "footwear", "gloves", "back_item", "armour_accents", "accessories", "style"]
const COMPONENTS := {
	"vault_runner":{"facial_hair":"none", "makeup":"natural", "markings":"none", "jewellery":"runner_relic", "headwear":"none", "upper_outfit":"scavenger_coat", "lower_outfit":"runner_trousers", "footwear":"runner_boots", "gloves":"runner_bracers", "back_item":"coat_tails", "armour_accents":"brass", "accessories":"utility_belt", "style":"practical_explorer"},
	"ruin_warden":{"facial_hair":"warden_stubble", "makeup":"none", "markings":"none", "jewellery":"warden_relic", "headwear":"none", "upper_outfit":"warden_coat", "lower_outfit":"warden_trousers", "footwear":"warden_boots", "gloves":"warden_bracers", "back_item":"coat_tails", "armour_accents":"brass", "accessories":"utility_belt", "style":"armoured_warden"},
	"nightstage_drifter":{"facial_hair":"none", "makeup":"dark_liner", "markings":"drifter_geometry", "jewellery":"violet_choker_ear_stack", "headwear":"none", "upper_outfit":"nightstage_vest", "lower_outfit":"nightstage_trousers_sash", "footwear":"nightstage_combat_boots", "gloves":"nightstage_cuffs", "back_item":"none", "armour_accents":"silver_hardware", "accessories":"chain_belt", "style":"alternative"},
	"velvet_astrologer":{"facial_hair":"none", "makeup":"plum_lip", "markings":"none", "jewellery":"arcana_gold", "headwear":"none", "upper_outfit":"arcana_bodice", "lower_outfit":"arcana_split_skirt_leggings", "footwear":"arcana_gold_boots", "gloves":"arcana_bracers", "back_item":"split_skirt_tails", "armour_accents":"gold_filigree", "accessories":"arcana_belt", "style":"glamorous_arcane"},
	"ashtrail_hunter":{"facial_hair":"auburn_beard", "makeup":"none", "markings":"hunter_cheek_scar", "jewellery":"hunter_brooch", "headwear":"none", "upper_outfit":"hunter_gambeson", "lower_outfit":"hunter_trousers", "footwear":"hunter_strapped_boots", "gloves":"hunter_bracers", "back_item":"hunter_short_cloak", "armour_accents":"bronze_pauldron", "accessories":"bone_trophy_pouches", "style":"rugged_hunter"}
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
	return {"preset_id":"vault_runner", "avatar_id":"wanderer", "body_frame":"athletic", "lineage":"reachborn", "origin":"vault_hunter", "pronouns":"they/them", "voice":"dry", "skin_tone":"umber", "face_id":"runner", "hair_id":"short_curls", "hair_colour":"dark", "markings":[], "outfit_cosmetic_id":"scavenger_coat", "head_cosmetic_id":"", "cape_cosmetic_id":"", "jewellery_cosmetic_id":"", "idle_pose_id":"ready", "victory_pose_id":"proud", "appearance":appearance_manifest("vault_runner")}

static func appearance_manifest(id: String) -> Dictionary:
	var preset: Dictionary = PRESETS.get(id, PRESETS.vault_runner)
	var components: Dictionary = COMPONENTS.get(id, COMPONENTS.vault_runner).duplicate(true)
	components.merge({"face":preset.face_id, "skin_tone":preset.skin_tone, "hair_style":preset.hair_id, "hair_colour":preset.hair_colour})
	return {"version":1, "mode":"authored_preset", "components":components}

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
	result.appearance = appearance_manifest(str(result.preset_id))
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
