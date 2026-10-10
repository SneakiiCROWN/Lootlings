extends "res://tests/phase4b_native_qa.gd"
func review() -> void:
 for size in [Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=size;folder="res://.godot_test_data/perks-053/%dx%d/" % [size.x,size.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.app_lifecycle.platform_notifications_enabled=false;game.start_run();game.set_process(false)
  game.rng.seed=53053;game.coins=987;game.gold=321;game.pending_levels=1;game.crit_chance=.72;game.life_steal=.08;game.execute_ratio=.35
  game.show_upgrade_choices();await capture("free_perk_choices")
  for up in game.selected_upgrades:assert(not up.id in ["crit","vamp","execute","greed"])
  await tap(game.upgrade_buttons[0]);await create_timer(.22).timeout;await tap(game.upgrade_take_button)
  assert(game.state=="playing" and game.coins==987 and game.gold==321)
  game.free();await process_frame
 print("PERK OFFER 053 NATIVE PASS: real free selection, no currency charge, capped offers excluded; three layouts. Expert-versus-random combat balance not yet accepted.")
 quit()
