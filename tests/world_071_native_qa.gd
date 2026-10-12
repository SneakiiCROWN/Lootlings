extends "res://tests/phase4b_native_qa.gd"
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 OS.set_environment("LOOTLINGS_MOBILE_TEST","1")
 create_timer(180).timeout.connect(func():push_error("World071 timeout");quit(1));call_deferred("review")
func review() -> void:
 var evidence:Array=[]
 for viewport in [Vector2i(360,640),Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/world071/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  game.startup_ui.show_title();await capture("title")
  game.gold=1234567;game.meta_shards=9876;game.inventory.scrap=9999
  game.profile.companion.owned_ids=preload("res://companion_catalog.gd").known_ids();game.profile.companion.equipped_id="auricub";game.profile.companion.accompany=true
  game.show_hideout();await create_timer(.5).timeout;var h=game.hideout_ui;await capture("hub")
  if h.has_method("notice_resident"):
   for speaker in ["Salvager","Relic Keeper","Archivist"]:
    h.notice_resident(speaker);assert(h.resident_activity(speaker)=="inspect")
    var body:Dictionary=preload("res://resident_art_catalog.gd").presentation(speaker,h.RESIDENT_RECTS[speaker],h.resident_activity(speaker),h.resident_facing)
    assert(body.export_state=="inspect" and body.full_body)
   await capture("residents_notice")
  h.request_dialogue("tapped","Salvager");assert(h.resident_activity("Salvager")=="talk");await capture("patch_talk")
  await tap(h.speech_role);assert(h.current_screen=="shop")
  await capture("shop")
  var controls:Array=[h.shop_gold_cache_button,h.shop_cache_button,h.shop_expansion_button,h.shop_reroll_button]
  for i in range(controls.size()):
   var b:Button=controls[i];var rect:Rect2=b.get_global_rect();var physical:Vector2=root.get_screen_transform().basis_xform(rect.size)
   assert(physical.y>=44 and root.get_visible_rect().encloses(rect))
   for j in range(i):assert(not rect.intersects(controls[j].get_global_rect()),"Shop utility buttons overlap")
   assert(not rect.intersects(h.shop_buy_button.get_global_rect()))
   var gold:int=game.gold;var scrap:int=game.inventory.scrap;var cap:int=game.inventory.stash_capacity
   assert(not b.disabled);await tap(b);assert(is_instance_valid(game.touch_ux.dialog),b.text)
   await capture("confirm_"+str(i));game.touch_ux.close_dialog();assert(game.gold==gold and game.inventory.scrap==scrap and game.inventory.stash_capacity==cap)
  game.navigate_back();assert(h.current_screen=="home")
  game.expedition_progress.data.seen["event:secret_bell"]=true;game.expedition_progress.data.archive_read.clear();h.show_phase4("archive");await process_frame;await tap(h.phase4_list.get_child(3));assert(h.archive_discoveries.visible)
  var view=h.archive_discoveries;var row:Button=view.list.get_child(0)
  assert(row.text.contains("New"));await capture("archive_new")
  preload("res://save_scope.gd").transitioning=true;view.open_record(row.get_meta("discovery_id"));preload("res://save_scope.gd").transitioning=false
  assert(game.expedition_progress.data.archive_read.is_empty() and h.phase4_detail.text.contains("Could not save"))
  await tap(h.phase4_action);row=view.list.get_child(0);await tap(row);assert(game.expedition_progress.data.archive_read.get(row.get_meta("discovery_id"),false));await capture("archive_read")
  var reload=preload("res://expedition_progress.gd").new();reload.load_progress();assert(reload.data.archive_read==game.expedition_progress.data.archive_read)
  var seen:Dictionary=reload.data.seen.duplicate(true);assert(reload.read_discovery("secret:never_found")==ERR_INVALID_PARAMETER and reload.data.seen==seen)
  await tap(h.phase4_action);assert(view.list.get_child(0).text.contains("Read"));h.show_home()
  game.show_personal_home();var home=game.personal_home;await capture("home")
  var saved:Dictionary=game.profile.homestead.duplicate(true);await tap(home.buttons.display);assert(home.view=="decor");await capture("decor")
  home.open("decor_preview");await capture("preview");home.go_back();home.go_back();assert(home.view=="room" and game.profile.homestead==saved)
  await tap(home.buttons.nook);assert(home.view in ["room","companions"]);home.open("room")
  await tap(home.buttons.chest);assert(h.current_screen=="stash" and h.private_return);game.navigate_back();assert(home.visible)
  await tap(home.buttons.leave);assert(game.state=="hideout")
  game.audio_settings.cinematic_reduced_motion=true;await capture("hub_reduced_motion")
  evidence.append({"viewport":str(viewport),"shop_four_independent_targets":true,"confirmed_cancel_no_debit":true,"canonical_resident_inspect_talk":h.has_method("notice_resident"),"home_preview_cancel_no_save_mutation":true,"physical_android":false,"professional_acceptance":false})
  game.free();await process_frame
 var f=FileAccess.open("res://.godot_test_data/world071/RESULTS.json",FileAccess.WRITE);f.store_string(JSON.stringify(evidence,"  "));f.close()
 print("WORLD071 NATIVE PASS four layouts: title, Hub notice/talk, Shop four separate confirmation targets, Home decorate/preview/cancel/Stash/return, reduced motion. Sparse canon keyframes only; owner artistic acceptance pending.");quit()
