extends "C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-fixtures-0591/phase4b_native_qa.gd"
# extends SceneTree through guarded native helper. Final owner-directed world pass.
func return_hub() -> void:
 for attempt in range(5):
  if game.state=="hideout" and game.hideout_ui.visible and game.hideout_ui.current_screen=="home" and not game.hideout_ui.speech_panel.visible:return
  game.navigate_back();await process_frame;await create_timer(.26).timeout
 assert(false,"Missing natural return to public Hub")
func review() -> void:
 var results:=[]
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-0591/world-navigation/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
  game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false;game.set_process(false)
  game.show_hideout();await create_timer(.3).timeout
  var hub=game.hideout_ui;var nav=hub.hub_navigation;var home=game.personal_home
  var gold:int=game.gold;var scrap:int=game.inventory.scrap;var attacks:int=game.attack_sequence
  var title_hash:String=FileAccess.get_sha256("res://art/audio/production/music/title.ogg")
  await capture("hub_world_overview")
  assert(nav.buttons.size()==6) # Three essential shortcuts and three aliases; no duplicate controls.
  var regions:Array=[]
  for id in nav.world_buttons:
   var b:Button=nav.world_buttons[id];assert(b.size.x>=84 and b.size.y>=52);assert(b.flat)
   assert(Rect2(0,0,480,854).encloses(Rect2(b.position,b.size)))
   for previous in regions:assert(not Rect2(b.position,b.size).intersects(previous),"World interactions overlap: "+id)
   regions.append(Rect2(b.position,b.size))
   assert(not b.get_node("FeatureName").text.is_empty())
  var direct={"GateEntrance":"campaign","ShrineProp":"upgrades","ShopEntrance":"shop","ContractBoard":"contracts","StorageChest":"stash","ForgeStation":"forge","ArchiveDesk":"workshop","RelicEngine":"relic_spinner"}
  for id in direct:
   await tap(nav.world_buttons[id])
   assert(game.state=="relic_spinner" if id=="RelicEngine" else hub.current_screen==direct[id],"Incorrect direct station: "+id)
   if id=="ArchiveDesk":assert(hub.phase4_mode=="archive")
   await capture("station_"+id)
   results.append({"viewport":str(viewport),"station":id,"destination":direct[id],"ordinary_taps":1,"natural_return":"hub"});await return_hub()
  for id in ["sera","patch","ilex"]:
   await tap(nav.talk_buttons[id]);await create_timer(.15).timeout
   if game.presentation_director.vignette.active:game.presentation_director.vignette.finish();await process_frame
   assert(hub.speech_panel.visible);assert(hub.speech_speaker=={"sera":"Relic Keeper","patch":"Salvager","ilex":"Archivist"}[id]);await capture("talk_"+id)
   # Dialogue is modal. Tapping a world object under it cannot open that service.
   var before:String=hub.current_screen
   await tap(nav.world_buttons.ForgeStation);assert(hub.current_screen==before and hub.speech_panel.visible)
   game.navigate_back();await process_frame;assert(not hub.speech_panel.visible)
  await tap(nav.buttons.character);assert(game.startup_ui.visible and game.input_surface()==game.startup_ui);await capture("character");await return_hub()
  await tap(nav.world_buttons.GateEntrance);await tap(hub.dungeon_start_button);assert(game.state=="mode_menu");game.navigate_back();await process_frame;await return_hub()
  await tap(nav.world_buttons.ForgeStation)
  var blueprint:Button
  for child in hub.forge_content.get_children():
   if child is Button and child.text=="BLUEPRINT FORGE":blueprint=child
  assert(blueprint!=null);await tap(blueprint);assert(hub.phase4_mode=="blueprints");await return_hub()
  await tap(nav.world_buttons.ContractBoard)
  var bounties:Button
  for child in hub.contracts_content.get_children():
   if child is Button and child.text.contains("BOUNT"):bounties=child
  assert(bounties!=null);await tap(bounties);assert(hub.phase4_mode=="contracts");await return_hub()
  await tap(nav.world_buttons.ArchiveDesk);await tap(hub.phase4_nav[0]);assert(hub.current_screen=="achievements");await return_hub()
  await tap(nav.world_buttons.ArchiveDesk);await tap(hub.phase4_nav[1]);assert(hub.current_screen=="lore");await return_hub()
  await tap(nav.buttons.home);assert(game.state=="personal_home" and not hub.visible);await capture("home_world_overview")
  await tap(home.buttons.bed);assert(home.warmth>0 and home.home_reaction.visible);assert(home.view=="room");await capture("home_rest_interaction")
  await tap(home.buttons.hearth);assert(home.warmth>0 and home.home_reaction.text.contains("embers"));assert(home.view=="room")
  assert(home.background().resource_path.ends_with("personal_home_lived_in_v2.png"),"Reviewed Home revision did not load")
  assert(preload("res://home_runtime_art.gd").registered_paths.has("environment:personal_home:interior"),"Home redraw loader is not cached")
  assert(home.buttons.gear==home.buttons.chest) # One chest, no duplicate Gear button.
  var layout:String=JSON.stringify(game.profile.homestead)
  await tap(home.buttons.chest);assert(hub.current_screen=="stash" and hub.private_return);game.navigate_back();await process_frame;assert(game.state=="personal_home")
  await tap(home.buttons.archive);assert(hub.current_screen=="memories" and hub.private_return);game.navigate_back();await process_frame;assert(game.state=="personal_home")
  await tap(home.buttons.character);assert(game.personal_profile_return and game.startup_ui.visible);game.navigate_back();await process_frame;assert(game.state=="personal_home")
  await tap(home.buttons.companions);assert(home.view=="companions");await capture("home_companions");game.navigate_back();await process_frame;assert(home.view=="room")
  await tap(home.buttons.shelf);assert(home.view=="decor" and home.selected_slot=="home.wall_display")
  await tap(home.decor_tabs["home.floor_perch"]);await tap(home.decor_list.get_child(1));assert(home.draft.placements["home.floor_perch"]=="")
  await tap(home.decor_panel.get_node("ViewRoom"));assert(home.view=="decor_preview");await capture("home_decor_preview")
  game.navigate_back();await process_frame;assert(home.view=="decor");game.navigate_back();await process_frame;assert(home.view=="room" and JSON.stringify(game.profile.homestead)==layout)
  await tap(home.buttons.display);await tap(home.decor_tabs["home.floor_perch"]);await tap(home.decor_list.get_child(0));await tap(home.decor_panel.get_node("ApplyDecor"));assert(home.view=="room")
  assert(game.profile.homestead.home_layout.placements["home.floor_perch"]=="home_companion_cushion")
  game.profile=preload("res://profile_store.gd").load_profile(game.PROFILE_SAVE_PATH);game.show_personal_home();assert(game.profile.homestead.home_layout.placements["home.floor_perch"]=="home_companion_cushion")
  await capture("home_saved_return");await tap(home.buttons.leave);await process_frame;assert(game.state=="hideout" and hub.current_screen=="home")
  await tap(nav.buttons.title);assert(game.startup_ui.visible and game.startup_ui.current_screen=="title");assert(FileAccess.get_sha256("res://art/audio/production/music/title.ogg")==title_hash)
  game.show_hideout();await create_timer(.3).timeout;await capture("hub_final_return")
  assert(game.gold==gold and game.inventory.scrap==scrap and game.attack_sequence==attacks,"World navigation changed economy or leaked combat")
  results.append({"viewport":str(viewport),"direct_stations":8,"essential_shortcuts":3,"npc_dialogue":3,"home_room_features":6,"decor_cancel_apply_reload":true,"existing_nested_features":true,"modal_input":true,"economy_unchanged":true,"approved_title_preserved":true})
  game.free();await process_frame
 var report=FileAccess.open("C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-0591/world-navigation/NAVIGATION_RESULTS.json",FileAccess.WRITE);report.store_string(JSON.stringify(results,"\t"));report.close()
 print("WORLD NAVIGATION NATIVE PASS: phone/tablet/desktop eight direct Hub stations, three edge shortcuts, exact NPC dialogue/modal input, retained workshop/bounty/Archive/mode routes; separate Home chest/book/display/character/companion interactions and decor Cancel/Apply/reload; no economy/combat leaks; title preserved")
 quit()
