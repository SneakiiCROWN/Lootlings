extends "res://tests/phase4_native_qa.gd"
const Scope=preload("res://save_scope.gd")
class CurrencyReview:
 extends Control
 func _draw() -> void:
  var ui=preload("res://lootlings_ui.gd")
  draw_rect(Rect2(0,0,448,250),Color("#081326"))
  for row in range(2):
   for index in range(5):
    var extent:int=[16,24,32,48,64][index]
    ui.draw_icon(get_canvas_item(),ui.icon("currency_gold" if row==0 else "currency_star_shard"),Rect2(20+index*84,32+row*105,extent,extent))
func review() -> void:
 OS.set_environment("LOOTLINGS_OWNER_TEST","1")
 for viewport in [Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/economy-057/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  Scope.active=false;game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.audio_settings.cinematic_first_time=false;game.app_lifecycle.platform_notifications_enabled=false;game.gold=12345;game.meta_shards=456;game.inventory.scrap=80;game.refresh_hideout();game.show_hideout();game.presentation_director.finish_travel();game.presentation_director.vignette.finish()
  game.startup_ui.visible=true;game.hideout_ui.hide();game.startup_ui.show_title();await capture("title_preserved");game.startup_ui.hide();game.hideout_ui.show();await capture("hub_currency");game.show_personal_home();await capture("home_currency");game.show_hideout()
  game.hideout_ui.show_shop();await capture("shop_currency");game.hideout_ui.show_stash();await capture("stash_currency");game.hideout_ui.show_forge();await capture("forge_currency");game.hideout_ui.show_upgrades();await capture("shrine_currency")
  game.hideout_ui.show_home();game.retention.show_earned_spinner();assert(game.retention.panel.visible and game.state=="relic_spinner");game.retention.machine.wind_up("mastery","UNCOMMON",false);game.retention.machine.set_process(false);game.retention.machine.stage="reveal";game.retention.machine.burst=.8;game.retention.machine.queue_redraw();await capture("spinner_mastery_not_diamonds");game.retention.panel.hide();game.retention.dimmer.hide()
  game.start_run();game.set_process(false);game.wave_banner_timer=0;game.presentation_director.toast_queue.clear();game.presentation_director.active_toast.clear();game.presentation_director.toast_panel.hide();await capture("combat_currency");game.show_merchant();await capture("pack_peddler_currency");await tap(game.merchant_buttons[0]);await capture("pack_peddler_comparison");game.merchant_panel.hide();game.state="playing";game.prepare_hoard_chest();await capture("chest_currency");game.state="playing";game.end_run(false);await capture("result_currency")
  Scope.active=true;game.debug_panel.open();game.debug_panel.filter_sections(2);await capture("owner_wallet_controls");var wallet_scroll:ScrollContainer=game.debug_panel.amount.get_parent().get_parent().get_parent();wallet_scroll.scroll_vertical=wallet_scroll.get_v_scroll_bar().max_value;await capture("owner_wallet_controls_scrolled");game.debug_panel.close();Scope.active=false
  var grid:=CurrencyReview.new();grid.position=Vector2(16,280);grid.size=Vector2(448,250);grid.z_index=1200;grid.mouse_filter=Control.MOUSE_FILTER_IGNORE;game.add_child(grid);grid.queue_redraw();await capture("currency_16_24_32_48_64");grid.free()
  game.free();await process_frame
 print("ECONOMY ART 057 NATIVE PASS: canonical shared currency artwork, title and twelve gameplay routes, owner controls and 16/24/32/48/64px review on phone/tablet/desktop. Artistic acceptance separate.");quit()
