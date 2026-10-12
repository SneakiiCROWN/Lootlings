extends "res://tests/phase4b_native_qa.gd"
func button(parent:Node,caption:String) -> Button:
 for child in parent.get_children():
  if child is Button and child.text==caption:return child
  var found:=button(child,caption)
  if found!=null:return found
 return null
func review() -> void:
 var rows:Array=[]
 for viewport in [Vector2i(480,854),Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/premium066/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
  game.audio_settings.cinematic_first_time=false;game.audio_settings.cinematic_reduced_motion=false
  var title=game.startup_ui;title.settings.cinematic_reduced_motion=false;title.profile_exists=true;title.show_title()
  var attacks:int=game.attack_sequence
  await capture("title_initial")
  var ambience=title.title_ambience
  assert(ambience.motes.size()==12 and ambience.mouse_filter==Control.MOUSE_FILTER_IGNORE and ambience.focus_mode==Control.FOCUS_NONE)
  assert(button(title.title_content,"START").is_visible_in_tree() and button(title.title_content,"PROFILE").is_visible_in_tree() and button(title.title_content,"SETTINGS").is_visible_in_tree())
  var rng:int=game.rng.state;var loot_rng:int=game.loot_system.rng.state
  seed(66065);var expected:=randf();seed(66065)
  for i in range(3000):ambience._process(.1)
  assert(randf()==expected and game.rng.state==rng and game.loot_system.rng.state==loot_rng)
  await create_timer(2).timeout;await capture("title_elapsed_300s")
  title.settings.cinematic_reduced_motion=true;var clock:float=ambience.clock;ambience._process(10);assert(ambience.clock==clock);ambience.queue_redraw();await capture("title_reduced_motion")
  title.settings.cinematic_reduced_motion=false
  game.app_lifecycle.suspend();clock=ambience.clock;await create_timer(.15,true).timeout;assert(ambience.clock==clock);game.app_lifecycle.restore_focus()
  await tap(button(title.title_content,"PROFILE"));assert(title.current_screen=="profile");game.navigate_back();assert(title.current_screen=="title")
  await tap(button(title.title_content,"SETTINGS"));assert(title.current_screen=="settings");game.navigate_back();assert(title.current_screen=="title")
  await tap(button(title.title_content,"START"));await create_timer(.8).timeout
  if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
  assert(game.state=="hideout");game.hideout_ui.show_home();await capture("hub")
  var hub=game.hideout_ui;var nav=hub.hub_navigation
  for badge in nav.talk_buttons.values():assert(not badge.visible)
  await tap(nav.world_buttons.ShopEntrance);assert(hub.current_screen=="shop")
  await capture("patch_shop")
  await tap(hub.shop_offer_buttons[0]);await capture("patch_comparison")
  assert(hub.shop_offer_buttons[2].get_global_rect().end.y<hub.shop_detail_panel.get_global_rect().position.y)
  var compare=hub.shop_detail.get_meta("quick_comparison")
  assert(compare.get_global_rect().end.y<=hub.shop_buy_button.get_global_rect().position.y)
  hub.show_shop_message("PURCHASED\nYour equipment is safe in the Stash.")
  assert(hub.shop_status_panel.visible and not hub.shop_detail_panel.visible and hub.shop_status.size.y>=200)
  await capture("shop_feedback");await tap(hub.shop_status_dismiss);assert(not hub.shop_status_panel.visible and hub.shop_detail_panel.visible)
  game.hideout_shop.blocked_cache={"retained":"invalid test fixture"};hub.refresh_shop()
  assert(hub.shop_status_panel.visible and hub.shop_status.text.contains("record is retained"));game.hideout_shop.blocked_cache=null;hub.shop_message_active=false;hub.refresh_shop()
  game.gold=1000;game.inventory.scrap=60;game.hideout_shop.gold_cache_bought_this_cycle=false;game.inventory.stash.clear();game.refresh_hideout();hub.show_shop();await create_timer(.3).timeout
  assert(not hub.shop_gold_cache_button.disabled)
  await tap(hub.shop_gold_cache_button);assert(is_instance_valid(game.touch_ux.dialog));await create_timer(.3).timeout;await tap(game.touch_ux.confirm_button)
  assert(not game.hideout_shop.pending_cache_item.is_empty() and hub.shop_status_panel.visible and not hub.shop_detail_panel.visible)
  await capture("cache_reveal");await create_timer(1).timeout;await capture("cache_reserved");assert(hub.shop_reveal_icon.visible);var held:int=game.inventory.stash.size()
  await tap(hub.shop_gold_cache_button);assert(is_instance_valid(game.touch_ux.dialog));await create_timer(.3).timeout;await tap(game.touch_ux.confirm_button)
  assert(game.hideout_shop.pending_cache_item.is_empty() and game.inventory.stash.size()==held+1);await capture("cache_claimed")
  await tap(button(hub.shop_content,"Talk"))
  if game.presentation_director.vignette.active:game.presentation_director.vignette.finish();await process_frame
  assert(hub.speech_panel.visible and hub.speech_speaker=="Salvager");await capture("patch_dialogue");game.navigate_back();game.navigate_back()
  if hub.current_screen!="home":hub.show_home()
  await tap(nav.world_buttons.ShrineProp);assert(hub.current_screen=="upgrades");await capture("sera_upgrades")
  await tap(button(hub.upgrade_content,"Talk"))
  if game.presentation_director.vignette.active:game.presentation_director.vignette.finish();await process_frame
  assert(hub.speech_panel.visible and hub.speech_speaker=="Relic Keeper");game.navigate_back();game.navigate_back();hub.show_home()
  await tap(nav.world_buttons.ArchiveDesk);assert(hub.current_screen=="workshop" and hub.phase4_mode=="archive");game.navigate_back();hub.show_home()
  await tap(nav.buttons.home);assert(game.state=="personal_home");await capture("home_preserved");game.show_hideout()
  assert(game.attack_sequence==attacks)
  rows.append({"viewport":str(viewport),"decorative_input_rng_lifecycle":true,"idle":"300 simulated seconds plus two real seconds","title_profile_settings_start":true,"npc_direct_services_dialogue_comparison":true,"home_preserved":true,"combat_input_leak":false,"professional_owner_acceptance":false})
  game.free();await process_frame
 var f=FileAccess.open("res://.godot_test_data/premium066/RESULTS.json",FileAccess.WRITE);f.store_string(JSON.stringify(rows,"  "));f.close()
 print("PREMIUM WORLD 066 NATIVE PASS: four layouts, title actions, bounded private-RNG ambience, simulated extended idle/reduced motion/background pause, direct Patch/Sera/Ilex services, dialogue, comparison and Home return. Owner artistic acceptance remains open.");quit()
