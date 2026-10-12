extends "res://tests/phase4b_native_qa.gd"
const Profiles=preload("res://profile_store.gd")
const Scope=preload("res://save_scope.gd")
func review() -> void:
 for viewport in [Vector2i(360,640),Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/journey076/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
  game.profile=Profiles.create_default();game.show_hideout();var h=game.hideout_ui
  h.last_home_facts={"region":"act_i","outcome":"victory"};h.queue_dialogue_context("boss_defeated")
  assert(Profiles.load_profile(game.PROFILE_SAVE_PATH).home_conversation.event=="boss_defeated")
  game.free();await process_frame
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.show_hideout();h=game.hideout_ui
  await capture("hub");await tap(h.hub_navigation.world_buttons.ShopEntrance);assert(h.current_screen=="shop")
  h.request_dialogue("tapped","Salvager");assert(h.queued_dialogue_context=="boss_defeated");h.dismiss_dialogue()
  h.request_dialogue("tapped","Archivist");assert(h.home_dialogue.last_selection.event=="boss_defeated");await capture("earned_return_dialogue")
  assert(Profiles.load_profile(game.PROFILE_SAVE_PATH).home_conversation.heard.Archivist=="boss_defeated")
  h.dismiss_dialogue();game.free();await process_frame
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.show_hideout();h=game.hideout_ui
  h.request_dialogue("tapped","Archivist");assert(h.home_dialogue.last_selection.get("event","")!="boss_defeated");h.dismiss_dialogue()
  var hash:String=FileAccess.get_sha256(Scope.path(game.PROFILE_SAVE_PATH));Scope.transitioning=true;h.queue_dialogue_context("boss_defeated");assert(FileAccess.get_sha256(Scope.path(game.PROFILE_SAVE_PATH))==hash);Scope.transitioning=false;assert(game.app_lifecycle.persist()==OK)
  game.inventory.stash=[game.ItemCatalog.create_item("dawnweave","MYTHICAL SHINY",76001)];game.refresh_hideout();h.show_stash()
  for i in range(h.entries.size()):
   if not h.entries[i].equipped:h.select_entry(i);break
  var q=h.stash_detail.get_meta("quick_comparison");await capture("stash_stats");await tap(q.effects_button);assert(h.stash_detail.is_visible_in_tree() and h.stash_detail.size.y>=290);await capture("stash_full_details");await swipe(h.stash_detail);game.touch_ux.inertia=null;await tap(q.effects_button);assert(not q.showing_effects)
  game.show_personal_home();await capture("home");await tap(game.personal_home.buttons.display);var before:Dictionary=game.profile.homestead.duplicate(true);game.personal_home.open("decor_preview");game.personal_home.go_back();game.personal_home.go_back();assert(game.profile.homestead==before)
  game.show_hideout();h.show_achievements();await capture("archive_heading");game.free();await process_frame
 print("LIVING JOURNEY076 NATIVE PASS:4 layouts, persistent earned conversation and acknowledgement across scene reloads, unrelated speaker protection, refused-write retry, Shop/Home/decor navigation and full-height detail toggles. Physical/device and artistic acceptance pending.");quit()
