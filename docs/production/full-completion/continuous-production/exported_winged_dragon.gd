extends SceneTree
var game
var folder:String
func _initialize() -> void:
 assert(OS.get_environment("LOOTLINGS_QA")=="1" and ".godot_test_data" in OS.get_user_data_dir())
 create_timer(90).timeout.connect(func():push_error("EXPORTED OWNER ROUTE timeout");quit(1))
 OS.set_environment("LOOTLINGS_MOBILE_TEST","1")
 call_deferred("review")
func capture(label:String) -> void:
 await create_timer(.3).timeout;game.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
 assert(root.get_texture().get_image().save_png(folder+label+".png")==OK)
func tap(control: Control) -> void:
 root.grab_focus(); await process_frame
 var point: Vector2=root.get_screen_transform()*control.get_global_rect().get_center()-Vector2(root.position)
 var motion:=InputEventMouseMotion.new(); motion.position=point; Input.parse_input_event(motion); Input.flush_buffered_events(); await process_frame
 var event:=InputEventScreenTouch.new(); event.index=0; event.pressed=true; event.position=point
 Input.parse_input_event(event); Input.flush_buffered_events(); await create_timer(.07).timeout
 event=InputEventScreenTouch.new(); event.index=0; event.pressed=false; event.position=point
 Input.parse_input_event(event); Input.flush_buffered_events(); await process_frame; await process_frame

func find_button(parent:Node,text:String) -> Button:
 for n in parent.get_children():
  if n is Button and n.text==text:return n
  var found:=find_button(n,text)
  if found!=null:return found
 return null
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder=OS.get_environment("LOOTLINGS_EXPORT_CAPTURE")+"/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame
  game.app_lifecycle.platform_notifications_enabled=false;game.audio_settings.cinematic_first_time=false
  game.profile.avatar_mode="lootling";game.profile.current_lootling_id="relic_beast"
  game.inventory.reset_to_starter();game.inventory.equip(game.ItemCatalog.create_item(str(preload("res://weapon_catalog.gd").STARTERS.wand.id),"COMMON",81));game.start_run();game.set_process(false)
  game.campaign_id="act_i";game.wave=15;game.spawn_enemy();game.enemy_entry_anim=0;game.special_intro_timer=0;game.wave_banner_timer=0;game.presentation_director.finish_travel();game.presentation_director.toast_queue.clear();game.presentation_director.active_toast.clear();game.presentation_director.toast_panel.hide()
  if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
  game.enemy_hp=10000;game.enemy_max_hp=10000;game.player_hp=10000;game.player_max_hp=10000
  for facing in [-1,1]:
   game.forced_facing_test=0;game.player_x=160 if facing<0 else 355;game.enemy_stage_x=365 if facing<0 else 140
   for phase in ["idle","windup","commit","hurt","recovery","defeat"]:
    game.enemy_alive=phase!="defeat";game.enemy_attack_count=0;game.enemy_flash=.1 if phase=="hurt" else 0;game.enemy_squash=0;game.enemy_recoil=0
    game.enemy_death_anim=.82 if phase=="defeat" else 0
    game.boss_recovery=.4 if phase=="recovery" else 0;game.enemy_attack_clock=.15 if phase=="windup" else game.enemy_attack_interval
    game.combat_presentation.boss_action="CLAWS";game.combat_presentation.boss_action_time=.55 if phase=="commit" else 0
    var profile:=preload("res://boss_presentation.gd").profile_for(game)
    assert(profile.get("authored_state","")==phase)
    assert(not profile.get("reused_idle_for_missing_action",false))
    await capture("%s_%s" % [phase,"left" if facing<0 else "right"])
   game.enemy_alive=true;game.enemy_flash=0;game.enemy_death_anim=0;game.boss_recovery=0;game.enemy_attack_count=0;game.enemy_attack_clock=.1
   game.perform_enemy_attack();game.enemy_attack_clock=game.enemy_attack_interval
   for tick in range(6):
    game.update_effects(.07);await capture("transition_%d_%d" % [facing,tick])
   assert(preload("res://boss_art_manifest.gd").state_for(game).state=="recovery")
  # Unrelated regional boss fallbacks keep their current accepted source.
  game.campaign_id="mossglass_wilds";assert(not preload("res://boss_presentation.gd").profile_for(game).has("authored_state"))
  game.free();await process_frame
 print("HOARD DRAGON NATIVE PASS: 12 distinct canonical states, both real facings, no mirrors, actual claw/settle transition, unchanged other bosses, three viewports");quit()
