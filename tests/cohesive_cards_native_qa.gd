extends "res://tests/phase4b_native_qa.gd"
# extends SceneTree through isolated native touch/capture helpers.
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(100).timeout.connect(func():push_error("Card family timeout");quit(1))
 call_deferred("review")
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/cohesive-cards/%dx%d/" % [viewport.x,viewport.y]
  DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
  game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  game.start_run();game.set_process(false);game.presentation_director.finish_travel()
  if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
  game.coins=1000;game.show_merchant();await create_timer(.3).timeout
  var held:int=game.coins;var attacks:int=game.attack_sequence
  for i in range(3):
   assert(game.merchant_icons[i].get_parent()==game.merchant_buttons[i])
   assert(Rect2(Vector2.ZERO,game.merchant_buttons[i].size).encloses(Rect2(game.merchant_icons[i].position,game.merchant_icons[i].size)))
  await tap(game.merchant_buttons[0]);await tap(game.merchant_buttons[1])
  assert(game.merchant_selection==1 and game.coins==held and game.attack_sequence==attacks)
  assert(not game.merchant_buttons[0].get_node("SelectionMark").visible and game.merchant_buttons[1].get_node("SelectionMark").visible)
  assert(game.merchant_buttons[0].get_theme_stylebox("normal").texture.resource_path.ends_with("button_secondary.png"))
  assert(game.merchant_buttons[1].get_theme_stylebox("normal").texture.resource_path.ends_with("button_primary.png"))
  game.merchant_buttons[0].grab_focus();await process_frame
  assert(not game.merchant_buttons[0].get_node("SelectionMark").visible and game.merchant_buttons[1].get_node("SelectionMark").visible)
  await capture("merchant_selected")
  game.merchant_panel.hide();game.state="playing";game.pending_levels=1;game.show_upgrade_choices();await create_timer(.3).timeout
  await tap(game.upgrade_buttons[0]);await tap(game.upgrade_buttons[1])
  assert(game.upgrade_selection==1 and game.attack_sequence==attacks)
  assert(not game.upgrade_buttons[0].get_node("SelectionMark").visible and game.upgrade_buttons[1].get_node("SelectionMark").visible)
  await capture("perk_selected")
  game.free();await process_frame
 print("COHESIVE CARD NATIVE PASS: approved cool/warm frame family, persistent one-selection tick, old tick clears, keyboard focus distinct, merchant/perk modal input isolation, unchanged funds/attacks; three viewports")
 quit()
