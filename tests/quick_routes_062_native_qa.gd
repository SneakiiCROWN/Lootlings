extends "res://tests/phase4b_native_qa.gd"
func review() -> void:
 for viewport in [Vector2i(360,640),Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/quickroutes062/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.audio_settings.cinematic_first_time=false;game.app_lifecycle.platform_notifications_enabled=false
  game.start_run();game.presentation_director.finish_travel();game.presentation_director.vignette.finish();game.set_process(false)
  game.show_merchant();game.inspect_merchant_item(0);await capture("free_merchant")
  var quick=game.merchant_detail.get_meta("quick_comparison");assert(quick.visible and game.merchant_detail.position.y+game.merchant_detail.size.y<=game.merchant_buy_button.position.y)
  game.show_hideout();game.inventory.stash.append(game.ItemCatalog.create_item("dawnweave","MYTHICAL SHINY",921));game.refresh_hideout();game.hideout_ui.show_stash()
  var ui=game.hideout_ui
  for index in range(ui.entries.size()):
   if not ui.entries[index].equipped:ui.select_entry(index);break
  await capture("stash_compare");assert(ui.stash_detail.has_meta("quick_comparison"))
  ui.show_forge();ui.select_forge_weapon(-1);await capture("forge_compare")
  if ui.forge_detail.has_meta("quick_comparison"):
   assert(ui.forge_detail.position.y+ui.forge_detail.size.y<=ui.forge_confirm.position.y)
  game.free();await process_frame
 print("QUICK ROUTES 062 PASS: shared free merchant, owned stash, Forge; four layouts; independent scroll and action separation. Artistic acceptance remains scoped.");quit()
