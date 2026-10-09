extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree; only isolated QA may route staged named-action candidates.
func _initialize() -> void:
    if not preload("res://tests/test_safety.gd").require_isolated(self):return
    var staged=false
    for row in preload("res://boss_art_manifest.gd").rows():
        if row.get("production_status","")=="staged_canon_candidate":staged=true
    if not staged:
        print("NOT RUN: named Dragon candidates quarantined after visual rejection; no named action acceptance.");quit(0);return
    OS.set_environment("LOOTLINGS_QA_DRAGON_PREVIEW","1")
    create_timer(160).timeout.connect(func():push_error("Named Dragon review timeout");quit(1))
    call_deferred("review")
func review() -> void:
    for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
        root.size=viewport;folder="res://.godot_test_data/hoard-named/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
        game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
        game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
        var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game;helper.prepare("relic_beast","wand")
        game.campaign_id="act_i";game.wave=15;game.spawn_enemy();game.set_process(false);game.enemy_entry_anim=0;game.special_intro_timer=0;game.wave_banner_timer=0
        game.presentation_director.finish_travel();game.presentation_director.toast_queue.clear();game.presentation_director.active_toast.clear();game.presentation_director.toast_panel.hide()
        if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
        game.enemy_hp=10000;game.enemy_max_hp=10000;game.player_hp=10000;game.player_max_hp=10000
        for facing in [-1,1]:
            game.player_x=160 if facing<0 else 355;game.enemy_stage_x=365 if facing<0 else 140
            for pair in [["BRACE",1],["COIN BREATH",2],["TAIL SWEEP",4]]:
                for phase in ["windup","commit"]:
                    var action:String=pair[0]
                    if facing<0 and (action=="TAIL SWEEP" or action=="COIN BREATH" and phase=="commit"):continue
                    game.enemy_alive=true;game.enemy_flash=0;game.enemy_death_anim=0;game.boss_recovery=0;game.boss_phase=1;game.enemy_attack_count=pair[1]
                    game.enemy_attack_clock=.1 if phase=="windup" else game.enemy_attack_interval
                    game.combat_presentation.boss_action=action;game.combat_presentation.boss_action_time=.55 if phase=="commit" else 0
                    var pose=preload("res://boss_presentation.gd").profile_for(game)
                    assert(not pose.get("reused_idle_for_missing_action",false) and pose.texture_path.contains(action.replace(" ","_")))
                    assert(pose.authored_state==phase);await capture(action.replace(" ","_")+"_"+phase+"_"+("left" if facing<0 else "right"))
                game.enemy_attack_count=pair[1];game.enemy_attack_clock=.1;game.combat_presentation.boss_action_time=0
                var hp:float=game.player_hp;game.perform_enemy_attack();assert(game.player_hp<hp and game.combat_presentation.boss_action==pair[0])
                game.enemy_attack_clock=game.enemy_attack_interval
                for tick in range(6):game.update_effects(.07);await capture("transition_%s_%d_%d" % [str(pair[0]).replace(" ","_"),facing,tick])
                assert(preload("res://boss_art_manifest.gd").state_for(game).state=="recovery")
        helper.free();game.free();await process_frame
    print("NAMED DRAGON NATIVE PASS: nine exact named action/facing cells; BRACE, breath and tail real damage/contact/settle; three viewports. Three rejected left action cells remain open.");quit()
