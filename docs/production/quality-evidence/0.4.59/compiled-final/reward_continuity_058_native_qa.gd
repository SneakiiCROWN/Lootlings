extends "C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-fixtures-0591/phase4b_native_qa.gd"
const Views=preload("res://result_actor_view.gd")
const Pickups=preload("res://pickup_presentation.gd")
const Reveal=preload("res://reward_reveal_catalog.gd")
const Myth=preload("res://mythical_collection.gd")
func point_tap(local:Vector2) -> void:
 var point:Vector2=root.get_screen_transform()*(game.get_global_transform_with_canvas()*local)-Vector2(root.position)
 for down in [true,false]:
  var e:=InputEventScreenTouch.new();e.index=0;e.pressed=down;e.position=point;Input.parse_input_event(e);Input.flush_buffered_events();await create_timer(.07).timeout
 await process_frame
func review() -> void:
 var outcome_cases:=0;var fallbacks:=0;var matrix:Array=[]
 for viewport in [Vector2i(1080,2340),Vector2i(1600,2560),Vector2i(1920,1080)]:
  root.size=viewport;folder="C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-0591/reward-058/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.start_run();game.set_process(false);game.audio_settings.cinematic_first_time=false;game.app_lifecycle.platform_notifications_enabled=false;game.enemy_alive=false;game.enemy_encounter.clear();game.wave_banner_timer=0;game.particles.clear();game.loot_drops.clear()
  game.prepare_hoard_chest();game.update_hoard_chest(.63);assert(game.hoard_chest_phase=="ready" and game.hoard_chest_y==493 and game.hoard_chest_button.visible)
  game.boss_reward_options.clear()
  for index in range(3):game.boss_reward_options.append(game.ItemCatalog.create_item(Myth.IDS[index],"MYTHICAL SHINY",index+58))
  game.hoard_reveal_profile=Reveal.for_rewards("hoard_chest",game.boss_reward_options)
  assert(game.hoard_reveal_profile.rarity=="MYTHICAL SHINY" and game.hoard_reveal_profile.anticipation>1.02)
  var rng_before:int=game.rng.state;var attacks:int=game.attack_sequence
  await capture("chest_ready");await point_tap(Vector2(24,300));assert(game.hoard_chest_phase=="ready" and game.attack_sequence==attacks)
  var right:=InputEventMouseButton.new();right.pressed=true;right.button_index=MOUSE_BUTTON_RIGHT;right.position=Vector2(24,300);game._unhandled_input(right);assert(game.hoard_chest_phase=="ready")
  await tap(game.hoard_chest_button);assert(game.hoard_chest_phase=="windup" and game.attack_sequence==attacks);game.open_hoard_chest();assert(game.loot_drops.is_empty())
  await capture("chest_anticipation");game.update_hoard_chest(2);assert(game.hoard_chest_phase=="silence");game.update_hoard_chest(1)
  assert(game.loot_drops.size()==3 and game.rng.state==rng_before and game.audio_manager.last_event_msec.has("spinner_jackpot"))
  game.eject_hoard_loot();assert(game.loot_drops.size()==3)
  var banner_found:=false
  for message in game.floating_texts:
   if message.text=="THE HOARD OPENS":assert(message.pos.y==280 and message.lane=="announcement");banner_found=true
  assert(banner_found)
  for index in range(3):
   assert(game.loot_drops[index].visual_slot==index);game.loot_drops[index].pos=Vector2(90+index*150,580);game.loot_drops[index].bounces=1
   for previous in range(index):assert(not Pickups.caption_rect(game.loot_drops[index]).intersects(Pickups.caption_rect(game.loot_drops[previous])))
  game.presentation_director.toast_queue.clear();game.presentation_director.active_toast.clear();game.presentation_director.toast_panel.hide();await capture("real_hoard_three_captions")
  game.audio_settings.cinematic_reduced_motion=true;game.loot_drops.clear();game.prepare_hoard_chest();game.update_hoard_chest(.63);assert(game.screen_shake==0);await capture("reduced_chest_ready");game.open_hoard_chest();game.update_hoard_chest(2);game.update_hoard_chest(1);assert(game.screen_shake==0)
  # Existing canonical portraits are an honest fallback, not new outcome art.
  for mode in ["lootling","wanderer"]:
   var actors:Array=game.LootlingCatalog.ENTRIES.keys() if mode=="lootling" else game.Phase4.HUMANS.keys()
   for actor in actors:
    game.profile.avatar_mode=mode
    if mode=="lootling":game.profile.current_lootling_id=actor
    else:game.profile.wanderer.preset_id=actor
    for weapon in range(4):
     game.inventory.equipped.Weapon=game.ItemCatalog.create_item(Myth.IDS[weapon],"MYTHICAL SHINY",weapon+580)
     for facing in [-1,1]:
      game.forced_facing_test=facing;game.player_facing=facing
      for won in [true,false]:
       game.debug_show_result(won);assert(game.run_won==won)
       var view=Views.new();view.game=game;var kind:String=view.presentation_kind();view.free()
       assert(kind in ["authored_outcome","canonical_portrait_pending_outcome"])
       assert(preload("res://avatar_presentation.gd").portrait(game.profile)!=null)
       if kind=="canonical_portrait_pending_outcome":fallbacks+=1
       outcome_cases+=1;matrix.append({"actor":actor,"weapon":Myth.IDS[weapon],"facing":facing,"victory":won,"presentation":kind,"professional_acceptance":false})
    if actor in ["relic_beast","vault_runner"]:await capture("outcome_"+actor)
  var helper=preload("C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-fixtures-0591/weapon_fit_qa.gd").new();helper.game=game;helper.prepare("moonkip","orb");game.debug_show_result(false)
  var authored_view=Views.new();authored_view.game=game;assert(authored_view.presentation_kind()=="authored_outcome");authored_view.free();await capture("preserved_moonkip_orb_outcome");helper.free()
  game.free();await process_frame
 var f:=FileAccess.open(folder+"outcome_matrix.json",FileAccess.WRITE);assert(f!=null);f.store_string(JSON.stringify(matrix,"  "));f.close()
 print("REWARD CONTINUITY 058 NATIVE PASS: real chest land/object tap/three ejected caption slots/one-time reveal, Mythical existing fanfare, reduced shake; %d actor-weapon-facing-outcome layout cases; %d intentional portrait fallbacks remain missing authored outcome contracts." % [outcome_cases,fallbacks]);quit()
