extends RefCounted
# Match rendered species/body, not combat class. Variants never change species.
const PROFILES := ["relic","ember","moss","moon","pebble","glimmer","gloom","imp","brute","hexer","dragon","forge","human_light","human_heavy"]
const PLAYER_PROFILES := {"relic_beast":"relic","emberhorn":"ember","mosskin":"moss","moonkip":"moon","pebblewyrm":"pebble","glimmerfin":"glimmer","gloomlet":"gloom","vault_runner":"human_light","velvet_astrologer":"human_light","nightstage_drifter":"human_light","ruin_warden":"human_heavy","ashtrail_hunter":"human_heavy"}

static func player(g) -> String:
	var avatar = preload("res://avatar_presentation.gd")
	var id: String = avatar.preset_id(g.profile) if avatar.is_wanderer(g.profile) else str(g.profile.get("current_lootling_id","relic_beast"))
	return PLAYER_PROFILES.get(id,"relic")

static func enemy(g) -> String:
	if g.enemy_is_boss:
		if g.campaign_id == "mossglass_wilds": return "moss"
		if g.campaign_id == "cinder_crown": return "forge"
		return "dragon" # Other campaigns currently reuse the approved dragon body.
	if g.enemy_is_miniboss: return "human_heavy" # Armoured Grump Knight.
	if g.enemy_archetype == "tank":
		return "forge" if g.current_zone_id == "emberworks" else "brute"
	return "hexer" if g.enemy_archetype == "hexer" else "imp"
