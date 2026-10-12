extends "res://tests/phase4b_native_qa.gd"
const Rewards=preload("res://home_rewards.gd")
const Decor=preload("res://home_catalog.gd")
func review() -> void:
 var rows:Array=[]
 for viewport in [Vector2i(480,854),Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/home067/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  game.achievements.reset();game.profile=preload("res://profile_store.gd").create_default();game.profile.display_name="Rowan"
  game.show_personal_home();await capture("home_unearned")
  var home=game.personal_home;var hub=game.hideout_ui;var saved:Dictionary=game.profile.homestead.duplicate(true)
  await tap(home.buttons.archive);assert(hub.current_screen=="achievements" and hub.private_return);hub.select_achievement("hoard_dragon");assert(hub.achievement_display_button.disabled);await capture("archive_goal")
  game.navigate_back();assert(home.visible)
  await tap(home.buttons.display);home.draft.placements["home.wall_display"]=Rewards.DECOR_ID;home.apply_decor();assert(home.view=="decor" and game.profile.homestead==saved);game.navigate_back()
  # Real equipped gear, actual boss spawn/attack/HP removal. Controlled final
  # wave fixture; no claim of a complete campaign or human balance acceptance.
  game.inventory.equip(game.ItemCatalog.create_item("dawnweave","MYTHICAL SHINY",67001));game.campaign_id="act_i";game.start_run();game.set_process(false);game.wave=15;game.spawn_enemy();game.wave_banner_timer=0;game.enemy_entry_anim=0;game.player_x=game.target_player_x()
  for id in ["damage","damage","damage","damage","multi","multi","vamp","vamp","regen","regen","armor","armor"]:
   for up in game.UPGRADES:
    if up.id==id:game.apply_upgrade_effect(up);break
  var elapsed:=0.0;var tapped:=0.0
  while game.enemy_alive and game.state=="playing" and elapsed<60:
   game._process(.05);elapsed+=.05;tapped+=.05
   if tapped>=.25:tapped-=.25;game.request_tap_attack()
  assert(Rewards.earned(game) and not game.debug_god_mode);await capture("earned_feedback")
  var timestamp:int=game.achievements.unlocked.hoard_dragon;assert(not game.achievements.add_progress("hoard_dragon") and game.achievements.unlocked.hoard_dragon==timestamp)
  game.show_hideout();hub.show_phase4("archive");await process_frame
  var records=hub.phase4_list.get_child(6);records.get_parent().get_parent().ensure_control_visible(records);await process_frame;await tap(records);assert(hub.phase4_detail.text.contains("Permanently earned"));await capture("ilex_keepsake_record")
  await tap(hub.phase4_action);assert(hub.current_screen=="achievements");assert(not hub.achievement_display_button.disabled)
  await tap(hub.achievement_display_button);assert(home.view=="decor_preview" and home.draft.placements["home.wall_display"]==Rewards.DECOR_ID);await capture("home_reward_preview")
  assert(game.profile.homestead==saved);game.navigate_back();game.navigate_back();assert(game.profile.homestead==saved)
  Rewards.preview(game)
  preload("res://save_scope.gd").transitioning=true;home.apply_decor();preload("res://save_scope.gd").transitioning=false
  assert(home.view=="decor_preview" and game.profile.homestead==saved and home.preview_status.text.contains("unchanged"))
  await capture("apply_refused_safe");await tap(home.preview_actions.get_node("ApplyPreview"));assert(home.view=="room" and Rewards.displayed(game));await capture("home_earned_display")
  var restored:Dictionary=preload("res://profile_store.gd").load_profile(game.PROFILE_SAVE_PATH);assert(restored.homestead.home_layout.placements["home.wall_display"]==Rewards.DECOR_ID)
  var awards=preload("res://achievement_manager.gd").new();assert(awards.is_unlocked("hoard_dragon") and awards.unlocked.hoard_dragon==timestamp)
  game.profile=restored;game.show_personal_home();await capture("home_reload")
  # All six identities use existing approved frames on the actual cushion.
  game.profile.companion.owned_ids=preload("res://companion_catalog.gd").known_ids();game.profile.companion.equipped_id="auricub"
  game.profile.homestead.home_layout.companion_mode="perch";game.profile.homestead.home_layout.companion_perch_slot="home.floor_perch"
  home.follower.initialized=false
  for i in range(90):home._process(.05)
  assert(home.follower.position==Vector2(117,592) and home.follower.facing=="right");await capture("grounded_companion")
  var attacks:int=game.attack_sequence;await tap(home.buttons.chest);assert(hub.current_screen=="stash" and hub.private_return);game.navigate_back();assert(game.state=="personal_home")
  await tap(home.buttons.leave);assert(game.state=="hideout");await capture("hub")
  assert(game.attack_sequence==attacks)
  var preview:Dictionary=preload("res://boss_presentation.gd").profile("act_i");assert(preview.texture_path==preload("res://boss_art_manifest.gd").select_frame("act_i","idle","",-1).asset_path)
  game.play_story_preview("boss/hoard_dragon",game.profile);assert(game.presentation_director.vignette.actor is AtlasTexture);await capture("canonical_dragon_preview");game.presentation_director.vignette.finish()
  game.campaign_id="mossglass_wilds";game.start_run();game.set_process(false);game.wave=15;game.spawn_enemy();game.wave_banner_timer=0;game.enemy_entry_anim=0;await capture("verdant_mirror_open_defect")
  rows.append({"viewport":str(viewport),"actual_final_boss_seconds":elapsed,"saved_achievement":true,"duplicate_unlock":false,"preview_cancel_apply_reload":true,"grounded_canonical_companion":true,"hub_home_archive_stash_input":true,"owner_artistic_acceptance":false})
  game.free();await process_frame
 var f=FileAccess.open("res://.godot_test_data/home067/RESULTS.json",FileAccess.WRITE);f.store_string(JSON.stringify(rows,"  "));f.close()
 print("HOME COLLECTION 067 NATIVE PASS: actual Hoard Dragon combat -> durable achievement -> Ilex Archive -> Home preview/Cancel/Apply/reload; locked/duplicate guards, canonical companion grounding, original preview binding and touch-return routes across four viewports. Artistic acceptance and ActII boss remain open.");quit()
