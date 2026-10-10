extends "res://tests/phase4b_native_qa.gd"
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(140).timeout.connect(func():push_error("Service quality timeout");quit(1));call_deferred("review")
func clean_text(node:Node) -> void:
 if node is Label or node is Button or node is RichTextLabel:
  assert(not node.text.contains("Ã") and not node.text.contains("ƒ"),"Corrupt visible text: "+node.text)
 for child in node.get_children():clean_text(child)
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/service-quality-045/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
  game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false;game.set_process(false)
  game.startup_ui.profile.lootling_nickname="Treasure Scout";game.startup_ui.show_title();await capture("title_named")
  assert(not game.startup_ui.title_wordmark.get_rect().intersects(game.startup_ui.title_tagline.get_rect()))
  game.startup_ui.show_profile(false);await capture("profile_names");clean_text(game.startup_ui)
  game.show_hideout();await create_timer(1.2).timeout;await capture("hub_preserved")
  var h=game.hideout_ui
  game.contracts=preload("res://contract_system.gd").new();h.contracts=game.contracts
  h.show_shop();await capture("shop")
  h.show_forge();await capture("forge");assert(h.forge_list.get_parent().horizontal_scroll_mode==ScrollContainer.SCROLL_MODE_DISABLED)
  await tap(h.forge_list.get_child(1));assert(h.forge_recipe=="greataxe" and not h.forge_list.get_child(0).get_meta("ui_selected"));await capture("forge_recipe")
  h.forge_list.get_parent().scroll_vertical=10000;await process_frame;await capture("forge_last_rows")
  h.show_stash();await capture("stash")
  h.show_contracts();await capture("contracts_progress")
  assert(h.contract_buttons[0].get_node("Requirement").text.contains("Defeat enemies"));assert(h.contract_buttons[0].disabled)
  game.contracts.counts.kill=12;h.refresh_contracts();assert(not h.contract_buttons[0].disabled);await capture("contract_ready")
  var gold:int=game.gold;await tap(h.contract_buttons[0]);assert(game.gold==gold+10);assert(h.contract_buttons[0].disabled);await capture("contract_claimed")
  h.show_campaign();await capture("expeditions")
  h.show_home();game.retention.show_modes("dungeons");await capture("dungeons");assert(game.retention.detail.text.contains("Crownroot fragments") and game.retention.detail.text.contains("Gravebloom"))
  if game.retention.buttons[1].disabled:
   assert(game.retention.detail.text.contains("unlock both routes"))
   var button:Button=game.retention.buttons[1]
   assert(button.get_theme_font("font").get_string_size(button.text,HORIZONTAL_ALIGNMENT_LEFT,-1,button.get_theme_font_size("font_size")).x<button.size.x-36,"Dungeon label crosses frame")
  game.retention.show_modes("siege");await capture("siege")
  game.show_hideout();h.show_home();game.retention.progress.data.free_spins=1;game.retention.show_earned_spinner();await capture("engine_ready")
  assert(game.retention.chase.text.contains("paid and earned"));var fragments:int=game.retention.progress.data.red_fragments
  await tap(game.retention.buttons[0]);await create_timer(5.0).timeout;assert(not game.retention.spin_busy);await capture("engine_reward")
  assert(game.retention.progress.data.red_fragments>=fragments);await tap(game.retention.buttons[1]);assert(game.state=="hideout")
  clean_text(h);clean_text(game.retention.panel)
  assert(FileAccess.get_sha256("res://art/audio/production/music/title.ogg")=="7d53beed1a8ba204fb9fc7809a659ca73c755f328c7c8e456b9a037db65ec9a7")
  game.free();await process_frame
 print("SERVICE QUALITY 045 NATIVE PASS: title/profile encoding and logo separation, Forge selection/scroll, Contracts progress and exact claim, Shop/Stash/Expeditions, Dungeons/Siege naming, earned Engine spin/return; three native viewports; artistic approval remains open")
 quit()
