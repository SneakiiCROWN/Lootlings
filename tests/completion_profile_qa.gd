extends SceneTree
const Profiles=preload("res://profile_store.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	call_deferred("run_qa")
func run_qa() -> void:
	var source:=Profiles.create_default()
	source.display_name="  Rowan  ";source.current_lootling_id="gloomlet";source.bosses_slain=17
	source.memories=["boss:act_i","memory:patch"];source.homestead={"display":"scroll"}
	var uuid: String=source.player_uuid
	assert(Profiles.save_profile("user://completion_profile.cfg",source)==OK)
	var restored:=Profiles.load_profile("user://completion_profile.cfg")
	assert(restored.player_uuid==uuid and restored.bosses_slain==17 and restored.current_lootling_id=="gloomlet" and restored.homestead.display=="scroll" and restored.memories==source.memories)
	var cfg:=ConfigFile.new();cfg.set_value("profile","player_uuid",uuid);cfg.set_value("profile","display_name",{"invalid":true});cfg.set_value("profile","bosses_slain",INF);cfg.set_value("profile","wanderer",[])
	cfg.set_value("profile","account_link",{"linked":"yes", "cloud_save_revision":-19});cfg.set_value("profile","homestead",{"display":[]});cfg.set_value("profile","companion",{"owned_ids":["enemy_proxy"],"equipped_id":"enemy_proxy"});cfg.set_value("profile","memories",["valid",9,"valid"])
	assert(cfg.save("user://malformed_profile.cfg")==OK)
	var repaired:=Profiles.load_profile("user://malformed_profile.cfg")
	assert(repaired.player_uuid==uuid and repaired.display_name=="" and repaired.bosses_slain==0 and repaired.memories==["valid"])
	assert(not repaired.account_link.linked and repaired.account_link.cloud_save_revision==0 and repaired.homestead.display=="weapon" and repaired.companion.equipped_id=="")
	var original:=ConfigFile.new();assert(original.load("user://malformed_profile.cfg")==OK and original.get_value("profile","display_name") is Dictionary)
	var companion_catalog=preload("res://companion_catalog.gd")
	for id in companion_catalog.known_ids():
		if id not in companion_catalog.available_ids():assert(companion_catalog.texture(id,"idle","right")==null)
	assert(preload("res://companion_catalog.gd").known_ids().size()==6)
	for id in preload("res://companion_catalog.gd").known_ids():
		var item_id: String=preload("res://companion_catalog.gd").ENTRIES[id].unlock_id
		assert(Profiles.grant_companion_unlock("user://completion_profile.cfg",restored,item_id)==OK)
		assert(Profiles.grant_companion_unlock("user://completion_profile.cfg",restored,item_id)==OK)
	assert(restored.companion.owned_ids.size()==6 and Profiles.load_profile("user://completion_profile.cfg").companion.owned_ids.size()==6 and restored.companion.equipped_id=="")
	assert(Profiles.grant_companion_unlock("user://completion_profile.cfg",restored,"enemy_proxy")==ERR_INVALID_PARAMETER)
	for id in companion_catalog.available_ids():
		restored.companion.equipped_id=id
		assert(Profiles.save_profile("user://completion_profile.cfg",restored)==OK)
		assert(Profiles.load_profile("user://completion_profile.cfg").companion.equipped_id==id)
	var unowned:=Profiles.create_default();unowned.companion.equipped_id="auricub"
	assert(Profiles.sanitize(unowned).companion.equipped_id=="")
	var follower:=preload("res://companion_presentation.gd").new();follower.update(.1,Vector2(240,491));assert(follower.position==Vector2(168,536));follower.react("talk");follower.update(.1,Vector2(340,491));assert(follower.state=="reaction" and follower.position.x>168)
	var settings=preload("res://settings_store.gd");var audio_cfg:=ConfigFile.new();audio_cfg.set_value("audio","master",NAN);audio_cfg.set_value("audio","music",{});audio_cfg.set_value("audio","sfx",.42);audio_cfg.set_value("audio","music_muted",{"invalid":true});assert(audio_cfg.save("user://malformed_audio.cfg")==OK)
	var audio: Dictionary=settings.load_settings("user://malformed_audio.cfg");assert(audio.master==settings.defaults().master and audio.music==settings.defaults().music and audio.sfx==.42 and not audio.music_muted)
	var shop_cfg:=ConfigFile.new();shop_cfg.set_value("shop","cycle",{});shop_cfg.set_value("shop","stock",[{"id":{},"rarity":[]},{"id":"bonebow","rarity":{},"serial":INF}]);assert(shop_cfg.save("user://malformed_shop.cfg")==OK)
	var shop=preload("res://hideout_shop_system.gd").new();shop.load("user://malformed_shop.cfg");assert(shop.cycle>=0 and shop.stock.size()==3)
	var reserved={"id":"bonebow","rarity":[],"serial":777};shop_cfg.set_value("shop","pending_cache",reserved);assert(shop_cfg.save("user://malformed_shop.cfg")==OK);shop.load("user://malformed_shop.cfg");assert(shop.requires_review() and shop.blocked_cache==reserved);assert(shop.save("user://retained_shop.cfg")==OK);var preserved:=ConfigFile.new();assert(preserved.load("user://retained_shop.cfg")==OK and preserved.get_value("shop","pending_cache")==reserved)
	var contract_cfg:=ConfigFile.new();contract_cfg.set_value("contracts","counts",{"kill":{},"boss":INF});contract_cfg.set_value("contracts","next",[]);contract_cfg.set_value("contracts","active",[{"template":{},"start":INF},{},{}]);assert(contract_cfg.save("user://malformed_contracts.cfg")==OK)
	var contracts=preload("res://contract_system.gd").new();contracts.load_progress("user://malformed_contracts.cfg");assert(contracts.counts.kill==0 and contracts.counts.boss==0 and contracts.next_template==3)
	var progress_store=preload("res://endgame_progress.gd").new();progress_store.load_progress()
	var malformed={"receipt":"spent-reward","kind":"mastery","region":"act_i","amount":3,"actor":"unknown_actor","family":"invented_weapon"}
	progress_store.data.pending=[malformed];progress_store.data.spin_wallet=777;progress_store.data.free_spins=2;assert(progress_store.save()==OK)
	var loaded=preload("res://endgame_progress.gd").new();loaded.load_progress();assert(loaded.data.pending.is_empty() and loaded.data.quarantined_rewards==[malformed])
	var random:=RandomNumberGenerator.new();random.seed=819;var rng_state: int=random.state
	loaded.spin(random,"relic_beast","greatsword");loaded.free_spin(random,"relic_beast","greatsword");assert(loaded.data.spin_wallet==777 and loaded.data.free_spins==2 and random.state==rng_state)
	assert(loaded.save()==OK);var retained=preload("res://endgame_progress.gd").new();retained.load_progress();assert(retained.data.quarantined_rewards==[malformed])
	# Isolated malformed-store exercise finished; clear only this disposable fixture.
	retained.data.quarantined_rewards=[];assert(retained.save()==OK)
	var game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.show_hideout();var attacks: int=game.attack_sequence;var coins: int=game.coins;var gold: int=game.gold
	game.hideout_ui.show_home_settings();game.hideout_ui.choose_home_display("scroll");assert(game.profile.homestead.display=="scroll" and Profiles.load_profile(game.PROFILE_SAVE_PATH).homestead.display=="scroll")
	game.hideout_ui.choose_companion("enemy_proxy");assert(game.profile.companion.equipped_id=="")
	game.hideout_ui.show_home();game.hideout_ui.choose_home_display("none");assert(game.profile.homestead.display=="scroll")
	assert(game.attack_sequence==attacks and game.coins==coins and game.gold==gold)
	game.free();await process_frame;print("COMPLETION PROFILE PASS: upgrade preservation, semantic types, bounded cosmetic shell, persisted Home choices, no reward/input mutation");quit()
