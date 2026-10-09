extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through isolated native input/capture helper.
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 OS.set_environment("LOOTLINGS_QA_ENEMY_PREVIEW","1")
 create_timer(180).timeout.connect(func():push_error("Mass family timeout");quit(1))
 call_deferred("review")
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/corrected-coal/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
  game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  var helper=preload("res://tests/weapon_fit_qa.gd").new();helper.game=game;helper.prepare("relic_beast","greatsword")
  game.set_process(false);game.campaign_id="mossglass_wilds";game.wave=1;game.spawn_enemy();game.enemy_is_boss=false;game.enemy_is_miniboss=false;game.enemy_entry_anim=0;game.special_intro_timer=0;game.wave_banner_timer=0
  game.presentation_director.finish_travel();game.presentation_director.toast_queue.clear();game.presentation_director.active_toast.clear();game.presentation_director.toast_panel.hide()
  if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
  for actor in ["coal_pup"]:
   game.enemy_name=actor.replace("_"," ").to_upper();game.enemy_archetype="skirmisher";game.campaign_id={"bell_bat":"moonfen","rime_pup":"frostbell_hollows","coal_pup":"cinder_crown"}[actor]
   for facing in ["left","right"]:
    game.enemy_hp=10000;game.enemy_max_hp=10000;game.player_hp=10000;game.player_max_hp=10000;game.player_x=120 if facing=="left" else 355;game.enemy_stage_x=355 if facing=="left" else 140
    var rng_state:int=game.rng.state
    for phase in ["idle","role windup","role commit","hurt","recovery","defeat"]:
     game.enemy_alive=phase!="defeat";game.enemy_flash=.1 if phase=="hurt" else 0;game.enemy_death_anim=.62 if phase=="defeat" else 0
     game.enemy_attack_anim=.16 if phase=="role commit" else .04 if phase=="recovery" else 0;game.enemy_attack_clock=.12 if phase=="role windup" else game.enemy_attack_interval
     var frame:=preload("res://approved_missing_runtime_art.gd").enemy_neutral(game,game.enemy_stage_x)
     assert(frame.get("authored_state","")==phase and frame.source_facing==facing and not frame.get("reused_idle_for_missing_action",false),actor+" missing "+phase+" "+facing)
     await capture(actor+"_"+phase.replace(" ","_")+"_"+facing)
    assert(rng_state==game.rng.state)
    game.enemy_alive=true;game.enemy_flash=0;game.enemy_death_anim=0;game.enemy_attack_anim=0
    var hp:float=game.player_hp;game.perform_enemy_attack();assert(game.player_hp<hp)
    await capture(actor+"_actual_attack_"+facing)
    var transition:Array=[]
    for tick in range(11):
     transition.append(preload("res://enemy_art_manifest.gd").state_for(game));game.update_effects(.02)
    assert("role commit" in transition and "recovery" in transition and "idle" in transition)
    game.perform_player_attack(false);await capture(actor+"_weapon_contact_"+facing)
  helper.free();game.free();await process_frame
 print("CORRECTED COAL NATIVE PASS: 12 exact state/facing cells, correct independent left attack, real attack damage, player weapon feedback, unchanged selector RNG, three viewports");quit()
