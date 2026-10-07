extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through the guarded native capture helper.
const Fit=preload("res://weapon_fit_catalog.gd")
const Authored=preload("res://authored_pose_manifest.gd")
const CASES=[
	["emberhorn","claws","windup"],["emberhorn","claws","strike"],
	["moonkip","daggers","windup"],["moonkip","daggers","strike"],
	["pebblewyrm","claws","windup"],["glimmerfin","staff","windup"],
	["glimmerfin","orb","strike"],["glimmerfin","wand","strike"],
	["gloomlet","claws","strike"]]
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	assert(DisplayServer.get_name()!="headless");call_deferred("review_actions")
func review_actions() -> void:
	game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
	var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
	# Controlled visual baseline: disable only this batch's eight source routes.
	# Existing authored poses, clocks, rigs, enemies and all v33 UI stay identical.
	var baseline=OS.get_environment("LOOTLINGS_ACTION_BASELINE")=="1"
	if baseline:
		Authored.extracted_phase("", "", "", 1)
		Authored.extracted_rows=Authored.extracted_rows.filter(func(row):
			return not str(row.asset_path).get_file() in ["emberhorn_windup_right.png","emberhorn_strike_right.png","moonkip_windup_right.png","moonkip_strike_right.png","pebblewyrm_windup_right.png","glimmerfin_windup_right.png","glimmerfin_cast_right.png","gloomlet_strike_right.png"])
		Authored.extracted_resolved.clear()
	for layout in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=layout;folder="res://.godot_test_data/canonical-actions/%s/%dx%d/" % ["baseline" if baseline else "native",layout.x,layout.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		for entry in CASES:
			helper.prepare(entry[0],entry[1]);game.forced_facing_test=0;game.enemy_entry_anim=0;game.wave_banner_timer=0
			game.presentation_director.set_process(false);game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.hide()
			game.attack_anim=0 if entry[2]=="windup" else .18;game.attack_clock=.01
			var rng=game.rng.state;var loot_rng=game.loot_system.rng.state;var damage=game.base_damage;var interval=game.current_attack_interval()
			var pose=Fit.sample(game)
			if baseline:assert(pose.sprite_rig,"Controlled baseline must expose original TEMP action")
			else:assert(not pose.sprite_rig and pose.extracted_pose,"Source action must replace TEMP")
			await capture("%s_%s_%s" % entry)
			assert(game.rng.state==rng and game.loot_system.rng.state==loot_rng and game.base_damage==damage and game.current_attack_interval()==interval)
			if baseline:continue
			if entry[2]=="strike":
				game.attack_anim=.05;assert(Fit.sample(game).sprite_rig,"Missing recovery cannot reuse strike")
				game.attack_anim=.12;assert(not Fit.sample(game).sprite_rig,"Actual strike also covers commit")
			game.player_x=game.target_player_x()+220;assert(game.combat_facing()<0);assert(Fit.sample(game).sprite_rig,"Missing opposite view cannot mirror source")
		if baseline:continue
		# Existing neutral/heavy sources remain for the rest of the locked cast.
		for actor in ["relic_beast","mosskin","vault_runner","ruin_warden","nightstage_drifter","velvet_astrologer","ashtrail_hunter"]:
			helper.prepare(actor,"maul");game.forced_facing_test=0;game.enemy_entry_anim=0;game.wave_banner_timer=0
			await capture(actor+"_preserved_heavy")
		# Advance the actual game update/attack code, rather than assigning action phases.
		for entry in [["emberhorn","claws"],["moonkip","daggers"],["pebblewyrm","claws"],["glimmerfin","orb"],["gloomlet","claws"]]:
			helper.prepare(entry[0],entry[1]);game.forced_facing_test=0;game.enemy_entry_anim=0;game.attack_clock=.22
			game.presentation_director.set_process(false);game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.hide()
			var seen={};var sequence=game.attack_sequence
			for step in range(45):
				game._process(1.0/60.0)
				var pose=Fit.sample(game)
				if pose.extracted_pose and not seen.has(pose.action.phase):
					seen[pose.action.phase]=true;await capture(entry[0]+"_live_"+pose.action.phase.to_lower())
			assert(game.attack_sequence>sequence,"Actual attack clock must fire")
	helper.free();game.free();await process_frame;await process_frame
	print("CANONICAL ACTION PASS: nine source action/family routes; no fake recovery/opposite art; combat RNG/damage/timing unchanged");quit()
