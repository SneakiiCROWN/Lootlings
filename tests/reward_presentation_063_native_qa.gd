extends "res://tests/phase4b_native_qa.gd"
func review() -> void:
 for viewport in [Vector2i(360,640),Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/rewards063/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.audio_settings.cinematic_first_time=false;game.app_lifecycle.platform_notifications_enabled=false
  game.start_run();game.presentation_director.finish_travel();game.presentation_director.vignette.finish();game.set_process(false)
  game.boss_reward_options=[game.ItemCatalog.create_item("dawnweave","MYTHICAL SHINY",901),game.ItemCatalog.create_item("mirrorwake","MYTHICAL SHINY",902),game.ItemCatalog.create_item("stormspark","RED",903)]
  game.show_boss_reward();await capture("named_hoard")
  for i in range(3):assert(game.boss_reward_visuals[i].name.text==game.boss_reward_options[i].name and game.boss_reward_buttons[i].size.x<=391)
  var before:String=JSON.stringify(game.inventory.equipped);var rng:int=game.rng.state;var attacks:int=game.attack_sequence
  await tap(game.boss_reward_buttons[0]);assert(is_instance_valid(game.touch_ux.dialog));await capture("hoard_dual_preview")
  var found=false
  for node in game.touch_ux.dialog.find_children("*","RichTextLabel",true,false):
   if node.has_meta("hoard_preview"):
    found=true;var quick=node.get_meta("quick_comparison");var position:Vector2=quick.position
    node.get_v_scroll_bar().value=node.get_v_scroll_bar().max_value;await process_frame;assert(quick.position==position)
  assert(found and JSON.stringify(game.inventory.equipped)==before and game.rng.state==rng and game.attack_sequence==attacks)
  game.touch_ux.close_dialog();await process_frame;assert(game.state=="boss_reward" and game.boss_reward_options.size()==3)
  game.inspect_boss_reward(0);await create_timer(.21).timeout;await tap(game.touch_ux.confirm_button);assert(game.state=="item" and game.current_item.id=="dawnweave" and game.boss_reward_options.is_empty())
  assert(JSON.stringify(game.inventory.equipped)==before and game.attack_sequence==attacks)
  game.item_panel.hide();game.boss_reward_panel.hide();game.state="result";game.retention.show_spinner();await capture("spinner_clear_chase")
  assert(game.retention.chase.position.y+game.retention.chase.size.y<=game.retention.chase_bar.position.y)
  assert(game.retention.chase_bar.position.y+game.retention.chase_bar.size.y<=game.retention.machine.position.y)
  game.retention.close_spinner();game.presentation_director.vignette.finish()
  var entry=preload("res://vignette_catalog.gd").entry("boss/hoard_dragon")
  assert(entry.actor.contains("approved/hoard_dragon/") and entry.has("actor_region"))
  assert(game.presentation_director.vignette.play(entry,game.audio_settings,"preview"));await capture("canonical_dragon_memory");game.presentation_director.vignette.finish()
  game.free();await process_frame
 print("REWARD PRESENTATION 063 PASS: named three-item hoard, persistent read-only dual preview, cancel preserves rewards, separated Spark/fragments labels across four layouts.");quit()
