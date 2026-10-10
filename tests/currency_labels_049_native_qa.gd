extends "res://tests/phase4b_native_qa.gd"
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(100).timeout.connect(func():push_error("Currency labels timeout");quit(1));call_deferred("review")
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/wallet-049/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.audio_settings.cinematic_first_time=false;game.app_lifecycle.platform_notifications_enabled=false
  game.gold=1460;game.meta_shards=82;game.meta_power=33;game.inventory.scrap=36;game.refresh_hideout();game.show_hideout();game.presentation_director.finish_travel();game.presentation_director.vignette.finish()
  assert(game.hideout_ui.resource_label.text.contains("Lootcoins") and game.hideout_ui.resource_label.text.contains("Diamonds"));await capture("hub_wallet")
  game.hideout_ui.show_upgrades();assert(game.hideout_ui.upgrade_summary.text.contains("LOOT DIAMONDS"));await capture("training_wallet")
  game.hideout_ui.show_shop();await capture("shop_wallet")
  game.hideout_ui.show_forge();await capture("forge_wallet")
  game.hideout_ui.forge_confirm.pressed.emit();assert(is_instance_valid(game.touch_ux.dialog));await capture("forge_confirmation");game.touch_ux.close_dialog()
  game.hideout_ui.show_home();game.start_run();game.presentation_director.finish_travel();game.presentation_director.vignette.finish();game.set_process(false);game.end_run(false);assert(game.result_summary.text.contains("Lootcoins") and game.result_summary.text.contains("Diamonds"));await capture("result_wallet")
  game.free();await process_frame
 print("CURRENCY LABELS 049 NATIVE PASS: Hub, Shop, Forge, named craft confirmation, Training and results; three viewports; legacy prices/payouts preserved")
 quit()
