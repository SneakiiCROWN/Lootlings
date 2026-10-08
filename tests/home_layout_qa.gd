extends SceneTree
const Decor=preload("res://home_catalog.gd")
const Profiles=preload("res://profile_store.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	var old:=Profiles.create_default();old.homestead={"display":"scroll"};old.companion.owned_ids=["stonekith"]
	var migrated:=Profiles.sanitize(old)
	assert(migrated.homestead.home_layout.schema_version==1 and migrated.homestead.home_layout.placements["home.wall_display"]=="home_plans")
	assert(migrated.companion.owned_ids==["stonekith"] and migrated.companion.equipped_id=="")
	var bad: Dictionary=old.duplicate(true);bad.homestead={"display":"trophy","home_layout":{"schema_version":500,"placements":{"home.wall_display":"home_lantern","home.wall_banner":"home_banner","home.wall_light":{"wrong":"type"},"unknown":"home_trophy"},"companion_mode":"perch","companion_perch_slot":"home.wall_perch"}}
	var clean:=Profiles.sanitize(bad)
	assert(clean.homestead.home_layout.schema_version==1 and clean.homestead.home_layout.placements["home.wall_display"]=="" and clean.homestead.home_layout.placements["home.wall_banner"]=="home_banner")
	assert(clean.homestead.home_layout.placements["home.wall_light"]=="" and clean.homestead.home_layout.companion_mode=="follow")
	assert(not clean.homestead.home_layout.placements.has("unknown") and clean.companion.owned_ids==old.companion.owned_ids)
	assert(Decor.available("home_trophy") and Decor.available("home_plans") and Decor.available("home_banner") and Decor.available("home_lantern"))
	assert(not Decor.available("home_companion_cushion") and not Decor.available("home_companion_ledge"))
	assert(Profiles.save_profile("user://home_layout.cfg",clean)==OK)
	var restored:=Profiles.load_profile("user://home_layout.cfg")
	assert(restored.homestead==clean.homestead and restored.companion==clean.companion and restored.player_uuid==clean.player_uuid)
	var contract=JSON.parse_string(FileAccess.get_file_as_string("res://docs/production/master-art-delivery/HOME_LAUNCH_DECOR_CATALOGUE.json"))
	for item in contract:
		var runtime: Dictionary=Decor.ITEMS[item.decoration_id]
		assert(runtime.asset_path==item.asset_path and runtime.allowed_slots==item.allowed_slots)
		for axis in range(2):
			assert(float(runtime.canvas[axis])==float(item.canvas[axis]) and float(runtime.pivot_pixel[axis])==float(item.pivot_pixel[axis]))
	print("HOME LAYOUT PASS: authoritative catalogue, four reused props, gated perches, legacy migration, bad-slot isolation, companion ownership preserved, save/reload")
	quit()
