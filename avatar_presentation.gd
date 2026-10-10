extends RefCounted

const Lootlings = preload("res://lootling_catalog.gd")
const Wanderers = preload("res://wanderer_catalog.gd")
static var portraits := {}

static func is_wanderer(profile: Dictionary) -> bool:
	return str(profile.get("avatar_mode", "lootling")) == "wanderer"

static func preset_id(profile: Dictionary) -> String:
	return str(profile.get("wanderer", {}).get("preset_id", "vault_runner"))

static func texture(profile: Dictionary) -> Texture2D:
	return Wanderers.runtime_texture(preset_id(profile)) if is_wanderer(profile) else Lootlings.runtime_texture(str(profile.get("current_lootling_id", "relic_beast")))

static func tint(profile: Dictionary) -> Color:
	return Color.WHITE if is_wanderer(profile) else Lootlings.presentation_tint(str(profile.get("current_lootling_id", "relic_beast")))

static func portrait(profile: Dictionary, expression: String = "determined") -> Texture2D:
	if not is_wanderer(profile):
		if str(profile.get("current_lootling_id","relic_beast"))=="relic_beast":
			if not portraits.has("relic_beast"):
				var face:=AtlasTexture.new();face.atlas=preload("res://art/sprites/relic_beast_base.png")
				face.region=Rect2(540,285,510,440);portraits.relic_beast=face
			return portraits.relic_beast
		var extracted := preload("res://phase4e_extracted_art.gd").portrait(str(profile.get("current_lootling_id","relic_beast")),expression)
		if extracted != null: return extracted
		return texture(profile)
	var id := preset_id(profile)
	if not portraits.has(id):
		var source := texture(profile)
		if source == null:
			return null
		var image := AtlasTexture.new()
		image.atlas = source
		var region := Rect2(0.35, 0.06, 0.34, 0.23) if id == "vault_runner" else Rect2(0.35, 0.01, 0.34, 0.23)
		region = Wanderers.definition(id).get("portrait_region", region)
		image.region = Rect2(region.position * source.get_size(), region.size * source.get_size())
		portraits[id] = image
	return portraits[id]

static func fit_rect(profile: Dictionary, rect: Rect2) -> Rect2:
	if not is_wanderer(profile):
		return rect
	var width := rect.size.y * 2.0 / 3.0
	return Rect2(rect.position + Vector2((rect.size.x - width) * 0.5, 0), Vector2(width, rect.size.y))

static func display_name(profile: Dictionary) -> String:
	return str(Wanderers.definition(preset_id(profile)).display_name) if is_wanderer(profile) else str(Lootlings.definition(str(profile.get("current_lootling_id", "relic_beast"))).display_name)

static func identity_line(profile: Dictionary) -> String:
	if is_wanderer(profile):
		var appearance: Dictionary = profile.get("wanderer", {})
		return str(Wanderers.ORIGINS.get(str(appearance.get("origin", "vault_hunter")), Wanderers.ORIGINS.vault_hunter).name)
	return display_name(profile)

# Cache only transparent margins of accepted runtime bodies; retain every body pixel.
static var grounded_bodies: Dictionary = {}
static func grounded_texture(source: Texture2D) -> Texture2D:
	var key: String = source.resource_path
	if not grounded_bodies.has(key):
		var image: Image = source.get_image()
		var bounds: Rect2i = image.get_used_rect()
		if bounds.size.x == 0 or bounds.size.y == 0: return source
		var body := AtlasTexture.new()
		body.atlas = source
		body.region = Rect2(bounds)
		grounded_bodies[key] = body
	return grounded_bodies[key]
