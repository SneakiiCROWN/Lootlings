extends RefCounted

const GROVE = preload("res://art/backgrounds/beta/crystal_grove.png")
const INFERNAL = preload("res://art/backgrounds/beta/infernal_citadel.png")
const FROST = preload("res://art/backgrounds/beta/frozen_citadel.png")
const MARKET = preload("res://art/backgrounds/beta/moonmarket.png")
const PLATFORM = preload("res://art/backgrounds/beta/ruin_platform.png")
const MOONFEN = preload("res://art/backgrounds/beta/moonfen_marsh.png")
const ARCHIVE = preload("res://art/backgrounds/beta/starfall_sanctum.png")
const SKYHOOK = preload("res://art/backgrounds/beta/skyhook_city.png")
const NULLGLASS = preload("res://art/backgrounds/beta/nullglass_gate.png")
const GEARWORKS = preload("res://art/backgrounds/beta/gearworks_foundry.png")
const FIRST_HOARD = preload("res://art/backgrounds/beta/first_hoard_throne.png")
const VERDANT_MIRROR = preload("res://art/sprites/enemies/beta/verdant_mirror.png")
const FURNACE_REGENT = preload("res://art/sprites/enemies/beta/furnace_regent.png")

static func boss_texture(id: String) -> Texture2D:
	return VERDANT_MIRROR if id == "mossglass_wilds" else FURNACE_REGENT if id == "cinder_crown" else null

# Approved beta compositions; unknown IDs retain a safe painted fallback.
static func region_background(id: String, fallback: Texture2D) -> Texture2D:
	match id:
		"mossglass_wilds": return GROVE
		"frostbell_hollows": return FROST
		"cinder_crown": return INFERNAL
		"moonfen": return MOONFEN
		"starfall_archive": return ARCHIVE
		"skyhook_bastion": return SKYHOOK
		"nullglass_expanse": return NULLGLASS
		"sunken_gearworks": return GEARWORKS
		"first_hoard": return FIRST_HOARD
		_: return fallback
