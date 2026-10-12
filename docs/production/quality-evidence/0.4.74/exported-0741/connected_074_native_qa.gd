extends "C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-fixtures-0741/phase4b_native_qa.gd"
func review() -> void:
 for viewport in [Vector2i(360,640),Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-0741/connected074/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  game.show_hideout();var h=game.hideout_ui;h.last_home_facts.region="act_i";h.queue_dialogue_context("boss_defeated")
  h.request_dialogue("tapped","Salvager");assert(not h.resident_context_heard.has("Salvager") and h.queued_dialogue_context=="boss_defeated");await capture("patch_does_not_consume_boss_story");h.dismiss_dialogue()
  h.request_dialogue("tapped","Archivist");assert(h.home_dialogue.last_selection.get("event","")=="boss_defeated" and h.resident_context_heard.Archivist=="boss_defeated");await capture("ilex_boss_acknowledgement");h.dismiss_dialogue()
  h.request_dialogue("tapped","Archivist");assert(h.home_dialogue.last_selection.get("event","")!="boss_defeated");h.dismiss_dialogue()
  h.queue_dialogue_context("boss_defeated");h.request_dialogue("tapped","Archivist");assert(h.home_dialogue.last_selection.get("event","")=="boss_defeated");h.dismiss_dialogue()
  game.inventory.stash=[game.ItemCatalog.create_item("dawnweave","MYTHICAL SHINY",7401)];game.refresh_hideout();h.show_stash()
  for index in range(h.entries.size()):
   if not h.entries[index].equipped:h.select_entry(index);break
  await capture("stash_shared_comparison")
  var view=h.stash_detail.get_meta("quick_comparison");assert(not h.stash_detail.text.contains("EFFECTIVE IF EQUIPPED") and view.rows.size()==5)
  for row in view.rows:assert(is_equal_approx(row.value_delta,row.value_after-row.value_before))
  game.gold=100000;game.refresh_hideout();h.show_shop();await tap(h.shop_offer_buttons[0]);await capture("shop_shared_comparison")
  var wallet:int=game.gold;await tap(h.shop_buy_button);assert(is_instance_valid(game.touch_ux.dialog));game.touch_ux.close_dialog();assert(game.gold==wallet)
  game.show_personal_home();var home=game.personal_home;var saved:Dictionary=game.profile.homestead.duplicate(true)
  game.achievements.unlocked["hoard_dragon"]=true;game.profile.homestead.home_layout.placements["home.wall_display"]=preload("res://home_rewards.gd").DECOR_ID;home.open("room")
  await tap(home.buttons.shelf);assert(h.current_screen=="achievements" and h.selected_achievement_id=="hoard_dragon");await capture("actual_keepsake_record");game.navigate_back();assert(game.state=="personal_home")
  await tap(home.buttons.display);assert(home.view=="decor");home.open("decor_preview");home.go_back();home.go_back();assert(home.view=="room")
  game.profile.homestead=saved;game.free();await process_frame
 print("CONNECTED074 NATIVE PASS shared truthful comparisons, confirmed Shop cancellation, unconsumed/matching/repeated-adventure authored dialogue, actual Home keepsake record/return and decor cancellation;4 layouts, no new canon or pose closures.");quit()
