extends RefCounted

const GROVE = preload("res://art/backgrounds/beta/crystal_grove.png")
const INFERNAL = preload("res://art/backgrounds/beta/infernal_citadel.png")
const FROST = preload("res://art/backgrounds/beta/frozen_citadel.png")
const MARKET = preload("res://art/backgrounds/beta/moonmarket.png")
const PLATFORM = preload("res://art/backgrounds/beta/ruin_platform.png")
const VERDANT_MIRROR = preload("res://art/sprites/enemies/beta/verdant_mirror.png")
const FURNACE_REGENT = preload("res://art/sprites/enemies/beta/furnace_regent.png")

static func boss_texture(id: String) -> Texture2D:
	return VERDANT_MIRROR if id == "mossglass_wilds" else FURNACE_REGENT if id == "cinder_crown" else null

# Only supplied appropriate scenery: other regions retain painted fallbacks.
static func region_background(id: String, fallback: Texture2D) -> Texture2D:
	match id:
		"mossglass_wilds": return GROVE
		"frostbell_hollows": return FROST
		"cinder_crown": return INFERNAL
		_: return fallback
