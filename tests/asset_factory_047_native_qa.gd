extends "res://tests/phase4b_native_qa.gd"
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 assert(DisplayServer.get_name()!="headless")
 OS.set_environment("LOOTLINGS_MOBILE_TEST","1")
 create_timer(240).timeout.connect(func():push_error("Factory 047 timeout");quit(1))
 call_deferred("review")
func review() -> void:
 var catalog=preload("res://companion_catalog.gd")
 var probes=[]
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/asset-factory-047/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  game.profile.companion.owned_ids=catalog.known_ids()
  for id in catalog.known_ids():
   game.show_personal_home("companions");game.hideout_ui.choose_companion(id)
   assert(game.profile.companion.equipped_id==id)
   if not game.profile.companion.accompany:await tap(game.hideout_ui.companion_follow_button)
   assert(game.profile.companion.accompany)
   var saved=preload("res://profile_store.gd").load_profile(game.PROFILE_SAVE_PATH);assert(saved.companion.equipped_id==id and saved.companion.accompany)
   var equipment:String=JSON.stringify(game.inventory.equipped);var gold:int=game.gold;var attacks:int=game.attack_sequence;var rng_state:int=game.rng.state;var loot_state:int=game.loot_system.rng.state
   game.show_hideout();await capture(id+"_hub");assert(game.hideout_ui.companion_presenter.last_drawn_asset==catalog.runtime_path(id,game.hideout_ui.companion_presenter.state,game.hideout_ui.companion_presenter.facing))
   assert(JSON.stringify(game.inventory.equipped)==equipment and game.gold==gold and game.attack_sequence==attacks and game.rng.state==rng_state and game.loot_system.rng.state==loot_state)
   game.start_run();game.set_process(false);game.wave_banner_timer=0;game.special_intro_timer=0;game.presentation_director.finish_travel()
   rng_state=game.rng.state;loot_state=game.loot_system.rng.state;attacks=game.attack_sequence
   var owner:=Vector2(preload("res://weapon_fit_catalog.gd").world_position(game).x,548)
   for face in ["right","left"]:
    game.combat_companion.initialized=false;game.combat_companion.update(.1,owner,Vector2(-100,0));game.combat_companion.position.x=clampf(game.combat_companion.position.x,30,450);game.combat_companion.facing=face;game.combat_companion.state="move"
    await capture(id+"_combat_"+face)
    assert(game.combat_companion.last_drawn_asset==catalog.runtime_path(id,"move",face))
    assert(game.rng.state==rng_state and game.loot_system.rng.state==loot_state and game.attack_sequence==attacks)
   game.kill_enemy();assert(game.combat_companion.reaction_timer>0)
   game.combat_companion.update(.01,owner,Vector2(-100,0));await capture(id+"_combat_reward")
   assert(game.combat_companion.last_drawn_asset==catalog.runtime_path(id,"reaction",game.combat_companion.facing))
   game.show_personal_home();assert(not game.pause_button.visible and not game.help_label.visible);await capture(id+"_home")
   game.show_personal_home("companions");await tap(game.hideout_ui.companion_follow_button);assert(not game.profile.companion.accompany)
   game.show_hideout();await capture(id+"_stay_home");assert(game.hideout_ui.companion_presenter.last_drawn_asset=="")
   probes.append({"actor":id,"viewport":str(viewport),"canonical_assets_reused":true,"saved_toggle":true,"combat_rng_unchanged":true,"both_combat_facings":true})
  game.show_hideout()
  for key in game.hideout_ui.hub_navigation.world_buttons:
   var target=game.hideout_ui.hub_navigation.world_buttons[key]
   assert(target.get_meta("world_feedback_bound",false))
   target.button_down.emit();assert(target.get_meta("world_feedback_strength")==1.0)
  await create_timer(.5).timeout
  for key in game.hideout_ui.hub_navigation.world_buttons:
   assert(game.hideout_ui.hub_navigation.world_buttons[key].get_meta("world_feedback_strength")<.01)
  game.hideout_ui.show_stash();await capture("stash")
  game.hideout_ui.show_shop();await capture("shop")
  game.hideout_ui.show_forge();await capture("forge")
  assert(FileAccess.get_sha256("res://art/audio/production/music/title.ogg")=="7d53beed1a8ba204fb9fc7809a659ca73c755f328c7c8e456b9a037db65ec9a7")
  game.free();await process_frame
 var report=FileAccess.open("res://.godot_test_data/asset-factory-047/PROBES.json",FileAccess.WRITE);report.store_string(JSON.stringify({"probes":probes,"new_art_contracts_closed":0,"physical_device_tested":false,"fluid_animation_completed":false},"\t"));report.close()
 print("ASSET FACTORY 047 NATIVE PASS: six canonical companions, saved follow/Home toggle, Hub and combat both facings, unchanged RNG/equipment/economy/input, world cues and equipment service routes; three layouts.")
 quit()
