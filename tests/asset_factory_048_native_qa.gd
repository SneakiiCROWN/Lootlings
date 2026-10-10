extends "res://tests/phase4b_native_qa.gd"
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 assert(DisplayServer.get_name()!="headless")
 if OS.get_environment("LOOTLINGS_048_PREVIEW")=="1":
  OS.set_environment("LOOTLINGS_QA_NPC_PREVIEW","1")
  OS.set_environment("LOOTLINGS_QA_ITEM_PREVIEW","1")
 create_timer(180).timeout.connect(func():push_error("Factory 048 timeout");quit(1))
 call_deferred("review")
func capture(label: String) -> void:
 game.hideout_ui.queue_redraw()
 await super.capture(label)
func review() -> void:
 var catalog=preload("res://resident_art_catalog.gd")
 var ids=["quiet_chime","frostbell_seal","storm_ledger","threefold_ink","shelter_script","critical_script"]
 var probes=[]
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/asset-factory-048/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
  game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  game.show_hideout();await create_timer(.4).timeout
  var hub=game.hideout_ui;hub.set_process(false);hub.dismiss_dialogue()
  if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
  var original=[game.gold,game.inventory.scrap,game.rng.state,game.attack_sequence]
  for facing in ["left","right"]:
   hub.resident_facing=facing;hub.scene_time=0
   assert(catalog.presentation("Relic Keeper",Rect2(337,350,74,128),"tend",facing).export_state=="work/read/tend")
   for speaker in ["Salvager","Archivist","Relic Keeper"]:
    var entry:Dictionary=catalog.presentation(speaker,Rect2(337,350,74,128),"repair" if speaker=="Salvager" else "tend" if speaker=="Relic Keeper" else "read",facing)
    assert(entry.export_state=="work/read/tend" and entry.facing==facing and entry.full_body)
    assert(absf(entry.rect.end.y-478)<1.0)
   await capture("hub_work_"+facing)
  for station in ["ShopEntrance","ForgeStation","ArchiveDesk"]:
   await tap(hub.hub_navigation.world_buttons[station]);await capture(station)
   game.navigate_back();await process_frame;assert(hub.current_screen=="home")
  game.inventory.stash.clear()
  for id in ids:
   var item:Dictionary=game.ItemCatalog.create_item(id,"RARE",game.inventory.stash.size()+200)
   assert(not item.is_empty())
   var art:Texture2D=preload("res://lootlings_ui.gd").raw_item_texture(item)
   assert(art.resource_path=="res://art/production/phase4e/items/named_048/"+id+".png")
   game.inventory.stash.append(item)
  hub.show_stash();await capture("named_loot_stash")
  for index in range(hub.entries.size()):
   if str(hub.entries[index].item.id) in ids:
    hub.select_entry(index);await capture("detail_"+str(hub.entries[index].item.id))
    hub.close_stash_detail()
  game.show_personal_home();await capture("personal_home")
  assert([game.gold,game.inventory.scrap,game.rng.state,game.attack_sequence]==original)
  assert(FileAccess.get_sha256("res://art/audio/production/music/title.ogg")=="7d53beed1a8ba204fb9fc7809a659ca73c755f328c7c8e456b9a037db65ec9a7")
  probes.append({"viewport":str(viewport),"npc_work_both_facings":true,"six_named_items":true,"station_touch_returns":true,"economy_unchanged":true,"physical_device_tested":false})
  game.free();await process_frame
 var report=FileAccess.open("res://.godot_test_data/asset-factory-048/PROBES.json",FileAccess.WRITE);report.store_string(JSON.stringify({"probes":probes,"fluid_animation_accepted":false},"\t"));report.close()
 print("ASSET FACTORY 048 NATIVE PASS: six service poses, six named item identities in Stash/detail, original Shop/Forge/Archive touch routes and returns, unchanged economy/title; phone/tablet/desktop.")
 quit()
