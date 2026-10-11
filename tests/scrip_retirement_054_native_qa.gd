extends "res://tests/phase4_native_qa.gd"
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/scrip-054/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.app_lifecycle.platform_notifications_enabled=false;game.start_run();game.set_process(false);game.gold=321;game.coins=0
  await capture("combat_wallet")
  game.show_merchant();await capture("free_merchant")
  await tap(game.merchant_reroll_button);assert(is_instance_valid(game.touch_ux.dialog));await create_timer(.22).timeout;await tap(game.touch_ux.confirm_button)
  assert(game.shop.rerolls==1 and game.merchant_reroll_button.disabled)
  await tap(game.merchant_buttons[0]);await create_timer(.22).timeout;await capture("selected_supply")
  await tap(game.merchant_buy_button);await capture("free_supply_confirmation");game.touch_ux.close_dialog()
  assert(game.gold==321 and game.coins==0 and not game.shop.purchase_taken)
  game.buy_merchant_item(0);assert(game.state=="item");game.accept_item_keep();game.leave_merchant()
  game.state="event";game.event_id="promise_shrine";game.event_seen.clear();game.show_expedition_event();await capture("event_choices")
  game.end_run(false);await capture("result_rewards")
  game.retention.progress.data.pending.clear();game.retention.progress.data.quarantined_rewards.clear();game.retention.progress.data.free_spins=1;game.retention.progress.data.legacy_spins=0;game.retention.progress.save();game.retention.show_spinner();await capture("earned_spinner")
  assert(game.retention.can_spin() and not game.retention.wallet_text().contains("SCRIP"))
  game.free();await process_frame
 print("SCRIP RETIREMENT 054 NATIVE PASS: combat HUD, free roadside supplies, one redraw, selection/confirmation/cancel, events, results and earned spinner rendered on phone/tablet/desktop. Artistic acceptance separate.")
 quit()
