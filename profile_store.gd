extends RefCounted

const SCHEMA_VERSION := 4
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
		"memories":[],
		"companion":{"equipped_id":"", "owned_ids":[], "accompany":false},
		"homestead":{"display":"weapon"},
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
	if preload("res://safe_config.gd").load_config(config, path, "profile") != OK:
		return create_default()
	var profile := create_default()
	for key in profile.keys():
		profile[key] = config.get_value("profile", key, profile[key])
	return sanitize(profile)

static func save_profile(path: String, profile: Dictionary) -> Error:
	var config := ConfigFile.new()
	var safe_profile := sanitize(profile)
	for key in safe_profile:
		config.set_value("profile", key, safe_profile[key])
	return preload("res://safe_config.gd").save_config(config, path)

static func sanitize(value: Dictionary) -> Dictionary:
	var result := create_default()
	for key in result:
		var candidate = value.get(key,result[key])
		if typeof(candidate)==typeof(result[key]): result[key]=candidate
	result.schema_version=SCHEMA_VERSION
	if result.player_uuid.is_empty() or result.player_uuid.length()>80: result.player_uuid=create_uuid()
	result.display_name=sanitize_name(result.display_name)
	result.lootling_nickname=sanitize_name(result.lootling_nickname)
	for key in ["profile_icon_id","title_id","banner_id","favourite_weapon_id","clan_tag","clan_id"]:
		result[key]=str(result[key]).strip_edges().replace("\n"," ").replace("\r"," ").left(80)
	if not preload("res://lootling_catalog.gd").ENTRIES.has(result.current_lootling_id): result.current_lootling_id="relic_beast"
	result.avatar_mode="wanderer" if result.avatar_mode=="wanderer" else "lootling"
	result.wanderer=WandererCatalog.sanitize(result.wanderer)
	result.memories=sanitize_memories(result.memories)
	result.cosmetic_ids=sanitize_memories(result.cosmetic_ids)
	result.selected_badge_ids=sanitize_memories(result.selected_badge_ids).slice(0,3)
	for key in ["bosses_slain","legendary_finds"]: result[key]=clampi(result[key],0,999999999)
	var defaults:=create_default()
	for section in ["customisation","account_link","rename_metadata"]:
		var cleaned: Dictionary=defaults[section].duplicate(true)
		for key in cleaned:
			var candidate=result[section].get(key,cleaned[key])
			if typeof(candidate)==typeof(cleaned[key]):
				cleaned[key]=candidate.left(128) if candidate is String else maxi(0,candidate) if candidate is int else candidate
		result[section]=cleaned
	result.companion=preload("res://companion_catalog.gd").sanitize(result.companion)
	result.homestead={"display":result.homestead.get("display","weapon") if result.homestead.get("display","weapon") in ["weapon","scroll","trophy","none"] else "weapon"}
	return result

static func is_created(profile: Dictionary) -> bool:
	return not sanitize_name(str(profile.get("display_name", ""))).is_empty()

static func sanitize_memories(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for id in value:
			if id is String and id.length() <= 80 and not id.is_empty() and not id in result:
				result.append(id)
			if result.size() >= 128: break
	return result

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

static func grant_companion(path: String, profile: Dictionary, id: String) -> Error:
	if id not in preload("res://companion_catalog.gd").available_ids():return ERR_INVALID_PARAMETER
	var next:=sanitize(profile)
	if not id in next.companion.owned_ids:next.companion.owned_ids.append(id)
	var error:=save_profile(path,next)
	if error==OK:profile.companion=next.companion
	return error
