extends SceneTree
var game
var folder:String
# extends SceneTree through guarded native touch/capture helper.
func _initialize() -> void:
 assert(OS.get_environment("LOOTLINGS_QA")=="1" and ".godot_test_data" in OS.get_user_data_dir())
 create_timer(115).timeout.connect(func():push_error("Player route timeout");quit(1))
 call_deferred("review")
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder=OS.get_environment("LOOTLINGS_EXPORT_CAPTURE")+"/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
  game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false;game.set_process(false)
  game.inventory.scrap=0;game.meta_shards=0;game.hideout_ui.shards=0
  game.show_personal_home();await capture("home");await tap(game.personal_home.buttons.leave);assert(game.state=="hideout")
  var hub=game.hideout_ui;await create_timer(.3).timeout;await capture("hub")
  # The actual cart region itself owns the Shop, not its optional dialogue badge.
  assert(hub.hub_navigation.world_buttons.ShopEntrance.get_rect().encloses(Rect2(350,338,110,116)))
  await tap(hub.hub_navigation.world_buttons.ShopEntrance);assert(hub.current_screen=="shop")
  var attacks:int=game.attack_sequence
  await capture("shop_no_selection")
  await tap(hub.shop_offer_buttons[0]);assert(hub.shop_buy_button.disabled and hub.shop_buy_button.text.contains("NEED"));await capture("shop_compare_unaffordable")
  await tap(hub.shop_offer_buttons[1]);assert(not hub.shop_offer_buttons[0].get_meta("ui_selected") and hub.shop_offer_buttons[1].get_meta("ui_selected"))
  game.inventory.scrap=300;hub.refresh_shop();hub.refresh_shop();
  for offer in hub.shop_offer_buttons:
   var icons:int=0
   for child in offer.get_children():
    if child is TextureRect or child.get_script()==preload("res://item_icon.gd"):icons+=1
   assert(icons<=2,"Refresh must not accumulate item pictures")
  assert(not hub.shop_buy_button.disabled);assert(hub.shop_offer_buttons[1].get_theme_stylebox("normal").texture!=null);await capture("shop_compare_ready")
  var price:int=game.hideout_shop.stock[1].price;var stored:int=game.inventory.stash.size();var scrap:int=game.inventory.scrap
  await tap(hub.shop_buy_button);assert(game.inventory.stash.size()==stored+1 and game.inventory.scrap==scrap-price)
  game.navigate_back();await process_frame;assert(hub.current_screen=="home")
  await tap(hub.hub_navigation.world_buttons.StorageChest);await tap(hub.stash_list.get_child(hub.entries.size()-1));await capture("stash_owned_compare");game.navigate_back();await process_frame;game.navigate_back();await process_frame
  game.meta_shards=0;hub.shards=0;await tap(hub.hub_navigation.world_buttons.ShrineProp);assert(hub.upgrade_button.disabled and hub.upgrade_button.text.contains("NEED"));await capture("shrine_requirements");game.navigate_back();await process_frame
  game.retention.progress.data.free_spins=1;game.retention.progress.save();await tap(hub.engine_button);assert(game.state=="relic_spinner" and game.retention.spinner_from_home)
  await create_timer(.25).timeout;var wallet:int=game.retention.progress.data.spin_wallet
  await tap(game.retention.buttons[0]);assert(game.retention.spin_busy and game.retention.progress.data.free_spins==0 and game.retention.progress.data.spin_wallet==wallet)
  await capture("spinner_real_earned_reveal")
  while game.retention.spin_busy:await process_frame
  await create_timer(.25).timeout
  await tap(game.retention.buttons[1]);assert(game.state=="hideout");await create_timer(.3).timeout
  await tap(hub.engine_button);assert(game.retention.buttons[0].disabled and game.retention.buttons[0].text=="EARN SPINS ON EXPEDITIONS");assert(game.retention.detail.text.contains("30 kills"));await capture("spinner_empty_explained")
  game.navigate_back();await process_frame;assert(game.state=="hideout" and game.attack_sequence==attacks)
  var risky:Dictionary={"slot":"Relic","effects":{"incoming_mult":.12}}
  var neutral:Dictionary={"slot":"Relic","name":"Current charm","effects":{}}
  var comparison:String=game.build_item_comparison(risky,neutral);assert(comparison.contains("#ff7d88") and comparison.contains("more damage taken"));assert(not game.build_item_comparison(risky,{}).contains("EVERYTHING IS A GAIN"))
  game.start_run();game.set_process(false);game.wave_banner_timer=0;game.special_intro_timer=0;game.enemy_entry_anim=0;game.player_x=game.target_player_x();game.presentation_director.finish_travel()
  if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
  game.presentation_director.toast_queue.clear();game.presentation_director.active_toast.clear();game.presentation_director.toast_panel.hide()
  game.player_hp=game.player_max_hp*.6;game.player_ward=12;game.xp=game.xp_needed*.6;await capture("combat_readability")
  game.player_x=355;game.enemy_stage_x=140;await capture("portrait_fallback_no_debug_text")
  game.player_x=game.target_player_x();game.enemy_stage_x=355
  var hp:float=game.enemy_hp;game.request_tap_attack();for tick in range(12):game._process(.05)
  assert(game.enemy_hp<hp or not game.enemy_alive)
  game.pending_levels=1;game.show_upgrade_choices();await create_timer(.4).timeout;await tap(game.upgrade_buttons[0]);await capture("perk_choice");game.skip_upgrade()
  game.boss_reward_options=[game.ItemCatalog.create_item("mossguard_harness","EPIC",9502)];game.normal_loot_choice=true;game.show_boss_reward();await capture("reward_find");game.choose_boss_reward(0);game.accept_item_keep()
  game.total_kills=12;game.end_run(false);await capture("results")
  var secured:Array=[game.gold,game.meta_shards,game.inventory.scrap];game.end_run(false);assert(secured==[game.gold,game.meta_shards,game.inventory.scrap])
  await tap(game.restart_button);assert(game.state=="hideout");await capture("return_hub")
  assert(FileAccess.get_sha256("res://art/audio/production/music/title.ogg")=="7d53beed1a8ba204fb9fc7809a659ca73c755f328c7c8e456b9a037db65ec9a7")
  game.free();await process_frame
 print("PLAYER ROUTE POLISH NATIVE PASS: Home/Hub/cart Shop, actual purchase once, Stash, Shrine reasons, earned Spinner touch/reward/return and empty bank, combat/perks/find/results; three viewports; title preserved");quit()

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
