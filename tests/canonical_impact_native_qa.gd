extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through the isolated native capture helper.
const Fit=preload("res://weapon_fit_catalog.gd")
const Authored=preload("res://authored_pose_manifest.gd")
const CASES=[["moonkip","daggers"],["emberhorn","claws"],["gloomlet","claws"],["glimmerfin","wand"],["glimmerfin","orb"]]
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	assert(DisplayServer.get_name()!="headless");call_deferred("review_impact")
func review_impact() -> void:
	game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	game.set_process(false) # Capture an exact sampled state; live sequences advance explicitly below.
	game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
	var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
	var baseline=OS.get_environment("LOOTLINGS_IMPACT_BASELINE")=="1"
	if baseline:
		Authored.extracted_phase("", "", "", 1)
		Authored.extracted_rows=Authored.extracted_rows.filter(func(row):return not str(row.asset_path).get_file() in ["moonkip_impact_right.png","emberhorn_impact_right.png","gloomlet_impact_right.png","glimmerfin_impact_right.png"])
		Authored.extracted_resolved.clear()
	for layout in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=layout;folder="res://.godot_test_data/source-impact/%s/%dx%d/" % ["baseline" if baseline else "native",layout.x,layout.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		for entry in CASES:
			helper.prepare(entry[0],entry[1]);game.forced_facing_test=0;game.enemy_entry_anim=0;game.wave_banner_timer=0
			game.player_flash=0 # The prior layout's real thorn retaliation must not leak a hurt pose into this sample.
			game.presentation_director.set_process(false);game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.hide()
			game.attack_anim=.11;game.attack_clock=.01
			var rng=game.rng.state;var loot_rng=game.loot_system.rng.state;var damage=game.base_damage;var interval=game.current_attack_interval()
			var pose=Fit.sample(game);assert(pose.action.phase=="IMPACT")
			assert(pose.extracted_pose and not pose.sprite_rig,"Accepted strike art must remain")
			var later: bool=str(pose.texture.resource_path).ends_with("_impact_right.png")
			assert(later!=baseline,"Baseline uses accepted early strike; revised commit uses later source strike")
			await capture("%s_%s_impact" % entry)
			assert(game.rng.state==rng and game.loot_system.rng.state==loot_rng and game.base_damage==damage and game.current_attack_interval()==interval)
			if baseline:continue
			game.player_x=game.target_player_x()+220;assert(game.combat_facing()<0);assert(Fit.sample(game).sprite_rig,"No fabricated opposite view")
			game.player_x=game.target_player_x();game.player_flash=.3;assert(Fit.sample(game,true).sprite_rig,"No impact as hurt")
			game.player_flash=0;game.attack_anim=.05;assert(Fit.sample(game).sprite_rig,"No impact as recovery")
		if baseline:continue
		for entry in CASES:
			helper.prepare(entry[0],entry[1]);game.forced_facing_test=0;game.enemy_entry_anim=0;game.attack_clock=.22
			game.player_flash=0
			game.presentation_director.set_process(false);game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.hide()
			var seen=false;var sequence=game.attack_sequence
			for step in range(45):
				game._process(1.0/60.0)
				var pose=Fit.sample(game)
				if pose.extracted_pose and pose.action.phase=="IMPACT" and not seen:
					seen=true;await capture("%s_%s_live_impact" % entry)
			assert(seen and game.attack_sequence>sequence,"Real game clock must reach source impact")
		# Trigger the real fourth-hit signature. Only its visual motif changed;
		# compare the exact existing Poison retaliation amount and survival rule.
		helper.prepare("mosskin","staff");game.forced_facing_test=0;game.enemy_entry_anim=0;game.wave_banner_timer=0
		game.inventory.equip(preload("res://item_catalog.gd").create_item("thorn_receipt","COMMON",412));assert(game.inventory.has_signature("rooted_revenge"))
		game.player_hp=game.player_max_hp;game.survived_hits=3;game.enemy_hp=1000;game.enemy_max_hp=1000
		game.enemy_is_boss=false;game.enemy_is_miniboss=false;game.enemy_archetype="skirmisher";game.enemy_variant_id="";game.enemy_damage=1
		var before_hp: float=game.enemy_hp;var expected: float=game.base_damage*.30*game.enemy_hit_multiplier
		game.perform_enemy_attack();assert(game.survived_hits==4 and is_equal_approx(before_hp-game.enemy_hp,expected))
		assert(game.element_flash_identity=="Nature");await capture("rooted_revenge_actual_fourth_hit")
	helper.free();game.free();await process_frame;await process_frame
	print("CANONICAL IMPACT PASS: five real source routes; live clocks; no fake opposite/recovery/hurt; gameplay unchanged");quit()
