extends "res://tests/phase4b_native_qa.gd"
func review() -> void:
 for viewport in [Vector2i(360,640),Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/before071/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false
  game.startup_ui.show_title();await capture("title")
  game.gold=1234567;game.inventory.scrap=9999;game.meta_shards=9876;game.show_hideout();await capture("hub");game.hideout_ui.show_shop();await capture("shop");game.show_personal_home();await capture("home")
  game.free();await process_frame
 print("BASELINE071 prior exported pack capture complete; no fixes claimed.");quit()
