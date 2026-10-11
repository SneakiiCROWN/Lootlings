extends "C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-fixtures-053/phase4b_native_qa.gd"
var actions := 0
func _initialize() -> void:
 if not preload("C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-fixtures-053/test_safety.gd").require_isolated(self):return
 create_timer(180).timeout.connect(func():push_error("Input 049 timeout");quit(1))
 call_deferred("review")
func contact(point:Vector2,down:bool,index:int=0) -> void:
 var e:=InputEventScreenTouch.new();e.index=index;e.pressed=down;e.position=root.get_screen_transform()*point-Vector2(root.position);Input.parse_input_event(e);await process_frame
func mouse(point:Vector2,down:bool) -> void:
 var e:=InputEventMouseButton.new();e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;e.position=point;Input.parse_input_event(e);await process_frame
func review() -> void:
 for viewport in [Vector2i(1080,2340),Vector2i(1200,1920),Vector2i(1920,1080)]:
  root.size=viewport;folder="C:/Users/Snkii/Documents/lootlings/.godot_test_data/exported-053/input-049/%dx%d/" % [viewport.x,viewport.y];DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
  game=load("res://main.tscn").instantiate();root.add_child(game);await process_frame;game.set_process(false);game.audio_settings.cinematic_first_time=false;game.app_lifecycle.platform_notifications_enabled=false
  for mode in ["merchant","upgrade","item","boss_reward","result","route","relic_spinner"]:
   game.show_hideout();game.start_run();game.set_process(false);game.presentation_director.finish_travel();game.presentation_director.vignette.finish();game.enemy_encounter.clear();game.enemy_hp=100000;game.player_x=game.target_player_x();await process_frame
   var point:Vector2=game.combat_controls.attack.get_global_rect().get_center()
   var start_actions:=actions;var economy=[game.gold,game.inventory.scrap,game.meta_shards]
   await contact(point,true);await contact(point,true,1)
   game.tap_buffer_timer=.4;game.state=mode
   var surface:Control=game.input_surface();surface.show()
   var trap:=Button.new();trap.text="Inherited input must never activate";trap.size=Vector2(300,64);surface.add_child(trap);trap.global_position=point-trap.size*.5;trap.pressed.connect(func():actions+=1)
   # No intervening frame: the release itself must observe the changed surface.
   await contact(point,false)
   assert(game.touch_ux.release_barrier and game.tap_buffer_timer==0)
   for repeat in range(12):await contact(point,true);await contact(point,true);await contact(point,false)
   assert(actions==start_actions and game.touch_ux.release_barrier)
   await contact(point,false,1);assert(not game.touch_ux.release_barrier)
   assert(actions==start_actions and [game.gold,game.inventory.scrap,game.meta_shards]==economy)
   await contact(point,true);await contact(point,false);assert(actions==start_actions+1,"Fresh deliberate press lost")
   trap.queue_free();surface.hide();await process_frame
  # A new modal in the SAME game state must fence both touch and real mouse.
  game.show_hideout();await process_frame
  var point:Vector2=game.hideout_ui.hub_navigation.world_buttons["ForgeStation"].get_global_rect().get_center()
  await contact(point,true);game.touch_ux.request("Test named purchase","No balance change",func():actions+=10)
  await contact(game.touch_ux.confirm_button.get_global_rect().get_center(),false);assert(not game.touch_ux.release_barrier)
  var before:=actions;await wait_real(220);assert(actions==before)
  await capture("named_confirmation");game.touch_ux.close_dialog();await process_frame
  await mouse(point,true);game.touch_ux.request("Second surface","Held mouse cannot confirm",func():actions+=10)
  await mouse(game.touch_ux.confirm_button.get_global_rect().get_center(),false);assert(actions==before)
  game.touch_ux.close_dialog();await process_frame
  await actual_consequences()
  game.free();await process_frame
 print("INPUT 049 NATIVE PASS: 7 screen types, repeated/held/multitouch and frame-perfect transitions, same-state modal/mouse fencing; fresh press works; zero inherited actions; three layouts.")
 quit()

func actual_consequences() -> void:
 game.show_hideout();game.start_run();game.set_process(false);game.presentation_director.finish_travel();game.presentation_director.vignette.finish()
 game.coins=10000;game.gold=10000;game.inventory.scrap=10000
 var attack:Vector2=game.combat_controls.attack.get_global_rect().get_center()
 await contact(attack,true);await wait_real(700)
 game.show_merchant();var balance:int=game.coins
 await contact(attack,false)
 for i in range(15):await contact(attack,true);await contact(attack,false)
 assert(game.coins==balance and not game.shop.purchase_taken and game.merchant_selection==-1)
 await tap(game.merchant_buttons[0]);await wait_real(220)
 var count:int=game.inventory.stash.size()
 await tap(game.merchant_buy_button);assert(is_instance_valid(game.touch_ux.dialog) and game.coins==balance)
 await capture("merchant_named_preview")
 game.touch_ux.close_dialog();assert(game.coins==balance and game.inventory.stash.size()==count)
 # Perks preview before separate commit, even under fresh repeated Attack taps.
 game.state="playing";game.pending_levels=1;game.show_upgrade_choices();var perks:Dictionary=game.upgrade_counts.duplicate(true)
 for i in range(15):await contact(attack,true);await contact(attack,false)
 assert(game.upgrade_selection==-1 and game.upgrade_counts==perks)
 await tap(game.upgrade_buttons[0]);assert(game.upgrade_counts==perks)
 # Consecutive perks reuse one panel: identity alone must not retain contact ownership.
 game.pending_levels=2;game.show_upgrade_choices();await tap(game.upgrade_buttons[0]);await wait_real(220)
 var generation:int=game.touch_ux.input_generation
 var take:Vector2=game.upgrade_take_button.get_global_rect().get_center()
 await contact(take,true,1);await tap(game.upgrade_take_button)
 assert(game.pending_levels==1 and game.state=="upgrade" and game.touch_ux.input_generation>generation and game.touch_ux.release_barrier)
 for i in range(12):await contact(take,true);await contact(take,false)
 assert(game.pending_levels==1 and game.upgrade_selection==-1)
 await contact(take,false,1);assert(not game.touch_ux.release_barrier)
 var old_band:Rect2=game.combat_controls.attack.get_global_rect()
 for button in [game.merchant_buy_button,game.merchant_reroll_button,game.upgrade_take_button]:
  assert(not button.get_global_rect().intersects(old_band),"Action still overlaps former Attack area: %s / %s / %s" % [button.text,button.get_global_rect(),old_band])
 game.show_hideout();game.presentation_director.finish_travel();game.presentation_director.vignette.finish();var h=game.hideout_ui;h.show_forge()
 assert(not h.forge_confirm.get_global_rect().intersects(old_band))
 await capture("forge_safe_layout")
 # Two consecutive confirmation surfaces cannot inherit a held second finger.
 game.touch_ux.request("First confirmation","Opens another modal",func():game.touch_ux.request("Second confirmation","Requires all fingers released and a new press",func():actions+=100))
 await wait_real(250)
 var point:Vector2=game.touch_ux.confirm_button.get_global_rect().get_center()
 await contact(point,true,1);await contact(point,true);await contact(point,false)
 assert(is_instance_valid(game.touch_ux.dialog) and game.touch_ux.release_barrier)
 var before:=actions
 for i in range(12):await contact(point,true);await contact(point,false)
 await contact(point,false,1);assert(actions==before)
 await wait_real(220);await tap(game.touch_ux.confirm_button);assert(actions==before+100)
 # Permanent salvage never happens on a preview tap or cancelled confirmation.
 var item:Dictionary=preload("res://item_catalog.gd").create_item("scrapfang_blade","COMMON",987)
 game.inventory.keep(item);game.refresh_hideout();h.show_stash()
 for i in range(h.entries.size()):
  if not h.entries[i].equipped and game.inventory.stash[h.entries[i].stash_index].serial==987:h.select_entry(i);break
 await wait_real(350)
 var scrap:int=game.inventory.scrap;count=game.inventory.stash.size()
 var equipped:Dictionary=game.inventory.equipped_item("Weapon").duplicate(true)
 for button in [h.stash_equip_button,h.stash_scrap_button]:assert(not button.get_global_rect().intersects(old_band))
 for i in range(15):await contact(attack,true);await contact(attack,false)
 assert(game.inventory.scrap==scrap and game.inventory.stash.size()==count and game.inventory.equipped_item("Weapon")==equipped)
 await tap(h.stash_scrap_button);assert(is_instance_valid(game.touch_ux.dialog) and game.inventory.scrap==scrap and game.inventory.stash.size()==count)
 game.touch_ux.close_dialog();assert(game.inventory.scrap==scrap and game.inventory.stash.size()==count)
 print("ACTUAL CONSEQUENCE PASS: no Attack-spam purchase/perk/equip/salvage; named preview/cancel; long hold; consecutive modals; action geometry")

func wait_real(milliseconds:int) -> void:
 var until:int=Time.get_ticks_msec()+milliseconds
 while Time.get_ticks_msec()<until:await process_frame
