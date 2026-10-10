extends "res://tests/phase4b_native_qa.gd"
func _initialize() -> void:
 if not preload("res://tests/test_safety.gd").require_isolated(self):return
 create_timer(100).timeout.connect(func():push_error("Peddler QA timeout");quit(1));call_deferred("review")
func review() -> void:
 var probes:Array=[]
 for viewport in [Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="res://.godot_test_data/peddler-051/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  game.show_hideout();game.start_run();game.set_process(false);game.presentation_director.finish_travel();game.presentation_director.vignette.finish();game.enemy_encounter.clear();game.wave_banner_timer=0;game.special_intro_timer=0
  game.coins=5000;game.show_merchant();await create_timer(.35).timeout
  var actor=game.merchant_panel.get_node("PackPeddlerBody")
  var wallets:Array=[game.coins,game.gold,game.meta_shards];var stock:Array=game.shop.stock.duplicate(true)
  for facing in ["left","right"]:
   for activity in ["rest","talk","offer","inspect","return"]:
    var row:Dictionary=preload("res://resident_art_catalog.gd").body_frame("pack_peddler",activity,facing)
    assert(not row.is_empty() and row.row.state==activity and row.row.facing==facing)
    assert(row.texture.atlas is Texture2D and row.texture.get_width()>0 and row.texture.get_height()>0)
    actor.qa_state=activity;actor.qa_facing=facing
    await capture(activity+"_"+facing)
    probes.append({"state":activity,"facing":facing,"viewport":[viewport.x,viewport.y],"slot_id":row.row.contract_slot_id})
  actor.qa_state="";actor.qa_facing=""
  for i in range(3):
   assert(game.merchant_buttons[i].size.y>=48)
   if i<2:assert(game.merchant_buttons[i].position.y+game.merchant_buttons[i].size.y<game.merchant_buttons[i+1].position.y)
  assert(game.merchant_buttons[2].position.y+game.merchant_buttons[2].size.y<game.merchant_detail.position.y)
  assert(game.merchant_detail.position.y+game.merchant_detail.size.y<game.merchant_buy_button.position.y)
  await tap(game.merchant_buttons[0]);await create_timer(.1).timeout
  assert(game.merchant_selection==0 and actor.activity=="offer" and not game.merchant_buy_button.disabled)
  await tap(game.merchant_reroll_button);await create_timer(.1).timeout
  assert(is_instance_valid(game.touch_ux.dialog) and actor.activity=="inspect")
  game.touch_ux.close_dialog();game.audio_settings.cinematic_reduced_motion=true
  var away:=InputEventMouseMotion.new();away.position=Vector2(2,2);Input.parse_input_event(away);Input.flush_buffered_events();await create_timer(.1).timeout
  await capture("selected_offer_reduced_motion")
  assert([game.coins,game.gold,game.meta_shards]==wallets and game.shop.stock==stock)
  await tap(game.merchant_continue_button);assert(not game.merchant_panel.visible)
  game.free();await process_frame
 var file=FileAccess.open("res://.godot_test_data/peddler-051/PROBES.json",FileAccess.WRITE);file.store_string(JSON.stringify({"probes":probes,"failures":[]},"\t"));file.close()
 print("PEDDLER 051 NATIVE PASS: 30 exact service-state/facing/layout probes; offer selection, reroll cancel, reduced motion, no wallet/stock mutation and exit")
 quit()
