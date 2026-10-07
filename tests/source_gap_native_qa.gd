extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through the isolated native capture helper.
const Fit=preload("res://weapon_fit_catalog.gd")
const Actors=preload("res://lootling_catalog.gd")
const Wanderers=preload("res://wanderer_catalog.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	assert(DisplayServer.get_name()!="headless");call_deferred("review_gaps")
func review_gaps() -> void:
	game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
	var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
	for layout in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=layout;folder="res://.godot_test_data/source-impact/gaps/%dx%d/" % [layout.x,layout.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		for weapon in ["greatsword","bow","wand","staff","daggers","claws"]:
			helper.prepare("relic_beast",weapon);game.forced_facing_test=0;game.enemy_entry_anim=0;game.wave_banner_timer=0
			game.presentation_director.set_process(false);game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.hide()
			var neutral=Fit.sample(game);assert(not neutral.sprite_rig if weapon in ["greatsword","wand","daggers","claws"] else neutral.sprite_rig)
			await capture("relic_beast_"+weapon+"_neutral_"+("TEMP" if neutral.sprite_rig else "canonical"))
			game.attack_anim=.18;var strike=Fit.sample(game)
			assert(not strike.sprite_rig if weapon=="greatsword" else strike.sprite_rig)
			await capture("relic_beast_"+weapon+"_strike_"+("TEMP" if strike.sprite_rig else "canonical"))
			game.attack_anim=.05;assert(Fit.sample(game).sprite_rig if weapon!="greatsword" else not Fit.sample(game).sprite_rig)
			assert(Fit.sample(game,true).sprite_rig if weapon!="greatsword" else not Fit.sample(game,true).sprite_rig)
		var all_actors: Array=Actors.selectable_ids();all_actors.append_array(Wanderers.selectable_ids())
		for actor in all_actors:
			helper.prepare(actor,"greatsword");game.forced_facing_test=0;game.enemy_entry_anim=0;game.wave_banner_timer=0
			game.presentation_director.set_process(false);game.presentation_director.toast_queue.clear();game.presentation_director.toast_panel.hide()
			var pose=Fit.sample(game)
			assert(not pose.sprite_rig if actor=="relic_beast" or actor in Wanderers.PRESETS else pose.sprite_rig)
			await capture(actor+"_preserved_greatsword_"+("TEMP" if pose.sprite_rig else "canonical"))
	helper.free();game.free();await process_frame;await process_frame
	print("SOURCE GAP NATIVE PASS: canonical Relic neutral/heavy preserved; missing ranged/paired actions remain TEMP; all twelve current heavy mappings preserved without false art acceptance");quit()
