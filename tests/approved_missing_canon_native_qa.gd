extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree via native isolated capture helper.
const Art=preload("res://approved_missing_runtime_art.gd")
func _initialize() -> void:
	if not preload("res://tests/test_safety.gd").require_isolated(self):return
	assert(DisplayServer.get_name()!="headless");call_deferred("review_new_canon")
func review_new_canon() -> void:
	game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
	game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
	var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game
	for size in [Vector2i(1080,2340),Vector2i(1200,1920)]:
		root.size=size;folder="res://.godot_test_data/new-canon-neutral/native/%dx%d/" % [size.x,size.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		helper.prepare("relic_beast","greatsword");game.set_process(false);game.forced_facing_test=0
		game.enemy_name="FEN SNEAK";game.enemy_archetype="skirmisher";game.enemy_is_boss=false;game.enemy_is_miniboss=false
		game.enemy_entry_anim=0;game.enemy_attack_clock=2;game.enemy_attack_anim=0;game.enemy_flash=0;game.enemy_death_anim=0;game.wave_banner_timer=0;game.player_flash=0
		game.presentation_director.set_process(false);game.presentation_director.toast_panel.hide()
		game.player_x=440
		game.enemy_encounter.active=false
		var enemy_x: float=preload("res://combat_stage.gd").enemy_position(game,game.target_combat_position().x).x
		assert(game.enemy_facing_at(enemy_x)>0)
		assert(Art.enemy_neutral(game,enemy_x).path.ends_with("fen_sneak_idle_right.png"))
		var damage=game.enemy_damage;var rng=game.rng.state;var clock=game.enemy_attack_clock
		await capture("fen_sneak_exact_idle_right_target_driven")
		assert(game.enemy_damage==damage and game.rng.state==rng and game.enemy_attack_clock==clock)
		game.enemy_attack_clock=.15;assert(Art.enemy_neutral(game,enemy_x).is_empty());await capture("fen_sneak_windup_OPEN")
		game.enemy_attack_clock=2;game.enemy_attack_anim=.15;assert(Art.enemy_neutral(game,enemy_x).is_empty())
		game.enemy_attack_anim=0;game.enemy_flash=.1;assert(Art.enemy_neutral(game,enemy_x).is_empty());await capture("fen_sneak_hurt_OPEN")
		game.enemy_flash=0;game.player_x=100;assert(game.enemy_facing_at(enemy_x)<0);assert(Art.enemy_neutral(game,enemy_x).is_empty());await capture("fen_sneak_opposite_view_OPEN")
		assert(Art.frame("moonkip","idle","right").is_empty());assert(Art.frame("pack_peddler","rest","right").is_empty())
		assert(Art.frame("fen_sneak","recovery","right").is_empty())
	helper.free();game.free();await process_frame;await process_frame
	print("APPROVED MISSING CANON PASS: exact right neutral only; no unsafe mirror, hurt/recovery/attack substitution; damage/RNG/clocks unchanged");quit()
