extends "res://tests/phase4_native_qa.gd"
func wait_real(ms: int) -> void:
 var until:=Time.get_ticks_msec()+ms
 while Time.get_ticks_msec()<until:await process_frame
func review() -> void:
 var dimensions:=OS.get_environment("LOOTLINGS_CAPTURE_SIZE").split("x")
 var viewport_size:=Vector2i(int(dimensions[0]),int(dimensions[1]));root.size=viewport_size
 game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
 game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
 folder="res://.godot_test_data/progression-050/%dx%d/" % [viewport_size.x,viewport_size.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
 game.gold=10000;game.show_hideout();game.hideout_ui.show_shop();await capture("shop_lootcoins");game.hideout_ui.show_upgrades();await wait_real(250);await capture("training_top")
 var before:int=game.gold;await tap(game.hideout_ui.gold_upgrade_buttons.bedroll);assert(is_instance_valid(game.touch_ux.dialog) and game.gold==before);await capture("named_purchase")
 game.touch_ux.close_dialog();await wait_real(250)
 var scroll:ScrollContainer=game.hideout_ui.gold_upgrade_buttons.mending.get_parent().get_parent();scroll.scroll_vertical=scroll.get_v_scroll_bar().max_value;await process_frame;await capture("training_survival")
 assert(scroll.scroll_vertical>100)
 game.retention.progress.data.free_spins=12;game.retention.progress.save();game.hideout_ui.show_home();game.retention.show_earned_spinner()
 for rarity in ["COMMON","EPIC","LEGENDARY","RED"]:
  await wait_real(230)
  var bank:int=game.retention.progress.data.free_spins
  var inventory_size:int=game.inventory.stash.size()
  if rarity=="RED":
   game.retention.progress.data.red_fragments=24;assert(game.retention.progress.save()==OK);game.retention.show_spinner();await wait_real(230);await tap(game.retention.buttons[4])
   assert(game.inventory.stash.size()==inventory_size+1)
  else:
   var rng:=RandomNumberGenerator.new();var found:=false
   for candidate in range(2000):
    rng.seed=candidate
    if preload("res://relic_spin_catalog.gd").roll(rng).rarity==rarity:game.retention.rng.seed=candidate;found=true;break
   assert(found);await tap(game.retention.buttons[0]);assert(game.retention.progress.data.free_spins==bank-1)
  assert(game.retention.spin_busy and game.retention.machine.rarity==rarity)
  var saved_materials:Dictionary=game.expedition_progress.data.materials.duplicate(true)
  var saved_bank:int=game.retention.progress.data.free_spins
  await wait_real(230);await tap(game.retention.buttons[2]);assert(not game.retention.spin_busy and game.retention.detail.text.contains("YOU WON!"))
  assert(game.retention.progress.data.free_spins==saved_bank and game.expedition_progress.data.materials==saved_materials)
  game.retention.machine.lock_result();game.retention.finish_spin()
  assert(game.retention.progress.data.free_spins==saved_bank and game.expedition_progress.data.materials==saved_materials and game.retention.progress.data.pending.is_empty())
  await capture("reward_"+rarity.to_lower());await wait_real(230)
 for event in ["spinner_tick","spinner_catch","spinner_stop","spinner_activate","spinner_fanfare"]:assert(not preload("res://audio_manager.gd").production_event_streams(event).is_empty())
 print("PROGRESSION 050 NATIVE PASS: scrolled six-row training, named confirmation, real all-tier skip touch, truthful reward banner, unchanged earned-spin balance and five authored audio assets")
 game.free();quit()
