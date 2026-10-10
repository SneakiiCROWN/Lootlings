extends "res://tests/phase4b_native_qa.gd"
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(100).timeout.connect(func():push_error("Inventory 046 timeout");quit(1));call_deferred("review")
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/inventory-guidance-046/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false;game.set_process(false)
  game.show_hideout();var h=game.hideout_ui
  h.show_stash();var items:String=JSON.stringify(game.inventory.stash);var gold:int=game.gold;var attacks:int=game.attack_sequence
  h.stash_filter="ARMOUR";h.refresh_stash();assert(h.entries.is_empty())
  var guide:VBoxContainer=h.stash_list.get_node("EmptyStashGuide");assert(guide.get_child(0).text.contains("GEAR YET"))
  var button:Button=guide.get_child(2);assert(button.size.y>=48);await capture("empty_armour")
  await tap(button);assert(h.stash_filter=="ALL" and not h.entries.is_empty());assert(JSON.stringify(game.inventory.stash)==items and game.gold==gold and game.attack_sequence==attacks);await capture("all_gear")
  await tap(h.stash_list.get_child(0));assert(h.stash_detail_panel.visible);await capture("selected_detail")
  h.close_stash_detail();assert(not h.stash_detail_panel.visible)
  game.show_hideout();await capture("hub_preserved");h.show_home();await capture("home_preserved")
  assert(FileAccess.get_sha256("res://art/audio/production/music/title.ogg")=="7d53beed1a8ba204fb9fc7809a659ca73c755f328c7c8e456b9a037db65ec9a7")
  game.free();await process_frame
 print("INVENTORY GUIDANCE 046 NATIVE PASS: empty category, touch return to all gear, selection/detail, unchanged items/gold/attack input, Home/Hub, three layouts; title track preserved")
 quit()
