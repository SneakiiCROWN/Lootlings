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
  game.campaign_id="mossglass_wilds";game.wave=1;game.spawn_enemy();game.enemy_name="FEN SNEAK";game.enemy_archetype="skirmisher";game.enemy_is_boss=false;game.enemy_is_miniboss=false;game.enemy_entry_anim=0;game.special_intro_timer=0;game.wave_banner_timer=0
  game.presentation_director.finish_travel();game.presentation_director.toast_queue.clear();game.presentation_director.active_toast.clear();game.presentation_director.toast_panel.hide()
  if game.presentation_director.vignette.active:game.presentation_director.vignette.finish()
  game.enemy_hp=10000;game.enemy_max_hp=10000;game.player_hp=10000;game.player_max_hp=10000;game.player_x=160;game.enemy_stage_x=365
  var original_rng: int=game.rng.state
  for phase in ["idle","role windup","role commit","hurt","recovery","defeat"]:
   game.enemy_alive=phase!="defeat";game.enemy_flash=.1 if phase=="hurt" else 0;game.enemy_death_anim=.62 if phase=="defeat" else 0
   game.enemy_attack_anim=.16 if phase=="role commit" else .04 if phase=="recovery" else 0;game.enemy_attack_clock=.12 if phase=="role windup" else game.enemy_attack_interval
   var frame:=preload("res://approved_missing_runtime_art.gd").enemy_neutral(game,365)
   assert(frame.authored_state==phase and frame.source_facing=="left" and not frame.get("reused_idle_for_missing_action",false))
   await capture(phase.replace(" ","_"))
  assert(original_rng==game.rng.state,"Pure pose selection must preserve RNG")
  game.enemy_alive=true;game.enemy_flash=0;game.enemy_death_anim=0;game.enemy_attack_anim=0;game.enemy_attack_clock=.12
  var hp: float=game.player_hp;game.perform_enemy_attack();assert(game.player_hp<hp)
  game.enemy_attack_clock=game.enemy_attack_interval
  for tick in range(8):game.update_effects(.02);await capture("slash_transition_%d" % tick)
  game.player_x=420;game.enemy_stage_x=108;game.enemy_attack_anim=0
  assert(preload("res://approved_missing_runtime_art.gd").enemy_neutral(game,108).path.ends_with("fen_sneak_idle_right.png"),"Accepted right body preserved")
  await capture("retained_right_idle")
  game.free();await process_frame
 print("FEN SNEAK NATIVE PASS: six exact left poses, real attack damage/transition, canonical right retained, unchanged pose-selection RNG, three viewports");quit()
