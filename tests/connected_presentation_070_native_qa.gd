extends "res://tests/phase4b_native_qa.gd"
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 OS.set_environment("LOOTLINGS_MOBILE_TEST","1");create_timer(240).timeout.connect(func():push_error("Connected070 timeout");quit(1));call_deferred("review")
func review() -> void:
 var records:Array=[]
 for viewport in [Vector2i(360,640),Vector2i(480,854),Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/connected070/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false;game.show_hideout()
  var h=game.hideout_ui;game.contracts=preload("res://contract_system.gd").new();h.contracts=game.contracts;game.campaign.completed.clear();var attacks:int=game.attack_sequence;var wallet:int=game.gold
  await capture("hub");await tap(h.hub_navigation.world_buttons.ContractBoard);assert(h.current_screen=="contracts");await capture("contracts_active")
  for i in range(12):game.contracts.record("kill")
  h.refresh_contracts();await capture("contract_claimable");await tap(h.contract_buttons[0]);await tap(h.contract_buttons[0]);assert(game.gold==wallet+10);await capture("contract_claimed")
  game.contracts.save("user://contracts.cfg");var reloaded=preload("res://contract_system.gd").new();reloaded.load_progress("user://contracts.cfg");assert(reloaded.offer(0).name==game.contracts.offer(0).name)
  assert(h.contract_buttons[0].get_node("Progress").size.y<=8);await tap(h.contracts_back);assert(h.current_screen=="home")
  game.show_hideout();h.show_phase4("archive");await capture("archive_entry");await tap(h.phase4_list.get_child(3));await capture("archive_discoveries")
  h.show_lore();await capture("field_notes");assert(h.lore_detail.get_parent().position.y+h.lore_detail.get_parent().size.y<694);await swipe(h.lore_detail);game.touch_ux.inertia=null;h.cycle_lore(1);await capture("next_note");h.show_memories();await capture("memories")
  for memory in h.memory_list.get_children():
   if memory is Button and not memory.disabled:
    await tap(memory);assert(game.presentation_director.vignette.active);await capture("memory_replay");game.navigate_back();assert(not game.presentation_director.vignette.active);break
  game.navigate_back();assert(h.current_screen=="lore");game.navigate_back();assert(h.current_screen=="workshop" and h.phase4_mode=="archive")
  game.show_hideout();h.show_campaign();await tap(h.campaign_list.get_child(1));assert(h.region_sheet.visible and h.region_depart.disabled);await capture("locked_region");game.navigate_back()
  game.retention.show_modes("dungeons");await capture("locked_dungeons");assert(root.get_screen_transform().basis_xform(game.retention.buttons[4].size).y>=44);game.navigate_back();game.campaign.finish("act_i");game.retention.show_modes("dungeons");await capture("available_dungeons");game.navigate_back();game.retention.show_modes("siege");await capture("siege");game.navigate_back()
  game.show_hideout();h.request_dialogue("tapped","Archivist");await capture("ilex_dialogue");assert(not game.contextual_guide.chip.visible and h.speech_panel.position.y+h.speech_panel.size.y<782);game.navigate_back();assert(not h.speech_panel.visible)
  assert(game.attack_sequence==attacks and game.gold==wallet+10)
  records.append({"viewport":str(viewport),"single_contract_reward":10,"contract_rotation_reload":true,"archive_notes_memory_modes_dialogue":true,"touch_no_attack":true,"physical_S23":false,"owner_artistic_acceptance":false});game.free();await process_frame
 var file=FileAccess.open("res://.godot_test_data/connected070/RESULTS.json",FileAccess.WRITE);file.store_string(JSON.stringify(records,"  "));file.close()
 print("CONNECTED 070 NATIVE PASS: five layouts; contract claim/rotation/reload, Archive/notes/memories, locked/available regions and modes, dialogue close, no duplicate reward or combat input. Artistic/physical acceptance pending.");quit()
