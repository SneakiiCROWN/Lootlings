extends RefCounted

const SCHEMA_VERSION := 3
const WandererCatalog = preload("res://wanderer_catalog.gd")

static func create_default() -> Dictionary:
	return {
		"schema_version":SCHEMA_VERSION,
		"player_uuid":create_uuid(),
		"display_name":"",
		"lootling_nickname":"",
		"profile_icon_id":"relic_beast",
		"title_id":"ruin_rookie",
		"banner_id":"outer_ruins",
		"current_lootling_id":"relic_beast",
		"avatar_mode":"lootling",
		"wanderer":WandererCatalog.create_default(),
		"cosmetic_ids":[],
		"customisation":{"skin_id":"", "head_id":"", "core_effect_id":"", "weapon_skin_id":"", "trail_id":"", "victory_pose_id":"", "emote_id":""},
		"favourite_weapon_id":"scrapfang_blade",
		"selected_badge_ids":[],
		"bosses_slain":0,
		"legendary_finds":0,
		"clan_tag":"",
		"clan_id":"",
		"account_link":{
			"provider_type":"",
			"provider_player_id":"",
			"lootlings_account_id":"",
			"linked":false,
			"cloud_save_revision":0,
			"last_sync_unix":0
		},
		"rename_metadata":{"last_rename_unix":0, "rename_count":0}
	}

static func load_profile(path: String) -> Dictionary:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return create_default()
	var profile := create_default()
	for key in profile.keys():
		profile[key] = config.get_value("profile", key, profile[key])
	profile.schema_version = SCHEMA_VERSION
	if str(profile.player_uuid).is_empty():
		profile.player_uuid = create_uuid()
	profile.display_name = sanitize_name(str(profile.display_name))
	profile.lootling_nickname = sanitize_name(str(profile.lootling_nickname))
	if not preload("res://lootling_catalog.gd").ENTRIES.has(str(profile.current_lootling_id)):
		profile.current_lootling_id = "relic_beast"
	profile.avatar_mode = "wanderer" if str(profile.avatar_mode) == "wanderer" else "lootling"
	profile.wanderer = WandererCatalog.sanitize(profile.wanderer)
	return profile

static func save_profile(path: String, profile: Dictionary) -> Error:
	var config := ConfigFile.new()
	var safe_profile := create_default()
	for key in safe_profile.keys():
		safe_profile[key] = profile.get(key, safe_profile[key])
	safe_profile.schema_version = SCHEMA_VERSION
	safe_profile.display_name = sanitize_name(str(safe_profile.display_name))
	safe_profile.lootling_nickname = sanitize_name(str(safe_profile.lootling_nickname))
	safe_profile.avatar_mode = "wanderer" if str(safe_profile.avatar_mode) == "wanderer" else "lootling"
	safe_profile.wanderer = WandererCatalog.sanitize(safe_profile.wanderer)
	for key in safe_profile:
		config.set_value("profile", key, safe_profile[key])
	return config.save(path)

static func is_created(profile: Dictionary) -> bool:
	return not sanitize_name(str(profile.get("display_name", ""))).is_empty()

static func sanitize_name(value: String) -> String:
	var cleaned := value.strip_edges().replace("\n", " ").replace("\r", " ")
	while cleaned.contains("  "):
		cleaned = cleaned.replace("  ", " ")
	return cleaned.left(20)

static func create_uuid() -> String:
	var bytes := Crypto.new().generate_random_bytes(16)
	if bytes.size() != 16:
		return "%08x-%08x-%08x-%08x" % [Time.get_unix_time_from_system(), Time.get_ticks_msec(), randi(), randi()]
	bytes[6] = (bytes[6] & 0x0f) | 0x40
	bytes[8] = (bytes[8] & 0x3f) | 0x80
	var hex := bytes.hex_encode()
	return "%s-%s-%s-%s-%s" % [hex.substr(0, 8), hex.substr(8, 4), hex.substr(12, 4), hex.substr(16, 4), hex.substr(20, 12)]
