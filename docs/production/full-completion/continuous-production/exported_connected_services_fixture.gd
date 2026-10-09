extends SceneTree
var game
var folder:String
func _initialize() -> void:
 assert(OS.get_environment("LOOTLINGS_QA")=="1" and ".godot_test_data" in OS.get_user_data_dir())
 OS.set_environment("LOOTLINGS_MOBILE_TEST","1")
 create_timer(115).timeout.connect(func():push_error("Connected services timeout");quit(1));call_deferred("review")
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder=OS.get_environment("LOOTLINGS_EXPORT_CAPTURE")+"/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
  game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false;game.set_process(false);game.show_hideout();await create_timer(1.3).timeout
  var h=game.hideout_ui;var p=game.expedition_progress;var heard:Array=[];h.ui_event.connect(func(event):heard.append(event))
  game.gold=0;game.inventory.scrap=0;game.inventory.stash.clear();game.refresh_hideout();h.show_forge();await capture("forge_requirements")
  assert(h.forge_confirm.disabled and h.forge_confirm.text.contains("NEED"));assert(h.forge_list.get_child(0).get_meta("ui_selected"))
  var attacks:int=game.attack_sequence;await tap(h.forge_list.get_child(1));assert(h.forge_recipe=="greataxe" and not h.forge_list.get_child(0).get_meta("ui_selected"))
  game.gold=500;game.inventory.scrap=30;game.refresh_hideout();h.select_forge_recipe("greataxe");await capture("forge_recipe_ready")
  await tap(h.forge_confirm);assert(h.forge_armed and game.inventory.stash.is_empty());await tap(h.forge_confirm);assert(game.inventory.stash.size()==1 and game.gold==350 and game.inventory.scrap==24)
  h.show_phase4("blueprints");await process_frame;await tap(h.phase4_list.get_child(0));assert(h.phase4_selected=="oath_slab" and h.phase4_action.disabled and h.phase4_action.text.contains("NEED"));await capture("blueprint_requirements")
  p.data.fragments.oath_slab=3;p.data.materials.act_i=30;p.data.boss_parts.act_i=2;h.refresh_phase4();assert(not h.phase4_action.disabled);await capture("blueprint_ready");await create_timer(.4).timeout;await tap(h.phase4_action)
  assert(game.inventory.stash.size()==2 and p.data.materials.act_i==18);assert(h.phase4_detail.text.contains("forged into Gear"));await capture("blueprint_delivery")
  p.data.seen["region:act_i"]=true;p.data.seen["event:secret_bell"]=true;p.data.actors.relic_beast=31
  h.show_phase4("archive");await process_frame;await tap(h.phase4_list.get_child(0));assert(h.phase4_detail.text.contains("RELIC RANK") and not h.phase4_action.visible);await capture("archive_mastery")
  await tap(h.phase4_list.get_child(3));assert(h.phase4_detail.text.contains("The Hidden Bell") and not h.phase4_detail.text.contains("actor:") and not h.phase4_detail.text.contains("RELIC RANK"));assert("archive_page" in heard);assert(game.audio_manager.EVENT_SPECS.archive_page[0]=="UI");assert(game.audio_manager.production_event_streams("archive_page")[0].data==game.audio_manager.production_event_streams("home_page")[0].data);await capture("archive_discoveries");await tap(h.phase4_list.get_child(1));assert(h.phase4_detail.text.contains("Emberhorn") and h.phase4_detail.text.contains("WANDERERS"));await capture("canon_roster")
  h.show_home();h.request_dialogue("tapped","Salvager");assert(h.speech_role.text.contains("SHOP"));await capture("patch_dialogue");await tap(h.speech_role);assert(h.current_screen=="shop" and not h.speech_panel.visible)
  game.campaign.completed.clear();p.data.actors.clear();p.data.weapons.clear();h.show_campaign();await process_frame;assert(h.tier_buttons[1].text.contains("Rank"));await capture("expedition_unlocks")
  await tap(h.campaign_list.get_child(1));assert(h.region_sheet.visible and h.region_depart.disabled and h.region_detail.text.contains("to unlock"));await capture("locked_region_inspect")
  var chosen:String=h.selected_region_id;await tap(h.campaign_list.get_child(0));assert(h.selected_region_id==chosen);game.navigate_back();assert(not h.region_sheet.visible and not h.campaign_content.get_node("RegionVeil").visible)
  await tap(h.campaign_list.get_child(0));assert(not h.region_depart.disabled);await capture("region_ready");await tap(h.region_depart);await create_timer(1.1).timeout;assert(game.state in ["route","playing"])
  game.set_process(false);game.show_hideout();h.show_stash();await process_frame;await tap(h.stash_list.get_child(1));await capture("crafted_stash")
  assert(game.attack_sequence==attacks);assert(FileAccess.get_sha256("res://art/audio/production/music/title.ogg")=="7d53beed1a8ba204fb9fc7809a659ca73c755f328c7c8e456b9a037db65ec9a7")
  game.free();await process_frame
 print("CONNECTED SERVICES NATIVE PASS: two-step weapon craft, exact blueprint debit/delivery, Archive categories and page audio, Patch Shop route, locked region inspection, modal isolation, depart/return/Stash; three viewports; title preserved");quit()

func capture(label:String) -> void:
 await create_timer(.3).timeout;await RenderingServer.frame_post_draw
 assert(root.get_texture().get_image().save_png(folder+label+".png")==OK)
func tap(control: Control) -> void:
 root.grab_focus(); await process_frame
 var point: Vector2=root.get_screen_transform()*control.get_global_rect().get_center()-Vector2(root.position)
 var motion:=InputEventMouseMotion.new(); motion.position=point; Input.parse_input_event(motion); Input.flush_buffered_events(); await process_frame
 var event:=InputEventScreenTouch.new(); event.index=0; event.pressed=true; event.position=point
 Input.parse_input_event(event); Input.flush_buffered_events(); await create_timer(.07).timeout
 event=InputEventScreenTouch.new(); event.index=0; event.pressed=false; event.position=point
 Input.parse_input_event(event); Input.flush_buffered_events(); await process_frame; await process_frame
