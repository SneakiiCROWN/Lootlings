extends "res://tests/phase4b_native_qa.gd"
func review() -> void:
 var rows:Array=[]
 for viewport in [Vector2i(360,640),Vector2i(480,854),Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/utility069/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  game.startup_ui.show_settings();game.startup_ui.support_panel.show();await capture("support")
  var attacks:int=game.attack_sequence;var wallet:int=game.gold;var guide=game.contextual_guide;var backups=game.backup_menu
  guide.read_ids.clear();guide.open("currencies");await capture("field_guide");guide.picker.show_popup();await capture("guide_dropdown");assert(guide.picker.get_popup().size.y<=480);guide.picker.get_popup().hide()
  guide.close();assert(game.startup_ui.support_panel.visible and not guide.panel.visible and game.attack_sequence==attacks)
  backups.open();await capture("backups_initial")
  if backups.bundle.is_empty():assert(backups.restore_button.disabled and backups.picker.is_item_disabled(0))
  assert(backups.create_backup()==OK);assert(backups.picker.item_count>0);backups.select_backup(0);await capture("backup_selected")
  backups.request_restore();assert(is_instance_valid(game.touch_ux.dialog) and game.touch_ux.dialog.z_index>backups.z_index);await capture("restore_confirmation")
  var confirmation=game.touch_ux.dialog.get_child(1);await tap(confirmation.get_child(confirmation.get_child_count()-2));assert(not is_instance_valid(game.touch_ux.dialog) and game.gold==wallet);backups.close()
  game.startup_ui.visible=false;game.show_hideout();game.inventory.stash.clear();game.inventory.stash.append(game.ItemCatalog.create_item("dawnweave","MYTHICAL SHINY",69001));game.hideout_ui.show_stash();await process_frame
  var stored=game.hideout_ui.stash_list.get_child(game.hideout_ui.entries.size()-1);stored.get_parent().get_parent().ensure_control_visible(stored);await process_frame
  await tap(stored);await capture("equipment_comparison");assert(game.hideout_ui.stash_detail.has_meta("quick_comparison"))
  assert(game.hideout_ui.stash_detail.size.y>=90);await swipe(game.hideout_ui.stash_detail);game.touch_ux.inertia=null;await process_frame;await capture("comparison_effects_scroll")
  for button in [game.hideout_ui.stash_equip_button,game.hideout_ui.stash_scrap_button,backups.restore_button]:
   var physical:Vector2=root.get_screen_transform().basis_xform(button.size);assert(physical.y>=44)
  assert(game.gold==wallet and game.attack_sequence==attacks)
  rows.append({"viewport":str(viewport),"guide_return":true,"backup_create_preview_cancel":true,"comparison":true,"wallet_unchanged":true,"touch_no_attack":true,"physical_device":false,"owner_artistic_acceptance":false})
  game.free();await process_frame
 var output=FileAccess.open("res://.godot_test_data/utility069/RESULTS.json",FileAccess.WRITE);output.store_string(JSON.stringify(rows,"  "));output.close()
 print("UTILITY 069 NATIVE PASS: Support, guide/dropdown, backup create/preview/confirmation cancel and named Mythical comparison; four layouts, no wallet/attack mutation. Physical/artistic acceptance pending.");quit()
