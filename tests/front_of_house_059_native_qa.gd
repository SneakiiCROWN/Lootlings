extends "res://tests/phase4b_native_qa.gd"
const Settings=preload("res://settings_store.gd")
func named_button(parent:Node,caption:String) -> Button:
 for child in parent.get_children():
  if child is Button and child.text==caption:return child
  var found:=named_button(child,caption)
  if found!=null:return found
 return null
func review() -> void:
 var routes:Array=[]
 for viewport in [Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/front059/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  var title=game.startup_ui;var attacks:int=game.attack_sequence
  title.profile_exists=false;title.show_title();await create_timer(.3).timeout;await capture("title")
  await tap(named_button(title.title_content,"ENTER THE HIDEOUT"));assert(title.current_screen=="profile_create")
  title.name_edit.text="Rowan";title.nickname_edit.text="Crystal Scout";await tap(named_button(title.profile_content,"SAVE PROFILE"));assert(title.current_screen=="lootling_select")
  await tap(title.selector_confirm);await create_timer(1).timeout
  if game.presentation_director.vignette.active:game.presentation_director.vignette.finish();await process_frame
  assert(game.state=="hideout" and not title.visible);game.set_process(false);await capture("first_profile_hub")
  game.show_personal_home();await tap(game.personal_home.buttons.character);assert(game.personal_profile_return)
  await tap(named_button(title.profile_content,"SETTINGS"));assert(title.current_screen=="settings" and title.settings_return_screen=="profile")
  title.setting_sliders.ui.value=.37;title.cinematic_toggles.cinematic_reduced_motion.button_pressed=true
  await tap(named_button(title.settings_content,"STORY & MOTION"));assert(game.input_surface()==title.cinematic_preferences)
  # A backdrop control cannot activate through an accessibility modal.
  await tap(named_button(title.settings_content,"SUPPORT"));assert(not title.support_panel.visible)
  game.navigate_back();assert(not title.cinematic_preferences.visible and title.current_screen=="settings")
  await tap(named_button(title.settings_content,"SUPPORT"));assert(game.input_surface()==title.support_panel);await capture("support_modal")
  game.navigate_back();assert(not title.support_panel.visible and title.current_screen=="settings")
  await capture("settings");game.navigate_back();assert(title.current_screen=="profile" and game.personal_profile_return)
  var saved:Dictionary=Settings.load_settings(game.SETTINGS_SAVE_PATH);assert(is_equal_approx(saved.ui,.37) and saved.cinematic_reduced_motion)
  title.show_settings();await tap(named_button(title.settings_content,"SAVE & RETURN"));assert(title.current_screen=="profile")
  game.navigate_back();assert(game.state=="personal_home" and not title.visible)
  await capture("home_return");game.show_hideout();game.show_title_from_hideout();await create_timer(.3).timeout
  assert(title.presentation.reduced_motion());title.show_settings();assert(title.settings_content.scale==Vector2.ONE and title.settings_content.modulate.a==1.0)
  game.navigate_back();assert(title.current_screen=="title");assert(game.attack_sequence==attacks)
  routes.append({"viewport":str(viewport),"new_profile_character_hub":true,"home_profile_settings_return":true,"nested_back_modal_input":true,"settings_save_reload":true,"reduced_motion":true,"combat_input_leak":false,"tutorial_claimed":false,"professional_acceptance":false})
  game.free();await process_frame
 var f=FileAccess.open("res://.godot_test_data/front059/JOURNEY_RESULTS.json",FileAccess.WRITE);f.store_string(JSON.stringify(routes,"  "));f.close()
 print("FRONT 059 NATIVE PASS: real touch profile creation/character/Hub, Home card/settings/save-reload/nested Back/modal fencing/reduced motion across three layouts; no invented tutorial or animation closures.");quit()
